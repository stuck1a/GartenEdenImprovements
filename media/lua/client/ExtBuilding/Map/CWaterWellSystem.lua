require 'Map/CGlobalObjectSystem'


--- @class CWaterWellSystem : CGlobalObjectSystem
CWaterWellSystem = CGlobalObjectSystem:derive('CWaterWellSystem')


function CWaterWellSystem:new()
  return CGlobalObjectSystem.new(self, 'waterwell')
end



function CWaterWellSystem:isValidIsoObject(isoObject)
  return instanceof(isoObject, 'IsoThumpable') and isoObject:getName() == 'Water Well'
end



function CWaterWellSystem:newLuaObject(globalObject)
  return CWaterWellGlobalObject:new(self, globalObject)
end


CGlobalObjectSystem.RegisterSystemClass(CWaterWellSystem)