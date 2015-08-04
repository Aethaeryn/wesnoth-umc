#define MOD_LUA_CORE
<<
-- For host-only menu items; checks for side 1 or 6, the host sides.
function filter_host(form)
   local host_side = 1

   local function check_wesnoth_variable(variable)
      return T["variable"] {
         name = variable,
         equals = true,
      }
   end

   -- The menus should also render for side 6.
   if wesnoth.get_variable("side_number") == 6 then
      host_side = 6
   end

   local filter = T["variable"] {
      name = "side_number",
      equals = host_side,
   }

   if form == "long" then
      return T["show_if"] {
         filter
      }

   elseif form == "summoner" then
      return T["and"] {
         filter,
         T["and"] {
            check_wesnoth_variable("MoD_summon_summoner")
         }
      }

   elseif form == "editor" then
      return T["show_if"] {
         filter,
         T["and"] {
            check_wesnoth_variable("MoD_terrain_editor")
         }
      }

   elseif form == "unit" then
      return T["show_if"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1"
         },
         T["and"] {
            filter,
            T["and"] {
               check_wesnoth_variable("MoD_unit_editor")
            }
         }
      }
   else
      return filter
   end
end

-- For menu items that affect certain units; check that a unit is present on that hex.
function filter_unit()
   return T["show_if"] {
      T["have_unit"] {
         side = side_number,
         x = "$x1",
         y = "$y1"
      }
   }
end

-- Strictly a syntactical shortcut, and makes it easy to spot and remove from code.
function debugOut(n)
   wesnoth.message(tostring(n))
end

-- Disallows recruiting the traditional way.
wesnoth.fire("set_recruit", {
                side = "1, 2, 3, 4, 5, 6, 7, 8",
                recruit = ""
             })

-- Returns a number that approximates how hard to make a scenario.
-- You can adjust based on the number returned.
function dynamic_difficulty(side_num)
   local recalls     = wesnoth.get_recall_units{side = side_num}
   local player_gold = wesnoth.get_side(side_num).gold
   local recall_cost = 20

   local function recall_value(unit)
      local cost = wesnoth.unit_types[unit.type].cost
      local xp_percent = unit.experience / unit.max_experience
      local promotions = unit.advances_to
      local promotion_avg = 0

      for i, promotion in ipairs(promotions) do
         promotion_avg = promotion_avg + wesnoth.unit_types[promotion].cost
      end

      promotion_avg = promotion_avg / table.getn(promotions)

      local value = (1 - xp_percent) * cost + xp_percent * promotion_avg - recall_cost

      if value >= 0 then
         return value
      else
         return 0
      end
   end

   local strength_table = {}

   for i, unit in ipairs(recalls) do
      table.insert(strength_table, recall_value(unit))
   end

   table.sort(strength_table)

   local max_recalls = math.floor(player_gold / recall_cost)
   local recall_strength = 0
   local counter = 1

   while max_recalls >= 0 and counter <= table.getn(strength_table) do
      recall_strength = recall_strength + strength_table[counter]
      counter = counter + 1
      max_recalls = max_recalls - 1
   end

   return recall_strength
end

-- debugOut(dynamic_difficulty(2))

function options_list_short(root_msg, run, options_table)
   local options = DungeonOpt:new{
      root_message   = root_msg,
      option_message = '$input1',
      code           = run,
   }

   options:short_fire(options_table)
end

function set_menu_item(id, description, image, filter, command)
   wesnoth.fire("set_menu_item", {
                   id = id,
                   description = description,
                   image = image,
                   filter,
                   T["command"] { T["lua"] { code = command }}})
end

>>
#enddef
