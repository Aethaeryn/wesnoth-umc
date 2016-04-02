wesnoth-umc
===========

About
-----

This is a collection of some of the user-made content (UMC) that I
have written for [The Battle for Wesnoth](https://wesnoth.org). Each
directory is or will eventually be on the add-on server as a separate
add-on, but they are kept in one repository here for convenience. The
add-ons are designed to run on both the latest stable version (1.12)
and the latest development version (1.13) of Wesnoth, with some code
that only runs on 1.13. None of them have been published for 1.12 or
1.13 yet because they are undergoing heavy rewrites.

Not every add-on of mine is currently here, but every add-on I have
worked on recently (since 2015) is. Ones that rely on large amounts of
binary data (e.g. sprites) will probably need a different solution
than this, such as using separate git submodules for the images so the
downloads aren't huge if you only want to download one of the
text-only add-ons.

There are three kinds of content in these add-ons. Github only detects
one (the Lua). The content are .map files (game map files), .cfg files
(written in WML, an XML-like language used by Wesnoth), and .lua files
(using the Lua programming language).

Installing
----------

Having wesnoth 1.12 (stable), 1.13 (development), or a current branch
of the [wesnoth git repository](https://github.com/wesnoth/wesnoth/)
is the only requirement to run these add-ons. I recommend 1.12 (the
stable version) because I design with multiplayer in mind and the 1.13
(development) multiplayer servers are usually dead. Not every feature
is available when you run it in 1.12, though. You *can* compile the
1.12 branch from the Wesnoth git repository and use it to play
multiplayer on the stable server. I develop and test this on the 1.12
git branch and on the master git branch, so there might be bugs that I
don't notice, especially in 1.13.

When new stable versions of Wesnoth are released, I will immediately
drop support for old stable versions, which will immediately make this
repository break on old stable versions, but you will be able to run
old versions of my add-ons on old stable versions of Wesnoth. I might
create a 1.12 branch that still runs on 1.12 when this happens. The
master branch is only guaranteed to work on the latest stable (1.12)
and latest development (1.13.x) versions. Note that Wesnoth breaks
compatibility each odd number (development) release, so if it works on
1.13.5 it might not work on 1.13.4.

To install the latest version of my add-ons, just checkout this
repository, or download a copy of this repository, and then
symbolically link the directories for the add-ons you want to use in
the wesnoth/1.12/data/add-ons or wesnoth/1.13/data/add-ons directory,
depending on what version you are using. wesnoth's git master counts
as 1.13.

You will also be able to download Aethaeryn's Maps from the add-on
server within Wesnoth itself for versions 1.4, 1.6, and 1.8, but I
wouldn't recommend doing that because those versions of Wesnoth are
old and no longer supported. My add-ons are not available on 1.10's
add-on server and are not currently available on the add-ons servers
for Wesnoth versions 1.12 or 1.13. I will upload stable versions of my
add-ons to Wesnoth versions 1.12 and 1.13 once I get everything
working. Each add-on directory has its own todo that shows what I need
to do to get these add-ons working.

There is a reason why I haven't published these yet for 1.12 and 1.13
and that reason is that these add-ons are *unstable* at the moment,
and some things are *very broken* right now. The code here dates back
to November 2007, originally written for 1.3.9, so I would be
surprised if everything here worked.

License
-------

All content here is licensed under the GPLv2 or later because using
the GPLv2 is a requirement of the Wesnoth add-on server. If I
accidentally write some generally useful Lua code and you want it
under a permissive license, contact me and I'll see if I can double
license it.
