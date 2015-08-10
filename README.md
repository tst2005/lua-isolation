Lua Isolation
=============

Isolation help you to create a isolated lua environment, a sandbox.

It's easy to create an new environment and run code inside.
It's harder to have a full emulated `require` and package management inside this sandbox.

Isolation allow you to create a new isolated package management (including require).

Difference between native Lua environment
=========================================

I decide to follow :
 * the Lua 5.2 (5.3?) `require` implementation, it means a `require` without sentinel.
 * the package table items follow the Lua 5.3 names, with the `package.loaders` == `package.searchers` and the `paackage.searchpath` is implemented.
 * the new created environment does only contains `table` and `string`. All other module must be called with the `require` function.


Alternative use
---------------

You are also able to make a new `require` attached to the current `package` table.
The isolation's `require` follow the Lua5.2+ one.
It should be usefull to got a modern `require` on Lua 5.1.


Long term goal
==============

 * Inception : Be able to load this module inside a isolated environment create a new one.
 * API : define the minimal function to setup a isolated environment
 * Customization : find a good way to setup what you want
 * Sharing : how manage/control sharing stuff between guest and parent environment
 * ... and more.


Dependencies
------------

Tested with Lua 5.1, LuaJIT(5.1), Lua5.2.
Should be compatible with Lua 5.3.


See also
========

Similar projet
* [sandbox.lua](https://github.com/APItools/sandbox.lua)
* [lua-modjail](https://github.com/siffiejoe/lua-modjail)
* info on http://lua-users.org/wiki/SandBoxes

About potential futur API :
* [rings](https://github.com/keplerproject/rings) that has master/slave API.

License
=======

Licensed under MIT.


