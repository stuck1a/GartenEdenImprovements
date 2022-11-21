--[[
--- @class ExtBuildingBuildAction : ISBuildAction
ExtBuildingBuildAction = ISBuildAction:derive('ExtBuildingBuildAction')


---
--- LuaObject Constructor
---
function ExtBuildingBuildAction:new(character, item, x, y, z, north, spriteName, time)
  return ISBuildAction:new(character, item, x, y, z, north, spriteName, time)
end



---
--- Checks if the action can be done
---
function ExtBuildingBuildAction:isValid()
  return true
end



---
--- Triggered every game tick while actively
--- performing the timed action
---
function ExtBuildingBuildAction:update()
  print('Timed Action ExtBuildingBuildAction updated')
end



---
--- Actions which will be performed after initializing
--- the timed action and the actual beginning of it
---
function ExtBuildingBuildAction:waitToStart()
  self.character:faceThisObject(self.generator)
  return self.character:shouldBeTurning()
end



---
--- Triggered when the timed action starts
---
function ExtBuildingBuildAction:start()
  self.character:getEmitter():playSound('PZ_Hammer')
  self.character:faceThisObject(self.generator)
  self:setActionAnim('Build')
end



---
--- Triggered if the timed action is canceled
---
function ExtBuildingBuildAction:stop()
  print('Timed Action ExtBuildingBuildAction completed aborted')
  ISBaseTimedAction.stop(self)
end



---
--- Triggered if the action is completed
---
function ExtBuildingBuildAction:perform()
  print('Timed Action ExtBuildingBuildAction completed')
  ISBaseTimedAction.perform(self)
end
--]]