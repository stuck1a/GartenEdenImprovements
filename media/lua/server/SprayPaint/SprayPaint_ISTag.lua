require 'BuildingObjects/ISBuildingObject'
Tag = ISBuildingObject:derive('Tag')

---
--- JavaObject constructor
--- Will place the tag on the cell in its special object layer
---
function Tag:create(x, y, z, north, sprite)
  if not self.playerObject:isEquipped(self.sprayCanItem) then
    self:reset()
  elseif math.floor(self.sprayCanItem:getUsedDelta() / self.sprayCanItem:getUseDelta()) > 0 then
    local cell = getWorld():getCell()
    local gridSquare = cell:getGridSquare(x, y, z)
    local tagTile = IsoObject.new(gridSquare, sprite, 'Tag')
    local isoObjectModData = tagTile:getModData()
    isoObjectModData['isTag'] = 'true'
    isoObjectModData['lastRainCheck'] = getGameTime():getWorldAgeHours()
    isoObjectModData['isChalk'] = self.isChalk
    isoObjectModData['red'] = self.red
    isoObjectModData['green'] = self.green
    isoObjectModData['blue'] = self.blue
    local colorInfo = ColorInfo.new(self.red, self.green, self.blue, 1.0)
    tagTile:getSprite():setTintMod(colorInfo)
    gridSquare:AddTileObject(tagTile)
    if isClient() then
      tagTile:transmitCompleteItemToServer()
    else
      tagTile:transmitCompleteItemToClients()
    end
    -- Use paint, so decreasing quantity of paint in spraycan
    self.sprayCanItem:Use()
  else
    self.playerObject:Say('UI_SprayPaint_CanIsEmpty')
    ISTimedActionQueue.add(ISUnequipAction:new(self.playerObject, self.sprayCanItem, 50))
  end
end


---
--- Test if it's possible to place a symbol where the ghost tile is located
---
function Tag:isValid(square, north)
  if not square then return false end
  if square:isSolid() or square:isSolidTrans() then return false end
  if square:HasStairs() then return false end
  if square:HasTree() then return false end
  if not square:getMovingObjects():isEmpty() then return false end
  if not square:TreatAsSolidFloor() then return false end
  if square:isVehicleIntersecting() then return false end
  for i=1,square:getObjects():size() do
    local props = square:getProperties()
    if props:Is(IsoFlagType.water) then return false end
  end
  --  Special object layer must be yet unused
  if square:getSpecialObjects():size() == 0 then return false end
  return true
end


function Tag:render(x, y, z, square, north)
  local sprite = IsoSprite.new()
  local colorInfo = ColorInfo.new(self.red, self.green, self.blue, 1)
  sprite:LoadFramesNoDirPageSimple(self.shape)
  sprite:setTintMod(colorInfo)
  sprite:RenderGhostTile(x, y, z)
  return true
end


---
--- LuaObject constructor
---
function Tag:new(player, sprayCanItem, shape, red, green, blue, isChalk)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o:init()
  o:setSprite(shape)
  o.player = player
  o.playerObject = getSpecificPlayer(player)
  o.sprayCanItem = sprayCanItem;
  o.shape = shape
  o.red = red
  o.green = green
  o.blue = blue
  o.isChalk = isChalk
  o.maxTime = 10
  o.noNeedHammer = true
  return o
end
