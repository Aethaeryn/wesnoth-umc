#define MOD_LUA_INVENTORY
<<
if game_containers == nil then
   game_containers = {}
end

function check_x_coord(x)
   if game_containers[x] == nil then
      game_containers[x] = {}
   end
end

function chest_add(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   game_containers[e.x1][e.y1]["chest"][name] = game_containers[e.x1][e.y1]["chest"][name] + 1
   unit.variables[name] = unit.variables[name] - 1
end

function chest_remove(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   game_containers[e.x1][e.y1]["chest"][name] = game_containers[e.x1][e.y1]["chest"][name] - 1
   if unit.variables[name] == nil then
      unit.variables[name] = 1
   else
      unit.variables[name] = unit.variables[name] + 1
   end
end

function clear_game_object(x, y)
   w_items.remove(x, y)
   if game_containers[x] ~= nil then
      game_containers[x][y] = nil
   end
end

local function simple_place(x, y, type, image, inventory)
   clear_game_object(x,y)
   w_items.place_image(x, y, image)
   check_x_coord(x)
   game_containers[x][y] = {}
   game_containers[x][y][type] = {}
   if inventory == true then
      for i, v in ipairs(item_table) do
         item_name = v["name"]
         game_containers[x][y][type][item_name] = 0
      end
   end
end

local function place_gold(x, y)
   wesnoth.fire("message", {
                   speaker  = "narrator",
                   message  = "How much gold do you want to place in your pile",
                   image    = "wesnoth-icon.png",
                   show_for = side_number,
                   T["text_input"] {
                      variable  = "place_object_gold",
                      label     = "New value:",
                      max_chars = 10 }})

   local gold = wesnoth.get_variable("place_object_gold")

   if type(gold) == "number" and gold > 0 then
      local gold_image = "items/gold-coins-medium.png"
      if gold < 20 then
         gold_image = "items/gold-coins-small.png"
      elseif gold >= 50 then
         gold_image = "items/gold-coins-large.png"
      end

      simple_place(x, y, "gold", gold_image, false)
      check_x_coord(x)
      game_containers[x][y]["gold"] = gold
   end
end

function use_coins()
   this_side.gold = this_side.gold + 10
end

function use_potion(potion, size)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   if potion == "Healing" then
      local hp_effect = 14

      if size == "Small" then
         if unit.status.poisoned then
            unit.status.poisoned = false
            hp_effect = 0
         else
            hp_effect = 6
         end
      elseif unit.status.poisoned then
         unit.status.poisoned = false
         hp_effect = 6
      end

      if unit.hitpoints + hp_effect >= unit.max_hitpoints then
         unit.hitpoints = unit.max_hitpoints
      else
         unit.hitpoints = unit.hitpoints + hp_effect
      end
   end
end

function item_use(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)

   unit.variables[name] = unit.variables[name] - 1

   local effect

   this_side = wesnoth.sides[side_number]

   for i, item in ipairs(item_table) do
      if item.name == name then
         effect = item.effect
      end
   end

   if effect ~= "" then
      local run = loadstring(effect)
      run()
   end
end

function add_unit_item(name, quantity, start_only)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)

   if unit.variables[name] == nil then
      unit.variables[name] = quantity
   elseif start_only == false then
      unit.variables[name] = unit.variables[name] + quantity
   end
end

function add_container_item(name, quantity, container_add, start_only)
   local e = wesnoth.current.event_context
   check_x_coord(e.x1)
   local container = ""
   if container_add == "chest_modify" then
      container = "chest"
   elseif container_add == "shop_modify" then
      container = "shop"
   end
   if game_containers[e.x1][e.y1][container][name] == nil then
      game_containers[e.x1][e.y1][container][name] = quantity
   elseif start_only == false then
      game_containers[e.x1][e.y1][container][name] = game_containers[e.x1][e.y1][container][name] + quantity
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
      if container == "unit_inventory_modify" then
         add_unit_item(item, count, false)
      else
         add_container_item(item, count, container, false)
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
      game_containers[e.x1][e.y1]["shop"][name] = game_containers[e.x1][e.y1]["shop"][name] - 1
      if unit.variables[name] == nil then
         unit.variables[name] = 1
      else
         unit.variables[name] = unit.variables[name] + 1
      end
   else
      wesnoth.message("Error", "You can't afford that!")
   end
end

function submenu_interact()
   local e = wesnoth.current.event_context
   local title = "Unit Commands"
   local description = "How do you want to interact?"
   local image = "portraits/undead/transparent/ancient-lich.png" -- todo: definitely not appropriate here
   local interactions = {}
   check_x_coord(e.x1)
   if game_containers[e.x1][e.y1] ~= nil then
      if game_containers[e.x1][e.y1]["shop"] ~= nil then
         table.insert(interactions, 1, {"Visit Shop", "scenery/tent-shop-weapons.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["chest"] ~= nil then
         table.insert(interactions, 1, {"Remove from Chest", "items/chest-plain-closed.png", e.x1, e.y1})
         table.insert(interactions, 2, {"Add to Chest", "items/chest-plain-closed.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["pack"] ~= nil then
         table.insert(interactions, 1, {"Investigate Drop", "items/leather-pack.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["gold"] ~= nil then
         table.insert(interactions, 1, {"Collect Gold", "icons/coins_copper.png", e.x1, e.y1})
      end
   end
   local option = menu(interactions, image, title, description, menu_picture_list, 1)
   if option then
      check_x_coord(e.x1)
      if option == "Visit Shop" then
         submenu_inventory('visit_shop', game_containers[e.x1][e.y1]["shop"])
      elseif option == "Collect Gold" then
         wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + game_containers[e.x1][e.y1]["gold"]
         clear_game_object(e.x1, e.y1)
      elseif option == "Remove from Chest" then
         submenu_inventory('chest_remove', game_containers[e.x1][e.y1]["chest"])
      elseif option == "Add to Chest" then
         submenu_inventory('chest_add', false)
      end
   end
end

function menu_placement()
   local title = "Place Objects"
   local description = "What do you want to do with this unit?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {
      {"Place Shop", "scenery/tent-shop-weapons.png"},
      {"Place Chest", "items/chest-plain-closed.png"},
      {"Place Pack", "items/leather-pack.png"},
      {"Place Gold Pile", "items/gold-coins-large.png"},
      {"Clear Hex", "terrain/grass/green-symbol.png"}}
   local option = menu(options, image, title, description, menu_picture_list, 1)
   if option then
      local e = wesnoth.current.event_context
      if option == "Place Shop" then
         simple_place(e.x1, e.y1, "shop", "scenery/tent-shop-weapons.png", true)
      elseif option == "Place Chest" then
         simple_place(e.x1, e.y1, "chest", "items/chest-plain-closed.png", true) -- items/chest-plain-open.png
      elseif option == "Place Pack" then
         simple_place(e.x1, e.y1, "pack", "items/leather-pack.png", true)
      elseif option == "Place Gold Pile" then
         place_gold(e.x1, e.y1)
      elseif option == "Clear Hex" then
         clear_game_object(e.x1, e.y1)
      end
   end
end

function submenu_inventory(context, container)
   local e = wesnoth.current.event_context
   local unit = false
   if not container then unit = wesnoth.get_unit(e.x1, e.y1) end
   local msg
   local opt
   local run
   local options_table = {}

   local function option_find(item_holder)
      for i, item in ipairs(item_table) do
         quantity = item_holder[item.name]
         if quantity ~= nil and quantity > 0 then
            table.insert(options_table, {item.name, item.image, item.price, quantity, item.msg})
         end
      end
   end

   local function option_find_all()
      for i, item in ipairs(item_table) do
         table.insert(options_table, {item.name, item.image, item.price, item.msg})
      end
   end

   if context == "unit_use" or context == "chest_add" or context == "chest_remove" or context == "visit_shop" then
      if context == "unit_use" then
         msg = "Which item do you want to use?"
         run = "item_use('$input1')"
      elseif context == "chest_add" then
         msg = "What item do you want to put in the chest?"
         run = "chest_add('$input1')"
      elseif context == "chest_remove" then
         msg = "What item do you want to remove from the chest?"
         run = "chest_remove('$input1')"
      elseif context == "visit_shop" then
         msg = "What item do you want to purchase from the shop?"
         run = "shop_buy('$input1')"
      end
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\nQuantity: $input4\n$input5"
      if unit then
         option_find(unit.variables)
      else
         option_find(container)
      end
   elseif context == "chest_modify" or context == "shop_modify" then
      msg = "Which item do you want to add?"
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\n$input4"
      run = "submenu_inventory_quantity('$input1', '"..context.."')"
      option_find_all()
   elseif context == "unit_add" then
      msg = "Which item do you want to add?"
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\n$input4"
      run = "submenu_inventory_quantity('$input1', 'unit_inventory_modify')"
      option_find_all()
   end

   local options = DungeonOpt:new{
      root_message   = msg,
      option_message = opt,
      code           = run,
   }

   options:fire(options_table)
end

function menu_inventory()
   local title = "Unit Commands"
   local description = "What do you want to do with this unit?"
   local image = "portraits/undead/transparent/ancient-lich.png" -- todo: definitely not appropriate here
   local options = {
      {"Interact", "icons/coins_copper.png"},
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}
   }
   local option = menu(options, image, title, description, menu_picture_list, 1)
   if option == "Use Item" then
      submenu_inventory('unit_use')
   elseif option == "Upgrades" then
      menu_upgrade_unit()
   elseif option == "Speak" then
      fire.custom_message()
   elseif option == "Interact" then
      submenu_interact()
   end
end

>>
#enddef
