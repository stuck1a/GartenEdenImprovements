require 'TimedActions/ISBaseTimedAction'

---@class ISExtBuildAction : ISBuildAction
ISExtBuildAction = ISBuildAction:derive('ISExtBuildAction')


ISExtBuildAction.constructionSiteOverlay = 'garteneden_tech_01_2'


---
--- Generates the sound map
---
local function init()
  local type2sound = {
    ['GardenSaw'] = 'Sawing',
    ['Wrench'] = 'RepairWithWrench',
    ['LugWrench'] = 'RepairWithWrench',
    ['PipeWrench'] = 'RepairWithWrench',
    ['BlowTorch'] = 'BlowTorch',
    ['Paintbrush'] = 'Painting',
  }
  local tag2sound = {
    ['Hammer'] = 'Hammering',
    ['Saw'] = 'Sawing',
    ['DigPlow'] = 'Shoveling',
    ['CutPlant'] = 'ChopTree',
    ['ChopTree'] = 'ChopTree',
    ['SharpKnife'] = 'SliceMeat',
    ['Razor'] = 'SliceMeat',
    ['DullKnife'] = 'SliceBread',
    ['Crowbar'] = 'Dismantle',
    ['Sledgehammer'] = 'Dismantle',
    ['MortarPestle'] = 'SliceBread',
    ['Screwdriver'] = 'Screwdriver',
    ['SewingNeedle'] = 'Screwdriver',
    ['EmptyPetrol'] = 'GetWaterFromTapPlasticBig',
    ['CanOpener'] = 'RepairWithWrench',
    --['Fork'] = 'BuildingGeneric',
    --['Scissors'] = 'BuildingGeneric',
    --['Spoon'] = 'BuildingGeneric',
    --['FishingSpear'] = 'BuildingGeneric',
    --['Digital'] = 'BuildingGeneric',       -- digital watches
    --['GasMask'] = 'BuildingGeneric',
    --['WeldingMask'] = 'BuildingGeneric',
    --['HeavyItem'] = 'BuildingGeneric',     -- in vanilla only Generator for now
    --['BrokenGlass'] = 'BuildingGeneric',
    --['Corkscrew'] = 'BuildingGeneric',
  }
  for k,v in pairs(tag2sound) do
    local aItems = getScriptManager():getItemsTag(k)
    for j=0, aItems:size() - 1 do
      local type = aItems:get(j):getName()
      if type then type2sound[type] = v end
    end
  end
  ISExtBuildAction.soundMap = type2sound
end



---
--- Adds or replaces sound names used for specific tools
--- @param soundMap table Mappings to merge - Syntax: {['MyItemType']='MySoundScript',['AxeStone']='ChopTree',...}
--- @param skipExisting boolean Do not overwrite existing entries (Default: false)
---
function ISExtBuildAction.addSoundMapping(soundMap, skipExisting)
  skipExisting = skipExisting or false
  if not ISExtBuildAction.soundMap then init() end
  for k,v in ipairs(soundMap) do
    local type = k
    if (skipExisting == false) or (skipExisting and ISExtBuildAction[type] == nil) then
      if string.find(type, '.') then type = luautils.split(type, '.')[2] end
      ISExtBuildAction.soundMap[type] = v
    end
  end
end



---
--- Constructs a new timed action for constructions
--- @param character IsoPlayer Target player object
--- @param item ISBuildingObject Target building class object
--- @param x int Target squares x coordinate (primary square if multi-tiled)
--- @param y int Target squares x coordinate (primary square if multi-tiled)
--- @param z int Target squares z coordinate  (primary square if multi-tiled)
--- @param north string|boolean Secondary sprite parameter. For most isoObjects it's the rotated sprite
--- @param spriteName string Name of the chosen sprite of the building
--- @param time int Overall duration for required for the building
--- @param tool1 string|nil Item type of the first required tool found, if any
--- @param tool2 string|nil Item type of the second required tool found, if any
--- @param isoTile IsoObject The construction site tile overlay
--- @return ISExtBuildAction Timed action class object for building the structure
---
function ISExtBuildAction:new(character, item, x, y, z, north, spriteName, time, tool1, tool2, isoTile)
  local o = ISBuildAction.new(self, character, item, x, y, z, north, spriteName, time)
  setmetatable(o, self)
  self.__index = self
  if type(tool1) == 'string' and string.find(tool1, '.') then tool1 = luautils.split(tool1, '.')[2] end
  if type(tool2) == 'string' and string.find(tool2, '.') then tool2 = luautils.split(tool2, '.')[2] end
  o.tool1 = tool1
  o.tool2 = tool2
  o.isoTile = isoTile
  if self.soundMap == nil then init() end
  return o
end



---
--- Executed in every action process quantum
--- Alternates sounds and adjusts construction site overlay
---
function ISExtBuildAction:update()
  local worldSoundRadius = 0
  if self.soundTime + ISBuildAction.soundDelay < getTimestamp() then
    self.soundTime = getTimestamp()
    local playingSaw = self.sawSound ~= 0 and self.character:getEmitter():isPlaying(self.sawSound)
    local playingHammer = self.hammerSound ~= 0 and self.character:getEmitter():isPlaying(self.hammerSound)
    if not playingSaw and not playingHammer then
      if self.doSaw == true and self.tool1 ~= nil and ISExtBuildAction.soundMap[self.tool1] ~= nil then
        self.sawSound = self.character:getEmitter():playSound(ISExtBuildAction.soundMap[self.tool1])
        worldSoundRadius = 15
        self.doSaw = false
      elseif self.tool2 ~= nil and ISExtBuildAction.soundMap[self.tool2] ~= nil then
        self.hammerSound = self.character:getEmitter():playSound(ISExtBuildAction.soundMap[self.tool2])
        worldSoundRadius = math.ceil(20 * self.character:getHammerSoundMod())
        self.doSaw = true
      end
    end
    if self.craftingBank then
      local playingCrafting = self.craftingSound ~= 0 and self.character:getEmitter():isPlaying(self.craftingSound)
      if not playingCrafting then self.craftingSound = self.character:getEmitter():playSound(self.craftingBank) end
      worldSoundRadius = 15
    end
  end
  if worldSoundRadius > 0 then
    ISBuildAction.worldSoundTime = getTimestamp()
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), worldSoundRadius, worldSoundRadius)
  end
  self.character:setMetabolicTarget(Metabolics.HeavyWork)
  self:faceLocation()
end



function ISExtBuildAction:stop()
  ISBuildAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end







---@class ISExtInventoryTransferAction : ISInventoryTransferAction
ISExtInventoryTransferAction = ISInventoryTransferAction:derive('ISExtInventoryTransferAction')
function ISExtInventoryTransferAction:new(character, item, srcContainer, destContainer, time, isoTile)
  local o = ISInventoryTransferAction:new(character, item, srcContainer, destContainer, time)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtInventoryTransferAction:stop()
  ISInventoryTransferAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end



---@class ISExtWearClothing : ISWearClothing
ISExtWearClothing = ISWearClothing:derive('ISExtWearClothing')
function ISExtWearClothing:new(character, item, time, isoTile)
  local o = ISWearClothing:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtWearClothing:stop()
  ISWearClothing.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end



---@class ISExtClothingExtraAction : ISClothingExtraAction
ISExtClothingExtraAction = ISClothingExtraAction:derive('ISExtClothingExtraAction')
function ISExtClothingExtraAction:new(character, item, extra, isoTile)
  local o = ISClothingExtraAction:new(character, item, extra)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtClothingExtraAction:stop()
  ISClothingExtraAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end



---@class ISExtUnequipAction : ISUnequipAction
ISExtUnequipAction = ISUnequipAction:derive('ISExtUnequipAction')
function ISExtUnequipAction:new(character, item, time, isoTile)
  local o = ISUnequipAction:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtUnequipAction:stop()
  ISUnequipAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end



---@class ISExtEquipWeaponAction : ISEquipWeaponAction
ISExtEquipWeaponAction = ISEquipWeaponAction:derive('ISExtEquipWeaponAction')
function ISExtEquipWeaponAction:new(character, item, time, primary, twoHands, isoTile)
  local o = ISEquipWeaponAction:new(character, item, time, primary, twoHands)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtEquipWeaponAction:stop()
  ISEquipWeaponAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end



---@class ISExtGrabItemAction : ISGrabItemAction
ISExtGrabItemAction = ISGrabItemAction:derive('ISExtGrabItemAction')
function ISExtGrabItemAction:new(character, item, time, isoTile)
  local o = ISGrabItemAction:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  self.isoTile = isoTile
  return o
end
function ISExtGrabItemAction:stop()
  ISGrabItemAction.stop(self)
  if not ISTimedActionQueue.isPlayerDoingAction(self.character) and self.isoTile then
    self.square:RemoveTileObject(self.isoTile)
  end
end