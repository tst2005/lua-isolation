local ce = require("compat_env")


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


-- make the list of currently loaded modules (without restricted.*)
--local package = require("package")
--local loadlist = {}
--for modname in pairs(package.loaded) do
--	if not modname:find("^restricted%.") then
--		loadlist[#loadlist+1] = modname
--	end
--end

--[[ lua 5.1
cpath   ./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so
path    ./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua
config  "/\n;\n?\n!\n-\n"
preload table: 0x3865c40
loaded  table: 0x3863bd0
loaders table: 0x38656b0
loadlib function: 0x38655f0
seeall  function: 0x3865650
]]--
--[[ lua 5.2
cpath   /usr/local/lib/lua/5.2/?.so;/usr/lib/x86_64-linux-gnu/lua/5.2/?.so;/usr/lib/lua/5.2/?.so;/usr/local/lib/lua/5.2/loadall.so;./?.so
path    /usr/local/share/lua/5.2/?.lua;/usr/local/share/lua/5.2/?/init.lua;/usr/local/lib/lua/5.2/?.lua;/usr/local/lib/lua/5.2/?/init.lua;./?.lua;/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua;./?.lua
config  "/\n;\n?\n!\n-\n"
preload table: 0x3059560
loaded  table: 0x3058840
loaders table: 0x3059330 <- compat stuff ??? == searchers
loadlib function: 0x4217d0
seeall  function: 0x4213c0

searchpath      function: 0x421b10
searchers       table: 0x3059330
]]--

local function new_package(preload, loaded, searchers)
	local preload, loaded, searchers = preload or {}, loaded or {}, searchers or {}
	local package = {}
	package.cpath = ""
	package.path = ""
	package.config = "/\n;\n?\n!\n-\n"
	package.preload = preload
	package.loaded = loaded
	package.searchers = searchers
	package.loaders = package.searchers -- compat
	--package.loadlib
	--package.seeall
	return package
end

local t_package_wanted = {
"bit32",
"coroutine",
"debug",
"io",
"math",
"os",
"string",
"table",
}

local function populate_package(loaded, t_package_wanted)
	for i,modname in ipairs(t_package_wanted) do
		loaded[modname] = require("restricted."..modname)
	end
	return loaded
end

local g_content = {
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

local function new_g(t_keys)
	local g = merge({}, keysfrom(_G, g_content))
	g._G = g -- self
	return g
end

local function new_require_with(preload, loaded, searchers)
	local r = function(modname)
		if loaded[modname] then
			return loaded[modname]
		end
		return require(modname)
	end
	return r
end

local function new_env(config)
	package_wanted = t_package_wanted

	local g = new_g()

	local preload, loaded, searchers = {}, {}, {}
	local req = new_require_with(preload, loaded, searchers)
	local p = new_package(preload, loaded, searchers)
	loaded.package	= p -- add package as loaded modules
	loaded._G	= g -- add _G      as loaded modules

	if config.package ~= "minimal" then
		populate_package(loaded, package_wanted)
	end
	g.require = req
	g.table = loaded.table --
	g.string = loaded.string --

	return g
end

local function run(f, env)
	return ce.load(f, nil, nil, newenv)
end
local _M = {
	new = new_env,
	run = run,
}
return _M
