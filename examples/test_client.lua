PPI = require("ppi")
tprint = require("tprint")

GMCP = nil -- someplace to store it globally

function waha(info, message)
  ColourNote("blue", "black", "INFO:" .. info .. "\n")
  if type(message) == "table" then
    tprint(message)
  else
    Note(message)
  end
end

-- (ID, on_success, on_failure)
PPI.OnLoad("29a4c0721bef6ae11c3e9a82",
  -- Callback for when it's been (re)loaded.
  function(gmcp)
    gmcp.Listen("Char.Vitals", waha)
    gmcp.Listen("Room.Info", waha)
    GMCP = gmcp -- store it globally
  end,
  -- Optional callback for if it's not available.
  function(reason)
    Note("Plugin interface unavailable: " .. reason)
  end
)

function OnPluginListChanged()
  PPI.Refresh()
end
