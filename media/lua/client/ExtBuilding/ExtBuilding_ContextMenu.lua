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
  if ISBuildMenu.haveSomethingtoBuild(player) then  -- TODO: Simply check whether the vanilla entry exist might be faster
    local oBuildOption = context:insertOptionAfter(getText('ContextMenu_Build'), getText('ContextMenu_Build'))
    --context:removeOptionByName(getText('ContextMenu_Build')) --TODO: Uncomment again after debugging vanilla all implementations
    local oSubMenu = ISContextMenu:getNew(context)
    context:addSubMenu(oBuildOption, oSubMenu)
    ExtBuildingContextMenu.doMenuRecursive(oSubMenu, ExtBuildingContextMenu.BuildingRecipes, player, getSpecificPlayer(player))
  end
end


---
--- Handler which will be called when clicked on
--- a building recipe within the context menu
--- @param oPlayer IsoPlayer Target player object
--- @param oClass ISBuildingObject Target building object
--- @param recipe table Selected building definition
---
ExtBuildingContextMenu.onClickEntry = function(oPlayer, oClass, recipe)
  local obj = oClass:new(oPlayer, recipe)
  getCell():setDrag(obj, oPlayer)
end


---
--- Iterate through the given building recipes table and create
--- all necessary menu items from it
--- @param menu ISContextMenu First level menu to which the entries will be added to
--- @param defTable table Build menu entries
--- @param player int Target player id
--- @param oPlayer IsoPlayer Target player object
---
ExtBuildingContextMenu.doMenuRecursive = function(menu, defTable, player, oPlayer)
  for name, recipe in pairs(defTable) do
    if type(name) == 'string' then
      -- submenus
      local subMenu = ISContextMenu:getNew(menu)
      local subMenuOption = menu:addOption(getText(name))
      menu:addSubMenu(subMenuOption, subMenu)
      ExtBuildingContextMenu.doMenuRecursive(subMenu, recipe, player, oPlayer)
    else
      -- building recipes
      local oClass = _G[recipe.targetClass] or ISExtBuildingObject
      if oClass ~= nil then
        local requiresRecipe = recipe.requiresRecipe or oClass.defaults.requiresRecipe or ISExtBuildingObject.defaults.requiresRecipe or false
        if requiresRecipe == false or oPlayer:isRecipeKnown(requiresRecipe) or ISBuildMenu.cheat then
          local displayName = recipe.displayName or oClass.defaults.displayName or ISExtBuildingObject.defaults.displayName or 'RECIPE ERROR'
          local option = menu:addOption(getText(displayName), player, ExtBuildingContextMenu.onClickEntry, oClass, recipe)
          option.toolTip = oClass.makeTooltip(oPlayer, option, recipe, oClass)
        end
      else
        print(string.format('[ExtBuilding] Entry contains invalid building object class "%s" - SKIPPED', recipe.targetClass or 'nil'))
      end

    end
  end
end

Events.OnFillWorldObjectContextMenu.Add(ExtBuildingContextMenu.doMenu)