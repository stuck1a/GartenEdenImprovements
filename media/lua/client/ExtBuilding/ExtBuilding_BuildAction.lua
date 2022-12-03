require 'TimedActions/ISBaseTimedAction'


---@class ISExtBuildAction : ISBuildAction
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
--- Removes the construction site tile object
---
local function removeConstructionSite(isoTile)
  local square = isoTile:getSquare()
  local specialTiles = square:getSpecialObjects()
  for i=0, specialTiles:size()-1 do
    if specialTiles:get(i) == isoTile then
      square:RemoveTileObject(isoTile)
      isoTile = nil
      return
    end
  end
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
--- @param isoTile IsoObject Construction site tile overlay
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
  if self.soundMap == nil then init() end
  o.isoTile = isoTile
  return o
end



---
--- Executed in every action process quantum
--- Alternates sounds
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



---
--- Called when the action is done
---
function ISExtBuildAction:perform()
  if self.tool2 and self.tool2 == 'HammerStone' then
    local oTool = self.character:getSecondaryHandItem()
    if oTool ~= nil and ZombRand(oTool:getConditionLowerChance()) == 0 then
      oTool:setCondition(oTool:getCondition() - 1)
      ISWorldObjectContextMenu.checkWeapon(self.character)
    end
  end
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
  ISBuildAction.perform(self)
end



---
--- Called if the the action gets interrupted
---
function ISExtBuildAction:stop()
  ISBuildAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end



--
-- Overloaded versions of all possible additional actions which might be used while
-- building something. Stores a pointer to the construction site tile object
-- and adds an additional call to remove it if an action becomes interrupted.
--
 ---@class ISExtInventoryTransferAction : ISInventoryTransferAction
ISExtInventoryTransferAction = ISInventoryTransferAction:derive('ISExtInventoryTransferAction')
function ISExtInventoryTransferAction:new(character, item, srcContainer, destContainer, isoTile)
  local o = ISInventoryTransferAction:new(character, item, srcContainer, destContainer)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtInventoryTransferAction:stop()
  ISInventoryTransferAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtWearClothing : ISWearClothing
ISExtWearClothing = ISWearClothing:derive('ISExtWearClothing')
function ISExtWearClothing:new(character, item, time, isoTile)
  local o = ISWearClothing:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtWearClothing:stop()
  ISWearClothing.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtClothingExtraAction : ISClothingExtraAction
ISExtClothingExtraAction = ISClothingExtraAction:derive('ISExtClothingExtraAction')
function ISExtClothingExtraAction:new(character, item, extra, isoTile)
  local o = ISClothingExtraAction:new(character, item, extra)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtClothingExtraAction:stop()
  ISClothingExtraAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtUnequipAction : ISUnequipAction
ISExtUnequipAction = ISUnequipAction:derive('ISExtUnequipAction')
function ISExtUnequipAction:new(character, item, time, isoTile)
  local o = ISUnequipAction:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtUnequipAction:stop()
  ISUnequipAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtEquipWeaponAction : ISEquipWeaponAction
ISExtEquipWeaponAction = ISEquipWeaponAction:derive('ISExtEquipWeaponAction')
function ISExtEquipWeaponAction:new(character, item, time, primary, twoHands, isoTile)
  local o = ISEquipWeaponAction:new(character, item, time, primary, twoHands)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtEquipWeaponAction:stop()
  ISEquipWeaponAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtGrabItemAction : ISGrabItemAction
ISExtGrabItemAction = ISGrabItemAction:derive('ISExtGrabItemAction')
function ISExtGrabItemAction:new(character, item, time, isoTile)
  local o = ISGrabItemAction:new(character, item, time)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtGrabItemAction:stop()
  ISGrabItemAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end


 ---@class ISExtWalkToTimedAction : ISWalkToTimedAction
ISExtWalkToTimedAction = ISWalkToTimedAction:derive('ISExtWalkToTimedAction')
function ISExtWalkToTimedAction:new(character, location, isoTile)
  local o = ISWalkToTimedAction:new(character, location)
  setmetatable(o, self)
  self.__index = self
  o.isoTile = isoTile
  return o
end
function ISExtWalkToTimedAction:stop()
  ISWalkToTimedAction.stop(self)
  if self.isoTile ~= nil then removeConstructionSite(self.isoTile) end
end





-- ---------------------------------------------------------------


---@class ISExtTimedActionQueue : ISTimedActionQueue
ISExtTimedActionQueue = ISTimedActionQueue:derive('ISExtTimedActionQueue')


ISExtTimedActionQueue.queues = ISTimedActionQueue.queues


function ISExtTimedActionQueue:new(character)
  local o = ISTimedActionQueue:new(character)
  setmetatable(o, self)
  self.__index = self
  o.character = character
  o.queue = {}
  ISExtTimedActionQueue.queues[character] = o
  return o
end



function ISExtTimedActionQueue:addToQueue(action)
  local count = #self.queue
  table.insert(self.queue, action)
  if count == 0 then
    self.current = action
    action:begin()
  end
end



function ISExtTimedActionQueue:indexOf(action)
  for i,v in ipairs(self.queue) do
    if v == action then return i end
  end
  return -1
end



function ISExtTimedActionQueue:removeFromQueue(action)
  local i = self:indexOf(action)
  if i ~= -1 then
    table.remove(self.queue, i)
  end
end



function ISExtTimedActionQueue.getTimedActionQueue(character)
  local queue = ISExtTimedActionQueue.queues[character]
  if queue == nil then queue = ISExtTimedActionQueue:new(character) end
  return queue
end



function ISExtTimedActionQueue.add(action)
  if action.ignoreAction then return end
  if instanceof(action.character, 'IsoGameCharacter') and action.character:isAsleep() then return end
  local queue = ISExtTimedActionQueue.getTimedActionQueue(action.character)
  local current = queue.queue[1]
  if current and (current.Type == 'ISQueueActionsAction') and current.isAddingActions then
    table.insert(queue.queue, current.indexToAdd, action)
    current.indexToAdd = current.indexToAdd + 1
    return queue
  end
  queue:addToQueue(action)
  return queue
end



function ISExtTimedActionQueue:tick()
  local action = self.queue[1]
  if action == nil then
    self:clearQueue()
    return
  end
  if not action.character:getCharacterActions():contains(action.action) then
    if action.isoTile ~= nil then removeConstructionSite(action.isoTile) end
    self:resetQueue()
    return
  end
  if action.action:hasStalled() then
    self:onCompleted(action)
    return
  end
end



function ISExtTimedActionQueue.queueActions(character, addActionsFunction, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
  local action = ISQueueActionsAction:new(character, addActionsFunction, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
  return ISExtTimedActionQueue.add(action)
end



function ISExtTimedActionQueue:onCompleted(action)
  self:removeFromQueue(action)
  self.current = self.queue[1]
  if self.current then
    self.current:begin() else
    if action.isoTile ~= nil then removeConstructionSite(action.isoTile) end
  end
end



function ISExtTimedActionQueue:clearQueue()
  table.wipe(self.queue)
end



function ISExtTimedActionQueue:resetQueue()
  table.wipe(self.queue)
  self.current = nil
end



function ISExtTimedActionQueue.addAfter(previousAction, action)
  if action.ignoreAction then return nil end
  if instanceof(action.character, 'IsoGameCharacter') and action.character:isAsleep() then return nil end
  local queue = ISExtTimedActionQueue.getTimedActionQueue(action.character)
  local i = queue:indexOf(previousAction)
  if i ~= -1 then
    table.insert(queue.queue, i + 1, action)
    return queue,action
  end
  return nil
end



function ISExtTimedActionQueue.hasAction(action)
  if action == nil then return false end
  local queue = ISExtTimedActionQueue.queues[action.character]
  if queue == nil then return false end
  return queue:indexOf(action) ~= -1
end



function ISExtTimedActionQueue.clear(character)
  character:StopAllActionQueue()
  local queue = ISExtTimedActionQueue.getTimedActionQueue(character)
  queue:clearQueue()
  return queue
end


function ISExtTimedActionQueue.onTick()
  for _,queue in pairs(ISExtTimedActionQueue.queues) do queue:tick() end
end


Events.OnTick.Add(ISExtTimedActionQueue.onTick)