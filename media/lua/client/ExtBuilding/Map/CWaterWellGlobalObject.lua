if isServer() then return end

require 'Map/CGlobalObject'

---@class CWaterWellGlobalObject : CGlobalObject
CWaterWellGlobalObject = CGlobalObject:derive('CWaterWellGlobalObject')


function CWaterWellGlobalObject:new(luaSystem, globalObject)
  return CGlobalObject.new(self, luaSystem, globalObject)
end



function CWaterWellGlobalObject:getObject()
  return self:getIsoObject()
end
