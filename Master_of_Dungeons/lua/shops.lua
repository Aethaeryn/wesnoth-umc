function create_shop(x, y)
   local shop = DungeonShop:new{item_table = inventory.item_table}
   shop:place(x, y)
end

function shops()
   local options = DungeonOpt:new{
      menu_id        = "070_Manage_Shops",
      menu_desc      = "Manage Shops",
      menu_image     = "misc/vision-fog-shroud.png", -- replace

      root_message   = "What would you like to do?", -- replace
      option_message = "$input1",
      code           = "option_terrain_choose('$input1')", -- replace
   }

   options:menu({
                   {"Place a Shop"},
                },
                filter_host("long")
             )
end
