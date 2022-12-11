if not ExtBuildingContextMenu then require 'ExtBuilding/ExtBuilding_BuildRecipes' end
require 'BuildingObjects/ISBuildingObject'
require 'luautils'


--- @class ISExtBuildingObject : ISBuildingObject
ISExtBuildingObject = ISBuildingObject:derive('ISExtBuildingObject')


-- Generic defaults (those are absolutely mandatory for initialisation)
ISExtBuildingObject.defaults = {
  displayName = 'Unnamed',
  buildTime = 200,
  baseHealth = 200,
  mainMaterial = 'wood',
  hasSpecialTooltip = false,
  breakSound = 'BreakObject',
  thumpSound = 'ZombieThumpGeneric',
  craftingBank = nil,
  sprites = { sprite = 'invisible_01_0' },
  isoData = {
    isoName = 'unnamed',
    isoType = 'IsoThumpable',
    mapObjectPriority = 7
  },
  modData = {}
}


-- Storage for construction site pointer
ISExtBuildingObject.constructionSites = {}    -- proxy (provides getter/setter meta for the shadow table)
ISExtBuildingObject.constructionSitesShadow = {}    -- holds the real values


---
--- Checks whether the given item object (tool) is broken or not.
--- @param item IsoObject Target item instance
--- @return boolean Whether the instance has got the predicate "broken" or not
---
local function predicateNotBroken(item)
  return not item:isBroken()
end



---
--- Compares the player location with the target location and
--- adjusts the resulting location for the construction site tile for wallType objects.
--- For each target edge (W,N,E,S) of the target square there exists one possible mirrored square.
--- First, it will try the use the square, the player faces.
--- Only if this square has no flooring, the other side will be used to place the construction site.
--- @param plr IsoPlayer Target player object
--- @param x int Target square x coordinate
--- @param y int Target square x coordinate
--- @param z int Target square x coordinate
--- @param square IsoGridSquare The base target square object
--- @param west boolean Whether the wall is shall be placed on either the west or east edge of the target square
--- @return IsoGridSquare Resulting square object for the construction site tile
---
local function getAdjustedSquareForConstructionSite(plr, x, y, z, square, west)
  if west then
    if z == 0 then
      if plr:getX() < x then return square:getW() or square else return square or square:getW() end
    else
      return square:getW() or square
    end
  else
    if z == 0 then
      if plr:getY() < y then return square:getN() or square else return square or square:getN() end
    else
      return square:getN() or square
    end
  end
  return square
end



---
--- Listener for player update event - removes construction site if necessary
--- @param oPlayer IsoPlayer Target player object
---
local function onPlayerUpdate(oPlayer)
  local actionlist = oPlayer:getCharacterActions()
  if actionlist:size() ~= 0 then return end
  local isoTile = ISExtBuildingObject.constructionSites[oPlayer]
  if isoTile == nil then return end
  Events.OnPlayerUpdate.Remove(onPlayerUpdate)
  local square = isoTile:getSquare()
  -- there might be several construction sites on the square, so remove only the assigned one
  if square then
    local specialTiles = square:getSpecialObjects()
    for i=0, specialTiles:size()-1 do
      if specialTiles:get(i) == isoTile then
        square:transmitRemoveItemFromSquare(isoTile)
        square:RemoveTileObject(isoTile)
        isoTile = nil
        return
      end
    end
  end
end



---
--- Replaces possibly existing construction site tile assigned to the player
--- with the new one
--- @param _ table The shadow table (only used for proxy access)
--- @param key IsoPlayer The target player instance
--- @param value IsoObject The construction site tile object
---
local function setConstructionSite(_, key, value)
  if ISExtBuildingObject.constructionSitesShadow[key] ~= nil then
    local isoTile = ISExtBuildingObject.constructionSitesShadow[key]
    if isoTile == nil then return end
    Events.OnPlayerUpdate.Remove(onPlayerUpdate)
    local square = isoTile:getSquare()
    -- there might be several construction sites on the square, so remove only the assigned one
    if square then
      local specialTiles = square:getSpecialObjects()
      for i=0, specialTiles:size()-1 do
        if specialTiles:get(i) == isoTile then
          square:transmitRemoveItemFromSquare(isoTile)
          square:RemoveTileObject(isoTile)
          isoTile = nil
          break
        end
      end
    end
  end
  ISExtBuildingObject.constructionSitesShadow[key] = value
end
---
--- Returns the isoTile from the shadowed table
--- @param _ table The shadowed table
--- @param key IsoPlayer The target player instance
---
local function getConstructionSite(_, key)
  return ISExtBuildingObject.constructionSitesShadow[key] or nil
end
setmetatable(ISExtBuildingObject.constructionSites, {
 __newindex = setConstructionSite,
 __index = getConstructionSite
})



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
  self.thumpSound = settings.thumpSound
  self.breakSound = settings.breakSound
  self.craftingBank = settings.craftingBank
  self.isValidAddition = settings.isValidAddition
  self:setSprite(settings.sprites.sprite)
  self:setNorthSprite(settings.sprites.northSprite or settings.sprites.sprite)
  if settings.sprites.east then self:setEastSprite(settings.sprites.east) end
  if settings.sprites.south then self:setSouthSprite(settings.sprites.south) end
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
  if settings.forceEquip then self.forceEquip = settings.forceEquip end
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
  self.javaObject:setThumpSound(self.thumpSound)
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
  local oPlayer, perk = getSpecificPlayer(self.player)
  if     mainMaterial == 'wood'  then perk = Perks.Woodwork
  elseif mainMaterial == 'metal' then perk = Perks.MetalWelding
  elseif mainMaterial == 'stone' then perk = Perks.Strength
  elseif mainMaterial == 'glass' then perk = Perks.Woodwork
  else   perk = Perks.Woodwork
  end
  local health = baseHealth + oPlayer:getPerkLevel(perk) * 50
  if oPlayer:HasTrait('Handy') then health = health + 100 end
  return health
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean If the hovered cell has space for the target construction
---
function ISExtBuildingObject:isValid(square)
  -- base rules (valid square, blocked by char, stranger safehouse, not twice the same, etc)
  if not ISBuildingObject.isValid(self, square) then return false end
  -- not allow to block stairs except walls
  if self.isWallLike then
    if buildUtil.stairIsBlockingPlacement(square, true, (self.nSprite==4 or self.nSprite==2)) then return false end
  else
    if buildUtil.stairIsBlockingPlacement(square, true) then return false end
  end
  -- check additional isValid callbacks, if any
  if self.isValidAddition ~= nil then
    if not self.isValidAddition(square) then return false end
  end
  -- not occupied by a solid structure
  if square:isSolid() or square:isSolidTrans() then return false end
  --if square:HasStairs() then return false end
  if square:HasTree() then return false end
  if not square:getMovingObjects():isEmpty() then return false end
  if not square:TreatAsSolidFloor() then return false end
  return true
end



---
--- Called by DoTileBuilding after ghost tile drag located the desired target square.
--- It will generate the timed action query from the modData/fields and handle the
--- construction site tile
--- @param x int Target squares x coordinate
--- @param y int Target squares y coordinate
--- @param z int Target squares z coordinate
---
function ISExtBuildingObject:tryBuild(x, y, z)
  local square = getCell():getGridSquare(x, y, z)
  local oPlayer = getSpecificPlayer(self.player)
  local oInv = oPlayer:getInventory()
  local grabTime1, grabTime2, fromGround1, fromGround2 = 50, 50, false, false
  local maxTime, tool1, tool2, toolSound1, toolSound2, wearable, material1, material2, sqConstructionSite
  local forceTool1, forceTool2, forceWearable

  if self.forceEquip then
    forceTool1 = self.forceEquip['tool1']
    forceTool2 = self.forceEquip['tool2']
    forceWearable = self.forceEquip['wearable']
  end

  if self.isWallLike then
    sqConstructionSite = getAdjustedSquareForConstructionSite(oPlayer, x, y, z, square, self.west)
    else
    sqConstructionSite = square
  end
  local isoTile = IsoObject.new(sqConstructionSite, 'garteneden_tech_01_2', 'ConstructionSite')
  -- TODO: Replace self.Type == 'fishingNet' with something like self.Type == 'waterConstruction'
  if ISBuildMenu.cheat or self:walkTo(x, y, z) or (self.Type == 'fishingNet' and self:isValid(square)) then
    if not self.skipBuildAction then
      if sqConstructionSite then
        sqConstructionSite:AddSpecialTileObject(isoTile)
        isoTile:transmitCompleteItemToServer()








        ISExtBuildingObject.constructionSites[oPlayer] = isoTile
      end
    end
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
          elseif stringStarts(k, 'keep:') then
            if tool1 == nil then
              local skipEntry = false
              if forceTool1 ~= nil and not k ~= forceTool1 then skipEntry = true end
              if skipEntry == false then
                local typelist = split(split(k, ':')[2], '/')
                for i=1, #typelist do
                  local oItem = oInv:getFirstTypeEvalRecurse(typelist[i], predicateNotBroken)
                  if oItem then
                    if instanceof(oItem, 'Clothing') then break end
                    tool1 = oItem
                    toolSound1 = v
                    break
                  end
                end
              end
            elseif tool2 == nil then
              local skipEntry = false
              if forceTool2 ~= nil and k ~= forceTool2 then skipEntry = true end
              if skipEntry == false then
                local typelist = split(split(k, ':')[2], '/')
                for i=1, #typelist do
                  local oItem = oInv:getFirstTypeEvalRecurse(typelist[i], predicateNotBroken)
                  if oItem then
                    if instanceof(oItem, 'Clothing') then break end
                    tool2 = oItem
                    toolSound2 = v
                    break
                  end
                end
              end
            end
            if wearable == nil then
              local skipEntry = false
              if forceWearable ~= nil and k ~= forceWearable then skipEntry = true end
              if skipEntry == false then
                local typelist = split(split(k, ':')[2], '/')
                for i=1, #typelist do
                  local oItem = oInv:getFirstTypeRecurse(typelist[i])
                  if oItem and instanceof(oItem, 'Clothing') then
                    wearable = oItem
                    break
                  end
                end
              end
            end
          elseif stringStarts(k, 'need:') or stringStarts(k, 'use:') then
            if material1 == nil then
              local skipEntry = false
              local forceOverwrite = forceTool1 ~= nil
              if forceOverwrite and k ~= forceTool1 then skipEntry = true end
              if skipEntry == false then
                local typelist = split(split(k, ':')[2], '/')
                for i=1, #typelist do
                  material1 = oInv:getFirstTypeRecurse(typelist[i])
                  if material1 then
                    if toolSound2 == nil or forceOverwrite then toolSound2 = k end
                    if forceOverwrite then tool1 = material1 end
                    break
                  end
                end
                if material1 == nil then
                  for i=1, #typelist do
                    local groundItems = buildUtil.getMaterialOnGround(square)
                    for k,v in ipairs(groundItems) do
                      if k == typelist[i] then
                        material1 = v
                        if toolSound2 == nil or forceOverwrite then toolSound2 = k end
                        if forceOverwrite then tool1 = material1 end
                        fromGround1 = true
                        grabTime1 = ISWorldObjectContextMenu.grabItemTime(oPlayer, material1:getWorldItem())
                        break
                      end
                    end
                    if material1 then break end
                  end
                end
              end
            elseif material2 == nil then
              local skipEntry = false
              local forceOverwrite = forceTool2 ~= nil
              if forceOverwrite and k ~= forceTool2 then skipEntry = true end
              if skipEntry == false then
                local typelist = split(split(k, ':')[2], '/')
                for i=1, #typelist do
                  material2 = oInv:getFirstTypeRecurse(typelist[i])
                  if material2 then
                    if toolSound1 == nil or forceOverwrite then toolSound1 = k end
                    if forceOverwrite then tool2 = material2 end
                    break
                  end
                end
                if material2 == nil then
                  for i=1, #typelist do
                    local groundItems = buildUtil.getMaterialOnGround(square)
                    for k,v in ipairs(groundItems) do
                      if k == typelist[i] then
                        material2 = v
                        if toolSound1 == nil or forceOverwrite then toolSound1 = k end
                        if forceOverwrite then tool2 = material2 end
                        fromGround2 = true
                        grabTime2 = ISWorldObjectContextMenu.grabItemTime(oPlayer, material2:getWorldItem())
                        break
                      end
                    end
                    if material2 then break end
                  end
                end
              end
            end
          end
        end
        if counter > 0 then
          maxTime = math.floor(buildTime - 5 * sumOfReqSkills / counter)
        else
          maxTime = buildTime
        end
      else
        maxTime = math.floor(buildTime - 5 * oPlayer:getPerkLevel(Perks.Woodwork))
      end
    end
    if self.skipBuildAction then
      self:create(x, y, z, self.north, self:getSprite())
    else
      if not ISBuildMenu.cheat then
        if wearable then ISInventoryPaneContextMenu.wearItem(wearable, self.player) end
        if tool1 then
          ISInventoryPaneContextMenu.equipWeapon(tool1, true, false, self.player)
        elseif material2 then
          if fromGround2 then
            ISTimedActionQueue.add(ISGrabItemAction:new(oPlayer, material2:getWorldItem(), grabTime2))
          end
          luautils.equipItems(oPlayer, material2, false)
        end
        if tool2 then
          ISInventoryPaneContextMenu.equipWeapon(tool2, false, false, self.player)
        elseif material1 then
          if fromGround1 then
            ISTimedActionQueue.add(ISGrabItemAction:new(oPlayer, material1:getWorldItem(), grabTime1))
          end
          luautils.equipItems(oPlayer, false, material1)
        end
      end
      local selfCopy = copyTable(self)
      setmetatable(selfCopy, getmetatable(self, true))
      ISTimedActionQueue.add(ISExtBuildAction:new(oPlayer, selfCopy, x, y, z, self.north, self:getSprite(), maxTime, toolSound1, toolSound2))
      Events.OnPlayerUpdate.Add(onPlayerUpdate, oPlayer)
    end
  end
end







---
--- Creates the custom tooltip for the building menu entry
--- @param oPlayer IsoPlayer Target player object
--- @param option ISContextMenu Build menu entry
--- @param recipe table Definition table
--- @param targetClass ISExtBuildingObject Type class
--- @return ISToolTip Tooltip panel for the build menu entry
---
function ISExtBuildingObject.makeTooltip(oPlayer, option, recipe, targetClass)
  local toolTip = ISToolTip:new()
  local canBuild, headlineSet = true, false
  local sRed,sGreen,sWhite = '<RGB:.9,0,0>', '<RGB:0,0.7,0>', '<RGB:1,1,1>'
  local sPen = sWhite
  local getText,split,getItemName,stringStarts,format,merge = getText,luautils.split,getItemNameFromFullType,luautils.stringStarts,string.format,ISExtBuildingObject.merge
  local oInv = oPlayer:getInventory()
  local settings = merge(merge(ISExtBuildingObject.defaults, targetClass.defaults), recipe)
  toolTip:initialise()
  toolTip:setName(option.name)
  toolTip:setTexture(settings.sprites.sprite)
  local desc = ' <LEFT> ' .. getText(settings.tooltipDesc or '') .. ' <BR> '
  if settings.modData ~= nil then
    -- required skills
    headlineSet = false
    for k,v in pairs(settings.modData) do
      if stringStarts(k, 'requires:') then
        if not headlineSet then desc = format('%s <H2> %s:', desc, getText('Tooltip_ExtBuilding__RequiredSkills')); headlineSet = true end
        local perk = Perks.FromString(split(k, ':')[2])
        local plrLvl = oPlayer:getPerkLevel(perk)
        if plrLvl < v then sPen = sRed; canBuild = false else sPen = sGreen end
        desc = format('%s <LINE> <TEXT> %s %s %d/%d', desc, sPen, perk:getName(), plrLvl, v)
      end
    end
    -- required tools
    headlineSet = false
    for k,v in pairs(settings.modData) do
      if stringStarts(k, 'keep:') then
        if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredTools')); headlineSet = true end
        local toolList = split(split(k, ':')[2], '/')
        local found = false
        for i=1, #toolList do
          if toolList ~= nil and toolList[i] ~= nil then
            if oInv:containsTypeRecurse(toolList[i]) then found = true; break end
          end
        end
        if found then sPen = sGreen else sPen = sRed; canBuild = false end
        desc = format('%s <LINE> <TEXT> %s %s', desc, sPen, getItemName(v))
      end
    end
    -- required materials
    local groundItems = buildUtil.getMaterialOnGround(oPlayer:getSquare())
    local groundItemCounts = buildUtil.getMaterialOnGroundCounts(groundItems)
    local groundItemUses = buildUtil.getMaterialOnGroundUses(groundItems)
    headlineSet = false
    for k,v in pairs(settings.modData) do
      -- regular
      if stringStarts(k, 'need:') then
        v = v or 1
        if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials')); headlineSet = true end
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
        if sum < v then sPen = sRed; canBuild = false else sPen = sGreen end
        materialString = format('%s %d/%d', materialString, sum, v)
        desc = format('%s <LINE> <TEXT> %s %s', desc, sPen, materialString)
      -- drainables
      elseif stringStarts(k, 'use:') then
        v = v or 1
        if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials')); headlineSet = true end
        local sum = 0
        local materialString = ''
        local itemList = split(split(k, ':')[2], '/')
        for i=1, #itemList do
          if itemList ~= nil and itemList[i] ~= nil then
            local aItemObjects = oInv:getAllTypeRecurse(itemList[i])
            if aItemObjects ~= nil and aItemObjects:size() > 0 then
              for j=0, aItemObjects:size()-1 do
                local oItem = aItemObjects:get(j)
                sum = sum + oItem:getDrainableUsesInt() or 0
              end
            end
            if groundItemUses[itemList[i]] ~= nil then sum = sum + groundItemUses[itemList[i]] end
            materialString = materialString .. getItemName(itemList[i])
            if i < #itemList then materialString = materialString .. '/' end
          end
        end
        if sum < v then sPen = sRed; canBuild = false else sPen = sGreen end
        if v == 1 then
          materialString = sum .. '/' .. getText('IGUI_CraftUI_CountOneUnit', materialString)
        else
          materialString = getText('IGUI_CraftUI_CountUnits', materialString, sum .. '/' .. v)
        end
        desc = format('%s <LINE> <TEXT> %s %s', desc, sPen, materialString)
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



LuaEventManager.AddEvent('ExtBuildEvent')