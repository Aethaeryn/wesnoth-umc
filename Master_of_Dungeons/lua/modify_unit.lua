#define MOD_LUA_MODIFY_UNIT
<<
function change_side(new_side)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   unit.side = new_side
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
      local healthy = false

      if unit_data.hitpoints == unit_data.max_hitpoints then
         healthy = true
      end

      unit_data.max_hitpoints = change

      if healthy == true then
         unit_data.hitpoints = change
      end

   elseif stat == "Moves" then
      local unmoved = false

      if unit_data.moves == unit_data.max_moves then
         unmoved = true
      end

      unit_data.max_moves = change

      if unmoved == true then
         unit_data.moves = change
      end

   elseif stat == "Experience" then
      unit_data.experience = change

   elseif stat == "Max Experience" then
      unit_data.max_experience = change

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

   wesnoth.put_unit(e.x1, e.y1, unit_data)

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
   elseif variable == "Inventory" then submenu_inventory('unit_add')
   elseif variable == "Side"      then side()
   elseif variable == "Stats"     then stats()
   elseif variable == "Save"      then
      -- fixme: finish
      wesnoth.wml_actions.set_global_variable{namespace="MoD"}
   end
end

function menu_item_unit_change_stats()
   local options = DungeonOpt:new {
      menu_id        = "021_Unit_Change_Stats",
      menu_desc      = "Change Unit",
      menu_image     = "misc/icon-amla-tough.png",

      root_message   = "What stat do you want to modify?",
      option_message = "$input1",
      code           = "change_stats('$input1')",
   }

   options:menu({
                   {"Side"},
                   {"Inventory"},
                   {"Transform"},
                   {"Role"},
                   {"Stats"},
                   {"Save"}
                },
                filter_host("unit")
             )
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
