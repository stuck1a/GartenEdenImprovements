if not ISExtBuildingObject then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end


--- @class ISWaterCollector : ISExtBuildingObject
ISWaterCollector = ISExtBuildingObject:derive('ISWaterCollector')


ISWaterCollector.defaults = {
  hasSpecialTooltip = true,
  isoData = {
    isoName = 'watercollector',    -- used as fallback name for the iso object
    systemName = 'watercollector',    -- used as name for the map object system
    objectModDataKeys = { 'waterAmount', 'waterMax', 'addWaterPerAction' },
  },
  properties = {
    waterAmount = 0,
    waterMax = 100,
    addWaterPerAction = 1
  }
}
ISWaterCollector.registeredRecipes = {}


---
--- Java object constructor - initializes and places a completed water collector
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from west to east)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether the north sprite was chosen
--- @param sprite string Name of the chosen sprite
---
function ISWaterCollector:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite)
  self.javaObject:getModData()['waterMax'] = self.waterMax
  self.javaObject:getModData()['waterAmount'] = self.waterAmount
  self.javaObject:getModData()['addWaterPerAction'] = self.addWaterPerAction
  self.javaObject:transmitCompleteItemToServer()
  if getCore():getGameMode() ~= 'Multiplayer' then triggerEvent('OnObjectAdded', self.javaObject) end
end



---
--- Lua object constructor - generates a new water collector object
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
--- @return ISWaterCollector BuildingObject instance
---
function ISWaterCollector:new(player, recipe)
  local o = ISExtBuildingObject.new(self, player, recipe)
  setmetatable(o, self)
  self.__index = self
  return o
end



---
--- Extension of the ghost tile placement validation
--- @param square IsoGridSquare Clicked square object
--- @return boolean True, if building can be placed on current target square
---
function ISWaterCollector:isValid(square)
  -- base rules (valid, walkable, free space, reachable, solid ground, etc)
  if not ISExtBuildingObject.isValid(self, square) then return false end
  -- only on surface
  if not getSpecificPlayer(self.player):getZ() == 0 then return false end
  -- not under stairs
  if buildUtil.stairIsBlockingPlacement(square, true) then return false end
  -- tile must have any exterior, natural ground (except water)
  for i=1, square:getObjects():size() do
    local props = square:getProperties()
    if props:Is(IsoFlagType.water) then return false end
    local obj = square:getObjects():get(i-1)
    local textureName = obj:getTextureName() or 'occupied'
    if (not luautils.stringStarts(textureName, 'floors_exterior_natur')) and (not luautils.stringStarts(textureName, 'blends_natur')) then return false end
  end
  return true
end



---
--- Creates an on hover tooltip for water collectors with an amount bar if near enough
--- @param tooltipUI UIElement Tooltip factory
--- @param square IsoGridSquare Clicked square
---
local function DoSpecialTooltip(tooltipUI, square)
  local oPlayer = getSpecificPlayer(0)
  if not oPlayer or oPlayer:getZ() ~= square:getZ() or oPlayer:DistToSquared(square:getX() + 0.5, square:getY() + 0.5) > 4 then return end
  local oIsoObject = CWaterCollectorSystem.instance:getIsoObjectOnSquare(square)
  if not oIsoObject or not oIsoObject:getModData()['waterMax'] then return end
  local name = getText(oIsoObject:getTable().displayName or ISWaterCollector.defaults.displayName or ISExtBuildingObject.defaults.displayName)
  local font = UIFont.Small
  local fontHeight = getTextManager():getFontFromEnum(font):getLineHeight()
  tooltipUI:setHeight(6 + fontHeight + 6 + fontHeight + 12)
  local textX, textY = 12, 6 + fontHeight + 6
  local barWid, barHgt = 80, 4
  local barX = textX + getTextManager():MeasureStringX(font, getText('IGUI_invpanel_Remaining')) + 12
  local barY = textY + (fontHeight - barHgt) / 2 + 2
  tooltipUI:setWidth(barX + barWid + 12)
  tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
  tooltipUI:DrawTextCentre(getText(name), tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
  tooltipUI:DrawText(getText('IGUI_invpanel_Remaining'), textX, textY, 1, 1, 1, 1)
  local percent = oIsoObject:getWaterAmount() / oIsoObject:getModData()['waterMax']
  if percent < 0 then percent = 0 end
  if percent > 1 then percent = 1 end
  local amountWidth = math.floor(barWid * percent)
  if percent > 0 then amountWidth = math.max(amountWidth, 1) end
  tooltipUI:DrawTextureScaledColor(nil, barX, barY, amountWidth, barHgt, 0, 0.6, 0, 0.7)
  tooltipUI:DrawTextureScaledColor(nil, barX + amountWidth, barY, barWid - amountWidth, barHgt, 0.15, 0.15, 0.15, 1)
end


Events.DoSpecialTooltip.Add(DoSpecialTooltip)



if isClient() then

  require 'Map/CGlobalObjectSystem'

  --- @class CWaterCollectorSystem : CGlobalObjectSystem
  CWaterCollectorSystem = CGlobalObjectSystem:derive('CWaterCollectorSystem')


  ---
  --- Creates a new JS global object system on client-side
  --- @return  CGlobalObjectSystem New controller instance of this global object system type
  ---
  function CWaterCollectorSystem:new()
    return CGlobalObjectSystem.new(self, ISWaterCollector.defaults.isoData.isoName or ISExtBuildingObject.isoData.isoName)
  end



  ---
  --- Checks, if a given IsoObject is a water collector or not (client-side)
  --- @param isoObject userdata Target buildings JS object
  --- @return boolean True, if the object is linked to this system
  ---
  function CWaterCollectorSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, ISWaterCollector.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) and #(ISWaterCollector.registeredRecipes) > 0 then
      for i=1, #(ISWaterCollector.registeredRecipes) do if ISWaterCollector.registeredRecipes[i] == isoObject:getName() then return true end end
    end
    return false
  end



  ---
  --- Creates a new global object controller on client-side
  --- @param globalObject CGlobalObject Target global object type
  --- @return CGlobalObject New instance of the target object type
  ---
  function CWaterCollectorSystem:newLuaObject(globalObject)
    return CWaterCollectorGlobalObject:new(self, globalObject)
  end


  CGlobalObjectSystem.RegisterSystemClass(CWaterCollectorSystem)




  require 'Map/CGlobalObject'

  --- @class CWaterCollectorGlobalObject : CGlobalObject
  CWaterCollectorGlobalObject = CGlobalObject:derive('CWaterCollectorGlobalObject')


  ---
  --- Creates a new global object on client-side
  --- @param luaSystem CGlobalObjectSystem Global object controller
  --- @param globalObject CGlobalObject Target global object
  --- @return CGlobalObject New instance of the target global object
  ---
  function CWaterCollectorGlobalObject:new(luaSystem, globalObject)
    return CGlobalObject.new(self, luaSystem, globalObject)
  end




  --- @class ISWaterCollectorMenu
  ISWaterCollectorMenu = {}


  ---
  --- Checks whether any right click hit a watercollector global object and if so,
  --- adds its context menu items (including debug options in debug mode)
  --- @param player int ID of the player who did the right click
  --- @param context ISContextMenu The current context menu object
  --- @param worldobjects table Global objects found on the clicked point
  --- @param test boolean Whether this call is a fetch only call for controller support
  ---
  function ISWaterCollectorMenu.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    local found, isoObject = false
    for _,v in ipairs(worldobjects) do
      local square = v:getSquare()
      if square then
        for i=1, square:getObjects():size() do
          local v = square:getObjects():get(i-1)
          if CWaterCollectorSystem.instance:isValidIsoObject(v) then
            isoObject = v
            found = true
            break
          end
        end
      end
      if found then break end
    end
    if not found then return end
    local oPlayer = getSpecificPlayer(player)
    if isoObject and isoObject:getSquare():getBuilding() == oPlayer:getBuilding() then
      -- main option with tooltip
      local name = getText(isoObject:getTable().displayName or ISWaterCollector.defaults.displayName or ISExtBuildingObject.defaults.displayName)
      local subMenu = context:getNew(context)
      local subOption = context:addOptionOnTop(name)
      context:addSubMenu(subOption, subMenu)
      local tooltip = ISWorldObjectContextMenu.addToolTip()  -- make use of the vanilla tooltip pool
      tooltip:setName(name)
      local tx = getTextManager():MeasureStringX(tooltip.font, getText('ContextMenu_WaterName') .. ':') + 20
      tooltip.description = string.format('%s: <SETX:%d> %d / %d', getText('ContextMenu_WaterName'), tx, isoObject:getWaterAmount(), isoObject:getWaterMax())
      tooltip.maxLineWidth = 512
      subOption.toolTip = tooltip
      -- option "pour on ground"
      local optionPour = subMenu:addOption(getText('ContextMenu_Pour_on_Ground'), isoObject, ISWaterCollectorMenu.emptyWaterCollector, oPlayer)
      if not isoObject:hasWater() then
        optionPour.onSelect = nil
        optionPour.notAvailable = true
      end
      -- option "add water from item"
      local oInv = oPlayer:getInventory()
      rainCollectorBarrel = isoObject
      ISWorldObjectContextMenu.addWaterFromItem(test, context, worldobjects, oPlayer, oInv)
      local oldOption = context:getOptionFromName(getText('ContextMenu_AddWaterFromItem'))
      if oldOption ~= nil then
        -- xcopy the option to the correct index
        local newOption
        if context:getOptionFromName('ContextMenu_Drink') ~= nil then
          newOption = context:insertOptionBefore(getText('ContextMenu_Drink'), oldOption.name, oldOption.target, nil)
        else
          newOption = context:insertOptionBefore(getText('ContextMenu_Walk_to'), oldOption.name, oldOption.target, nil)
        end
        context:addSubMenu(newOption, context:getSubMenu(oldOption.subOption))
        context:removeLastOption()    -- the vanilla one was inserted at bottom
      end
      -- add debug options
      if isDebugEnabled() then
        -- if there are no other object debug options, the menu must be recreated
        local debugOption = context:getOptionFromName('Objects')
        if debugOption == nil then
          if context:getOptionFromName('UIs') then
            debugOption = context:insertOptionAfter('UIs', 'Objects', worldobjects)
            debugOption.iconTexture = getTexture('media/ui/BugIcon.png')
          else
            debugOption = context:addDebugOption('Objects', worldobjects)
          end
        end
        local debugSubMenu = ISContextMenu:getNew(context)
        context:addSubMenu( debugOption, debugSubMenu)
        debugSubMenu:addOption(name .. ': Zero Water', isoObject, ISWaterCollectorMenu.OnWaterCollectorZeroWater, oPlayer)
        debugSubMenu:addOption(name .. ': Set Water', isoObject, ISWaterCollectorMenu.OnWaterCollectorSetWater)
      end
    end
  end



  ---
  --- Removes all the water from the water collector
  --- @param obj CGlobalObject Target global object instance
  --- @param oPlayer IsoPlayer Acting player object instance
  ---
  function ISWaterCollectorMenu.emptyWaterCollector(obj, oPlayer)
    if luautils.walkAdj(oPlayer, obj:getSquare()) then
      ISTimedActionQueue.add(ISEmptyRainBarrelAction:new(oPlayer, obj))
    end
  end



  ---
  --- Outsourced part of OnWaterCollectorSetWater - executes the action
  --- @param _ any Target object (nil)
  --- @param button ISButton The clicked button
  --- @param obj CWaterCollectorGlobalObject The global object instance of interest
  ---
  local function OnWaterCollectorConfirm(_, button, obj)
    if button.internal == 'OK' then
      local playerObj = getSpecificPlayer(0)
      local text = button.parent.entry:getText()
      if tonumber(text) then
        local waterAmt = math.min(tonumber(text), obj:getWaterMax())
        waterAmt = math.max(waterAmt, 0.0)
        local args = { x = obj:getX(), y = obj:getY(), z = obj:getZ(), index = obj:getObjectIndex(), amount = waterAmt }
        sendClientCommand(playerObj, 'object', 'setWaterAmount', args)
      end
    end
  end



  ---
  --- Debug option which opens a UI to adjust the water amount of the water collector.
  --- Execution after confirmation is outsourced to a local function for performance
  --- @param obj CWaterCollectorGlobalObject Target global object instance
  ---
  function ISWaterCollectorMenu.OnWaterCollectorSetWater(obj)
    local luaObject = CWaterCollectorSystem.instance:getLuaObjectOnSquare(obj:getSquare())
    if not luaObject then return end
    local modal = ISTextBox:new(0, 0, 280, 180, string.format('Water (0-%d):', obj:getWaterMax()), tostring(obj:getWaterAmount()), nil, OnWaterCollectorConfirm, nil, obj)
    modal:initialise()
    modal:addToUIManager()
  end



  ---
  --- Debug option to set the water amount of the water collector to zero
  --- @param obj CWaterCollectorGlobalObject Target global object instance
  --- @param oPlayer IsoPlayer Acting player object instance
  ---
  function ISWaterCollectorMenu.OnWaterCollectorZeroWater(obj, oPlayer)
    local args = { x = obj:getX(), y = obj:getY(), z = obj:getZ(), index = obj:getObjectIndex(), amount = 0 }
    sendClientCommand(oPlayer, 'object', 'setWaterAmount', args)
  end


  Events.OnFillWorldObjectContextMenu.Add(ISWaterCollectorMenu.OnFillWorldObjectContextMenu)

end




if isServer() then
  require 'Map/SGlobalObjectSystem'

  --- @class SWaterCollectorSystem : SGlobalObjectSystem
  SWaterCollectorSystem = SGlobalObjectSystem:derive('SWaterCollectorSystem')


  ---
  --- Creates a new JS global object system on server-side
  ---
  function SWaterCollectorSystem:new()
    return SGlobalObjectSystem.new(self, ISWaterCollector.defaults.isoData.isoName or ISExtBuilding.isoData.isoName)
  end



  ---
  --- Initialises the controller by defining which fields
  --- of the building object are relevant for the controller
  ---
  function SWaterCollectorSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    self.system:setModDataKeys(ISWaterCollector.defaults.isoData.modDataKeys or ISExtBuildingObject.defaults.isoData.modDataKeys or {})
    self.system:setObjectModDataKeys(ISWaterCollector.defaults.isoData.objectModDataKeys or ISExtBuildingObject.defaults.isoData.objectModDataKeys or {})
    self:convertOldModData()
  end



  ---
  --- Creates a new global object controller (server-side)
  --- @param globalObject SWaterCollectorGlobalObject Target global object type
  ---
  function SWaterCollectorSystem:newLuaObject(globalObject)
    return SWaterCollectorGlobalObject:new(self, globalObject)
  end



  ---
  --- Checks, if a given IsoObject is a water collector or not (server-side)
  --- @param isoObject userdata Target buildings JS object
  --- @return boolean True, if the object is linked to this system
  ---
  function SWaterCollectorSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, ISWaterCollector.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) and #(ISWaterCollector.registeredRecipes) > 0 then
      for i=1, #(ISWaterCollector.registeredRecipes) do
        if ISWaterCollector.registeredRecipes[i] == isoObject:getName() then return true end
      end
    end
    return false
  end



  -- TODO: Checken, ob es auch ohne die geht, immerhin wird es hierfür keine oldModData geben
  ---
  --- For backwards compatibility
  --- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it
  ---
  function SWaterCollectorSystem:convertOldModData()
    if self.system:loadedWorldVersion() ~= -1 then return end
  end



  ---
  --- Increases the water amount of the buildings JS objects
  ---
  function SWaterCollectorSystem:refill()
    for i=1, self:getLuaObjectCount() do
      local luaObject = self:getLuaObjectByIndex(i)
      if luaObject and luaObject.waterAmount < luaObject.waterMax then
        luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + luaObject.addWaterPerAction)
        local isoObject = luaObject:getIsoObject()
        if isoObject then
          isoObject:setWaterAmount(luaObject.waterAmount)
          isoObject:transmitModData()
        end
      end
    end
  end



  ---
  --- Listener-Wrapper to invoke the refill method of each water collector instance
  ---
  local function EveryTenMinutes()
    SWaterCollectorSystem.instance:refill()
  end



  ---
  --- Writes the new water amount from global object to this lua object
  --- @param object IsoObject Target buildings JS object instance
  --- @param _ int Previous water amount
  ---
  local function OnWaterAmountChange(object, _)
    if not object then return end
    local luaObject = SWaterCollectorSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
    if luaObject then luaObject.waterAmount = object:getWaterAmount() end
  end


  SGlobalObjectSystem.RegisterSystemClass(SWaterCollectorSystem)
  Events.EveryTenMinutes.Add(EveryTenMinutes)
  Events.OnWaterAmountChange.Add(OnWaterAmountChange)




  require 'Map/SGlobalObject'

  --- @class SWaterCollectorGlobalObject : SGlobalObject
  SWaterCollectorGlobalObject = SGlobalObject:derive('SWaterCollectorGlobalObject')


  ---
  --- Creates a new global object (server-side)
  --- @param luaSystem SGlobalObjectSystem Global object controller
  --- @param globalObject SGlobalObject Target global object
  ---
  function SWaterCollectorGlobalObject:new(luaSystem, globalObject)
    return SGlobalObject.new(self, luaSystem, globalObject)
  end



  ---
  --- Initialises a new global object
  ---
  function SWaterCollectorGlobalObject:initNew()
    self.waterAmount = ISWaterCollector.defaults.properties.waterAmount
    self.waterMax = ISWaterCollector.defaults.properties.waterMax
    self.addWaterPerAction = ISWaterCollector.defaults.properties.addWaterPerAction
  end



  ---
  --- Transfers the current vales from the buildings JS object to the global object
  --- @param isoObject IsoObject Target buildings JS object instance
  ---
  function SWaterCollectorGlobalObject:stateFromIsoObject(isoObject)
    self.waterAmount = isoObject:getWaterAmount()
    self.waterMax = isoObject:getModData().waterMax
    self.addWaterPerAction = isoObject:getModData().addWaterPerAction
    isoObject:getModData().waterMax = self.waterMax
    isoObject:getModData().addWaterPerAction = self.addWaterPerAction
    isoObject:transmitModData()
  end



  ---
  --- Transfers the current values from the global object to the buildings JS object
  --- @param isoObject IsoObject Target buildings JS object instance
  ---
  function SWaterCollectorGlobalObject:stateToIsoObject(isoObject)
    if not self.waterAmount then self.waterAmount = ISWaterCollector.defaults.properties.waterAmount end
    if not self.waterMax then self.waterMax = ISWaterCollector.defaults.properties.waterMax end
    if not self.addWaterPerAction then self.addWaterPerAction = ISWaterCollector.defaults.properties.addWaterPerAction end
    isoObject:setWaterAmount(self.waterAmount)
    isoObject:getModData().waterMax = self.waterMax
    isoObject:getModData().addWaterPerAction = self.addWaterPerAction
    isoObject:transmitModData()
  end

end



---
--- Initialises the global objects of all existing building JS objects while loading the map
--- @param isoObject IsoObject Target building object JS object instance
---
local function loadGlobalObject(isoObject)
  if not instanceof(isoObject, ISWaterCollector.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) then return end
  SWaterCollectorSystem.instance:loadIsoObject(isoObject)
end



---
--- Checks the recipe definitions for any recipe which uses ISWaterCollector as targetClass
--- and adds it to the registry, so we can differ between those recipes in the system classes
--- and gather the overloaded sprite and name.
---
local function registerWaterCollectors(recipes)
  for _,v in pairs(recipes) do
    if v ~= nil then
      if v.targetClass == nil and type(v) == 'table' then
        registerWaterCollectors(v)
      elseif v.targetClass == 'ISWaterCollector' then
        if isServer() then
          local sprite = v.sprites.sprite or ISWaterCollector.defaults.sprites.sprite or ISExtBuildingObject.defaults.sprites.sprite
          local priority = v.isoData.mapObjectPriority or ISWaterCollector.defaults.isoData.mapObjectPriority or ISExtBuildingObject.defaults.isoData.mapObjectPriority
          MapObjects.OnLoadWithSprite(sprite, loadGlobalObject, priority)
        end
        table.insert(ISWaterCollector.registeredRecipes, v.isoData.isoName or ISWaterCollector.defaults.isoData.isoName or ISExtBuildingObject.defaults.isoData.isoName)
      end
    end
  end
end
registerWaterCollectors(ExtBuildingContextMenu.BuildingRecipes)