local math = require("math")
local _math = {}
for k,v in pairs(math) do
	_math[k] = v
end

--math.abs
--math.acos
--math.asin
--math.atan
--math.atan2
--math.ceil
--math.cos
--math.cosh
--math.deg
--math.exp
--math.floor
--math.fmod
--math.frexp
--math.huge
--math.ldexp
--math.log
--math.log10
--math.max
--math.min
--math.modf
--math.pi
--math.pow
--math.rad
--math.random
--math.randomseed
--math.sin
--math.sinh
--math.sqrt
--math.tan
--math.tanh

return _math -- lock metatable ?
