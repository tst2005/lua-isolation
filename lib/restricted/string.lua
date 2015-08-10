
local string = require "string"
local _M = {}
for i,k in pairs{
	"byte",
	"char",
	"find",
	"format",
	"gmatch",
	"gsub",
	"len",
	"lower",
	"match",
	"reverse",
	"sub",
	"upper",
} do
	_M[k]=string[k]
end

return setmetatable({}, {
	__index=_M,
	__newindex=function() error("readonly", 2) end,
	__metatable=false,
})
