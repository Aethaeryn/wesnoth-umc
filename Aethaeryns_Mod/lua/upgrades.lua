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

function submenu_upgrade_unit()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local points = unit.variables["advancement"]
   local point_word = "points"
   local upgrades = {}
   local upgrade_info = {}
   if points == nil then
      points = 0
   end
   if points == 1 then
      point_word = "point"
   end
   for i, upgrade in ipairs(upgrade_table) do
      local upgrade_count = 0
      if unit.variables["upgrade"..upgrade.name] ~= nil then
         upgrade_count = unit.variables["upgrade"..upgrade.name]
      end
      table.insert(upgrades, {upgrade.name,
                              upgrade.image,
                              upgrade.cost,
                              upgrade_count,
                              upgrade.cap,
                              upgrade.msg})
      upgrade_info[upgrade.name] = { cost = upgrade.cost, cap = upgrade.cap }
   end
   local title = "Unit Commands"
   local description = string.format("What do you want to upgrade? You have %d %s available.", points, point_word)
   local upgrade = menu(upgrades, "", title, description, menu_picture_list, 1, "upgrade_stats")
   if upgrade then
      upgrade_unit(upgrade, upgrade_info[upgrade].cost, unit.variables["upgrade"..upgrade], upgrade_info[upgrade].cap)
   end
end

>>
#enddef
