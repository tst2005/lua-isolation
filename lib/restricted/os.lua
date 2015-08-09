local os = require("os")

local _M = {}

for k,v in pairs{
	"clock",
	"date", -- FIXME: On non-POSIX systems, this function may be not thread safe
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
	_M[k]=v
end

return _M
