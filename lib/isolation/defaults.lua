local defaultconfig = {}
defaultconfig.package_wanted = {
	"bit32", "coroutine", "debug", "io", "math", "os", "string", "table",
}
defaultconfig.g_content = {
	"table", "string",
}

defaultconfig.package = "all"

local _M = {
	defaultconfig = defaultconfig,
}
return _M
