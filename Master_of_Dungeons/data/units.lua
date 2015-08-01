#define MOD_DATA_UNITS
<<
SIDES = {1, 2, 3, 4, 5, 6, 7, 8}

SUMMON_ROLES = {"Undead", "Nature", "Elves", "Fire", "Loyalists", "Outlaws",
                "Orcs", "Dwarves", "Earth", "Swamp", "Water"}

PORTRAIT = {
   Undead    = "portraits/undead/transparent/spectre.png",
   Nature    = "portraits/elves/transparent/shyde.png",
   Elves     = "portraits/elves/transparent/lord.png",
   Fire      = "portraits/humans/transparent/mage-red.png",
   Loyalists = "portraits/humans/transparent/marshal.png",
   Outlaws   = "portraits/humans/transparent/assassin.png",
   Orcs      = "portraits/orcs/transparent/warlord.png",
   Dwarves   = "portraits/dwarves/transparent/lord.png",
   Earth     = "portraits/trolls/transparent/troll.png",
   Swamp     = "portraits/saurians/transparent/augur.png",
   Water     = "portraits/merfolk/transparent/priestess.png",
}

summoners = {
   Undead = {
      "Dark Adept",
      "Dark Sorcerer",
      "Necromancer",
      "Lich",
      "Ancient Lich",
   },

   Nature = {
      "Elvish Shaman",
      "Elvish Druid",
      "Elvish Shyde",
      "Elvish Sorceress",
      "Elvish Enchantress",
      "Elvish Sylph",
   },

   Elves = {
      "Elvish Lord",
      "Elvish High Lord",
   },

   Fire = {
      "Mage",
      "Red Mage",
      "Silver Mage",
      "Arch Mage",
      "Great Mage",
      "Elder Mage",
   },

   Loyalists = {
      "White Mage",
      "Mage of Light",
      "Sergeant",
      "Lieutenant",
      "General",
      "Grand Marshal",
   },

   Outlaws = {
      "Poacher",
      "Trapper",
      "Huntsman",
      "Ranger",
   },

   Orcs = {
      "Orcish Leader",
      "Orcish Ruler",
      "Orcish Sovereign",
   },

   Dwarves = {
      "Dwarvish Fighter",
      "Dwarvish Steelclad",
      "Dwarvish Lord",
   },

   Earth = {
      "Troll Shaman",
      "Dwarvish Runesmith",
      "Dwarvish Runemaster",
      "Dwarvish Arcanister",
   },

   Swamp = {
      "Saurian Augur",
      "Saurian Oracle",
      "Saurian Soothsayer",
   },

   Water = {
      "Mermaid Initiate",
      "Mermaid Enchantress",
      "Mermaid Siren",
      "Mermaid Priestess",
      "Mermaid Diviner",
   },
}

regular = {
   Undead = {
      ['Level 0'] = {
         "Walking Corpse",
         "Vampire Bat",
      },

      ['Level 1'] = {
         "Soulless",
         "Skeleton Archer",
         "Skeleton",
         "Ghoul",
         "Ghost",
         "Blood Bat",
      },

      ['Level 2'] = {
         "Bone Shooter",
         "Necrophage",
         "Deathblade",
         "Revenant",
         "Dread Bat",
         "Chocobone",
         "Shadow",
         "Wraith",
      },

      ['Level 3'] = {
         "Banebow",
         "Ghast",
         "Death Knight",
         "Draug",
         "Nightgaunt",
         "Spectre",
      },

      ['Level 4'] = {
         "Skeletal Dragon",
      },
   },

   Nature = {
      ['Level 0'] = {
         "Falcon",
         "Mudcrawler",
         "Giant Rat",
      },

      ['Level 1'] = {
         "Elder Falcon",
         "Giant Mudcrawler",
         "Giant Scorpion",
         "Young Ogre",
         "Wolf",
         "Wose",
      },

      ['Level 2'] = {
         "Elder Wose",
         "Ogre",
         "Great Wolf",
         "Gryphon",
      },

      ['Level 3'] = {
         "Ancient Wose",
         "Direwolf",
         "Giant Spider",
      },
   },

   Elves = {
      ['Level 1'] = {
         "Elvish Fighter",
         "Elvish Archer",
         "Elvish Scout",
      },

      ['Level 2'] = {
         "Elvish Rider",
         "Elvish Captain",
         "Elvish Hero",
         "Elvish Marksman",
         "Elvish Ranger",
      },

      ['Level 3'] = {
         "Elvish Outrider",
         "Elvish Champion",
         "Elvish Marshal",
         "Elvish Sharpshooter",
         "Elvish Avenger",
         "Elvish Lady",
      },
   },

   Fire = {
      ['Level 1'] = {
         "Drake Glider",
         "Drake Fighter",
         "Drake Clasher",
         "Fire Guardian",
         "Drake Burner",
      },

      ['Level 2'] = {
         "Sky Drake",
         "Drake Warrior",
         "Drake Arbiter",
         "Drake Thrasher",
         "Drake Flare",
         "Fire Drake",
      },

      ['Level 3'] = {
         "Drake Flameheart",
         "Inferno Drake",
         "Drake Warden",
         "Drake Enforcer",
         "Drake Blademaster",
         "Hurricane Drake",
      },

      ['Level 4'] ={
         "Armageddon Drake",
      },

      ['Level 5'] = {
         "Fire Dragon",
      },
   },

   Loyalists = {
      ['Level 0'] = {
         "Peasant",
         "Woodsman",
      },

      ['Level 1'] = {
         "Bowman",
         "Spearman",
         "Fencer",
         "Cavalryman",
         "Heavy Infantryman",
         "Horseman",
      },

      ['Level 2'] = {
         "Javelineer",
         "Pikeman",
         "Swordsman",
         "Longbowman",
         "Duelist",
         "Dragoon",
         "Shock Trooper",
         "Knight",
         "Lancer",
      },

      ['Level 3'] = {
         "Royal Guard",
         "Royal Warrior",
         "Halberdier",
         "Master at Arms",
         "Master Bowman",
         "Iron Mauler",
         "Cavalier",
         "Grand Knight",
         "Paladin",
      },
   },

   Outlaws = {
      ['Level 0'] = {
         "Ruffian",
         "Woodsman",
      },

      ['Level 1'] = {
         "Thief",
         "Thug",
         "Footpad",
      },

      ['Level 2'] = {
         "Bandit",
         "Rogue",
         "Outlaw",
      },

      ['Level 3'] = {
         "Assassin",
         "Highwayman",
         "Fugitive",
      },
   },

   Orcs = {
      ['Level 0'] = {
         "Goblin Spearman",
      },

      ['Level 1'] = {
         "Orcish Grunt",
         "Goblin Impaler",
         "Goblin Rouser",
         "Orcish Archer",
         "Orcish Assassin",
         "Wolf Rider",
      },

      ['Level 2'] = {
         "Orcish Crossbowman",
         "Orcish Warrior",
         "Goblin Pillager",
         "Goblin Knight",
         "Orcish Slayer",
      },

      ['Level 3'] = {
         "Direwolf Rider",
         "Orcish Slurbow",
         "Orcish Warlord",
      },
   },

   Dwarves = {
      ['Level 1'] = {
         "Dwarvish Thunderer",
         "Dwarvish Scout",
         "Dwarvish Guardsman",
         "Dwarvish Ulfserker",
         "Gryphon Rider",
      },

      ['Level 2'] = {
         "Dwarvish Pathfinder",
         "Dwarvish Thunderguard",
         "Dwarvish Stalwart",
         "Dwarvish Berserker",
         "Gryphon Master",
      },

      ['Level 3'] = {
         "Dwarvish Sentinel",
         "Dwarvish Explorer",
         "Dwarvish Dragonguard",
      },
   },

   Earth = {
      ['Level 0'] = {
         "Mudcrawler",
      },

      ['Level 1'] = {
         "Giant Mudcrawler",
         "Troll Whelp",
      },

      ['Level 2'] = {
         "Troll",
         "Troll Rocklobber",
         "Troll Hero",
      },

      ['Level 3'] = {
         "Troll Warrior",
         "Great Troll",
         "Giant Spider",
      },

      ['Level 4'] ={
         "Yeti",
      },
   },

   Swamp = {
      ['Level 0'] = {
         "Mudcrawler",
      },

      ['Level 1'] = {
         "Giant Mudcrawler",
         "Naga Fighter",
         "Saurian Skirmisher",
      },

      ['Level 2'] = {
         "Naga Warrior",
         "Saurian Ambusher",
      },

      ['Level 3'] = {
         "Naga Myrmidon",
         "Saurian Flanker",
      },
   },

   Water = {
      ['Level 1'] = {
         "Tentacle of the Deep",
         "Merman Fighter",
         "Merman Hunter",
      },

      ['Level 2'] = {
         "Merman Warrior",
         "Merman Netcaster",
         "Merman Spearman",
         "Water Serpent",
         "Cuttle Fish",
      },

      ['Level 3'] = {
         "Merman Hoplite",
         "Merman Triton",
         "Merman Entangler",
         "Merman Javelineer",
         "Sea Serpent",
      },
   },
}
>>
#enddef
