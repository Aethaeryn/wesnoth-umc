#define MOD_DATA_MENU
<<
mod_menu = {
   summon_summoner = {
      id = "MOD_005",
      text = "Summon Summoner",
      image = "terrain/symbols/terrain_group_custom2_30.png",
      filter = filter_summon_summoner(),
      command = "spawn_units.menu_summon_summoner()",
      status = true },
   unit_commands = {
      id = "MOD_010",
      text = "Unit Commands",
      image = "misc/key.png",
      filter = filter_unit(),
      command = "menu_inventory()",
      status = true },
   unit_editor = {
      id = "MOD_020",
      text = "Change Unit",
      image = "misc/icon-amla-tough.png",
      filter = filter_host("unit"),
      command = "menu_unit_change_stats()",
      status = true },
   terrain_editor = {
      id = "MOD_050",
      text = "Change Terrain",
      image = "misc/vision-fog-shroud.png",
      filter = filter_host("long"),
      command = "menu_change_terrain()",
      status = true },
   settings = {
      id = "MOD_040",
      text = "Settings",
      image = "misc/ums.png",
      filter = filter_host("long"),
      command = "menu_settings()",
      status = true },
   place_object = {
      id = "MOD_070",
      text = "Place Object",
      image = "misc/dot-white.png",
      filter = filter_item(),
      command = "menu_placement()",
      status = true }}
>>
#enddef
