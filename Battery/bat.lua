---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * 2010, Edited by Jiminald <code@jiminald.co.uk>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}


-- Bat: provides state, charge, and remaining time for a requested battery
module("vicious.widgets.bat")


-- {{{ Battery widget type
local function worker(format, warg)
    if not warg then return end

    local battery = helpers.pathtotable("/sys/class/power_supply/"..warg)
    local info = {
		["{state}"] = "Unknown",
		["{percent}"] = "0",
		["{time}"] = "N/A"
    }

    -- Check if the battery is present
    if battery.present ~= "1\n" then
        return info
    end


    -- Get state information
    --local state = battery_state[battery.status] or battery_state["Unknown\n"]
    info["{state}"] = battery.status

    -- Get capacity information
    if battery.charge_now then
        remaining, capacity = battery.charge_now, battery.charge_full
    elseif battery.energy_now then
        remaining, capacity = battery.energy_now, battery.energy_full
    else
        return info
    end

    -- Calculate percentage (but work around broken BAT/ACPI implementations)
    info["{percent}"] = math.min(math.floor(remaining / capacity * 100), 100)


    -- Get charge information
    if battery.current_now then
        rate = battery.current_now
    else -- Todo: other rate sources, as with capacity?
        return info
    end

    -- Calculate remaining (charging or discharging) time
    if state == "+" then
        timeleft = (tonumber(capacity) - tonumber(remaining)) / tonumber(rate)
    elseif state == "-" then
        timeleft = tonumber(remaining) / tonumber(rate)
    else
        return info
    end
    local hoursleft = math.floor(timeleft)
    local minutesleft = math.floor((timeleft - hoursleft) * 60 )
    info["{time}"] = string.format("%02d:%02d", hoursleft, minutesleft)

    return info
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
