if isClient() then return end

require 'Map/SGlobalObject'

---@class SWaterWellGlobalObject : SGlobalObject
SWaterWellGlobalObject = SGlobalObject:derive('SWaterWellGlobalObject')


function SWaterWellGlobalObject:new(luaSystem, globalObject)
  return SGlobalObject.new(self, luaSystem, globalObject)
end



function SWaterWellGlobalObject:initNew()
  self.waterAmount = ISWaterWell.waterAmount
  self.waterMax = ISWaterWell.waterMax
end



function SWaterWellGlobalObject:stateFromIsoObject(isoObject)
  self.waterAmount = isoObject:getWaterAmount()
  self.waterMax = isoObject:getModData().waterMax
  isoObject:getModData().waterMax = self.waterMax
  isoObject:transmitModData()
end



function SWaterWellGlobalObject:stateToIsoObject(isoObject)
  if not self.waterAmount then self.waterAmount = ISWaterWell.waterAmount end
  if not self.waterMax then self.waterMax = ISWaterWell.waterMax end
  isoObject:setWaterAmount(self.waterAmount)
  isoObject:getModData().waterMax = self.waterMax
  isoObject:transmitModData()
end
