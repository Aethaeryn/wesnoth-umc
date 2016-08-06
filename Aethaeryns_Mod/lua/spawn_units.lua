#define MOD_LUA_SPAWN_UNITS
<<
spawn_unit = {}

-- Unit role is summoner type; icon and unit_role are optional.
function spawn_unit.spawn_unit(x, y, unit_type, side_number, icon, unit_role, gender)
   local unit_stats = {type = unit_type,
                       side = side_number,
                       upkeep = 0}
   if string.find(wesnoth.get_terrain(x, y), "%^V") ~= nil then
      fire.capture_village(x, y, side_number)
      unit_stats.moves = 0
   end
   if icon ~= nil then
      unit_stats.overlays = icon
   end
   if unit_role ~= nil then
      unit_stats.role = unit_role
   end
   if gender ~= nil then
      unit_stats.gender = gender
   end
   wesnoth.put_unit(x, y, unit_stats)
end

function spawn_unit.spawn_group(x, y, units, side_number)
   local hexes = wesnoth.get_locations { x = x, y = y, radius = 1 }
   local j = 1
   for i, unit in ipairs(units) do
      if wesnoth.get_unit(hexes[j][1], hexes[j][2]) == nil then
         spawn_unit.spawn_unit(hexes[j][1], hexes[j][2], unit, side_number)
      end
      j = j + 1
   end
end

function spawn_unit.boss_spawner(x, y, unit_type, unit_role, side_number)
   spawn_unit.spawn_unit(x, y, unit_type, side_number, "misc/hero-icon.png", unit_role)
   local regenerates = wesnoth.get_variable("regenerates")
   local boss_ability = { T["effect"] { apply_to = "new_ability", {"abilities", regenerates}}}
   local unit = wesnoth.get_unit(x, y)
   wesnoth.add_modification(unit, "object", boss_ability)
end

function spawn_unit.reg_spawner(x, y, unit_type, unit_role, side_number)
   local unit_cost = wesnoth.unit_types[unit_type].__cfg.cost
   local summoner = find_summoner(x, y, wesnoth.get_units {side = side_number, role = unit_role})
   if summoner.hitpoints > unit_cost then
      summoner.hitpoints = summoner.hitpoints - unit_cost
      spawn_unit.spawn_unit(x, y, unit_type, side_number)
      return true
   else
      return false
   end
end

-- Spawns all the preset units so the huge maps can get populated.
local function spawn_npc(coord, unit_name)
   spawn_unit.spawn_unit(coord[1], coord[2], unit_name, 6)
end

function spawn_default_starting_units()
   if wesnoth.get_variable("aeth_scenario_name") == "Big Woods" then
      local peasant_coords = {
         {70, 129},
         {65, 128},
         {58, 125},
         {61, 122},
         {69, 123},
         {73, 124},
         {82, 117},
         {75, 114},
         {71, 116},
         {62, 114},
         {64, 111},
         {61, 109},
         {66, 106},
         {77, 107},
         {83, 111},
         {56, 103},
         {59, 99},
         {57, 96},
         {49, 85},
         {55, 83},
         {51, 81},
         {56, 77},
         {59, 80},
         {63, 75},
         {56, 69},
         {70, 73},
         {72, 78},
         {78, 75},
         {79, 67},
         {86, 66},
         {86, 71},
         {88, 74},
         {93, 67},
         {92, 73},
         {87, 82},
         {91, 83},
         {89, 86},
         {98, 88},
         {104, 89},
         {102, 92},
         {100, 62},
         {104, 62},
         {110, 64},
         {112, 67},
         {108, 74},
         {139, 52},
         {141, 52},
         {141, 48},
         {150, 49},
         {152, 55},
         {155, 55},
         {151, 46},
         {153, 44},
         {158, 46},
         {162, 44},
         {166, 36},
         {178, 37},
         {171, 70},
         {170, 68},
         {173, 63},
         {178, 63},
         {189, 25},
         {195, 25},
         {196, 29},
         {196, 20},
         {26, 144},
         {23, 147},
         {30, 146},
         {44, 149},
         {35, 152},
         {37, 153},
         {31, 158},
         {35, 164},
         {30, 167},
         {35, 167},
         {40, 166},
         {41, 171},
         {54, 182},
         {57, 187},
         {58, 189},
         {57, 193},
      }
      local woodsman_coords = {
         {23, 44},
         {31, 72},
         {39, 91},
         {44, 94},
         {23, 124},
         {17, 131},
         {37, 42},
         {35, 48},
         {53, 50},
         {118, 69},
         {123, 70},
         {125, 65},
         {138, 81},
         {42, 196},
         {46, 197},
      }
      local ruffian_coords = {
         {133, 74},
         {135, 72},
         {140, 79},
         {142, 76},
         {115, 86},
         {117, 85},
         {107, 93},
         {107, 95},
         {64, 194},
         {62, 191},
         {65, 193},
      }
      local guard_coords = {
         -- Mountain spawns
         {37, 21, "Spearman"},
         {38, 15, "Spearman"},
         {53, 15, "Spearman"},
         {62, 14, "Spearman"},
         {65, 21, "Spearman"},
         {69, 33, "Poacher"},
         {86, 27, "Spearman"},
         {99, 28, "Bowman"},
         -- Northwest forest spawns
         {6, 54, "Spearman"},
         {8, 58, "Heavy Infantryman"},
         {7, 62, "Bowman"},
         {15, 55, "Bowman"},
         {17, 57, "Bowman"},
         {14, 64, "Bowman"},
         {18, 62, "Swordsman"},
         {35, 69, "Spearman"},
         {41, 75, "Heavy Infantryman"},
         {44, 73, "Longbowman"},
         {36, 77, "Bowman"},
         {47, 75, "Horseman"},
         {43, 78, "Horseman"},
         {52, 77, "Cavalryman"},
         {37, 36, "Bowman"},
         {34, 52, "Bowman"},
         {38, 59, "Bowman"},
         {39, 61, "Spearman"},
         {41, 63, "Spearman"},
         {53, 41, "Poacher"},
         {66, 45, "Poacher"},
         {64, 58, "Poacher"},
         {51, 65, "Bowman"},
         {54, 67, "Longbowman"},
         {57, 66, "Swordsman"},
         {53, 71, "Lieutenant"},
         {52, 68, "Spearman"},
         {51, 70, "Spearman"},
         {54, 72, "Bowman"},
         {55, 72, "Bowman"},
         {56, 72, "Spearman"},
         {59, 72, "Spearman"},
         {59, 67, "Bowman"},
         {61, 67, "Spearman"},
         {64, 68, "Spearman"},
         {69, 69, "Bowman"},
         {71, 68, "Spearman"},
         {57, 67, "Cavalryman"},
         {62, 76, "Spearman"},
         {41, 80, "Spearman"},
         {43, 81, "Bowman"},
         {43, 82, "Spearman"},
         {49, 84, "Bowman"},
         {51, 85, "Bowman"},
         {55, 86, "Cavalryman"},
         {73, 73, "Spearman"},
         {74, 75, "Heavy Infantryman"},
         {77, 72, "Heavy Infantryman"},
         {73, 76, "Cavalryman"},
         {75, 66, "Bowman"},
         {75, 65, "Spearman"},
         {78, 63, "Bowman"},
         {79, 63, "Bowman"},
         {80, 62, "Spearman"},
         {81, 64, "Lieutenant"},
         {85, 64, "Spearman"},
         {91, 66, "Sergeant"},
         {92, 64, "Bowman"},
         {93, 64, "Spearman"},
         {95, 62, "Spearman"},
         {99, 60, "Bowman"},
         {88, 72, "Bowman"},
         {93, 75, "Spearman"},
         {99, 67, "Lieutenant"},
         {98, 66, "Fencer"},
         {97, 67, "Knight"},
         {97, 68, "Horseman"},
         {98, 68, "Horseman"},
         {98, 67, "Longbowman"},
         {91, 70, "Cavalryman"},
         {106, 59, "Poacher"},
         {104, 67, "White Mage"},
         {106, 68, "Knight"},
         {106, 69, "Dragoon"},
         {107, 66, "Swordsman"},
         {107, 68, "Spearman"},
         {107, 70, "Bowman"},
         {104, 71, "Spearman"},
         {102, 71, "Spearman"},
         {100, 70, "Spearman"},
         {115, 64, "Pikeman"},
         {117, 66, "Swordsman"},
         {118, 64, "Horseman"},
         {121, 64, "Horseman"},
         {120, 65, "Spearman"},
         {121, 65, "Bowman"},
         {119, 63, "Spearman"},
         {122, 61, "Bowman"},
         {119, 66, "Horseman"},
         {123, 66, "Cavalryman"},
         {117, 71, "Cavalryman"},
         {133, 73, "Cavalryman"},
         {107, 76, "Shock Trooper"},
         {128, 62, "Spearman"},
         {128, 63, "Bowman"},
         {128, 66, "Spearman"},
         {128, 67, "Bowman"},
         {126, 68, "Lieutenant"},
         {127, 71, "Longbowman"},
         {139, 69, "Spearman"},
         {136, 70, "Bowman"},
         {134, 70, "Bowman"},
         {130, 72, "Spearman"},
         {130, 74, "Bowman"},
         {136, 81, "Bowman"},
         {139, 80, "Spearman"},
         {146, 76, "Spearman"},
         {147, 80, "Bowman"},
         {147, 79, "Thug"},
         {146, 74, "Lieutenant"},
         {145, 74, "Fencer"},
         {145, 75, "Knight"},
         {144, 77, "Horseman"},
         {146, 78, "Horseman"},
         {142, 80, "Horseman"},
         {139, 83, "Swordsman"},
         {144, 83, "Pikeman"},
         {142, 83, "Heavy Infantryman"},
         {146, 83, "Longbowman"},
         {147, 83, "Ranger"},
         {145, 83, "Swordsman"},
         {146, 82, "Heavy Infantryman"},
         {151, 74, "Spearman"},
         {106, 76, "Pikeman"},
         {107, 79, "Cavalryman"},
         {112, 80, "Lieutenant"},
         {111, 80, "Arch Mage"},
         {112, 81, "Swordsman"},
         {110, 80, "White Mage"},
         {111, 81, "Red Mage"},
         {111, 82, "Mage"},
         {112, 82, "Mage"},
         {112, 84, "Javelineer"},
         {116, 83, "Spearman"},
         {112, 86, "Bowman"},
         {113, 88, "Bowman"},
         {109, 87, "Shock Trooper"},
         {110, 88, "Duelist"},
         {110, 89, "Knight"},
         {108, 91, "Thug"},
         {109, 92, "Footpad"},
         {106, 92, "Rogue"},
         {105, 97, "General"},
         {106, 96, "Iron Mauler"},
         {106, 97, "Longbowman"},
         {103, 96, "White Mage"},
         {97, 93, "Halberdier"},
         {91, 90, "Halberdier"},
         {99, 90, "Dragoon"},
         {94, 87, "Spearman"},
         {94, 86, "Longbowman"},
         {92, 84, "Pikeman"},
         -- Southwest bandit camp
         {19, 192, "Highwayman"},
         {19, 194, "Rogue"},
         {21, 194, "Rogue"},
         {20, 193, "Rogue"},
         {19, 193, "Outlaw"},
         {21, 193, "Poacher"},
         {23, 192, "Footpad"},
         {24, 191, "Footpad"},
         {24, 190, "Poacher"},
         {23, 190, "Poacher"},
         {21, 190, "Thief"},
         {20, 190, "Thug"},
         {22, 184, "Bandit"},
         {22, 185, "Trapper"},
         {21, 186, "Footpad"},
         {20, 185, "Thief"},
         {22, 190, "Ruffian"},
         {23, 191, "Ruffian"},
         {21, 191, "Ruffian"},
         {24, 192, "Woodsman"},
         {17, 190, "Woodsman"},
         {20, 189, "Ruffian"},
         {21, 185, "Thug"},
         {20, 192, "Thief"},
         {20, 191, "Thief"},
         {22, 197, "Poacher"},
         {22, 189, "Trapper"},
         {20, 183, "Thug"},
         {18, 185, "Thug"},
         {27, 195, "Thug"},
         {28, 193, "Thug"},
         {32, 193, "Footpad"},
         {16, 197, "Footpad"},
         {15, 194, "Thug"},
         {12, 191, "Poacher"},
         {27, 175, "Footpad"},
         {24, 172, "Footpad"},
         {10, 187, "Trapper"},
         {23, 181, "Ruffian"},
         {25, 179, "Ruffian"},
         {36, 185, "Poacher"},
         -- West forest spawns
         {51, 199, "Poacher"},
         {48, 192, "Poacher"},
         {54, 195, "Spearman"},
         {57, 197, "Bowman"},
         {63, 196, "Thug"},
         {61, 195, "Sergeant"},
         {62, 193, "Bowman"},
         {61, 192, "Thug"},
         {61, 190, "Spearman"},
         {63, 189, "Thug"},
         {54, 189, "Footpad"},
         {51, 188, "Footpad"},
         {62, 185, "Spearman"},
         {57, 185, "Bowman"},
         {48, 185, "Poacher"},
         {50, 184, "Spearman"},
         {51, 183, "Bowman"},
         {54, 180, "Spearman"},
         -- North forest spawns
      }
      for i, coord in ipairs(peasant_coords) do
         spawn_npc(coord, "Peasant")
      end
      for i, coord in ipairs(woodsman_coords) do
         spawn_npc(coord, "Woodsman")
      end
      for i, coord in ipairs(ruffian_coords) do
         spawn_npc(coord, "Ruffian")
      end
      for i, coord in ipairs(guard_coords) do
         spawn_unit.spawn_unit(coord[1], coord[2], coord[3], 6)
      end
   -- else
   --    debugOut(wesnoth.get_variable("aeth_scenario_name"))
   end
end
>>
#enddef
