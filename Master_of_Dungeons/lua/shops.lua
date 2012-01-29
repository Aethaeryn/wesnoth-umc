#define MOD_LUA_SHOPS
<<
-- Because map coordinates are at most three digits right now,
-- any location on the map can be represented in one dimension
-- by x * 1000 + y.
if game_containers == nil then
   game_containers = {}
end

function clear_game_object()
   local e = wesnoth.current.event_context
   w_items.remove(e.x1, e.y1)

   local coords = e.x1 * 1000 + e.y1

   game_containers[coords] = nil
end

function interact_do(selection)
   local e = wesnoth.current.event_context
   local coords = e.x1 * 1000 + e.y1

   -- todo: "Visit Shop", "Open Chest", "Investigate Drop"
   -- todo: Add to these as host

   if selection == "Collect Gold" then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + game_containers[coords]["gold"] 
      clear_game_object()
   end
end

function submenu_interact()
   local e = wesnoth.current.event_context

   local options = DungeonOpt:new{
      root_message   = "How do you want to interact?",
      option_message = "&$input2= $input1",
      code           = "interact_do('$input1')",
   }

   local interactions = {}

   local coords = e.x1 * 1000 + e.y1

   if game_containers[coords] ~= nil then
      if game_containers[coords]["shop"] ~= nil then
         table.insert(interactions, 1, {"Visit Shop", "scenery/tent-shop-weapons.png"})

      elseif game_containers[coords]["chest"] ~= nil then
         table.insert(interactions, 1, {"Open Chest", "items/chest-plain-closed.png"})

      elseif game_containers[coords]["pack"] ~= nil then
         table.insert(interactions, 1, {"Investigate Drop", "items/leather-pack.png"})

      elseif game_containers[coords]["gold"] ~= nil then
         table.insert(interactions, 1, {"Collect Gold", "icons/coins_copper.png"})
      end
   end

   options:fire(interactions)
end


function place_object_choose(choice)
   local e = wesnoth.current.event_context

   local function simple_place(type, image, inventory)
      clear_game_object()
      w_items.place_image(e.x1, e.y1, image)
 
      local coords = e.x1 * 1000 + e.y1

      game_containers[coords] = {}
      game_containers[coords][type] = {}

      if inventory == true then
         for i, v in ipairs(item_table) do
            item_name = v["name"]

            game_containers[coords][type][item_name] = 0
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
      simple_place("chest", "items/chest-plain-closed.png", true)

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