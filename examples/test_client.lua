--"cebb3e2370084a697f4ca5ae
--requiring some modules to use
PPI = require("ppi")
require("tprint")
--variables
local required_plugin = "0f16b58085aefa674b524ee1"
local info = "char.vitals"
dummy_service = nil

-- (ID, on_success, on_failure)
PPI.OnLoad(required_plugin, 
			function(ds) 
				ds.Hello()
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

Note(tostring(dummy_service))