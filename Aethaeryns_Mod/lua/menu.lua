#define MOD_MENU
<<
-- This file is built on top of the gui2.lua wrapper over the game's
-- GUI2 API. The menus here use the other lua files in lua/ to do
-- actions in the game engine. By convention, menu_ functions are
-- triggered by right click menu items and submenu_ functions are
-- triggered by other menu_ functions. Due to limitations in the
-- engine, menu_ functions must be global.

-- Menu Options --
mod_menu = {}
mod_menu.lich_image = "portraits/undead/transparent/ancient-lich.png"
mod_menu.gender = {{_ "Male ♂", "male"}, {_ "Female ♀", "female"}}
mod_menu.scenarios = {
   {"Introduction", "intro"},
   {"Battle", "battle"},
   {"Woods", "big_woods"}}
mod_menu.place_object_options = {
   {"Place Shop", "scenery/tent-shop-weapons.png"},
   {"Place Chest", "items/chest-plain-closed.png"},
   {"Place Pack", "items/leather-pack.png"},
   {"Place Gold Pile", "items/gold-coins-large.png"},
   {"Clear Hex", "terrain/grass/green-symbol.png"}}
mod_menu.misc_settings =  {
   "Modify Object",
   "Modify Side",
   "Max Starting Level",
   "New Scenario",
   "Toggle Summon Summoners",
   "Toggle Summon Units",
   "Toggle Unit Editor",
   "Toggle Terrain Editor",
   "Toggle Place Object"}

-- (Most) Helper Functions --

-- Turns a function that takes (x, y, option) into a function that
-- takes (option) with x, y saved.
local function location_closure(func, x, y)
   return function(option)
      func(x, y, option)
   end
end

-- Get a list of the roles (types) allowed for summoners.
local function get_roles()
   local roles = {}
   for i, v in ipairs(SUMMON_ROLES) do
      roles[i] = SUMMON_ROLES[i]
   end
   table.insert(roles, "None")
   return roles
end

-- Add an All option at the end of the side list.
local function get_sides_with_all()
   local sides = {"All"}
   for i, v in ipairs(SIDES) do
      sides[i + 1] = SIDES[i]
   end
   return sides
end

-- Finds neighboring things on (x, y) that a unit is allowed to
-- interact with.
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
   if teleporters[x] ~= nil and teleporters[x][y] ~= nil and not blocked then
      table.insert(interactions, 1, {"Use Teleporter", "attacks/lightbeam.png"})
   end
   local unit = wesnoth.get_unit(x, y)
   if unit ~= nil and not on_hex then
      table.insert(interactions, {"Interact with Unit", string.format("%s~RC(magenta>%s)", unit.__cfg.image, wesnoth.sides[unit.side].color)})
   end
   return interactions
end

-- Find containers at (x, y) that the host can modify.
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
   if teleporters[x] ~= nil and teleporters[x][y] ~= nil then
      if wesnoth.get_variable(string.format("mod_teleporters[%d]", teleporters[x][y]))["active"] then
         table.insert(interactions, 1, {"Turn Teleporter Off", "attacks/lightbeam.png"})
      else
         table.insert(interactions, 1, {"Turn Teleporter On", "attacks/lightbeam.png"})
      end
   end
   return interactions
end

-- Find out if there are any units that can be interacted with at the
-- location (x, y).
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
         if (hex[1] ~= x or hex[2] ~= y)
            or (containers[x] ~= nil and containers[x][y] ~= nil)
            or (teleporters[x] ~= nil and teleporters[x][y] ~= nil)
         then
            table.insert(unit_list, unit)
         end
      -- A hostile unit blocks all non-unit interactions on the hex.
      elseif unit ~= nil and unit.side ~= current_side and
      not wesnoth.match_side(unit.side, { team_name = wesnoth.sides[current_side]["team_name"] }) then
         blocked = true
      end
   end
   return unit_list, blocked
end

local function get_unit_commands(unit)
   local temp_table = {
      {"Use Item", "icons/potion_red_small.png"},
      {"Upgrades", "attacks/woodensword.png"},
      {"Speak", "icons/letter_and_ale.png"}}
   -- Appends "Select Unit" to the unit commands menu if the player
   -- didn't select a leader type.
   if unit.variables.selection_active then
      table.insert(temp_table, 1, {"Select Unit", "attacks/thorns.png"})
   end
   -- Faerie elves have the power to disguise themselves.
   if unit.type == "Elvish Sylph" or unit.type == "Elvish Shyde" then
      table.insert(temp_table, 1, {"Use Disguise", "icons/jewelry_butterfly_pin.png"})
   elseif unit.type == "Elvish Lady" and unit.variables.disguised_from then
      table.insert(temp_table, 1, {"Remove Disguise", "icons/jewelry_butterfly_pin.png"})
   end
   return temp_table
end

-- Returns a list of valid levels from 0 to max_level of a particular
-- unit category in a table of units.
local function get_levels(unit_table, category, max_level)
   local levels = {}
   for key, value in pairs(unit_table[category]) do
      if tonumber(string.sub(key, 7)) <= max_level then
         table.insert(levels, key)
      end
   end
   table.sort(levels)
   return levels
end

-- Generates a list of upgrades available for the Upgrade menu.
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

-- Gets the current value of a stat and includes it in the menu list
-- for that side's stats.
local function side_stats(side, stats)
   local temp = {}
   for i, stat in ipairs(stats) do
      temp[i] = {stat, wesnoth.sides[side][stat]}
   end
   return temp
end

-- Special --

-- Toggles certain features on and off so the right click menu doesn't
-- get cluttered with something that's not currently being used.
function mod_menu.toggle(menu_item)
   if mod_menu_items[menu_item].status then
      mod_menu_items[menu_item].status = false
      fire.clear_menu_item(mod_menu_items[menu_item].id)
   else
      mod_menu_items[menu_item].status = true
      fire.set_menu_item(mod_menu_items[menu_item])
   end
end

-- Menus and Submenus --

-- Adds item to container.
-- fixme: merge with "Add to chest" submenu.
local function submenu_add_item(title, container, max)
   if max == nil then
      max = 20
   end
   menu{
      list = mod_inventory.show_all(),
      title = title,
      description = _ "Which item do you want to add?",
      dialog_list = "item",
      sidebar = true,
      action = function(item)
         menu_slider{
            title = _ "Change Inventory",
            description = string.format("How much of %s do you want to add?", item.name),
            label = _ "Item Quantity:",
            max = max,
            min = 1,
            step = 1,
            value = 1,
            action = function(quantity)
               mod_inventory.add(item.name, quantity, container)
            end
         }
      end
   }
end

-- Submenu that provides a common interface for selecting units by
-- species.
local function submenu_unit_selection_common(arg_table)
   -- You only exit the menu at the top level or if you choose a unit.
   local done = false
   if arg_table.max_level == nil then
      arg_table.max_level = 5
   end
   while not done do
      menu{
         list = LEADER_ROLES,
         title = arg_table.title,
         description = _ "Select a unit category.",
         dialog_list = "simple",
         action = function(unit_category)
            menu{
               list = get_levels(units_by_species, unit_category, arg_table.max_level),
               title = arg_table.title,
               description = _ "Select a unit level.",
               dialog_list = "simple",
               action = function(level)
                  menu{
                     list = units_by_species[unit_category][level],
                     title = arg_table.title,
                     description = _ "Select a unit.",
                     dialog_list = "unit",
                     sidebar = true,
                     action = function(choice)
                        if wesnoth.unit_types[choice].__cfg.gender ~= "male,female" then
                           arg_table.action(choice)
                           done = true
                        else
                           menu{
                              list = mod_menu.gender,
                              title = arg_table.title,
                              description = _ "Select a gender.",
                              dialog_list = "almost_simple",
                              sublist_index = 2,
                              action = function(gender)
                                 arg_table.gender_action(choice, gender)
                                 done = true
                              end
                           }
                        end
                     end
                  }
               end
            }
         end,
         else_action = function() done = true end
      }
   end
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
      local max_level
      if wesnoth.current.side == 1 or wesnoth.current.side == 6 then
         max_level = 5
      else
         max_level = change_unit.max_level
      end
      -- Lets the player come back to the submenu.
      leader.variables.selection_active = true
      submenu_unit_selection_common{
         title = title,
         max_level = max_level,
         action = function(choice)
            change_unit.transform(leader.x, leader.y, choice)
            mod_upgrade.increment(leader)
            leader.variables.dont_make_me_quick = true
            leader.variables.selection_active = false
            change_unit.max_moves_doubler(leader.x, leader.y)
         end,
         gender_action = function(choice, gender)
            change_unit.transform(leader.x, leader.y, choice, gender)
            mod_upgrade.increment(leader)
            leader.variables.dont_make_me_quick = true
            leader.variables.selection_active = false
            change_unit.max_moves_doubler(leader.x, leader.y)
         end
      }
   end
end

-- Host-only but closer to the player menus than the host menus.
function mod_menu.summon_units()
   local e = wesnoth.current.event_context
   local title = _ "Summon Units"
   menu{
      list = {"Summon Group", "Summon Unit"},
      title = title,
      description = _ "Select what kind of summon to use.",
      dialog_list = "simple",
      action = function(option)
         if option == "Summon Group" then
            menu{
               list = unit_groups_menu,
               title = title,
               description = _ "Select a group.",
               dialog_list = "simple",
               action = function(choice) spawn_unit.spawn_group(e.x1, e.y1, unit_groups[choice], wesnoth.current.side) end
            }
         elseif option == "Summon Unit" then
            submenu_unit_selection_common{
               title = title,
               action = function(choice)
                  spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side)
               end,
               gender_action = function(choice, gender)
                  spawn_unit.spawn_unit(e.x1, e.y1, choice, wesnoth.current.side, nil, nil, gender)
               end
            }
         end
      end
   }
end

function mod_menu.summon(summoner_type)
   local e = wesnoth.current.event_context
   local title = string.format("Summon %s", summoner_type)
   local image = PORTRAIT[summoner_type]
   menu{
      list = get_levels(regular, summoner_type, 5),
      image = image,
      title = title,
      description = _ "Select a unit level.",
      dialog_list = "simple",
      action = function(level)
         menu{
            list = regular[summoner_type][level],
            image = image,
            title = title,
            description = _ "Select a unit to summon.",
            dialog_list = "unit_cost",
            sidebar = true,
            action = function(choice)
               if not spawn_unit.reg_spawner(e.x1, e.y1, choice, summoner_type, wesnoth.current.side) then
                  gui2_error(_ "Insufficient hitpoints on the attempted summoner.")
               end
            end
         }
      end
   }
end

-- Host-only but closer to the player menus than the host menus.
function mod_menu.summon_summoner()
   local e = wesnoth.current.event_context
   local title = _ "Summon Summoner"
   menu{
      list = SUMMON_ROLES,
      title = title,
      description = _ "Select a summoner type.",
      dialog_list = "simple",
      action = function(summoner_type)
         menu{
            list = summoners[summoner_type],
            title = title,
            description = _ "Select a unit to summon.",
            dialog_list = "unit",
            sidebar = true,
            action = function(summoner)
               spawn_unit.boss_spawner(e.x1, e.y1, summoner, summoner_type, wesnoth.current.side)
            end
         }
      end
   }
end

-- This menu is only needed if there's more than one unit that could
-- be doing the interacting.
local function submenu_interact_unit_selection(unit_list, title)
   local unit
   if unit_list[2] ~= nil then
      menu{
         list = unit_list,
         title = title,
         description = _ "Which unit is doing the interaction?",
         dialog_list = "unit_name_and_location",
         action = function(choice)
            unit = choice
         end
      }
   else
      return unit_list[1]
   end
   if unit then
      return unit
   end
end

-- Everything a unit can do to interact with an adjacent hex that's
-- not part of the game engine.
function mod_menu.interact()
   local e = wesnoth.current.event_context
   local title = _ "Interactions"
   local unit_list, blocked = unit_interaction(e.x1, e.y1, wesnoth.current.side)
   local unit = submenu_interact_unit_selection(unit_list, title)
   if not unit then
      return
   end
   local on_hex = unit.x == e.x1 and unit.y == e.y1
   menu{
      list = find_interactions(e.x1, e.y1, blocked, on_hex),
      title = title,
      description = _ "How do you want to interact?",
      dialog_list = "with_picture",
      sublist_index = 1,
      action = function(option)
         if option == "Interact with Unit" then
            menu{
               list = { "Items" },
               title = title,
               description = _ "What do you want to give to this unit?",
               dialog_list = "simple",
               action = function(interaction)
                  if interaction == "Items" then
                     menu{
                        list = mod_inventory.show_current(unit.variables),
                        title = title,
                        description = _ "Which item do you want to give to this unit?",
                        dialog_list = "item",
                        sidebar = true,
                        action = function(item)
                           local item = item.name
                           menu_slider{
                              title = title,
                              description = _ "How many items do you want to gift?",
                              label = _ "Quantity",
                              max = unit.variables[item],
                              min = 1,
                              step = 1,
                              value = 1,
                              action = function(quantity)
                                 mod_inventory.transfer_item(unit, e.x1, e.y1, item, quantity)
                              end
                           }
                        end
                     }
                  end
               end
            }
         elseif option == "Buy from Shop" then
            menu{
               list = mod_inventory.show_current(containers[e.x1][e.y1]["shop"]),
               title = title,
               description = _ "What item do you want to purchase from the shop?",
               dialog_list = "item",
               sidebar = true,
               action = function(item)
                  local item = item.name
                  local price = mod_inventory.get_item_price(item)
                  local max = math.floor(wesnoth.sides[wesnoth.current.side]["gold"] / price)
                  if max < 1 then
                     gui2_error(_ "You can't afford that.")
                  else
                     menu_slider{
                        title = title,
                        description = _ "How much do you want to buy?",
                        label = _ "Quantity",
                        max = max,
                        min = 1,
                        step = 1,
                        value = 1,
                        action = function(quantity)
                           mod_inventory.shop_buy(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
                        end
                     }
                  end
               end
            }
         elseif option == "Sell to Shop" then
            menu{
               list = mod_inventory.show_current(unit.variables),
               title = title,
               description = _ "What item do you want to sell to the shop?",
               dialog_list = "item",
               sidebar = true,
               action = function(item)
                  local item = item.name
                  local price = mod_inventory.get_item_price(item)
                  menu_slider{
                     title = title,
                     description = _ "How much do you want to sell?",
                     label = _ "Quantity",
                     max = unit.variables[item],
                     min = 1,
                     step = 1,
                     value = 1,
                     action = function(quantity)
                        mod_inventory.shop_sell(unit, e.x1, e.y1, item, quantity, price, wesnoth.current.side)
                     end
                  }
               end
            }
         elseif option == "Collect Gold" then
            local max = containers[e.x1][e.y1]["gold"]
            menu_slider{
               title = title,
               description = _ "How much gold do you want to take?",
               label = _ "Gold",
               max = max,
               min = 10,
               step = 10,
               value = max,
               action = function(quantity)
                  mod_inventory.collect_gold(e.x1, e.y1, quantity, wesnoth.current.side)
               end
            }
         elseif option == "Remove from Chest" then
            menu{
               list = mod_inventory.show_current(containers[e.x1][e.y1]["chest"]),
               title = title,
               description = _ "What item do you want to remove from the chest?",
               dialog_list = "item",
               sidebar = true,
               action = function(item)
                  local item = item.name
                  local max = containers[e.x1][e.y1]["chest"][item]
                  menu_slider{
                     title = title,
                     description = _ "How much do you want to remove?",
                     label = _ "Quantity",
                     max = max,
                     min = 1,
                     step = 1,
                     value = max,
                     action = function(quantity)
                        mod_inventory.chest_remove(unit, e.x1, e.y1, item, quantity)
                     end
                  }
               end
            }
         elseif option == "Add to Chest" then
            menu{
               list = mod_inventory.show_current(unit.variables),
               title = title,
               description = _ "What item do you want to put in the chest?",
               dialog_list = "item",
               sidebar = true,
               action = function(item)
                  local item = item.name
                  menu_slider{
                     title = title,
                     description = _ "How much do you want to add?",
                     label = _ "Quantity",
                     max = unit.variables[item],
                     min = 1,
                     step = 1,
                     value = 1,
                     action = function(quantity)
                        mod_inventory.chest_add(unit, e.x1, e.y1, item, quantity)
                     end
                  }
               end
            }
         elseif option == "Use Teleporter" then
            local teleporter_id = teleporters[e.x1][e.y1]
            local teleporter_data = wesnoth.get_variable(string.format("mod_teleporters[%d]", teleporter_id))
            local last_teleporter_id = wesnoth.get_variable("mod_teleporters.length") - 1
            if teleporter_data["active"] then
               local destination_teleporters = {}
               for i = 0, last_teleporter_id do
                  if i ~= teleporter_id then
                     local destination_teleporter_data = wesnoth.get_variable(string.format("mod_teleporters[%d]", i))
                     if destination_teleporter_data["active"] then
                        table.insert(destination_teleporters,
                                     1,
                                     {destination_teleporter_data["name"],
                                      {destination_teleporter_data["x"],
                                       destination_teleporter_data["y"]}})
                     end
                  end
               end
               menu{
                  list = destination_teleporters,
                  title = title,
                  description = _ "Where do you want to teleport to?",
                  dialog_list = "almost_simple",
                  sublist_index = 2,
                  action = function(destination)
                     teleport_unit(destination[1], destination[2], unit, unit.side)
                  end
               }
            else
               gui2_error("The teleporter is inactive.")
            end
         end
      end
   }
end

function mod_menu.teleport_spell(x, y)
   local title = _ "Spell"
   local unit = wesnoth.get_unit(x, y)
   local destination_teleporters = {}
   local last_teleporter_id = wesnoth.get_variable("mod_teleporters.length") - 1
   for i = 0, last_teleporter_id do
      local destination_teleporter_data = wesnoth.get_variable(string.format("mod_teleporters[%d]", i))
      if destination_teleporter_data["active"] then
         table.insert(destination_teleporters,
                      1,
                      {destination_teleporter_data["name"],
                       {destination_teleporter_data["x"],
                        destination_teleporter_data["y"]}})
      end
   end
   menu{
      list = destination_teleporters,
      title = title,
      description = _ "Where do you want to teleport to?",
      dialog_list = "almost_simple",
      sublist_index = 2,
      action = function(destination)
         teleport_unit_without_cost(destination[1], destination[2], unit)
      end
   }
end

-- Everything a unit can do that isn't interacting with an adjacent
-- hex.
function mod_menu.unit_commands()
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local title = _ "Unit Commands"
   menu{
      list = get_unit_commands(unit),
      title = title,
      description = _ "What do you want to do with this unit?",
      dialog_list = "with_picture",
      sublist_index = 1,
      action = function(option)
         if option == "Use Item" then
            menu{
               list = mod_inventory.show_current(unit.variables),
               title = title,
               description = _ "Which item do you want to use?",
               dialog_list = "item",
               sidebar = true,
               action = function(item)
                  local item = item.name
                  menu_slider{
                     title = title,
                     description = _ "How much do you want to use?",
                     label = _ "Quantity",
                     max = unit.variables[item],
                     min = 1,
                     step = 1,
                     value = 1,
                     action = function(quantity)
                        for i=1,quantity do
                           mod_inventory.use(e.x1, e.y1, item)
                        end
                     end
                  }
               end
            }
         elseif option == "Upgrades" then
            menu{
               list = get_upgrade_options(unit),
               title = title,
               description = string.format("What do you want to upgrade? You have %d point(s) available.", unit.variables["advancement"] or 0),
               dialog_list = "upgrade",
               sidebar = true,
               action = function(upgrade)
                  upgrade_unit(upgrade.name, upgrade.cost, upgrade.count, upgrade.cap)
               end
            }
         elseif option == "Speak" then
            -- fixme (1.13): wesnoth.message does *not* show up in Chat
            -- Log because Wesnoth is full of terrible, hardcoded
            -- assumptions about how things will be used via buggy,
            -- half-implemented APIs.
            --
            -- fixme (1.12): make a log of these messages somewhere so
            -- that they can be accessed outside of the replay?
            menu_text_input{
               title = title,
               description = _ "What do you want to say?",
               label = _ "Message:",
               action = function(message)
                  wesnoth.message(string.format("(%d, %d) %s", unit.x, unit.y, tostring(unit.name)), message)
                  fire.custom_message(message)
               end
            }
         elseif option == "Select Unit" then
            unit.variables.selection_active = false
            mod_menu.select_leader()
         elseif option == "Use Disguise" then
            change_unit.transform_keeping_stats(e.x1, e.y1, unit, "Elvish Lady")
         elseif option == "Remove Disguise" then
            change_unit.transform_keeping_stats(e.x1, e.y1, unit, unit.variables.disguised_from)
         end
      end
   }
end

-- Host-Only Menus and Submenus --

function mod_menu.unit_editor()
   local e = wesnoth.current.event_context
   local title = _ "Change Unit"
   menu{
      list = {"Side", "Inventory", "Transform", "Role", "Stats"},
      title = title,
      description = _ "What stat do you want to modify?",
      dialog_list = "simple",
      action = function(choice)
         if choice == "Transform" then
            submenu_unit_selection_common{
               title = title,
               action = location_closure(change_unit.transform, e.x1, e.y1),
               gender_action = function(choice, gender)
                  change_unit.transform(e.x1, e.y1, choice, gender)
               end
            }
         elseif choice == "Role" then
            menu{
               list = get_roles(),
               title = title,
               description = _ "Select a new (summoning) role for this unit.",
               dialog_list = "simple",
               action = location_closure(change_unit.role, e.x1, e.y1)
            }
         elseif choice == "Inventory" then
            submenu_add_item(title, wesnoth.get_unit(e.x1, e.y1).variables)
         elseif choice == "Side" then
            menu{
               list = SIDES,
               title = title,
               description = _ "Select a target side.",
               dialog_list = "simple",
               action = location_closure(change_unit.side, e.x1, e.y1)
            }
         elseif choice == "Stats" then
            menu{
               list = {"Hitpoints", "Max Hitpoints", "Moves", "Max Moves",
                       "Experience", "Max Experience", "Gender",
                       "Leader"},
               title = title,
               description = _ "Which stat do you want to change?",
               dialog_list = "simple",
               action = function(stat)
                  stat = string.gsub(string.lower(stat), " ", "_")
                  if stat ~= "gender" and stat ~= "leader" then
                     menu_text_input{
                        title = title,
                        description = string.format("What should the new value of %s be?", stat),
                        label = _ "New Value:",
                        action = location_closure(change_unit[stat], e.x1, e.y1)
                     }
                  else
                     change_unit[stat](e.x1, e.y1)
                  end
               end
            }
         end
      end
   }
end

function mod_menu.terrain_editor()
   local e = wesnoth.current.event_context
   local title = _ "Terrain Editor"
   menu{
      list = terrain.options,
      title = title,
      description = _ "Which terrain would you like to switch to?",
      dialog_list = "simple",
      action = function(name)
         if name == "Repeat last terrain" then
            terrain.set_terrain(e.x1, e.y1, terrain.last_terrain)
         elseif name == "Change radius" then
            menu_slider{
               title = title,
               description = _ "What do you want to set the terrain radius as?",
               label = _ "Radius:",
               max = 3,
               min = 0,
               step = 1,
               value = 0,
               action = terrain.set_radius
            }
         elseif name == "Set an overlay" then
            menu{
               list = terrain.overlay_options,
               title = title,
               description = _ "Which overlay would you like to switch to?",
               dialog_list = "simple",
               action = function(overlay_name)
                  if overlay_name == "Repeat last overlay" then
                     terrain.set_overlay(e.x1, e.y1, terrain.last_overlay)
                  elseif overlay_name == "Remove overlay" then
                     terrain.remove_overlay(e.x1, e.y1)
                  else
                     menu{
                        list = terrain.overlays[overlay_name],
                        title = title,
                        description = _ "Which terrain overlay would you like to place?",
                        dialog_list = "terrain",
                        sidebar = true,
                        action = location_closure(terrain.set_overlay, e.x1, e.y1)
                     }
                  end
               end
            }
         else
            menu{
               list = terrain.terrain[name],
               title = title,
               description = _ "Which terrain would you like to place?",
               dialog_list = "terrain",
               sidebar = true,
               action = location_closure(terrain.set_terrain, e.x1, e.y1)
            }
         end
      end
   }
end

function mod_menu.place_object()
   local e = wesnoth.current.event_context
   local title = _ "Place Object"
   menu{
      list = mod_menu.place_object_options,
      title = title,
      description = _ "What do you want to do with this unit?",
      dialog_list = "with_picture",
      sublist_index = 1,
      action = function(option)
         if option == "Place Shop" then
            game_object.simple_place(e.x1, e.y1, "shop", "scenery/tent-shop-weapons.png", true)
         elseif option == "Place Chest" then
            game_object.simple_place(e.x1, e.y1, "chest", "items/chest-plain-closed.png", true) -- items/chest-plain-open.png
         elseif option == "Place Pack" then
            game_object.simple_place(e.x1, e.y1, "pack", "items/leather-pack.png", true)
         elseif option == "Place Gold Pile" then
            menu_slider{
               title = title,
               description = _ "How much gold do you want to place in the pile?",
               label = _ "Gold:",
               max = 500,
               min = 10,
               step = 10,
               value = 100,
               action = location_closure(game_object.gold_place, e.x1, e.y1)
            }
         elseif option == "Clear Hex" then
            game_object.clear(e.x1, e.y1)
         end
      end
   }
end

function mod_menu.settings()
   local e = wesnoth.current.event_context
   local title = _ "Settings"
   menu{
      list = mod_menu.misc_settings,
      title = title,
      description = _ "What action do you want to do?",
      dialog_list = "simple",
      action = function(option)
         if option == "Modify Object" then
            menu{
               list = find_interactions_to_modify(e.x1, e.y1),
               title = title,
               description = _ "Which object do you want to modify?",
               dialog_list = "with_picture",
               sublist_index = 1,
               action = function(interaction)
                  if interaction == "Modify Shop" then
                     submenu_add_item(title, containers[e.x1][e.y1]["shop"])
                  elseif interaction == "Modify Chest" then
                     submenu_add_item(title, containers[e.x1][e.y1]["chest"])
                  elseif interaction == "Turn Teleporter On" then
                     teleporter_on(e.x1, e.y1)
                  elseif interaction == "Turn Teleporter Off" then
                     teleporter_off(e.x1, e.y1)
                  end
               end
            }
         elseif option == "Modify Side" then
            menu{
               list = get_sides_with_all(),
               title = title,
               description = _ "Which side do you want to modify?",
               dialog_list = "simple",
               action = function(side)
                  local description = _ "Which variable do you want to change?"
                  local stats = {"gold", "village_gold", "base_income", "team_name", "objectives"}
                  if side == "All" then
                     menu{
                        list = stats,
                        title = title,
                        description = description,
                        dialog_list = "simple",
                        action = function(stat)
                           if stat ~= "objectives" then
                              menu_text_input{
                                 title = string.format("Choose a new value for %s", stat),
                                 description = description,
                                 label = _ "New value:",
                                 action = function(option)
                                    for i, side in ipairs(wesnoth.sides) do
                                       side[stat] = option
                                       if stat == "team_name" then
                                          side.user_team_name = side.team_name
                                       end
                                    end
                                 end
                              }
                           end
                        end
                     }
                  else
                     menu{
                        list = side_stats(side, stats),
                        title = title,
                        description = description,
                        dialog_list = "almost_simple",
                        sublist_index = 1,
                        -- sidebar = "team_stats",
                        action = function(stat)
                           if stat ~= "objectives" then
                              menu_text_input{
                                 title =  string.format("The old value of %s is: %s ", stat, wesnoth.sides[side][stat]),
                                 description = description,
                                 label = _ "New value:",
                                 action = function(option)
                                    wesnoth.sides[side][stat] = option
                                    if stat == "team_name" then
                                       wesnoth.sides[side].user_team_name = wesnoth.sides[side].team_name
                                    end
                                 end
                              }
                           end
                        end
                     }
                  end
               end
            }
         elseif option == "Max Starting Level" then
            menu_slider{
               title = title,
               description = _ "What level should be the maximum for leader selection?",
               label =  _ "Level:",
               max = 5,
               min = 0,
               step = 1,
               value = 1,
               action = change_unit.set_max_level
            }
         elseif option == "New Scenario" then
            menu{
               list = mod_menu.scenarios,
               title = title,
               description = _ "Which scenario do you want to start?",
               dialog_list = "almost_simple",
               sublist_index = 2,
               action = fire.end_scenario
            }
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
   }
end

-- Right-click menu items --

mod_menu_items = {
   summon_units = {
      id = "MOD_003",
      text = _ "Summon Units",
      image = "terrain/symbols/terrain_group_custom_30.png",
      filter = aeth_mod_filter.summon_summoner,
      command = "mod_menu.summon_units()",
      status = true },
   summon_summoner = {
      id = "MOD_005",
      text = _ "Summon Summoner",
      image = "terrain/symbols/terrain_group_custom2_30.png",
      filter = aeth_mod_filter.summon_summoner,
      command = "mod_menu.summon_summoner()",
      status = true },
   interact = {
      id = "MOD_015",
      text = _ "Interact",
      image = "misc/key.png",
      filter = aeth_mod_filter.interact,
      command = "mod_menu.interact()",
      status = true },
   unit_commands = {
      id = "MOD_010",
      text = _ "Unit Commands",
      image = "misc/key.png",
      filter = aeth_mod_filter.unit,
      command = "mod_menu.unit_commands()",
      status = true },
   unit_editor = {
      id = "MOD_020",
      text = _ "Change Unit",
      image = "misc/icon-amla-tough.png",
      filter = aeth_mod_filter.host_unit,
      command = "mod_menu.unit_editor()",
      status = true },
   terrain_editor = {
      id = "MOD_050",
      text = _ "Change Terrain",
      image = "misc/vision-fog-shroud.png",
      filter = aeth_mod_filter.host,
      command = "mod_menu.terrain_editor()",
      status = false },
   settings = {
      id = "MOD_040",
      text = _ "Settings",
      image = "misc/ums.png",
      filter = aeth_mod_filter.host,
      command = "mod_menu.settings()",
      status = true },
   place_object = {
      id = "MOD_070",
      text = _ "Place Object",
      image = "misc/dot-white.png",
      filter = aeth_mod_filter.host_item,
      command = "mod_menu.place_object()",
      status = true }}

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
   helper.set_variable_array("mod_teleporters", {})
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
