#define MOD_LUA_TERRAIN_EDITOR
<<
terrain = {}
terrain.last_terrain = "Ur"
terrain.last_overlay = "^Vh"
terrain.radius = 0
terrain.possible_radius = {0, 1, 2}

terrain.terrain = {
   Water = {"Wog", "Wo", "Wot", "Wwg", "Ww", "Wwt", "Wwf", "Wwr", "Ss", "Sm", "Chw", "Chs", "Khw", "Khs"},
   Flat = {"Gg", "Gs", "Gd", "Gll", "Rb", "Re", "Rd", "Rr", "Rrc", "Rp", "Iwr"},
   Desert = {"Rd", "Dd", "Ds", "Dd^Dc", "Hd", "Md", "Md^Xm", "Cd", "Kd"},
   Frozen = {"Ai", "Aa", "Ha", "Ms", "Ms^Xm", "Cea", "Coa", "Cha", "Kea", "Koa", "Kha"},
   Rough = {"Hh", "Hhd", "Hd", "Ha", "Mm", "Md", "Ms", "Uh", "Mv", "Mm^Xm", "Md^Xm", "Ms^Xm"},
   Cave = {"Uu", "Uue", "Urb", "Ur", "Uh", "Qxu", "Qxe", "Qxua", "Ql", "Qlf", "Xu", "Xuc", "Xue", "Xuce", "Xos", "Xol", "Cud", "Kud"},
   Obstacle = {"Qxu", "Qxe", "Qxua", "Ql", "Qlf", "Mv", "Mm^Xm", "Md^Xm", "Ms^Xm", "Xu", "Xuc", "Xue", "Xuce", "Xos", "Xol"},
   Castle = {"Ce", "Cea", "Co", "Coa", "Ch", "Cha", "Cv", "Cud", "Chr", "Chw", "Chs", "Cd", "Ke", "Kea", "Ko", "Koa", "Kh", "Kha", "Kv", "Kud", "Khr", "Khw", "Khs", "Kd"},
   Special = {"Xv"}}

terrain.overlays = {
   Water = {
      {"^Vhs",   "Swamp Village"                  },
      {"^Vm",    "Shallow Merfolk Village"        },
      {"^Vm",    "Swamp Merfolk Village"          },
      {"^Bw|",   "Wood Bridge |"                  },
      {"^Bw/",   "Wood Bridge /"                  },
      {"^Bw\\",  "Wood Bridge \\"                 },
      {"^Bsb|",  "Basic Stone Bridge |"           },
      {"^Bsb/",  "Basic Stone Bridge /"           },
      {"^Bsb\\", "Basic Stone Bridge \\"          }},
   Desert = {
      {"^Dr",    "Rubble"                         },
      {"^Edp",   "Desert Plants"                  },
      {"^Edpp",  "Desert Plants w/o Bones"        },
      {"^Vda",   "Adobe Village"                  },
      {"^Vdt",   "Desert Tent Village"            }},
   Embellishments = {
      {"^Efm",   "Mixed Flowers"                  },
      {"^Gvs",   "Farmland"                       },
      {"^Es",    "Stones"                         },
      {"^Em",    "Small Mushrooms"                },
      {"^Emf",   "Mushroom Farm"                  },
      {"^Edp",   "Desert Plants"                  },
      {"^Edpp",  "Desert Plants w/o Bones"        },
      {"^Wm",    "Windmill"                       },
      {"^Eff",   "Fence"                          }},
   Forest = {
      {"^Do",    "Oasis"                          },
      {"^Fet",   "Great Tree"                     },
      {"^Ft",    "Tropical Forest"                },
      {"^Fp",    "Pine Forest"                    },
      {"^Fpa",   "Snowy Pine Forest"              },
      {"^Fds",   "Summer Deciduous Forest"        },
      {"^Fdf",   "Fall Deciduous Forest"          },
      {"^Fdw",   "Winter Deciduous Forest"        },
      {"^Fda",   "Snowy Deciduous Forest"         },
      {"^Fms",   "Summer Mixed Forest"            },
      {"^Fmf",   "Fall Mixed Forest"              },
      {"^Fmw",   "Winter Mixed Forest"            },
      {"^Fma",   "Snowy Mixed Forest"             },
      {"^Uf",    "Mushroom Grove"                 }},
   Frozen = {
      {"^Fpa",   "Snowy Pine Forest"              },
      {"^Fda",   "Snowy Deciduous Forest"         },
      {"^Fma",   "Snowy Mixed Forest"             },
      {"^Voa",   "Snowy Orcish Village"           },
      {"^Vea",   "Snowy Elven Village"            },
      {"^Vha",   "Snowy Cottage"                  },
      {"^Vhha",  "Snowy Hill Stone Village"       },
      {"^Vca",   "Snowy Hut"                      },
      {"^Vla",   "Snowy Log Cabin"                }},
   Rough = {
      {"^Dr",    "Rubble"                         },
      {"^Vhh",   "Hill Stone Village"             },
      {"^Vhha",  "Snowy Hill Stone Village"       },
      {"^Vhhr",  "Ruined Hill Stone Village"      }},
   Cave = {
      {"^Emf",   "Mushroom Farm"                  },
      {"^Uf",    "Mushroom Grove"                 },
      {"^Ufi",   "Lit Mushroom Grove"             },
      {"^Vu",    "Cave Village"                   },
      {"^Vud",   "Dwarven Village"                },
      {"^Br| ",  "Mine Rail |"                    },
      {"^Br/",   "Mine Rail /"                    },
      {"^Br\\",  "Mine Rail \\"                   },
      {"^Bs| ",  "Cave Chasm Bridge |"            },
      {"^Bs/",   "Cave Chasm Bridge /"            },
      {"^Bs\\",  "Cave Chasm Bridge \\"           }},
   Village = {
      {"^Vda",   "Adobe Village"                  },
      {"^Vdt",   "Desert Tent Village"            },
      {"^Vct",   "Tent Village"                   },
      {"^Vo",    "Orcish Village"                 },
      {"^Voa",   "Snowy Orcish Village"           },
      {"^Vea",   "Snowy Elven Village"            },
      {"^Ve",    "Elven Village"                  },
      {"^Vh",    "Cottage"                        },
      {"^Vha",   "Snowy Cottage"                  },
      {"^Vhr",   "Ruined Cottage"                 },
      {"^Vhc",   "Human City"                     },
      {"^Vhca", "Snowy Human City"                },
      {"^Vhcr",  "Ruined Human City"              },
      {"^Vhh",   "Hill Stone Village"             },
      {"^Vhh",   "Snowy Hill Stone Village"       },
      {"^Vhhr", "Ruined Hill Stone Village"       },
      {"^Vht",   "Tropical Village"               },
      {"^Vd",    "Drake Village"                  },
      {"^Vu",    "Cave Village"                   },
      {"^Vud",   "Dwarven Village"                },
      {"^Vc",    "Hut"                            },
      {"^Vca",   "Snowy Hut"                      },
      {"^Vl",    "Log Cabin"                      },
      {"^Vla",   "Snowy Log Cabin"                },
      {"^Vhs",   "Swamp Village"                  },
      {"^Vm",    "Shallow Merfolk Village"        },
      {"^Vm",    "Swamp Merfolk Village"          }},
   Bridge = {
      {"^Bw|",   "Wood Bridge |"                  },
      {"^Bw/",   "Wood Bridge /"                  },
      {"^Bw\\",  "Wood Bridge \\"                 },
      {"^Bsb|",  "Basic Stone Bridge |"           },
      {"^Bsb/",  "Basic Stone Bridge /"           },
      {"^Bsb\\", "Basic Stone Bridge \\"          },
      {"^Bs|",   "Cave Chasm Bridge |"            },
      {"^Bs/",   "Cave Chasm Bridge /"            },
      {"^Bs\\",  "Cave Chasm Bridge \\"           }},
   Special = {
      {"^Vov",   "Village Overlay"                },
      {"^Cov",   "Castle Overlay"                 },
      {"^Kov",   "Keep Overlay"                   }}}

function terrain.set_terrain(terrain_symbol)
   terrain.last_terrain = terrain_symbol
   for i, terrain in ipairs(terrain.change_hexes) do
      wesnoth.set_terrain(terrain[1], terrain[2], terrain_symbol)
   end
end

function terrain.set_overlay(terrain_symbol)
   terrain.last_overlay = terrain_symbol
   for i, hex in ipairs(terrain.change_hexes) do
      local terrain_type = wesnoth.get_terrain(hex[1], hex[2])
      local split_char = string.find(terrain_type, "%^")
      if split_char == nil then
         local terrain_symbol = terrain_type..terrain_symbol
         wesnoth.set_terrain(hex[1], hex[2], terrain_symbol)
      else
         local terrain_symbol = string.sub(terrain_type, 1, split_char - 1)..terrain_symbol
         wesnoth.set_terrain(hex[1], hex[2], terrain_symbol)
      end
   end
end

function terrain.remove_overlay()
   for i, hex in ipairs(terrain.change_hexes) do
      local terrain_type = wesnoth.get_terrain(hex[1], hex[2])
      local split_char = string.find(terrain_type, "%^")
      if split_char ~= nil then
         local terrain_symbol = string.sub(terrain_type, 1, split_char - 1)
         wesnoth.set_terrain(hex[1], hex[2], terrain_symbol)
      end
   end
end

function submenu_terrain_choose(name)
   if name == "Repeat last terrain" then
      terrain.set_terrain(terrain.last_terrain)
   elseif name == "Change radius" then
      local new_radius = menu(terrain.possible_radius, "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "What do you want to set the terrain radius as?", menu_simple_list)
      if new_radius then
         terrain.radius = new_radius
      end
   elseif name == "Set an overlay" then
      local options_overlay = {"Repeat last overlay", "Water", "Desert", "Embellishments", "Forest", "Frozen", "Rough", "Cave", "Village", "Bridge", "Special", "Remove overlay"}
      local overlay_name = menu(options_overlay, "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "Which terrain would you like to switch to?", menu_simple_list)
      if overlay_name then
         if overlay_name == "Repeat last overlay" then
            terrain.set_overlay(terrain.last_overlay)
         elseif overlay_name == "Remove overlay" then
            terrain.remove_overlay()
         else
            local options = DungeonOpt:new {
               root_message   = "Which overlay would you like to place?",
               option_message = "$input2",
               code           = "terrain.set_overlay('$input1')" }
            local terrain_list = terrain.overlays[overlay_name]
            options:fire(terrain_list)
         end
      end
   else
      local terrain_choice = menu(terrain.terrain[name], "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "Which terrain would you like to switch to?", menu_terrain_list)
      if terrain_choice then
         terrain.set_terrain(terrain_choice)
      end
   end
end
>>
#enddef
