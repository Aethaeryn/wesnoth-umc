#define MOD_LUA_DUNGEONOPT
<<
-- Creates object by setting object = DungeonOpt:new{ option_message = "string", code = "lua code in a string" }
-- The other table items are also changeable.
DungeonOpt = {
   -- Root [message] tags with reasonable defaults.
   speaker_string = "narrator",
   root_message   = "Please select an option: ",
   image_string   = "wesnoth-icon.png",

   -- Tags in each individual [option]. Use $input1, $input2, etc., to make them replaceable by arguments.
   -- code id Lua code to be run when the option is selected.
   option_message = "",
   code           = "",

   -- These variables are only used in the function menu, and so only need to be customized if you're doing a menu.
   menu_id        = "000_Blank",
   menu_desc      = "Blank Menu Item",
   menu_image     = "misc/dot-white.png",

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
                   if item == false then
                      item = "false"
                   end
                   out_message = string.gsub(out_message, "$input"..j, item)
                   out_code    = string.gsub(out_code,    "$input"..j, item)
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

   -- This is a more complicated shortcut, for menu items.
   -- The last argument, effect, is optional and is used if the menu runs something in addition to a message.
   -- The actual command to be run is determined in the menu_command() function below.
   menu = function(self, inputs, filter, effect)
             wesnoth.fire("set_menu_item", {
                             id          = self.menu_id,
                             description = self.menu_desc,
                             image       = self.menu_image,
                             filter,
                             T["command"] {
                                self:menu_command(inputs, effect)
                             }
                          }
                       )
          end,

   -- This function is used in the menu function to determine the command to be run.
   -- If there is no effect, only the menu is shown. If there is an effect, it is run before the menu.
   menu_command = function(self, inputs, effect)
                     if effect == nil then
                        return {
                           self:show(inputs)
                        }

                     else
                        return
                        T["lua"] {
                           code = effect
                        }, {
                           self:show(inputs)
                        }
                     end
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
