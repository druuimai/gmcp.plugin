---- initialize the libraries
require("json")
require("tprint")
PPI = require ("ppi")

--- table of listeners whom want a specific info; char.vital, etc.
GMCP_listeners = {}

-- GMCP and Telnet Request/Subnegotiation info
local CLIENT_ID = "MUSHclient " .. Version ()
local IAC, SB, SE, DO = 0xFF, 0xFA, 0xF0, 0xFD
local GMCP = 201
local ATTEMPTED = false
-------------

function OnPluginTelnetRequest (type, data)
	--Note("TYPE: " .. tostring(type) .. "\nDATA:" .. tostring(data))
	if type== GMCP and data == "WILL" and ATTEMPTED == false then
		SendPkt(string.char(IAC, DO, GMCP))
		return
	end
	if type == GMCP and data == "SENT_DO" and ATTEMPTED == false then
		ColourNote("blue", "black", "attempting to enable GMCP\n")
		ColourNote("white", "black", "\n")
		SendPkt(string.char(IAC, SB, GMCP) .. 
			'Core.Hello { "client" : "Mushclient", "version" : "' .. Version() .. '" }' ..
			string.char(IAC, SE))
			
	SendPkt(string.char(IAC, SB, GMCP) .. 
			'Core.Supports.Set [ "Char 1", "Char.Skills 1", "Room 1", "Char.Items 1", "Comm.Channel 1", "IRE.Rift 1" ]' .. 
			string.char(IAC, SE))
	ATTEMPTED = true
	end
			
end

function OnPluginTelnetSubnegotiation (subType, option)
	if not subType == 201 then
		return
	end
	local decodedmessage, t
	t = utils.split (option, " ", 1)
	decodedmessage = json.decode(tostring(t[2]), initialObject)
	
	--if the enduser want to view what gmcp says, he/she use #gmcpdebug to enable this. --
	if gmcpdebug then
		ColourNote("blue", "black", t[1])
		if type(decodedmessage) == "table" then
			tprint(decodedmessage)
			ColourNote("white", "black", "\n")
		else
			print(decodedmessage)
			ColourNote("silver", "black", "\n")
		end
	end -- gmcpdebug
	OnGMCPcall(t[1], decodedmessage)
end

function OnPluginTelnetOption (data)
  Note ("Received option string ", tostring(data))
end -- function OnPluginTelnetOption

function OnPluginDisconnect()
	ATTEMPTED = false
end

function OnGMCPcall(stat, GMCPmsg)
	local stat = string.lower(stat)
	local GMCPmsg = GMCPmsg
	--tprint(GMCP_listeners)
	for w, t in pairs(GMCP_listeners) do
		for k, f in pairs(t) do
			if stat == string.lower(k) then
				f(k, GMCPmsg)
			end
		end
	end
end


function Listen(info, callback)
	local info = utils.split (info, ",", 1)
	info["id"] = info[1]
	info["stat"] = info[2]
	if GMCP_listeners[info.id] == nil then
		GMCP_listeners[info.id] = {}
	end
	GMCP_listeners[info.id][info.stat] = callback
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

PPI.Expose("Listen", Listen)
PPI.Expose("UnListen", UnListen)
PPI.Expose("UnListenAll", UnListenAll)