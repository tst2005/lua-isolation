local cwtest = require "cwtest"

local T = cwtest.new()

T:start("I. new require with the current package"); do
	local native_package = require "package" -- native package

	require "isolation" -- -- usefull in case of aio preloading...
	local require_new = require "newpackage".new

	local req = require_new(package.loaded, package.preload)
	T:yes(req"package" ~= package)
	T:yes(req"os")
end T:done()

T:exit()
