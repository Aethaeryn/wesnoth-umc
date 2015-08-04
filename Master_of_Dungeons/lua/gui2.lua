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

function test_gui2(units, image, description)
   local function safe_dialog()
      local choice = 0
      local function preshow()
         local function select()
            wesnoth.set_dialog_value(image, "the_image")
         end
         wesnoth.set_dialog_value(description, "dialog_description")
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
         choice = wesnoth.get_dialog_value "the_list"
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
   -- Calls the above function in an MP-safe way.
   return wesnoth.synchronize_choice(safe_dialog).value
end

function mp_safe_gui2()
   local image = "data/core/images/portraits/undead/transparent/ancient-lich.png"
   local description = "Select a unit to summon."
   local first_choice = test_gui2(summoners.Undead, image, description)
   if first_choice > 0 then
      wesnoth.message(string.format("Selected %s", summoners.Undead[first_choice]))
      local second_choice = test_gui2(regular.Undead['Level 2'], image, description)
      if second_choice > 0 then
         wesnoth.message(string.format("Selected %s", regular.Undead['Level 2'][second_choice]))
      end
   end
end
>>
#enddef
