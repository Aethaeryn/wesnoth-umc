#define MOD_LUA_UPGRADES
<<
is_amla = false

mod_upgrade = {}

function event_post_advance()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local unit_data = unit.__cfg
   -- No AMLA bonus HP.
   if is_amla == true then
      unit_data.max_hitpoints = unit_data.max_hitpoints - 3
      unit_data.hitpoints = unit_data.max_hitpoints
      wesnoth.put_unit(e.x1, e.y1, unit_data)
      is_amla = false
   -- If it's a regular promotion we need to keep the upgrades that
   -- were set.
   else
      unit_data.max_moves = unit_data.max_moves * 2
      wesnoth.put_unit(e.x1, e.y1, unit_data)
      if unit.variables["upgradeSpeed"] ~= nil then
         change_unit.max_moves(e.x1, e.y1, unit_data.max_moves + unit.variables["upgradeSpeed"])
      end
      if unit.variables["upgradeResilience"] ~= nil then
         change_unit.max_hitpoints(e.x1, e.y1, unit_data.max_hitpoints + (unit.variables["upgradeResilience"] * 4))
      end
      if unit.variables["upgradeIntelligence"] ~= nil then
         change_unit.max_experience(e.x1, e.y1, unit_data.max_experience * .8)
      end
   end
end

function event_advance()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local current_type = unit.type

   -- If no advancements to the unit exist, it is AMLAing, so subtract 3 HP.
   if unit.advances_to[1] == nil then
      is_amla = true
   end

   mod_upgrade.increment(unit)
end

function mod_upgrade.increment(unit)
   if unit.variables["advancement"] == nil then
      unit.variables["advancement"] = 1
   else
      unit.variables["advancement"] = unit.variables["advancement"] + 1
   end
end

function upgrade_unit(choice, cost, current, cap)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local unit_data = unit.__cfg
   -- if unit.variables["advancement"] == nil then
   --    unit.variables["advancement"] = 0
   -- end
   if unit.variables["advancement"] ~= nil and unit.variables["advancement"] >= cost
   and (cap == false or current < cap) then
      unit.variables["advancement"] = unit.variables["advancement"] - cost
      if unit.variables["upgrade"..choice] == nil then
         unit.variables["upgrade"..choice] = 1
      else
         unit.variables["upgrade"..choice] = unit.variables["upgrade"..choice] + 1
      end
      if choice == "Speed" then
         change_unit.max_moves(e.x1, e.y1, unit_data.max_moves + 1)
      elseif choice == "Resilience" then
         change_unit.max_hitpoints(e.x1, e.y1, unit_data.max_hitpoints + 4)
      elseif choice == "Strength" then
         debugOut("Strength is not yet implemented.")
      elseif choice == "Dexterity" then
         debugOut("Dexterity is not yet implemented.")
      elseif choice == "Intelligence" then
         change_unit.max_experience(e.x1, e.y1, unit_data.max_experience * .8)
      end
   else
      gui2_error("You cannot get that upgrade right now.")
   end
end
>>
#enddef
