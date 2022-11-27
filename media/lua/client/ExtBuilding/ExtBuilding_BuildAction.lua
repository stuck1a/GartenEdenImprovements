require 'TimedActions/ISBaseTimedAction'

---@class ISExtBuildAction : ISBuildAction
ISExtBuildAction = ISBuildAction:derive('ISExtBuildAction')


-- ISExtBuildAction.soundDelay = 6
ISExtBuildAction.worldSoundTime = ISBuildAction.worldSoundTime



-- TODO: Use existing ItemTags to fill the table
local function initSoundMappings()
  ISExtBuildAction.soundMappings = {
    ['Hammer'] = 'Hammering',
    ['ClubHammer'] = 'Hammering',
    ['BallPeenHammer'] = 'Hammering',
    ['WoodenMallet'] = 'Hammering',
    ['HammerStone'] = 'Hammering',
    ['Sledgehammer'] = 'Hammering',
    ['Sledgehammer2'] = 'Hammering',
    ['Crowbar'] = 'Hammering',
    ['Saw'] = 'Sawing',
    ['GardenSaw'] = 'Sawing',
    ['Shovel'] = 'Shoveling',
    ['Shovel2'] = 'Shoveling',
    ['SnowShovel'] = 'Shoveling',
    ['Axe'] = 'ChopTree',
    ['AxeStone'] = 'ChopTree',
    ['PickAxe'] = 'ChopTree',
    ['HandAxe'] = 'ChopTree',
    ['WoodAxe'] = 'ChopTree',
    ['Wrench'] = 'RepairWithWrench',
    ['LugWrench'] = 'RepairWithWrench',
    ['PipeWrench'] = 'RepairWithWrench',
    ['KitchenKnife'] = 'SliceBread',
    ['HuntingKnife'] = 'SliceBread',
    ['MeatCleaver'] = 'SliceBread',
    ['HandScythe'] = 'SliceBread',
    ['BlowTorch'] = 'BlowTorch',
    ['Screwdriver'] = 'Screwdriver',
    ['Paintbrush'] = 'Painting'
  }
end




function ISExtBuildAction:isReachableThroughWindow(_square)
  return ISBuildAction.isReachableThroughWindow(self, _square)
  --local objects = _square:getObjects()
  --for i=0, objects:size()-1 do
  --  local object = objects:get(i)
  --  if object and instanceof(object, 'IsoWindow') then
  --    local curtains = object:HasCurtains()
  --    if curtains then
  --      if curtains:IsOpen() then
  --        if object:canClimbThrough(self.character) then return true end
  --      end
  --    else
  --      if object:canClimbThrough(self.character) then return true end
  --    end
  --  end
  --end
  --return false
end



function ISExtBuildAction:isValid()
  return ISBuildAction.isValid(self)
  --local plSquare = self.character:getSquare()
  --if (plSquare and self.square) and (plSquare:getZ() == self.square:getZ()) then
  --  if self.square:isSomethingTo(plSquare) then
  --    if (not luautils.isSquareAdjacentToSquare(plSquare, self.square)) then
  --      self:stop()
  --      return false
  --    end
  --    if not (self:isReachableThroughWindow(self.square) or self:isReachableThroughWindow(plSquare)) then
  --      self:stop()
  --      return false
  --    end
  --  end
  --else
  --  self:stop()
  --  return false
  --end
  --if not self.item.noNeedHammer and self.hammer then return self.hammer:getCondition() > 0 end
  --return true
end



function ISExtBuildAction:waitToStart()
  return ISBuildAction.waitToStart(self)
  --if ISBuildMenu.cheat then return false end
  --self:faceLocation()
  --return self.character:shouldBeTurning()
end



function ISExtBuildAction:update()

  print('CALLED ISExtBuildingAction:update()')
  local worldSoundRadius = 0
  if self.soundTime + ISBuildAction.soundDelay < getTimestamp() then
    self.soundTime = getTimestamp()
    local playingSaw = self.sawSound ~= 0 and self.character:getEmitter():isPlaying(self.sawSound)
    local playingHammer = self.hammerSound ~= 0 and self.character:getEmitter():isPlaying(self.hammerSound)
    if not playingSaw and not playingHammer then
      if self.doSaw == true and self.tool1 ~= nil and ISExtBuildingAction.soundMappings[self.tool1] ~= nil then
        self.sawSound = self.character:getEmitter():playSound(ISExtBuildingAction.soundMappings[self.tool1])
        worldSoundRadius = 15
        self.doSaw = false
      elseif self.tool2 ~= nil and ISExtBuildingAction.soundMappings[self.tool2] ~= nil then
        self.hammerSound = self.character:getEmitter():playSound(ISExtBuildingAction.soundMappings[self.tool2])
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



function ISExtBuildAction:start()
  ISBuildAction.start(self)
  --if not self.item.noNeedHammer then
  --  self.sawSound = 0
  --  self.hammer = self.character:getPrimaryHandItem()
  --  self.hammerSound = 0
  --end
  --if self.craftingBank then self.craftingSound = 0 end
  --self.soundTime = 0
  --self.item.ghostSprite = IsoSprite.new()
  --self.item.ghostSprite:LoadFramesNoDirPageSimple(self.spriteName)
  --self.item.ghostSpriteX = self.x
  --self.item.ghostSpriteY = self.y
  --self.item.ghostSpriteZ = self.z
  --self.item:onTimedActionStart(self)
end



function ISExtBuildAction:stop()
  ISBuildAction.stop(self)
  --self.item:onTimedActionStop(self)
  --self.item.ghostSprite = nil
  --if self.sawSound and self.sawSound ~= 0 and self.character:getEmitter():isPlaying(self.sawSound) then
  --  self.character:getEmitter():stopSound(self.sawSound)
  --end
  --if self.hammerSound and self.hammerSound ~= 0 and self.character:getEmitter():isPlaying(self.hammerSound) then
  --  self.character:getEmitter():stopSound(self.hammerSound)
  --end
  --if self.craftingSound and self.craftingSound ~= 0 and self.character:getEmitter():isPlaying(self.craftingSound) then
  --  self.character:stopOrTriggerSound(self.craftingSound)
  --end
  --ISBaseTimedAction.stop(self)
end



function ISExtBuildAction:perform()
  ISBuildAction.perform(self)
  --self.item.ghostSprite = nil
  --if self.sawSound and self.sawSound ~= 0 and self.character:getEmitter():isPlaying(self.sawSound) then
  --  self.character:getEmitter():stopSound(self.sawSound)
  --end
  --if self.hammerSound and self.hammerSound ~= 0 and self.character:getEmitter():isPlaying(self.hammerSound) then
  --  self.character:getEmitter():stopSound(self.hammerSound)
  --end
  --if self.craftingSound and self.craftingSound ~= 0 and self.character:getEmitter():isPlaying(self.craftingSound) then
  --  self.character:getEmitter():stopSound(self.craftingSound)
  --end
  --local hammer = self.character:getPrimaryHandItem()
  --if hammer and hammer:getType() == 'HammerStone' and ZombRand(hammer:getConditionLowerChance()) == 0 then
  --  hammer:setCondition(hammer:getCondition() - 1)
  --  ISWorldObjectContextMenu.checkWeapon(self.character)
  --end
  --self.item.character = self.character
  --self.item:create(self.x, self.y, self.z, self.north, self.spriteName)
  --self.square:RecalcAllWithNeighbours(true)
  --if self.item.completionSound ~= nil and self.item.completionSound ~= '' then
  --  self.character:playSound(self.item.completionSound)
  --end
  --buildUtil.setHaveConstruction(self.square, true)
  --ISBaseTimedAction.perform(self)
end



function ISExtBuildAction:faceLocation()
  ISBuildAction.faceLocation(self)
  --if self.item.isWallLike then
  --  if self.item.north then
  --    self.character:faceLocationF(self.x + 0.5, self.y)
  --  else
  --    self.character:faceLocationF(self.x, self.y + 0.5)
  --  end
  --else
  --  self.character:faceLocation(self.x, self.y)
  --end
end



function ISExtBuildAction:new(character, item, x, y, z, north, spriteName, time, tool1, tool2)
  local o = ISBuildAction.new(self, character, item, x, y, z, north, spriteName, time)
  setmetatable(o, self)
  self.__index = self
  o.tool1 = tool1
  o.tool2 = tool2
  if self.soundMappings == nil then initSoundMappings() end
  --o.character = character
  --o.item = item
  --o.x = x
  --o.y = y
  --o.z = z
  --o.north = north
  --o.spriteName = spriteName
  --o.stopOnWalk = true
  --o.stopOnRun = true
  --o.maxTime = time
  --o.craftingBank = item.craftingBank
  --if character:HasTrait('Handy') then o.maxTime = time - 50 end
  --o.square = getCell():getGridSquare(x, y, z)
  --o.doSaw = false
  --o.caloriesModifier = 8
  return o
end