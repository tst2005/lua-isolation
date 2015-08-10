local isolation = require "isolation"

-- I. new isolated env with new require
do

local e = isolation.new(_G, {package="all"})
assert(e ~= _G)
assert(e._G == e)
assert(e.require)
assert(e.require ~= _G.require)

assert(e.require("_G") == e)
do
	local os = e.require("os")
	for i,k in ipairs({"clock", "difftime", "time"}) do
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

	local req = require_new(package.loaded, package.preload)
	assert(req"package" ~= package)
	assert(req"os")
end

print("ok")
