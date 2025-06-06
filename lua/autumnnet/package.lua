---@protected
autumnnet.package = {}

if (SERVER) then
  util.AddNetworkString "autumnnet"
end

---@class AutumnNet.Package
---@field id string
---@field name string
---@field sender Player
---@field payload table<string, AutumnNet.Types>
local packageMt = {}

---@return string
function packageMt:getId()
  return self.id
end

---@return Player
function packageMt:getSender()
  return self.sender
end

---@return table<string, AutumnNet.Types>
function packageMt:getPayload()
  return self.payload
end

function packageMt.__index(tbl, key)
  local method = rawget(packageMt, key)
  if method then
    return method
  end

  local payload = rawget(tbl, "payload")
  return payload and payload[key]
end

---@paran id string
---@param name string
---@param sender Player
---@param payload table<string, AutumnNet.Types>
function autumnnet.package:new(id, name, sender, payload)
  return setmetatable({ id = id, name = name, sender = sender, payload = payload }, packageMt)
end

---@param id string
---@param name string
---@param sender Player
function autumnnet.package:incoming(id, name, sender)
  local side = SERVER and "server" or "client"
  -- reading package's contents
  local ok, payload = pcall(autumnnet.payload.read, autumnnet.payload, id, name, sender, side)

  if (not ok) then
    print("[autumnnet] unable to read payload '" .. (name or "unknown message") .. "' from " .. (IsValid(sender) and sender:SteamID() or "Console") .. ": " .. payload)
  end

  -- creating package
  local package = autumnnet.package:new(id, name, sender, payload)

  autumnnet.events:run(name, package)
end

---@param _len integer
---@param sender Player
function autumnnet.package.read(_len, sender)
  local id = autumnnet.net.readId()
  local name = net.ReadString()

  autumnnet.package:incoming(id, name, sender)
end

net.Receive("autumnnet", autumnnet.package.read)