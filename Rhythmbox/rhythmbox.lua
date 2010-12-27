---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Jiminald <code@jiminald.co.uk>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
-- }}}

-- Mpd: provides Rhythmbox information
module("vicious.widgets.rhythmbox")

-- {{{ Rhythmbox widget type
local function worker(format, warg)
	local info = {
	    ["{state}"] = "nil"
	}
	
	local f = io.popen("rhythmbox-client --no-start --print-playing")
	info["{state}"] = f:read("*line")
	f:close()
	return info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
