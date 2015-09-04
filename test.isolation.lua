local cwtest = require "cwtest"

local T = cwtest.new()

T:start("I. new isolated env with new require"); do
	local isolation = require "isolation"
	local o = isolation.new(_G, {package="all"})
	local e = o.env

	T:yes(e ~= _G)
	T:yes(e._G == e)
	T:yes(e.require)
	T:yes(e.require ~= _G.require)

	T:yes(e.require("_G") == e)
	do
		local os = e.require("os")
		for i,k in ipairs({"clock", "difftime", "time"}) do
			assert(os[k])
			assert(type(os[k])=="function")
		end
	end
	for i,name in ipairs{ "string", "table", } do
		T:yes(e[name])
		T:yes(e.require(name) == e[name])
	end
	for i,name in ipairs{ "bit32", "coroutine", "debug", "io", "math", "os", } do
		T:no(e[name])
		T:yes(e.require(name))
	end

end T:done()

T:start("II. more test"); do
	local isolation = require "isolation"
	local o = isolation.new(_G, {package="all"})
	T:yes(o.dostring)
	T:yes(o.run)
	T:eq(o:run("return 123"), 123)
end T:done()

local isolation = require "isolation"
local o = isolation.new(_G, {package="all"})

T:start("not in global"); do
	for i,name in ipairs{ "string", "table", } do
		T:yes( type( o:run( "return "..name ) ) == "table" )
		T:yes( o:run( "return require('"..name.."')" ) == o:run( "return "..name ) )
	end
end T:done()

T:start("is in global"); do
	for i,name in ipairs{ "bit32", "coroutine", "debug", "io", "math", "os", } do
		T:no( o:run( "return "..name ) )
		T:yes( type( o:run( "return require('"..name.."')" ) ) == "table" )
	end
end T:done()

T:start("like rings"); do
	local rings = require"isolation"
	local S = rings.new()

	local data = { 12, 13, 14, }
	T:seq( {
S:dostring ([[
aux = {}
for i, v in ipairs ({...}) do
    table.insert (aux, 1, v)
end
return unpack (aux)]], unpack(data))
}, {true, 14, 13, 12}) -- true, 14, 13, 12

	T:seq( { S:dostring( "return ...", unpack(data) ) }, {true, 14, 13, 12} )

end T:done()

T:start('sandbox.run-like') do
	local instance = require "isolation".new()
	local sandbox = {run = function(a1, ...)
		return instance:run(a1, ...)
	end}

--	print(sandbox.run)
--	print(sandbox.run("return 123"))

--	print('when handling base cases')
--	print('it can run harmless function')
	local r = sandbox.run([[return (function() return 'hello' end)()]])
--	print('hello?', type(r), instance.lasterr)
	T:eq(r, 'hello')

	do
	local r = unpack(instance:runf( function() return 'hello' end ))
	T:eq(r, 'hello')
	end

	do
	local ok, r1, r2, r3 = instance:dofunction( function(z) return 'hello', 'world', z end, "!!" )
--T:eq(r1, 'hello')
--T:eq(r2, 'world')
--T:eq(r3, '!!')
	T:yes( r1 == 'hello' and r2 == 'world' and r3 == '!!' )
	end
end T:done()

T:exit()
