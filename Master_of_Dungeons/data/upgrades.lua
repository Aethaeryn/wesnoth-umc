#define MOD_DATA_UPGRADES
<<
-- Name:   A unique string that identifies what it is called.
-- Image:  Anything from icons/ or attacks/ should work.
-- Msg:    What the user sees when browsing their inventory; explain the effect.
-- Cost:   How many improvement points it costs.
-- Cap:    How many of these upgrades you can have.
-- Effect: The actual code for running the item.
upgrade_table = {
    {
       name   = "Speed",
       image  = "icons/boots_elven.png",
       msg    = "+1 maximum MP",
       cost   = 3,
       cap    = 2,
       effect = "",
    },
    {
       name   = "Resilience",
       image  = "attacks/fire-blast.png",
       msg    = "+4 maximum HP",
       cost   = 1,
       cap    = false,
       effect = "",
    },
    {
       name   = "Strength",
       image  = "attacks/fist-human.png",
       msg    = "+1 melee damage",
       cost   = 2,
       cap    = false,
       effect = "",
    },
    {
       name   = "Dexterity",
       image  = "attacks/bow-elven-magic.png",
       msg    = "+1 range damage",
       cost   = 2,
       cap    = false,
       effect = "",
    },
    {
       name   = "Intelligence",
       image  = "attacks/faerie-fire.png",
       msg    = "-20%% XP to next promotion",
       cost   = 2,
       cap    = 2,
       effect = "",
    },
}

>>
#enddef
