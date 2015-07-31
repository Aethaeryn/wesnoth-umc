#define MOD_LUA_DUNGEONDIALOG
<<
function test_dialog()
    return "temporarily disabled"
end
-- function test_dialog()
--    local function button(name)
--       return T["button"] {id = string.lower(name), label = name }
--    end

--    local function simple_grid(items)
--       local columns = { }

--       for i, item in ipairs(items) do
--          table.insert(columns, T["column"] { item })
--       end

--       -- return T["grid"] { T["row"] columns }
--       return T["grid"] { T["row"] { T["column"] { button("OK") }} }

--    end

--    local dialog = {
--       T["tooltip"] { id = "tooltip_large" },
--       T["helptip"] { id = "tooltip_large" },
--       T["grid"] {
--          T["row"] {
--             T["column"] {
--                T["grid"] {
--                   T["row"] {
--                      T["column"] {
--                         T["label"] { id = "the_msg" }
--                   }},
--                   T["row"] {
--                      T["column"] {
--                         horizontal_grow = true,
--                         T["listbox"] {
--                            id = "inventory_list",
--                            T["list_definition"] {
--                               T["row"] {
--                                  T["column"] {
--                                     horizontal_grow = true,
--                                     T["toggle_panel"] {
--                                        T["grid"] {
--                                           T["row"] {
--                                              T["column"] {
--                                                 horizontal_alignment = "left",
--                                                 T["image"] { id = "the_icon" }
--                                              },
--                                              T["column"] {
--                                                 horizontal_alignment = "left",
--                                                 T["label"] { id = "the_label" }
--                   }}}}}}}}}},
--                   T["row"] {
--                      T["column"] {
--                         simple_grid(button("OK"), button("Cancel"))
--    }}}}}}}
--    local function preshow()
--       local inv = {}

--       for i, v in ipairs(item_table) do
--          table.insert(inv, v.name)
--       end

--       wesnoth.set_dialog_value("Please choose an item.", "the_msg")

--       local function select()
--          local i = wesnoth.get_dialog_value "inventory_list"
--          local type = inv[i]
--          -- wesnoth.set_dialog_value(item_table[i].msg, "item_stats")
--       end

--       wesnoth.set_dialog_callback(select, "inventory_list")

--       for i,v in ipairs(inv) do
--          local type = inv[i]
--          wesnoth.set_dialog_value(item_table[i].name, "inventory_list", i, "the_label")
--          wesnoth.set_dialog_value(item_table[i].image, "inventory_list", i, "the_icon")
--       end

--       wesnoth.set_dialog_value(1, "inventory_list")

--       select()
--    end

--    local li = 0
--    local function postshow()
--       li = wesnoth.get_dialog_value "inventory_list"
--    end

--    local r = wesnoth.show_dialog(dialog, preshow, postshow)
--    wesnoth.message(string.format("Button %d pressed. Item %d selected.", r, li))
-- end

-- Creates object by setting object = DungeonOpt:new{ option_message = "string", code = "lua code in a string" }
-- The other table items are also changeable.
DungeonDialog = {
   -- Root [message] tags with reasonable defaults.
   speaker_string = "narrator",
   root_message   = "Please select an option: ",
   image_string   = "wesnoth-icon.png",

   -- Tags in each individual [option]. Use $input1, $input2, etc., to make them replaceable by arguments.
   -- code id Lua code to be run when the option is selected.
   option_message = "",
   code           = "",

   -- Proper syntax: object:show{ {"item"}, {"item"}, {"etc."} }
   -- Both tables can have as many arguments as you want.
   -- The outside table contains all options, the inside table contains the arguments for each individual option.
   -- inputs *must* be a table that contains tables.
   show = function(self, inputs)
             -- This is the message stuff that comes before the options.
             local outputs = {
                speaker = self.speaker_string,
                message = self.root_message,
                image   = self.image_string
             }

             -- This is actually the *last* item in every menu, after the options.
             local cancel = T["option"] {
                message = "Cancel"
             }

             -- This reads through the tables and adds them to outputs.
             for i, input in ipairs(inputs) do
                -- Creates a local copy so that each part of the loop has their own message.
                local out_message = self.option_message
                local out_code    = self.code

                -- There can now be as many table items as necessary and it will match the $input with the input.
                -- Proper syntax: $input1 is replaced by the item with the index of 1 (j == 1), $input2 by j == 2, etc.
                for j, item in ipairs(input) do
                   out_message = string.gsub(out_message, "$input"..j, item)
                   out_code    = string.gsub(out_code,    "$input"..j, item)
                end

                -- If $unit_image is used somewhere, then it replaces it with the unit config's image.
                -- If $unit_cost is used, it is replaced with the default cost of that unit.
                -- This assumes the unit is in the first input and any non-nil location of $unit will run this code.
                if string.find(out_message, "%$unit") or string.find(out_message, "%$unit") then
                   out_message = string.gsub(out_message, "$unit_image", wesnoth.get_unit_type(input[1]).__cfg.image)
                   out_code    = string.gsub(out_code,    "$unit_image", wesnoth.get_unit_type(input[1]).__cfg.image)
                   out_message = string.gsub(out_message, "$unit_cost", wesnoth.get_unit_type(input[1]).cost)
                   out_code    = string.gsub(out_code,    "$unit_cost", wesnoth.get_unit_type(input[1]).cost)
                end

                -- This is a basic WML table for a Lua-runnning [option] that should serve most purposes.
                local output = T["option"] {
                   message = out_message,
                   T["command"] {
                      T["lua"] {
                         code = out_code
                      }
                   }
                }

                -- Adding the options in the order they appear in the inputs table.
                table.insert(outputs, output)
             end

             -- Adding cancel.
             table.insert(outputs, cancel)

             -- Returning the whole table, note that this replaces {"message", {}} with {object:show}.
             -- It needs to be returned within a table to still be a valid WML table.
             return "message", outputs
          end,

   -- Proper syntax: object:short_show{"item", "item", "etc."}
   -- This is a syntax shortcut. If you have a list of menu items with only one item per table,
   -- then this turns a regular Lua table into the table-within-a-table format show recognizes.
   short_show = function(self, inputs)
                   local new_table = {}

                   for i, v in ipairs(inputs) do
                      table.insert(new_table, {v})
                   end

                   return self:show(new_table)
                end,

   -- This is strictly a syntax shortcut.
   -- wesnoth.fire(object:show{ }) shortens to object:fire{ }
   fire = function(self, inputs)
             wesnoth.fire(self:show(inputs))
          end,

   -- This functions just like fire, but uses short_show instead.
   short_fire = function(self, inputs)
                   wesnoth.fire(self:short_show(inputs))
                end,

   -- Turns this table (DungeonOpt) into a class to allow for the creation of objects.
   new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            return o
         end
}
>>
#enddef
