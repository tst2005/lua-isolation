do local sources, priorities = {}, {};assert(not sources["newpackage"])sources["newpackage"]=([===[-- <pack newpackage> --

-- ----------------------------------------------------------

--local loadlib = loadlib
--local setmetatable = setmetatable
--local setfenv = setfenv

local assert, error, ipairs, type = assert, error, ipairs, type
local find, format, gmatch, gsub, sub = string.find, string.format, string.gmatch or string.gfind, string.gsub, string.sub
local loadfile = loadfile

local function lassert(cond, msg, lvl)
	if not cond then
		error(msg, lvl+1)
	end
	return cond
end

-- this function is used to get the n-th line of the str, should be improved !!
local function string_line(str, n)
	if not str then return end
	local f = string.gmatch(str, "(.-)\n")
	local r
	for i = 1,n+1 do
		local v = f()
		if not v then break end
		r = v
	end
	return r
end

local function bigfunction_new(with_loaded, with_preloaded)

--
local _PACKAGE = {}
local _LOADED = with_loaded or {}
local _PRELOAD = with_preloaded or {}
local _SEARCHERS  = {}

--
-- looks for a file `name' in given path
--
local function _searchpath(name, path, sep, rep)
	sep = sep or '.'
	rep = rep or string_line(_PACKAGE.config, 1) or '/'
	local LUA_PATH_MARK = '?'
	local LUA_DIRSEP = '/'
	name = gsub(name, "%.", LUA_DIRSEP)
	lassert(type(path) == "string", format("path must be a string, got %s", type(pname)), 2)
	for c in gmatch(path, "[^;]+") do
		c = gsub(c, "%"..LUA_PATH_MARK, name)
		local f = io.open(c) -- FIXME: use virtual FS here ???
		if f then
			f:close()
			return c
		end
	end
	return nil -- not found
end

--
-- check whether library is already loaded
--
local function searcher_preload(name)
	lassert(type(name) == "string", format("bad argument #1 to `require' (string expected, got %s)", type(name)), 2)
	lassert(type(_PRELOAD) == "table", "`package.preload' must be a table", 2)
	return _PRELOAD[name]
end

--
-- Lua library searcher
--
local function searcher_Lua(name)
	lassert(type(name) == "string", format("bad argument #1 to `require' (string expected, got %s)", type(name)), 2)
	local filename = _searchpath(name, _PACKAGE.path)
	if not filename then
		return false
	end
	local f, err = loadfile(filename)
	if not f then
		error(format("error loading module `%s' (%s)", name, err))
	end
	return f
end

--
-- iterate over available searchers
--
local function iload(modname, searchers)
	lassert(type(searchers) == "table", "`package.searchers' must be a table", 2)
	local msg = ""
	for _, searcher in ipairs(searchers) do
		local loader, param = searcher(modname)
		if type(loader) == "function" then
			return loader, param -- success
		end
		if type(loader) == "string" then
			-- `loader` is actually an error message
			msg = msg .. loader
		end
	end
	error("module `" .. modname .. "' not found: "..msg, 2)
end

--
-- new require
--
local function _require(modname)

	local function checkmodname(s)
		local t = type(s)
		if t == "string" then
		        return s
		elseif t == "number" then
			return tostring(s)
		else
			error("bad argument #1 to `require' (string expected, got "..t..")", 3)
		end
	end

	modname = checkmodname(modname)
	local p = _LOADED[modname]
	if p then -- is it there?
		return p -- package is already loaded
	end

	local loader, param = iload(modname, _SEARCHERS)

	local res = loader(modname, param)
	if res ~= nil then
		p = res
	elseif not _LOADED[modname] then
		p = true
	end

	_LOADED[modname] = p
	return p
end


_SEARCHERS[#_SEARCHERS+1] = searcher_preload
_SEARCHERS[#_SEARCHERS+1] = searcher_Lua
--_SEARCHERS[#_SEARCHERS+1] = searcher_C
--_SEARCHERS[#_SEARCHERS+1] = searcher_Croot,

_LOADED.package = _PACKAGE
do
	local package = _PACKAGE

	--package.config	= nil -- setup by parent
	--package.cpath		= "" -- setup by parent
	package.loaded		= _LOADED
	--package.loadlib
	--package.path		= "./?.lua;./?/init.lua" -- setup by parent
	package.preload		= _PRELOAD
	package.searchers	= _SEARCHERS
	package.searchpath	= _searchpath
end
return _require, _PACKAGE
end -- big function

return {new = bigfunction_new}

-- ----------------------------------------------------------

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

--
-- new package.seeall function
--
--function _package_seeall(module)
--	local t = type(module)
--	assert(t == "table", "bad argument #1 to package.seeall (table expected, got "..t..")")
--	local meta = getmetatable(module)
--	if not meta then
--		meta = {}
--		setmetatable(module, meta)
--	end
--	meta.__index = _G
--end

--
-- new module function
--
--local function _module(modname, ...)
--	local ns = _LOADED[modname]
--	if type(ns) ~= "table" then
--		-- findtable
--		local function findtable(t, f)
--			assert(type(f)=="string", "not a valid field name ("..tostring(f)..")")
--			local ff = f.."."
--			local ok, e, w = find(ff, '(.-)%.', 1)
--			while ok do
--				local nt = rawget(t, w)
--				if not nt then
--					nt = {}
--					t[w] = nt
--				elseif type(t) ~= "table" then
--					return sub(f, e+1)
--				end
--				t = nt
--				ok, e, w = find(ff, '(.-)%.', e+1)
--			end
--			return t
--		end
--		ns = findtable(_G, modname)
--		if not ns then
--			error(format("name conflict for module '%s'", modname), 2)
--		end
--		_LOADED[modname] = ns
--	end
--	if not ns._NAME then
--		ns._NAME = modname
--		ns._M = ns
--		ns._PACKAGE = gsub(modname, "[^.]*$", "")
--	end
--	setfenv(2, ns)
--	for i, f in ipairs(arg) do
--		f(ns)
--	end
--end


--local POF = 'luaopen_'
--local LUA_IGMARK = ':'
--
--local function mkfuncname(name)
--	local LUA_OFSEP = '_'
--	name = gsub(name, "^.*%"..LUA_IGMARK, "")
--	name = gsub(name, "%.", LUA_OFSEP)
--	return POF..name
--end
--
--local function old_mkfuncname(name)
--	local OLD_LUA_OFSEP = ''
--	--name = gsub(name, "^.*%"..LUA_IGMARK, "")
--	name = gsub(name, "%.", OLD_LUA_OFSEP)
--	return POF..name
--end
--
----
---- C library searcher
----
--local function searcher_C(name)
--	lassert(type(name) == "string", format(
--		"bad argument #1 to `require' (string expected, got %s)", type(name)), 2)
--	local filename = _searchpath(name, _PACKAGE.cpath)
--	if not filename then
--		return false
--	end
--	local funcname = mkfuncname(name)
--	local f, err = loadlib(filename, funcname)
--	if not f then
--		funcname = old_mkfuncname(name)
--		f, err = loadlib(filename, funcname)
--		if not f then
--			error(format("error loading module `%s' (%s)", name, err))
--		end
--	end
--	return f
--end
--
--local function searcher_Croot(name)
--	local p = gsub(name, "^([^.]*).-$", "%1")
--	if p == "" then
--		return
--	end
--	local filename = _searchpath(p, "cpath")
--	if not filename then
--		return
--	end
--	local funcname = mkfuncname(name)
--	local f, err, where = loadlib(filename, funcname)
--	if f then
--		return f
--	elseif where ~= "init" then
--		error(format("error loading module `%s' (%s)", name, err))
--	end
--end


]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["isolation.defaults"])sources["isolation.defaults"]=([===[-- <pack isolation.defaults> --
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
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.debug"])sources["restricted.debug"]=([===[-- <pack restricted.debug> --

local _debug = {}
return _debug
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.bit32"])sources["restricted.bit32"]=([===[-- <pack restricted.bit32> --
return {}
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.io"])sources["restricted.io"]=([===[-- <pack restricted.io> --
local io = require("io")

local _M = {}
--io.close
--io.flush
--io.input
--io.lines
--io.open
--io.output
--io.popen
--io.read
--io.stderr
--io.stdin
--io.stdout
--io.tmpfile
--io.type
--io.write
return _M
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.os"])sources["restricted.os"]=([===[-- <pack restricted.os> --
local os = require("os")

local _M = {}

for i,k in ipairs{
	"clock",
--	"date", -- See [date_unsafe] FIXME: On non-POSIX systems, this function may be not thread safe
	"difftime",
--execute
--exit
--getenv
--remove
--rename
--setlocale
	"time",
--tmpname
} do
	_M[k]=os[k]
end

-- os.date is unsafe : The Lua 5.3 manuals say "On non-POSIX systems, this function may be not thread safe"
-- See also : https://github.com/APItools/sandbox.lua/issues/7#issuecomment-129259145
-- > I believe it was intentional. See the comment. https://github.com/APItools/sandbox.lua/blob/a4c0a9ad3d3e8b5326b53188b640d69de2539313/sandbox.lua#L48
-- > Probably based on http://lua-users.org/wiki/SandBoxes
-- >     os.date - UNSAFE - This can crash on some platforms (undocumented). For example, os.date'%v'. It is reported that this will be fixed in 5.2 or 5.1.3.

return _M
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.table"])sources["restricted.table"]=([===[-- <pack restricted.table> --
local table = require "table"

local _M = {}
_M.insert = table.insert
_M.maxn = table.maxn
_M.remove = table.remove
_M.sort = table.sort
_M.unpack = table.unpack
_M.pack = table.pack

return _M
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted._file"])sources["restricted._file"]=([===[-- <pack restricted._file> --
local file = require("file")

local _file = {}
--file:close
--file:flush
--file:lines
--file:read
--file:seek
--file:setvbuf
--file:write
return _file
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.string"])sources["restricted.string"]=([===[-- <pack restricted.string> --

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
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.coroutine"])sources["restricted.coroutine"]=([===[-- <pack restricted.coroutine> --
local coroutine = require "coroutine"
local _M = {
	create = coroutine.create,
	resume = coroutine.resume,
	running = coroutine.running,
	status = coroutine.status,
	wrap = coroutine.wrap,
	yield = coroutine.yield,
}

return _M
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
assert(not sources["restricted.math"])sources["restricted.math"]=([===[-- <pack restricted.math> --
local math = require("math")
local _M = {}

for i,k in ipairs({
	"abs", "acos", "asin", "atan", "atan2", "ceil", "cos", "cosh",
	"deg", "exp", "floor", "fmod", "frexp", "huge", "ldexp", "log",
	"log10", "max", "min", "modf", "pi", "pow", "rad", "random",
	--"randomseed",
	"sin", "sinh", "sqrt", "tan", "tanh",
}) do
	_M[k] = math[k]
end

-- lock metatable ?
return _M
]===]):gsub('\\([%]%[]===)\\([%]%[])','%1%2')
local add
if not pcall(function() add = require"aioruntime".add end) then
        local loadstring=_G.loadstring or _G.load; local preload = require"package".preload
        add = function(name, rawcode)
		if not preload[name] then
		        preload[name] = function(...) return assert(loadstring(rawcode), "loadstring: "..name.." failed")(...) end
		else
			print("WARNING: overwrite "..name)
		end
        end
end
for name, rawcode in pairs(sources) do add(name, rawcode, priorities[name]) end
end;
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

local function setup_g(g, master, config)
	assert(type(g)=="table")
	assert(type(master)=="table")
	assert(type(config)=="table")

	for i,k in ipairs{
		"_VERSION", "assert", "error", "ipairs", "next", "pairs",
		"pcall", "select", "tonumber", "tostring", "type", "unpack","xpcall",
	} do
		g[k]=master[k]
	end

	local safe_getmetatable, safe_setmetatable = make_safe_getsetmetatable(master.getmetatable,master.setmetatable)
	g.getmetatable = assert(safe_getmetatable)
	g.setmetatable = assert(safe_setmetatable)
	g.print = function() end
	g["_G"] = g -- self
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
	loaded["_G"]	= g		-- add _G as loaded modules

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


local function new_env(master, conf)
	assert(master) -- the real _G
	local config = {}
	for k,v in pairs(_M.defaultconfig) do config[k]=v end
	if type(conf) == "table" then
		for k,v in pairs(conf) do config[k]=v end
	end
	assert( config.package )
	assert( config.package_wanted )
	assert( config.g_content )

	local g = {}

	local req, package = require("newpackage").new()
	assert(req("package") == package)
	assert(package.loaded.package == package)

	setup_g(g, master, config)
	setup_package(package, config)
	cross_setup_g_package(g, package, config)

	g.require = req

	return g
end

local ce_load = require("compat_env").load
--local function run(f, env)
--	return ce_load(f, nil, nil, env)
--end

local funcs = {
	dostring = function(self, str, ...)
		return pcall(function(...) return ce_load(str, str, 't', self.env)(...) end, ...)
	end,
	run = function(self, str, ...)
		local function filter(ok, ...)
			self.lastok = ok
			if not ok then
				self.lasterr = ...
				return nil
			end
			self.lasterr = nil
			return ...
		end
		if type(str) == "function" then
			print("STR = function here", #{...}, ...)
			return require"compat_env".setfenv(f, self.env)(...)
			--return filter(pcall(function(...)
			--	return assert(ce_load(string.dump(str), nil, 'b', self.env))(...)
			--end))
		end
		return filter( pcall( function(...)
			return assert(ce_load(str, str, 't', self.env))(...)
		end) )
	end,
	dofunction = function(self, func, ...)
		assert( type(func) == "function")
		return pcall(function(...) return func(...) end, ...)
	end,
	runf = function(self, func, ...)
		assert( type(func) == "function")
		local ok, t_ret = pcall(function(...) return {func(...)} end, ...)
		if ok then
			return t_ret
		else
			return nil
		end
	end,
}
local new_mt = { __index = funcs, }

local function new(master, conf)
	local e = new_env(master or _G, conf)
	local o = setmetatable( {env = e}, new_mt)
	assert(o.env)
	return o
end

local defaultconfig = require "isolation.defaults".defaultconfig

--_M.new_env = new_env
_M.new = new
_M.run = run
_M.defaultconfig = defaultconfig

return _M
