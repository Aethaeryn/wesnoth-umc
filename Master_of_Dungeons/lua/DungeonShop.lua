#define MOD_LUA_DUNGEONSHOP
<<

DungeonShop = {
   item_table = { "Run DungeonInventory first, and import from inventory.item_table" }
}

function DungeonShop:place (x, y)
   -- create image, place it on that location, then create a trigger event for when player moves there.
end

function DungeonShop:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

>>
#enddef