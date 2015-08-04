#define MOD_LUA_MODIFY_UNIT
<<
function change_side(new_side)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   unit.side = new_side
end

function change_unit_max_hitpoints(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   -- Full health units stay at full health. Units with more health
   -- than the new max have to lose health.
   if unit.hitpoints == unit.max_hitpoints
   or unit.hitpoints > change then
      unit.hitpoints = change
   end
   unit.max_hitpoints = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit_max_moves(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   if unit.moves == unit.max_moves then
      unit.moves = change
   end
   unit.max_moves = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit_max_experience(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.max_experience = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit_stat(stat)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local unit_data = unit.__cfg

   if stat ~= "Gender" and stat ~= "Leader" then
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "What should the new value of "..stat.." be?",
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T["text_input"] {
                         variable  = "new_stat_change",
                         label     = "Unit:",
                         max_chars = 50
                      }
                   }
                )
   end

   local change = wesnoth.get_variable("new_stat_change")

   if stat == "Hitpoints" then
      unit_data.hitpoints = change
   elseif stat == "Max Hitpoints" then
      change_unit_max_hitpoints(e.x1, e.y1, change)
   elseif stat == "Moves" then
      change_unit_max_moves(e.x1, e.y1, change)
   elseif stat == "Experience" then
      unit_data.experience = change
   elseif stat == "Max Experience" then
      change_unit_max_experience(e.x1, e.y1, change)
   elseif stat == "Gender" then
      if unit_data.gender == "male" then
         unit_data.gender = "female"
      elseif unit_data.gender == "female" then
         unit_data.gender = "male"
      end
   elseif stat == "Leader" then
      if unit_data.canrecruit == true then
         unit_data.canrecruit = false
      else
         unit_data.canrecruit = true
      end
   end
   if not (stat == "Max Hitpoints" or stat == "Moves" or stat == "Max Experience") then
      wesnoth.put_unit(e.x1, e.y1, unit_data)
   end

   -- Makes sure that the summoner crown shows on non-leader summoners.
   if unit_data.role ~= "None" and unit_data.role ~= "" then
      if unit_data.canrecruit == true then
         wesnoth.wml_actions.remove_unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}
      else
         wesnoth.wml_actions.unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}
      end
   end
end

function change_stats(variable)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)

   local function transform()
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "What unit do you want it to transform to?",
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T["text_input"] {
                         variable  = "transform_unit_to",
                         label     = "Unit:",
                         max_chars = 50
                      }
                   }
                )

      local new_unit = wesnoth.get_variable("transform_unit_to")

      -- checks to make sure the unit type is valid
      for unit_type, i in pairs(wesnoth.unit_types) do
         if unit_type == new_unit then
            wesnoth.transform_unit(unit, new_unit)
            unit.hitpoints = unit.max_hitpoints
         end
      end
   end

   local function role()
      local function get_roles()
         local roles = {}

         for i, v in ipairs(SUMMON_ROLES) do
            roles[i] = SUMMON_ROLES[i]
         end

         table.insert(roles, "None")

         return roles
      end

      options_list_short("Select a new role for the unit.",
                         "wesnoth.set_variable('change_role', '$input1')",
                         get_roles())

      local chosen_role = wesnoth.get_variable('change_role')

      unit.role = chosen_role

      if chosen_role ~= "None" and unit.canrecruit ~= true then
         wesnoth.wml_actions.unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}

      elseif chosen_role == "None" then
         wesnoth.wml_actions.remove_unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}
      end
   end

   local function side()
      options_list_short("Select a target side.",
                         "change_side($input1)",
                         SIDES)
   end

   local function stats()
      local stats = {"Hitpoints", "Max Hitpoints", "Moves",
                     "Experience", "Max Experience", "Gender",
                     "Leader"}

      options_list_short("What stat do you want to change?",
                         "change_unit_stat('$input1')",
                         stats)
   end

   if variable == "Transform"     then transform()
   elseif variable == "Role"      then role()
   elseif variable == "Inventory" then submenu_inventory('unit_add', false)
   elseif variable == "Side"      then side()
   elseif variable == "Stats"     then stats()
   elseif variable == "Save"      then
      -- fixme: finish
      wesnoth.wml_actions.set_global_variable{namespace="MoD"}
   end
end

function menu_unit_change_stats()
   local title = "Change Unit"
   local description = "What stat do you want to modify?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Side", "Inventory", "Transform", "Role", "Stats", "Save"}
   local choice = menu(options, image, title, description, menu_simple_list)
   if choice then
      change_stats(choice)
   end
end

function menu_item_unit_change_stats()
   local menu_id = "021_Unit_Change_Stats"
   local menu_desc = "Change Unit"
   local menu_image = "misc/icon-amla-tough.png"
   local filter = filter_host("unit")
   wesnoth.fire("set_menu_item", {
                   id          = menu_id,
                   description = menu_desc,
                   image       = menu_image,
                   filter,
                   T["command"] { T["lua"] { code = "menu_unit_change_stats()" }}})
end

function option_unit_message()
   wesnoth.fire("message", {
                   speaker  = "unit",
                   caption  = "Unit Message",
                   message  = "What will you say?",
                   show_for = side_number,
                   T["text_input"] {
                      variable  = "aeth_custom_message",
                      label     = "Type Here:",
                      max_chars = 50
                   }
                }
             )

   local message = wesnoth.get_variable('aeth_custom_message')

   if message ~= "" then
      wesnoth.fire("message", {
                      side    = side_number,
                      speaker = "unit",
                      message = "$aeth_custom_message"
                   }
                )
   end
end

function modify_unit()
   menu_item_unit_change_stats()
end
>>
#enddef
