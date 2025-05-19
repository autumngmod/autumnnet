---@protected
autumnnet.net = {}

---@param iter? integer
---@return string
function autumnnet.net.generateId(iter)
  local netId = util.SHA256(tostring(os.time() + math.random(0, 9999)))

  -- todo
  if (autumnnet.messagesIds[netId]) then
    if (iter && iter > 20) then
      error("unable to generate netId")
    end

    return generateNetId((iter or 0) + 1)
  end

  return netId
end

---@param idOverride? string
---@return string Id
function autumnnet.net.writeId(idOverride)
  local id = idOverride or generateNetId()

  net.WriteString(id)

  return id
end

---@return string Id
function autumnnet.net.readId()
  return net.ReadString()
end