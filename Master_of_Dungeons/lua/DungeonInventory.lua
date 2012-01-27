#define MOD_LUA_DUNGEONINVENTORY
<<
-- Creates an object that handles inventory, with menu_item_inventory() handling the unit inventory.
-- Another function will handle the shop inventory code.
DungeonInventory = {
   menu_id    = "000_Inventory",
   menu_desc  = "Menu Name",
   menu_image = "misc/key.png",

   unit       = "",

   item_table = {
      {
         name   = "Sample Item",
         image  = "icons/letter_and_ale.png",
         msg    = "* Line 1.\n* Line 2..",
         price  = 53,
         effect = "",
      },
   },
}

function DungeonInventory:item_use (name, quantity)
   self.unit.variables[name] = self.unit.variables[name] - 1

   local effect

   this_side = wesnoth.sides[side_number]

   for i, item in ipairs(self.item_table) do
      if item.name == name then
         effect = item.effect
      end
   end

   if effect ~= "" then
      local run = loadstring(effect)
      run()
   end

end

function DungeonInventory:option_find ()
   local options_table = {}

   for i, item in ipairs(self.item_table) do
      quantity = self.unit.variables[item.name]
      if quantity ~= nil and quantity > 0 then
         table.insert(options_table, {item.name, item.image, quantity, item.msg})
      end
   end

   return options_table
end

function DungeonInventory:option_find_all ()
   local options_table = {}

   for i, item in ipairs(self.item_table) do
      table.insert(options_table, {item.name, item.image, item.msg})
   end

   return options_table
end

function DungeonInventory:add_item (name, quantity, start_only)
   if self.unit.variables[name] == nil then
      self.unit.variables[name] = quantity
   elseif start_only == false then
      self.unit.variables[name] = self.unit.variables[name] + quantity
   end
end

function DungeonInventory:submenu_inventory_quantity (item)
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

   self:add_item(item, item_count, false)
end

function DungeonInventory:submenu_inventory_add ()
   local args = wesnoth.current.event_context
   self.unit = wesnoth.get_unit(args.x1, args.y1)

   local options = DungeonOpt:new{
      root_message   = "Select an item for more information.",
      option_message = "&$input2=<b>$input1</b>\n$input3",
      code           = "globalInv:submenu_inventory_quantity('$input1')",
   }
   
   options_table = self:option_find_all()

   options:fire(options_table)
end

function DungeonInventory:submenu_inventory ()
   local args = wesnoth.current.event_context
   self.unit = wesnoth.get_unit(args.x1, args.y1)

   local options = DungeonOpt:new{
      root_message   = "Select an item for more information.",
      option_message = "&$input2=<b>$input1</b>\nQuantity: $input3\n$input4",
      code           = "globalInv:item_use('$input1', '$input3')",
   }

   -- Testing code; gives units starting inventory.
   -- self:add_item("Small Haste Potion", 53, true)
   -- self:add_item("Ale", 21, true)
   
   options_table = self:option_find()

   options:fire(options_table)
end

function DungeonInventory:option_inventory (option)
   if option == "Use Item" then
      self:submenu_inventory()

   elseif option == "Add Item" then
      self:submenu_inventory_add()
   end
end

function DungeonInventory:menu_item_inventory ()
   globalInv = self

   local options = DungeonOpt:new{
      menu_id        = self.menu_id,
      menu_desc      = self.menu_desc,
      menu_image     = self.menu_image,

      root_message   = "What do you want to do with this unit's inventory?",
      option_message = "&$input2= $input1",
      code           = "globalInv:option_inventory('$input1')",
   }

   local menu_options = {
      {"Use Item", "icons/letter_and_ale.png"},
   }

   -- Hosts get more options
   if side_number == 1 or side_number == 6 then
      table.insert(menu_options, {"Add Item", "attacks/blank-attack.png"})
   end

   options:menu(
      menu_options,
      filter_unit()
   )
end

function DungeonInventory:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end
>>
#enddef