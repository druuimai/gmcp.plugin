--0f16b58085aefa674b524ee1

PPI = require("ppi")
require("tprint")

GMCP_listeners = {}

PPI.Expose("Listen", function (info, callback) Listen(info, callback) end)

function Listen(info, callback)
	local info = utils.split (info, ",", 1)
	info["id"] = info[1]
	info["stat"] = info[2]
	if GMCP_listeners[info.id] == nil then
		GMCP_listeners[info.id] = {}
	end
	GMCP_listeners[info.id][info.stat] = callback
end

function OnGMCPcall()
	tprint(GMCP_listeners)
	for w, t in pairs(GMCP_listeners) do
		for k, f in pairs(t) do
			pcall(f(k, "Can you hear me now?"))
		end
	end
end
		
function UnListen(info)
	local info = utils.split (info, ",", 1)
	info["id"] = info[1]
	info["stat"] = info[2]
	GMCP_listeners[info.id][info.stat] = nil
end

function UnListenAll(PluginIDx)
	GMCP_Listeners[PluginIDx] = nil
end

function Hello()
	print("Hello user, what you want from me?")
end
PPI.Expose("Listen", Listen)
PPI.Expose("UnListen", UnListen)
PPI.Expose("UnListenAll", UnListenAll)
PPI.Expose("Hello", Hello)