local defaultconfig = {}
defaultconfig.package_wanted = {
	"bit32", "coroutine", "debug", "io", "math", "os", "string", "table",
}
defaultconfig.g_content = {
	"_VERSION", "assert", "error", "ipairs", "next", "pairs",
	"pcall", "select", "tonumber", "tostring", "type", "unpack","xpcall",
	"getmetatable", "setmetatable",
	"print",
}
--collectgarbage --dofile --getfenv --load --loadfile --loadstring --module
--rawequal --rawget --rawset --setfenv

defaultconfig.package = "all"

local _M = {
	defaultconfig = defaultconfig,
}
return _M
