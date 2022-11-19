if isClient() then return end
require 'Map/SGlobalObjectSystem'

--- @class SWaterWellSystem : SGlobalObjectSystem
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



---
--- Checks, if a given IsoObject is a water well or not
--- @param isoObject IsoObject Target object
--- @return boolean True, if the object belongs to the system "waterwell"
---
function SWaterWellSystem:isValidIsoObject(isoObject)
  return instanceof(isoObject, 'IsoThumpable') and isoObject:getName() == 'Water Well'
end



---
--- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it
---
function SWaterWellSystem:convertOldModData()
  if self.system:loadedWorldVersion() ~= -1 then return end
end



---
--- Adds 5 units of water to the well
---
function SWaterWellSystem:refill()
  for i=1, self:getLuaObjectCount() do
    local luaObject = self:getLuaObjectByIndex(i)
    if luaObject and luaObject.waterAmount < luaObject.waterMax then
      luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + 5)
      local isoObject = luaObject:getIsoObject()
      if isoObject then
        isoObject:setWaterAmount(luaObject.waterAmount)
        isoObject:transmitModData()
      end
    end
  end
end



---
--- Wrapper to invoke the refill method of each water well instance
---
local function EveryTenMinutes()
  SWaterWellSystem.instance:refill()
end



---
--- Writes the new water amount from global object to this lua object
--- @param object IsoObject
--- @param _ int Previous water amount
---
local function OnWaterAmountChange(object, _)
  if not object then return end
  local luaObject = SWaterWellSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
  if luaObject then luaObject.waterAmount = object:getWaterAmount() end
end


SGlobalObjectSystem.RegisterSystemClass(SWaterWellSystem)
Events.EveryTenMinutes.Add(EveryTenMinutes)
Events.OnWaterAmountChange.Add(OnWaterAmountChange)