#define MOD_GUI2
<<
gui2 = {
   make_list = {},
   on_select = {},
   wml = {}}

---- GUI2 WML ----

gui2.wml.list = T.column {
   horizontal_grow = true,
   T.listbox { id = "menu_list",
               T.list_definition { T.row { T.column { horizontal_grow = true,
                 T.toggle_panel {
                    return_value_id = "ok",
                    T.grid { T.row {
                                T.column { horizontal_alignment = "left", T.image { id = "icon" }},
                                T.column { horizontal_alignment = "left", T.label { id = "label" }}}}}}}}}}

-- -- Possibly buggy implementation of tree WML in Lua. Can't use until 1.13.
-- gui2.wml.tree = T.column {
--    horizontal_grow = true,
--    T.tree_view { id = "menu_tree",
--                  -- indentation_step_size = 0,
--                  T.node {
--                     id = "foobar",
--                     T.node_definition { T.row {
--                       T.column {
--                          T.toggle_button {
--                             id = "tree_view_node_icon",
--                             definition = "tree_view_node",
--                       }},
--                       T.column {
--                          grow_factor = 1,
--                          horizontal_grow = "true",
--                          border = "right",
--                          border_size = 5,
--                          T.label {
--                             id = "tree_view_node_label",
--                             definition = "default_tiny",
--                             label = "group", }}}}},
--                  T.node {
--                     id = "foo",
--                     T.node_definition { T.row { T.column { horizontal_grow = true,
--                       T.toggle_panel {
--                          return_value_id = "ok",
--                          T.grid { T.row {
--                                      T.column { horizontal_alignment = "left", T.image { id = "icon" }},
--                                      T.column { horizontal_alignment = "left", T.label { id = "label" }}}}}}}}}}}

gui2.wml.text_input = T.column {
   T.grid {
      T.row { T.column { T.label { id = "menu_text_box_label" }}},
      T.row { T.column { T.text_box { id = "menu_text_box" }}}}}

gui2.wml.empty = T.column { T.label { id = "menu_list_empty" }}

function gui2.wml.buttons(not_empty)
   if not_empty then
      return T.row {
         T.column { T.button { id = "ok", label = _ "OK" }},
         T.column { T.button { id = "cancel", label = _ "Cancel" }}}
   else
      return T.row {
         T.column { T.button { id = "cancel", label = _ "Close" }}}
   end
end

function gui2.wml.left_column(has_sidebar)
   if has_sidebar ~= nil then
      return T.column { T.grid {
                           T.row { T.column { T.image { id = "menu_image" }}},
                           T.row { T.column { horizontal_grow = true,
                                              T.label { id = "menu_sidebar_intro" }}},
                           T.row { T.column { horizontal_grow = true,
                                              T.label { id = "menu_sidebar_text"}}}}}
   else
      return T.column { T.image { id = "menu_image" }}
   end
end

function gui2.wml.dialog(not_empty, dialog_type, has_sidebar, slider)
   if not not_empty then
      dialog_type = "empty"
   end
   local dialog_core
   if dialog_type ~= "slider" then
      dialog_core = gui2.wml[dialog_type]
   else
      dialog_core = T.column {
         T.grid {
            T.row { T.column { T.label { id = "menu_slider_label" }}},
            T.row { T.column { T.slider {
                                  id = "menu_slider",
                                  minimum_value = slider.min,
                                  maximum_value = slider.max,
                                  step_size = slider.step}}}}}
   end
   return {
      T.tooltip { id = "tooltip_large" },
      T.helptip { id = "tooltip_large" },
      T.grid {
         T.row { T.column { T.label { id = "menu_title" }}},
         T.row { T.column { T.label { id = "menu_description" }}},
         T.row { T.column { T.grid { T.row { gui2.wml.left_column(has_sidebar),
                                             T.column { T.grid {
                                                           T.row { dialog_core },
                                                           T.row { T.column { T.grid { gui2.wml.buttons(not_empty) }}}}}}}}}}}
end

---- GUI2 Lua Dialogs ----

-- This returns the selection of the choice.
local function dialog_choice(dialog, preshow, not_empty, dialog_name)
   local choice

   local function postshow()
      if not_empty then
         choice = wesnoth.get_dialog_value(dialog_name)
      else
         choice = false
      end
   end

   -- OK and Cancel
   return wesnoth.synchronize_choice(
      function ()
         local button = wesnoth.show_dialog(dialog, preshow, postshow)
         if button == -1 and choice ~= "" then
            return { value = choice }
         else
            return { value = false }
         end
      end).value
end

local function do_action(choice, list, action, else_action, sublist_index)
   if choice then
      if sublist_index ~= nil then
         action(list[choice][sublist_index])
      else
         action(list[choice])
      end
   elseif else_action ~= nil then
      else_action()
   end
end

local function generate_menu_preshow(list, title, description, image, dialog_list, sidebar, not_empty)
   if image == nil then
      image = ""
   end

   if not_empty then
      return function()
         wesnoth.set_dialog_value(title, "menu_title")
         wesnoth.set_dialog_value(description, "menu_description")
         gui2.make_list[dialog_list](list)
         wesnoth.set_dialog_value(1, "menu_list")
         if sidebar ~= nil then
            local select = gui2.on_select[sidebar](list)
            wesnoth.set_dialog_callback(select, "menu_list")
            select()
         else
            wesnoth.set_dialog_value(image, "menu_image")
         end
         if wesnoth.compare_versions(wesnoth.game_config.version, ">=", "1.13.2") then
            wesnoth.set_dialog_focus("menu_list")
         end
      end
   else
      return function()
         wesnoth.set_dialog_value(title, "menu_title")
         wesnoth.set_dialog_value(description, "menu_description")
         wesnoth.set_dialog_value(image, "menu_image")
         wesnoth.set_dialog_value("None", "menu_list_empty")
         if wesnoth.compare_versions(wesnoth.game_config.version, ">=", "1.13.2") then
            wesnoth.set_dialog_focus("menu_list")
         end
      end
   end
end

-- This is a menu that is suitable for most of MOD. It takes in a
-- list, an image that shows on the left for decoration, a title and
-- description that show at the top, and a function that specifies how
-- the list needs to be built.
--
-- It takes a table with the following arguments (only list, title,
-- description, and dialog_list are mandatory):
--
-- list, image, title, description, dialog_list, sublist_index,
-- sidebar, action, else_action
function menu(arg_table)
   local not_empty = true
   local sidebar = nil
   if arg_table.list[1] == nil then
      not_empty = false
   end
   if arg_table.sidebar then
      sidebar = arg_table.dialog_list
   end
   do_action(dialog_choice(gui2.wml.dialog(not_empty, "list", sidebar),
                           generate_menu_preshow(arg_table.list,
                                                 arg_table.title,
                                                 arg_table.description,
                                                 arg_table.image,
                                                 arg_table.dialog_list,
                                                 sidebar,
                                                 not_empty),
                           not_empty,
                           "menu_list"),
             arg_table.list,
             arg_table.action,
             arg_table.else_action,
             arg_table.sublist_index)
end

-- Takes an arg table with the following values:
-- image, title, description, label, default_text
-- fixme: when updated for 1.13, make the text input box start focused
function menu_text_input(arg_table)
   if arg_table.default_text == nil then
      arg_table.default_text = ""
   end

   if arg_table.image == nil then
      arg_table.image = ""
   end

   local function preshow()
      wesnoth.set_dialog_value(arg_table.title, "menu_title")
      wesnoth.set_dialog_value(arg_table.description, "menu_description")
      wesnoth.set_dialog_value(arg_table.default_text, "menu_text_box")
      wesnoth.set_dialog_value(arg_table.label, "menu_text_box_label")
      wesnoth.set_dialog_value(arg_table.image, "menu_image")
      if wesnoth.compare_versions(wesnoth.game_config.version, ">=", "1.13.2") then
         wesnoth.set_dialog_focus("menu_text_box")
      end
   end

   local choice = dialog_choice(gui2.wml.dialog(true, "text_input"), preshow, true, "menu_text_box")
   if choice then
      arg_table.action(choice)
   end
end

-- Takes an arg table with the following values:
-- title, description, label, max, min, step, value
function menu_slider(arg_table)
   if arg_table.image == nil then
      arg_table.image = ""
   end

   local function preshow()
      wesnoth.set_dialog_value(arg_table.title, "menu_title")
      wesnoth.set_dialog_value(arg_table.description, "menu_description")
      wesnoth.set_dialog_value(arg_table.value, "menu_slider")
      wesnoth.set_dialog_value(arg_table.label, "menu_slider_label")
      wesnoth.set_dialog_value(arg_table.image, "menu_image")
   end

   local choice = dialog_choice(gui2.wml.dialog(true, "slider", nil, arg_table), preshow, true, "menu_slider")
   if choice then
      arg_table.action(choice)
   end
end

function gui2_error(text)
   local function preshow()
      wesnoth.set_dialog_value(_ "Error!", "menu_title")
      wesnoth.set_dialog_value(text, "menu_description")
   end

   wesnoth.show_dialog(gui2.wml.dialog(false), preshow)
end

---- GUI2 List Builders ----

function gui2.make_list.unit(units)
   local team_color = wesnoth.sides[wesnoth.current.side].color
   for i, unit in ipairs(units) do
      local unit_data = wesnoth.unit_types[unit].__cfg
      wesnoth.set_dialog_value(unit_data.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)", unit_data.image, team_color), "menu_list", i, "icon")
   end
end

function gui2.make_list.unit_cost(units)
   local team_color = wesnoth.sides[wesnoth.current.side].color
   for i, unit in ipairs(units) do
      local unit_data = wesnoth.unit_types[unit].__cfg
      wesnoth.set_dialog_value(string.format("%s - %d %s", unit_data.name, unit_data.cost, tostring(_ "HP")), "menu_list", i, "label")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)", unit_data.image, team_color), "menu_list", i, "icon")
   end
end

function gui2.make_list.unit_name_and_location(units)
   local team_color = wesnoth.sides[wesnoth.current.side].color
   for i, unit in ipairs(units) do
      wesnoth.set_dialog_value(string.format("%s (%s) (%d, %d)",
                                             unit.name,
                                             unit.type,
                                             unit.x,
                                             unit.y), "menu_list", i, "label")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)", unit.__cfg.image, team_color), "menu_list", i, "icon")
   end
end

function gui2.make_list.upgrade(upgrades)
   for i, upgrade in ipairs(upgrades) do
      wesnoth.set_dialog_value(upgrade.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(upgrade.image, "menu_list", i, "icon")
   end
end

function gui2.make_list.item(items)
   for i, item in ipairs(items) do
      wesnoth.set_dialog_value(item.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(item.image, "menu_list", i, "icon")
   end
end

function gui2.make_list.with_picture(list)
   for i, sublist in ipairs(list) do
      wesnoth.set_dialog_value(sublist[1], "menu_list", i, "label")
      wesnoth.set_dialog_value(sublist[2], "menu_list", i, "icon")
   end
end

function gui2.make_list.terrain(list)
   for i, terrain_code in ipairs(list) do
      wesnoth.set_dialog_value(wesnoth.get_terrain_info(terrain_code).editor_name, "menu_list", i, "label")
   end
end

function gui2.make_list.simple(list)
   for i, item in ipairs(list) do
      wesnoth.set_dialog_value(item, "menu_list", i, "label")
   end
end

function gui2.make_list.almost_simple(list)
   for i, sublist in ipairs(list) do
      wesnoth.set_dialog_value(sublist[1], "menu_list", i, "label")
   end
end

---- GUI2 On Select Actions ----

function gui2.on_select.unit(list)
   return function ()
      local i = wesnoth.get_dialog_value("menu_list")
      local unit_data = wesnoth.unit_types[list[i]].__cfg
      wesnoth.set_dialog_value("Information about the selected unit:  \n", "menu_sidebar_intro")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)",
                                             unit_data.image,
                                             wesnoth.sides[wesnoth.current.side].color),
                               "menu_image")
      wesnoth.set_dialog_markup(true, "menu_sidebar_text")
      wesnoth.set_dialog_value(string.format("<span size='small'>%s\n%s\n%s: %d\n%s: %d</span>",
                                             unit_data.name,
                                             tostring(_(unit_data.alignment)),
                                             tostring(_ "HP"),
                                             unit_data.hitpoints,
                                             tostring(_ "MP"),
                                             unit_data.movement),
                               "menu_sidebar_text")
   end
end

-- This function is identical to the above one.
gui2.on_select.unit_cost = gui2.on_select.unit

function gui2.on_select.team_stats(list)
   return function ()
      local i = wesnoth.get_dialog_value("menu_list")
      wesnoth.set_dialog_value("Information about the selected stat:  \n", "menu_sidebar_intro")
      wesnoth.set_dialog_markup(true, "menu_sidebar_text")
      wesnoth.set_dialog_value(string.format("%s : %s", list[i][1], list[i][2]), "menu_sidebar_text")
   end
end

function gui2.on_select.item(list)
   return function ()
      local i = wesnoth.get_dialog_value("menu_list")
      wesnoth.set_dialog_value("Information about the selected item:  \n", "menu_sidebar_intro")
      wesnoth.set_dialog_markup(true, "menu_sidebar_text")
      wesnoth.set_dialog_value(list[i].image, "menu_image")
      if list[i].quantity == nil then
         wesnoth.set_dialog_value(string.format("%s\n<small>Price: %d Gold\n%s</small>",
                                                list[i].name,
                                                list[i].price,
                                                list[i].msg),
                                  "menu_sidebar_text")
      else
         wesnoth.set_dialog_value(string.format("%s\n<small>Price: %d Gold\nQuantity: %d\n%s</small>",
                                                list[i].name,
                                                list[i].price,
                                                list[i].quantity,
                                                list[i].msg),
                                  "menu_sidebar_text")
      end
   end
end

function gui2.on_select.upgrade(upgrades)
   return function ()
      local i = wesnoth.get_dialog_value("menu_list")
      wesnoth.set_dialog_value("Information about the selected upgrade:  \n", "menu_sidebar_intro")
      wesnoth.set_dialog_markup(true, "menu_sidebar_text")
      wesnoth.set_dialog_value(upgrades[i].image, "menu_image")
      if upgrades[i].cap then
         wesnoth.set_dialog_value(string.format("%s\n<small>\nProgress: %d of %d\nPrice: %d\n%s</small>",
                                                upgrades[i].name,
                                                upgrades[i].count,
                                                upgrades[i].cap,
                                                upgrades[i].cost,
                                                upgrades[i].msg),
                                  "menu_sidebar_text")
      else
         wesnoth.set_dialog_value(string.format("%s\n<small>\nProgress: %d\nPrice: %d\n%s</small>",
                                                upgrades[i].name,
                                                upgrades[i].count,
                                                upgrades[i].cost,
                                                upgrades[i].msg),
                                  "menu_sidebar_text")
      end
   end
end

function gui2.on_select.terrain(terrain_code)
   return function ()
      local i = wesnoth.get_dialog_value("menu_list")
      local terrain_info = wesnoth.get_terrain_info(terrain_code[i])
      wesnoth.set_dialog_value("Terrain information:  \n", "menu_sidebar_intro")
      wesnoth.set_dialog_markup(true, "menu_sidebar_text")
      if wesnoth.compare_versions(wesnoth.game_config.version, ">", "1.13.4") then
         wesnoth.set_dialog_value(terrain_info.editor_image, "menu_image")
      end
      wesnoth.set_dialog_value(string.format("%s\n<small>%s</small>",
                                             tostring(terrain_info.editor_name),
                                             tostring(terrain_info.name)),
                               "menu_sidebar_text")
   end
end
>>
#enddef
