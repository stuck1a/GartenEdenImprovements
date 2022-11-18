if isClient() then return end

require 'Map/SGlobalObjectSystem'


---@class SWaterWellSystem : SGlobalObjectSystem
SWaterWellSystem = SGlobalObjectSystem:derive('SWaterWellSystem')


function SWaterWellSystem:new()
  return SGlobalObjectSystem.new(self, 'waterwell')
end



function SWaterWellSystem:initSystem()
  SGlobalObjectSystem.initSystem(self)
  self.system:setModDataKeys({})
  self.system:setObjectModDataKeys({'waterAmount', 'waterMax'})
  self:convertOldModData()
end



function SWaterWellSystem:newLuaObject(globalObject)
  return SWaterWellGlobalObject:new(self, globalObject)
end



function SWaterWellSystem:isValidIsoObject(isoObject)
  return instanceof(isoObject, 'IsoThumpable') and isoObject:getName() == 'waterwell'
end


---
--- If the gos_xxx.bin file existed, don't touch GameTime modData
---
function SWaterWellSystem:convertOldModData()
  if self.system:loadedWorldVersion() ~= -1 then return end
end



function SWaterWellSystem:refill()
  for i=1, self:getLuaObjectCount() do
    local luaObject = self:getLuaObjectByIndex(i)
    if luaObject.waterAmount < luaObject.waterMax then
      luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + 4)
      local isoObject = luaObject:getIsoObject()
      if isoObject then
        isoObject:setWaterAmount(luaObject.waterAmount)
        isoObject:transmitModData()
      end
    end
  end
end

SGlobalObjectSystem.RegisterSystemClass(SWaterWellSystem)



local function EveryTenMinutes()
  SWaterWellSystem.instance:refill()
end



---
--- Event listener
--- @param object
--- @param _ int Previous water amount
---
local function OnWaterAmountChange(object, _)
  if not object then return end
  local luaObject = SWaterWellSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
  if luaObject then luaObject.waterAmount = object:getWaterAmount() end
end


Events.EveryTenMinutes.Add(EveryTenMinutes)
Events.OnWaterAmountChange.Add(OnWaterAmountChange)
