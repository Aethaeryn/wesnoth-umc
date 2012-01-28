#define MOD_SETTINGS
<<
function menu_change_var(side_num, variable, old_value)
   if variable ~= "objectives" then
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "The old value of "..variable.." is: "..old_value,
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T["text_input"] {
                         variable  = "change_"..variable,
                         label     = "New value:",
                         max_chars = 50
                      }
                   }
                )
      if variable == "team_name" then
         side.team_name = wesnoth.get_variable("change_team_name")
         side.user_team_name = side.team_name

      elseif variable == "gold" then
         side.gold = wesnoth.get_variable("change_gold")

      elseif variable == "village_gold" then
         side.village_gold = wesnoth.get_variable("change_village_gold")

      elseif variable == "base_income" then
         side.base_income = wesnoth.get_variable("change_base_income")

         -- The less elegant code is used as a fall-back if the variable is not recognized.
      else 
         set_new_variable = loadstring("side."..variable.." = wesnoth.get_variable('change_"..variable.."')")
         set_new_variable()
      end
   end
end

function menu_change_var_all(variable)
   if variable ~= "objectives" then
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "Choose a new value for "..variable,
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T["text_input"] {
                         variable  = "change_"..variable,
                         label     = "New value:",
                         max_chars = 50
                      }
                   }
                )
      for i, side in ipairs(wesnoth.sides) do
         if variable == "team_name" then
            side.team_name = wesnoth.get_variable("change_team_name")
            side.user_team_name = side.team_name
            
         elseif variable == "gold" then
            side.gold = wesnoth.get_variable("change_gold")
            
         elseif variable == "village_gold" then
            side.village_gold = wesnoth.get_variable("change_village_gold")
            
         elseif variable == "base_income" then
            side.base_income = wesnoth.get_variable("change_base_income")
            
            -- The less elegant code is used as a fall-back if the variable is not recognized.
         else 
            set_new_variable = loadstring("side."..variable.." = wesnoth.get_variable('change_"..variable.."')")
            set_new_variable()
         end
      end
   end
end

function menu_view_side(side_num)
   if side_num == "All" then
      local options = DungeonOpt:new{
         root_message   = "Which variable of all sides do you want to change?",
         option_message = "$input1",
         code           = "menu_change_var_all('$input1')"
      }

      options:short_fire{"gold", "village_gold", "base_income", "objectives"}
   else
      local options = DungeonOpt:new{
         root_message   = "Which variable do you want to change?",
         option_message = "side$input2.$input1 = $input3",
         code           = "menu_change_var('$input2', '$input1', side.$input1)"
      }

      side_num = tonumber(side_num)
      side     = wesnoth.sides[side_num]

      local var_gold         = loadstring("return side.gold")()
      local var_village_gold = loadstring("return side.village_gold")()
      local var_base_income  = loadstring("return side.base_income")()
      local var_team_name    = loadstring("return side.team_name")()
      local var_objectives   = loadstring("return tostring(side.objectives)")()

      options:fire{
         {"gold",         side_num, var_gold},
         {"village_gold", side_num, var_village_gold},
         {"base_income",  side_num, var_base_income},
         {"team_name",    side_num, var_team_name},
         {"objectives",   side_num, var_objectives}
      }
   end
end

function menu_item_modify_side()
   local options = DungeonOpt:new{
      root_message   = "Which side do you want to modify?",
      option_message = "$input1",
      code           = "menu_view_side('$input1')"
   }

   local sides = {"All"}

   for i, v in ipairs(SIDES) do
      sides[i + 1] = SIDES[i]
   end

   wesnoth.fire("set_menu_item", {
                   id          = "040_Modify_Side",
                   description = "Modify Side",
                   image       = "misc/ums.png",
                   filter_host("long"),
                   T["command"] {
                      {
                         options:short_show(sides)
                      }
                   }
                }
             )
end

function settings()
   menu_item_modify_side()
end
>>
#enddef
