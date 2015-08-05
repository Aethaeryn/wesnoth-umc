#define MOD_LUA_CORE
<<

aeth_mod_filter = {}

aeth_mod_filter.bad_summon_terrain = "X*, Q*, *^Xm, Mv"

-- For host-only menu items; checks for side 1 or 6, the host sides.
function filter_host(form)
   local host_side = 1

   local function check_wesnoth_variable(variable)
      return T["variable"] {
         name = variable,
         equals = true,
      }
   end

   -- The menus should also render for side 6.
   if wesnoth.get_variable("side_number") == 6 then
      host_side = 6
   end

   local filter = T["variable"] {
      name = "side_number",
      equals = host_side,
   }

   if form == "long" then
      return T["show_if"] {
         filter
      }

   elseif form == "summoner" then
      return T["and"] {
         filter,
         T["and"] {
            check_wesnoth_variable("MoD_summon_summoner")
         }
      }

   elseif form == "editor" then
      return T["show_if"] {
         filter,
         T["and"] {
            check_wesnoth_variable("MoD_terrain_editor")
         }
      }

   elseif form == "unit" then
      return T["show_if"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1"
         },
         T["and"] {
            filter,
            T["and"] {
               check_wesnoth_variable("MoD_unit_editor")
            }
         }
      }
   else
      return filter
   end
end

function filter_item()
   return T["show_if"] {
      filter_host("short"),
      T["not"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1"}}}
end

-- For menu items that affect certain units; check that a unit is present on that hex.
function filter_unit()
   return T["show_if"] {
      T["have_unit"] {
         side = side_number,
         x = "$x1",
         y = "$y1"
      }
   }
end

>>
#enddef
