#define MOD_SETTINGS
<<
function menu_placement()
   local e = wesnoth.current.event_context
   local title = "Place Object"
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
      if option == "Place Shop" then
         simple_place(e.x1, e.y1, "shop", "scenery/tent-shop-weapons.png", true)
      elseif option == "Place Chest" then
         simple_place(e.x1, e.y1, "chest", "items/chest-plain-closed.png", true) -- items/chest-plain-open.png
      elseif option == "Place Pack" then
         simple_place(e.x1, e.y1, "pack", "items/leather-pack.png", true)
      elseif option == "Place Gold Pile" then
         local description = "How much gold do you want to place in the pile?"
         local label = "Gold:"
         local gold = menu_text_input(image, title, description, label)
         if gold and type(gold) == "number" and gold > 0 then
            place_gold(e.x1, e.y1, gold)
         end
      elseif option == "Clear Hex" then
         clear_game_object(e.x1, e.y1)
      end
   end
end

function submenu_change_var(side_num, variable, old_value)
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

function submenu_change_var_all(variable)
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

function submenu_view_side(side_num)
   if side_num == "All" then
      local all_stats = {"gold", "village_gold", "base_income", "objectives"}
      variable = menu(all_stats, "portraits/undead/transparent/ancient-lich.png", "Settings", "Which variable of all sides do you want to change?", menu_simple_list)
      if variable then
         submenu_change_var_all(variable)
      end
   else
      local options = DungeonOpt:new{
         root_message   = "Which variable do you want to change?",
         option_message = "side$input2.$input1 = $input3",
         code           = "submenu_change_var('$input2', '$input1', side.$input1)"
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

local function get_sides_with_all()
   local sides = {"All"}
   for i, v in ipairs(SIDES) do
      sides[i + 1] = SIDES[i]
   end
   return sides
end

local function feature_toggle(menu_item)
   if mod_menu[menu_item].status then
      mod_menu[menu_item].status = false
      fire.clear_menu_item(mod_menu[menu_item].id)
   else
      mod_menu[menu_item].status = true
      fire.set_menu_item(mod_menu[menu_item])
   end
end

function menu_settings()
   local e = wesnoth.current.event_context
   local title = "Settings"
   local description = "What action do you want to do?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Modify Container",
                    "Modify Side",
                    "New Scenario",
                    "Toggle Summon Summoners",
                    "Toggle Unit Editor",
                    "Toggle Terrain Editor",
                    "Toggle Place Object"}
   local option = menu(options, image, title, description, menu_simple_list)
   if option then
      if option == "Modify Container" then
         local description = "Which container do you want to modify?"
         local interaction = menu(find_interactions_to_modify(e.x1, e.y1), image, title, description, menu_picture_list, 1)
         if interaction then
            if interaction == "Modify Shop" then
               submenu_inventory('shop_modify', game_containers[e.x1][e.y1]["shop"])
            elseif interaction == "Modify Chest" then
               submenu_inventory('chest_modify', game_containers[e.x1][e.y1]["chest"])
            end
         end
      elseif option == "Modify Side" then
         local side = menu(get_sides_with_all(), "portraits/undead/transparent/ancient-lich.png", "Settings", "Which side do you want to modify?", menu_simple_list)
         if side then
            submenu_view_side(side)
         end
      elseif option == "New Scenario" then
         local description = "Which scenario do you want to start?"
         local scenarios = {"Introduction",
                            "Introduction (Underground)",
                            "Battle",
                            "Cavern",
                            "Classic",
                            "Hide and Seek",
                            "Open Dungeon",
                            "Woods"}
         local scenario_ids = {
            ["Introduction"] = "intro",
            ["Introduction (Underground)"] = "intro2",
            ["Battle"] = "battle",
            ["Cavern"] = "cavern",
            ["Classic"] = "classic",
            ["Hide and Seek"] = "hide_and_seek",
            ["Open Dungeon"] = "open_dungeon",
            ["Woods"] = "woods"}
         local scenario = menu(scenarios, image, title, description, menu_simple_list)
         if scenario then
            fire.end_scenario(scenario_ids[scenario])
         end
      elseif option == "Toggle Summon Summoners" then
         feature_toggle("summon_summoner")
      elseif option == "Toggle Unit Editor" then
         feature_toggle("unit_editor")
      elseif option == "Toggle Terrain Editor" then
         feature_toggle("terrain_editor")
      elseif option == "Toggle Place Object" then
         feature_toggle("place_object")
      end
   end
end

local function menu_item_summon(unit_role)
   local menu_item = {
      id = "MOD_001_"..unit_role,
      text = "Summon "..unit_role,
      image = "terrain/symbols/terrain_group_custom3_30.png",
      filter = filter_summon(unit_role),
      command = "spawn_units.menu_summon('"..unit_role.."')" }
   return menu_item
end

function set_all_menu_items()
   -- Generates the toggleable, general menu items.
   for key, menu_item in pairs(mod_menu) do
      if menu_item.status then
         fire.set_menu_item(menu_item)
      end
   end
   -- Generates the menu items for each summoner type.
   for summoner_type, v in pairs(summoners) do
      fire.set_menu_item(menu_item_summon(summoner_type))
   end
end
>>
#enddef
