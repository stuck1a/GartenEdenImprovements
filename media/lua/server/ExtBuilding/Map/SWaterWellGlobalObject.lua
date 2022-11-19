if isClient() then return end
require 'Map/SGlobalObject'


--- @class SWaterWellGlobalObject : SGlobalObject
SWaterWellGlobalObject = SGlobalObject:derive('SWaterWellGlobalObject')


function SWaterWellGlobalObject:new(luaSystem, globalObject)
  return SGlobalObject.new(self, luaSystem, globalObject)
end



function SWaterWellGlobalObject:initNew()
  self.waterAmount = 0
  self.waterMax = 5000
end



function SWaterWellGlobalObject:stateFromIsoObject(isoObject)
  self.waterAmount = isoObject:getWaterAmount()
  self.waterMax = isoObject:getModData().waterMax
  isoObject:getModData().waterMax = self.waterMax
  isoObject:transmitModData()
end



function SWaterWellGlobalObject:stateToIsoObject(isoObject)
  if not self.waterAmount then self.waterAmount = 0 end
  if not self.waterMax then self.waterMax = 5000 end
  isoObject:setWaterAmount(self.waterAmount)
  isoObject:getModData().waterMax = self.waterMax
  isoObject:transmitModData()
end