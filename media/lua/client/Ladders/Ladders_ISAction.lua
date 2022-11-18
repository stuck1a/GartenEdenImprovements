local ISLadder = {}
ISLadder.topOfLadder = 'TopOfLadder'

--
-- List of tiles which should be climbable but without the proper
-- flags to recognize them as climbable.
--
ISLadder.tileFlags = {}
ISLadder.tileFlags.location_sewer_01_32 = IsoFlagType.climbSheetW
ISLadder.tileFlags.location_sewer_01_33 = IsoFlagType.climbSheetN
ISLadder.tileFlags.industry_railroad_05_20 = IsoFlagType.climbSheetW
ISLadder.tileFlags.industry_railroad_05_21 = IsoFlagType.climbSheetN
ISLadder.tileFlags.industry_railroad_05_36 = IsoFlagType.climbSheetW
ISLadder.tileFlags.industry_railroad_05_37 = IsoFlagType.climbSheetN
ISLadder.holeTiles = {}
ISLadder.holeTiles.floors_interior_carpet_01_24 = true
ISLadder.poleTiles = {}
ISLadder.poleTiles.recreational_sports_01_32 = true
ISLadder.poleTiles.recreational_sports_01_33 = true


function ISLadder.getLadderObject(square)
  local objects = square:getObjects()
  for i = 0, objects:size() - 1 do
    local object = objects:get(i)
    local sprite = object:getSprite()
    if sprite then
      local prop = sprite:getProperties()
      if prop:Is(IsoFlagType.climbSheetN) or prop:Is(IsoFlagType.climbSheetS) or prop:Is(IsoFlagType.climbSheetE) or prop:Is(IsoFlagType.climbSheetW) then
        return object
      end
    end
  end
end


function ISLadder.setFlags(square, sprite, flag)
  sprite:getProperties():Set(flag)
  square:getProperties():Set(flag)
end


function ISLadder.unsetFlags(square, sprite, flag)
  sprite:getProperties():UnSet(flag)
  square:getProperties():UnSet(flag)
end


function ISLadder.setTopOfLadderFlags(square, sprite, north)
  if north then
    ISLadder.setFlags(square, sprite, IsoFlagType.climbSheetTopN)
    ISLadder.setFlags(square, sprite, IsoFlagType.HoppableN)
  else
    ISLadder.setFlags(square, sprite, IsoFlagType.climbSheetTopW)
    ISLadder.setFlags(square, sprite, IsoFlagType.HoppableW)
  end
end


function ISLadder.addTopOfLadder(square, north)
  local props = square:getProperties()
  if props:Is(IsoFlagType.WallN) or props:Is(IsoFlagType.WallW) or props:Is(IsoFlagType.WallNW) then return end
  local objects = square:getObjects()
  for i = 0, objects:size() - 1 do
    local object = objects:get(i)
    if object:getName() == ISLadder.topOfLadder then
      ISLadder.setTopOfLadderFlags(square, object:getSprite(), north)
      return
    end
  end
  local sprite = IsoSprite.new()
  ISLadder.setTopOfLadderFlags(square, sprite, north)
  object = IsoObject.new(getCell(), square, sprite)
  object:setName(ISLadder.topOfLadder)
  square:transmitAddObjectToSquare(object, -1)
end


function ISLadder.removeTopOfLadder(square)
  local x = square:getX()
  local y = square:getY()
  for z = square:getZ() + 1, 8 do
    local aboveSquare = getSquare(x, y, z)
    if not aboveSquare then return end
    local objects = aboveSquare:getObjects()
    for i = 0, objects:size() - 1 do
      local object = objects:get(i)
      if object:getName() == ISLadder.topOfLadder then
        aboveSquare:transmitRemoveItemFromSquare(object)
        return
      end
    end
  end
end


function ISLadder.makeLadderClimbable(square, north)
  local x, y = square:getX(), square:getY()
  for z = square:getZ(), 8 do
    local aboveSquare = getSquare(x, y, z + 1)
    if not aboveSquare then return end
    local object = ISLadder.getLadderObject(aboveSquare)
    if not object then
      ISLadder.addTopOfLadder(aboveSquare, north)
      break
    end
  end
end


function ISLadder.makeLadderClimbableFromTop(square)
  local x = square:getX()
  local y = square:getY()
  local z = square:getZ() - 1
  local belowSquare = getSquare(x, y, z)
  if belowSquare then
    ISLadder.makeLadderClimbableFromBottom(getSquare(x - 1, y, z))
    ISLadder.makeLadderClimbableFromBottom(getSquare(x + 1, y, z))
    ISLadder.makeLadderClimbableFromBottom(getSquare(x, y - 1, z))
    ISLadder.makeLadderClimbableFromBottom(getSquare(x, y + 1, z))
  end
end


function ISLadder.makeLadderClimbableFromBottom(square)
  if not square then return end
  local objects = square:getObjects()
  for i = 0, objects:size() - 1 do
    local object = objects:get(i)
    local sprite = object:getSprite()
    if sprite then
      local prop = sprite:getProperties()
      if prop:Is(IsoFlagType.climbSheetN) then
        ISLadder.makeLadderClimbable(square, true)
        break
      elseif prop:Is(IsoFlagType.climbSheetW) then
        ISLadder.makeLadderClimbable(square, false)
        break
      end
    end
  end
end


function ISLadder.OnKeyPressed(key)
  if key == getCore():getKey("Interact") then
    local square = getPlayer():getSquare()
    ISLadder.makeLadderClimbableFromTop(square)
    ISLadder.makeLadderClimbableFromBottom(square)
  end
end


function ISLadder.LoadGridsquare(square)
  local objects = square:getObjects()
  for i = 0, objects:size() - 1 do
    local sprite = objects:get(i):getSprite()
    if sprite then
      local name = sprite:getName()
      if ISLadder.tileFlags[name] then
        ISLadder.setFlags(square, sprite, ISLadder.tileFlags[name])
      elseif ISLadder.holeTiles[name] then
        ISLadder.setFlags(square, sprite, IsoFlagType.HoppableW)
        ISLadder.setFlags(square, sprite, IsoFlagType.climbSheetTopW)
        ISLadder.unsetFlags(square, sprite, IsoFlagType.solidfloor)
      elseif ISLadder.poleTiles[name] and square:getZ() == 0 then
        ISLadder.setFlags(square, sprite, IsoFlagType.climbSheetW)
      end
    end
  end
end


-- When a player places a crafted ladder, he won't be able to climb it unless:
-- - the ladder sprite has the proper flags set
-- - the player moves to another chunk and comes back
-- - the player quit and load the saved game
-- - the same sprite was already spawned and went through the LoadGridsquare event
-- To fix this, ISMoveablesAction:perform() will be extended to append an instant update.
local ISMoveablesAction_perform = ISMoveablesAction.perform
function ISMoveablesAction:perform()
  ISMoveablesAction_perform(self)
  if self.mode == 'pickup' then
    ISLadder.removeTopOfLadder(self.square)
  elseif self.mode == 'place' then
    ISLadder.LoadGridsquare(self.square)
    ISLadder.makeLadderClimbableFromBottom(self.square)
  end
end


Events.OnKeyPressed.Add(ISLadder.OnKeyPressed)
Events.LoadGridsquare.Add(ISLadder.LoadGridsquare)
