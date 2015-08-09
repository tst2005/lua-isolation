
local function merge(dest, source)
	for k,v in pairs(source) do
		dest[k] = dest[k] or v
	end
	return dest
end
local function keysfrom(source, keys)
	assert(type(source)=="table")
	assert(type(keys)=="table")
	local t = {}
	for i,k in ipairs(keys) do
		t[k] = source[k]
	end
	return t
end

local function populate_package(loaded, modnames)
	for i,modname in ipairs(modnames) do
		loaded[modname] = require("restricted."..modname)
	end
	return loaded
end

local function setup_g(g, _G, config)
	assert(type(g)=="table")
	assert(type(_G)=="table")
	assert(type(config)=="table")
	assert(type(config.g_content)=="table")
	local g = merge(g, keysfrom(_G, config.g_content))
	g._G = g -- self
end
local function setup_package(package, config)
	package.config	= require"package".config or "/\n;\n?\n!\n-\n"
	package.cpath	= "" -- nil?
	package.path	= "./?.lua;./?/init.lua"
	package.loaders	= package.searchers -- compat
	package.loadlib	= nil
end
local function cross_setup_g_package(g, package, config)
	local loaded = package.loaded
	loaded._G	= g		-- add _G as loaded modules
	
	-- global register all modules
	--for k,v in pairs(loaded) do g[k] = v end
	--g.debug = nil -- except debug

	if config.package == "minimal" then
		populate_package(loaded, {"table", "string"})
	elseif config.package == "all" then
		populate_package(loaded, config.package_wanted)
	end
	g.table		= loaded.table	-- _G.table
	g.string	= loaded.string	-- _G.string

end

local defaultconfig = {}

local function new_env(_G, conf)
	assert(_G)
	local config = {}
	for k,v in pairs(defaultconfig) do config[k]=v end
	for k,v in pairs(conf) do config[k]=v end
	assert( config.package )
	assert( config.package_wanted )
	assert( config.g_content )

	local g = {}

	local req, package = require("newpackage").new()
	assert(req("package") == package)
	local preload, loaded, searchers = package.preload, package.loaded, package.searchers
	assert(loaded.package == package)

	setup_g(g, _G, config)
	setup_package(package, config)
	cross_setup_g_package(g, package, config)

	g.require = req

	return g
end

local function run(f, env)
	local ce = require("compat_env")
	return ce.load(f, nil, nil, newenv)
end


defaultconfig.package_wanted = {
	"bit32", "coroutine", "debug", "io", "math", "os", "string", "table",
}
defaultconfig.g_content = {
	"_VERSION", "assert",
	--collectgarbage --dofile
	"error",
	--getfenv
	"getmetatable", "ipairs",
	--load --loadfile --loadstring --module
	"next", "pairs", "pcall", "print",
	--rawequal --rawget --rawset
	"select",
	--setfenv
	"setmetatable", "tonumber", "tostring", "type", "unpack", "xpcall",
}
defaultconfig.package = "all"

local _M = {
	new = new_env,
	--new_package = function(...) return require"newpackage".new(...) end,
	run = run,
	defaultconfig = defaultconfig,
}
return _M
