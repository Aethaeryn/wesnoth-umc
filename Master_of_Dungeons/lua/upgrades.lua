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

function upgrade_unit(choice)
   debugOut(choice)
end

function menu_upgrade_unit()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local points = unit.variables["advancement"]

   if points == nil then
      points = 0
   end

   local upgrades = {"Foo", "Bar"}

   options_list_short("What do you want to upgrade? You have "..points.." points(s).",
                      "upgrade_unit('$input1')",
                      upgrades)
end

>>
#enddef
