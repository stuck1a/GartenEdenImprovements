require 'TimedActions/ISBaseTimedAction'

--- @class ISExtBuildAction : ISBuildAction
ISExtBuildAction = ISBuildAction:derive('ISExtBuildAction')


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
    -- Further vanilla item tags - let's see which one might be useful or not later on...
    --['Fork'] = 'BuildingGeneric',
    --['Scissors'] = 'BuildingGeneric',
    --['Spoon'] = 'BuildingGeneric',
    --['FishingSpear'] = 'BuildingGeneric',
    --['Digital'] = 'BuildingGeneric',       -- digital watches (no analogue ones)
    --['GasMask'] = 'BuildingGeneric',
    --['WeldingMask'] = 'BuildingGeneric',
    --['HeavyItem'] = 'BuildingGeneric',     -- generator only in vanilla
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
--- @return ISExtBuildAction Timed action class object for building the structure
---
function ISExtBuildAction:new(character, item, x, y, z, north, spriteName, time, tool1, tool2)
  local o = ISBuildAction.new(self, character, item, x, y, z, north, spriteName, time)
  setmetatable(o, self)
  self.__index = self
  if type(tool1) == 'string' and string.find(tool1, '.') then tool1 = luautils.split(tool1, '.')[2] end
  if type(tool2) == 'string' and string.find(tool2, '.') then tool2 = luautils.split(tool2, '.')[2] end
  tool1 = tool1 or tool2
  tool2 = tool2 or tool1
  if self.soundMap == nil then init() end
  o.toolSound1 = self.soundMap[tool1] or self.soundMap[tool2] or false
  o.toolSound2 = self.soundMap[tool2] or self.soundMap[tool1] or false
  o.shallPlay1 = true
  o.shallPlay2 = false
  return o
end



---
--- Executed in every action process quantum
--- Alternates sounds tool1 and tool2 and additionally
--- overlays soundBank, if given. Also forces to face the
--- object and fixes the metabolic target.
---
function ISExtBuildAction:update()
  if self.toolSound1 then
    local worldSoundRadius = 0
    if self.soundTime + ISBuildAction.soundDelay < getTimestamp() then
      self.soundTime = getTimestamp()
      local isPlaying1 = self.character:getEmitter():isPlaying(self.toolSound1)
      local isPlaying2 = self.character:getEmitter():isPlaying(self.toolSound2)
      if not isPlaying1 and not isPlaying2 then
        worldSoundRadius = math.ceil(20 * self.character:getHammerSoundMod())
        if self.shallPlay1 then
          self.toolSound1Pointer = self.character:getEmitter():playSound(self.toolSound1)
          self.shallPlay1 = false
          self.shallPlay2 = true
        else
          self.toolSound2Pointer = self.character:getEmitter():playSound(self.toolSound2)
          self.shallPlay1 = true
          self.shallPlay2 = false
        end
      end
      if self.craftingBank then
        local playingCrafting = self.craftingSound ~= 0 and self.character:getEmitter():isPlaying(self.craftingSound)
        if not playingCrafting then self.craftingSound = self.character:getEmitter():playSound(self.craftingBank) end
      end
    end
    if worldSoundRadius > 0 then
      ISBuildAction.worldSoundTime = getTimestamp()
      addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), worldSoundRadius, worldSoundRadius)
    end
  end
  self.character:setMetabolicTarget(Metabolics.HeavyWork)
  self:faceLocation()
end



function ISExtBuildAction:start()
  ISBuildAction.start(self)
  --self.setOverrideHandModels(self, self.character:getPrimaryHandItem(), self.character:getSecondaryHandItem())
end




---
--- Executed once if the action ends anyhow.
--- Will stop any action sound which might currently playing.
--- Further resets the ghost sprite and executes the stop callback
--- of the building, if any. Finally the action queue will be reset,
--- since this will always be the last action in queue.
---
function ISExtBuildAction:stop()
  self.item:onTimedActionStop(self)
  self.item.ghostSprite = nil
  if self.toolSound1 and self.toolSound1Pointer ~= nil and self.character:getEmitter():isPlaying(self.toolSound1) then
    self.character:getEmitter():stopSound(self.toolSound1Pointer)
  end
  if self.toolSound2 and self.toolSound2Pointer ~= nil and self.character:getEmitter():isPlaying(self.toolSound2) then
    self.character:getEmitter():stopSound(self.toolSound2Pointer)
  end
  if self.craftingSound and self.character:getEmitter():isPlaying(self.craftingSound) then
    self.character:stopOrTriggerSound(self.craftingSound)
  end
  ISBaseTimedAction.stop(self)
end



---
--- Called when the action is completed
---
function ISExtBuildAction:perform()
  self.item.ghostSprite = nil
  if self.toolSound1 and self.toolSound1Pointer ~= nil and self.character:getEmitter():isPlaying(self.toolSound1) then
    self.character:getEmitter():stopSound(self.toolSound1Pointer)
  end
  if self.toolSound2 and self.toolSound2Pointer ~= nil and self.character:getEmitter():isPlaying(self.toolSound2) then
    self.character:getEmitter():stopSound(self.toolSound2Pointer)
  end
  if self.craftingSound and self.character:getEmitter():isPlaying(self.craftingSound) then
    self.character:stopOrTriggerSound(self.craftingSound)
  end
  if self.tool2 and self.tool2 == 'HammerStone' then
    local oTool = self.character:getSecondaryHandItem()
    if oTool ~= nil and ZombRand(oTool:getConditionLowerChance()) == 0 then
      oTool:setCondition(oTool:getCondition() - 1)
      ISWorldObjectContextMenu.checkWeapon(self.character)
    end
  end
  ISBuildAction.perform(self)
end