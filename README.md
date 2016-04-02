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
==========

Requirements
------------

The only requirement is a recent version of the game *wesnoth*. You
can find out how to download the stable and development releases
[from its website](https://wesnoth.org) and you can checkout the
latest git versions (including the stable branch) from the
[wesnoth git repository](https://github.com/wesnoth/wesnoth/). If
you're using a Linux or BSD distro, it is probably in the repositories
as wesnoth. If you download it from the repositories, make sure to
install everything related to wesnoth because some add-ons (not the
ones here, though) use resources from campaigns even though some
distros split the campaign data into separate packages.

Wesnoth version scheme
----------------------

To understand how the dependency works, you need to understand how the
wesnoth versions work. The wesnoth version scheme is 1.m.n, where 1
exists because the developers like small numbers, m stands for the
current branch, and n stands for the current minor version. Every even
m stands for a stable version and every odd m stands for a development
version. When m becomes stable, it is labeled m+1. Releases, numbered
by n, will only break backwards compatibility for odd numbers, not
even numbers.

For example, 1.11 developed into 1.12. 1.13 became the new development
version, and when it is ready it will become 1.14 and no more breaking
changes will be introduced there, but rather to 1.15.

Practically speaking, this means that if you want to use the new nice
features, you need to be on the latest odd branch, and if you want to
play multiplayer, you want to be on the latest even branch *or* the
odd branch with the highest n. 1.12.5 can play multiplayer with
1.12.0, but 1.13.4 can't play multiplayer with 1.13.0 because a lot of
breaking changes were introduced since then. In practice, most
multiplayer is done on the stable (even) branches because of this.

This is slightly complicated by the way wesnoth works on git. There is
a 1.12 branch and a branch for each prior stable version, but there is
no 1.13 branch or any prior odd-numbered release. Development for the
odd-numbered branches is done directly on master, and forked off into
an even branch when a new stable branch is released. This means that
there are in effect two "latest" unstable versions of Wesnoth on git:
whatever specific commit became tagged as 1.13.n and whatever the
current commit on the master branch is.

If you use git to get the latest stable branch (1.12) it doesn't
matter if you try to pick a specific tagged commit or just use the
latest because everything in 1.12 is supposed to be compatible with
everything else. I personally use the latest commit on the 1.12
branch.

Currently recommended Wesnoth versions
--------------------------------------

This runs on both the latest stable branch (1.12) and the latest
development branch (master, 1.13) with no modifications required,
using conditionals to not run certain Lua API calls if they're not
available.

The latest *1.12 (stable) version* is preferred if you want to use
these add-ons in multiplayer because the multiplayer is much more
active there. Either download it or compile the 1.12 branch from the
git repository. I do most of my testing on 1.12, so there shouldn't be
any issues.

When run in the *1.13 (development) version*, the add-on has more
features. I only test those features on the latest git master branch
of wesnoth, so it's possible that it won't currently work on released
versions of 1.13. If that's the case, it should work when the next
version is released, but report it as a bug and I can add the
appropriate conditionals to disable the feature that's not yet there.

Supported versions
------------------

When new stable versions of Wesnoth are released, I will immediately
drop support for old stable versions, which will immediately make this
repository break on old stable versions, but you will be able to run
old versions of my add-ons on old stable versions of Wesnoth. I might
create a 1.12 branch that still runs on 1.12 when this happens. The
master branch of this repository is only guaranteed to work on the
latest stable branch (1.12) and the latest development version
(1.13.n).

Aethaeryn's Maps is on the add-on server within Wesnoth itself for
versions 1.4, 1.6, and 1.8, but I wouldn't recommend installing it
from there because those versions of Wesnoth are old and no longer
supported, and those versions of Aethaeryn's Maps are old and no
longer supported. My add-ons are not available on 1.10's add-on server
and are not currently available on the add-ons servers for Wesnoth
versions 1.12 or 1.13. I will upload stable versions of my add-ons to
Wesnoth versions 1.12 and 1.13 once I get everything working. Each
add-on directory has its own todo that shows what I need to do to get
these add-ons working.

Installation
------------

To install the latest version of my add-ons, just checkout this
repository, or download a copy of this repository, and then
symbolically link the directories for the add-ons you want to use in
the wesnoth/1.12/data/add-ons or wesnoth/1.13/data/add-ons directory,
depending on what version you are using. wesnoth's git master counts
as 1.13.

As noted in the previous section, these add-ons are not currently on
the add-on server. There is a reason why I haven't published these yet
for 1.12 and 1.13 and that reason is that these add-ons are *unstable*
at the moment, and some things are *very broken* right now. The code
here dates back to November 2007, originally written for 1.3.9, so I
would be surprised if everything here worked.

License
=======

All content here is licensed under the GPLv2 or later because using
the GPLv2 is a requirement of the Wesnoth add-on server. If I
accidentally write some generally useful Lua code and you want it
under a permissive license, contact me and I'll see if I can double
license it.

More information
================

Each directory in wesnoth-umc is its own add-on, intended to be
published as a separate add-on on the Wesnoth add-on server. For
information on the specific add-on, see the README.md in each
directory.
