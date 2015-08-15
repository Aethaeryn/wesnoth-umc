#define MOD_LUA_INVENTORY
<<
containers = {}
mod_inventory = {}
game_object = {}

function mod_inventory.transfer_item(unit, x, y, name, quantity)
   if quantity <= unit.variables[name] then
      local target_unit = wesnoth.get_unit(x, y)
      if target_unit.variables[name] == nil then
         target_unit.variables[name] = quantity
      else
         target_unit.variables[name] = target_unit.variables[name] + quantity
      end
      unit.variables[name] = unit.variables[name] - quantity
   end
end

function mod_inventory.chest_add(unit, x, y, name, quantity)
   if quantity <= unit.variables[name] then
      if containers[x][y]["chest"][name] == nil then
         containers[x][y]["chest"][name] = quantity
      else
         containers[x][y]["chest"][name] = containers[x][y]["chest"][name] + quantity
      end
      unit.variables[name] = unit.variables[name] - quantity
   end
end

function mod_inventory.chest_remove(unit, x, y, name, quantity)
   if quantity <= containers[x][y]["chest"][name] then
      containers[x][y]["chest"][name] = containers[x][y]["chest"][name] - quantity
      if unit.variables[name] == nil then
         unit.variables[name] = quantity
      else
         unit.variables[name] = unit.variables[name] + quantity
      end
   end
end

function game_object.clear(x, y)
   w_items.remove(x, y)
   if containers[x] ~= nil then
      containers[x][y] = nil
   end
   fire.label(x, y, "")
   local mod_containers = helper.get_variable_array("mod_containers")
   for i, coordinates in ipairs(mod_containers) do
      if coordinates.x == x and coordinates.y == y then
         wesnoth.fire("clear_variable", { name = string.format("mod_containers[%d]", i - 1) })
         return
      end
   end
end

function game_object.simple_place(x, y, container_type, image, inventory)
   game_object.clear(x,y)
   w_items.place_image(x, y, image)
   if containers[x] == nil then
      containers[x] = {}
   end
   if containers[x][y] == nil then
      containers[x][y] = {}
   end
   containers[x][y][container_type] = {}
   local l = wesnoth.get_variable("mod_containers.length")
   wesnoth.set_variable(string.format("mod_containers[%d]", l), { x = x, y = y })
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

function game_object.gold_place(x, y, gold)
   local gold_image = "items/gold-coins-medium.png"
   if gold < 20 then
      gold_image = "items/gold-coins-small.png"
   elseif gold >= 100 then
      gold_image = "items/gold-coins-large.png"
   end

   game_object.simple_place(x, y, "gold", gold_image, false)
   containers[x][y]["gold"] = gold
end

function mod_inventory.use(x, y, name)
   local unit = wesnoth.get_unit(x, y)
   unit.variables[name] = unit.variables[name] - 1
   if name == "Coins" then
      wesnoth.sides[wesnoth.current.side].gold = wesnoth.sides[wesnoth.current.side].gold + 10
   elseif name == "Small Healing Potion" then
      change_unit.heal(x, y, 6)
   elseif name == "Healing Potion" then
      change_unit.heal(x, y, 14)
   elseif name == "Small Haste Potion" then
      change_unit.add_turn_effect(x, y, "haste", 2)
   elseif name == "Haste Potion" then
      change_unit.add_turn_effect(x, y, "haste", 4)
   end
end

function mod_inventory.add(name, quantity, container)
   if container[name] == nil then
      container[name] = quantity
   else
      container[name] = container[name] + quantity
   end
end

function mod_inventory.get_item_price(name)
   local price = 9999
   for i, item in ipairs(item_table) do
      if item.name == name then
         price = item.price
      end
   end
   return price
end

function mod_inventory.shop_buy(unit, x, y, name, quantity, price, side_number)
   if wesnoth.sides[side_number]["gold"] >= price * quantity then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] - (price * quantity)
      mod_inventory.add(name, -1 * quantity, containers[x][y]["shop"])
      mod_inventory.add(name, quantity, unit.variables)
   else
      gui2_error("You can't afford that!")
   end
end

function mod_inventory.shop_sell(unit, x, y, name, quantity, price, side_number)
   wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + math.floor(price * quantity * 0.8)
   mod_inventory.add(name, quantity, containers[x][y]["shop"])
   mod_inventory.add(name, -1 * quantity, unit.variables)
end

function mod_inventory.collect_gold(x, y, quantity, side)
   if quantity > 0 and quantity <= containers[x][y]["gold"] then
      wesnoth.sides[side]["gold"] = wesnoth.sides[side]["gold"] + quantity
      if quantity == containers[x][y]["gold"] then
         game_object.clear(x, y)
      else
         containers[x][y]["gold"] = containers[x][y]["gold"] - quantity
      end
   end
end

function mod_inventory.show_current(item_holder)
   local options = {}
   for i, item in ipairs(item_table) do
      quantity = item_holder[item.name]
      if quantity ~= nil and quantity > 0 then
         table.insert(options, {item.name, item.image, item.price, item.msg, quantity})
      end
   end
   return options
end

function mod_inventory.show_all()
   local options = {}
   for i, item in ipairs(item_table) do
      table.insert(options, {item.name, item.image, item.price, item.msg})
   end
   return options
end
>>
#enddef
