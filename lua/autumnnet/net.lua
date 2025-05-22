---@protected
autumnnet.net = {}
autumnnet.net._storage = {}

---@param iter? integer
---@return string
function autumnnet.net.generateId(iter)
  local netId = util.SHA256(tostring(os.time() + math.random(0, 9999)))

  -- todo
  if (autumnnet.net._storage[netId]) then
    if (iter && iter > 20) then
      error("unable to generate netId")
    end

    return autumnnet.net.generateId((iter or 0) + 1)
  end

  autumnnet.net._storage[netId] = true

  return netId
end

---@param idOverride? string
---@return string Id
function autumnnet.net.writeId(idOverride)
  local id = idOverride or autumnnet.net.generateId()

  net.WriteString(id)

  return id
end

---@return string Id
function autumnnet.net.readId()
  return net.ReadString()
end