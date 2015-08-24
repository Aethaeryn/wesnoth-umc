#define MOD_MENU
<<
mod_menu = {}
mod_menu.lich_image = "portraits/undead/transparent/ancient-lich.png"
mod_menu.gender = {{_ "Male ♂", "male"}, {_ "Female ♀", "female"}}
mod_menu.scenarios = {
   {"Introduction", "intro"},
   {"Introduction (Underground)", "intro2"},
   {"Battle", "battle"},
   {"Cavern", "cavern"},
   {"Classic", "classic"},
   {"Hide and Seek", "hide_and_seek"},
   {"Open Dungeon", "open_dungeon"},
   {"Woods", "woods"}}

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
   local count = menu_slider("", title, description, label, {max = 20, min = 1, step = 1, value = 1})
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

function mod_menu.toggle(menu_item)
   if mod_menu_items[menu_item].status then
      mod_menu_items[menu_item].status = false
      fire.clear_menu_item(mod_menu_items[menu_item].id)
   else
      mod_menu_items[menu_item].status = true
      fire.set_menu_item(mod_menu_items[menu_item])
   end
end

local function get_levels(category, max_level)
   local levels = {}
   for key, value in pairs(regular[category]) do
      if tonumber(string.sub(key, 7)) <= max_level then
         table.insert(levels, key)
      end
   end
   table.sort(levels)
   return levels
end

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
      local description = _ "Select a leader type."
      -- You only exit the menu at the top level, or if you choose a
      -- unit successfully.
      local done = false
      while not done do
         local leader_category = menu(LEADER_ROLES, mod_menu.lich_image, title, description, "simple")
         if leader_category then
            local description = _ "Select a unit level."
            local level = menu(get_levels(leader_category, change_unit.max_level), mod_menu.lich_image, title, description, "simple")
            if level then
               local description = _ "Select a unit."
               local choice = menu(regular[leader_category][level], mod_menu.lich_image, title, description, "unit", nil, "summoner")
               if choice then
                  if wesnoth.unit_types[choice].__cfg.gender ~= "male,female" then
                     change_unit.transform(leader.x, leader.y, choice)
                     mod_upgrade.increment(leader)
                     done = true
                  else
                     local description = _ "Select a gender."
                     local gender = menu(mod_menu.gender, mod_menu.lich_image, title, description, "almost_simple", 2)
                     if gender then
                        change_unit.transform(leader.x, leader.y, choice, gender)
                        mod_upgrade.increment(leader)
                        done = true
                     end
                  end
               end
            end
         else
            done = true
         end
      end
   end
end

function mod_menu.summon_units()
   local e = wesnoth.current.event_context
   local title = _ "Summon Units"
   local description = _ "Select what kind of summon to use."
   local option = menu({"Summon Group", "Summon Unit"}, mod_menu.lich_image, title, description, "simple")
   if option then
      if option == "Summon Group" then
         local description = _ "Select a group."
         local group = menu(unit_groups_menu, mod_menu.lich_image, title, description, "simple")
         if group then
            spawn_unit.spawn_group(e.x1, e.y1, unit_groups[group], wesnoth.current.side)
         end
      elseif option == "Summon Unit" then
         local description = _ "Select a unit category."
         local unit_category = menu(LEADER_ROLES, mod_menu.lich_image, title, description, "simple")
         if unit_category then
            local description = _ "Select a unit level."
            local level = menu(get_levels(unit_category, 5), mod_menu.lich_image, title, description, "simple")
            if level then
               local description = _ "Select a unit."
               local choice = menu(regular[unit_category][level], mod_menu.lich_image, title, description, "unit", nil, "summoner")
               if choice then
                  if wesnoth.unit_types[choice].__cfg.gender ~= "male,female" then
                     spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side)
                  else
                     local description = _ "Select a gender."
                     local gender = menu(mod_menu.gender, mod_menu.lich_image, title, description, "almost_simple", 2)
                     if gender then
                        spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side, nil, nil, gender)
                     end
                  end
               end
            end
         end
      end
   end
end

function mod_menu.summon(summoner_type)
   local e = wesnoth.current.event_context
   local title = string.format("Summon %s", summoner_type)
   local description = _ "Select a unit level."
   local image = PORTRAIT[summoner_type]
   local level = menu(get_levels(summoner_type, 5), image, title, description, "simple")
   if level then
      local description = _ "Select a unit to summon."
      local choice = menu(regular[summoner_type][level], image, title, description, "unit_cost", nil, "unit")
      if choice then
         local spawn_success = spawn_unit.reg_spawner(e.x1, e.y1, choice, summoner_type, wesnoth.current.side)
         if not spawn_success then
            gui2_error(_ "Insufficient hitpoints on the attempted summoner.")
         end
      end
   end
end

function mod_menu.summon_summoner()
   local e = wesnoth.current.event_context
   local title = _ "Summon Summoner"
   local description = _ "Select a summoner type."
   local summoner_type = menu(SUMMON_ROLES, mod_menu.lich_image, title, description, "simple")
   if summoner_type then
      local description = _ "Select a unit to summon."
      local summoner = menu(summoners[summoner_type], mod_menu.lich_image, title, description, "unit", nil, "summoner")
      if summoner then
         spawn_unit.boss_spawner(e.x1, e.y1, summoner, summoner_type, wesnoth.current.side)
      end
   end
end

function mod_menu.interact()
   local e = wesnoth.current.event_context
   local title = _ "Interactions"
   local image = mod_menu.lich_image -- todo: definitely not appropriate here
   local interaction_hexes = wesnoth.get_locations { x = e.x1, y = e.y1, radius = 1 }
   local unit_list = {}
   local current_side = wesnoth.current.side
   local blocked = false
   local on_hex = false
   for i, hex in ipairs(interaction_hexes) do
      local unit = wesnoth.get_unit(hex[1], hex[2])
      -- A unit must be in the radius on the current side...
      if unit ~= nil and unit.side == current_side then
         -- ...but a unit can't interact with itself so there must be
         -- something else on the hex other than a unit to interact
         -- with if a unit is on the hex.
         if (hex[1] ~= e.x1 or hex[2] ~= e.y1) or (containers[e.x1] ~= nil and containers[e.x1][e.y1] ~= nil) then
            table.insert(unit_list, unit)
         end
      -- A hostile unit blocks all non-unit interactions on that hex.
      elseif unit ~= nil and unit.side ~= current_side
      and wesnoth.sides[unit.side].team_name ~= wesnoth.sides[current_side].team_name then
         blocked = true
      end
   end
   local unit = unit_list[1]
   if unit_list[2] ~= nil then
      local description = _ "Which unit is doing the interaction?"
      local selected_unit = menu(unit_list, image, title, description, "unit_name_and_location")
      if selected_unit then
         unit = selected_unit
      else
         return
      end
   end
   if unit.x == e.x1 and unit.y == e.y1 then
      on_hex = true
   end
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
               local item = menu(inventory, "", title, description, "with_picture", 1, "item")
               if item then
                  local description = _ "How many items do you want to gift?"
                  local max = unit.variables[item]
                  local quantity = menu_slider("", title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
                  if quantity then
                     mod_inventory.transfer_item(unit, e.x1, e.y1, item, quantity)
                  end
               end
            end
         end
      elseif option == "Buy from Shop" then
         local description = _ "What item do you want to purchase from the shop?"
         local inventory = mod_inventory.show_current(containers[e.x1][e.y1]["shop"])
         local item = menu(inventory, "", title, description, "with_picture", 1, "item")
         if item then
            local price = mod_inventory.get_item_price(item)
            local max = math.floor(wesnoth.sides[wesnoth.current.side]["gold"] / price)
            if max < 1 then
               max = 1
            end
            local description = _ "How much do you want to buy?"
            local quantity = menu_slider("", title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
            if quantity then
               mod_inventory.shop_buy(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
            end
         end
      elseif option == "Sell to Shop" then
         local description = _ "What item do you want to sell to the shop?"
         local inventory = mod_inventory.show_current(unit.variables)
         local item = menu(inventory, "", title, description, "with_picture", 1, "item")
         if item then
            local description = _ "How much do you want to sell?"
            local price = mod_inventory.get_item_price(item)
            local max = unit.variables[item]
            local quantity = menu_slider("", title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
            if quantity then
               mod_inventory.shop_sell(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
            end
         end
      elseif option == "Collect Gold" then
         local description = _ "How much gold do you want to take?"
         local max = containers[e.x1][e.y1]["gold"]
         local amount = menu_slider("", title, description, _ "Gold", {max = max, min = 10, step = 10, value = max})
         if amount then
            mod_inventory.collect_gold(e.x1, e.y1, amount, wesnoth.current.side)
         end
      elseif option == "Remove from Chest" then
         local description = _ "What item do you want to remove from the chest?"
         local inventory = mod_inventory.show_current(containers[e.x1][e.y1]["chest"])
         local item = menu(inventory, "", title, description, "with_picture", 1, "item")
         if item then
            local description = _ "How much do you want to remove?"
            local max = containers[e.x1][e.y1]["chest"][item]
            local quantity = menu_slider("", title, description, _ "Quantity", {max = max, min = 1, step = 1, value = max})
            if quantity then
               mod_inventory.chest_remove(unit, e.x1, e.y1, item, quantity)
            end
         end
      elseif option == "Add to Chest" then
         local description = _ "What item do you want to put in the chest?"
         local inventory = mod_inventory.show_current(unit.variables)
         local item = menu(inventory, "", title, description, "with_picture", 1, "item")
         if item then
            local description = _ "How much do you want to add?"
            local max = unit.variables[item]
            local quantity = menu_slider("", title, description, _ "Quantity", {max = max, min = 1, step = 1, value = 1})
            if quantity then
               mod_inventory.chest_add(unit, e.x1, e.y1, item, quantity)
            end
         end
      end
   end
end

function mod_menu.unit_commands()
   local e = wesnoth.current.event_context
   local title = _ "Unit Commands"
   local description = _ "What do you want to do with this unit?"
   local image = mod_menu.lich_image -- todo: definitely not appropriate here
   local options = {
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}}
   local option = menu(options, image, title, description, "with_picture", 1)
   if option == "Use Item" then
      local description = _ "Which item do you want to use?"
      local unit = wesnoth.get_unit(e.x1, e.y1)
      local inventory = mod_inventory.show_current(unit.variables)
      local item = menu(inventory, "", title, description, "with_picture", 1, "item")
      if item then
         local description = _ "How much do you want to use?"
         local quantity = menu_slider("", title, description, _ "Quantity", {max = unit.variables[item], min = 1, step = 1, value = 1})
         if quantity then
            for i=1,quantity do
               mod_inventory.use(e.x1, e.y1, item)
            end
         end
      end
   elseif option == "Upgrades" then
      local unit = wesnoth.get_unit(e.x1, e.y1)
      local points = unit.variables["advancement"]
      local point_word = "points"
      local upgrades = {}
      if points == nil then
         points = 0
      end
      if points == 1 then
         point_word = "point"
      end
      for i, upgrade in ipairs(upgrade_table) do
         local upgrade_count = 0
         if unit.variables["upgrade"..upgrade.name] ~= nil then
            upgrade_count = unit.variables["upgrade"..upgrade.name]
         end
         table.insert(upgrades, {name = upgrade.name,
                                 image = upgrade.image,
                                 cost = upgrade.cost,
                                 count = upgrade_count,
                                 cap = upgrade.cap,
                                 msg = upgrade.msg})
      end
      local description = string.format("What do you want to upgrade? You have %d %s available.", points, point_word)
      local upgrade = menu(upgrades, "", title, description, "upgrade", nil, "upgrade")
      if upgrade then
         upgrade_unit(upgrade.name, upgrade.cost, upgrade.count, upgrade.cap)
      end
   elseif option == "Speak" then
      local unit = wesnoth.get_unit(e.x1, e.y1)
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
         local role = menu(get_roles(), mod_menu.lich_image, title, description, "simple")
         if role then
            change_unit.role(e.x1, e.y1, role)
         end
      elseif choice == "Inventory" then
         local description = _ "Which item do you want to add?"
         local item = menu(mod_inventory.show_all(), "", title, description, "with_picture", 1, "item")
         if item then
            submenu_inventory_quantity(item, wesnoth.get_unit(e.x1, e.y1).variables)
         end
      elseif choice == "Side" then
         local side = menu(SIDES, mod_menu.lich_image, title, "Select a target side.", "simple")
         if side then
            change_unit.side(e.x1, e.y1, side)
         end
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
   local options = {
      {"Place Shop", "scenery/tent-shop-weapons.png"},
      {"Place Chest", "items/chest-plain-closed.png"},
      {"Place Pack", "items/leather-pack.png"},
      {"Place Gold Pile", "items/gold-coins-large.png"},
      {"Clear Hex", "terrain/grass/green-symbol.png"}}
   local option = menu(options, mod_menu.lich_image, title, description, "with_picture", 1)
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
         local gold = menu_slider("", title, description, label, {max = 500, min = 10, step = 10, value = 100})
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
   local options = {"Modify Container",
                    "Modify Side",
                    "Max Starting Level",
                    "New Scenario",
                    "Toggle Summon Summoners",
                    "Toggle Summon Units",
                    "Toggle Unit Editor",
                    "Toggle Terrain Editor",
                    "Toggle Place Object"}
   local option = menu(options, mod_menu.lich_image, title, description, "simple")
   if option then
      if option == "Modify Container" then
         local description = _ "Which container do you want to modify?"
         local interaction = menu(find_interactions_to_modify(e.x1, e.y1), mod_menu.lich_image, title, description, "with_picture", 1)
         if interaction then
            if interaction == "Modify Shop" then
               local description = _ "Which item do you want to add?"
               local item = menu(mod_inventory.show_all(), "", title, description, "with_picture", 1, "item")
               if item then
                  submenu_inventory_quantity(item, containers[e.x1][e.y1]["shop"])
               end
            elseif interaction == "Modify Chest" then
               local description = _ "Which item do you want to add?"
               local item = menu(mod_inventory.show_all(), "", title, description, "with_picture", 1, "item")
               if item then
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
         local levels = {1, 2, 3, 4, 5}
         local level = menu(levels, mod_menu.lich_image, title, description, "simple")
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
