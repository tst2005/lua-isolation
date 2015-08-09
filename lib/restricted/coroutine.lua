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
