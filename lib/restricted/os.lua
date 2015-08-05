local os = require("os")

local _os = {}
_os.clock	= os.clock
_os.date	= os.date
_os.difftime	= os.difftime
--_os.execute	=
--_os.exit	= os.exit
_os.getenv	= os.getenv -- expose the FS
--_os.remove	=
--_os.rename	=
--_os.setlocale	= 
_os.time	= os.time
--_os.tmpname	=

return _os
