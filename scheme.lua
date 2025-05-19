---@protected
autumnnet.scheme = {}
autumnnet.scheme._storage = {}

---@class AutumnNet.Scheme.Payload
---@field [1] string
---@field [2] AutumnNet.Types

---@class AutumnNet.Scheme
---@field server? AutumnNet.Scheme.Payload[]
---@field client? AutumnNet.Scheme.Payload[]
local schemeMt = {}
---@type nil
schemeMt.__index = schemeMt

---@param name string
---@param schemeTab AutumnNet.Scheme
---@return AutumnNet.Scheme
function autumnnet.scheme:new(name, schemeTab)
  local scheme = setmetatable(schemeTab, schemeMt)

  self._storage[name] = scheme

  return scheme
end

---@param name string
---@return AutumnNet.Scheme | nil
function autumnnet.scheme:get(name)
  return self._storage[name]
end

---@param name string
---@return AutumnNet.Scheme
function autumnnet.scheme:getThrowable(name)
  local scheme = self:get(name)

  if (!scheme) then
    error("scheme '" .. tostring(name) .. "' not found")
  end

  return scheme
end