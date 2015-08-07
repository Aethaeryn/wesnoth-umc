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

function change_unit.transform(x, y, new_unit)
   local unit = wesnoth.get_unit(x, y)
   -- Only transforms if a valid unit was input.
   for unit_type, i in pairs(wesnoth.unit_types) do
      if unit_type == new_unit then
         wesnoth.transform_unit(unit, new_unit)
         unit.hitpoints = unit.max_hitpoints
      end
   end
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
