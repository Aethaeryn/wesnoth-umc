#define MOD_LUA_UPGRADES
<<
is_amla = false

function event_post_advance()
   if is_amla == true then
      local e = wesnoth.current.event_context
      local unit = wesnoth.get_unit(e.x1, e.y1).__cfg

      unit.max_hitpoints = unit.max_hitpoints - 3
      unit.hitpoints = unit.max_hitpoints

      wesnoth.put_unit(e.x1, e.y1, unit)

      is_amla = false
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

   -- If you have enough points, and you are not at the cap, then you
   -- lose as many upgrade points as the cost is and you gain the
   -- desired modifier on the unit being upgraded. The count of how
   -- many times you have that upgrade is incremented.
   debugOut(choice)
   debugOut(unit.name)
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
      if upgrade.cap then
         cap_info = " of "..upgrade.cap
      end
      table.insert(options_table, {upgrade.name, upgrade.image, upgrade.cost, 0, cap_info, upgrade.msg})
   end

   local options = DungeonOpt:new{
      root_message = "What do you want to upgrade? You have "..points.." points(s).",
      option_message = "&$input2=<b>$input1</b>\nCost: $input3 points\nCurrent: $input4$input5\n$input6",
      code = "upgrade_unit('$input1', $input3, $input4, '$input5')",
   }

   options:fire(options_table)
end

>>
#enddef
