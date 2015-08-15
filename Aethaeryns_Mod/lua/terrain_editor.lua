#define MOD_LUA_TERRAIN_EDITOR
<<
terrain = {}
terrain.last_terrain = "Ur"
terrain.last_overlay = "^Vh"
terrain.radius = 0
terrain.possible_radius = {0, 1, 2}
terrain.terrain = {
   Water = {"Wog", "Wo", "Wot", "Wwg", "Ww", "Wwt", "Wwf", "Wwrg", "Wwr", "Wwrt", "Ss", "Sm", "Chw", "Chs", "Khw", "Khs"},
   Flat = {"Gg", "Gs", "Gd", "Gll", "Rb", "Re", "Rd", "Rr", "Rrc", "Rp", "Iwr", "Urb", "Ur"},
   Desert = {"Rd", "Dd", "Ds", "Dd^Dc", "Hd", "Md", "Md^Xm", "Cd", "Cdr", "Kd", "Kdr"},
   Fall = {"Gll", "Hhd"},
   Frozen = {"Ai", "Aa", "Ha", "Ms", "Ms^Xm", "Cea", "Coa", "Cha", "Kea", "Koa", "Kha"},
   Rough = {"Hh", "Hhd", "Hd", "Ha", "Mm", "Md", "Ms", "Uh", "Mv", "Mm^Xm", "Md^Xm", "Ms^Xm"},
   Cave = {"Uu", "Uue", "Urb", "Ur", "Uh", "Qxu", "Qxe", "Qxua", "Ql", "Qlf", "Xu", "Xuc", "Xue", "Xuce", "Xos", "Xol", "Cud", "Kud"},
   Obstacle = {"Qxu", "Qxe", "Qxua", "Ql", "Qlf", "Mv", "Mm^Xm", "Md^Xm", "Ms^Xm", "Xu", "Xuc", "Xue", "Xuce", "Xos", "Xol", "_off^_usr"},
   Castle = {"Ce", "Cea", "Co", "Coa", "Ch", "Cha", "Cv", "Cud", "Chr", "Chw", "Chs", "Cd", "Cdr", "Ke", "Ket", "Kea", "Ko", "Koa", "Kh", "Kha", "Kv", "Kud", "Khr", "Khw", "Khs", "Kd", "Kdr"},
   Special = {"Xv"}}
terrain.overlays = {
   Water = {"^Vhs", "^Vm", "^Ewl", "^Ewf", "^Bw|", "^Bw/", "^Bw\\", "^Bw|r", "^Bw/r", "^Bw\\r", "^Bsb|", "^Bsb/", "^Bsb\\"},
   Desert = {"^Do", "^Dr", "^Edp", "^Edpp", "^Esd", "^Ftd", "^Fts", "^Vda", "^Vdt"},
   Embellishments = {"^Efm", "^Gvs", "^Es", "^Em", "^Emf", "^Edp", "^Edpp", "^Wm", "^Ecf", "^Eff", "^Esd", "^Ewl", "^Ewf", "^Edt", "^Edb"},
   Forest = {"^Do", "^Fet", "^Fetd", "^Ft", "^Ftr", "^Ftd", "^Ftp", "^Fts", "^Fp", "^Fpa", "^Fds", "^Fdf", "^Fdw", "^Fda", "^Fms", "^Fmf", "^Fmw", "^Fma", "^Uf"},
   Fall = {"^Fdf", "^Fdw", "^Fmf", "^Fmw"},
   Frozen = {"^Fpa", "^Fda", "^Fma", "^Voa", "^Vea", "^Vha", "^Vhca", "^Vhha", "^Vca", "^Vla", "^Vaa"},
   Rough = {"^Dr", "^Vhh", "^Vhha", "^Vhhr"},
   Cave = {"^Emf", "^Ii", "^Uf", "^Ufi", "^Br|", "^Br/", "^Br\\", "^Vu", "^Vud", "^Bs|", "^Bs/", "^Bs\\", "^Bh\\", "^Bh/", "^Bh|", "^Bcx\\", "^Bcx/", "^Bp\\", "^Bp/", "^Bp|"},
   Obstacle = {"^Xo", "^Qov"},
   Village = {"^Vda", "^Vdt", "^Vct", "^Vo", "^Voa", "^Vea", "^Ve", "^Vh", "^Vha", "^Vhr", "^Vhc", "^Vwm", "^Vhca", "^Vhcr", "^Vhh", "^Vhha", "^Vhhr", "^Vht", "^Vd", "^Vu", "^Vud", "^Vc", "^Vca", "^Vl", "^Vla", "^Vaa", "^Vhs", "^Vm", "^Vov"},
   Castle = {"^Cov", "^Kov"},
   Bridge = {"^Bw|", "^Bw/", "^Bw\\", "^Bsb|", "^Bsb/", "^Bsb\\", "^Bs|", "^Bs/", "^Bs\\"},
   Special = {"^Vov", "^Cov", "^Kov"}}
terrain.options = {
   "Repeat last terrain",
   "Set an overlay",
   "Change radius",
   "Water",
   "Flat",
   "Desert",
   "Fall",
   "Frozen",
   "Rough",
   "Cave",
   "Obstacle",
   "Castle",
   "Special"}
terrain.overlay_options = {
   "Repeat last overlay",
   "Water",
   "Desert",
   "Embellishments",
   "Forest",
   "Frozen",
   "Rough",
   "Cave",
   "Obstacle",
   "Village",
   "Bridge",
   "Special",
   "Remove overlay"}

function terrain.set_terrain(terrain_symbol)
   terrain.last_terrain = terrain_symbol
   for i, hex in ipairs(terrain.change_hexes) do
      wesnoth.set_terrain(hex[1], hex[2], terrain_symbol)
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
>>
#enddef
