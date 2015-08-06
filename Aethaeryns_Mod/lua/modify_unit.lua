#define MOD_LUA_MODIFY_UNIT
<<
change_unit = {}

function change_unit.side(x, y, new_side)
   local unit = wesnoth.get_unit(x, y)
   unit.side = new_side
end

function change_unit.hitpoints(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.hitpoints = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit.max_hitpoints(x, y, change)
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

function change_unit.max_moves(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   if unit.moves == unit.max_moves then
      unit.moves = change
   end
   unit.max_moves = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit.experience(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.experience = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit.max_experience(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.max_experience = change
   wesnoth.put_unit(x, y, unit)
end

function change_unit.gender(x, y)
   local unit = wesnoth.get_unit(x, y).__cfg
   if unit.gender == "male" then
      unit.gender = "female"
   elseif unit.gender == "female" then
      unit.gender = "male"
   end
   wesnoth.put_unit(x, y, unit)
end

function change_unit.leader(x, y)
   local unit = wesnoth.get_unit(x, y).__cfg
   if unit.canrecruit == true then
      unit.canrecruit = false
   else
      unit.canrecruit = true
   end
   wesnoth.put_unit(x, y, unit)
   if unit.role ~= "None" and unit.role ~= "" then
      if unit.canrecruit == true then
         wesnoth.wml_actions.remove_unit_overlay{x = x, y = y, image = "misc/hero-icon.png"}
      else
         wesnoth.wml_actions.unit_overlay{x = x, y = y, image = "misc/hero-icon.png"}
      end
   end
end

function change_unit_stat(stat)
   local e = wesnoth.current.event_context
   stat = string.gsub(string.lower(stat), " ", "_")
   if stat ~= "gender" and stat ~= "leader" then
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
   change_unit[stat](e.x1, e.y1, change)
end

local function transform(unit)
   wesnoth.fire("message", {
                   speaker  = "narrator",
                   message  = "What unit do you want it to transform to?",
                   image    = "wesnoth-icon.png",
                   show_for = side_number,
                   T["text_input"] {
                      variable  = "transform_unit_to",
                      label     = "Unit:",
                      max_chars = 50 }})

   local new_unit = wesnoth.get_variable("transform_unit_to")

   -- checks to make sure the unit type is valid
   for unit_type, i in pairs(wesnoth.unit_types) do
      if unit_type == new_unit then
         wesnoth.transform_unit(unit, new_unit)
         unit.hitpoints = unit.max_hitpoints
      end
   end
end

local function get_roles()
   local roles = {}
   for i, v in ipairs(SUMMON_ROLES) do
      roles[i] = SUMMON_ROLES[i]
   end
   table.insert(roles, "None")
   return roles
end

function menu_unit_change_stats()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local title = "Change Unit"
   local description = "What stat do you want to modify?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Side", "Inventory", "Transform", "Role", "Stats"}
   local choice = menu(options, image, title, description, menu_simple_list)
   if choice then
      if choice == "Transform" then
         transform(unit)
      elseif choice == "Role" then
         local chosen_role = menu(get_roles(), image, title, "Select a new (summoning) role for this unit.", menu_simple_list)
         unit.role = chosen_role
         if chosen_role ~= "None" and unit.canrecruit ~= true then
            wesnoth.wml_actions.unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}
         elseif chosen_role == "None" then
            wesnoth.wml_actions.remove_unit_overlay{x = e.x1, y = e.y1, image = "misc/hero-icon.png"}
         end
      elseif choice == "Inventory" then
         submenu_inventory('unit_add', false)
      elseif choice == "Side" then
         local side = menu(SIDES, image, title, "Select a target side.", menu_simple_list)
         if side then
            change_unit.side(e.x1, e.y1, side)
         end
      elseif choice == "Stats" then
         local stats = {"Hitpoints", "Max Hitpoints", "Max Moves",
                        "Experience", "Max Experience", "Gender",
                        "Leader"}
         local stat = menu(stats, image, title, "Which stat do you want to change?", menu_simple_list)
         if stat then
            change_unit_stat(stat)
         end
      end
   end
end

>>
#enddef
