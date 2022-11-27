if not ExtBuildingContextMenu then require 'ExtBuilding/ExtBuilding_BuildRecipes' end
require 'BuildingObjects/ISBuildingObject'

--- @class ISExtBuildingObject : ISBuildingObject
ISExtBuildingObject = ISBuildingObject:derive('ISExtBuildingObject')


-- Generic defaults (those are absolutely mandatory for initialisation)
ISExtBuildingObject.defaults = {
  displayName = 'Unnamed',
  buildTime = 200,
  baseHealth = 200,
  mainMaterial = 'wood',    -- decides which skill lvl determines the extra health (allowed is "wood", "metal", "stone" or "glass")
  hasSpecialTooltip = false,
  breakSound = 'BreakObject',
  craftingBank = 'BuildingGeneric',    -- used sound file while performing the build action (it will alternate with tool sounds of the first two tool requirements defined as modData "keep:" entry. It can be used for regular construction sounds as well as "real" crafting bank sounds.
  sprites = { sprite = 'invisible_01_0' },
  isoData = {
    isoName = 'unnamed',    -- defines the name of the global map object instance, if any. If a global object has several subtypes (like in "watercollector"), this might be used to differ between those subtypes (like "waterwell", "rainbarrel"). If there are no subtypes, then it can simply use the same value as its systemName (name of the associated global object system, which must be unique)
    isoType = 'IsoThumpable',
    mapObjectPriority = 7
  },
  modData = {}
}


---
--- Merges two objects while entries of b will replace identical entries of a if
--- within the deepest level - used to merge recipe data over class defaults over general defaults.
--- Can handle nil values and empty tables as well.
--- @param a table Existing entries
--- @param b table New entries to merge
--- @param _r table DO NOT SET - used for recursion transfer
--- @return table merged tables
---
ISExtBuildingObject.merge = function(a, b, _r)
  if a == nil then return b end
  if b == nil then b = {} end
  if _r == nil then _r = {} end
  for k,v in pairs(a) do
    if k ~= nil then
      if type(v) == 'table' then _r[k] = ISExtBuildingObject.merge(a[k], v, _r[k]) else _r[k] = v end
    end
  end
  for k,v in pairs(b) do
    if k ~= nil then
      if type(v) == 'table' then _r[k] = ISExtBuildingObject.merge(b[k], v, _r[k]) else _r[k] = v end
    end
  end
  return _r
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
  self.isoData = settings.isoData
  self.displayName = settings.displayName
  self.name = settings.isoData.isoName
  self.buildTime = settings.buildTime
  self.baseHealth = settings.baseHealth
  self.mainMaterial = settings.mainMaterial
  self.hasSpecialTooltip = settings.hasSpecialTooltip
  self.breakSound = settings.breakSound
  self.craftingBank = settings.craftingBank
  self:setSprite(settings.sprites.sprite)
  self:setNorthSprite(settings.sprites.northSprite or settings.sprites.sprite)
  if settings.sprites.east then self:setEastSprite(settings.sprites.east) end -- TODO: Use west sprite as alternative?
  if settings.sprites.south then self:setSouthSprite(settings.sprites.south) end -- TODO: Use northSprite as alternativ
  if settings.sprites.corner then self.corner = settings.sprites.corner end
  if settings.sprites.openSprite or settings.sprites.openNorthSprite then
    self.openSprite = settings.sprites.openSprite or settings.sprites.openNorthSprite
    self.openNorthSprite = settings.sprites.openNorthSprite or settings.sprites.openSprite
  end
  if settings.properties then
    for k,v in pairs(settings.properties) do
      if k ~= nil then
        if type(v) == 'function' then v = v(self) end
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
  -- buildings objects which can be opened/closed will use an overloaded constructor
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
  local objIndex = self:getObjectIndex()
  if objIndex ~= nil then
    self.sq:AddSpecialObject(self.javaObject, objIndex)
  else
    self.sq:AddSpecialObject(self.javaObject)
  end
end



---
--- Lua object constructor - called when creating the ghost tile
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
--- @return table New lua building object instance
---
function ISExtBuildingObject:new(player, recipe)
  local o = ISBuildingObject:new()
  setmetatable(o, self)
  self.__index = self
  o.player = player
  o:init()
  o:initialise(recipe, self.defaults)
  return o
end



---
--- Hook for descendants which implements this function
--- to interact anyhow with existing objects on the square.
--- @return nil|int Index of the object of interest or nil if not implemented
---
function ISExtBuildingObject:getObjectIndex()
  return nil
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
  local health = baseHealth + plr:getPerkLevel(perk) * 50
  if plr:HasTrait('Handy') then health = health + 100 end
  return health
end



---
--- Checks whether the given item object (tool) is broken or not.
--- @param item IsoObject Target item instance
--- @return boolean Whether the instance has got the predicate "broken" or not
---
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
--- Called by DoTileBuilding after ghost tile drag located the desired target square.
--- It will generate the timed action query from the modData/fields and launch it and by that,
--- validate the requirements once more (things could have changed since the context menu vaildation).
--- @param x int Target squares x coordinate
--- @param y int Target squares y coordinate
--- @param z int Target squares z coordinate
---
function ISExtBuildingObject:tryBuild(x, y, z)
  local square = getCell():getGridSquare(x, y, z)
  local oPlayer = getSpecificPlayer(self.player)
  local oInv = oPlayer:getInventory()
  local maxTime, firstToolEntry, toolSound1, toolSound2
  if ISBuildMenu.cheat or self:walkTo(x, y, z) then
    if self.dragNilAfterPlace then getCell():setDrag(nil, self.player) end
    if oPlayer:isTimedActionInstant() then
      maxTime = 1
    else
      local buildTime = self.buildTime or 200
      if self.modData ~= nil then
        local sumOfReqSkills, counter = 0, 0
        local stringStarts, split = luautils.stringStarts, luautils.split
        for k,v in pairs(self.modData) do
          if stringStarts(k, 'requires:') then
            local perk = Perks.FromString(split(k, ':')[2])
            sumOfReqSkills = sumOfReqSkills + oPlayer:getPerkLevel(perk)
            counter = counter + 1
          end
          if stringStarts(k, 'keep:') then
            if firstToolEntry == nil then
              toolSound1 = v
              firstToolEntry = split(split(k, ':')[2], '/')
            elseif toolSound2 == nil then
              toolSound2 = v
            end
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
      local equipTool
      if not ISBuildMenu.cheat then
        if firstToolEntry ~= nil then
          if type(firstToolEntry) == 'table' then
            for i=1, #firstToolEntry do
              equipTool = oInv:getFirstTypeEvalRecurse(firstToolEntry[i], ISExtBuildingObject.predicateNotBroken)
              if equipTool then break end
            end
          else
            equipTool = oInv:getFirstTypeEvalRecurse(firstToolEntry, ISExtBuildingObject.predicateNotBroken)
          end
        end
      end
      if equipTool then ISInventoryPaneContextMenu.equipWeapon(equipTool, true, false, self.player) end
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
      ISTimedActionQueue.add(ISExtBuildAction:new(oPlayer, selfCopy, x, y, z, self.north, self:getSprite(), maxTime, toolSound1, toolSound2))
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
  local desc = getText(settings.tooltipDesc or '') .. ' <BR> <RGB:1,1,1> '
  if settings.modData ~= nil then
    -- required skills
    desc = format('%s\n%s:\n', desc, getText('Tooltip_ExtBuilding__RequiredSkills'))
    for k,v in pairs(settings.modData) do
      if stringStarts(k, 'requires:') then
        local perk = Perks.FromString(split(k, ':')[2])
        local plrLvl = oPlayer:getPerkLevel(perk)
        if plrLvl < v then sPen = sRed; canBuild = false else sPen = sGreen end
        desc = format(' <SETX:3> %s %s %s %d\n', desc, sPen, perk:getName(), v)
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
        desc = format(' <SETX:3> %s %s %s\n', desc, sPen, getItemName(v))
      end
    end
    -- required materials
    local groundItems = buildUtil.getMaterialOnGround(oPlayer:getSquare())
    local groundItemCounts = buildUtil.getMaterialOnGroundCounts(groundItems)
    local groundItemUses = buildUtil.getMaterialOnGroundUses(groundItems)
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
            if groundItemCounts[itemList[i]] ~= nil then sum = sum + groundItemCounts[itemList[i]] end
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
        desc = format(' <SETX:3> %s %s %s\n', desc, sPen, materialString)
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
                  sum = sum + math.floor(oItem:getUsedDelta() or 0 / oItem:getUseDelta() or 1)
                  if groundItemUses[itemList[i]] ~= nil then sum = sum + groundItemUses[itemList[i]] end
                end
              end
              materialString = materialString .. getItemName(itemList[i])
            end
            if i < #itemList then materialString = materialString .. '/' end
          end
        end
        if sum < v then sPen = sRed; canBuild = false else sPen = sGreen end
        if v == 1 then
          materialString = getText('IGUI_CraftUI_CountOneUnit', materialString)
        else
          materialString = getText('IGUI_CraftUI_CountUnits', materialString, sum .. '/' .. v)
        end
        desc = format(' <SETX:3> %s %s %s\n', desc, sPen, materialString)
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