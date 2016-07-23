#define MOD_LUA_SPAWN_UNITS
<<
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
      }
      local guard_coords = {
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
         {62, 76, "Spearman"}
      }
      for i, coord in ipairs(peasant_coords) do
         spawn_npc(coord, "Peasant")
      end
      for i, coord in ipairs(woodsman_coords) do
         spawn_npc(coord, "Woodsman")
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
