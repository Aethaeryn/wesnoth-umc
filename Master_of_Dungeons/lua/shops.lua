#define MOD_LUA_SHOPS
<<
if game_containers == nil then
   game_containers = {}
end

function check_x_coord(x)
   if game_containers[x] == nil then
      game_containers[x] = {}
   end
end

function chest_add(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   game_containers[e.x1][e.y1]["chest"][name] = game_containers[e.x1][e.y1]["chest"][name] + 1
   unit.variables[name] = unit.variables[name] - 1
end

function chest_remove(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   check_x_coord(e.x1)
   game_containers[e.x1][e.y1]["chest"][name] = game_containers[e.x1][e.y1]["chest"][name] - 1
   if unit.variables[name] == nil then
      unit.variables[name] = 1
   else
      unit.variables[name] = unit.variables[name] + 1
   end
end

function shop_buy(name)
   local e = wesnoth.current.event_context
   local unit = wesnoth.get_unit(e.x1, e.y1)
   local price = 99999
   check_x_coord(e.x1)
   for i, item in ipairs(item_table) do
      if item.name == name then
         price = item.price
      end
   end
   if wesnoth.sides[side_number]["gold"] >= price then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] - price
      game_containers[e.x1][e.y1]["shop"][name] = game_containers[e.x1][e.y1]["shop"][name] - 1
      if unit.variables[name] == nil then
         unit.variables[name] = 1
      else
         unit.variables[name] = unit.variables[name] + 1
      end
   else
      wesnoth.message("Error", "You can't afford that!")
   end
end

function clear_game_object()
   local e = wesnoth.current.event_context
   w_items.remove(e.x1, e.y1)
   if game_containers[e.x1] ~= nil then
      game_containers[e.x1][e.y1] = nil
   end
end

-- todo "Investigate Drop"
function interact_do(selection, x, y)
   check_x_coord(x)
   if selection == "Visit Shop" then
      submenu_inventory('visit_shop', game_containers[x][y]["shop"])
   elseif selection == "Collect Gold" then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + game_containers[x][y]["gold"]
      clear_game_object()
   elseif selection == "Remove from Chest" then
      submenu_inventory('chest_remove', game_containers[x][y]["chest"])
   elseif selection == "Add to Chest" then
      submenu_inventory('chest_add', false)
   end
end

function modify_container_do(selection)
   local e = wesnoth.current.event_context
   check_x_coord(e.x1)
   if selection == "Modify Shop" then
      submenu_inventory('shop_modify', game_containers[e.x1][e.y1]["shop"])
   elseif selection == "Modify Chest" then
      submenu_inventory('chest_modify', game_containers[e.x1][e.y1]["chest"])
   end
end

function submenu_interact()
   local e = wesnoth.current.event_context
   local options = DungeonOpt:new{
      root_message   = "How do you want to interact?",
      option_message = "&$input2= $input1",
      code           = "interact_do('$input1', $input3, $input4)",
   }
   local interactions = {}
   check_x_coord(e.x1)
   if game_containers[e.x1][e.y1] ~= nil then
      if game_containers[e.x1][e.y1]["shop"] ~= nil then
         table.insert(interactions, 1, {"Visit Shop", "scenery/tent-shop-weapons.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["chest"] ~= nil then
         table.insert(interactions, 1, {"Remove from Chest", "items/chest-plain-closed.png", e.x1, e.y1})
         table.insert(interactions, 2, {"Add to Chest", "items/chest-plain-closed.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["pack"] ~= nil then
         table.insert(interactions, 1, {"Investigate Drop", "items/leather-pack.png", e.x1, e.y1})
      elseif game_containers[e.x1][e.y1]["gold"] ~= nil then
         table.insert(interactions, 1, {"Collect Gold", "icons/coins_copper.png", e.x1, e.y1})
      end
   end
   options:fire(interactions)
end

function submenu_modify_container()
   local e = wesnoth.current.event_context
   local options = DungeonOpt:new{
      root_message   = "Which container do you want to modify?",
      option_message = "&$input2= $input1",
      code           = "modify_container_do('$input1')",
   }
   local interactions = {}
   check_x_coord(e.x1)
   if game_containers[e.x1][e.y1] ~= nil then
      if game_containers[e.x1][e.y1]["shop"] ~= nil then
         table.insert(interactions, 1, {"Modify Shop", "scenery/tent-shop-weapons.png"})
      elseif game_containers[e.x1][e.y1]["chest"] ~= nil then
         table.insert(interactions, 1, {"Modify Chest", "items/chest-plain-closed.png"})
      elseif game_containers[e.x1][e.y1]["pack"] ~= nil then
         table.insert(interactions, 1, {"Modify Drop", "items/leather-pack.png"})
      elseif game_containers[e.x1][e.y1]["gold"] ~= nil then
         table.insert(interactions, 1, {"Modify Gold", "icons/coins_copper.png"})
      end
   end
   options:fire(interactions)
end

function place_object_choose(choice)
   local e = wesnoth.current.event_context

   local function simple_place(type, image, inventory)
      clear_game_object()
      w_items.place_image(e.x1, e.y1, image)
      check_x_coord(e.x1)
      game_containers[e.x1][e.y1] = {}
      game_containers[e.x1][e.y1][type] = {}
      if inventory == true then
         for i, v in ipairs(item_table) do
            item_name = v["name"]
            game_containers[e.x1][e.y1][type][item_name] = 0
         end
      end
   end

   local function gold()
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "How much gold do you want to place in your pile",
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T["text_input"] {
                         variable  = "place_object_gold",
                         label     = "New value:",
                         max_chars = 10
                      }
                   }
                )

      local gold = wesnoth.get_variable("place_object_gold")

      if type(gold) == "number" and gold > 0 then
         local gold_image = "items/gold-coins-medium.png"

         if gold < 20 then
            gold_image = "items/gold-coins-small.png"

         elseif gold >= 50 then
            gold_image = "items/gold-coins-large.png"
         end

         simple_place("gold", gold_image, false)

         game_containers[e.x1 * 1000 + e.y1]["gold"] = gold
      end
   end

   if choice == "Place Shop" then
      simple_place("shop", "scenery/tent-shop-weapons.png", true)

   elseif choice == "Place Chest" then
      simple_place("chest", "items/chest-plain-closed.png", true) -- items/chest-plain-open.png

   elseif choice == "Place Pack" then
      simple_place("pack", "items/leather-pack.png", true)

   elseif choice == "Place Gold Pile" then
      gold()

   elseif choice == "Clear Hex" then
      clear_game_object()
   end
end

function menu_item_placement()
   local options = DungeonOpt:new{
      menu_id        = "070_Place_Objects",
      menu_desc      = "Place Objects",
      menu_image     = "misc/dot-white.png",

      root_message   = "What item do you want to place on the map?",
      option_message = "$input1",
      code           = "place_object_choose('$input1')",
   }

   options:menu({
                   {"Place Shop"},
                   {"Place Chest"},
                   {"Place Pack"},
                   {"Place Gold Pile"},
                   {"Clear Hex"},
                },
                T["show_if"] {
                   filter_host("short"),
                   T["and"] {
                      T["not"] {
                         T["have_unit"] {
                            x = "$x1",
                            y = "$y1",
                         }
                      }
                   }
                }
             )
end

function object_placement()
   menu_item_placement()
end
>>
#enddef
