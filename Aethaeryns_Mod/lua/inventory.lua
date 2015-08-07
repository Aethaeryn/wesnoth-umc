#define MOD_LUA_INVENTORY
<<
if containers == nil then
   containers = {}
end

function check_x_coord(x)
   if containers[x] == nil then
      containers[x] = {}
   end
end

function chest_add(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   containers[e.x1][e.y1]["chest"][name] = containers[e.x1][e.y1]["chest"][name] + 1
   unit.variables[name] = unit.variables[name] - 1
end

function chest_remove(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   containers[e.x1][e.y1]["chest"][name] = containers[e.x1][e.y1]["chest"][name] - 1
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

function simple_place(x, y, type, image, inventory)
   clear_game_object(x,y)
   w_items.place_image(x, y, image)
   check_x_coord(x)
   containers[x][y] = {}
   containers[x][y][type] = {}
   if inventory == true then
      for i, v in ipairs(item_table) do
         item_name = v["name"]
         containers[x][y][type][item_name] = 0
      end
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

function add_container_item(name, quantity, container_add)
   local e = wesnoth.current.event_context
   check_x_coord(e.x1)
   local container = ""
   if container_add == "chest_modify" then
      container = "chest"
   elseif container_add == "shop_modify" then
      container = "shop"
   end
   if containers[e.x1][e.y1][container][name] == nil then
      containers[e.x1][e.y1][container][name] = quantity
   else
      containers[e.x1][e.y1][container][name] = containers[e.x1][e.y1][container][name] + quantity
   end
end

function submenu_inventory_quantity(item, container)
   local title = "Change Inventory"
   local description = string.format("How much of %s do you want to give?", item)
   local image = "portraits/undead/transparent/ancient-lich.png"
   local label = "Item Quantity:"
   local count = menu_text_input(image, title, description, label)
   if count then
      if count < 0 then
         count = 0
      end
      if container == "unit_add" then
         add_unit_item(item, count)
      else
         add_container_item(item, count, container)
      end
   end
end

function shop_buy(name)
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

local function show_current_inventory(item_holder)
   local options = {}
   for i, item in ipairs(item_table) do
      quantity = item_holder[item.name]
      if quantity ~= nil and quantity > 0 then
         table.insert(options, {item.name, item.image, item.price, item.msg, quantity})
      end
   end
   return options
end

local function show_all_inventory()
   local options = {}
   for i, item in ipairs(item_table) do
      table.insert(options, {item.name, item.image, item.price, item.msg})
   end
   return options
end

function submenu_inventory(context, container)
   local e = wesnoth.current.event_context
   local unit = false
   if container == nil then unit = wesnoth.get_unit(e.x1, e.y1) end
   local title = "Unit Commands"
   local description
   local opt
   local run
   local options_list = {}
   if context == "unit_use" or context == "chest_add" or context == "chest_remove" or context == "visit_shop" then
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\nQuantity: $input5\n$input4"
      if context == "unit_use" then
         description = "Which item do you want to use?"
         run = "item_use('$input1')"
      elseif context == "chest_add" then
         description = "What item do you want to put in the chest?"
         run = "chest_add('$input1')"
      elseif context == "chest_remove" then
         description = "What item do you want to remove from the chest?"
         run = "chest_remove('$input1')"
      elseif context == "visit_shop" then
         description = "What item do you want to purchase from the shop?"
         run = "shop_buy('$input1')"
      end
      if unit then
         options_list = show_current_inventory(unit.variables)
      else
         options_list = show_current_inventory(container)
      end
   elseif context == "chest_modify" or context == "shop_modify" or context == "unit_add" then
      description = "Which item do you want to add?"
      run = "submenu_inventory_quantity('$input1', '"..context.."')"
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\n$input4"
      options_list = show_all_inventory()
   end
   local options = DungeonOpt:new{
      root_message   = description,
      option_message = opt,
      code           = run }
   options:fire(options_list)
   selection = menu(options_list, "", title, description, menu_picture_list, 1, "item_stats")
end
>>
#enddef
