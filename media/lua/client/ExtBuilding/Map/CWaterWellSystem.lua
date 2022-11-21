require 'Map/CGlobalObjectSystem'

--- @class CWaterWellSystem : CGlobalObjectSystem
CWaterWellSystem = CGlobalObjectSystem:derive('CWaterWellSystem')


function CWaterWellSystem:new()
  return CGlobalObjectSystem.new(self, ISWaterWell.defaults.isoData.systemName)
end



function CWaterWellSystem:isValidIsoObject(isoObject)
  return instanceof(isoObject, ISWaterWell.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) and isoObject:getName() == ISWaterWell.defaults.name
end



function CWaterWellSystem:newLuaObject(globalObject)
  return CWaterWellGlobalObject:new(self, globalObject)
end


CGlobalObjectSystem.RegisterSystemClass(CWaterWellSystem)