#define MOD_LUA_TERRAIN_EDITOR
<<
-- If/then is currently needed so variables persist past side turns.
if terrain == nil then
   terrain = {}
   terrain.last_terrain = "Ur"
   terrain.radius = 0
   terrain.possible_radius = {0, 1, 2}
end

function terrain.set_terrain(terrain_symbol)
   terrain.last_terrain = terrain_symbol
   for i, terrain in ipairs(terrain.change_hexes) do
      wesnoth.set_terrain(terrain[1], terrain[2], terrain_symbol)
   end
end

function terrain.set_overlay(terrain_symbol)
   for i, terrain in ipairs(terrain.change_hexes) do
      local terrain_type = wesnoth.get_terrain(terrain[1], terrain[2])
      if string.find(terrain_type, "%^") == nil then
         local terrain_symbol = terrain_type..terrain_symbol
         wesnoth.set_terrain(terrain[1], terrain[2], terrain_symbol)
      else
         char = string.find(terrain_type, "%^")
         local terrain_symbol = string.sub(terrain_type, 1, char - 1)..terrain_symbol
         wesnoth.set_terrain(terrain[1], terrain[2], terrain_symbol)
      end
   end
end

function submenu_overlay_options(name)
   local options = DungeonOpt:new{
      root_message   = "Which overlay would you like to place?",
      option_message = "$input2",
      code           = "terrain.set_overlay('$input1')"
   }

   if name == "Water" then
      options:fire{
         {"^Vhs",   "Swamp Village"                  },
         {"^Vm",    "Shallow Merfolk Village"        },
         {"^Vm",    "Swamp Merfolk Village"          },
         {"^Bw|",   "Wood Bridge |"                  },
         {"^Bw/",   "Wood Bridge /"                  },
         {"^Bw\\",  "Wood Bridge \\"                 },
         {"^Bsb|",  "Basic Stone Bridge |"           },
         {"^Bsb/",  "Basic Stone Bridge /"           },
         {"^Bsb\\", "Basic Stone Bridge \\"          }
      }
   elseif name == "Desert" then
      options:fire{
         {"^Dr",    "Rubble"                         },
         {"^Edp",   "Desert Plants"                  },
         {"^Edpp",  "Desert Plants w/o Bones"        },
         {"^Vda",   "Adobe Village"                  },
         {"^Vdt",   "Desert Tent Village"            }
      }
   elseif name == "Embellishments" then
      options:fire{
         {"^Efm",   "Mixed Flowers"                  },
         {"^Gvs",   "Farmland"                       },
         {"^Es",    "Stones"                         },
         {"^Em",    "Small Mushrooms"                },
         {"^Emf",   "Mushroom Farm"                  },
         {"^Edp",   "Desert Plants"                  },
         {"^Edpp",  "Desert Plants w/o Bones"        },
         {"^Wm",    "Windmill"                       },
         {"^Eff",   "Fence"                          }
      }
   elseif name == "Forest" then
      options:fire{
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
         {"^Uf",    "Mushroom Grove"                 }
      }
   elseif name == "Frozen" then
      options:fire{
         {"^Fpa",   "Snowy Pine Forest"              },
         {"^Fda",   "Snowy Deciduous Forest"         },
         {"^Fma",   "Snowy Mixed Forest"             },
         {"^Voa",   "Snowy Orcish Village"           },
         {"^Vea",   "Snowy Elven Village"            },
         {"^Vha",   "Snowy Cottage"                  },
         {"^Vhha",  "Snowy Hill Stone Village"       },
         {"^Vca",   "Snowy Hut"                      },
         {"^Vla",   "Snowy Log Cabin"                },
      }
   elseif name == "Rough" then
      options:fire{
         {"^Dr",    "Rubble"                         },
         {"^Vhh",   "Hill Stone Village"             },
         {"^Vhha",  "Snowy Hill Stone Village"       },
         {"^Vhhr",  "Ruined Hill Stone Village"      }
      }
   elseif name == "Cave" then
      options:fire{
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
         {"^Bs\\",  "Cave Chasm Bridge \\"           }
      }
   elseif name == "Village" then
      options:fire{
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
         {"^Vm",    "Swamp Merfolk Village"          }
      }
   elseif name == "Bridge" then
      options:fire{
         {"^Bw|",   "Wood Bridge |"                  },
         {"^Bw/",   "Wood Bridge /"                  },
         {"^Bw\\",  "Wood Bridge \\"                 },
         {"^Bsb|",  "Basic Stone Bridge |"           },
         {"^Bsb/",  "Basic Stone Bridge /"           },
         {"^Bsb\\", "Basic Stone Bridge \\"          },
         {"^Bs|",   "Cave Chasm Bridge |"            },
         {"^Bs/",   "Cave Chasm Bridge /"            },
         {"^Bs\\",  "Cave Chasm Bridge \\"           }
      }
   elseif name == "Special" then
      options:fire{
         {"^Vov",   "Village Overlay"                },
         {"^Cov",   "Castle Overlay"                 },
         {"^Kov",   "Keep Overlay"                   }
      }
   elseif name == "Remove overlay" then
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
      local options_overlay = {"Water", "Desert", "Embellishments", "Forest", "Frozen", "Rough", "Cave", "Village", "Bridge", "Special", "Remove overlay"}
      local overlay = menu(options_overlay, "portraits/undead/transparent/ancient-lich.png", "Terrain Editor", "Which terrain would you like to switch to?", menu_simple_list)
      if overlay then
         submenu_overlay_options(overlay)
      end
   elseif name == "Water" then
      options:fire{
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
         {"Ss^Vhs", "Swamp Village"          },
         {"Ww^Vm",  "Shallow Merfolk Village"},
         {"Ss^Vm",  "Swamp Merfolk Village"  },
         {"Chw",    "Sunken Human Ruin"      },
         {"Chs",    "Swamp Humain Ruin"      },
         {"Khw",    "Sunken Human Keep"      },
         {"Khs",    "Swamp Human Keep"       }
      }
   elseif name == "Flat" then
      options:fire{
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
         {"Iwr",    "Basic Wooden Floor"     }
      }
   elseif name == "Desert" then
      options:fire{
         {"Rd",     "Dry Dirt"               },
         {"Dd",     "Desert Sands"           },
         {"Ds",     "Beach Sands"            },
         {"Dd^Do",  "Oasis"                  },
         {"Dd^Dc",  "Crater"                 },
         {"Hd",     "Dunes"                  },
         {"Md",     "Dry Mountains"          },
         {"Md^Xm",  "Desert Impassables"     },
         {"Dd^Vda", "Adobe Village"          },
         {"Dd^Vdt", "Desert Tent Village"    },
         {"Cd",     "Desert Castle"          },
         {"Kd",     "Desert Keep"            }
      }
   elseif name == "Forest" then
      options:fire{
         {"Dd^Do",   "Oasis"                          },
         {"Gg^Fet",  "Great Tree"                     },
         {"Gs^Ft",   "Tropical Forest"                },
         {"Gll^Fp",  "Pine Forest"                    },
         {"Aa^Fpa",  "Snowy Pine Forest"              },
         {"Gs^Fds",  "Summer Deciduous Forest"        },
         {"Gd^Fdf",  "Fall Deciduous Forest"          },
         {"Gs^Fdw",  "Winter Deciduous Forest"        },
         {"Aa^Fda",  "Snowy Deciduous Forest"         },
         {"Gs^Fms",  "Summer Mixed Forest"            },
         {"Gll^Fmf", "Fall Mixed Forest"              },
         {"Gd^Fmw",  "Winter Mixed Forest"            },
         {"Aa^Fma",  "Snowy Mixed Forest"             },
         {"Uu^Uf",   "Mushroom Grove"                 }
      }
   elseif name == "Frozen" then
      options:fire{
         {"Ai",      "Ice"                            },
         {"Aa",      "Snow"                           },
         {"Aa^Fpa",  "Snowy Pine Forest"              },
         {"Aa^Fda",  "Snowy Deciduous Forest"         },
         {"Aa^Fma",  "Snowy Mixed Forest"             },
         {"Ha",      "Snow Hills"                     },
         {"Ms",      "Snowy Mountains"                },
         {"Ms^Xm",   "Snowy Impassable Mountains"     },
         {"Aa^Voa",  "Snowy Orcish Village"           },
         {"Aa^Vea",  "Snowy Elven Village"            },
         {"Aa^Vha",  "Snowy Cottage"                  },
         {"Ha^Vhha", "Snowy Hill Stone Village"       },
         {"Aa^Vca",  "Snowy Hut"                      },
         {"Aa^Vla",  "Snowy Log Cabin"                },
         {"Cea",     "Snowy Encampment"               },
         {"Coa",     "Snowy Orcish Castle"            },
         {"Cha",     "Snowy Human Castle"             },
         {"Kea",     "Snowy Encampment Keep"          },
         {"Koa",     "Snowy Orcish Keep"              },
         {"Kha",     "Snowy Human Castle Keep"        }
      }
   elseif name == "Rough" then
      options:fire{
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
         {"Ms^Xm",    "Snowy Impassable Mountains"     },
         {"Hh^Vhh",   "Hill Stone Village"             },
         {"Ha^Vhha",  "Snowy Hill Stone Village"       },
         {"Hhd^Vhhr", "Ruined Hill Stone Village"      }
      }
   elseif name == "Cave" then
      options:fire{
         {"Uu",      "Cave Floor"                     },
         {"Uue",     "Earthy Cave Floor"              },
         {"Urb",     "Dark Flagstones"                },
         {"Ur",      "Cave Path"                      },
         {"Uu^Uf",   "Mushroom Grove"                 },
         {"Uu^Ufi",  "Lit Mushroom Grove"             },
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
         {"Uu^Vu",   "Cave Village"                   },
         {"Uu^Vud",  "Dwarven Village"                },
         {"Cud",     "Dwarven Castle"                 },
         {"Kud",     "Dwarven Castle Keep"            }
      }
   elseif name == "Obstacle" then
      options:fire{
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
         {"Xol",     "Lit Stone Wall"                 }
      }
   elseif name == "Village" then
      options:fire{
         {"Dd^Vda",   "Adobe Village"                  },
         {"Dd^Vdt",   "Desert Tent Village"            },
         {"Re^Vct",   "Tent Village"                   },
         {"Gd^Vo",    "Orcish Village"                 },
         {"Aa^Voa",   "Snowy Orcish Village"           },
         {"Aa^Vea",   "Snowy Elven Village"            },
         {"Gg^Ve",    "Elven Village"                  },
         {"Gs^Vh",    "Cottage"                        },
         {"Aa^Vha",   "Snowy Cottage"                  },
         {"Gd^Vhr",   "Ruined Cottage"                 },
         {"Rr^Vhc",   "Human City"                     },
         {"Rrc^Vhca", "Snowy Human City"               },
         {"Rp^Vhcr",  "Ruined Human City"              },
         {"Hh^Vhh",   "Hill Stone Village"             },
         {"Ha^Vhh",   "Snowy Hill Stone Village"       },
         {"Hhd^Vhhr", "Ruined Hill Stone Village"      },
         {"Gs^Vht",   "Tropical Village"               },
         {"Rr^Vd",    "Drake Village"                  },
         {"Uu^Vu",    "Cave Village"                   },
         {"Uu^Vud",   "Dwarven Village"                },
         {"Gs^Vc",    "Hut"                            },
         {"Aa^Vca",   "Snowy Hut"                      },
         {"Gs^Vl",    "Log Cabin"                      },
         {"Aa^Vla",   "Snowy Log Cabin"                },
         {"Ss^Vhs",   "Swamp Village"                  },
         {"Ww^Vm",    "Shallow Merfolk Village"        },
         {"Ss^Vm",    "Swamp Merfolk Village"          }
      }
   elseif name == "Castle" then
      options:fire{
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
         {"Kd",      "Desert Keep"                    }
      }
   elseif name == "Special" then
      options:fire{
         {"Xv",      "Void"                           }
      }
   end
end

function menu_change_terrain()
   local e = wesnoth.current.event_context
   terrain.change_hexes = wesnoth.get_locations { x = e.x1, y = e.y1, radius = terrain.radius }
   local title = "Terrain Editor"
   local description = "Which terrain would you like to switch to?"
   local image = "portraits/undead/transparent/ancient-lich.png"
   local options = {"Repeat last terrain",
                    "Set an overlay",
                    "Change radius",
                    "Water",
                    "Flat",
                    "Desert",
                    "Forest",
                    "Frozen",
                    "Rough",
                    "Cave",
                    "Obstacle",
                    "Village",
                    "Castle",
                    "Special"}
   local choice = menu(options, image, title, description, menu_simple_list)
   if choice then
      submenu_terrain_choose(choice)
   end
end

>>
#enddef
