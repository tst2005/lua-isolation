#!/bin/sh

cd -- "$(dirname "$0")" || exit 1

# see https://github.com/tst2005/lua-aio
# wget https://raw.githubusercontent.com/tst2005/lua-aio/aio.lua

#headn=$(grep -nh '^_=nil$' bin/featuredlua |head -n 1 |cut -d: -f1)

LUA_PATH="?.lua;hirdparty/git/tst2005/lua-?/?.lua;;" \
lua -e '
local aio = require "aio"
aio.mode("raw2")

--aio.shebang(			"lib/isolation.lua")
aio.mod("compat_env",		"thirdparty/git/davidm/lua-compat-env/lua/compat_env.lua")
aio.mod("bit.numberlua",	"thirdparty/git/davidm/lua-bit-numberlua/lmod/bit/numberlua.lua")
aio.finish()

aio.code(			"lib/isolation.lua")
aio.finish()
' > isolation.lua
