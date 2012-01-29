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
         hp_effect = 6
      end

      if unit.hitpoints + hp_effect >= unit.max_hitpoints then
         unit.hitpoints = unit.max_hitpoints
      else
         unit.hitpoints = unit.hitpoints + hp_effect
      end
   end
end

function item_use (name, quantity)
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

function add_item (name, quantity, start_only)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)

   if unit.variables[name] == nil then
      unit.variables[name] = quantity
   elseif start_only == false then
      unit.variables[name] = unit.variables[name] + quantity
   end
end

function submenu_inventory_quantity(item)
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

   add_item(item, item_count, false)
end

function submenu_inventory(context)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)

   local msg
   local opt
   local run
   local options_table = {}

   local function option_find()
      for i, item in ipairs(item_table) do
         quantity = unit.variables[item.name]
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

   if context == "unit_use" then
      msg = "Which item do you want to use?"
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\nQuantity: $input4\n$input5"
      run = "item_use('$input1', '$input3')"

      option_find()

   elseif context == "unit_add" then
      msg = "Which item do you want to add?"
      opt = "&$input2=<b>$input1</b>\nValue: $input3 gold\n$input4"
      run = "submenu_inventory_quantity('$input1')"

      option_find_all()
   end

   local options = DungeonOpt:new{
      root_message   = msg,
      option_message = opt,
      code           = run,
   }

   options:fire(options_table)
end

function option_unit (option)
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

function menu_item_inventory ()
   local options = DungeonOpt:new{
      menu_id        = "005_Unit",
      menu_desc      = "Unit Commands",
      menu_image     = "misc/key.png",

      root_message   = "What do you want to do with this unit?",
      option_message = "&$input2= $input1",
      code           = "option_unit('$input1')",
   }

   local menu_options = {
      {"Interact", "icons/coins_copper.png"},
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}
   }

   options:menu(
      menu_options,
      filter_unit()
   )
end

function inventory()
   menu_item_inventory()
end
>>
#enddef
