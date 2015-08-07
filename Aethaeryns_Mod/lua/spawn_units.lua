#define MOD_LUA_SPAWN_UNITS
<<
spawn_units = {}

-- This goes over all the possible summoners and chooses one with the
-- highest HP in the area.
local function find_summoner(x, y, summoners)
   local max_hp = 0
   for key,value in pairs(summoners) do
      if summoners[key].x <= x + 1 and summoners[key].x >= x - 1
         and summoners[key].y <= y + 1 and summoners[key].y >= y - 1
         and summoners[key].hitpoints > max_hp then
         max_hp  = summoners[key].hitpoints
         max_key = key
      end
   end
   return summoners[max_key]
end

-- This spawns a unit with unit_role (summoner type) and icon (image
-- overlay) as optional arguments.
local function spawn_unit(x, y, unit_type, side_number, icon, unit_role)
   local unit_stats = {type = unit_type,
                       side = side_number,
                       upkeep = 0}
   if icon then
      unit_stats.overlays = icon
   end
   if unit_role then
      unit_stats.role = unit_role
   end
   wesnoth.put_unit(x, y, unit_stats)
end

function spawn_units.boss_spawner(x, y, unit_type, unit_role)
   spawn_unit(x, y, unit_type, side_number, "misc/hero-icon.png", unit_role)
   local regenerates = wesnoth.get_variable("regenerates")
   local boss_ability = { T["effect"] {
                             apply_to = "new_ability", {"abilities", regenerates}}}
   local unit = wesnoth.get_unit(x, y)
   wesnoth.add_modification(unit, "object", boss_ability)
end

function spawn_units.reg_spawner(x, y, unit_type, unit_role)
   local unit_cost = wesnoth.unit_types[unit_type].__cfg.cost
   local summoner = find_summoner(x, y, wesnoth.get_units {side = side_number, role = unit_role})
   if summoner.hitpoints > unit_cost then
      summoner.hitpoints = summoner.hitpoints - unit_cost
      spawn_unit(x, y, unit_type, side_number, false, false)
      return true
   else
      return false
   end
end
>>
#enddef
