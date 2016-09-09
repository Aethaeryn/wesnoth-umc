#define MOD_LUA_FILTER
<<
-- This file is a wrapper over a bunch of WML filters so ugly and
-- verbose WML metatables don't clutter the rest of the mod.
aeth_mod_filter = {}
aeth_mod_filter.bad_summon_terrain = "X*, Q*, *^Xm, Mv"
aeth_mod_filter.host1 = T["variable"] { name = "side_number", equals = MOB_SIDE }
aeth_mod_filter.host2 = T["or"] { T["variable"] { name = "side_number", equals = NPC_SIDE }}
aeth_mod_filter.host = T["show_if"] { aeth_mod_filter.host1, aeth_mod_filter.host2 }
aeth_mod_filter.unit = T["show_if"] {
   T["have_unit"] {
      side = "$side_number",
      x = "$x1",
      y = "$y1" }}
aeth_mod_filter.host_unit = T["show_if"] {
   T["have_unit"] {
      x = "$x1",
      y = "$y1" },
   T["and"] { aeth_mod_filter.host1, aeth_mod_filter.host2 }}
aeth_mod_filter.host_item = T["show_if"] {
   aeth_mod_filter.host1, aeth_mod_filter.host2,
   T["not"] {
      T["have_location"] {
         x = "$x1",
         y = "$y1",
         terrain = aeth_mod_filter.bad_summon_terrain },
      T["or"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1" }}}}
aeth_mod_filter.summon_summoner = T["show_if"] {
   aeth_mod_filter.host1, aeth_mod_filter.host2,
   T["not"] {
      T["have_location"] {
         x = "$x1",
         y = "$y1",
         terrain = aeth_mod_filter.bad_summon_terrain },
      T["or"] {
         T["have_unit"] {
            x = "$x1",
            y = "$y1" }}}}
aeth_mod_filter.interact = T["show_if"] {
   -- menu only shows up on interaction target
   T["have_unit"] {
      x = "$x1",
      y = "$y1",
      T["filter_adjacent"] {
         side = "$side_number" }},
   -- menu only shows up on unit at location if a container is there
   T["or"] {
      T["have_unit"] {
         side = "$side_number",
         x = "$x1",
         y = "$y1",
         T["filter_location"] {
               find_in = "mod_containers",
               T["or"] { find_in = "mod_teleporters" }}}},
   -- menu only shows up adjacent to your unit if a container is there
   T["or"] {
      T["have_location"] {
         x = "$x1",
         y = "$y1",
         find_in = "mod_containers",
         T["filter_adjacent_location"] {
            T["filter"] { side = "$side_number" }}}},
   T["or"] {
      T["have_location"] {
         x = "$x1",
         y = "$y1",
         find_in = "mod_teleporters",
         T["filter_adjacent_location"] {
            T["filter"] { side = "$side_number" }}}}}

function aeth_mod_filter.summon(role)
   return T["filter_location"] {
      x = "$x1",
      y = "$y1",
      T["filter_adjacent_location"] {
         T["filter"] {
            side = "$side_number",
            role = role }},
      T["not"] {
         terrain = aeth_mod_filter.bad_summon_terrain,
         -- this is prevents spawning over another unit
         T["or"] {
            T["filter"] { }}}}
end
>>
#enddef
