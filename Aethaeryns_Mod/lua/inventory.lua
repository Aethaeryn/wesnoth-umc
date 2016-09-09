#define MOD_LUA_INVENTORY
<<
containers = {}
mod_inventory = {}
game_object = {}

local SELL_PRICE_MODIFIER = 0.8
local SMALL_HEALING_QUANTITY = 6
local NORMAL_HEALING_QUANTITY = 14

function mod_inventory.transfer_item(unit, x, y, name, quantity)
   if quantity <= unit.variables[name] then
      local target_unit = wesnoth.get_unit(x, y)
      if target_unit.variables[name] == nil then
         target_unit.variables[name] = quantity
      else
         target_unit.variables[name] = target_unit.variables[name] + quantity
      end
      unit.variables[name] = unit.variables[name] - quantity
   end
end

function mod_inventory.chest_add(unit, x, y, name, quantity)
   if quantity <= unit.variables[name] then
      if containers[x][y]["chest"][name] == nil then
         containers[x][y]["chest"][name] = quantity
      else
         containers[x][y]["chest"][name] = containers[x][y]["chest"][name] + quantity
      end
      unit.variables[name] = unit.variables[name] - quantity
   end
end

function mod_inventory.chest_remove(unit, x, y, name, quantity)
   if quantity <= containers[x][y]["chest"][name] then
      containers[x][y]["chest"][name] = containers[x][y]["chest"][name] - quantity
      if unit.variables[name] == nil then
         unit.variables[name] = quantity
      else
         unit.variables[name] = unit.variables[name] + quantity
      end
   end
end

function game_object.clear(x, y)
   w_items.remove(x, y)
   if containers[x] ~= nil then
      containers[x][y] = nil
   end
   fire.label(x, y, "")
   local mod_containers = helper.get_variable_array("mod_containers")
   for i, coordinates in ipairs(mod_containers) do
      if coordinates.x == x and coordinates.y == y then
         wesnoth.fire("clear_variable", { name = string.format("mod_containers[%d]", i - 1) })
         return
      end
   end
end

function game_object.simple_place(x, y, container_type, image, inventory)
   game_object.clear(x,y)
   w_items.place_image(x, y, image)
   if containers[x] == nil then
      containers[x] = {}
   end
   if containers[x][y] == nil then
      containers[x][y] = {}
   end
   containers[x][y][container_type] = {}
   local l = wesnoth.get_variable("mod_containers.length")
   wesnoth.set_variable(string.format("mod_containers[%d]", l), { x = x, y = y })
   if inventory == true then
      for i, v in ipairs(item_table) do
         item_name = v["name"]
         containers[x][y][container_type][item_name] = 0
      end
   end
   if container_type == "shop" then
      fire.label(x, y, "Shop")
   end
end

function game_object.gold_place(x, y, gold)
   local gold_image = "items/gold-coins-medium.png"
   if gold < 20 then
      gold_image = "items/gold-coins-small.png"
   elseif gold >= 100 then
      gold_image = "items/gold-coins-large.png"
   end

   game_object.simple_place(x, y, "gold", gold_image, false)
   containers[x][y]["gold"] = gold
end

function mod_inventory.use(x, y, name)
   local unit = wesnoth.get_unit(x, y)
   unit.variables[name] = unit.variables[name] - 1
   if name == "Coins" then
      wesnoth.sides[wesnoth.current.side].gold = wesnoth.sides[wesnoth.current.side].gold + 10
   elseif name == "Small Healing Potion" then
      change_unit.heal(x, y, SMALL_HEALING_QUANTITY)
   elseif name == "Healing Potion" then
      change_unit.heal(x, y, NORMAL_HEALING_QUANTITY)
   elseif name == "Small Haste Potion" then
      change_unit.haste(x, y, "haste", 1)
   elseif name == "Scroll (Teleportation)" then
      mod_menu.teleport_spell(x, y)
   -- elseif name == "Haste Potion" then
   --    change_unit.haste(x, y, "haste", 2)
   -- elseif name == "Ale" then
   --    change_unit.add_turn_effect(x, y, "confidence", 3)
   end
end

function mod_inventory.add(name, quantity, container)
   if container[name] == nil then
      container[name] = quantity
   else
      container[name] = container[name] + quantity
   end
end

function mod_inventory.get_item_price(name)
   local price = 9999
   for i, item in ipairs(item_table) do
      if item.name == name then
         price = item.price
      end
   end
   return price
end

function mod_inventory.shop_buy(unit, x, y, name, quantity, price, side_number)
   if wesnoth.sides[side_number]["gold"] >= price * quantity then
      wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] - (price * quantity)
      mod_inventory.add(name, -1 * quantity, containers[x][y]["shop"])
      mod_inventory.add(name, quantity, unit.variables)
   else
      gui2_error("You can't afford that!")
   end
end

function mod_inventory.shop_sell(unit, x, y, name, quantity, price, side_number)
   wesnoth.sides[side_number]["gold"] = wesnoth.sides[side_number]["gold"] + math.floor(price * quantity * SELL_PRICE_MODIFIER)
   mod_inventory.add(name, quantity, containers[x][y]["shop"])
   mod_inventory.add(name, -1 * quantity, unit.variables)
end

-- quantity should always be valid due to the slider
function mod_inventory.collect_gold(x, y, quantity, side)
   local share_list = {}
   local share_counter = 0

   -- find allies
   for team in helper.all_teams() do
      local same_team = wesnoth.match_side(team.side, { team_name = wesnoth.sides[side]["team_name"] })
      local usually_exclude_mobs_and_npcs = (team.side ~= MOB_SIDE and team.side ~= NPC_SIDE) or side == team.side
      local has_leader = wesnoth.get_units { side = team.side, canrecruit = true }[1] ~= nil
      if same_team and usually_exclude_mobs_and_npcs and has_leader then
         table.insert(share_list, team.side)
         share_counter = share_counter + 1
      end
   end

   -- any remainder due to rounding goes to the collecting unit,
   -- otherwise it's evenly split
   local shared_quantity = math.floor(quantity / share_counter)
   local finder_bonus = 0

   if (shared_quantity * share_counter) < quantity then
      finder_bonus = quantity - (shared_quantity * share_counter)
   end

   -- actually divide the gold
   for i, target_side in ipairs(share_list) do
      wesnoth.sides[target_side]["gold"] = wesnoth.sides[target_side]["gold"] + shared_quantity
      if side == target_side then
         wesnoth.sides[target_side]["gold"] = wesnoth.sides[target_side]["gold"] + finder_bonus
      end
   end

   if quantity == containers[x][y]["gold"] then
      game_object.clear(x, y)
   else
      containers[x][y]["gold"] = containers[x][y]["gold"] - quantity
   end
end

function mod_inventory.show_current(item_holder)
   local options = {}
   for i, item in ipairs(item_table) do
      quantity = item_holder[item.name]
      if quantity ~= nil and quantity > 0 then
         table.insert(options, {name = item.name,
                                image = item.image,
                                price = item.price,
                                msg = item.msg,
                                quantity = quantity})
      end
   end
   return options
end

function mod_inventory.show_all()
   local options = {}
   for i, item in ipairs(item_table) do
      table.insert(options, {name = item.name,
                             image = item.image,
                             price = item.price,
                             msg = item.msg})
   end
   return options
end
>>
#enddef
