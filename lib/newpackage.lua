
-- ----------------------------------------------------------

--_COMPAT51 = "Compat-5.1 R5"
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


