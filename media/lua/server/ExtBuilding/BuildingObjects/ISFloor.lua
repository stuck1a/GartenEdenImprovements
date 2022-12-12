if not 'ISExtBuildingObject' then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end

--- @class ISFloor : ISExtBuildingObject
ISFloor = ISExtBuildingObject:derive('ISFloor')


ISFloor.defaults = {
  displayName = 'Floor',
  isoData = { isoName = 'floor' },
  properties = {
    buildLow = true,
    floor = true,
  }
}



function ISFloor:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite, true)
  self.javaObject = self.sq:addFloor(sprite)
  for i=0, self.sq:getObjects():size() - 1 do
    local object = self.sq:getObjects():get(i)
    if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
      self.sq:transmitRemoveItemFromSquare(object)
      self.sq:RemoveTileObject(object)
      break
    end
  end
  self.sq:disableErosion()
  local coords = { x = self.sq:getX(), y = self.sq:getY(), z = self.sq:getZ() }
  sendClientCommand('erosion', 'disableForSquare', coords)
end



function ISFloor:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



function ISFloor:isValid(square)
  if self.isValidAddition ~= nil then if not self.isValidAddition(square) then return false end end
  if not ISWoodenFloor.isValid(self, square) then return false end
  return true
end