#define MOD_LUA_INVENTORY
<<
if containers == nil then
   containers = {}
end

mod_inventory = {}

local function check_x_coord(x)
   if containers[x] == nil then
      containers[x] = {}
   end
end

function mod_inventory.chest_add(x, y, name)
   local unit = wesnoth.get_unit(x, y)
   check_x_coord(x)
   containers[x][y]["chest"][name] = containers[x][y]["chest"][name] + 1
   unit.variables[name] = unit.variables[name] - 1
end

function mod_inventory.chest_remove(e, y, name)
   local unit = wesnoth.get_unit(x, y)
   check_x_coord(x)
   containers[x][y]["chest"][name] = containers[x][y]["chest"][name] - 1
   if unit.variables[name] == nil then
      unit.variables[name] = 1
   else
      unit.variables[name] = unit.variables[name] + 1
   end
end

function clear_game_object(x, y)
   w_items.remove(x, y)
   if containers[x] ~= nil then
      containers[x][y] = nil
   end
end

function simple_place(x, y, container_type, image, inventory)
   clear_game_object(x,y)
   w_items.place_image(x, y, image)
   check_x_coord(x)
   containers[x][y] = {}
   containers[x][y][container_type] = {}
   if inventory == true then
      for i, v in ipairs(item_table) do
         item_name = v["name"]
         containers[x][y][container_type][item_name] = 0
      end
   end
   if container_type == "shop" then
      fire.label(x, y, "Shop")
   end
end

function place_gold(x, y, gold)
   local gold_image = "items/gold-coins-medium.png"
   if gold < 20 then
      gold_image = "items/gold-coins-small.png"
   elseif gold >= 50 then
      gold_image = "items/gold-coins-large.png"
   end

   simple_place(x, y, "gold", gold_image, false)
   check_x_coord(x)
   containers[x][y]["gold"] = gold
end

function item_use(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   unit.variables[name] = unit.variables[name] - 1
   if name == "Coins" then
      wesnoth.sides[side_number].gold = wesnoth.sides[side_number].gold + 10
   elseif name == "Small Healing Potion" then
      change_unit.heal(e.x1, e.y1, 6)
   elseif name == "Healing Potion" then
      change_unit.heal(e.x1, e.y1, 14)
   end
end

function add_unit_item(name, quantity)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   if unit.variables[name] == nil then
      unit.variables[name] = quantity
   else
      unit.variables[name] = unit.variables[name] + quantity
   end
end

function add_container_item(name, quantity, container)
   if container[name] == nil then
      container[name] = quantity
   else
      container[name] = container[name] + quantity
   end
end

function shop_buy(name, side_number)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local price = 99999
   check_x_coord(e.x1)
   for i, item in ipairs(item_table) do
      if item.name == name then
         price = item.price
      end
   end
   if wesnoth.sides[side_number]["gold"] >= price then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] - price
      containers[e.x1][e.y1]["shop"][name] = containers[e.x1][e.y1]["shop"][name] - 1
      if unit.variables[name] == nil then
         unit.variables[name] = 1
      else
         unit.variables[name] = unit.variables[name] + 1
      end
   else
      gui2_error("You can't afford that!")
   end
end

function find_interactions(x, y)
   local interactions = {}
   check_x_coord(x)
   if containers[x][y] ~= nil then
      if containers[x][y]["shop"] ~= nil then
         table.insert(interactions, 1, {"Visit Shop", "scenery/tent-shop-weapons.png"})
      elseif containers[x][y]["chest"] ~= nil then
         table.insert(interactions, 1, {"Remove from Chest", "items/chest-plain-closed.png"})
         table.insert(interactions, 2, {"Add to Chest", "items/chest-plain-closed.png"})
      elseif containers[x][y]["pack"] ~= nil then
         table.insert(interactions, 1, {"Investigate Drop", "items/leather-pack.png"})
      elseif containers[x][y]["gold"] ~= nil then
         table.insert(interactions, 1, {"Collect Gold", "icons/coins_copper.png"})
      end
   end
   return interactions
end

function find_interactions_to_modify(x, y)
   local interactions = {}
   check_x_coord(x)
   if containers[x][y] ~= nil then
      if containers[x][y]["shop"] ~= nil then
         table.insert(interactions, 1, {"Modify Shop", "scenery/tent-shop-weapons.png"})
      elseif containers[x][y]["chest"] ~= nil then
         table.insert(interactions, 1, {"Modify Chest", "items/chest-plain-closed.png"})
      elseif containers[x][y]["pack"] ~= nil then
         table.insert(interactions, 1, {"Modify Drop", "items/leather-pack.png"})
      elseif containers[x][y]["gold"] ~= nil then
         table.insert(interactions, 1, {"Modify Gold", "icons/coins_copper.png"})
      end
   end
   return interactions
end

function show_current_inventory(item_holder)
   local options = {}
   for i, item in ipairs(item_table) do
      quantity = item_holder[item.name]
      if quantity ~= nil and quantity > 0 then
         table.insert(options, {item.name, item.image, item.price, item.msg, quantity})
      end
   end
   return options
end

function show_all_inventory()
   local options = {}
   for i, item in ipairs(item_table) do
      table.insert(options, {item.name, item.image, item.price, item.msg})
   end
   return options
end
>>
#enddef
