spraypaintMenu = {}
spraypaintMenu.ColorSpray = sprayCanConf.list[1]
spraypaintMenu.colorButtons = {}
spraypaintMenu.textureOff = getTexture('media/textures/Icons/Icon_Spraypaint_Menu_off.png')
spraypaintMenu.textureOn = getTexture('media/textures/Icons/Icon_Spraypaint_Menu_on.png')


spraypaintMenu.hideWindow = function(self)
  ISCollapsableWindow.close(self)
  spraypaintMenu.toolbarButton:setImage(spraypaintMenu.textureOff)
end



spraypaintMenu.addTab = function(name)
  spraypaintMenu.mainPanel = ISPanelJoypad:new(0, 75, spraypaintMenu.window:getWidth(), spraypaintMenu.window:getHeight() - spraypaintMenu.window.nested.tabHeight)
  spraypaintMenu.mainPanel:initialise()
  spraypaintMenu.mainPanel:instantiate()
  spraypaintMenu.mainPanel:setAnchorRight(true)
  spraypaintMenu.mainPanel:setAnchorLeft(true)
  spraypaintMenu.mainPanel:setAnchorTop(true)
  spraypaintMenu.mainPanel:setAnchorBottom(true)
  spraypaintMenu.mainPanel:noBackground()
  spraypaintMenu.mainPanel.borderColor = {r=0, g=0, b=0, a=0}
  spraypaintMenu.mainPanel:setScrollChildren(true)
  spraypaintMenu.mainPanel.onJoypadDown = MainOptions.onJoypadDownCurrentTab
  spraypaintMenu.mainPanel.onGainJoypadFocus = MainOptions.onGainJoypadFocusCurrentTab
  spraypaintMenu.mainPanel:addScrollBars()
  spraypaintMenu.window.nested:addView(name, spraypaintMenu.mainPanel)
end



spraypaintMenu.showWindow = function(player, useSprayCan)
  if useSprayCan then
    for _,sprayCan in ipairs(sprayCanConf.list) do
      if useSprayCan and (sprayCan.name == useSprayCan:getType()) then
        spraypaintMenu.ColorSpray = sprayCan
      end
    end
  end
  if spraypaintMenu.window then
    spraypaintMenu.window:setVisible(true)
    spraypaintMenu.toolbarButton:setImage(spraypaintMenu.textureOn)
    return
  end
  local sprayPanel = ISTabPanel:new(100, 100, 4 + (4 * 100), 40 + (5 * 20))
  sprayPanel:initialise()
  sprayPanel:setAnchorBottom(true)
  sprayPanel:setAnchorRight(true)
  sprayPanel.target = self
  sprayPanel:setEqualTabWidth(true)
  sprayPanel:setCenterTabs(true)
  spraypaintMenu.window = sprayPanel:wrapInCollapsableWindow('Spraypaint')
  spraypaintMenu.window.close = spraypaintMenu.hideWindow
  spraypaintMenu.window.closeButton.onmousedown = spraypaintMenu.hideWindow
  spraypaintMenu.window:setResizable(true)
  spraypaintMenu.addTab(getText('UI_Miscellaneous'))
  local x, y = 0, 0
  for _,symbolType in ipairs(shapeMiscConf.list[1].symbolTypes) do
    for _,shape in ipairs(symbolType.shapes) do
      local btn = ISButton:new(2 + (x * 22), 20 + (y * 22), 20, 20, '', nil, spraypaintMenu.onSpray)
      btn:setImage(getTexture(shape.icon))
      btn.render = spraypaintMenu.renderShapeButtonSpray
      btn.player = player
      btn.shape = shape
      spraypaintMenu.mainPanel:addChild(btn)
      x = x + 1
      if x >= 16 then
        y = y + 1
        x = 0
      end
    end
  end
  local inv = getSpecificPlayer(player):getInventory()
  x = 0
  for _,sprayCan in ipairs(sprayCanConf.list) do
    local btn = ISButton:new(2 + (x * 18), 2, 16, 16, '', nil, spraypaintMenu.selectColor)
    btn.player = player
    btn.item = sprayCan
    btn.backgroundColor = { r = sprayCan.red, g = sprayCan.green, b = sprayCan.blue, a = 1.0 }
    spraypaintMenu.colorButtons[sprayCan.name] = btn
    if not inv:FindAndReturn('Base.'..sprayCan.name) then
      btn:setVisible(false)
    end
    spraypaintMenu.mainPanel:addChild(btn)
    x = x + 1
  end
  spraypaintMenu.addTab(getText('UI_Alphabet'))
  x, y = 0, 0
  for _,symbolType in ipairs(shapeAlphabetConf.list[1].symbolTypes) do
    for _,shape in ipairs(symbolType.shapes) do
      local btn = ISButton:new(2 + (x * 22), 20 + (y * 22), 20, 20, '', nil, spraypaintMenu.onSpray)
      btn:setImage(getTexture(shape.icon))
      btn.render = spraypaintMenu.renderShapeButtonSpray
      btn.player = player
      btn.shape = shape
      spraypaintMenu.mainPanel:addChild(btn)
      x = x + 1
      if x >= 16 then
        y = y + 1
        x = 0
      end
    end
  end
  local inv = getSpecificPlayer(player):getInventory()
  x = 0
  for _,sprayCan in ipairs(sprayCanConf.list) do
    local btn = ISButton:new(2 + (x * 18), 2, 16, 16, '', nil, spraypaintMenu.selectColor)
    btn.player = player
    btn.item = sprayCan
    btn.backgroundColor = { r = sprayCan.red, g = sprayCan.green, b = sprayCan.blue, a = 1.0 }
    spraypaintMenu.colorButtons[sprayCan.name] = btn
    if not inv:FindAndReturn('Base.'..sprayCan.name) then
      btn:setVisible(false)
    end
    spraypaintMenu.mainPanel:addChild(btn)
    x = x + 1
  end
  spraypaintMenu.addTab(getText('UI_Numbers'))
  x, y = 0, 0
  for _,symbolType in ipairs(shapeNumbersConf.list[1].symbolTypes) do
    for _,shape in ipairs(symbolType.shapes) do
      local btn = ISButton:new(2 + (x * 22), 20 + (y * 22), 20, 20, '', nil, spraypaintMenu.onSpray)
      btn:setImage(getTexture(shape.icon))
      btn.render = spraypaintMenu.renderShapeButtonSpray
      btn.player = player
      btn.shape = shape
      spraypaintMenu.mainPanel:addChild(btn)
      x = x + 1
      if x >= 16 then
        y = y + 1
        x = 0
      end
    end
  end
  local inv = getSpecificPlayer(player):getInventory()
  x = 0
  for _,sprayCan in ipairs(sprayCanConf.list) do
    local btn = ISButton:new(2 + (x * 18), 2, 16, 16, '', nil, spraypaintMenu.selectColor)
    btn.player = player
    btn.item = sprayCan
    btn.backgroundColor = { r = sprayCan.red, g = sprayCan.green, b = sprayCan.blue, a = 1.0 }
    spraypaintMenu.colorButtons[sprayCan.name] = btn
    if not inv:FindAndReturn('Base.'..sprayCan.name) then
      btn:setVisible(false)
    end
    spraypaintMenu.mainPanel:addChild(btn)
    x = x + 1
  end
  spraypaintMenu.addTab(getText('UI_SpecialChar'))
  x, y = 0, 0
  for _,symbolType in ipairs(shapeSpecialCharsConf.list[1].symbolTypes) do
    for _,shape in ipairs(symbolType.shapes) do
      local btn = ISButton:new(2 + (x * 22), 20 + (y * 22), 20, 20, '', nil, spraypaintMenu.onSpray)
      btn:setImage(getTexture(shape.icon))
      btn.render = spraypaintMenu.renderShapeButtonSpray
      btn.player = player
      btn.shape = shape
      spraypaintMenu.mainPanel:addChild(btn)
      x = x + 1
      if x >= 16 then
        y = y + 1
        x = 0
      end
    end
  end
  local inv = getSpecificPlayer(player):getInventory()
  x = 0
  for _,sprayCan in ipairs(sprayCanConf.list) do
    local btn = ISButton:new(2 + (x * 18), 2, 16, 16, '', nil, spraypaintMenu.selectColor)
    btn.player = player
    btn.item = sprayCan
    btn.backgroundColor = { r = sprayCan.red, g = sprayCan.green, b = sprayCan.blue, a = 1.0 }
    spraypaintMenu.colorButtons[sprayCan.name] = btn
    if not inv:FindAndReturn('Base.'..sprayCan.name) then
      btn:setVisible(false)
    end
    spraypaintMenu.mainPanel:addChild(btn)
    x = x + 1
  end
  spraypaintMenu.window:addToUIManager()
  spraypaintMenu.toolbarButton:setImage(spraypaintMenu.textureOn)
end



spraypaintMenu.renderShapeButtonSpray = function(self)
  self:drawTextureScaledAspect(self.image, self:getWidth() - 20, self:getHeight() - 20, 20, 20, 1, spraypaintMenu.ColorSpray.red, spraypaintMenu.ColorSpray.green, spraypaintMenu.ColorSpray.blue)
end



spraypaintMenu.selectColor = function(_, self)
  spraypaintMenu.ColorSpray = self.item
end



spraypaintMenu.onSpray = function(_, self)
  local player = getSpecificPlayer(self.player)
  local inv = player:getInventory()
  local sprayCanItem = inv:FindAndReturn('Base.'..spraypaintMenu.ColorSpray.name)
  if (not sprayCanItem) or (utils.numUsesLeft(sprayCanItem) < 1) then
    player:Say(getText('UI_SprayPaint_NotHaveThisColor'))
    return
  end
  if player:getSecondaryHandItem() ~= sprayCanItem then
    ISTimedActionQueue.add(ISEquipWeaponAction:new(player, sprayCanItem, 50, false))
  end
  local tag = Tag:new(self.player, sprayCanItem, self.shape.name, spraypaintMenu.ColorSpray.red, spraypaintMenu.ColorSpray.green, spraypaintMenu.ColorSpray.blue)
  getCell():setDrag(tag, player:getPlayerNum())
end




spraypaintMenu.ISITAPerform = ISInventoryTransferAction.perform
ISInventoryTransferAction.perform = function(self)
  spraypaintMenu.ISITAPerform(self)
  spraypaintMenu.updateColorButtons(nil)
end



spraypaintMenu.updateColorButtons = function(object)
  if not spraypaintMenu.window then return end
  local inv = getPlayer():getInventory()
  for _,sprayCan in ipairs(sprayCanConf.list) do
    if inv:FindAndReturn('Base.'..sprayCan.name) then
      spraypaintMenu.colorButtons[sprayCan.name]:setVisible(true)
    else
      spraypaintMenu.colorButtons[sprayCan.name]:setVisible(false)
    end
  end
end



spraypaintMenu.showWindowToolbar = function()
  if spraypaintMenu.window and spraypaintMenu.window:getIsVisible() then
    spraypaintMenu.window:close()
  else
    spraypaintMenu.showWindow(getPlayer():getPlayerNum(), nil)
  end
end



spraypaintMenu.addToolbarButton = function()
  if spraypaintMenu.toolbarButton then return end
  local movableBtn = ISEquippedItem.instance.movableBtn
  spraypaintMenu.toolbarButton = ISButton:new(-5, movableBtn:getY() + movableBtn:getHeight() + 256, 64, 64, nil, nil, spraypaintMenu.showWindowToolbar)
  spraypaintMenu.toolbarButton:setImage(spraypaintMenu.textureOff)
  spraypaintMenu.toolbarButton:setDisplayBackground(false)
  spraypaintMenu.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1}
  ISEquippedItem.instance:addChild(spraypaintMenu.toolbarButton)
  ISEquippedItem.instance:setHeight(math.max(ISEquippedItem.instance:getHeight(), spraypaintMenu.toolbarButton:getY() + 64))
end



Events.OnContainerUpdate.Add(spraypaintMenu.updateColorButtons)
Events.OnCreatePlayer.Add(spraypaintMenu.addToolbarButton)