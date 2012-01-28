#define MOD_SETTINGS
<<
function end_scenario(new_scenario)
   scenario = 'aeth_mod_'..new_scenario

   wesnoth.fire("endlevel", {
                   result = "victory",
                   next_scenario = scenario,
                   bonus = false,
                   carryover_add = false,
                   carryover_percentage = 100,
                })
end

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

function menu_modify_side()
   local options = DungeonOpt:new{
      root_message   = "Which side do you want to modify?",
      option_message = "$input1",
      code           = "menu_view_side('$input1')"
   }

   function get_sides()
      local sides = {"All"}

      for i, v in ipairs(SIDES) do
         sides[i + 1] = SIDES[i]
      end

      return sides
   end

   local sides = get_sides()

   options:short_fire(sides)
end

function menu_new_scenario()
   local options = DungeonOpt:new {
      root_message   = "Which scenario do you want to start?",
      option_message = "$input2",
      code           = "end_scenario('$input1')",
   }

   options:fire{
                   {"intro", "Introduction"},
                   {"intro2", "Introduction (Underground)"},
                   {"battle", "Battle"},
                   {"cavern", "Cavern"},
                   {"classic", "Classic"},
                   {"hide_and_seek", "Hide and Seek"},
                   {"open_dungeon", "Open Dungeon"},
                   {"woods", "Woods"},
                }
end

function terrain_editor_toggle()
   local terrain_editor = wesnoth.get_variable('MoD_terrain_editor')

   if terrain_editor == true then
      wesnoth.set_variable('MoD_terrain_editor', false)
   else
      wesnoth.set_variable('MoD_terrain_editor', true)
   end
end

function unit_editor_toggle()
   local unit_editor = wesnoth.get_variable('MoD_unit_editor')

   if unit_editor == true then
      wesnoth.set_variable('MoD_unit_editor', false)
   else
      wesnoth.set_variable('MoD_unit_editor', true)
   end
end

function option_settings_choose(option)
   if option == "side" then
      menu_modify_side()
   elseif option == "scenario" then
      menu_new_scenario()
   elseif option == "unit" then
      unit_editor_toggle()
   elseif option == "terrain" then
      terrain_editor_toggle()
   end
end

function menu_item_modify_side()
   local options = DungeonOpt:new{
      menu_id        = "040_Settings",
      menu_desc      = "Settings",
      menu_image     = "misc/ums.png",

      root_message   = "What action do you want to do?",
      option_message = "$input2",
      code           = "option_settings_choose('$input1')",
   }

   local opt_list = {{"side", "Modify Side"},
                    {"scenario", "New Scenario"},
                    {"unit", "Toggle Unit Editor"},
                    {"terrain", "Toggle Terrain Editor"}}

   options:menu(opt_list, filter_host("long"))
end

function settings()
   inventory()
   spawn_units()
   modify_unit()
   terrain_editor()
   menu_item_modify_side()
end
>>
#enddef
