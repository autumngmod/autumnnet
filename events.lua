---@protected
autumnnet.events = {}
--- Event listeners
---@type table<string, table<string, (fun(package: AutumnNet.Package): nil | AutumnNet.Scheme.Payload)>>
autumnnet.events._storage = {}

---@param name string
---@param package AutumnNet.Package
function autumnnet.events:run(name, package)
  local listeners = self._storage[name]

  if (!listeners) then
    return print("[autumnnet] no listeners for message '" .. (name or "unknown message") .. "'")
  end

  -- "async" runtime
  local co = coroutine.create(function()
    for _, listen in ipairs(listeners) do
      local content = listen(package)

      if (!content) then
        continue
      end

      -- reply
      local id = package:getId()
      autumnnet.payload:write(name, content, package:getSender(), SERVER and "client" or "server", id)
    end
  end)

  coroutine.resume(co)
end

---@param name string
---@param listener fun(package: AutumnNet.Package): nil | AutumnNet.Scheme.Payload
---@param id? string
---@return integer?
function autumnnet.events:listen(name, listener, id)
  if (!self._storage[name]) then
    self._storage[name] = {}
  end

  local generated

  if (!id) then
    generated = #self._storage[name]+1
  end

  self._storage[name][id or generated] = listener

  return generated
end

---@param name string
---@param id string | integer
function autumnnet.events:remove(name, id)
  self._storage[name][id] = nil
end