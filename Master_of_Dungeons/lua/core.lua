#define MOD_LUA_CORE
<<
-- For host-only menu items; checks for side 1 or 6, the host sides.
function filter_host(form)
   local host_side = 1

   -- The menus should also render for side 6.
   if wesnoth.get_variable("side_number") == 6 then
      host_side = 6
   end

   local filter = T.variable {
      name = "side_number",
      equals = host_side
   }

   if form == "long" then
      return T.show_if {
         filter
      }
      
   else
      return filter
   end
end

-- For menu items that affect certain units; check that a unit is present on that hex.
function filter_unit()
   return T.show_if {
      T.have_unit {
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

function end_scenario(new_scenario)
   scenario = 'aeth_mod_'..new_scenario

   wesnoth.fire("endlevel", {
                   result = "victory",
                   next_scenario = scenario,
                   bonus = false,
                   carryover_add = true,
                   carryover_percentage = 100,
                })
end

function menu_item_new_scenario()
   local options = DungeonOpt:new {
      menu_id        = "100_New_Scenario",
      menu_desc      = "New_Scenario",
      menu_image     = "misc/reloaded.png",

      root_message   = "Which scenario do you want to start?",
      option_message = "$input1",
      code           = "end_scenario('$input1')",
   }

   options:menu({
                   {"intro"},
                   {"intro2"},
                   {"battle"},
                   {"cavern"},
                   {"classic"},
                   {"hide_and_seek"},
                   {"open_dungeon"},
                   {"woods"},
                },
                filter_host("long")
             )
end

>>
#enddef
