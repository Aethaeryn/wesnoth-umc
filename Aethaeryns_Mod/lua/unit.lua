#define MOD_LUA_UNIT
<<
change_unit = {}
spawn_unit = {}
units_with_effects = {}
change_unit.max_level = 1

function change_unit.set_max_level(option)
   change_unit.max_level = option
end

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

function change_unit.heal(x, y, change)
   local unit = wesnoth.get_unit(x, y)
   if unit.status.poisoned then
      unit.status.poisoned = false
      change = change - 8
   end
   if change > 0 then
      if unit.hitpoints + change >= unit.max_hitpoints then
         unit.hitpoints = unit.max_hitpoints
      else
         unit.hitpoints = unit.hitpoints + change
      end
   end
end

function change_unit.moves(x, y, change)
   local unit = wesnoth.get_unit(x, y).__cfg
   unit.moves = change
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

function change_unit.gender(x, y, gender)
   local unit = wesnoth.get_unit(x, y).__cfg
   if gender ~= nil then
      unit.gender = gender
   else
      if unit.gender == "male" then
         unit.gender = "female"
      elseif unit.gender == "female" then
         unit.gender = "male"
      end
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

function change_unit.transform(x, y, new_unit, gender)
   local unit = wesnoth.get_unit(x, y)
   -- Only transforms if a valid unit was input.
   for unit_type, unit_data in pairs(wesnoth.unit_types) do
      if unit_type == new_unit then
         -- Gender must change first for single-gender target units.
         if unit_data.__cfg.gender == "female" and unit.__cfg.gender ~= "female" then
            change_unit.gender(x, y)
         -- Yes, in Wesnoth male is literally the default.
         elseif unit_data.__cfg.gender == nil and unit.__cfg.gender == "female" then
            change_unit.gender(x, y)
         elseif unit_data.__cfg.gender == "male,female" and gender ~= nil then
            change_unit.gender(x, y, gender)
         end
         wesnoth.transform_unit(unit, new_unit)
         unit.hitpoints = unit.max_hitpoints
         unit.moves = unit.max_moves
         return
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

-- Chooses the adjacent summoner with the highest HP.
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

function haste(x, y, moves)
   wesnoth.add_modification(wesnoth.get_unit(x, y),
                            "object",
                            { duration = "turn",
                              T.effect { apply_to = "movement", increase = moves },
                              T.effect { apply_to = "attack", increase_attacks = 1 },
                              T.effect { apply_to = "new_ability",
                                         T.abilities { T.dummy { name = _ "haste",
                                                                 description = _ "This unit has extra attacks and movement." } } } })
end

-- Unit role is summoner type; icon and unit_role are optional.
function spawn_unit.spawn_unit(x, y, unit_type, side_number, icon, unit_role, gender)
   local unit_stats = {type = unit_type,
                       side = side_number,
                       upkeep = 0}
   if string.find(wesnoth.get_terrain(x, y), "%^V") ~= nil then
      fire.capture_village(x, y)
      unit_stats.moves = 0
   end
   if icon ~= nil then
      unit_stats.overlays = icon
   end
   if unit_role ~= nil then
      unit_stats.role = unit_role
   end
   if gender ~= nil then
      unit_stats.gender = gender
   end
   wesnoth.put_unit(x, y, unit_stats)
end

function spawn_unit.spawn_group(x, y, units, side_number)
   local hexes = wesnoth.get_locations { x = x, y = y, radius = 1 }
   local j = 1
   for i, unit in ipairs(units) do
      if wesnoth.get_unit(hexes[j][1], hexes[j][2]) == nil then
         spawn_unit.spawn_unit(hexes[j][1], hexes[j][2], unit, side_number)
      end
      j = j + 1
   end
end

function spawn_unit.boss_spawner(x, y, unit_type, unit_role, side_number)
   spawn_unit.spawn_unit(x, y, unit_type, side_number, "misc/hero-icon.png", unit_role)
   local regenerates = wesnoth.get_variable("regenerates")
   local boss_ability = { T["effect"] { apply_to = "new_ability", {"abilities", regenerates}}}
   local unit = wesnoth.get_unit(x, y)
   wesnoth.add_modification(unit, "object", boss_ability)
end

function spawn_unit.reg_spawner(x, y, unit_type, unit_role, side_number)
   local unit_cost = wesnoth.unit_types[unit_type].__cfg.cost
   local summoner = find_summoner(x, y, wesnoth.get_units {side = side_number, role = unit_role})
   if summoner.hitpoints > unit_cost then
      summoner.hitpoints = summoner.hitpoints - unit_cost
      spawn_unit.spawn_unit(x, y, unit_type, side_number)
      return true
   else
      return false
   end
end
>>
#enddef
