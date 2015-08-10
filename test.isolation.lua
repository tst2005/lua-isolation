local cwtest = require "cwtest"

local T = cwtest.new()

T:start("I. new isolated env with new require"); do
	local isolation = require "isolation"
	local e = isolation.new(_G, {package="all"})

	T:yes(e ~= _G)
	T:yes(e._G == e)
	T:yes(e.require)
	T:yes(e.require ~= _G.require)

	T:yes(e.require("_G") == e)
	do
		local os = e.require("os")
		for i,k in ipairs({"clock", "difftime", "time"}) do
			assert(os[k])
			assert(type(os[k])=="function")
		end
	end
	for i,name in ipairs{ "string", "table", } do
		T:yes(e[name])
		T:yes(e.require(name) == e[name])
	end
	for i,name in ipairs{ "bit32", "coroutine", "debug", "io", "math", "os", } do
		T:no(e[name])
		T:yes(e.require(name))
	end

end T:done()

-- TODO: move this part to test.newpackage.lua ?
T:start("II. new require with the current package"); do
	local native_package = require "package" -- native package

	require "isolation" -- -- usefull in case of aio preloading...
	local require_new = require "newpackage".new

	local req = require_new(package.loaded, package.preload)
	T:yes(req"package" ~= package)
	T:yes(req"os")
end T:done()

T:exit()
