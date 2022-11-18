require 'BuildingObjects/ISBuildingObject'


--- @class ISExtBuildingObject : ISBuildingObject
ISExtBuildingObject = ISBuildingObject:derive('ISExtBuildingObject')


---
--- Java ISO object constructor - called after completed build action
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from west to east)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether a north sprite was chosen
--- @param sprite string Name of the chosen sprite
---
function ISExtBuildingObject:create(x, y, z, north, sprite)
  local cell = getWorld():getCell()
  self.sq = cell:getGridSquare(x, y, z)
  if self.openSprite ~= nil then
    local openSprite = self.openSprite
    if north then openSprite = self.openNorthSprite end
    self.javaObject = _G[self.isoType].new(cell, self.sq, sprite, openSprite, north, self)
  else
    self.javaObject = _G[self.isoType].new(cell, self.sq, sprite, north, self)
  end
  buildUtil.setInfo(self.javaObject, self)
  buildUtil.consumeMaterial(self)
  self.javaObject:setName(self.name)
  self.javaObject:setModData(self.modData)
  self.javaObject:setMaxHealth(self:getHealth())
  self.javaObject:setHealth(self.javaObject:getMaxHealth())
  if self.breakSound then self.javaObject:setBreakSound(self.breakSound) end
  if self.DoSpecialTooltip ~= nil and type(self.DoSpecialTooltip) == 'function' then
    self.javaObject:setSpecialTooltip(true)
  end
  self.sq:AddSpecialObject(self.javaObject)
end



---
--- Lua object constructor - called when creating the ghost tile
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
---
function ISExtBuildingObject:new(player, recipe)
  local o = ISBuildingObject:new()
  setmetatable(o, self)
  self.__index = self
  o:init()
  o.name = getText(recipe.name) or self._name
  o.breakSound = recipe.breakSound or self._breakSound or 'BreakObject'
  o.player = player
  if recipe.sprites ~= nil then
    o:setSprite(recipe.sprites.sprite or self._sprites.sprite or '')
    if recipe.sprites.north ~= nil then o:setNorthSprite(recipe.sprites.north) else o:setNorthSprite(recipe.sprites.sprite or self._sprites.sprite or '') end
    if recipe.sprites.east ~= nil then o:setEastSprite(recipe.sprites.east) elseif self._sprites.east ~= nil then o:setEastSprite(self._sprites.east) end
    if recipe.sprites.south ~= nil then o:setSouthSprite(recipe.sprites.south) elseif self._sprites.south ~= nil then o:setSouthSprite(self._sprites.south) end
    o.openSprite = recipe.sprites.openSprite or self._sprites.openSprite or nil
    o.openNorthSprite = recipe.sprites.openNorthSprite or self._sprites.openNorthSprite or recipe.sprites.openSprite or self._sprites.openSprite or nil
  else
    o:setSprite(self._sprites.sprite)
    if self._sprites.north ~= nil then o:setNorthSprite(self._sprites.north) else o:setNorthSprite(self._sprites.sprite) end
    if self._sprites.east ~= nil then o:setEastSprite(self._sprites.east) end
    if self._sprites.south ~= nil then o:setSouthSprite(self._sprites.south) end
    o.openSprite = self._sprites.openSprite or nil
    o.openNorthSprite = self._sprites.openNorthSprite or self._sprites.openSprite or nil
  end
  if self._properties ~= nil then for k,v in pairs(self._properties) do o[k] = v end end
  if recipe.properties ~= nil then for k,v in pairs(recipe.properties) do o[k] = v end end
  o.modData = recipe.modData or self._modData or {}
  o.isoType = recipe._isoType or self._isoType or 'IsoThumpable'
  return o
end



---
--- Defines and returns the total health of the target building
--- @return int Max health of the building
---
function ISExtBuildingObject:getHealth()
  local perk
  if self._mainMaterial ~= nil then
    if     self._mainMaterial == 'wood'  then perk = Perks.Woodwork
    elseif self._mainMaterial == 'metal' then perk = Perks.MetalWelding
    elseif self._mainMaterial == 'stone' then perk = Perks.Strength
    elseif self._mainMaterial == 'glass' then perk = Perks.Woodwork
    end
  else
    perk = Perks.Woodwork
  end
  local plr = getSpecificPlayer(self.player)
  local health = plr:getPerkLevel(Perks.Woodwork) * 50
  if plr:HasTrait('Handy') then health = health + 100 end
  return health
end



function ISExtBuildingObject.predicateNotBroken(item)
  return not item:isBroken()
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
---
function ISExtBuildingObject:isValid(square)
  -- base rules (valid, walkable, free space, reachable, etc)
  if not ISBuildingObject.isValid(self, square) then return false end
  -- square must not occupied by another solid structure
  if square:isSolid() or square:isSolidTrans() then return false end
  if square:HasStairs() then return false end
  if square:HasTree() then return false end
  if not square:getMovingObjects():isEmpty() then return false end
  if not square:TreatAsSolidFloor() then return false end
  return true
end




---
--- Render the item on the ground or launch the build
---
function ISExtBuildingObject.DoTileBuilding(draggingItem, isRender, x, y, z, square)
  local spriteName
  if not draggingItem.player then print('[ExtBuilding] ERROR: player not set in DoTileBuilding'); draggingItem.player = 0 end
  -- if the square is nil we have to create it (for example, the 2nd floor square are nil)
  if square == nil and getWorld():isValidSquare(x, y, z) then
    square = getCell():createNewGridSquare(x, y, z, true)
  end
  -- get the sprite we have to display
  if draggingItem.player == 0 and wasMouseActiveMoreRecentlyThanJoypad() then
    local mouseOverUI = isMouseOverUI()
    if Mouse:isLeftDown() then
      if not draggingItem.isLeftDown then
        draggingItem.clickedUI = mouseOverUI
        draggingItem.isLeftDown = true
      end
      if draggingItem.clickedUI then return end
      draggingItem:rotateMouse(x, y)
    else
      if draggingItem.isLeftDown then
        draggingItem.isLeftDown = false
        draggingItem.build = draggingItem.canBeBuild and not mouseOverUI and not draggingItem.clickedUI
        draggingItem.clickedUI = false
      end
      if mouseOverUI then return end
    end
  end
  spriteName = draggingItem:getSprite()
  -- while left mouse down fix square and enable rotation
  -- so while we have the left button down, we can drag the mouse to change the direction of the item
  if (draggingItem.isLeftDown or draggingItem.build) and draggingItem.square then
    square = draggingItem.square
    x = square:getX()
    y = square:getY()
  else
    -- the square is the one our mouse is on
    draggingItem.square = square
  end
  -- there may be no square if we are at the edge of the map
  if not square then
    draggingItem.canBeBuild = false
    return
  end
  -- render our item on the ground, if it can be placed we render it with a bit of red over it
  if isRender then
    -- we first call the isValid function of our item
    draggingItem.canBeBuild = draggingItem:isValid(square, draggingItem.north)
    -- we call the render function of our item, because for stairs (for example), we drag only 1 item : the 1st part of the stairs
    -- so in the :render function is ISWoodenStair, we gonna display the 2 other part of the stairs, depending on his direction
    draggingItem:render(x, y, z, square)
  end
  -- finally build our item
  if draggingItem.canBeBuild and draggingItem.build then
    draggingItem.build = false
    draggingItem:tryBuild(x, y, z)
  end
  if draggingItem.build and not draggingItem.dragNilAfterPlace then
    draggingItem:reinit()
  end
end



---
--- Called by ISBuildAction:perform() if the timed action is done.
--- Will create the specified ISO object and add it to the world.
--- @overload
---
function ISExtBuildingObject:tryBuild(x, y, z)
  local square = getCell():getGridSquare(x, y, z)
  local oPlayer = getSpecificPlayer(self.player)
  local playerInv = oPlayer:getInventory()
  local maxTime
  if ISBuildMenu.cheat or self:walkTo(x, y, z) then
    if self.dragNilAfterPlace then getCell():setDrag(nil, self.player) end
    if oPlayer:isTimedActionInstant() then
      maxTime = 1
    else
      local buildTime = self._buildTime or 200
      if self.modData ~= nil then
        local sumOfReqSkills, counter = 0, 0
        local stringStarts, split = luautils.stringStarts, luautils.split
        for k,_ in pairs(self.modData) do
          if stringStarts(k, 'requires:') then
            local perk = Perks.FromString(split(k, ':')[2])
            sumOfReqSkills = sumOfReqSkills + oPlayer:getPerkLevel(perk)
            counter = counter + 1
          end
        end
        if counter == 0 then counter = 1 end
        maxTime = buildTime - 5 * math.floor(sumOfReqSkills / counter)
      else
        maxTime = buildTime - 5 * oPlayer:getPerkLevel(Perks.Woodwork)
      end
    end
    if self.skipBuildAction then
      self:create(x, y, z, self.get, self:getSprite())
    else
      -- TODO: Replace with first or first two tools the recipe requires
      if not self.noNeedHammer and not ISBuildMenu.cheat then
        local hammer = playerInv:getFirstTagEvalRecurse('Hammer', ISExtBuildingObject.predicateNotBroken)
        if hammer then ISInventoryPaneContextMenu.equipWeapon(hammer, true, false, self.player) end
      end
      if not ISBuildMenu.cheat then
        if self.firstItem then
          local item
          if self.firstPredicate then
            item = playerInv:getFirstTypeEvalArgRecurse(self.firstItem, self.firstPredicate)
            if not item then
              local groundItems = buildUtil.getMaterialOnGround(square)
              for _,item2 in ipairs(groundItems[self.firstItem]) do
                if self.firstPredicate(item2, self.firstArg) then
                  item = item2
                  break
                end
              end
              local time = ISWorldObjectContextMenu.grabItemTime(oPlayer, item:getWorldItem())
              ISTimedActionQueue.add(ISGrabItemAction:new(oPlayer, item:getWorldItem(), time))
            end
          else
            item = playerInv:getItemFromFullType(self.firstItem, true, true)
            if not item then
              local groundItems = buildUtil.getMaterialOnGround(square)
              item = groundItems[self.firstItem][1]
              local time = ISWorldObjectContextMenu.grabItemTime(oPlayer, item:getWorldItem())
              ISTimedActionQueue.add(ISGrabItemAction:new(oPlayer, item:getWorldItem(), time))
            end
          end
          ISInventoryPaneContextMenu.equipWeapon(item, true, false, self.player)
        end
        if self.secondItem then
          local item = playerInv:getItemFromFullType(self.secondItem, true, true)
          if instanceof(item, 'Clothing') then
            if not item:isEquipped() then ISInventoryPaneContextMenu.wearItem(item, self.player) end
          else
            ISInventoryPaneContextMenu.equipWeapon(item, false, false, self.player)
          end
        end
      end
      local selfCopy = copyTable(self)
      setmetatable(selfCopy, getmetatable(self, true))
      ISTimedActionQueue.add(ISBuildAction:new(oPlayer, selfCopy, x, y, z, self.north, self:getSprite(), maxTime))
    end
  end
end



---
--- Creates the custom tooltip for the building menu entry
--- @param player number Target player ID
--- @param option ISContextMenu Build menu entry
--- @return ISToolTip Tooltip panel for the build menu entry
---
function ISExtBuildingObject.makeTooltip(player, option, recipe, targetClass)
  local toolTip = ISToolTip:new()
  local canBuild = true
  local sRed,sGreen,sWhite = ' <RGB:.9,0,0> ',' <RGB:0,0.7,0> ',' <RGB:1,1,1> '
  local sPen = sWhite
  local getText,split,getItemName,stringStarts,format = getText,luautils.split,getItemNameFromFullType,luautils.stringStarts,string.format
  local oPlayer = getSpecificPlayer(player)
  local oPlayerInv = oPlayer:getInventory()
  local modData = recipe.modData or targetClass._modData or nil
  toolTip:initialise()
  toolTip:setName(option.name)
  if recipe.sprites ~= nil and recipe.sprites.sprite ~= nil then
    toolTip:setTexture(recipe.sprites.sprite)
  elseif targetClass._sprites ~= nil and targetClass._sprites.sprite ~= nil then
    toolTip:setTexture(targetClass._sprites.sprite)
  end
  local desc = getText(recipe.desc or targetClass._tooltipDesc or '') .. ' <LINE> '
  if modData ~= nil then
    -- required skills
    desc = format('\n%s\n%s:\n', desc, getText('Tooltip_ExtBuilding__RequiredSkills'))
    for k,v in pairs(modData) do
      if stringStarts(k, 'requires:') then
        local perk = Perks.FromString(split(k, ':')[2])
        local plrLvl = oPlayer:getPerkLevel(perk)
        if plrLvl < v then sPen = sRed; canBuild = false else sPen = sGreen end
        desc = format('%s %s %s %d\n', desc, sPen, perk:getName(), v)
      end
    end
    -- required tools
    desc = format('%s %s\n%s:\n', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredTools'))
    for k,v in pairs(modData) do
      if stringStarts(k, 'keep:') then
        local toolList = split(split(k, ':')[2], '/')
        local found = false
        for i=1, #toolList do
          if toolList ~= nil and toolList[i] ~= nil then
            if oPlayerInv:containsTypeRecurse(toolList[i]) then found = true; break end
          end
        end
        if found then sPen = sGreen else sPen = sRed; canBuild = false end
        desc = format('%s %s %s \n', desc, sPen, getItemName(v))
      end
    end
    -- required materials
    desc = format('%s %s\n%s:\n', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials'))
    for k,v in pairs(modData) do
      if not v then v = 1 end
      -- items
      if stringStarts(k, 'need:') then
        local sum = 0
        local materialString = ''
        local itemList = split(split(k, ':')[2], '/')
        for i=1, #itemList do
          if itemList ~= nil and itemList[i] ~= nil then
            sum = sum + oPlayerInv:getCountTypeRecurse(itemList[i]) or 0
            materialString = materialString .. getItemName(itemList[i])
            if i < #itemList then materialString = materialString .. '/' end
          end
        end
        if sum < v then
          sPen = sRed
          materialString = format('%s %d/%d', materialString, sum, v)
          canBuild = false
        else
          sPen = sGreen
          materialString = format('%s %d', materialString, v)
        end
        desc = format('%s %s %s\n', desc, sPen, materialString)
      -- drainables
      elseif stringStarts(k, 'use:') then
        local sum = 0
        local materialString = ''
        local itemList = split(split(k, ':')[2], '/')
        for i=1, #itemList do
          if itemList ~= nil and itemList[i] ~= nil then
            local aItemObjects = oPlayerInv:getAllTypeRecurse(itemList[i])
            if itemList ~= nil and itemList[i] ~= nil then
              if aItemObjects ~= nil and aItemObjects:size() > 0 then
                for j=0, aItemObjects:size()-1 do
                  local oItem = aItemObjects:get(j)
                  sum = sum + math.floor(oItem:getUsedDelta()/oItem:getUseDelta()) or 1
                end
              end
              materialString = materialString .. getItemName(itemList[i])
            end
            if i < #itemList then materialString = materialString .. '/' end
          end
        end
        if sum < v then
          sPen = sRed
          materialString = format('%s %d/%d', materialString, sum, v)
          canBuild = false
        else
          sPen = sGreen
          materialString = format('%s %d', materialString, v)
        end
        local unitName
        if v > 1 then unitName = 'Tooltip_ExtBuilding__Units' else unitName = 'Tooltip_ExtBuilding__Unit' end
        desc = format('%s %s %s %s\n', desc, sPen, materialString, getText(unitName))
      end
    end
  end
  toolTip.description = desc
  toolTip.footNote = getText('Tooltip_craft_pressToRotate', Keyboard.getKeyName(getCore():getKey('Rotate building')))
  if not canBuild and not ISBuildMenu.cheat then
    option.onSelect = nil
    option.notAvailable = true
  end
  return toolTip
end
