#define MOD_DATA_MENU
<<
mod_menu_items = {
   summon_summoner = {
      id = "MOD_005",
      text = "Summon Summoner",
      image = "terrain/symbols/terrain_group_custom2_30.png",
      filter = filter_summon_summoner(),
      command = "mod_menu.summon_summoner()",
      status = true },
   unit_commands = {
      id = "MOD_010",
      text = "Unit Commands",
      image = "misc/key.png",
      filter = filter_unit(),
      command = "mod_menu.unit_commands()",
      status = true },
   unit_editor = {
      id = "MOD_020",
      text = "Change Unit",
      image = "misc/icon-amla-tough.png",
      filter = filter_host("unit"),
      command = "mod_menu.unit_editor()",
      status = true },
   terrain_editor = {
      id = "MOD_050",
      text = "Change Terrain",
      image = "misc/vision-fog-shroud.png",
      filter = filter_host("long"),
      command = "mod_menu.terrain_editor()",
      status = true },
   settings = {
      id = "MOD_040",
      text = "Settings",
      image = "misc/ums.png",
      filter = filter_host("long"),
      command = "mod_menu.settings()",
      status = true },
   place_object = {
      id = "MOD_070",
      text = "Place Object",
      image = "misc/dot-white.png",
      filter = filter_item(),
      command = "mod_menu.place_object()",
      status = true }}
>>
#enddef
