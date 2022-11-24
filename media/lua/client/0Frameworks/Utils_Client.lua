require '0Frameworks/Utils_Shared'
require 'OptionScreens/MainScreen'
require 'ISUI/ISButton'

if not utils then utils = {} end


---
--- Provides direct access to the ResetLua method.
--- Shortcut for runtime debugging.
---
utils.reloadLua = function()
  getCore():ResetLua(true, 'modsChanged')
end



---
--- Adds a button to the games main menu to reload all lua files client-side
---
utils.initMainMenu = function()
  utils.forceReloadLuaButton = ISButton:new(MainScreen.instance.width-150, 50, 150, 25, 'Reload Lua (Client)', nil, utils.reloadLua)
  utils.forceReloadLuaButton.borderColor = {r=1, g=1, b=1, a=0.1}
  utils.forceReloadLuaButton:ignoreWidthChange()
  utils.forceReloadLuaButton:ignoreHeightChange()
  utils.forceReloadLuaButton:setAnchorLeft(false)
  utils.forceReloadLuaButton:setAnchorRight(true)
  utils.forceReloadLuaButton:setAnchorTop(true)
  utils.forceReloadLuaButton:setAnchorBottom(false)
  MainScreen.instance:addChild(utils.forceReloadLuaButton)
end

Events.OnMainMenuEnter.Add(utils.initMainMenu)



---
--- Polyfill for table.pack
---
if table.pack == nil then
  table.pack = function(...)
    return { n = select('#', ...), ... }
  end
end



---
--- Maps the vanilla Polyfill unpack to table.unpack
---
if table.unpack == nil then
  table.unpack = function(t, i)
    i = i or 1;
    if t[i] then return t[i], unpack(t, i + 1) end
  end
end