---- initialize the libraries
require("libraries.json")
require("tprint")
PPI = require ("ppi")

--- table of listeners whom want a specific info; char.vital, etc.
GMCP_listeners = {}

-- GMCP and Telnet Request/Subnegotiation info
local CLIENT_ID = {client="MUSHclient", version=Version()}
local codes = {
  IAC_DO_GMCP = "\255\253\201", -- enables GMCP communication
  IAC_SB_GMCP = "\255\250\201", -- begins a GMCP packet
  IAC_SE      = "\255\240",     -- ends a GMCP packet
  GMCP        = 201,            -- GTCP protocol number
}

-- GMCP modules supported by this plugin
local GMCP_options = {
  "Char 1",
  "Char.Skills 1",
  "Room 1",
  "Char.Items 1",
  "Comm.Channel 1",
  "IRE.Rift 1"
}
-------------

-- Linked list iterator
do
  local function iter(list, curr)
    return (curr and curr.next or nil), curr
  end
  
  function links(list)
    return iter, list, list[0]
  end
end


function SendGMCP(message, content)
  Note("Sending: " .. message .. " " .. json.encode(content))
  SendPkt(codes.IAC_SB_GMCP .. message .. " " .. json.encode(content) .. codes.IAC_SE)
end

function OnPluginTelnetRequest (opt, data)
  if opt ~= codes.GMCP then
    return
  end
  
  if data == "WILL" then
    return true
  elseif data == "SENT_DO" then
    ColourNote("blue", "black", "attempting to enable GMCP\n")
    ColourNote("white", "black", "\n")
    
    SendGMCP("Core.Hello", CLIENT_ID)
    SendGMCP("Core.Supports.Set", GMCP_options)
    
    return true
  end
end

function OnPluginTelnetSubnegotiation (opt, data)
  if opt ~= codes.GMCP then
    return
  end
  
  local msg, content
  do
    local t = utils.split(data, " ", 1)
    msg, content = t[1], json.decode(t[2])
  end
  
  --if the enduser want to view what gmcp says, he/she use #gmcpdebug to enable this. --
  if gmcpdebug then
    ColourNote("blue", "black", msg)
    Note(type(content))
    if type(content) == "table" then
      tprint(content)
      ColourNote("white", "black", "\n")
    else
      print(content)
      ColourNote("silver", "black", "\n")
    end
  end -- gmcpdebug
  
  local listeners = GMCP_listeners[msg]
  if listeners then
    for curr, prev in links(listeners) do
      -- If it blows up, remove this callback from the list.
      if not pcall(curr.callback, message, content) then
        prev.next = curr.next
        curr.next.prev = prev
        callbacks[curr.callback] = nil
      end
    end
  end
end

function Listen(message, callback)
  if type(message) ~= "string" or type(callback) ~= "function" then
    return nil, "Invalid argument(s)"
  end
  
  local listeners = GMCP_listeners[message]
  if listeners == nil then
    listeners = {[0] = {}} -- linked list
    GMCP_listeners[message] = listeners
  elseif listeners[callback] then
    return -- already listening
  end
  
  local previous = listeners[#listeners]
  local node = {
    callback = callback,
    next = nil,
    previous = previous,
  }
  
  table.insert(listeners, node)
  previous.next = node
  listeners[callback] = node
end
		
function Unlisten(message, callback)
  if type(message) ~= "string" or type(callback) ~= "function" then
    return nil, "Invalid argument(s)"
  end
  
  local listeners = listeners[message]
  if listeners == nil then
    return -- not listening
  end
  
  local node = listeners[message]
  if node == nil then
    return -- not listening
  end
  
  listeners[message] = nil
  if node.next then
    node.next.previous = node.previous
  end
  if node.previous then
    node.previous.next = node.next
  end
end

PPI.Expose("Listen", Listen)
PPI.Expose("Unlisten", Unlisten)