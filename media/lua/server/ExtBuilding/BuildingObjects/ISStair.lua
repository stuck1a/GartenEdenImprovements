if not 'ISExtBuildingObject' then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end

--- @class ISStair : ISExtBuildingObject
ISStair = ISExtBuildingObject:derive('ISStair')


ISStair.defaults = {
  buildTime = 1000,
  baseHealth = 500,
  displayName = 'Stair',
  isoData = { isoName = 'stair' },
  properties = {
    dismantable = true,
    blockAllTheSquare = true
  }
}



function ISStair:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite, true)
  local square1 = self:addSquareObject(self.sq, 0, north, sprite, self)
  buildUtil.setInfo(square1, self)
  -- add sprite 2 and 3
  local sprite2, sprite3, x2, x3, y2, y3 = self.northSprite2, self.northSprite3, x, x, y, y
  if north then
    y2 = y2 - 1
    y3 = y3 - 2
  else
    sprite2 = self.sprite2
    sprite3 = self.sprite3
    x2 = x2 - 1
    x3 = x3 - 2
  end
  local square2 = getCell():getGridSquare(x2, y2, z)
  if square2 == nil then
    square2 = IsoGridSquare.new(getCell(), nil, x2, y2, z)
    getCell():ConnectNewSquare(square2, false)
  end
  self:addSquareObject(square2, 1, north, sprite2, self)
  local square3 = getCell():getGridSquare(x3, y3, z)
  if square3 == nil then
    square3 = IsoGridSquare.new(getCell(), nil, x3, y3, z)
    getCell():ConnectNewSquare(square3, false)
  end
  self:addSquareObject(square3, 2, north, sprite3, self)
end



function ISStair:addSquareObject(square, level, north, sprite, luaobject)
  local pillarSprite = luaobject.pillar
  if north then pillarSprite = luaobject.pillarNorth end
  local stairTile = square:AddStairs(north, level, sprite, pillarSprite, luaobject)
  square:RecalcAllWithNeighbours(true)
  stairTile:setName(luaobject.displayName)
  stairTile:setMaxHealth(luaobject:getHealth(luaobject.mainMaterial, luaobject.baseHealth))
  stairTile:setHealth(stairTile:getMaxHealth())
  stairTile:setBreakSound(luaobject.breakSound)
  stairTile:setThumpSound(luaobject.thumpSound)
  stairTile:setSpecialTooltip(luaobject.hasSpecialTooltip)
  stairTile:setIsStairs(true)
  stairTile:setModData(copyTable(luaobject.modData))
  stairTile:transmitCompleteItemToServer()
  return stairTile
end



function ISStair:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



function ISStair:isValid(square)
  if not ISExtBuildingObject.isValid(self, square) then return false end
  -- TOOPTIMIZE: fix buggy vanilla validation (doesn't work against crossed stairs, possibly also not for other types with connected tiles)
  if not ISWoodenStairs.isValid(self, square) then return false end
 return true
end



function ISStair:render(x, y, z, square)
  -- TOOPTIMIZE: fixed buggy vanilla renderer (only renders tile1 and tile2)
  ISWoodenStairs.render(self, x, y, z, square)
end



function ISStair:getSquare2Pos(square, north)
  local x, y, z = square:getX(), square:getY(), square:getZ()
  if north then y = y - 1 else x = x - 1 end
  return x, y, z
end



function ISStair:getSquare3Pos(square, north)
  local x, y, z = square:getX(), square:getY(), square:getZ()
  if north then y = y - 2 else x = x - 2 end
  return x, y, z
end



function ISStair:getSquareTopPos(square, north)
  local x, y, z = square:getX(), square:getY(), square:getZ()
  if north then y = y - 3 else x = x - 3 end
  return x, y, z + 1
end