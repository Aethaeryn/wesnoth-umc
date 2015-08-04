#define MOD_LUA_INVENTORY
<<
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
   wesnoth.fire("message", {
                   speaker  = "narrator",
                   message  = "How much of "..item.." do you want to give?",
                   image    = "wesnoth-icon.png",
                   show_for = side_number,
                   T["text_input"] {
                      variable  = "place_"..item,
                      label     = "Quantity:",
                      max_chars = 50
                   }
                }
             )
   local item_count = wesnoth.get_variable("place_"..item)
   if item_count < 0 then
      item_count = 0
   end
   if container == "unit_inventory_modify" then
      add_unit_item(item, item_count, false)
   else
      add_container_item(item, item_count, container, false)
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

function option_unit(option)
   if option == "Use Item" then
      submenu_inventory('unit_use')

   elseif option == "Upgrades" then
      menu_upgrade_unit()

   elseif option == "Speak" then
      option_unit_message()

   elseif option == "Interact" then
      submenu_interact()
   end
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
   option_unit(option)
end

>>
#enddef
