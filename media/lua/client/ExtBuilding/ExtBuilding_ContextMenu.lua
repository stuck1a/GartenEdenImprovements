--- @class ExtBuildingContextMenu
ExtBuildingContextMenu = ExtBuildingContextMenu or {}


---
--- EventHandler which will remove any vanilla build menu
--- and therefore insert the new build menu
--- @param player number Target player id
--- @param context ISContextMenu Root context menu object
---
ExtBuildingContextMenu.doMenu = function(player, context)
  context:removeOptionByName(getText('ContextMenu_MetalWelding'))
  if ISBuildMenu.haveSomethingtoBuild(player) then
    local oBuildOption = context:insertOptionAfter(getText('ContextMenu_Build'), getText('ContextMenu_Build'))
    context:removeOptionByName(getText('ContextMenu_Build'))
    local oSubMenu = ISContextMenu:getNew(context)
    context:addSubMenu(oBuildOption, oSubMenu)
    ExtBuildingContextMenu.doMenuRecursive(oSubMenu, ExtBuildingContextMenu.BuildingRecipes, player)
  end
end


---
--- Handler which will be called when clicked on
--- a building recipe within the context menu
--- @param player IsoPlayer Target player object
--- @param classObj ISBuildingObject Target building object
--- @param recipe table Selected building definition
---
ExtBuildingContextMenu.onClickEntry = function(player, classObj, recipe)
  local obj = classObj:new(player, recipe)
  getCell():setDrag(obj, player)
end


---
--- Iterate through the given building recipes table and create
--- all necessary menu items from it
--- @param menu ISContextMenu First level menu to which the entries will be added to
--- @param defTable table Build menu entries
--- @param player number Target player id
---
ExtBuildingContextMenu.doMenuRecursive = function(menu, defTable, player)
  for name, recipe in pairs(defTable) do
    if type(name) == 'string' then
      -- submenus
      local subMenu = ISContextMenu:getNew(menu)
      local subMenuOption = menu:addOption(getText(name))
      menu:addSubMenu(subMenuOption, subMenu)
      ExtBuildingContextMenu.doMenuRecursive(subMenu, recipe, player)
    else
      -- building recipes
      local targetClass = _G[recipe.targetClass] or ISExtBuildingObject
      if targetClass ~= nil then
        local recipeName
        if recipe.displayName ~= nil then recipeName = recipe.displayName elseif targetClass.defaults.displayName ~= nil then recipeName = targetClass.defaults.displayName else recipeName = ISExtBuildingObject.defaults.displayName end
        local option = menu:addOption(getText(recipeName), player, ExtBuildingContextMenu.onClickEntry, targetClass, recipe)
        option.toolTip = targetClass.makeTooltip(player, option, recipe, targetClass)
      else
        print(string.format('[ExtBuilding] Entry contains invalid building object class "%s" - SKIPPED', recipe.targetClass or 'nil'))
      end
    end
  end
end

Events.OnFillWorldObjectContextMenu.Add(ExtBuildingContextMenu.doMenu)