#define MOD_MENU
<<
-- Menu Options --
mod_menu = {}
mod_menu.lich_image = "portraits/undead/transparent/ancient-lich.png"
mod_menu.gender = {{_ "Male ♂", "male"}, {_ "Female ♀", "female"}}
mod_menu.scenarios = {
   {"Introduction", "intro"},
   {"Introduction (Underground)", "intro2"},
   {"Battle", "battle"},
   {"Cavern", "cavern"},
   {"Hide and Seek", "hide_and_seek"},
   {"Woods", "woods"},
   {"Temple", "temple"}}
mod_menu.place_object_options = {
   {"Place Shop", "scenery/tent-shop-weapons.png"},
   {"Place Chest", "items/chest-plain-closed.png"},
   {"Place Pack", "items/leather-pack.png"},
   {"Place Gold Pile", "items/gold-coins-large.png"},
   {"Clear Hex", "terrain/grass/green-symbol.png"}}
mod_menu.misc_settings =  {
   "Modify Container",
   "Modify Side",
   "Max Starting Level",
   "New Scenario",
   "Toggle Summon Summoners",
   "Toggle Summon Units",
   "Toggle Unit Editor",
   "Toggle Terrain Editor",
   "Toggle Place Object"}

-- (Most) Local Functions --

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

local function submenu_inventory_quantity(item, container)
   local title = "Change Inventory"
   local description = string.format("How much of %s do you want to give?", item)
   local label = "Item Quantity:"
   local count = menu_slider(title, description, label, {max = 20, min = 1, step = 1, value = 1})
   if count and count > 0 then
      mod_inventory.add(item, count, container)
   end
end

local function find_interactions(x, y, blocked, on_hex)
   local interactions = {}
   if containers[x] ~= nil and containers[x][y] ~= nil and not blocked then
      if containers[x][y]["shop"] ~= nil then
         table.insert(interactions, 1, {"Buy from Shop", "scenery/tent-shop-weapons.png"})
         table.insert(interactions, 2, {"Sell to Shop", "scenery/tent-shop-weapons.png"})
      elseif containers[x][y]["chest"] ~= nil then
         table.insert(interactions, 1, {"Remove from Chest", "items/chest-plain-closed.png"})
         table.insert(interactions, 2, {"Add to Chest", "items/chest-plain-closed.png"})
      elseif containers[x][y]["pack"] ~= nil then
         table.insert(interactions, 1, {"Investigate Drop", "items/leather-pack.png"})
      elseif containers[x][y]["gold"] ~= nil then
         table.insert(interactions, 1, {"Collect Gold", "icons/coins_copper.png"})
      end
   end
   local unit = wesnoth.get_unit(x, y)
   if unit ~= nil and not on_hex then
      table.insert(interactions, {"Interact with Unit", string.format("%s~RC(magenta>%s)", unit.__cfg.image, wesnoth.sides[unit.side].color)})
   end
   return interactions
end

local function find_interactions_to_modify(x, y)
   local interactions = {}
   if containers[x] ~= nil and containers[x][y] ~= nil then
      if containers[x][y]["shop"] ~= nil then
         table.insert(interactions, 1, {"Modify Shop", "scenery/tent-shop-weapons.png"})
      elseif containers[x][y]["chest"] ~= nil then
         table.insert(interactions, 1, {"Modify Chest", "items/chest-plain-closed.png"})
      elseif containers[x][y]["pack"] ~= nil then
         table.insert(interactions, 1, {"Modify Drop", "items/leather-pack.png"})
      elseif containers[x][y]["gold"] ~= nil then
         table.insert(interactions, 1, {"Modify Gold", "icons/coins_copper.png"})
      end
   end
   return interactions
end

local function unit_interaction(x, y, current_side)
   local hexes = wesnoth.get_locations { x = x, y = y, radius = 1 }
   local unit_list = {}
   local blocked = false
   for i, hex in ipairs(hexes) do
      local unit = wesnoth.get_unit(hex[1], hex[2])
      -- A unit must be in the radius on the current side...
      if unit ~= nil and unit.side == current_side then
         -- ...but a unit can't interact with itself so there must be
         -- something else on the hex other than a unit to interact
         -- with if a unit is on the hex.
         if (hex[1] ~= x or hex[2] ~= y) or (containers[x] ~= nil and containers[x][y] ~= nil) then
            table.insert(unit_list, unit)
         end
      -- A hostile unit blocks all non-unit interactions on that hex.
      elseif unit ~= nil and unit.side ~= current_side
      and wesnoth.sides[unit.side].team_name ~= wesnoth.sides[current_side].team_name then
         blocked = true
      end
   end
   return unit_list, blocked
end

local function get_unit_commands(leader_selection)
   local temp_table = {
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}}
   if leader_selection then
      table.insert(temp_table, 1, {"Select Unit", "attacks/thorns.png"})
   end
   return temp_table
end

local function get_levels(category, max_level)
   local levels = {}
   for key, value in pairs(units_by_species[category]) do
      if tonumber(string.sub(key, 7)) <= max_level then
         table.insert(levels, key)
      end
   end
   table.sort(levels)
   return levels
end

local function get_upgrade_options(unit)
   local upgrades = {}
   for i, upgrade in ipairs(upgrade_table) do
      local upgrade_count = 0
      if unit.variables["upgrade"..upgrade.name] ~= nil then
         upgrade_count = unit.variables["upgrade"..upgrade.name]
      end
      table.insert(upgrades,
                   {name = upgrade.name,
                    image = upgrade.image,
                    cost = upgrade.cost,
                    count = upgrade_count,
                    cap = upgrade.cap,
                    msg = upgrade.msg})
   end
   return upgrades
end

-- Special --

function mod_menu.toggle(menu_item)
   if mod_menu_items[menu_item].status then
      mod_menu_items[menu_item].status = false
      fire.clear_menu_item(mod_menu_items[menu_item].id)
   else
      mod_menu_items[menu_item].status = true
      fire.set_menu_item(mod_menu_items[menu_item])
   end
end

-- Menus --

-- Transforms the peasant leader unit on the start of game into a unit
-- that the character selects. The unit then gets a free upgrade
-- point. The existence of upgrade points is later used to verify that
-- the peasant is a new spawn (instead of a chosen leader) when a new
-- scenario is selected so the menu doesn't fire on chosen peasants.
function mod_menu.select_leader()
   local leaders = wesnoth.get_units { side = wesnoth.current.side, canrecruit = true }
   if leaders[1] ~= nil and leaders[1].type == "Peasant" and leaders[1].variables["advancement"] == nil then
      local leader = leaders[1]
      local title = _ "Leader"
      -- You only exit the menu at the top level, or if you choose a
      -- unit successfully.
      local done = false
      -- Lets the player come back to this menu.
      leader.variables.selection_active = true
      while not done do
         local leader_category = menu(LEADER_ROLES, mod_menu.lich_image, title, "Select a leader type.", "simple")
         if leader_category then
            menu2(get_levels(leader_category, change_unit.max_level), mod_menu.lich_image, title, "Select a unit level.", "simple", nil, nil,
                 function(level)
                    menu2(units_by_species[leader_category][level], mod_menu.lich_image, title, "Select a unit.", "unit", nil, "summoner",
                          function(choice)
                             if wesnoth.unit_types[choice].__cfg.gender ~= "male,female" then
                                change_unit.transform(leader.x, leader.y, choice)
                                mod_upgrade.increment(leader)
                                leader.variables.dont_make_me_quick = true
                                leader.variables.selection_active = false
                                done = true
                             else
                                menu2(mod_menu.gender, mod_menu.lich_image, title, "Select a gender.", "almost_simple", 2, nil,
                                      function(gender)
                                         change_unit.transform(leader.x, leader.y, choice, gender)
                                         mod_upgrade.increment(leader)
                                         leader.variables.dont_make_me_quick = true
                                         leader.variables.selection_active = false
                                         done = true
                                end)
                             end
                    end)
            end)
         else
            done = true
         end
      end
   end
end

function mod_menu.summon_units()
   local e = wesnoth.current.event_context
   local title = _ "Summon Units"
   menu3{list = {"Summon Group", "Summon Unit"},
         title = title,
         description = _ "Select what kind of summon to use.",
         dialog_list = "simple",
         action = function(option)
            if option == "Summon Group" then
               menu3{list = unit_groups_menu,
                     title = title,
                     description = _ "Select a group.",
                     dialog_list = "simple",
                     action = function(choice) spawn_unit.spawn_group(e.x1, e.y1, unit_groups[choice], wesnoth.current.side) end}
            elseif option == "Summon Unit" then
               menu3{list = LEADER_ROLES,
                     title = title,
                     description = _ "Select a unit category.",
                     dialog_list = "simple",
                     action = function(unit_category)
                        menu3{list = get_levels(unit_category, 5),
                              title = title,
                              description = _ "Select a unit level.",
                              dialog_list = "simple",
                              action = function(level)
                                 menu3{list = units_by_species[unit_category][level],
                                       title = title,
                                       description = _ "Select a unit.",
                                       dialog_list = "unit",
                                       sidebar = "summoner",
                                       action = function(choice)
                                          if wesnoth.unit_types[choice].__cfg.gender ~= "male,female" then
                                             spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side)
                                          else
                                             menu3{list = mod_menu.gender,
                                                   title = title,
                                                   description = _ "Select a gender.",
                                                   dialog_list = "almost_simple",
                                                   sublist_index = 2,
                                                   action = function(gender) spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side, nil, nil, gender) end}
                                          end
                                 end}
                        end}
               end}
            end
   end}
end

function mod_menu.summon(summoner_type)
   local e = wesnoth.current.event_context
   local title = string.format("Summon %s", summoner_type)
   local image = PORTRAIT[summoner_type]
   menu3{list = get_levels(summoner_type, 5),
         image = image,
         title = title,
         description = _ "Select a unit level.",
         dialog_list = "simple",
         action = function(level)
            if level then
               menu3{list = regular[summoner_type][level],
                     image = image,
                     title = title,
                     description = _ "Select a unit to summon.",
                     dialog_list = "unit_cost",
                     sidebar = "unit",
                     action = function(choice)
                        local spawn_success = spawn_unit.reg_spawner(e.x1, e.y1, choice, summoner_type, wesnoth.current.side)
                        if not spawn_success then
                           gui2_error(_ "Insufficient hitpoints on the attempted summoner.")
                        end
               end}
            end
   end}
end

function mod_menu.summon_summoner()
   local e = wesnoth.current.event_context
   local title = _ "Summon Summoner"
   menu3{list = SUMMON_ROLES,
         title = title,
         description = _ "Select a summoner type.",
         dialog_list = "simple",
         action = function(summoner_type)
            if summoner_type then
               menu3{list = summoners[summoner_type],
                     title = title,
                     description = _ "Select a unit to summon.",
                     dialog_list = "unit",
                     sidebar = "summoner",
                     action = function(summoner) spawn_unit.boss_spawner(e.x1, e.y1, summoner, summoner_type, wesnoth.current.side) end}
            end
   end}
end

local function submenu_interact_unit_selection(unit_list, image, title)
   if unit_list[2] ~= nil then
      -- fixme: always seems to be false
      menu3{list = unit_list,
            image = image,
            title = title,
            description = _ "Which unit is doing the interaction?",
            dialog_list = "unit_name_and_location",
            action = function(choice) return choice end}
   else
      return unit_list[1]
   end
end

function mod_menu.interact()
   local e = wesnoth.current.event_context
   local title = _ "Interactions"
   local image = mod_menu.lich_image -- todo: definitely not appropriate here
   local unit_list, blocked = unit_interaction(e.x1, e.y1, wesnoth.current.side)
   local unit = submenu_interact_unit_selection(unit_list, image, title)
   if not unit then
      return
   end
   local on_hex = unit.x == e.x1 and unit.y == e.y1
   local description = _ "How do you want to interact?"
   local option = menu(find_interactions(e.x1, e.y1, blocked, on_hex), image, title, description, "with_picture", 1)
   if option then
      if option == "Interact with Unit" then
         local description = _ "What do you want to give to this unit?"
         local interactions = { "Items" }
         local interaction = menu(interactions, mod_menu.lich_image, title, description, "simple")
         if interaction then
            if interaction == "Items" then
               local description = _ "Which item do you want to give to this unit?"
               local inventory = mod_inventory.show_current(unit.variables)
               local item = menu(inventory, "", title, description, "item", nil, "item")
               if item then
                  local item = item.name
                  local description = _ "How many items do you want to gift?"
                  local max = unit.variables[item]
                  local quantity = menu_slider(title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
                  if quantity then
                     mod_inventory.transfer_item(unit, e.x1, e.y1, item, quantity)
                  end
               end
            end
         end
      elseif option == "Buy from Shop" then
         local description = _ "What item do you want to purchase from the shop?"
         local inventory = mod_inventory.show_current(containers[e.x1][e.y1]["shop"])
         local item = menu(inventory, "", title, description, "item", nil, "item")
         if item then
            local item = item.name
            local price = mod_inventory.get_item_price(item)
            local max = math.floor(wesnoth.sides[wesnoth.current.side]["gold"] / price)
            if max < 1 then
               gui2_error(_ "You can't afford that.")
            else
               local description = _ "How much do you want to buy?"
               local quantity = menu_slider(title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
               if quantity then
                  mod_inventory.shop_buy(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
               end
            end
         end
      elseif option == "Sell to Shop" then
         local description = _ "What item do you want to sell to the shop?"
         local inventory = mod_inventory.show_current(unit.variables)
         local item = menu(inventory, "", title, description, "item", nil, "item")
         if item then
            local item = item.name
            local description = _ "How much do you want to sell?"
            local price = mod_inventory.get_item_price(item)
            local max = unit.variables[item]
            local quantity = menu_slider(title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
            if quantity then
               mod_inventory.shop_sell(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
            end
         end
      elseif option == "Collect Gold" then
         local description = _ "How much gold do you want to take?"
         local max = containers[e.x1][e.y1]["gold"]
         local amount = menu_slider(title, description, _ "Gold", {max = max, min = 10, step = 10, value = max})
         if amount then
            mod_inventory.collect_gold(e.x1, e.y1, amount, wesnoth.current.side)
         end
      elseif option == "Remove from Chest" then
         local description = _ "What item do you want to remove from the chest?"
         local inventory = mod_inventory.show_current(containers[e.x1][e.y1]["chest"])
         local item = menu(inventory, "", title, description, "item", nil, "item")
         if item then
            local item = item.name
            local description = _ "How much do you want to remove?"
            local max = containers[e.x1][e.y1]["chest"][item]
            local quantity = menu_slider(title, description, _ "Quantity", {max = max, min = 1, step = 1, value = max})
            if quantity then
               mod_inventory.chest_remove(unit, e.x1, e.y1, item, quantity)
            end
         end
      elseif option == "Add to Chest" then
         local description = _ "What item do you want to put in the chest?"
         local inventory = mod_inventory.show_current(unit.variables)
         local item = menu(inventory, "", title, description, "item", nil, "item")
         if item then
            local item = item.name
            local description = _ "How much do you want to add?"
            local max = unit.variables[item]
            local quantity = menu_slider(title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
            if quantity then
               mod_inventory.chest_add(unit, e.x1, e.y1, item, quantity)
            end
         end
      end
   end
end

function mod_menu.unit_commands()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local title = _ "Unit Commands"
   local description = _ "What do you want to do with this unit?"
   local image = mod_menu.lich_image -- todo: definitely not appropriate here
   local option = menu(get_unit_commands(unit.variables.selection_active), image, title, description, "with_picture", 1)
   if option == "Select Unit" then
      unit.variables.selection_active = false
      mod_menu.select_leader()
   elseif option == "Use Item" then
      local description = _ "Which item do you want to use?"
      local inventory = mod_inventory.show_current(unit.variables)
      local item = menu(inventory, "", title, description, "item", nil, "item")
      if item then
         local item = item.name
         local description = _ "How much do you want to use?"
         local quantity = menu_slider(title, description, _ "Quantity", {max = unit.variables[item], min = 1, step = 1, value = 1})
         if quantity then
            for i=1,quantity do
               mod_inventory.use(e.x1, e.y1, item)
            end
         end
      end
   elseif option == "Upgrades" then
      local points = unit.variables["advancement"] or 0
      local point_word = "points"
      if points == 1 then
         point_word = "point"
      end
      local description = string.format("What do you want to upgrade? You have %d %s available.", points, point_word)
      menu2(get_upgrade_options(unit), "", title, description, "upgrade", nil, "upgrade",
            function(upgrade) upgrade_unit(upgrade.name, upgrade.cost, upgrade.count, upgrade.cap) end)
   elseif option == "Speak" then
      local description = _ "What do you want to say?"
      local label = _ "Message:"
      -- fixme (1.13): afaik, there's no way to force a focus on
      -- the text input except through the C++
      local message = menu_text_input(mod_menu.lich_image, title, description, label)
      if message then
         -- fixme (1.13): wesnoth.message does *not* show up in Chat
         -- Log because Wesnoth is full of terrible, hardcoded
         -- assumptions about how things will be used via buggy,
         -- half-implemented APIs.
         --
         -- fixme (1.12): make a log of these messages somewhere so
         -- that they can be accessed outside of the replay?
         wesnoth.message(string.format("(%d, %d) %s", unit.x, unit.y, tostring(unit.name)), message)
         fire.custom_message(message)
      end
   end
end

function mod_menu.unit_editor()
   local e = wesnoth.current.event_context
   local title = _ "Change Unit"
   local description = _ "What stat do you want to modify?"
   local options = {"Side", "Inventory", "Transform", "Role", "Stats"}
   local choice = menu(options, mod_menu.lich_image, title, description, "simple")
   if choice then
      if choice == "Transform" then
         local description = _ "What unit do you want it to transform to?"
         local label = _ "Unit Type:"
         local new_unit = menu_text_input(mod_menu.lich_image, title, description, label)
         if new_unit then
            change_unit.transform(e.x1, e.y1, new_unit)
         end
      elseif choice == "Role" then
         local description = _ "Select a new (summoning) role for this unit."
         menu2(get_roles(), mod_menu.lich_image, title, description, "simple", nil, nil, nil,
               function(role) change_unit.role(e.x1, e.y1, role) end)
      elseif choice == "Inventory" then
         local description = _ "Which item do you want to add?"
         menu2(mod_inventory.show_all(), "", title, description, "item", nil, "item",
               function(item) submenu_inventory_quantity(item.name, wesnoth.get_unit(e.x1, e.y1).variables) end)
      elseif choice == "Side" then
         menu2(SIDES, mod_menu.lich_image, title, "Select a target side.", "simple", nil, nil, nil,
               function(side) change_unit.side(e.x1, e.y1, side) end)
      elseif choice == "Stats" then
         local stats = {"Hitpoints", "Max Hitpoints", "Moves", "Max Moves",
                        "Experience", "Max Experience", "Gender",
                        "Leader"}
         local description = _ "Which stat do you want to change?"
         local stat = menu(stats, mod_menu.lich_image, title, description, "simple")
         if stat then
            stat = string.gsub(string.lower(stat), " ", "_")
            if stat ~= "gender" and stat ~= "leader" then
               local description = string.format("What should the new value of %s be?", stat)
               local label = "New Value:"
               local new_value
               new_value = menu_text_input(mod_menu.lich_image, title, description, label)
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
   local title = _ "Terrain Editor"
   local description = _ "Which terrain would you like to switch to?"
   local name = menu(terrain.options, mod_menu.lich_image, title, description, "simple")
   if name then
      if name == "Repeat last terrain" then
         terrain.set_terrain(terrain.last_terrain)
      elseif name == "Change radius" then
         local description = _ "What do you want to set the terrain radius as?"
         local new_radius = menu(terrain.possible_radius, mod_menu.lich_image, title, description, "simple")
         if new_radius then
            terrain.radius = new_radius
         end
      elseif name == "Set an overlay" then
         local description = _ "Which terrain would you like to switch to?"
         local overlay_name = menu(terrain.overlay_options, mod_menu.lich_image, title, description, "simple")
         if overlay_name then
            if overlay_name == "Repeat last overlay" then
               terrain.set_overlay(terrain.last_overlay)
            elseif overlay_name == "Remove overlay" then
               terrain.remove_overlay()
            else
               local description = _ "Which terrain overlay would you like to place?"
               local terrain_choice = menu(terrain.overlays[overlay_name], mod_menu.lich_image, title, description, "terrain", nil, "terrain")
               if terrain_choice then
                  terrain.set_overlay(terrain_choice)
               end
            end
         end
      else
         local description = _ "Which terrain would you like to place?"
         local terrain_choice = menu(terrain.terrain[name], mod_menu.lich_image, title, description, "terrain", nil, "terrain")
         if terrain_choice then
            terrain.set_terrain(terrain_choice)
         end
      end
   end
end

function mod_menu.place_object()
   local e = wesnoth.current.event_context
   local title = _ "Place Object"
   local description = _ "What do you want to do with this unit?"
   local option = menu(mod_menu.place_object_options, mod_menu.lich_image, title, description, "with_picture", 1)
   if option then
      if option == "Place Shop" then
         game_object.simple_place(e.x1, e.y1, "shop", "scenery/tent-shop-weapons.png", true)
      elseif option == "Place Chest" then
         game_object.simple_place(e.x1, e.y1, "chest", "items/chest-plain-closed.png", true) -- items/chest-plain-open.png
      elseif option == "Place Pack" then
         game_object.simple_place(e.x1, e.y1, "pack", "items/leather-pack.png", true)
      elseif option == "Place Gold Pile" then
         local description = _ "How much gold do you want to place in the pile?"
         local label = "Gold:"
         local gold = menu_slider(title, description, label, {max = 500, min = 10, step = 10, value = 100})
         if gold and type(gold) == "number" and gold > 0 then
            game_object.gold_place(e.x1, e.y1, gold)
         end
      elseif option == "Clear Hex" then
         game_object.clear(e.x1, e.y1)
      end
   end
end

function mod_menu.settings()
   local e = wesnoth.current.event_context
   local title = _ "Settings"
   local description = _ "What action do you want to do?"
   local option = menu(mod_menu.misc_settings, mod_menu.lich_image, title, description, "simple")
   if option then
      if option == "Modify Container" then
         local description = _ "Which container do you want to modify?"
         local interaction = menu(find_interactions_to_modify(e.x1, e.y1), mod_menu.lich_image, title, description, "with_picture", 1)
         if interaction then
            if interaction == "Modify Shop" then
               local description = _ "Which item do you want to add?"
               local item = menu(mod_inventory.show_all(), "", title, description, "item", nil, "item")
               if item then
                  local item = item.name
                  submenu_inventory_quantity(item, containers[e.x1][e.y1]["shop"])
               end
            elseif interaction == "Modify Chest" then
               local description = _ "Which item do you want to add?"
               local item = menu(mod_inventory.show_all(), "", title, description, "item", nil, "item")
               if item then
                  local item = item.name
                  submenu_inventory_quantity(item, containers[e.x1][e.y1]["chest"])
               end
            end
         end
      elseif option == "Modify Side" then
         local description = _ "Which side do you want to modify?"
         local side = menu(get_sides_with_all(), mod_menu.lich_image, title, description, "simple")
         if side then
            local description = _ "Which variable do you want to change?"
            local stats = {"gold", "village_gold", "base_income", "team_name", "objectives"}
            if side == "All" then
               stat = menu(stats, mod_menu.lich_image, title, description, "simple")
               if stat then
                  if stat ~= "objectives" then
                     local title = string.format("Choose a new value for %s", stat)
                     local label = _ "New value:"
                     local new_value = menu_text_input(mod_menu.lich_image, title, description, label)
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
               local side_stats = {}
               for i, stat in ipairs(stats) do
                  side_stats[i] = {stat, wesnoth.sides[side][stat]}
               end
               stat = menu(side_stats, mod_menu.lich_image, title, description, "almost_simple", 1, "team_stats")
               if stat then
                  if stat ~= "objectives" then
                     local title = string.format("The old value of %s is: %s ", stat, wesnoth.sides[side][stat])
                     local label = _ "New value:"
                     local new_value = menu_text_input(mod_menu.lich_image, title, description, label)
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
      elseif option == "Max Starting Level" then
         local description = "What level should be the maximum for leader selection?"
         local level = menu({1, 2, 3, 4, 5}, mod_menu.lich_image, title, description, "simple")
         if level then
            change_unit.max_level = level
         end
      elseif option == "New Scenario" then
         local description = "Which scenario do you want to start?"
         local scenario = menu(mod_menu.scenarios, mod_menu.lich_image, title, description, "almost_simple", 2)
         if scenario then
            fire.end_scenario(scenario)
         end
      elseif option == "Toggle Summon Summoners" then
         mod_menu.toggle("summon_summoner")
      elseif option == "Toggle Summon Units" then
         mod_menu.toggle("summon_units")
      elseif option == "Toggle Unit Editor" then
         mod_menu.toggle("unit_editor")
      elseif option == "Toggle Terrain Editor" then
         mod_menu.toggle("terrain_editor")
      elseif option == "Toggle Place Object" then
         mod_menu.toggle("place_object")
      end
   end
end

-- Setup --

local function menu_item_summon(unit_role)
   local menu_item = {
      id = "MOD_001_"..unit_role,
      text = "Summon "..unit_role,
      image = "terrain/symbols/terrain_group_custom3_30.png",
      filter = aeth_mod_filter.summon(unit_role),
      command = string.format("mod_menu.summon('%s')", unit_role)}
   return menu_item
end

function set_all_menu_items()
   helper.set_variable_array("mod_containers", {})
   -- Generates a quick yes/no table for summoners.
   for key, unit_list in pairs(summoners) do
      for i, unit in pairs(unit_list) do
         is_summoner[unit] = true
      end
   end
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
