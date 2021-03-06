#define MOD_DATA_INVENTORY
<<
-- Name:   A unique string that identifies what it is called.
-- Image:  Anything from icons/ or attacks/ should work.
-- Msg:    What the user sees when browsing their inventory; explain the effect.
-- Price:  The default buy-from and sell-to price in shops (when price is undefined or when they don't stock it.)
-- Effect: The actual code for running the item.
item_table = {
   {
      name   = "Small Healing Potion",
      image  = "icons/potion_red_small.png",
      msg    = "* Heals unit by 6 HP.",
      price  = 20,
   }, {
      name   = "Healing Potion",
      image  = "icons/potion_red_medium.png",
      msg    = "* Heals unit by 14 HP.",
      price  = 45,
   }, {
      name   = "Small Haste Potion",
      image  = "icons/potion_green_small.png",
      msg    = "* Gives the haste ability for 2 turns.",
      price  = 30,
   }, {
      name   = "Haste Potion",
      image  = "icons/potion_green_medium.png",
      msg    = "* Gives the haste ability for 4 turns.",
      price  = 55,
   }, {
      name   = "Ale",
      image  = "icons/letter_and_ale.png",
      msg    = "* Raises maximum HP by 5 for 3 turns.\n* 1/4 chance to get drunk (berserk melee).",
      price  = 25,
   }, {
      name   = "Scroll",
      image  = "icons/scroll_red.png",
      msg    = "* Allows for the casting of a spell.",
      price  = 100,
   }, {
      name   = "Scroll (Teleportation)",
      image  = "icons/scroll_red.png",
      msg    = "* Lets the user teleport to a teleporter.",
      price  = 25,
   }, {
      name   = "Coins",
      image  = "icons/coins_copper.png",
      msg    = "* Adds ten coins to the side total.",
      price  = 10,
   },
}

>>
#enddef
