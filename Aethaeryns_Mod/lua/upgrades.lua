#define MOD_LUA_UPGRADES
<<
is_amla = false

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

   -- Increment the unit's advancement points by one.
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
   -- -- For debugging/testing, uncomment this and comment the test that
   -- -- you have enough to pay for upgrades.
   if unit.variables["advancement"] == nil then
      unit.variables["advancement"] = 0
   end
   if unit.variables["advancement"] ~= nil -- and unit.variables["advancement"] >= cost
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
      wesnoth.message("Error", "You cannot get that upgrade right now.")
   end
end

function menu_upgrade_unit()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local points = unit.variables["advancement"]
   local options_table = {}
   if points == nil then
      points = 0
   end
   for i, upgrade in ipairs(upgrade_table) do
      local cap_info = ""
      local current_advancement = unit.variables["upgrade"..upgrade.name]
      if current_advancement == nil then
         current_advancement = 0
      end
      if upgrade.cap then
         cap_info = " of "..upgrade.cap
      end
      table.insert(options_table, {upgrade.name,
                                   upgrade.image,
                                   upgrade.cost,
                                   current_advancement,
                                   cap_info,
                                   upgrade.msg,
                                   upgrade.cap})
   end
   local options = DungeonOpt:new{
      root_message = "What do you want to upgrade? You have "..points.." points(s).",
      option_message = "&$input2=<b>$input1</b>\nCost: $input3 points\nCurrent: $input4$input5\n$input6",
      code = "upgrade_unit('$input1', $input3, $input4, $input7)",
   }
   options:fire(options_table)
end

>>
#enddef
