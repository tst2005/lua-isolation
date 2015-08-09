local isolation = require "isolation"

-- I. new isolated env with new require
do

local new = isolation.new
local e = new(_G, {package="all"})
assert(e ~= _G)
assert(e._G == e)
assert(e.require)
assert(e.require ~= _G.require)

assert(e.require("_G") == e)
do
	local os = e.require("os")
	for i,k in ipairs({"clock", "date", "difftime", "getenv", "time"}) do
		assert(os[k])
		assert(type(os[k])=="function")
	end
end
end -- </.I>


-- II. new require with the current package
do
	local package = require "package"

	require "isolation" -- -- usefull in case of aio preloading...
	local require_new = require "newpackage".new

	--local require_new = require "isolation".new_require

	local req = require_new(package.loaded, package.preload)
	assert(req"package" ~= package)
	assert(req"os")
end

print("ok")
