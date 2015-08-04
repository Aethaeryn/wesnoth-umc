#define MOD_GUI2
<<
helper = wesnoth.require "lua/helper.lua"
T = helper.set_wml_tag_metatable {}

local dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "tooltip_large" },
  T.grid {
     T.row { T.column { T.label { id = "dialog_description" } } },
     T.row { T.column { T.grid { T.row {
    T.column { T.image { id = "the_image" } },
    T.column { T.grid {
      T.row { T.column { horizontal_grow = true, T.listbox { id = "the_list",
        T.list_definition { T.row { T.column { horizontal_grow = true,
          T.toggle_panel { T.grid { T.row {
            T.column { horizontal_alignment = "left", T.image { id = "the_icon" } },
            T.column { horizontal_alignment = "left", T.label { id = "the_label" } },
          }}}}}}}}},
      T.row { T.column { T.grid { T.row {
        T.column { T.button { id = "ok", label = "OK" } },
        T.column { T.button { id = "cancel", label = "Close" }}}}}}}}}}}}}}

function test_gui2(units)
   local selected_item = 0
   local function preshow()
      local function select()
         wesnoth.set_dialog_value("data/core/images/portraits/undead/transparent/ancient-lich.png", "the_image")
      end
      wesnoth.set_dialog_value("Select a unit to summon.", "dialog_description")
      wesnoth.set_dialog_callback(select, "the_list")
      for i, unit in ipairs(units) do
         local unit_data = wesnoth.unit_types[unit].__cfg
         wesnoth.set_dialog_value(unit_data.name, "the_list", i, "the_label")
         wesnoth.set_dialog_value(unit_data.image, "the_list", i, "the_icon")
      end
      wesnoth.set_dialog_value(1, "the_list")
      select()
   end
   local function postshow()
      selected_item = wesnoth.get_dialog_value "the_list"
   end
   local button_choice = wesnoth.show_dialog(dialog, preshow, postshow)
   if button_choice == -1 then
      wesnoth.message(string.format("Selected %s", units[selected_item]))
      test_gui2(regular.Undead['Level 2'])
   end
end
>>
#enddef
