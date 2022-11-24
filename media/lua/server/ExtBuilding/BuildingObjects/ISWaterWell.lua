if not 'ISExtBuildingObject' then require 'ExtBuilding/BuildingObjects/ISExtBuildingObject' end


--- @class ISWaterWell : ISExtBuildingObject
ISWaterWell = ISExtBuildingObject:derive('ISWaterWell')


ISWaterWell.defaults = {
  displayName = 'ContextMenu_ExtBuilding_Obj__WaterWell',
  buildTime = 700,
  baseHealth = 600,
  mainMaterial = 'stone',   -- decides which skill lvl determines the extra health (allowed is "wood", "metal", "stone" or "glass")
  hasSpecialTooltip = true,
  tooltipDesc = 'Tooltip_ExtBuilding__WaterWell',
  sprites = {
    sprite = 'garteneden_tech_01_0',
    north = 'garteneden_tech_01_1'
  },
  isoData = {
    isoName = 'waterwell',    -- used as name for the iso object and global object system, if there is one
    objectModDataKeys = { 'waterAmount', 'waterMax' },
  },
  properties = {
    waterAmount = 50,
    waterMax = 5000,
  },
  modData = {
    ['keep:' .. utils.concatItemTypes({'Hammer'})] = 'Base.Hammer',
    ['keep:' .. utils.concatItemTypes({'Saw'})] = 'Base.Saw',
    ['keep:' .. utils.concatItemTypes({'DigGrave'})] = 'Base.Shovel',
    ['need:Base.Rope'] = 5,
    ['need:Base.Plank'] = 5,
    ['need:Base.Nails'] = 10,
    ['use:Base.Gravelbag'] = 8,
    ['need:Base.BucketEmpty'] = 1,
    ['requires:Woodwork'] = 7,
    ['requires:Fitness'] = 5,
    ['xp:Woodwork'] = 5,
    ['xp:Fitness'] = 5
  }
}



---
--- Java object constructor - initializes and places a completed water well
--- @param x number Target cell X coordinate (goes from north to south)
--- @param y number Target cell Y coordinate (goes from west to east)
--- @param z number Target cell level (0 = surface, 7 = highest possible layer)
--- @param north boolean Whether the north sprite was chosen
--- @param sprite string Name of the chosen sprite
---
function ISWaterWell:create(x, y, z, north, sprite)
  ISExtBuildingObject.create(self, x, y, z, north, sprite)
  self.javaObject:getModData()['waterMax'] = self.waterMax
  self.javaObject:getModData()['waterAmount'] = self.waterAmount
  self.javaObject:transmitCompleteItemToServer()
  if getCore():getGameMode() ~= 'Multiplayer' then triggerEvent('OnObjectAdded', self.javaObject) end
end



---
--- Lua object constructor - generates a new well object
--- @param player number Target player ID
--- @param recipe table The building definition - used to add/alter class fields/properties/modData
--- @return ISWaterWell BuildingObject instance
---
function ISWaterWell:new(player, recipe)
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
function ISWaterWell:isValid(square)
  -- base rules (valid, walkable, free space, reachable, solid ground, etc)
  if not ISExtBuildingObject.isValid(self, square) then return false end
  -- not in other players safehouses
  if isClient() and SafeHouse.isSafeHouse(square, getSpecificPlayer(self.player):getUsername(), true) then return false end
  return true
end



---
--- Creates the onHover tooltip for water wells showing an amount bar if near enough
--- @param tooltipUI UIElement Tooltip factory
--- @param square IsoGridSquare Clicked square
---
local function DoSpecialTooltip(tooltipUI, square)
  local oPlayer = getSpecificPlayer(0)
  if not oPlayer or oPlayer:getZ() ~= square:getZ() or oPlayer:DistToSquared(square:getX() + 0.5, square:getY() + 0.5) > 4 then return end
  local oIsoWell = CWaterWellSystem.instance:getIsoObjectOnSquare(square)
  if not oIsoWell or not oIsoWell:getModData()['waterMax'] then return end
  local font = UIFont.Small
  local fontHeight = getTextManager():getFontFromEnum(font):getLineHeight()
  tooltipUI:setHeight(6 + fontHeight + 6 + fontHeight + 12)
  local textX, textY = 12, 6 + fontHeight + 6
  local barWid, barHgt = 80, 4
  local barX = textX + getTextManager():MeasureStringX(font, getText('IGUI_invpanel_Remaining')) + 12
  local barY = textY + (fontHeight - barHgt) / 2 + 2
  tooltipUI:setWidth(barX + barWid + 12)
  tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
  tooltipUI:DrawTextCentre(getText(ISWaterWell.defaults.displayName), tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
  tooltipUI:DrawText(getText('IGUI_invpanel_Remaining'), textX, textY, 1, 1, 1, 1)
  local percent = oIsoWell:getWaterAmount() / oIsoWell:getModData()['waterMax']
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

  --- @class CWaterWellSystem : CGlobalObjectSystem
  CWaterWellSystem = CGlobalObjectSystem:derive('CWaterWellSystem')


  ---
  --- Creates a new JS global object system on client-side
  --- @return  CGlobalObjectSystem New controller instance of this global object system type
  ---
  function CWaterWellSystem:new()
    return CGlobalObjectSystem.new(self, ISWaterWell.defaults.isoData.isoName or ISExtBuildingObject.isoData.isoName)
  end



  ---
  --- Checks, if a given IsoObject is a water well or not on client-side
  --- @param isoObject IsoThumpable Target buildings JS object
  --- @return boolean True, if the object is linked to this system
  ---
  function CWaterWellSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, ISWaterWell.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) and isoObject:getName() == ISWaterWell.defaults.isoData.isoName
  end



  ---
  --- Creates a new global object controller on client-side
  --- @param globalObject CGlobalObject Target global object type
  --- @return CGlobalObject New instance of the target object type
  ---
  function CWaterWellSystem:newLuaObject(globalObject)
    return CWaterWellGlobalObject:new(self, globalObject)
  end


  CGlobalObjectSystem.RegisterSystemClass(CWaterWellSystem)




  require 'Map/CGlobalObject'

  --- @class CWaterWellGlobalObject : CGlobalObject
  CWaterWellGlobalObject = CGlobalObject:derive('CWaterWellGlobalObject')


  ---
  --- Creates a new global object on client-side
  --- @param luaSystem SGlobalObjectSystem Global object controller
  --- @param globalObject SGlobalObject Target global object
  --- @return SGlobalObject New instance of the target global object
  ---
  function CWaterWellGlobalObject:new(luaSystem, globalObject)
    return CGlobalObject.new(self, luaSystem, globalObject)
  end




  --- @class ISWaterWellMenu
  ISWaterWellMenu = {}


  ---
  --- Checks whether any right click hit a water well global object and if so,
  --- adds its context menu items (including debug options in debug mode)
  --- @param player int ID of the player who did the right click
  --- @param context ISContextMenu The current context menu object
  --- @param worldobjects table Global objects found on the clicked point
  --- @param test boolean Whether this call is a fetch only call for controller support
  ---
  function ISWaterWellMenu.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    --[[
    TODO: FillGlobalObjectContextMenu-Erzeugung in ExtBuildingObject:create() generalisieren
          Wie bei makeTooltip checken, ob es eine entsprechende Funktion gibt.
          Besser wäre sogar, Callbacks oder zumindest Namen der Funktionen in defaults/recipe zu integrieren.
          Evtl sollte dann ExtBuildingObject und evtl auch ExtBuildingContextMenu in Shared/0Framworks
          verschoben werden, damit nichts required werden muss und trotzdem alles verfügbar ist.
    --]]
    if test and ISWorldObjectContextMenu.Test then return true end
    local found, oWell = false
    for _,obj in ipairs(worldobjects) do
      local square = obj:getSquare()
      if square then
        for i=1, square:getObjects():size() do
          local obj = square:getObjects():get(i-1)
          if CWaterWellSystem.instance:isValidIsoObject(obj) then
            oWell = obj
            found = true
            break
          end
        end
      end
      if found then break end
    end
    if not found then return end
    local oPlayer = getSpecificPlayer(player)
    if oWell and oWell:getSquare():getBuilding() == oPlayer:getBuilding() then
      -- well option with tooltip
      local name = getText(ISWaterWell.defaults.displayName)
      local subMenu = context:getNew(context)
      local subOption = context:addOptionOnTop(name)
      context:addSubMenu(subOption, subMenu)
      local tooltip = ISWorldObjectContextMenu.addToolTip()  -- make use of the vanilla tooltip pool
      tooltip:setName(name)
      local tx = getTextManager():MeasureStringX(tooltip.font, getText('ContextMenu_WaterName') .. ':') + 20
      tooltip.description = string.format('%s: <SETX:%d> %d / %d', getText('ContextMenu_WaterName'), tx, oWell:getWaterAmount(), oWell:getWaterMax())
      tooltip.maxLineWidth = 512
      subOption.toolTip = tooltip
      -- option "pour on ground"
      local optionPour = subMenu:addOption(getText('ContextMenu_Pour_on_Ground'), oWell, ISWaterWellMenu.emptyWaterWell, oPlayer)
      if not oWell:hasWater() then
        optionPour.onSelect = nil
        optionPour.notAvailable = true
      end
      -- option "add water from item"
      local oInv = oPlayer:getInventory()
      rainCollectorBarrel = oWell
      ISWorldObjectContextMenu.addWaterFromItem(test, context, worldobjects, oPlayer, oInv)
      local oldOption = context:getOptionFromName(getText('ContextMenu_AddWaterFromItem'))
      if oldOption ~= nil then
        -- xcopy the option to the correct index
        local newOption = context:insertOptionBefore(getText('ContextMenu_Drink'), oldOption.name, oldOption.target, nil)
        context:addSubMenu(newOption, context:getSubMenu(oldOption.subOption))
        context:removeLastOption()
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
        debugSubMenu:addOption(name .. ': Zero Water', oWell, ISWaterWellMenu.OnWaterWellZeroWater, oPlayer)
        debugSubMenu:addOption(name .. ': Set Water', oWell, ISWaterWellMenu.OnWaterWellSetWater)
      end
    end
  end



  ---
  --- Removes all the water from the well
  --- @param obj CGlobalObject Target global object instance
  --- @param oPlayer IsoPlayer Acting player object instance
  ---
  function ISWaterWellMenu.emptyWaterWell(obj, oPlayer)
    if luautils.walkAdj(oPlayer, obj:getSquare()) then
      ISTimedActionQueue.add(ISEmptyRainBarrelAction:new(oPlayer, obj))
    end
  end



  ---
  --- Outsourced part of OnWaterWellSetWater - executes the action
  --- @param _ any Target object (nil)
  --- @param button ISButton The clicked button
  --- @param obj CWaterWellGlobalObject The global object instance of interest
  ---
  local function OnWaterWellConfirm(_, button, obj)
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
  --- Debug option which opens a UI to adjust the water amount of the well.
  --- Execution after confirmation is outsourced to a local function for performance
  --- @param obj CWaterWellGlobalObject Target global object instance
  ---
  function ISWaterWellMenu.OnWaterWellSetWater(obj)
    local luaObject = CWaterWellSystem.instance:getLuaObjectOnSquare(obj:getSquare())
    if not luaObject then return end
    local modal = ISTextBox:new(0, 0, 280, 180, string.format('Water (0-%d):', obj:getWaterMax()), tostring(obj:getWaterAmount()), nil, OnWaterWellConfirm, nil, obj)
    modal:initialise()
    modal:addToUIManager()
  end



  ---
  --- Debug option to set the water amount of the well to zero
  --- @param obj CWaterWellGlobalObject Target global object instance
  --- @param oPlayer IsoPlayer Acting player object instance
  ---
  function ISWaterWellMenu.OnWaterWellZeroWater(obj, oPlayer)
    local args = { x = obj:getX(), y = obj:getY(), z = obj:getZ(), index = obj:getObjectIndex(), amount = 0 }
    sendClientCommand(oPlayer, 'object', 'setWaterAmount', args)
  end


  Events.OnFillWorldObjectContextMenu.Add(ISWaterWellMenu.OnFillWorldObjectContextMenu)

end




if isServer() then
  require 'Map/SGlobalObjectSystem'

  --- @class SWaterWellSystem : SGlobalObjectSystem
  SWaterWellSystem = SGlobalObjectSystem:derive('SWaterWellSystem')


  ---
  --- Creates a new JS global object system on server-side
  ---
  function SWaterWellSystem:new()
    return SGlobalObjectSystem.new(self, ISWaterWell.defaults.isoData.isoName or ISExtBuilding.isoData.isoName)
  end



  ---
  --- Initialises the controller by defining which fields
  --- of the building object are relevant for the controller
  ---
  function SWaterWellSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    self.system:setModDataKeys(ISWaterWell.defaults.isoData.modDataKeys or ISExtBuildingObject.defaults.isoData.modDataKeys or {})
    self.system:setObjectModDataKeys(ISWaterWell.defaults.isoData.objectModDataKeys or ISExtBuildingObject.defaults.isoData.objectModDataKeys or {})
    self:convertOldModData()
  end



  ---
  --- Creates a new global object controller on server-side
  --- @param globalObject SWaterWellGlobalObject Target global object type
  ---
  function SWaterWellSystem:newLuaObject(globalObject)
    return SWaterWellGlobalObject:new(self, globalObject)
  end



  ---
  --- Checks, if a given IsoObject is a water well or not on server-side
  --- @param isoObject IsoObject Target buildings JS object
  --- @return boolean True, if the object is linked to this system
  ---
  function SWaterWellSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, (ISWaterWell.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType)) and isoObject:getName() == (ISWaterWell.defaults.isoData.isoName or ISExtBuildingObject.defaults.isoData.isoName)
  end



  ---
  --- For backwards compatibility
  --- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it
  ---
  function SWaterWellSystem:convertOldModData()
    if self.system:loadedWorldVersion() ~= -1 then return end
  end



  ---
  --- Increases the water amount of the buildings JS objects
  ---
  function SWaterWellSystem:refill()
    for i=1, self:getLuaObjectCount() do
      local luaObject = self:getLuaObjectByIndex(i)
      if luaObject and luaObject.waterAmount < luaObject.waterMax then
        luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + 5)
        local isoObject = luaObject:getIsoObject()
        if isoObject then
          isoObject:setWaterAmount(luaObject.waterAmount)
          isoObject:transmitModData()
        end
      end
    end
  end



  ---
  --- Listener-Wrapper to invoke the refill method of each water well instance
  ---
  local function EveryTenMinutes()
    SWaterWellSystem.instance:refill()
  end



  ---
  --- Writes the new water amount from global object to this lua object
  --- @param object IsoObject Target buildings JS object instance
  --- @param _ int Previous water amount
  ---
  local function OnWaterAmountChange(object, _)
    if not object then return end
    local luaObject = SWaterWellSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
    if luaObject then luaObject.waterAmount = object:getWaterAmount() end
  end


  SGlobalObjectSystem.RegisterSystemClass(SWaterWellSystem)
  Events.EveryTenMinutes.Add(EveryTenMinutes)
  Events.OnWaterAmountChange.Add(OnWaterAmountChange)




  require 'Map/SGlobalObject'

  --- @class SWaterWellGlobalObject : SGlobalObject
  SWaterWellGlobalObject = SGlobalObject:derive('SWaterWellGlobalObject')


  ---
  --- Creates a new global object on server-side
  --- @param luaSystem SGlobalObjectSystem Global object controller
  --- @param globalObject SGlobalObject Target global object
  ---
  function SWaterWellGlobalObject:new(luaSystem, globalObject)
    return SGlobalObject.new(self, luaSystem, globalObject)
  end



  ---
  --- Initialises a new global object
  ---
  function SWaterWellGlobalObject:initNew()
    self.waterAmount = ISWaterWell.defaults.properties.waterAmount
    self.waterMax = ISWaterWell.defaults.properties.waterMax
  end



  ---
  --- Transfers the current vales from the buildings JS object to the global object
  --- @param isoObject IsoObject Target buildings JS object instane
  ---
  function SWaterWellGlobalObject:stateFromIsoObject(isoObject)
    self.waterAmount = isoObject:getWaterAmount()
    self.waterMax = isoObject:getModData().waterMax
    isoObject:getModData().waterMax = self.waterMax
    isoObject:transmitModData()
  end



  ---
  --- Transfers the current values from the global object to the buildings JS object
  --- @param isoObject IsoObject Target buildings JS object instance
  ---
  function SWaterWellGlobalObject:stateToIsoObject(isoObject)
    if not self.waterAmount then self.waterAmount = ISWaterWell.defaults.properties.waterAmount end
    if not self.waterMax then self.waterMax = ISWaterWell.defaults.properties.waterMax end
    isoObject:setWaterAmount(self.waterAmount)
    isoObject:getModData().waterMax = self.waterMax
    isoObject:transmitModData()
  end




  ---
  --- Initialises the global objects of all existing building JS objects while loading the map
  --- @param isoObject IsoObject Target building object JS object instance
  ---
  local function loadGlobalObject(isoObject)
    if not instanceof(isoObject, ISWaterWell.defaults.isoData.isoType or ISExtBuildingObject.defaults.isoData.isoType) then return end
    SWaterWellSystem.instance:loadIsoObject(isoObject)
  end

  MapObjects.OnLoadWithSprite(ISWaterWell.defaults.sprites.sprite or ISExtBuildingObject.defaults.sprites.sprite, loadGlobalObject, ISWaterWell.defaults.isoData.mapObjectPriority or ISExtBuildingObject.defaults.isoData.mapObjectPriority)

end