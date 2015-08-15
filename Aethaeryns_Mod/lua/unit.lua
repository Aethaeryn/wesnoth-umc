#define MOD_LUA_UNIT
<<
change_unit = {}
spawn_unit = {}
units_with_effects = {}
change_unit.max_level = 1

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

local function add_drunk_effect(unit)
   local wml_effect_1 = T.effect { apply_to = "attack", range = "melee", T.set_specials { mode = "append",
                                                                                          T.special { wesnoth.get_variable("berserk")}}}
   local wml_effect_2 = T.effect { apply_to = "attack", remove_specials = "marksman" }
   wesnoth.add_modification(unit, "object", { duration = "turn", wml_effect_1, wml_effect_2})
end

function change_unit.add_turn_effect(x, y, effect, turns, refresh)
   local unit = wesnoth.get_unit(x, y)
   if effect == "haste" then
      local wml_effect_ability = T.effect { apply_to = "new_ability",
                                            T.abilities {
                                               T.dummy { name = _ "haste",
                                                         description = _ "This unit has an extra strike and two extra moves." }}}
      if unit.variables["haste"] == nil or unit.variables["haste"] == 0 or refresh ~= nil then
         if refresh == nil then
            unit.variables["haste"] = (turns - 1)
            if unit.variables["confidence"] == nil or unit.variables["confidence"] == 0 then
               table.insert(units_with_effects, unit)
            end
         end
         if unit.moves == unit.max_moves then
            unit.moves = unit.moves + 2
         end
         local wml_effect = T.effect { apply_to = "movement", increase = 2 }
         local wml_effect_2 = T.effect { apply_to = "attack", increase_attacks = 1 }
         wesnoth.add_modification(unit, "object", { duration = "turn", wml_effect, wml_effect_2, wml_effect_ability })
      elseif unit.variables["haste"] > 0 then
         unit.variables["haste"] = unit.variables["haste"] + (turns - 1)
      end
   elseif effect == "confidence" then
      local wml_effect_ability = T.effect { apply_to = "new_ability",
                                            T.abilities {
                                               T.dummy { name = _ "confidence",
                                                         description = _ "This unit has +5 HP." }}}
      local ability_drunk = T.effect { apply_to = "new ability",
                                       T.abilities {
                                          T.dummy { name = _ "drunk",
                                                    description = _ "This unit is very, very drunk." }}}
      if unit.variables["confidence"] == nil or unit.variables["confidence"] == 0 or refresh ~= nil then
         if refresh == nil then
            unit.variables["confidence"] = (turns - 1)
            if unit.variables["haste"] == nil or unit.variables["haste"] == 0 then
               table.insert(units_with_effects, unit)
            end
         end
         if unit.hitpoints == unit.max_hitpoints then
            unit.hitpoints = unit.hitpoints + 5
         end
         local wml_effect = T.effect { apply_to = "hitpoints", increase_total = 5 }
         if refresh ~= nil and unit.variables["drunk"] ~= nil and unit.variables["drunk"] >= 0 then
            add_drunk_effect(unit)
         elseif refresh == nil then
            local become_drunk = helper.rand("no,no,no,yes")
            if become_drunk then
               unit.variables["drunk"] = unit.variables["confidence"]
               add_drunk_effect(unit)
            end
         end
         if unit.variables["drunk"] ~= nil and unit.variables["drunk"] > 0 then
            wml_effect_ability = ability_drunk
         end
         wesnoth.add_modification(unit, "object", { duration = "turn", wml_effect, wml_effect_ability })
      elseif unit.variables["confidence"] > 0 then
         unit.variables["confidence"] = unit.variables["confidence"] + (turns - 1)
         if unit.variables["drunk"] ~= nil and unit.variables["drunk"] > 0 then
            unit.variables["drunk"] = unit.variables["confidence"]
         else
            local become_drunk = helper.rand("no,no,no,yes")
            debugOut(become_drunk)
            if become_drunk then
               unit.variables["drunk"] = unit.variables["confidence"]
               add_drunk_effect(unit)
            end
         end
      end
   end
end

-- Any [object] effects will only last until turn refresh. If there is
-- a multi-turn effect still in progress, then it needs to be added
-- again at turn refresh manually.
function change_unit.update_turn_effects()
   local finished_units = {}
   for i, unit in ipairs(units_with_effects) do
      if unit.side == wesnoth.current.side then
         if unit.variables["haste"] ~= nil and unit.variables["haste"] > 0 then
            unit.variables["haste"] = unit.variables["haste"] - 1
            change_unit.add_turn_effect(unit.x, unit.y, "haste", 0, true)
         end
         if unit.variables["confidence"] ~= nil and unit.variables["confidence"] > 0 then
            unit.variables["confidence"] = unit.variables["confidence"] - 1
            if unit.variables["drunk"] ~= nil and unit.variables["drunk"] > 0 then
               unit.variables["drunk"] = unit.variables["drunk"] - 1
            end
            change_unit.add_turn_effect(unit.x, unit.y, "confidence", 0, true)
         end
         if (unit.variables["haste"] == nil or unit.variables["haste"] == 0)
         and (unit.variables["confidence"] == nil or unit.variables["confidence"] == 0) then
            table.insert(finished_units, 1, i)
         end
      end
   end
   -- Units done with effects need to be removed separately so the
   -- table index doesn't shift until the end. The removal has to be
   -- in reverse index order.
   for i, j in ipairs(finished_units) do
      table.remove(units_with_effects, j)
   end
end

function change_unit.death_cleanup()
   local e = wesnoth.current.event_context
   local dead_unit = wesnoth.get_unit(e.x1, e.y1)
   for i, unit in ipairs(units_with_effects) do
      if unit.x == dead_unit.x and unit.y == dead_unit.y then
         table.remove(units_with_effects, i)
      end
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
