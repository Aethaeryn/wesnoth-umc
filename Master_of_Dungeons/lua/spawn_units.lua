#define MOD_LUA_SPAWN_UNITS
<<
-- These are impassable terrains, used to blacklist summoning there.
local BAD_TERRAIN  = "X*, Q*, *^Xm, Mv"

-- Turns a simple table of units or options into one that includes the type.
function add_type(units, type)
   local new_table = {}

   for i, v in ipairs(units) do
      table.insert(new_table, {v, type})
   end

   return new_table
end

function boss_spawner(unit_type, unit_role)
   local e = wesnoth.current.event_context

   local unit_traits_boss = wesnoth.get_variable("unit_traits_boss")
   local regenerates      = wesnoth.get_variable("regenerates")

   wesnoth.put_unit(e.x1, e.y1, {
                       type     = unit_type,
                       side     = side_number,
                       overlays = "misc/hero-icon.png",
                       role     = unit_role, {
                          "modifications",
                          unit_traits_boss
                       }
                    }
                 )
   
   unit = wesnoth.get_unit(e.x1, e.y1)
   
   wesnoth.add_modification(unit, "object", {
                               T["effect"] {
                                  apply_to = "new_ability", {
                                     "abilities", regenerates
                                  }
                               }
                            }
                         )
end

function reg_spawner(unit_type, unit_role, unit_cost)
   local e = wesnoth.current.event_context

   local unit_traits_reg = wesnoth.get_variable("unit_traits_reg")
   local role_summoners  = wesnoth.get_units {side = side_number, role = unit_role}
   local max_hp          = 0
   
   -- This goes over all the possible summoners and chooses one with the highest HP in the area. --
   for key,value in pairs(role_summoners) do
      if role_summoners[key].x <= e.x1 + 1 and role_summoners[key].x >= e.x1 - 1 then
         if role_summoners[key].y <= e.y1 + 1 and role_summoners[key].y >= e.y1 -1 then
            if role_summoners[key].hitpoints > max_hp then
               max_hp  = role_summoners[key].hitpoints
               max_key = key
            end
         end
      end
   end

   -- Creates the unit if there is enough HP --
   if role_summoners[max_key].hitpoints > unit_cost then
      role_summoners[max_key].hitpoints = role_summoners[max_key].hitpoints - unit_cost
      wesnoth.put_unit(e.x1, e.y1, {
                          type = unit_type,
                          side = side_number, {
                             "modifications",
                             unit_traits_reg
                          }
                       }
                    )
   else
      wesnoth.message("Error", "Insufficient hitpoints on the attempted summoner.")
   end
end

function menu_boss(type)
   local options = DungeonOpt:new{
      root_message   = "Select a unit to summon.",
      option_message = "&$unit_image~RC(magenta>red)=$input1",
      code           = "boss_spawner('$input1','$input2')"
   }

   options.image_string = PORTRAIT[type]
   options:fire(add_type(summoners[type], type))
end

function menu_reg(level, type)
   local options = DungeonOpt:new {
      root_message   = "Select a unit to summon.",
      option_message = "&$unit_image~RC(magenta>red)=$input1 - $unit_cost HP",
      code           = "reg_spawner('$input1', '$input2', $unit_cost)"
   }

   options.image_string = PORTRAIT[type]
   options:fire(add_type(regular[type][level], type))
end

function menu_reg_levels(type)
   local options = DungeonOpt:new {
      root_message   = "Select a unit level.",
      option_message = "$input1",
      code           = "menu_reg('$input1', '$input2')"
   }

   local levels = {}

   for key, value in pairs(regular[type]) do
      table.insert(levels, key)
   end

   table.sort(levels)

   options:fire(add_type(levels, type))
end

function menu_boss_type()
   local options = DungeonOpt:new{
      root_message   = "Select a unit to summon.",
      image_string   = "portraits/undead/transparent/lich.png",
      option_message = "$input1",
      code           = "menu_boss('$input1')"
   }

   options:short_fire(SUMMON_ROLES)
end

function menu_item_summon_summoner()
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
                            terrain = BAD_TERRAIN 
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
                         code = "menu_boss_type()"
                      }
                   }
                }
             )
end

function menu_item_summon(unit_role)
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
                         terrain = BAD_TERRAIN,
                         -- this is prevents spawning over another unit
                         T["or"] {
                            T["filter"] { }
                         }
                      }
                   },
                   T["command"] {
                      T["lua"] {
                         code = "menu_reg_levels('"..unit_role.."')"
                      }
                   }
                }
             )
end

function spawn_units()
   menu_item_summon_summoner()

   for k, v in pairs(summoners) do
      menu_item_summon(k)
   end
end
>>
#enddef
