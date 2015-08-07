#define MOD_LUA_FIRE
<<
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

function fire.custom_message()
   wesnoth.fire("message", {
                   speaker  = "unit",
                   caption  = "Unit Message",
                   message  = "What will you say?",
                   show_for = "$side_number",
                   T["text_input"] {
                      variable  = "aeth_custom_message",
                      label     = "Type Here:",
                      max_chars = 50 }})
   local message = wesnoth.get_variable('aeth_custom_message')
   if message ~= "" then
      wesnoth.fire("message", {
                      side    = "$side_number",
                      speaker = "unit",
                      message = "$aeth_custom_message" })
   end
end

function fire.capture_village(x, y)
   wesnoth.fire("capture_village", {
                   x = x,
                   y = y,
                   side = "$side_number" })
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
>>
#enddef
