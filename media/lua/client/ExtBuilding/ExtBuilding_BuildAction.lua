require 'TimedActions/ISBaseTimedAction'

---@class ISExtBuildAction : ISBuildAction
ISExtBuildAction = ISBuildAction:derive('ISExtBuildAction')


ISExtBuildAction.soundDelay = ISBuildAction.soundDelay
ISExtBuildAction.worldSoundTime = ISBuildAction.worldSoundTime



-- TODO: Use existing ItemTags to fill the table
local function init()
  ISExtBuildAction.soundMap = {
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
end



function ISExtBuildAction:isValid()
  return ISBuildAction.isValid(self)
end



function ISExtBuildAction:waitToStart()
  return ISBuildAction.waitToStart(self)
end



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



function ISExtBuildAction:start()
  ISBuildAction.start(self)
end



function ISExtBuildAction:stop()
  ISBuildAction.stop(self)
end



function ISExtBuildAction:perform()
  ISBuildAction.perform(self)
end



function ISExtBuildAction:faceLocation()
  ISBuildAction.faceLocation(self)
end



function ISExtBuildAction:new(character, item, x, y, z, north, spriteName, time, tool1, tool2)
  local o = ISBuildAction.new(self, character, item, x, y, z, north, spriteName, time)
  setmetatable(o, self)
  self.__index = self
  if type(tool1) == 'string' and string.find(tool1, '.') then tool1 = luautils.split(tool1, '.')[2] end
  if type(tool2) == 'string' and string.find(tool2, '.') then tool2 = luautils.split(tool2, '.')[2] end
  o.tool1 = tool1
  o.tool2 = tool2
  if self.soundMap == nil then init() end
  return o
end