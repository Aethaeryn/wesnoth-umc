#define MOD_LUA_SPAWN_UNITS
<<
spawn_units = {}

-- These are impassable terrains, used to blacklist summoning there.
spawn_units.bad_terrain = "X*, Q*, *^Xm, Mv"

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
local function spawn_unit(x, y, unit_type, side_number, icon, unit_role, traits)
   local unit_stats = {type = unit_type,
                       side = side_number,
                       {"modifications", traits}}
   if icon then
      unit_stats.overlays = icon
   end
   if unit_role then
      unit_stats.role = unit_role
   end
   wesnoth.put_unit(x, y, unit_stats)
end

function spawn_units.boss_spawner(unit_type, unit_role)
   local e = wesnoth.current.event_context
   spawn_unit(e.x1, e.y1, unit_type, side_number, "misc/hero-icon.png", unit_role, wesnoth.get_variable("unit_traits_boss"))
   local regenerates = wesnoth.get_variable("regenerates")
   local boss_ability = { T["effect"] {
                             apply_to = "new_ability", {"abilities", regenerates}}}
   local unit = wesnoth.get_unit(e.x1, e.y1)
   wesnoth.add_modification(unit, "object", boss_ability)
end

function spawn_units.reg_spawner(unit_type, unit_role, unit_cost)
   local e = wesnoth.current.event_context
   local summoner = find_summoner(e.x1, e.y1, wesnoth.get_units {side = side_number, role = unit_role})
   if summoner.hitpoints > unit_cost then
      summoner.hitpoints = summoner.hitpoints - unit_cost
      spawn_unit(e.x1, e.y1, unit_type, side_number, false, false, wesnoth.get_variable("unit_traits_reg"))
   else
      wesnoth.message("Error", "Insufficient hitpoints on the attempted summoner.")
   end
end

function spawn_units.menu_summon(summoner_type)
   local title = string.format("Summon %s", summoner_type)
   local description = "Select a unit level."
   local image = PORTRAIT[summoner_type]
   local levels = {}
   for key, value in pairs(regular[summoner_type]) do
      table.insert(levels, key)
   end
   table.sort(levels)
   local level = menu(levels, image, title, description, menu_simple_list)
   if level then
      description = "Select a unit to summon."
      local choice = menu(regular[summoner_type][level], image, title, description, menu_unit_list)
      -- todo: add back in the lookup for each unit cost here.
      if choice then
         spawn_units.reg_spawner(choice, summoner_type, 10)
      end
   end
end

function spawn_units.menu_summon_summoner()
   local title = "Summon Summoner"
   local description = "Select a summoner type."
   local image = "portraits/undead/transparent/ancient-lich.png"
   local summoner_type = menu(SUMMON_ROLES, image, title, description, menu_simple_list)
   if summoner_type then
      description = "Select a unit to summon."
      local summoner = menu(summoners[summoner_type], image, title, description, menu_unit_list)
      if summoner then
         spawn_units.boss_spawner(summoner, summoner_type)
      end
   end
end

-- Right click menu that lets the Master summon a summoner on
-- unoccupied, good terrain.
function spawn_units.menu_item_summon_summoner()
   wesnoth.fire("set_menu_item", {
                   id          = "005_Summon_Summoner",
                   description = "Summon Summoner",
                   image       = "misc/new-battle.png",
                   T["show_if"] {
                      T["not"] {
                         T["have_location"] {
                            x = "$x1",
                            y = "$y1",
                            terrain = spawn_units.bad_terrain
                         },
                         T["or"] {
                            T["have_unit"] {
                               x = "$x1",
                               y = "$y1"
                            }
                         }
                      },
                      filter_host("summoner")
                   },
                   T["command"] {
                      T["lua"] {
                         code = "spawn_units.menu_summon_summoner()"
                      }
                   }
                }
             )
end

-- Right click menu that lets a summoner summon a regular unit on
-- unoccupied, adjacent, good terrain.
function spawn_units.menu_item_summon(unit_role)
   wesnoth.fire("set_menu_item", {
                   id          = "001_Summon_"..unit_role,
                   description = "Summon "..unit_role,
                   image       = "misc/cross-white.png",
                   T["filter_location"] {
                      x = "$x1",
                      y = "$y1",
                      T["filter_adjacent_location"] {
                         T["filter"] {
                            side = side_number,
                            role = unit_role
                         }
                      }, T["not"] {
                         terrain = spawn_units.bad_terrain,
                         -- this is prevents spawning over another unit
                         T["or"] {
                            T["filter"] { }
                         }
                      }
                   },
                   T["command"] {
                      T["lua"] {
                         code = "spawn_units.menu_summon('"..unit_role.."')"
                      }
                   }
                }
             )
end

-- I think this creates a [set_menu_item] for each summoner. Since
-- this fires on side-turn, maybe it can be optimized by only doing
-- this for summoners that are on the same side, but then it would
-- need to handle summoners who change teams to the active team during
-- the turn. I think this might be the only thing here that actually
-- needs to run on side_turn.
function spawn_units.spawn_units()
   spawn_units.menu_item_summon_summoner()
   for k, v in pairs(summoners) do
      spawn_units.menu_item_summon(k)
   end
end
>>
#enddef
