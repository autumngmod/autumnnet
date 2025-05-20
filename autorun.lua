---@diagnostic disable-next-line: lowercase-global
autumnnet = {}
---@class AutumnNet.Types.Callbacks
---@field [1] fun(): any Reader
---@field [2] fun(n: any) Writer

---@alias AutumnNet.Types "i8" | "i16" | "i32" | "u8" | "u16" | "u32" | "u64" | "string" | "data" | "data_uncomp" | "entity" | "player"

---@type table<AutumnNet.Types, AutumnNet.Types.Callbacks>
autumnnet.types = {
  i8 = {function() return net.ReadInt(8) end, function(n) net.WriteInt(n, 8) end},
  i16 = {function() return net.ReadInt(16) end, function(n) net.WriteInt(n, 16) end},
  i32 = {function() return net.ReadInt(32) end, function(n) net.WriteInt(n, 32) end},
  u8 = {function() return net.ReadUInt(8) end, function(n) net.WriteUInt(n, 8) end},
  u16 = {function() return net.ReadUInt(16) end, function(n) net.WriteUInt(n, 16) end},
  u32 = {function() return net.ReadUInt(32) end, function(n) net.WriteUInt(n, 32) end},
  u64 = {function() return net.ReadUInt64() end, function(n) net.WriteUInt64(n) end},
  string = {function() return net.ReadString() end, function(n) net.WriteString(n) end},
  data = {function() return util.Decompress(net.ReadData(net.ReadUInt(32))) end, function(n) net.WriteUInt(#n, 32) net.WriteData(util.Compress(n)) end},
  data_uncomp = {function() return net.ReadData(net.ReadUInt(32)) end, function(n) net.WriteUInt(#n, 32) net.WriteData(n) end},
  entity = {function() return net.ReadEntity() end, function(n) net.WriteEntity(n) end},
  player = {function() return net.ReadPlayer() end, function(n) net.WritePlayer(n) end},
}

-- incapsulation

--- Registeres a scheme for the message
---@param name string
---@param scheme AutumnNet.Scheme
function autumnnet.register(name, scheme)
  autumnnet.scheme:new(name, scheme)
end

--- Sends a network message
---@param name string
---@param payload table<string, any>
---@param recipient? Player
function autumnet.send(name, payload, recipient)
  local ok, err = pcall(autumnnet.payload.write, autumnnet.payload, name, payload, recipient, SERVER and "client" or "server")

  if (not ok) then
    ---@diagnostic disable-next-line: need-check-nil
    print("[autumnnet] unable to send message '" .. (name or "unknown message") .. "' to " .. (IsValid(recipient) and recipient:SteamID() or "Console") .. ":" .. err)
  end
end

--- Send a network message, and waits for reply
---@param name string
---@param payload table<string, any>
---@param recipient Player
---@param timeout? integer
---@return AutumnNet.Package | "timeout" | nil
function autumnnet.sendAwait(name, payload, recipient, timeout)
  local co = coroutine.running()
  timeout = timeout or 2

  if (not co) then
    error("no coroutine runtime found!")
  end

  local ok, idOrErr = pcall(autumnnet.payload.write, autumnnet.payload, name, payload, recipient, SERVER and "client" or "server")

  if (not ok) then
    ---@diagnostic disable-next-line: need-check-nil
    print("[autumnnet] unable to send message '" .. (name or "unknown message") .. "' to " .. (IsValid(recipient) and recipient:SteamID() or "Console") ":" .. idOrErr)
  end

  local isReplied = false

  timer.Simple(math.Clamp(timeout, 1, 10), function()
    if (!isReplied) then
      print("[autumnnet] server didn't replied to message '" .. (name or "unknown message") .. "' for " .. timeout .. " seconds.")
      autumnnet.events:remove(name, idOrErr)
      coroutine.resume(co, "timeout")
    end
  end)

  autumnnet.events:listen(name, function(package)
    isReplied = true
    autumnnet.events:remove(name, idOrErr)
    coroutine.resume(co, package)
  end, idOrErr)

  return coroutine.yield()
end

--- Listens to a message
---@param name string
---@param callback fun(package: AutumnNet.Package): nil | AutumnNet.Scheme.Payload
---@param id string
function autumnnet.listen(name, callback, id)
  autumnnet.events:listen(name, callback, id)
end