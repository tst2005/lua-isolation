# Lua Isolation

Isolation help you to create a isolated lua environment, a sandbox.

It's easy to create an new environment and run code inside.
It's harder to have a full emulated `require` and package management inside this sandbox.

Similar projet [sandbox.lua](https://github.com/APItools/sandbox.lua) 

# Long term goal

 * Inception : Be able to load this module inside a isolated environment create a new one.
 * API : define the minimal function to setup a isolated environment
 * Customization : find a good way to setup what you want
 * Sharing : how manage/control sharing stuff between guest and parent environment
 * ... and more.

# License

Licensed under MIT.


