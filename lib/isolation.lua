local _M = {}

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
end


-- getmetatable - UNSAFE
-- - Note that getmetatable"" returns the metatable of strings.
--   Modification of the contents of that metatable can break code outside the sandbox that relies on this string behavior.
--   Similar cases may exist unless objects are protected appropriately via __metatable. Ideally __metatable should be immutable. 
-- UNSAFE : http://lua-users.org/wiki/SandBoxes
local function make_safe_getsetmetatable(unsafe_getmetatable, unsafe_setmetatable)
	local safe_getmetatable, safe_setmetatable
	do
		local mt_string = unsafe_getmetatable("")
		safe_getmetatable = function(t)
			local mt = unsafe_getmetatable(t)
			if mt_string == mt then
				return false
			end
			return mt
		end
		safe_setmetatable = function(t, mt)
			if mt_string == t or mt_string == mt then
				return t
			end
			return unsafe_setmetatable(t, mt)
		end
	end
	return safe_getmetatable, safe_setmetatable
end

local function setup_g(g, _G, config)
	assert(type(g)=="table")
	assert(type(_G)=="table")
	assert(type(config)=="table")

	for i,k in ipairs{
		"_VERSION", "assert", "error", "ipairs", "next", "pairs",
		"pcall", "select", "tonumber", "tostring", "type", "unpack","xpcall",
	} do
		g[k]=_G[k]
	end

	local safe_getmetatable, safe_setmetatable = make_safe_getsetmetatable(_G.getmetatable,_G.setmetatable)
	g.getmetatable = assert(safe_getmetatable)
	g.setmetatable = assert(safe_setmetatable)
	g.print = function() end
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
	for i,k in ipairs(config.g_content) do
		if loaded[k] then
			g[k] = loaded[k]
		end
	end
end


local function new_env(_G, conf)
	assert(_G)
	local config = {}
	for k,v in pairs(_M.defaultconfig) do config[k]=v end
	for k,v in pairs(conf) do config[k]=v end
	assert( config.package )
	assert( config.package_wanted )
	assert( config.g_content )

	local g = {}

	local req, package = require("newpackage").new()
	assert(req("package") == package)
	assert(package.loaded.package == package)

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

local defaultconfig = require "isolation.defaults".defaultconfig

_M.new = new_env
_M.run = run
_M.defaultconfig = defaultconfig

return _M
