--- @class ExtBuildingContextMenu
ExtBuildingContextMenu = ExtBuildingContextMenu or {}


local function predicateNotBroken(item)
  return not item:isBroken()
end


---
--- EventHandler which will remove any vanilla build menu
--- and therefore insert the new build menu
--- @param player number Target player id
--- @param context ISContextMenu Root context menu object
--- @param worldobjects table List of world objects at cursor position
---
ExtBuildingContextMenu.doMenu = function(player, context, worldobjects)
  --context:removeOptionByName(getText('ContextMenu_MetalWelding'))
  if ISBuildMenu.haveSomethingtoBuild(player) then  -- TODO: Simply check whether the vanilla entry exist might be faster
    local oBuildOption = context:insertOptionAfter(getText('ContextMenu_Build'), getText('ContextMenu_Build'))
    --context:removeOptionByName(getText('ContextMenu_Build')) --TODO: Uncomment again after debugging vanilla all implementations
    local oSubMenu = ISContextMenu:getNew(context)
    context:addSubMenu(oBuildOption, oSubMenu)
    -- replace vanilla toolTips of multi stage buildings
    local oPlayer = getSpecificPlayer(player)
    local oInv = oPlayer:getInventory()
    local thump, square = nil, nil
    for _, v in ipairs(worldobjects) do
      square = v:getSquare()
      if instanceof(v, 'IsoThumpable') and not v:isDoor() then
        if not MultiStageBuilding.getStages(oPlayer, v, ISBuildMenu.cheat):isEmpty() then
          thump = v
        end
      end
    end
    if thump then
      local stages = MultiStageBuilding.getStages(oPlayer, thump, ISBuildMenu.cheat)
      if not stages:isEmpty() then
        for i=0, stages:size() - 1 do
          local stage = stages:get(i)
          local option = context:getOptionFromName(stage:getDisplayName())
          local sRed, sGreen, sWhite = '<RGB:.9,0,0>', '<RGB:0,0.7,0>', '<RGB:1,1,1>'
          local sPen = sWhite
          local getText, format, tonumber, predicateMaterial, GetItemInstance, buildUtil = getText, string.format, tonumber, buildUtil.predicateMaterial, ISBuildMenu.GetItemInstance, buildUtil
          if option then
            local groundItems = buildUtil.getMaterialOnGround(oPlayer:getSquare())
            local groundItemCounts = buildUtil.getMaterialOnGroundCounts(groundItems)
            local groundItemUses = buildUtil.getMaterialOnGroundUses(groundItems)
            local skills, recipe, tools, items = stage:getPerksLua(), stage:getKnownRecipe(), stage:getItemsToKeep(), stage:getItemsLua()
            local desc = ' <LEFT> ' .. getText('Tooltip_ExtBuilding__' .. stage:getRecipeName()) .. ' <BR> '
            -- required skills and recipes
            local headlineSet = false
            for k, v in pairs(skills) do
              if not headlineSet then desc = format('%s <H2> %s:', desc, getText('Tooltip_ExtBuilding__RequiredSkills')); headlineSet = true end
              local perk = PerkFactory.getPerk(k)
              local plrLvl = oPlayer:getPerkLevel(perk)
              if plrLvl < tonumber(v) then sPen = sRed else sPen = sGreen end
              desc = format('%s <LINE> <TEXT> %s %s %d/%d', desc, sPen, perk:getName(), plrLvl, tonumber(v))
            end
            if recipe then
              if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredSkills')); headlineSet = true end
              if oPlayer:isRecipeKnown(recipe) then sPen = sGreen else sPen = sRed end
              desc = format('%s <LINE> <TEXT> %s %s', desc, sPen, getText('Tooltip_vehicle_requireRecipe', getRecipeDisplayName(recipe)))
            end
            -- required tools
            headlineSet = false
            for i=0, tools:size()-1 do
              local toolString = tools:get(i)
              if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredTools')); headlineSet = true end
              local tool = GetItemInstance(toolString)
              if tool then
                local found = oInv:containsTypeEvalRecurse(toolString, predicateNotBroken)
                if not found and groundItems[toolString] then
                  for _,item3 in ipairs(groundItems[toolString]) do
                    if predicateNotBroken(item3) then found = true; break end
                  end
                end
                if found then sPen = sGreen else sPen = sRed end
                desc = format('%s <LINE> <TEXT> %s %s', desc, sPen, tool:getName())
              end
            end
            -- required materials
            headlineSet = false
            for k, v in pairs(items) do
              local item = GetItemInstance(k)
              -- drainables
              if item then
                if instanceof(item, 'DrainableComboItem') then
                  if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials')); headlineSet = true end
                  local useLeft = oInv:getUsesTypeRecurse(k)
                  if groundItemUses[k] then useLeft = useLeft + groundItemUses[k] end
                  if useLeft >= tonumber(v) then sPen = sGreen else sPen = sRed end
                  desc = format('%s <LINE> <TEXT> %s %s %d/%d', desc, sPen, item:getName(), useLeft, tonumber(v))
                else
                  -- regular
                  if not headlineSet then desc = format('%s %s <LINE> <LINE> <H2> %s:', desc, sWhite, getText('Tooltip_ExtBuilding__RequiredMaterials')); headlineSet = true end
                  local sum = oInv:getCountTypeEvalRecurse(k, predicateMaterial)
                  if groundItemCounts[k] then sum = sum + groundItemCounts[k] end
                  if k == 'Base.Nails' then
                    sum = sum + oInv:getCountTypeEvalRecurse('Base.NailsBox', predicateMaterial) * 100
                    if groundItemCounts['Base.NailsBox'] then sum = sum + groundItemCounts['Base.NailsBox'] * 100 end
                  end
                  if sum >= tonumber(v) then sPen = sGreen else sPen = sRed end
                  desc = format('%s <LINE> <TEXT> %s %s %d/%d', desc, sPen, item:getName(), sum, tonumber(v))
                end
              end
            end
            option.toolTip.description = desc
          end
         end
      end
    end
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