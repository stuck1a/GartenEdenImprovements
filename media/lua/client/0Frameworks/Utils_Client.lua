require "0Frameworks/Utils_Shared"
require "OptionScreens/MainScreen"
require "ISUI/ISButton"

if not bcUtils then bcUtils = {} end


--
-- Provides direct access to the ResetLua method.
-- Very good for runtime debugging.
--
bcUtils.reloadLua = function()
  getCore():ResetLua(true, "modsChanged")
end


--
-- Adds a button to the games main menu to reload all lua files clientside 
--
bcUtils.initMainMenu = function()
  bcUtils.forceReloadLuaButton = ISButton:new(MainScreen.instance.width-150, 50, 150, 25, "Forcereload LUA", nil, bcUtils.reloadLua);
  bcUtils.forceReloadLuaButton.borderColor = {r=1, g=1, b=1, a=0.1};
  bcUtils.forceReloadLuaButton:ignoreWidthChange();
  bcUtils.forceReloadLuaButton:ignoreHeightChange();
  bcUtils.forceReloadLuaButton:setAnchorLeft(false);
  bcUtils.forceReloadLuaButton:setAnchorRight(true);
  bcUtils.forceReloadLuaButton:setAnchorTop(true);
  bcUtils.forceReloadLuaButton:setAnchorBottom(false);
  MainScreen.instance:addChild(bcUtils.forceReloadLuaButton);
end

Events.OnMainMenuEnter.Add(bcUtils.initMainMenu);


--
-- Polyfill for table.pack
--
if table.pack == nil then
  table.pack = function(...)
    return { n = select("#", ...), ... }
  end
end


--
-- Polyfill for table.unpack
--
if table.unpack == nil then
  table.unpack = function(t, i)
    i = i or 1;
    if t[i] then
      return t[i], unpack(t, i + 1)
    end
  end
end
