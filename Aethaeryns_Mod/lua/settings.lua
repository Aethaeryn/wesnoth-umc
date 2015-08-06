#define MOD_SETTINGS
<<
fire = {}

function fire.end_scenario(new_scenario)
   local scenario = string.format('aeth_mod_%s', new_scenario)
   wesnoth.fire("endlevel", {
                   result = "victory",
                   next_scenario = scenario,
                   bonus = false,
                   carryover_add = false,
                   carryover_percentage = 100 })
end

function fire.custom_message()
   wesnoth.fire("message", {
                   speaker  = "unit",
                   caption  = "Unit Message",
                   message  = "What will you say?",
                   show_for = side_number,
                   T["text_input"] {
                      variable  = "aeth_custom_message",
                      label     = "Type Here:",
                      max_chars = 50 }})
   local message = wesnoth.get_variable('aeth_custom_message')
   if message ~= "" then
      wesnoth.fire("message", {
                      side    = side_number,
                      speaker = "unit",
                      message = "$aeth_custom_message" })
   end
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
      local all_stats = {"gold", "village_gold", "base_income", "objectives"}
      variable = menu(all_stats, "portraits/undead/transparent/ancient-lich.png", "Settings", "Which variable of all sides do you want to change?", menu_simple_list)
      if variable then
         menu_change_var_all(variable)
      end
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
   local function get_sides()
      local sides = {"All"}

      for i, v in ipairs(SIDES) do
         sides[i + 1] = SIDES[i]
      end

      return sides
   end
   local side = menu(get_sides(), "portraits/undead/transparent/ancient-lich.png", "Settings", "Which side do you want to modify?", menu_simple_list)
   if side then
      menu_view_side(side)
   end
end

function menu_new_scenario()
   local options = DungeonOpt:new {
      root_message   = "Which scenario do you want to start?",
      option_message = "$input2",
      code           = "fire.end_scenario('$input1')",
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

local function feature_toggle(variable)
   local check_variable = wesnoth.get_variable(variable)

   if check_variable == true then
      wesnoth.set_variable(variable, false)
   else
      wesnoth.set_variable(variable, true)
   end
end

function menu_settings()
   local title = "Settings"
   local description = "What action do you want to do?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Modify Container",
                    "Modify Side",
                    "New Scenario",
                    "Toggle Summon Summoners",
                    "Toggle Unit Editor",
                    "Toggle Terrain Editor"}
   local option = menu(options, image, title, description, menu_simple_list)
   if option then
      if option == "Modify Side" then
         menu_modify_side()
      elseif option == "New Scenario" then
         menu_new_scenario()
      elseif option == "Toggle Summon Summoners" then
         feature_toggle("MoD_summon_summoner")
      elseif option == "Toggle Unit Editor" then
         feature_toggle("MoD_unit_editor")
      elseif option == "Toggle Terrain Editor" then
         feature_toggle("MoD_terrain_editor")
      elseif option == "Modify Container" then
         submenu_modify_container()
      end
   end
end

function fire.set_menu_item(id, description, image, filter, command)
   wesnoth.fire("set_menu_item", {
                   id = id,
                   description = description,
                   image = image,
                   filter,
                   T["command"] { T["lua"] { code = command }}})
end

function settings()
   spawn_units.spawn_units()
   fire.set_menu_item("MOD_010", "Unit Commands", "misc/key.png", filter_unit(), "menu_inventory()")
   fire.set_menu_item("MOD_020", "Change Unit", "misc/icon-amla-tough.png", filter_host("unit"), "menu_unit_change_stats()")
   fire.set_menu_item("MOD_050", "Change Terrain", "misc/vision-fog-shroud.png", filter_host("editor"), "menu_change_terrain()")
   fire.set_menu_item("MOD_040", "Settings", "misc/ums.png", filter_host("long"), "menu_settings()")
   fire.set_menu_item("MOD_070", "Place Objects", "misc/dot-white.png", filter_item(), "menu_placement()")
end
>>
#enddef
