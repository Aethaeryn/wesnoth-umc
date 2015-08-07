#define MOD_MENU
<<
mod_menu = {}

local function get_roles()
   local roles = {}
   for i, v in ipairs(SUMMON_ROLES) do
      roles[i] = SUMMON_ROLES[i]
   end
   table.insert(roles, "None")
   return roles
end

local function get_sides_with_all()
   local sides = {"All"}
   for i, v in ipairs(SIDES) do
      sides[i + 1] = SIDES[i]
   end
   return sides
end

function mod_menu.toggle(menu_item)
   if mod_menu_items[menu_item].status then
      mod_menu_items[menu_item].status = false
      fire.clear_menu_item(mod_menu_items[menu_item].id)
   else
      mod_menu_items[menu_item].status = true
      fire.set_menu_item(mod_menu_items[menu_item])
   end
end

function mod_menu.summon(summoner_type)
   local e = wesnoth.current.event_context
   local title = string.format("Summon %s", summoner_type)
   local description = "Select a unit level."
   local image = PORTRAIT[summoner_type]
   local levels = {}
   for key, value in pairs(regular[summoner_type]) do
      table.insert(levels, key)
   end
   table.sort(levels)
   local level = menu(levels, image, title, description, menu_simple_list)
   if level then
      description = "Select a unit to summon."
      local choice = menu(regular[summoner_type][level], image, title, description, menu_unit_list_with_cost)
      if choice then
         local spawn_success = spawn_unit.reg_spawner(e.x1, e.y1, choice, summoner_type)
         if not spawn_success then
            gui2_error("Insufficient hitpoints on the attempted summoner.")
         end
      end
   end
end

function mod_menu.summon_summoner()
   local e = wesnoth.current.event_context
   local title = "Summon Summoner"
   local description = "Select a summoner type."
   local image = "portraits/undead/transparent/ancient-lich.png"
   local summoner_type = menu(SUMMON_ROLES, image, title, description, menu_simple_list)
   if summoner_type then
      description = "Select a unit to summon."
      local summoner = menu(summoners[summoner_type], image, title, description, menu_unit_list)
      if summoner then
         spawn_unit.boss_spawner(e.x1, e.y1, summoner, summoner_type)
      end
   end
end

function mod_menu.unit_commands()
   local e = wesnoth.current.event_context
   local title = "Unit Commands"
   local description = "What do you want to do with this unit?"
   local image = "portraits/undead/transparent/ancient-lich.png" -- todo: definitely not appropriate here
   local options = {
      {"Interact", "icons/coins_copper.png"},
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}}
   local option = menu(options, image, title, description, menu_picture_list, 1)
   if option == "Use Item" then
      submenu_inventory('unit_use')
   elseif option == "Upgrades" then
      submenu_upgrade_unit()
   elseif option == "Speak" then
      fire.custom_message()
   elseif option == "Interact" then
      local description = "How do you want to interact?"
      local option = menu(find_interactions(e.x1, e.y1), image, title, description, menu_picture_list, 1)
      if option then
         if option == "Visit Shop" then
            submenu_inventory('visit_shop', game_containers[e.x1][e.y1]["shop"])
         elseif option == "Collect Gold" then
            wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + game_containers[e.x1][e.y1]["gold"]
            clear_game_object(e.x1, e.y1)
         elseif option == "Remove from Chest" then
            submenu_inventory('chest_remove', game_containers[e.x1][e.y1]["chest"])
         elseif option == "Add to Chest" then
            submenu_inventory('chest_add')
         end
      end
   end
end

function mod_menu.unit_editor()
   local e = wesnoth.current.event_context
   local title = "Change Unit"
   local description = "What stat do you want to modify?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Side", "Inventory", "Transform", "Role", "Stats"}
   local choice = menu(options, image, title, description, menu_simple_list)
   if choice then
      if choice == "Transform" then
         local description = "What unit do you want it to transform to?"
         local label = "Unit Type:"
         local new_unit = menu_text_input(image, title, description, label)
         if new_unit then
            change_unit.transform(e.x1, e.y1, new_unit)
         end
      elseif choice == "Role" then
         local role = menu(get_roles(), image, title, "Select a new (summoning) role for this unit.", menu_simple_list)
         if role then
            change_unit.role(e.x1, e.y1, role)
         end
      elseif choice == "Inventory" then
         submenu_inventory('unit_add', false)
      elseif choice == "Side" then
         local side = menu(SIDES, image, title, "Select a target side.", menu_simple_list)
         if side then
            change_unit.side(e.x1, e.y1, side)
         end
      elseif choice == "Stats" then
         local stats = {"Hitpoints", "Max Hitpoints", "Max Moves",
                        "Experience", "Max Experience", "Gender",
                        "Leader"}
         local stat = menu(stats, image, title, "Which stat do you want to change?", menu_simple_list)
         if stat then
            stat = string.gsub(string.lower(stat), " ", "_")
            if stat ~= "gender" and stat ~= "leader" then
               local description = string.format("What should the new value of %s be?", stat)
               local label = "New Value:"
               local new_value
               new_value = menu_text_input(image, title, description, label)
               if new_value then
                  change_unit[stat](e.x1, e.y1, new_value)
               end
            else
               change_unit[stat](e.x1, e.y1)
            end
         end
      end
   end
end

function mod_menu.terrain_editor()
   local e = wesnoth.current.event_context
   terrain.change_hexes = wesnoth.get_locations { x = e.x1, y = e.y1, radius = terrain.radius }
   local title = "Terrain Editor"
   local description = "Which terrain would you like to switch to?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Repeat last terrain",
                    "Set an overlay",
                    "Change radius",
                    "Water",
                    "Flat",
                    "Desert",
                    "Forest",
                    "Frozen",
                    "Rough",
                    "Cave",
                    "Obstacle",
                    "Village",
                    "Castle",
                    "Special"}
   local choice = menu(options, image, title, description, menu_simple_list)
   if choice then
      submenu_terrain_choose(choice)
   end
end

function mod_menu.place_object()
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

function mod_menu.settings()
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
         local description = "Which side do you want to modify?"
         local side = menu(get_sides_with_all(), image, title, description, menu_simple_list)
         if side then
            local description = "Which variable of all sides do you want to change?"
            local stats = {"gold", "village_gold", "base_income", "team_name", "objectives"}
            if side == "All" then
               stat = menu(stats, image, title, description, menu_simple_list)
               if stat then
                  if stat ~= "objectives" then
                     local title = string.format("Choose a new value for %s", stat)
                     local label = "New value:"
                     local new_value = menu_text_input(image, title, description, label)
                     if new_value then
                        for i, side in ipairs(wesnoth.sides) do
                           side[stat] = new_value
                           if stat == "team_name" then
                              side.user_team_name = side.team_name
                           end
                        end
                     end
                  end
               end
            else
               local description = "Which variable do you want to change?"
               for i, stat in ipairs(stats) do
                  debugOut(wesnoth.sides[side][stat])
               end
               stat = menu(stats, image, title, description, menu_simple_list)
               if stat then
                  if stat ~= "objectives" then
                     local title = string.format("The old value of %s is: %s ", stat, wesnoth.sides[side][stat])
                     local label = "New value:"
                     local new_value = menu_text_input(image, title, description, label)
                     if new_value then
                        wesnoth.sides[side][stat] = new_value
                        if stat == "team_name" then
                           wesnoth.sides[side].user_team_name = wesnoth.sides[side].team_name
                        end
                     end
                  end
               end
            end
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
         mod_menu.toggle("summon_summoner")
      elseif option == "Toggle Unit Editor" then
         mod_menu.toggle("unit_editor")
      elseif option == "Toggle Terrain Editor" then
         mod_menu.toggle("terrain_editor")
      elseif option == "Toggle Place Object" then
         mod_menu.toggle("place_object")
      end
   end
end

local function menu_item_summon(unit_role)
   local menu_item = {
      id = "MOD_001_"..unit_role,
      text = "Summon "..unit_role,
      image = "terrain/symbols/terrain_group_custom3_30.png",
      filter = aeth_mod_filter.summon(unit_role),
      command = string.format("mod_menu.summon('%s')", unit_role) }
   return menu_item
end

function set_all_menu_items()
   -- Generates the toggleable, general menu items.
   for key, menu_item in pairs(mod_menu_items) do
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
