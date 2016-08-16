#define MOD_LUA_UNIT
<<
change_unit = {}
units_with_effects = {}
change_unit.max_level = 1

function change_unit.max_moves_doubler(x, y)
   local unit = wesnoth.get_unit(x, y)
   wesnoth.add_modification(unit,
                            "object", { T["effect"] {
                                           apply_to = "movement",
                                           increase = "100%" }})
   unit.moves = unit.max_moves
end

function change_unit.set_max_level(option)
   change_unit.max_level = option
end

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

function change_unit.heal(x, y, change)
   local unit = wesnoth.get_unit(x, y)
   if unit.status.poisoned then
      unit.status.poisoned = false
      change = change - 8
   end
   if change > 0 then
      if unit.hitpoints + change >= unit.max_hitpoints then
         unit.hitpoints = unit.max_hitpoints
      else
         unit.hitpoints = unit.hitpoints + change
      end
   end
end

function change_unit.moves(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.moves = change
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

function change_unit.gender(x, y, gender)
   local unit = wesnoth.get_unit(x, y).__cfg
   if gender ~= nil then
      unit.gender = gender
   else
      if unit.gender == "male" then
         unit.gender = "female"
      elseif unit.gender == "female" then
         unit.gender = "male"
      end
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

function change_unit.transform(x, y, new_unit, gender)
   local unit = wesnoth.get_unit(x, y)
   -- Only transforms if a valid unit was input.
   for unit_type, unit_data in pairs(wesnoth.unit_types) do
      if unit_type == new_unit then
         -- Gender must change first for single-gender target units.
         if unit_data.__cfg.gender == "female" and unit.__cfg.gender ~= "female" then
            change_unit.gender(x, y)
         -- Yes, in Wesnoth male is literally the default.
         elseif unit_data.__cfg.gender == nil and unit.__cfg.gender == "female" then
            change_unit.gender(x, y)
         elseif unit_data.__cfg.gender == "male,female" and gender ~= nil then
            change_unit.gender(x, y, gender)
         end
         wesnoth.transform_unit(unit, new_unit)
         unit.hitpoints = unit.max_hitpoints
         unit.moves = unit.max_moves
         return
      end
   end
end

function change_unit.transform_keeping_stats(x, y, unit, new_unit)
   local damaged = unit.max_hitpoints - unit.hitpoints
   local moves = unit.moves
   unit.variables.disguised_from = unit.type
   change_unit.transform(x, y, new_unit)
   if damaged > unit.max_hitpoints then
      unit.hitpoints = 1
   else
      unit.hitpoints = unit.max_hitpoints - damaged
   end
   unit.moves = moves
end

function change_unit.role(x, y, new_role)
   local unit = wesnoth.get_unit(x, y)
   unit.role = new_role
   if new_role ~= "None" and unit.canrecruit ~= true then
      wesnoth.wml_actions.unit_overlay{x = x, y = y, image = "misc/hero-icon.png"}
   elseif new_role == "None" then
      wesnoth.wml_actions.remove_unit_overlay{x = x, y = y, image = "misc/hero-icon.png"}
   end
end
>>
#enddef
