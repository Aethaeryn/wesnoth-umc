#define MOD_GUI2
<<
helper = wesnoth.require "lua/helper.lua"
T = helper.set_wml_tag_metatable {}

local dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "tooltip_large" },
  T.grid {
     T.row { T.column { T.label { id = "menu_title" } } },
     T.row { T.column { T.label { id = "menu_description" } } },
     T.row { T.column { T.grid { T.row {
    T.column { T.image { id = "menu_image" } },
    T.column { T.grid {
      T.row { T.column { horizontal_grow = true, T.listbox { id = "menu_list",
        T.list_definition { T.row { T.column { horizontal_grow = true,
          T.toggle_panel { T.grid { T.row {
            T.column { horizontal_alignment = "left", T.image { id = "icon" } },
            T.column { horizontal_alignment = "left", T.label { id = "label" } },
          }}}}}}}}},
      T.row { T.column { T.grid { T.row {
        T.column { T.button { id = "ok", label = "OK" } },
        T.column { T.button { id = "cancel", label = "Close" }}}}}}}}}}}}}}

-- This is a menu that is suitable for most of MOD. It takes in a
-- list, an image that shows on the left for decoration, a title and
-- description that show at the top, and a function that specifies how
-- the list needs to be built.
function menu(list, image, title, description, build_list)
   local function safe_dialog()
      local choice = 0

      local function preshow()
         local function select()
            wesnoth.set_dialog_value(image, "menu_image")
         end

         wesnoth.set_dialog_value(title, "menu_title")
         wesnoth.set_dialog_value(description, "menu_description")
         wesnoth.set_dialog_callback(select, "menu_list")
	 build_list(list)
         wesnoth.set_dialog_value(1, "menu_list")
         select()
      end

      local function postshow()
         choice = wesnoth.get_dialog_value("menu_list")
      end

      local button = wesnoth.show_dialog(dialog, preshow, postshow)
      -- OK
      if button == -1 then
         return { value = choice }
      -- Close
      else
         return { value = 0 }
      end
   end

   local safe_choice = wesnoth.synchronize_choice(safe_dialog).value
   if safe_choice > 0 then
      return list[safe_choice]
   else
      return false
   end
end

-- todo: Add optional cost.
function menu_unit_list(units)
   for i, unit in ipairs(units) do
      local unit_data = wesnoth.unit_types[unit].__cfg
      wesnoth.set_dialog_value(unit_data.name, "menu_list", i, "label")
      wesnoth.set_dialog_value(unit_data.image, "menu_list", i, "icon")
   end
end

function menu_simple_list(list)
   for i, item in ipairs(list) do
      wesnoth.set_dialog_value(item, "menu_list", i, "label")
   end
end
>>
#enddef
