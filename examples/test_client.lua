--"cebb3e2370084a697f4ca5ae
--requiring some modules to use
PPI = require("ppi")
require("tprint")
--variables
local required_plugin = "0f16b58085aefa674b524ee1"
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

--GMCP = PPI.Load(required_plugin)
--GMCP.hello()
--tprint(GMCP)
