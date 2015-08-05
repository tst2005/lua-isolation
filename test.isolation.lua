local isolation = require "isolation"

local new = isolation.new
local e = new()
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

