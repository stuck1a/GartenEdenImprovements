if not 'ISExtBuildingObject' then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end


--- @class ISWall : ISExtBuildingObject
ISWall = ISExtBuildingObject:derive('ISWall')

ISWall.defaults = {
  displayName = 'Wall',
  craftingBank = 'Hammering',
  properties = { isWallLike = true },
  isoData = { isoName = 'wall' },
  modData = { ['wallType'] = 'wall' }
}


---
--- Java object constructor - initializes and places a completed water well
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from west to east)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether the north sprite was chosen
--- @param sprite string Name of the chosen sprite
---
function ISWall:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite)
  self.sq:RecalcAllWithNeighbours(true)
  buildUtil.checkCorner(x, y, z, north, self, self.javaObject)
  self.javaObject:transmitCompleteItemToServer()
end



---
--- Lua object constructor - generates a new wall object
--- @param player number Target player ID
--- @param recipe table The building definition
--- @return ISExtBuildingObject BuildingObject instance
---
function ISWall:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean True, if building can be placed on current target square
---
function ISWall:isValid(square)
  -- base rules (valid, walkable, free space, reachable, solid ground, etc)
  --if not ISExtBuildingObject.isValid(self, square) then return false end
  --for i=1, square:getObjects():size() do
  --  local object = square:getObjects():get(i-1);
  --  local sprite = object:getSprite()
  --  -- not if existing objects have mismatching collide flags
  --  if (sprite and ((sprite:getProperties():Is(IsoFlagType.collideN) and self.north) or
  --      (sprite:getProperties():Is(IsoFlagType.collideW) and not self.north))) or
  --      ((instanceof(object, 'IsoThumpable') and (object:getNorth() == self.north)) and not object:isCorner() and not object:isFloor() and not object:isBlockAllTheSquare()) or
  --      (instanceof(object, 'IsoWindow') and object:getNorth() == self.north) or
  --      (instanceof(object, 'IsoDoor') and object:getNorth() == self.north) then
  --    return false
  --  end
  --  -- not between parts of multi-tile objects
  --  local spriteGrid = sprite and sprite:getSpriteGrid()
  --  if spriteGrid then
  --    local gridX = spriteGrid:getSpriteGridPosX(sprite)
  --    local gridY = spriteGrid:getSpriteGridPosY(sprite)
  --    if self.north and gridY > 0 then return false end
  --    if not self.north and gridX > 0 then return false end
  --  end
  --end
  -- not in midair
  --if not square:hasFloor(self.north) then
  --  local belowSQ = getCell():getGridSquare(square:getX(), square:getY(), square:getZ()-1)
  --  if belowSQ then
  --    -- except on top of stairs
  --    if self.north and not belowSQ:HasStairsWest() then return false end
  --    if not self.north and not belowSQ:HasStairsNorth() then return false end
  --  end
  --end
  --return true
  if not self:haveMaterial(square) then return false end
  if isClient() and SafeHouse.isSafeHouse(square, getSpecificPlayer(self.player):getUsername(), true) then return false end
  if square:isVehicleIntersecting() then return false end
  for i=1, square:getObjects():size() do
    local object = square:getObjects():get(i-1)
    local sprite = object:getSprite()
    if (sprite and ((sprite:getProperties():Is(IsoFlagType.collideN) and self.north) or
        (sprite:getProperties():Is(IsoFlagType.collideW) and not self.north))) or
        ((instanceof(object, 'IsoThumpable') and (object:getNorth() == self.north)) and not object:isCorner() and not object:isFloor() and not object:isBlockAllTheSquare()) or
        (instanceof(object, 'IsoWindow') and object:getNorth() == self.north) or
        (instanceof(object, 'IsoDoor') and object:getNorth() == self.north) then
      return false
    end
    local spriteGrid = sprite and sprite:getSpriteGrid()
    if spriteGrid then
      local gridX = spriteGrid:getSpriteGridPosX(sprite)
      local gridY = spriteGrid:getSpriteGridPosY(sprite)
      if self.north and gridY > 0 then return false end
      if not self.north and gridX > 0 then return false end
    end
  end
  if buildUtil.stairIsBlockingPlacement(square, true, (self.nSprite==4 or self.nSprite==2)) then return false end
  if not square:hasFloor(self.north) then
    local belowSQ = getCell():getGridSquare(square:getX(), square:getY(), square:getZ()-1)
    if belowSQ then
      if self.north and not belowSQ:HasStairsWest() then return false end
      if not self.north and not belowSQ:HasStairsNorth() then return false end
    end
  end
  return true
end



---
--- Checks whether the square on which the wall is placed have
--- a man-made flooring or not.
--- @return int Object index on target square or -1 if no flooring found
---
function ISWall:getObjectIndex()
  return ISWoodenWall.getObjectIndex(self)
end