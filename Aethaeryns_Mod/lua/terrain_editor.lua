#define MOD_LUA_TERRAIN_EDITOR
<<
terrain = {}
terrain.last_terrain = "Ur"
terrain.last_overlay = "^Vh"
terrain.radius = 0
terrain.possible_radius = {0, 1, 2}

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

function submenu_overlay_options(name)
   local options = DungeonOpt:new{
      root_message   = "Which overlay would you like to place?",
      option_message = "$input2",
      code           = "terrain.set_overlay('$input1')"
   }
   if name == "Repeat last overlay" then
      terrain.set_overlay(terrain.last_overlay)
   elseif name == "Remove overlay" then
      terrain.remove_overlay()
   elseif name == "Water" then
      local terrain_list = {
         {"^Vhs",   "Swamp Village"                  },
         {"^Vm",    "Shallow Merfolk Village"        },
         {"^Vm",    "Swamp Merfolk Village"          },
         {"^Bw|",   "Wood Bridge |"                  },
         {"^Bw/",   "Wood Bridge /"                  },
         {"^Bw\\",  "Wood Bridge \\"                 },
         {"^Bsb|",  "Basic Stone Bridge |"           },
         {"^Bsb/",  "Basic Stone Bridge /"           },
         {"^Bsb\\", "Basic Stone Bridge \\"          }}
      options:fire(terrain_list)
   elseif name == "Desert" then
      local terrain_list = {
         {"^Dr",    "Rubble"                         },
         {"^Edp",   "Desert Plants"                  },
         {"^Edpp",  "Desert Plants w/o Bones"        },
         {"^Vda",   "Adobe Village"                  },
         {"^Vdt",   "Desert Tent Village"            }}
      options:fire(terrain_list)
   elseif name == "Embellishments" then
      local terrain_list = {
         {"^Efm",   "Mixed Flowers"                  },
         {"^Gvs",   "Farmland"                       },
         {"^Es",    "Stones"                         },
         {"^Em",    "Small Mushrooms"                },
         {"^Emf",   "Mushroom Farm"                  },
         {"^Edp",   "Desert Plants"                  },
         {"^Edpp",  "Desert Plants w/o Bones"        },
         {"^Wm",    "Windmill"                       },
         {"^Eff",   "Fence"                          }}
      options:fire(terrain_list)
   elseif name == "Forest" then
      local terrain_list = {
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
         {"^Uf",    "Mushroom Grove"                 }}
      options:fire(terrain_list)
   elseif name == "Frozen" then
      local terrain_list = {
         {"^Fpa",   "Snowy Pine Forest"              },
         {"^Fda",   "Snowy Deciduous Forest"         },
         {"^Fma",   "Snowy Mixed Forest"             },
         {"^Voa",   "Snowy Orcish Village"           },
         {"^Vea",   "Snowy Elven Village"            },
         {"^Vha",   "Snowy Cottage"                  },
         {"^Vhha",  "Snowy Hill Stone Village"       },
         {"^Vca",   "Snowy Hut"                      },
         {"^Vla",   "Snowy Log Cabin"                }}
      options:fire(terrain_list)
   elseif name == "Rough" then
      local terrain_list = {
         {"^Dr",    "Rubble"                         },
         {"^Vhh",   "Hill Stone Village"             },
         {"^Vhha",  "Snowy Hill Stone Village"       },
         {"^Vhhr",  "Ruined Hill Stone Village"      }}
      options:fire(terrain_list)
   elseif name == "Cave" then
      local terrain_list = {
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
         {"^Bs\\",  "Cave Chasm Bridge \\"           }}
      options:fire(terrain_list)
   elseif name == "Village" then
      local terrain_list = {
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
         {"^Vm",    "Swamp Merfolk Village"          }}
      options:fire(terrain_list)
   elseif name == "Bridge" then
      local terrain_list = {
         {"^Bw|",   "Wood Bridge |"                  },
         {"^Bw/",   "Wood Bridge /"                  },
         {"^Bw\\",  "Wood Bridge \\"                 },
         {"^Bsb|",  "Basic Stone Bridge |"           },
         {"^Bsb/",  "Basic Stone Bridge /"           },
         {"^Bsb\\", "Basic Stone Bridge \\"          },
         {"^Bs|",   "Cave Chasm Bridge |"            },
         {"^Bs/",   "Cave Chasm Bridge /"            },
         {"^Bs\\",  "Cave Chasm Bridge \\"           }}
      options:fire(terrain_list)
   elseif name == "Special" then
      local terrain_list = {
         {"^Vov",   "Village Overlay"                },
         {"^Cov",   "Castle Overlay"                 },
         {"^Kov",   "Keep Overlay"                   }}
      options:fire(terrain_list)
   end
end

function submenu_terrain_choose(name)
   local options = DungeonOpt:new{
      root_message   = "Which terrain would you like to switch to?",
      option_message = "$input2",
      code           = "terrain.set_terrain('$input1')"
   }
   if name == "Repeat last terrain" then
      terrain.set_terrain(terrain.last_terrain)
   elseif name == "Change radius" then
      local new_radius = menu(terrain.possible_radius, "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "What do you want to set the terrain radius as?", menu_simple_list)
      if new_radius then
         terrain.radius = new_radius
      end
   elseif name == "Set an overlay" then
      local options_overlay = {"Repeat last overlay", "Water", "Desert", "Embellishments", "Forest", "Frozen", "Rough", "Cave", "Village", "Bridge", "Special", "Remove overlay"}
      local overlay = menu(options_overlay, "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "Which terrain would you like to switch to?", menu_simple_list)
      if overlay then
         submenu_overlay_options(overlay)
      end
   elseif name == "Water" then
      local terrain_list = {
         {"Wog",    "Grey Deep Water"        },
         {"Wo",     "Medium Deep Water"      },
         {"Wot",    "Tropical Deep Water"    },
         {"Wwg",    "Gray Shallow Water"     },
         {"Ww",     "Medium Shallow Water"   },
         {"Wwt",    "Tropical Shallow Water" },
         {"Wwf",    "Ford"                   },
         {"Wwr",    "Coastal Reef"           },
         {"Ss",     "Swamp"                  },
         {"Sm",     "Muddy Quagmire"         },
         {"Chw",    "Sunken Human Ruin"      },
         {"Chs",    "Swamp Humain Ruin"      },
         {"Khw",    "Sunken Human Keep"      },
         {"Khs",    "Swamp Human Keep"       }}
      options:fire(terrain_list)
   elseif name == "Flat" then
      local terrain_list = {
         {"Gg",     "Green Grass"            },
         {"Gs",     "Semi-dry Grass"         },
         {"Gd",     "Dry Grass"              },
         {"Gll",    "Leaf Litter"            },
         {"Rb",     "Dark Dirt"              },
         {"Re",     "Regular Dirt"           },
         {"Rd",     "Dry Dirt"               },
         {"Rr",     "Regular Cobbles"        },
         {"Rrc",    "Clean Grey Cobbles"     },
         {"Rp",     "Overgrown Cobbles"      },
         {"Iwr",    "Basic Wooden Floor"     }}
      options:fire(terrain_list)
   elseif name == "Desert" then
      local terrain_list = {
         {"Rd",     "Dry Dirt"               },
         {"Dd",     "Desert Sands"           },
         {"Ds",     "Beach Sands"            },
         {"Dd^Dc",  "Crater"                 },
         {"Hd",     "Dunes"                  },
         {"Md",     "Dry Mountains"          },
         {"Md^Xm",  "Desert Impassables"     },
         {"Cd",     "Desert Castle"          },
         {"Kd",     "Desert Keep"            }}
      options:fire(terrain_list)
   elseif name == "Frozen" then
      local terrain_list = {
         {"Ai",      "Ice"                            },
         {"Aa",      "Snow"                           },
         {"Ha",      "Snow Hills"                     },
         {"Ms",      "Snowy Mountains"                },
         {"Ms^Xm",   "Snowy Impassable Mountains"     },
         {"Cea",     "Snowy Encampment"               },
         {"Coa",     "Snowy Orcish Castle"            },
         {"Cha",     "Snowy Human Castle"             },
         {"Kea",     "Snowy Encampment Keep"          },
         {"Koa",     "Snowy Orcish Keep"              },
         {"Kha",     "Snowy Human Castle Keep"        }}
      options:fire(terrain_list)
   elseif name == "Rough" then
      local terrain_list = {
         {"Hh",       "Regular Hills"                  },
         {"Hhd",      "Dry Hills"                      },
         {"Hd",       "Dunes"                          },
         {"Ha",       "Snow Hills"                     },
         {"Mm",       "Regulary Mountains"             },
         {"Md",       "Dry Mountains"                  },
         {"Ms",       "Snowy Mountains"                },
         {"Uh",       "Rockbound Cave"                 },
         {"Mv",       "Volcano"                        },
         {"Mm^Xm",    "Regular Impassable Mountains"   },
         {"Md^Xm",    "Desert Impassable Mountains"    },
         {"Ms^Xm",    "Snowy Impassable Mountains"     }}
      options:fire(terrain_list)
   elseif name == "Cave" then
      local terrain_list = {
         {"Uu",      "Cave Floor"                     },
         {"Uue",     "Earthy Cave Floor"              },
         {"Urb",     "Dark Flagstones"                },
         {"Ur",      "Cave Path"                      },
         {"Uh",      "Rockbound Cave"                 },
         {"Qxu",     "Regular Chasm"                  },
         {"Qxe",     "Earthy Chasm"                   },
         {"Qxua",    "Ethereal Abyss"                 },
         {"Ql",      "Lava Chasm"                     },
         {"Qlf",     "Lava"                           },
         {"Xu",      "Natural Cave Wall"              },
         {"Xuc",     "Hewn Cave Wall"                 },
         {"Xue",     "Natural Earthy Cave Wall"       },
         {"Xuce",    "Reinforced Earthy Cave Wall"    },
         {"Xos",     "Stone Wall"                     },
         {"Xol",     "Lit Stone Wall"                 },
         {"Cud",     "Dwarven Castle"                 },
         {"Kud",     "Dwarven Castle Keep"            }}
      options:fire(terrain_list)
   elseif name == "Obstacle" then
      local terrain_list = {
         {"Qxu",     "Regular Chasm"                  },
         {"Qxe",     "Earthy Chasm"                   },
         {"Qxua",    "Ethereal Abyss"                 },
         {"Ql",      "Lava Chasm"                     },
         {"Qlf",     "Lava"                           },
         {"Mv",      "Volcano"                        },
         {"Mm^Xm",   "Regular Impassable Mountains"   },
         {"Md^Xm",   "Desert Impassable Mountains"    },
         {"Ms^Xm",   "Snowy Impassable Mountains"     },
         {"Xu",      "Natural Cave Wall"              },
         {"Xuc",     "Hewn Cave Wall"                 },
         {"Xue",     "Natural Earthy Cave Wall"       },
         {"Xuce",    "Reinforced Earthy Cave Wall"    },
         {"Xos",     "Stone Wall"                     },
         {"Xol",     "Lit Stone Wall"                 }}
      options:fire(terrain_list)
   elseif name == "Castle" then
      local terrain_list = {
         {"Ce",      "Encampment"                     },
         {"Cea",     "Snowy Encampment"               },
         {"Co",      "Orcish Castle"                  },
         {"Coa",     "Snowy Orcish Castle"            },
         {"Ch",      "Human Castle"                   },
         {"Cha",     "Snowy Human Castle"             },
         {"Cv",      "Elven Castle"                   },
         {"Cud",     "Dwarven Castle"                 },
         {"Chr",     "Ruined Human Castle"            },
         {"Chw",     "Sunken Human Ruin"              },
         {"Chs",     "Swamp Human Ruin"               },
         {"Cd",      "Desert Castle"                  },
         {"Ke",      "Encampment Keep"                },
         {"Kea",     "Snowy Encampment Keep"          },
         {"Ko",      "Orcish Keep"                    },
         {"Koa",     "Snowy Orcish Keep"              },
         {"Kh",      "Human Castle Keep"              },
         {"Kha",     "Snowy Human Castle Keep"        },
         {"Kv",      "Elven Castle Keep"              },
         {"Kud",     "Dwarven Castle Keep"            },
         {"Khr",     "Ruined Human Castle Keep"       },
         {"Khw",     "Sunken Human Castle Keep"       },
         {"Khs",     "Swamp Human Castle Keep"        },
         {"Kd",      "Desert Keep"                    }}
      options:fire(terrain_list)
   elseif name == "Special" then
      local terrain_list = {
         {"Xv",      "Void"                           }}
      options:fire(terrain_list)
   end
end
>>
#enddef
