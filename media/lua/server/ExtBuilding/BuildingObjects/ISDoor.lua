if not ISExtBuildingObject then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end

--- @class ISDoor : ISExtBuildingObject
ISDoor = ISExtBuildingObject:derive('ISDoor')


ISDoor.defaults = {
  displayName = 'Door',
  properties = {
    isWallLike = true,
    dismantable = true,
  },
  isoData = { isoName = 'door' }
}



--- Java object constructor - initializes and places a completed door object
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from east to west)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether the north sprite was chosen
--- @param sprite string Name of the chosen sprite
function ISDoor:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite)
  self.javaObject:transmitCompleteItemToServer()



  local cell = getWorld():getCell();
  self.sq = cell:getGridSquare(x, y, z);
  local openSprite = self.openSprite;
  if north then
    openSprite = self.openNorthSprite;
  end
  self.javaObject = IsoThumpable.new(cell, self.sq, sprite, openSprite, north, self);


  -- set the key id if we had one
  for _,item in ipairs(consumedItems) do
    if item:getType() == "Doorknob" and item:getKeyId() ~= -1 then
      self.javaObject:setKeyId(item:getKeyId(), false)
    end
  end
  self.javaObject:transmitCompleteItemToServer();
end



--- Lua object constructor - generates a new door object
--- @param player number Target player ID
--- @param recipe table The building definition
--- @return ISExtBuildingObject BuildingObject instance
function ISDoor:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean True, if building can be placed on current target square
function ISDoor:isValid(square)
  if not ISExtBuildingObject.isValid(self, square) then return false end
  if not ISWoodenDoor.isValid(self, square) then return false end
  return true
end