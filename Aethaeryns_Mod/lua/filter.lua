#define MOD_LUA_FILTER
<<
aeth_mod_filter = {}
aeth_mod_filter.bad_summon_terrain = "X*, Q*, *^Xm, Mv"
aeth_mod_filter.host1 = T["variable"] { name = "side_number", equals = 1 }
aeth_mod_filter.host2 = T["or"] { T["variable"] { name = "side_number", equals = 6 }}
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
