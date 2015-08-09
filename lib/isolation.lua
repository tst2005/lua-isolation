
local function merge(dest, source)
	for k,v in pairs(source) do
		dest[k] = dest[k] or v
	end
	return dest
end
local function keysfrom(source, keys)
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

local function setup_g(g, config)
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
	elseif config.package == "default" then
		populate_package(loaded, package_wanted)
	end
	g.table		= loaded.table	-- _G.table
	g.string	= loaded.string	-- _G.string

end

local defaultconfig = {}

local function new_env(config)
	config = config or defaultconfig
	package_wanted = config.t_package_wanted

	local g = {}

	local req, package = require("newpackage").new()
	assert(req("package") == package)
	local preload, loaded, searchers = package.preload, package.loaded, package.searchers
	assert(loaded.package == package)

	setup_g(g, config)
	setup_package(package, config)
	cross_setup_g_package(g, package, config)

	g.require = req

	return g
end

local function run(f, env)
	local ce = require("compat_env")
	return ce.load(f, nil, nil, newenv)
end


defaultconfig.t_package_wanted = {
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
defaultconfig.package = "default"

local _M = {
	new = new_env,
	run = run,
	defaultconfig = defaultconfig,
}
return _M
