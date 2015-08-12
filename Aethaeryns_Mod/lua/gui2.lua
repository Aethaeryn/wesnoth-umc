#define MOD_GUI2
<<
gui2 = {
   with_list = {},
   on_select = {}}

local function generate_dialog(not_empty, menu_type, has_sidebar)
   local menu_core = {}
   if not_empty then
      if menu_type == "list" then
         menu_core = T.column { horizontal_grow = true, T.listbox { id = "menu_list",
             T.list_definition { T.row { T.column { horizontal_grow = true,
                 T.toggle_panel { T.grid { T.row {
                                              T.column { horizontal_alignment = "left", T.image { id = "icon" }},
                                              T.column { horizontal_alignment = "left", T.label { id = "label" }}}}}}}}}}
      elseif menu_type == "text_input" then
         menu_core = T.column { T.grid {
                                   T.row { T.column { T.label { id = "menu_text_box_label" }}},
                                   T.row { T.column { T.text_box { definition = "default", id = "menu_text_box" }}}}}
      end
   else
      menu_core = T.column { T.label { id = "menu_list_empty" }}
   end
   local buttons = {}
   if not_empty then
      buttons = T.row {
         T.column { T.button { id = "ok", label = _ "OK" }},
         T.column { T.button { id = "cancel", label = _ "Close" }}}
   else
      buttons = T.row {
         T.column { T.button { id = "cancel", label = _ "Close" }}}
   end
   left_column = {}
   if has_sidebar ~= nil then
      left_column = T.column { T.grid {
                                  T.row { T.column { T.image { id = "menu_image" }}},
                                  T.row { T.column { horizontal_grow = true,
                                                     T.label { id = "menu_sidebar_intro" }}},
                                  T.row { T.column { horizontal_grow = true,
                                                     T.label { id = "menu_sidebar_text"}}}}}
   else
      left_column = T.column { T.image { id = "menu_image" }}
   end
   return {
      T.tooltip { id = "tooltip_large" },
      T.helptip { id = "tooltip_large" },
      T.grid {
         T.row { T.column { T.label { id = "menu_title" }}},
         T.row { T.column { T.label { id = "menu_description" }}},
         T.row { T.column { T.grid { T.row { left_column,
                                             T.column { T.grid {
                                                           T.row { menu_core },
                                                           T.row { T.column { T.grid { buttons }}}}}}}}}}}
end

-- This is a menu that is suitable for most of MOD. It takes in a
-- list, an image that shows on the left for decoration, a title and
-- description that show at the top, and a function that specifies how
-- the list needs to be built.
function menu(list, image, title, description, build_list, sublist_index, sidebar)
   local dialog = {}
   local not_empty = true
   if sidebar == "unit" then
      local new_list = {}
      for i, unit in ipairs(list) do
         if is_summoner[unit] == nil then
            table.insert(new_list, unit)
         end
      end
      list = new_list
   end
   if list[1] == nil then
      not_empty = false
   end
   dialog = generate_dialog(not_empty, "list", sidebar)

   local function safe_dialog()
      local choice = 0

      local function preshow()
         local function select()
            if sidebar ~= nil then
               local i = wesnoth.get_dialog_value("menu_list")
               if sidebar == "summoner" then
                  sidebar = "unit"
               end
               gui2.on_select[sidebar](list, i)
            else
               wesnoth.set_dialog_value(image, "menu_image")
            end
         end

         wesnoth.set_dialog_value(title, "menu_title")
         wesnoth.set_dialog_value(description, "menu_description")
         if not_empty then
            build_list(list)
            wesnoth.set_dialog_value(1, "menu_list")
            wesnoth.set_dialog_callback(select_actions, "menu_list")
            wesnoth.set_dialog_callback(select, "menu_list")
            select()
         else
            wesnoth.set_dialog_value(image, "menu_image")
            wesnoth.set_dialog_value("None", "menu_list_empty")
         end
      end

      local function postshow()
         if not_empty then
            choice = wesnoth.get_dialog_value("menu_list")
         else
            choice = false
         end
      end

      local button = wesnoth.show_dialog(dialog, preshow, postshow)
      -- OK
      if button == -1 then
         return { value = choice }
      -- Close
      else
         return { value = false }
      end
   end

   local safe_choice = wesnoth.synchronize_choice(safe_dialog).value
   if safe_choice then
      if sublist_index ~= nil then
         return list[safe_choice][sublist_index]
      else
         return list[safe_choice]
      end
   else
      return false
   end
end

-- Fixme: I cannot find a way to give a text box the default focus
-- like some core game text box. It might not be possible right now
-- via wesnoth/src/scripting/lua_gui2.cpp
function menu_text_input(image, title, description, label, default_text)
   local dialog = {}
   dialog = generate_dialog(true, "text_input")
   if default_text == nil then
      default_text = ""
   end

   local function safe_dialog()
      local choice = ""

      local function preshow()
         wesnoth.set_dialog_value(title, "menu_title")
         wesnoth.set_dialog_value(description, "menu_description")
         wesnoth.set_dialog_value(default_text, "menu_text_box")
         wesnoth.set_dialog_value(label, "menu_text_box_label")
         wesnoth.set_dialog_value(image, "menu_image")
      end

      local function postshow()
         choice = wesnoth.get_dialog_value("menu_text_box")
      end

      local button = wesnoth.show_dialog(dialog, preshow, postshow)
      -- OK
      if button == -1 and choice ~= "" then
         return { value = choice }
      -- Close
      else
         return { value = false }
      end
   end

   local safe_choice = wesnoth.synchronize_choice(safe_dialog).value
   return safe_choice
end

function gui2_error(text)
   local dialog = {}
   dialog = generate_dialog(false, "error")
   local function safe_dialog()
      local function preshow()
         wesnoth.set_dialog_value(_ "Error!", "menu_title")
         wesnoth.set_dialog_value(text, "menu_description")
      end

      wesnoth.show_dialog(dialog, preshow)
      return { value = false }
   end

   local safe_choice = wesnoth.synchronize_choice(safe_dialog).value
   return safe_choice
end

function menu_unit_list(units)
   local team_color = wesnoth.sides[wesnoth.current.side].color
   for i, unit in ipairs(units) do
      local unit_data = wesnoth.unit_types[unit].__cfg
      wesnoth.set_dialog_value(unit_data.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)", unit_data.image, team_color), "menu_list", i, "icon")
   end
end

function menu_unit_list_with_cost(units)
   local team_color = wesnoth.sides[wesnoth.current.side].color
   for i, unit in ipairs(units) do
      local unit_data = wesnoth.unit_types[unit].__cfg
      wesnoth.set_dialog_value(string.format("%s - %d HP", unit_data.name, unit_data.cost), "menu_list", i, "label")
      wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s)", unit_data.image, team_color), "menu_list", i, "icon")
   end
end

function menu_unit_name_and_location(units)
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

function menu_upgrade_list(upgrades)
   for i, upgrade in ipairs(upgrades) do
      wesnoth.set_dialog_value(upgrade.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(upgrade.image, "menu_list", i, "icon")
   end
end

function menu_picture_list(list)
   for i, sublist in ipairs(list) do
      wesnoth.set_dialog_value(sublist[1], "menu_list", i, "label")
      wesnoth.set_dialog_value(sublist[2], "menu_list", i, "icon")
   end
end

function menu_terrain_list(list)
   for i, terrain_code in ipairs(list) do
      wesnoth.set_dialog_value(wesnoth.get_terrain_info(terrain_code).editor_name, "menu_list", i, "label")
   end
end

function menu_simple_list(list)
   for i, item in ipairs(list) do
      wesnoth.set_dialog_value(item, "menu_list", i, "label")
   end
end

function menu_almost_simple_list(list)
   for i, sublist in ipairs(list) do
      wesnoth.set_dialog_value(sublist[1], "menu_list", i, "label")
   end
end

function gui2.on_select.unit(list, i)
   local unit_data = wesnoth.unit_types[list[i]].__cfg
   wesnoth.set_dialog_value("Information about the selected unit:  \n", "menu_sidebar_intro")
   wesnoth.set_dialog_value(string.format("%s~RC(magenta>%s",
                                          unit_data.image,
                                          wesnoth.sides[wesnoth.current.side].color),
                            "menu_image")
   wesnoth.set_dialog_markup(true, "menu_sidebar_text")
   wesnoth.set_dialog_value(string.format("<span size='small'>%s\n%s\nHP: %d\nMP: %d</span>",
                                          unit_data.name,
                                          unit_data.alignment,
                                          unit_data.hitpoints,
                                          unit_data.movement),
                            "menu_sidebar_text")
end

function gui2.on_select.team_stats(list, i)
   wesnoth.set_dialog_value("Information about the selected stat:  \n", "menu_sidebar_intro")
   wesnoth.set_dialog_markup(true, "menu_sidebar_text")
   wesnoth.set_dialog_value(string.format("%s : %s", list[i][1], list[i][2]), "menu_sidebar_text")
end

function gui2.on_select.item_stats(list, i)
   wesnoth.set_dialog_value("Information about the selected item:  \n", "menu_sidebar_intro")
   wesnoth.set_dialog_markup(true, "menu_sidebar_text")
   wesnoth.set_dialog_value(list[i][2], "menu_image")
   if list[i][5] == nil then
      wesnoth.set_dialog_value(string.format("%s\n<small>Price: %d Gold\n%s</small>",
                                             list[i][1],
                                             list[i][3],
                                             list[i][4]),
                               "menu_sidebar_text")
   else
      wesnoth.set_dialog_value(string.format("%s\n<small>Price: %d Gold\nQuantity: %d\n%s</small>",
                                             list[i][1],
                                             list[i][3],
                                             list[i][5],
                                             list[i][4]),
                               "menu_sidebar_text")
   end
end

function gui2.on_select.upgrade_stats(upgrades, i)
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
>>
#enddef
