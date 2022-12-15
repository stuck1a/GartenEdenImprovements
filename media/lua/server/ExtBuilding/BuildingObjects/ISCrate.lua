if not ISExtBuildingObject then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end

--- @class ISCrate : ISExtBuildingObject
ISCrate = ISExtBuildingObject:derive('ISCrate')


ISCrate.defaults = {
  displayName = 'Crate',
  isoData = { isoName = 'crate' },
  properties = {
    renderFloorHelper = true,
    canBeAlwaysPlaced = true,
    dismantable = true,
    isContainer = true,
    blockAllTheSquare = true,
    canBeLockedByPadlock = true,
    buildLow = true,
    containerType = 'crate'
  }
}



function ISCrate:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite, true)
  self.javaObject = _G[self.isoData.isoType].new(getWorld():getCell(), self.sq, sprite, north, self)
  buildUtil.setInfo(self.javaObject, self)
  local sharedSprite = getSprite(self:getSprite())
  if self.sq and sharedSprite and sharedSprite:getProperties():Is('IsStackable') then
    local props = ISMoveableSpriteProps.new(sharedSprite)
    self.javaObject:setRenderYOffset(props:getTotalTableHeight(self.sq))
  end
  self.javaObject:setMaxHealth(self:getHealth(self.mainMaterial, self.baseHealth))
  self.javaObject:setHealth(self.javaObject:getMaxHealth())
  self.javaObject:setBreakSound(self.breakSound)
  self.javaObject:setThumpSound(self.thumpSound)
  self.javaObject:setSpecialTooltip(self.hasSpecialTooltip)
  self.sq:AddSpecialObject(self.javaObject)
end



function ISCrate:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



function ISCrate:isValid(square)
  if self.isValidAddition ~= nil then if not self.isValidAddition(square) then return false end end
  if not ISWoodenContainer.isValid(self, square) then return false end
  return true
end