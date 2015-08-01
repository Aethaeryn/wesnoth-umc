#define MOD_LUA_SPAWN_UNITS
<<
spawn_units = {}

-- These are impassable terrains, used to blacklist summoning there.
spawn_units.bad_terrain  = "X*, Q*, *^Xm, Mv"

-- Turns a simple table of units or options into one that includes the type.
local function add_type(units, type)
   local new_table = {}

   for i, v in ipairs(units) do
      table.insert(new_table, {v, type})
   end

   return new_table
end

-- This goes over all the possible summoners and chooses one with the highest HP in the area.
local function find_summoner(x, y, summoners)
   local max_hp = 0
   for key,value in pairs(summoners) do
      if summoners[key].x <= x + 1 and summoners[key].x >= x - 1 then
         if summoners[key].y <= y + 1 and summoners[key].y >= y -1 then
            if summoners[key].hitpoints > max_hp then
               max_hp  = summoners[key].hitpoints
               max_key = key
            end
         end
      end
   end
   return summoners[max_key]
end

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
   local unit_traits_boss = wesnoth.get_variable("unit_traits_boss")
   local regenerates      = wesnoth.get_variable("regenerates")
   spawn_unit(e.x1, e.y1, unit_type, side_number, "misc/hero-icon.png", unit_role, unit_traits_boss)
   local unit = wesnoth.get_unit(e.x1, e.y1)
   wesnoth.add_modification(unit, "object", {
                               T["effect"] {
                                  apply_to = "new_ability", {
                                     "abilities", regenerates
                                  }
                               }
                            }
                         )
end

function spawn_units.reg_spawner(unit_type, unit_role, unit_cost)
   local e = wesnoth.current.event_context
   local unit_traits_reg = wesnoth.get_variable("unit_traits_reg")
   local summoner = find_summoner(e.x1, e.y1, wesnoth.get_units {side = side_number, role = unit_role})
   if summoner.hitpoints > unit_cost then
      summoner.hitpoints = summoner.hitpoints - unit_cost
      spawn_unit(e.x1, e.y1, unit_type, side_number, false, false, unit_traits_reg)
   else
      wesnoth.message("Error", "Insufficient hitpoints on the attempted summoner.")
   end
end

function spawn_units.menu_boss(type)
   local options = DungeonOpt:new{
      root_message   = "Select a unit to summon.",
      option_message = "&$unit_image~RC(magenta>red)=$input1",
      code           = "spawn_units.boss_spawner('$input1','$input2')"
   }

   options.image_string = PORTRAIT[type]
   options:fire(add_type(summoners[type], type))
end

function spawn_units.menu_reg(level, type)
   local options = DungeonOpt:new {
      root_message   = "Select a unit to summon.",
      option_message = "&$unit_image~RC(magenta>red)=$input1 - $unit_cost HP",
      code           = "spawn_units.reg_spawner('$input1', '$input2', $unit_cost)"
   }

   options.image_string = PORTRAIT[type]
   options:fire(add_type(regular[type][level], type))
end

function spawn_units.menu_reg_levels(type)
   local options = DungeonOpt:new {
      root_message   = "Select a unit level.",
      option_message = "$input1",
      code           = "spawn_units.menu_reg('$input1', '$input2')"
   }

   local levels = {}

   for key, value in pairs(regular[type]) do
      table.insert(levels, key)
   end

   table.sort(levels)

   options:fire(add_type(levels, type))
end

function spawn_units.menu_boss_type()
   local options = DungeonOpt:new{
      root_message   = "Select a unit to summon.",
      image_string   = "portraits/undead/transparent/lich.png",
      option_message = "$input1",
      code           = "spawn_units.menu_boss('$input1')"
   }

   options:short_fire(SUMMON_ROLES)
end

function spawn_units.menu_item_summon_summoner()
   -- If they fire up the menu, then the boss selection menu is run.
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
                         code = "spawn_units.menu_boss_type()"
                      }
                   }
                }
             )
end

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
                         code = "spawn_units.menu_reg_levels('"..unit_role.."')"
                      }
                   }
                }
             )
end

function spawn_units.spawn_units()
   spawn_units.menu_item_summon_summoner()

   for k, v in pairs(summoners) do
      spawn_units.menu_item_summon(k)
   end
end
>>
#enddef
