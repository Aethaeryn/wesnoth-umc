#define MOD_LUA_FIRE
<<
-- Wrapper over the firing of Wesnoth events so it's more concise than
-- calling wesnoth.fire directly.
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

function fire.custom_message(message)
   wesnoth.fire("message", {
                   side    = "$side_number",
                   speaker = "unit",
                   message = message })
end

function fire.capture_village(x, y, side_number)
   wesnoth.fire("capture_village", {
                   x = x,
                   y = y,
                   side = side_number })
end

function fire.set_menu_item(menu_item_table)
   wesnoth.fire("set_menu_item", {
                   id = menu_item_table.id,
                   description = menu_item_table.text,
                   image = menu_item_table.image,
                   menu_item_table.filter,
                   T["command"] { T["lua"] { code = menu_item_table.command }}})
end

function fire.clear_menu_item(id)
   wesnoth.fire("clear_menu_item", { id = id })
end

function fire.label(x, y, text)
   wesnoth.fire("label", {
                   x = x,
                   y = y,
                   text = text})
end
>>
#enddef
