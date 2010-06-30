PPI = require("libraries.ppi")
tprint = require("libraries.tprint")

function OnPluginEnable()
	print("enabled")
end

local required_plugin = "29a4c0721bef6ae11c3e9a82"
local info = "char.vitals"
-- (ID, on_success, on_failure)
PPI.OnLoad(required_plugin, 
			function(gmcp) 
				gmcp.Listen(GetPluginID() .. "," .. "char.vitals", waha) 
				gmcp.Listen(GetPluginID() .. "," .. "room.info", waha) 
				end, 
			 -- Optional callback for if it's not available.
			function(reason) print(reason) end)

function OnPluginListChanged()
  PPI.Refresh()
end

function waha(info, message)
	ColourNote("blue", "black", "INFO:" .. info .. "\n")
	if type(message) == "string" then
		Note(message)
	else
		tprint(message)
	end
end