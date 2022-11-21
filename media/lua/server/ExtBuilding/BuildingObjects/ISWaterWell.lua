if not 'ISExtBuildingObject' then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end


--- @class ISWaterWell : ISExtBuildingObject
ISWaterWell = ISExtBuildingObject:derive('ISWaterWell')

-- Building type defaults
ISWaterWell.defaults = {
  displayName = 'ContextMenu_ExtBuilding_Obj__WaterWell',
  name = 'Water Well',
  buildTime = 500,
  baseHealth = 600,
  mainMaterial = 'stone',
  hasSpecialTooltip = true,
  tooltipDesc = 'Tooltip_ExtBuilding__WaterWell',
  sprites = {
    sprite = 'garteneden_tech_01_0',
    north = 'garteneden_tech_01_1'
  },
  isoData = {
    systemName = 'waterwell',
    objectModDataKeys = { 'waterAmount', 'waterMax' },
  },
  --properties = {
  --  waterAmount = 50,
  --  waterMax = 5000,
  --},
  modData = {
    ['keep:' .. UtilsSrv.ConcatItemTypes({'Hammer'})] = 'Base.Hammer',
    ['keep:' .. UtilsSrv.ConcatItemTypes({'Saw'})] = 'Base.Saw',
    ['keep:' .. UtilsSrv.ConcatItemTypes({'DigGrave'})] = 'Base.Shovel',
    ['need:Base.Rope'] = 5,
    ['need:Base.Plank'] = 5,
    ['need:Base.Nails'] = 10,
    ['use:Base.Gravelbag'] = 8,
    ['need:Base.BucketEmpty'] = 1,
    ['requires:Woodwork'] = 7,
    ['requires:Fitness'] = 5,
    ['xp:Woodwork'] = 5,
    ['xp:Fitness'] = 5
  }
}

ISWaterWell.initialValues = {
  waterAmount = 50,
  waterMax = 5000
}



---
--- Java object constructor - initializes and places a completed water well
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from west to east)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether the north sprite was chosen
--- @param sprite string Name of the chosen sprite
---
function ISWaterWell:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite)
  self.javaObject:setName(self.name)
  self.javaObject:getModData()['waterMax'] = self.waterMax
  self.javaObject:getModData()['waterAmount'] = self.initialValues.waterAmount
  self.javaObject:transmitCompleteItemToServer()
  if getCore():getGameMode() ~= 'Multiplayer' then triggerEvent('OnObjectAdded', self.javaObject) end
end



---
--- Lua object constructor - generates a new water well
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
--- @return ISWaterWell BuildingObject instance
---
function ISWaterWell:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  o.waterMax = self.initialValues.waterMax
  return o
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean True, if well can be placed on current target square
---
function ISWaterWell:isValid(square)
  -- base rules (valid, walkable, free space, reachable, solid ground, etc)
  if not ISExtBuildingObject.isValid(self, square) then return false end
  -- only on surface
  if not getSpecificPlayer(self.player):getZ() == 0 then return false end
  -- not under stairs
  if buildUtil.stairIsBlockingPlacement(square, true) then return false end
  -- tile must have any exterior, natural ground (except water)
  for i=1, square:getObjects():size() do
    local props = square:getProperties()
    if props:Is(IsoFlagType.water) then return false end
    local obj = square:getObjects():get(i-1)
    local textureName = obj:getTextureName() or 'occupied'
    if (not luautils.stringStarts(textureName, 'floors_exterior_natur')) and (not luautils.stringStarts(textureName, 'blends_natur')) then return false end
  end
  return true
end



---
--- Creates the hover tooltip for wells showing an amount bar if near enough
--- @param tooltipUI UIElement Tooltip factory
--- @param square IsoGridSquare Clicked square
---
local function DoSpecialTooltip(tooltipUI, square)
  local oPlayer = getSpecificPlayer(0)
  if not oPlayer or oPlayer:getZ() ~= square:getZ() or oPlayer:DistToSquared(square:getX() + 0.5, square:getY() + 0.5) > 4 then return end
  local oIsoWell = CWaterWellSystem.instance:getIsoObjectOnSquare(square)
  if not oIsoWell or not oIsoWell:getModData()['waterMax'] then return end
  local font = UIFont.Small
  local fontHeight = getTextManager():getFontFromEnum(font):getLineHeight()
  tooltipUI:setHeight(6 + fontHeight + 6 + fontHeight + 12)
  local textX, textY = 12, 6 + fontHeight + 6
  local barWid, barHgt = 80, 4
  local barX = textX + getTextManager():MeasureStringX(font, getText('IGUI_invpanel_Remaining')) + 12
  local barY = textY + (fontHeight - barHgt) / 2 + 2
  tooltipUI:setWidth(barX + barWid + 12)
  tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
  tooltipUI:DrawTextCentre(getText(ISWaterWell.defaults.displayName), tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
  tooltipUI:DrawText(getText('IGUI_invpanel_Remaining'), textX, textY, 1, 1, 1, 1)
  local percent = oIsoWell:getWaterAmount() / oIsoWell:getModData()['waterMax']
  if percent < 0 then percent = 0 end
  if percent > 1 then percent = 1 end
  local amountWidth = math.floor(barWid * percent)
  if percent > 0 then amountWidth = math.max(amountWidth, 1) end
  tooltipUI:DrawTextureScaledColor(nil, barX, barY, amountWidth, barHgt, 0, 0.6, 0, 0.7)
  tooltipUI:DrawTextureScaledColor(nil, barX + amountWidth, barY, barWid - amountWidth, barHgt, 0.15, 0.15, 0.15, 1)
end



local function loadGlobalObject(isoObject)
  if not instanceof(isoObject, ISWaterWell.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) then return end
  SWaterWellSystem.instance:loadIsoObject(isoObject)
end


Events.DoSpecialTooltip.Add(DoSpecialTooltip)
MapObjects.OnLoadWithSprite(ISWaterWell.defaults.sprites.sprite, loadGlobalObject, ISWaterWell.defaults.isoData.mapObjectPriority or ISExtBuildingObject.defaults.isoData.mapObjectPriority)