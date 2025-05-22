---@protected
autumnnet.payload = {}

--- Reads message with fields
---@protected
---@param id string
---@param name string
---@param sender Player
---@param side "client" | "server"
---@return table<string, AutumnNet.Types>
function autumnnet.payload:read(id, name, sender, side)
  local message = autumnnet.scheme:getThrowable(name)
  ---@type AutumnNet.Scheme.Payload[]
  local messageField = message[side]

  if (!messageField) then
    error("no " .. tostring(side) .. "side for the message")
  end

  local payload = {}

  for _, field in ipairs(messageField) do
    local name, type = field[1], field[2]
    local rw = autumnnet.types[type]
    local read = rw[1]

    payload[name] = read()
  end

  return payload
end

---@protected
---@param name string
---@param payload table<string, any>
---@param recipient Player
---@param side "client" | "server"
---@param idOverride? string
---@return string Message's Id
function autumnnet.payload:write(name, payload, recipient, side, idOverride)
  local id = autumnnet.net.writeId(idOverride)
  net.WriteString(name)

  --- payload
  local message = autumnnet.scheme:getThrowable(name)
  ---@type AutumnNet.Scheme.Payload[]
  local messageField = message[side]

  for _, field in ipairs(messageField) do
    local name, type = field[1], field[2]
    local rw = autumnnet.types[type]
    local write = rw[2]

    write(payload[name])
  end

  if (SERVER && IsValid(recipient)) then
    net.Send(recipient)
  elseif (CLIENT) then
    net.SendToServer()
  else
    error("invalid recipient")
  end

  return id
end