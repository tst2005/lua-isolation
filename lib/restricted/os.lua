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
