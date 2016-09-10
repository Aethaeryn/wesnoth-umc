Aethaeryn's Mod
===============

About
-----

This is both a multiplayer campaign and an RPG framework. The host is
supposed to play as side 1 and side 9, and every other side can be
another player. This means that the minimum number of players is 2,
since one player can control sides 2-8 or you can set sides 3-8 as
empty and just have one player control side 2. Obviously, it's more
fun the more players play, though.

Currently, no download is required to play this game. All of the Lua
code is loaded in as WML macros, treating the code as literal strings
so that people who don't have the add-on installed can download the
Lua when they join the game.

This game is currently not complete. To see what's missing, read the
todo file. A lot of the documentation is currently lacking, and a lot
of things that could be trivially translated are currently not
translated.

Basic Gameplay
--------------

The players pick characters, then the host picks a map, and spawns
units on those maps to generate an ad hoc RPG as the game goes
on. Good hosts will spawn just enough enemy units to be challenging,
but not more than the other players can handle. The hosts have a lot
of powers beyond just spawning hostile units (side 1). They can also
spawn friendly units (side 9) and change around the map, including by
placing containers/shops and changing the terrain itself. Think of it
as debug mode combined with a real-time map editor accessible through
MP. The only real downside is that the UI limitations make the map
editing slow and inconvenient, which is why there are predawn maps.

The players themselves have access to the standard mechanics of
Wesnoth RPG add-ons: inventory, upgrades, money for shops, etc. The
main difference (besides the powerful host) is that the main map is
both huge and open-ended, so no two games will play the
same. Originally, this add-on was intended to be played as an MP
campaign. Increasingly, the focus is on one very large map,
temporarily called "Woods".

Death of the player character isn't even necessarily the end, since
the host has the power to spawn in a new unit and then give it to a
player-controlled side. Resurrection of dead characters will be
possible soon, but it is not yet implemented. This presents an
interesting and unintended additional gameplay mechanic. If someone
dies, and then disconnects, the side can be "recycled" and given to an
observer, who then can receive a fresh unit. This means that the 9
side limitation of the Wesnoth engine does not translate to a 9 player
limitation (or 8, since sides 1 and 9 are intended to share the same
player), but instead only presents a *simultaneous* player
limitation. This adds to the potential for these games to be endless.
