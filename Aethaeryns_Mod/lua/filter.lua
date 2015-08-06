#define MOD_LUA_FILTER
<<
helper = wesnoth.require "lua/helper.lua"
T = helper.set_wml_tag_metatable {}

aeth_mod_filter = {}
aeth_mod_filter.bad_summon_terrain = "X*, Q*, *^Xm, Mv"

-- For host-only menu items; checks for side 1 or 6, the host sides.
function filter_host(form)
   local host_side = 1

   -- The menus should also render for side 6.
   if wesnoth.get_variable("side_number") == 6 then
      host_side = 6
   end

   local filter = T["variable"] {
      name = "side_number",
      equals = host_side }

   if form == "long" then
      return T["show_if"] {
         filter }

   elseif form == "unit" then
      return T["show_if"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1" },
         T["and"] {
            filter }}
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

function filter_summon_summoner()
   return T["show_if"] {
         filter_host("short"),
         T["not"] {
            T["have_location"] {
               x = "$x1",
               y = "$y1",
               terrain = aeth_mod_filter.bad_summon_terrain },
            T["or"] {
               T["have_unit"] {
                  x = "$x1",
                  y = "$y1" }}}}
end

function filter_unit()
   return T["show_if"] {
      T["have_unit"] {
         side = side_number,
         x = "$x1",
         y = "$y1" }}
end

>>
#enddef
