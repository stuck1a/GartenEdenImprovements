require 'BuildingObjects/ISBuildingObject'


--- @class ISExtBuildingObject : ISBuildingObject
ISExtBuildingObject = ISBuildingObject:derive('ISExtBuildingObject')


-- Generic defaults (those are absolutely mandatory for initialisation)
ISExtBuildingObject.defaults = {
  displayName = 'UNKNOWN',
  name = 'UNKNOWN',
  buildTime = 200,
  baseHealth = 200,
  mainMaterial = 'wood',
  hasSpecialTooltip = false,
  breakSound = 'BreakObject',
  sprites = { sprite = 'invisible_01_0' },
  isoData = { isoType = 'IsoThumpable', mapObjectPriority = 7 }
}


ISExtBuildingObject.merge = function(a, b, recurse)
  if a == nil then return b end
  if b == nil then b = {} end
  if recurse == nil then recurse = {} end
  for k,v in pairs(a) do
    if k ~= nil then
      if type(v) == 'table' then recurse[k] = ISExtBuildingObject.merge(a[k], v, recurse[k]) else recurse[k] = v end
    end
  end
  for k,v in pairs(b) do
    if k ~= nil then
      if type(v) == 'table' then recurse[k] = ISExtBuildingObject.merge(b[k], v, recurse[k]) else recurse[k] = v end
    end
  end
  return recurse
end




---
--- Set up properties the constructors will effectively use
--- Recipe level values have highest priority, then class defaults
--- the generic class defaults and finally vanilla defaults
--- @param recipe table The defined building recipe
--- @param classDefaults table Descendant class settings
---
function ISExtBuildingObject:initialise(recipe, classDefaults)
  local settings = ISExtBuildingObject.merge(ISExtBuildingObject.merge(ISExtBuildingObject.defaults, classDefaults), recipe)
  self.displayName = settings.displayName
  self.name = settings.name
  self.buildTime = settings.buildTime
  self.baseHealth = settings.baseHealth
  self.mainMaterial = settings.mainMaterial
  self.hasSpecialTooltip = settings.hasSpecialTooltip
  self.breakSound = settings.breakSound
  self:setSprite(settings.sprites.sprite)
  self:setNorthSprite(settings.sprites.north or settings.sprites.sprite)
  if settings.sprites.east then self:setEastSprite(settings.sprites.east) end
  if settings.sprites.south then self:setEastSprite(settings.sprites.south) end
  if settings.sprites.openSprite or settings.sprites.openNorthSprite then
    self.openSprite = settings.sprites.openSprite or settings.sprites.openNorthSprite
    self.openNorthSprite = settings.sprites.openNorthSprite or settings.sprites.openSprite
  end
  if settings.properties then
    for k,v in ipairs(settings.properties) do
      if k ~= nil then
        if type(v) == 'table' then self[k] = ISExtBuildingObject.merge(self[k], settings.properties[k]) else self[k] = v end
      end
    end
  end
  self.isoData = settings.isoData
  self.modData = settings.modData
end



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
    self.javaObject = _G[self.isoData.isoType].new(cell, self.sq, sprite, openSprite, north, self)
  else
    self.javaObject = _G[self.isoData.isoType].new(cell, self.sq, sprite, north, self)
  end
  buildUtil.setInfo(self.javaObject, self)
  buildUtil.consumeMaterial(self)
  self.javaObject:setMaxHealth(self:getHealth(self.mainMaterial, self.baseHealth))
  self.javaObject:setHealth(self.javaObject:getMaxHealth())
  self.javaObject:setBreakSound(self.breakSound)
  self.javaObject:setSpecialTooltip(self.hasSpecialTooltip)
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
  o:initialise(recipe, self.defaults)
  o.player = player
  return o
end



---
--- Defines and returns the total health of the target building
--- @param mainMaterial string The defined main material
--- @param baseHealth int The defined base health
--- @return int Max health of the building
---
function ISExtBuildingObject:getHealth(mainMaterial, baseHealth)
  local plr, perk = getSpecificPlayer(self.player)
  if     mainMaterial == 'wood'  then perk = Perks.Woodwork
  elseif mainMaterial == 'metal' then perk = Perks.MetalWelding
  elseif mainMaterial == 'stone' then perk = Perks.Strength
  elseif mainMaterial == 'glass' then perk = Perks.Woodwork
  else   perk = Perks.Woodwork
  end
  local health = 50 + plr:getPerkLevel(perk) * 50
  if plr:HasTrait('Handy') then health = health + 100 end
  return health
end



function ISExtBuildingObject.predicateNotBroken(item)
  return not item:isBroken()
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean If the hovered cell has space for the target construction
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
--- @param draggingItem ISExtBuildingObject
--- @param isRender boolean
--- @param x int
--- @param y int
--- @param z int
--- @param square IsoGridSquare
---
function ISExtBuildingObject.DoTileBuilding(draggingItem, isRender, x, y, z, square)
  if not draggingItem.player then draggingItem.player = 0 end
  if square == nil and getWorld():isValidSquare(x, y, z) then square = getCell():createNewGridSquare(x, y, z, true) end
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
  if (draggingItem.isLeftDown or draggingItem.build) and draggingItem.square then
    square = draggingItem.square
    x = square:getX()
    y = square:getY()
  else
    draggingItem.square = square
  end
  if not square then
    draggingItem.canBeBuild = false
    return
  end
  if isRender then
    draggingItem.canBeBuild = draggingItem:isValid(square, draggingItem.north)
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
--- @param x int
--- @param y int
--- @param z int
---
function ISExtBuildingObject:tryBuild(x, y, z)
  local square = getCell():getGridSquare(x, y, z)
  local oPlayer = getSpecificPlayer(self.player)
  local oInv = oPlayer:getInventory()
  local maxTime
  if ISBuildMenu.cheat or self:walkTo(x, y, z) then
    if self.dragNilAfterPlace then getCell():setDrag(nil, self.player) end
    if oPlayer:isTimedActionInstant() then
      maxTime = 1
    else
      local buildTime = self.buildTime or 200
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
      self:create(x, y, z, self.north, self:getSprite())
    else
      -- TODO: Replace with first or first two tools the recipe requires
      if not self.noNeedHammer and not ISBuildMenu.cheat then
        local hammer = oInv:getFirstTagEvalRecurse('Hammer', ISExtBuildingObject.predicateNotBroken)
        if hammer then ISInventoryPaneContextMenu.equipWeapon(hammer, true, false, self.player) end
      end
      if not ISBuildMenu.cheat then
        if self.firstItem then
          local item
          if self.firstPredicate then
            item = oInv:getFirstTypeEvalArgRecurse(self.firstItem, self.firstPredicate)
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
            item = oInv:getItemFromFullType(self.firstItem, true, true)
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
          local item = oInv:getItemFromFullType(self.secondItem, true, true)
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
--- @param recipe table Definition table
--- @param targetClass ISExtBuildingObject Type class
--- @return ISToolTip Tooltip panel for the build menu entry
---
function ISExtBuildingObject.makeTooltip(player, option, recipe, targetClass)
  local toolTip = ISToolTip:new()
  local canBuild = true
  local sRed,sGreen,sWhite = ' <RGB:.9,0,0> ',' <RGB:0,0.7,0> ',' <RGB:1,1,1> '
  local sPen = sWhite
  local getText,split,getItemName,stringStarts,format,merge = getText,luautils.split,getItemNameFromFullType,luautils.stringStarts,string.format,ISExtBuildingObject.merge
  local oPlayer = getSpecificPlayer(player)
  local oInv = oPlayer:getInventory()
  local settings = merge(merge(ISExtBuildingObject.defaults, targetClass.defaults), recipe)
  toolTip:initialise()
  toolTip:setName(option.name)
  toolTip:setTexture(settings.sprites.sprite)
  local desc = getText(settings.tooltipDesc or '') .. ' <LINE> '
  if settings.modData ~= nil then
    -- required skills
    desc = format('\n%s\n%s:\n', desc, getText('Tooltip_ExtBuilding__RequiredSkills'))
    for k,v in pairs(settings.modData) do
      if stringStarts(k, 'requires:') then
        local perk = Perks.FromString(split(k, ':')[2])
        local plrLvl = oPlayer:getPerkLevel(perk)
        if plrLvl < v then sPen = sRed; canBuild = false else sPen = sGreen end
        desc = format('%s %s %s %d\n', desc, sPen, perk:getName(), v)
      end
    end
    -- required tools
    desc = format('%s %s\n%s:\n', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredTools'))
    for k,v in pairs(settings.modData) do
      if stringStarts(k, 'keep:') then
        local toolList = split(split(k, ':')[2], '/')
        local found = false
        for i=1, #toolList do
          if toolList ~= nil and toolList[i] ~= nil then
            if oInv:containsTypeRecurse(toolList[i]) then found = true; break end
          end
        end
        if found then sPen = sGreen else sPen = sRed; canBuild = false end
        desc = format('%s %s %s \n', desc, sPen, getItemName(v))
      end
    end
    -- required materials
    desc = format('%s %s\n%s:\n', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials'))
    for k,v in pairs(settings.modData) do
      if not v then v = 1 end
      -- items
      if stringStarts(k, 'need:') then
        local sum = 0
        local materialString = ''
        local itemList = split(split(k, ':')[2], '/')
        for i=1, #itemList do
          if itemList ~= nil and itemList[i] ~= nil then
            sum = sum + oInv:getCountTypeRecurse(itemList[i]) or 0
            if itemList[i] == 'Base.Nails' then sum = oInv:getCountTypeRecurse('Base.NailsBox') * 100 end
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
            local aItemObjects = oInv:getAllTypeRecurse(itemList[i])
            if itemList ~= nil and itemList[i] ~= nil then
              if aItemObjects ~= nil and aItemObjects:size() > 0 then
                for j=0, aItemObjects:size()-1 do
                  local oItem = aItemObjects:get(j)
                  sum = sum + math.floor(oItem:getUsedDelta() / oItem:getUseDelta()) or 1
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