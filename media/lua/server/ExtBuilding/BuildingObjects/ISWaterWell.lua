require 'ISExtBuildingObject'


--- @class ISWaterWell : ISExtBuildingObject
ISWaterWell = ISExtBuildingObject:derive('ISWaterWell')

-- default class field values
ISWaterWell._buildTime = 500
ISWaterWell._baseHealth = 600
ISWaterWell._mainMaterial = 'stone'
ISWaterWell._breakSound = 'BreakObject'
ISWaterWell._tooltipDesc = 'Tooltip_ExtBuilding__WaterWell'
ISWaterWell._sprites = {
  sprite = 'garteneden_tech_01_0',
  north = 'garteneden_tech_01_1'
}

ISWaterWell._properties = {
  waterMax = 3000,
  waterAmount = 50
}

ISWaterWell._modData = {
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
  self.javaObject:getModData()['waterMax'] = self.waterMax
  self.javaObject:getModData()['waterAmount'] = self.waterAmount
  self.javaObject:transmitCompleteItemToServer()
  triggerEvent('OnObjectAdded', self.javaObject)
end



---
--- Lua object constructor - generates a new water well
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
--- @return ISWaterWell
---
function ISWaterWell:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
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


--[[
---
--- DoSpecialTooltip-EventListener
--- Creates global context menu entries for global objects of type waterwell
--- @param tooltipUI UIElement Java tooltip factory
--- @param square IsoGridSquare Clicked square
---
function ISWaterWell.DoSpecialTooltip(tooltipUI, square)
  local playerObj = getSpecificPlayer(0)
  if not playerObj or playerObj:getZ() ~= square:getZ() or playerObj:DistToSquared(square:getX() + 0.5, square:getY() + 0.5) > 2 * 2 then return end
  local oIsoWell = CWaterWellSystem.instance:getIsoObjectOnSquare(square)
  if not oIsoWell or not oIsoWell:getModData()['waterMax'] then return end
  local font = UIFont.Small
  local smallFontHgt = getTextManager():getFontFromEnum(font):getLineHeight()
  tooltipUI:setHeight(6 + smallFontHgt + 6 + smallFontHgt + 12)
  local textX, textY = 12, 6 + smallFontHgt + 6
  local barWid, barHgt = 80, 4
  local barX = textX + getTextManager():MeasureStringX(font, getText('IGUI_invpanel_Remaining')) + 12
  local barY = textY + (smallFontHgt - barHgt) / 2 + 2
  tooltipUI:setWidth(barX + barWid + 12)
  tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
  tooltipUI:DrawTextCentre(getText('ContextMenu_ExtBuilding_Obj__WaterWell'), tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
  tooltipUI:DrawText(getText('IGUI_invpanel_Remaining') .. ':', textX, textY, 1, 1, 1, 1)
  local percent = oIsoWell:getWaterAmount() / oIsoWell:getModData()['waterMax']
  if percent < 0 then percent = 0 end
  if percent > 1 then percent = 1 end
  local done = math.floor(barWid * percent)
  if percent > 0 then done = math.max(done, 1) end
  tooltipUI:DrawTextureScaledColor(nil, barX, barY, done, barHgt, 0, 0.6, 0, 0.7)
  tooltipUI:DrawTextureScaledColor(nil, barX + done, barY, barWid - done, barHgt, 0.15, 0.15, 0.15, 1)
end

Events.DoSpecialTooltip.Add(ISWaterWell.DoSpecialTooltip)
--]]
