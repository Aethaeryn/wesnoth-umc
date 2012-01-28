#define MOD_LUA_INVENTORY
<<
function use_coins()
   this_side.gold = this_side.gold + 10
end

function use_potion(potion, size)
   local event_data = wesnoth.current.event_context
   local unit = wesnoth.get_unit(event_data.x1, event_data.y1)
   if potion == "Healing" then
      local hp_effect = 14

      if size == "Small" then
         hp_effect = 6
      end

      if unit.hitpoints + hp_effect >= unit.max_hitpoints then
         unit.hitpoints = unit.max_hitpoints
      else
         unit.hitpoints = unit.hitpoints + hp_effect
      end
   end
end

function inventory()
   menu_item_inventory()
end
>>
#enddef
