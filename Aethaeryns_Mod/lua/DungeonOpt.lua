#define MOD_LUA_DUNGEONOPT
<<
-- Creates object by setting object = DungeonOpt:new{ option_message = "string", code = "lua code in a string" }
-- The other table items are also changeable.
DungeonOpt = {
   -- Root [message] tags with reasonable defaults.
   speaker_string = "narrator",
   root_message   = "Please select an option:",
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
             local outputs = {
                speaker = self.speaker_string,
                message = self.root_message,
                image   = self.image_string
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

             local cancel = T["option"] {
                message = "Cancel"
             }
             table.insert(outputs, cancel)

             -- Returning the whole table, note that this replaces {"message", {}} with {object:show}.
             -- It needs to be returned within a table to still be a valid WML table.
             return "message", outputs
          end,

   -- This is strictly a syntax shortcut.
   -- wesnoth.fire(object:show{ }) shortens to object:fire{ }
   fire = function(self, inputs)
             wesnoth.fire(self:show(inputs))
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