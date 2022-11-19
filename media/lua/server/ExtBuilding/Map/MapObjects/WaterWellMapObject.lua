if isClient() then return end
require 'ExtBuilding/BuildingObjects/ISWaterWell'


local PRIORITY = 7


local function LoadObject(isoObject)
  local sq = isoObject:getSquare()
  if not instanceof(isoObject, 'IsoThumpable') then return end
  SWaterWellSystem.instance:loadIsoObject(isoObject)
end



local function LoadWaterWell(isoObject)
  LoadObject(isoObject)
end


MapObjects.OnLoadWithSprite('garteneden_tech_01_0', LoadWaterWell, PRIORITY)