#define MOD_LUA_TERRAIN_EDITOR
<<
options_overlay = {"Water", "Desert", "Embellishments", "Forest", "Frozen", "Rough", "Cave", "Village", "Bridge", "Special", "Remove overlay"}

options_radius = {0, 1, 2}

function terrain_set(terrain_symbol)
   -- Creates a global variable that is remembered for terrain_repeat()
   last_terrain = terrain_symbol

   for i, terrain in ipairs(change_terrain) do
      wesnoth.set_terrain(terrain[1], terrain[2], terrain_symbol)
   end
end

function overlay_set(terrain_symbol)
   for i, terrain in ipairs(change_terrain) do
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

function option_overlay_options(name)
   local options = DungeonOpt:new{
      root_message   = "Which overlay would you like to place?",
      option_message = "$input2",
      code           = "overlay_set('$input1')"
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

function option_terrain_choose(name)
   local options = DungeonOpt:new{
      root_message   = "Which terrain would you like to switch to?",
      option_message = "$input2",
      code           = "terrain_set('$input1')"
   }
   if name == "Repeat last terrain" then
      terrain_set(last_terrain)

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
         {"Hh^Fp",   "Forested Hills"                 },
         {"Ha^Fpa",  "Forested Snow Hills"            },
         {"Hh^Fds",  "Summer Deciduous Forested Hills"},
         {"Hhd^Fdf", "Fall Deciduous Forested Hills"  },
         {"Hhd^Fdw", "Winter Deciduous Forested Hills"},
         {"Ha^Fda",  "Snowy Deciduous Forested Hills" },
         {"Hh^Fms",  "Summer Mixed Forested Hills"    },
         {"Hhd^Fmf", "Fall Mixed Forested Hills"      },
         {"Hhd^Fmw", "Winter Mixed Forested Hills"    },
         {"Ha^Fma",  "Snowy Mixed Forested Hills"     },
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
         {"Hh^Fpa",  "Forested Snow Hills"            },
         {"Ha^Fda",  "Snowy Deciduous Forested Hills" },
         {"Ha^Fma",  "Snowy Mixed Forested Hills"     },
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
         {"Mm",       "Mountains"                      },
         {"Md",       "Dry Mountains"                  },
         {"Ms",       "Snowy Mountains"                },
         {"Hh^Fp",    "Forested Hills"                 },
         {"Ha^Fpa",   "Forested Snow Hills"            },
         {"Hh^Fds",   "Summer Deciduous Forested Hills"},
         {"Hhd^Fdf",  "Fall Deciduous Forested Hills"  },
         {"Hhd^Fdw",  "Winter Deciduous Forested Hills"},
         {"Ha^Fda",   "Snowy Deciduous Forested Hills" },
         {"Hh^Fms",   "Summer Mixed Forested Hills"    },
         {"Hhd^Fmf",  "Fall Mixed Forested Hills"      },
         {"Hhd^Fmw",  "Winter Mixed Forested Hills"    },
         {"Ha^Fma",   "Snowy Mixed Forested Hills"     },
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

   elseif name == "Set an overlay" then
      options_list_short("Which terrain would you like to switch to?",
                         "option_overlay_options('$input1')",
                         options_overlay)

   elseif name == "Change radius" then
      options_list_short("What do you want to set the terrain radius as?",
                         "terrain_radius = $input1",
                         options_radius)
   end
end

-- A separate function is necessary because if it is kept in the code string of menu_item_change_terrain,
-- the terrain_radius will never change.
function change_terrain_generate()
   local args = wesnoth.current.event_context

   change_terrain = wesnoth.get_locations{
      x = args.x1,
      y = args.y1,
      radius = terrain_radius
   }
end

function menu_item_change_terrain()
   local options = DungeonOpt:new{
      menu_id        = "050_Change_Terrain",
      menu_desc      = "Change Terrain",
      menu_image     = "misc/vision-fog-shroud.png",

      root_message   = "Which terrain would you like to switch to?",
      option_message = "$input1",
      code           = "option_terrain_choose('$input1')",
   }

   if last_terrain == nil then
      last_terrain = "Ur"
   end

   options:menu({
                   {"Repeat last terrain"},
                   {"Water"},
                   {"Flat"},
                   {"Desert"},
                   {"Forest"},
                   {"Frozen"},
                   {"Rough"},
                   {"Cave"},
                   {"Obstacle"},
                   {"Village"},
                   {"Castle"},
                   {"Special"},
                   {"Set an overlay"},
                   {"Change radius"}
                },
                filter_host("editor"),
                "change_terrain_generate()"
             )
end

function terrain_editor()
   terrain_radius = 0

   menu_item_change_terrain()
end
>>
#enddef
