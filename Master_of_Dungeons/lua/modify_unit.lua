#define MOD_LUA_MODIFY_UNIT
<<
function change_side(new_side)
   local event_data = wesnoth.current.event_context
   local unit = wesnoth.get_unit(event_data.x1, event_data.y1)
   unit.side = new_side
end

function change_unit_stat(stat)
   local event_data = wesnoth.current.event_context
   local unit = wesnoth.get_unit(event_data.x1, event_data.y1)
   local unit_data = unit.__cfg

   wesnoth.fire("message", {
                   speaker  = "narrator",
                   message  = "What should the new value of "..stat.." be?",
                   image    = "wesnoth-icon.png",
                   show_for = side_number,
                   T.text_input {
                      variable  = "new_stat_change",
                      label     = "Unit:",
                      max_chars = 50
                   }
                }
             )

   local change = wesnoth.get_variable("new_stat_change")

   if stat == "Hitpoints" then
      unit_data.hitpoints = change

   elseif stat == "Max Hitpoints" then
      local healthy = false

      if unit_data.hitpoints == unit_data.max_hitpoints then
         healthy = true
      end

      unit_data.max_hitpoints = change

      if healthy == true then
         unit_data.hitpoints = change
      end

   elseif stat == "Moves" then
      local unmoved = false

      if unit_data.moves == unit_data.max_moves then
         unmoved = true
      end

      unit_data.max_moves = change

      if unmoved == true then
         unit_data.moves = change
      end

   elseif stat == "Experience" then
      unit_data.experience = change

   elseif stat == "Max Experience" then
      unit_data.max_experience = change

   end

   wesnoth.put_unit(event_data.x1, event_data.y1, unit_data)
end

function change_stats(variable)
   local event_data = wesnoth.current.event_context
   local unit = wesnoth.get_unit(event_data.x1, event_data.y1)

   if variable == "Transform" then
      wesnoth.fire("message", {
                      speaker  = "narrator",
                      message  = "What unit do you want it to transform to?",
                      image    = "wesnoth-icon.png",
                      show_for = side_number,
                      T.text_input {
                         variable  = "transform_unit_to",
                         label     = "Unit:",
                         max_chars = 50
                      }
                   }
                )

      local types =  wesnoth.get_unit_type_ids()
      local new_unit = wesnoth.get_variable("transform_unit_to")

      -- checks to make sure the unit type is valid
      for id, unit_type in pairs(types) do
         if unit_type == new_unit then
            wesnoth.transform_unit(unit, new_unit)
         end
      end

   elseif variable == "Role" then
      local options = DungeonOpt:new {
         root_message   = "Select a new role for the unit.",
         option_message = "$input1",
         code           = "wesnoth.set_variable('change_role', '$input1')"
      }

      options:fire {
         {"Undead"},
         {"Nature"},
         {"Elves"},
         {"Fire"},
         {"Loyalists"},
         {"Outlaws"},
         {"Orcs"},
         {"Dwarves"},
         {"Earth"},
         {"Swamp"},
         {"Water"},
         {"None"}
      }

      -- if unit.canrecruit == true then
      ---- do something about not changing the overlay

      local chosen_role = wesnoth.get_variable('change_role')

      unit.role = chosen_role

      if chosen_role ~= "None" and unit.canrecruit ~= true then
         wesnoth.wml_actions.unit_overlay{role  = chosen_role,
                                          image = "misc/hero-icon.png"}

      elseif chosen_role == "None" then
         wesnoth.wml_actions.remove_unit_overlay{x = event_data.x1,
                                                 y = event_data.y1,
                                                 image = "misc/hero-icon.png"}         
      end

   elseif variable == "Side" then
      menu_unit_change_side()

   elseif variable == "Stats" then
      menu_unit_change_stats()
   end
end

function filter_modify_unit(permissions)
   if permissions == "DM" then
      return T.show_if {
         T.have_unit {
            x = "$x1",
            y = "$y1"
         }, {
            "and", {
               filter_host("short")
            }
         }
      }
   else
      return T.show_if {
         T.have_unit {
            side = side_number,
            x    = "$x1",
            y    = "$y1"
         }
      }
   end
end

function menu_unit_change_stats() 
   local options = DungeonOpt:new {
      root_message   = "Which stat do you want to change?",
      option_message = "$input1",
      code           = "change_unit_stat('$input1')"
   }

   options:fire {
      {"Hitpoints"},
      {"Max Hitpoints"},
      {"Moves"},
      {"Experience"},
      {"Max Experience"}
   }

end

function menu_unit_change_side()
   local options = DungeonOpt:new {
      root_message   = "Select a target side.",
      option_message = "Side $input1",
      code           = "change_side($input1)",
   }

   options:fire({
                   {1},
                   {2},
                   {3},
                   {4},
                   {5},
                   {6},
                   {7},
                   {8},
                })
end

function menu_item_unit_change_stats()
   local options = DungeonOpt:new {
      menu_id        = "021_Unit_Change_Stats",
      menu_desc      = "Change Unit Stats",
      menu_image     = "misc/icon-amla-tough.png",
      
      root_message   = "What stat do you want to modify?",
     option_message = "$input1",
      code           = "change_stats('$input1')",
   }

   options:menu({
                   {"Side"},
                   {"Transform"},
                   {"Role"},
                   {"Stats"}
                },
                filter_modify_unit("DM")
             )
end

function menu_item_unit_message()
   wesnoth.fire("set_menu_item", {
                   id          = "025_Unit_Message",
                   description = "Unit Message",
                   image       = "misc/ums.png", 
                   filter_modify_unit("all"),
                   T.command {
                      T.message {
                         speaker  = "unit",
                         caption  = "Unit Message",
                         message  = "What will you say?",
                         show_for = side_number,
                         T.text_input {
                            variable  = "aeth_custom_message",
                            label     = "Type Here:",
                            max_chars = 50
                         }
                      },
                      T.message {
                         side    = side_number,
                         speaker = "unit",
                         message = "$aeth_custom_message"
                      }
                   }
                }
             )
end

function modify_unit()
   menu_item_unit_change_stats()
   menu_item_unit_message()
end
>>
#enddef