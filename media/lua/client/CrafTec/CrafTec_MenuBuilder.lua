--[[
require "Frameworks/Utils_Client"
require "ISUI/ISContextMenu"
--]]

--[[
if not BCCrafTec then BCCrafTec = {} end
-- Erlaube riskante Bauversuche bei mangelnden Skills
BCCrafTec.allowLowerSkill = true;
--]]


---
--- Platziert eine Baustelle
---
--[[
BCCrafTec.startCrafTec = function(player, recipe)
  local crafTec = BCCrafTecObject:new(recipe);
  crafTec.player = player;
  getCell():setDrag(crafTec, player);
end
--]]


---
--- Erzeugt die TimedAction für einen regulären Bau
---
--[[
BCCrafTec.buildCrafTec = function(player, object)
  BCCrafTec.allowLowerSkill = false;
  BCCrafTec.consumeMaterial(player, object);
  if not luautils.walkAdj(getSpecificPlayer(player), object:getSquare()) then return end
  local ta = BCCrafTecTA:new(player, object, false);
  ISTimedActionQueue.add(ta);
end



---
--- Erzeugt die TimedAction für einen risikobehafteten Bau
---
BCCrafTec.buildCrafTecLackSkill = function(player, object)
  BCCrafTecTA.allowLowerSkill = true;
  BCCrafTec.consumeMaterial(player, object);
  if not luautils.walkAdj(getSpecificPlayer(player), object:getSquare()) then return end
  local ta = BCCrafTecTA:new(player, object, false);
  ISTimedActionQueue.add(ta);
end



---
--- Erzeugt die TimedAction für den Abriss einer Baustelle.
---
BCCrafTec.deconstructCrafTec = function(player, object)
  if not luautils.walkAdj(getSpecificPlayer(player), object:getSquare()) then return end
  local ta = BCCrafTecTA:new(player, object, true);
  ISTimedActionQueue.add(ta);
end



---
--- Überträgt die Angaben für ein Bauprojekt in ein Meta-Objekt.
---
BCCrafTec.storeItemInformation = function(recipe, item)
  local data = {};
  if instanceof(item, "IsoWorldInventoryObject") then
    item = item:getItem();
  end
  if instanceof(item, "DrainableComboItem") then
    data.UsedDelta = item:getUsedDelta();
    data.UseDelta = item:getUseDelta();
  end
  if  item.getA                     then  data.A                     =  item:getA()                     end;
  if  item.getR                     then  data.R                     =  item:getR()                     end;
  if  item.getG                     then  data.G                     =  item:getG()                     end;
  if  item.getB                     then  data.B                     =  item:getB()                     end;
  if  item.getName                  then  data.Name                  =  item:getName()                  end;
  if  item.getReplaceOnUse          then  data.ReplaceOnUse          =  item:getReplaceOnUse()          end;
  if  item.getConditionMax          then  data.ConditionMax          =  item:getConditionMax()          end;
  if  item.getTexture               then  data.Texture               =  item:getTexture()               end;
  if  item.getTexturerotten         then  data.Texturerotten         =  item:getTexturerotten()         end;
  if  item.getTextureCooked         then  data.TextureCooked         =  item:getTextureCooked()         end;
  if  item.getTextureBurnt          then  data.TextureBurnt          =  item:getTextureBurnt()          end;
  if  item.getUses                  then  data.Uses                  =  item:getUses()                  end;
  if  item.getAge                   then  data.Age                   =  item:getAge()                   end;
  if  item.getLastAged              then  data.LastAged              =  item:getLastAged()              end;
  if  item.getCookingTime           then  data.CookingTime           =  item:getCookingTime()           end;
  if  item.getMinutesToCook         then  data.MinutesToCook         =  item:getMinutesToCook()         end;
  if  item.getMinutesToBurn         then  data.MinutesToBurn         =  item:getMinutesToBurn()         end;
  if  item.getOffAge                then  data.OffAge                =  item:getOffAge()                end;
  if  item.getOffAgeMax             then  data.OffAgeMax             =  item:getOffAgeMax()             end;
  if  item.getWeight                then  data.Weight                =  item:getWeight()                end;
  if  item.getActualWeight          then  data.ActualWeight          =  item:getActualWeight()          end;
  if  item.getWorldTexture          then  data.WorldTexture          =  item:getWorldTexture()          end;
  if  item.getDescription           then  data.Description           =  item:getDescription()           end;
  if  item.getCondition             then  data.Condition             =  item:getCondition()             end;
  if  item.getOffString             then  data.OffString             =  item:getOffString()             end;
  if  item.getCookedString          then  data.CookedString          =  item:getCookedString()          end;
  if  item.getUnCookedString        then  data.UnCookedString        =  item:getUnCookedString()        end;
  if  item.getBurntString           then  data.BurntString           =  item:getBurntString()           end;
  if  item.getModule                then  data.Module                =  item:getModule()                end;
  if  item.getBoredomChange         then  data.BoredomChange         =  item:getBoredomChange()         end;
  if  item.getUnhappyChange         then  data.UnhappyChange         =  item:getUnhappyChange()         end;
  if  item.getStressChange          then  data.StressChange          =  item:getStressChange()          end;
  if  item.getReplaceOnUseOn        then  data.ReplaceOnUseOn        =  item:getReplaceOnUseOn()        end;
  if  item.getCount                 then  data.Count                 =  item:getCount()                 end;
  if  item.getLightStrength         then  data.LightStrength         =  item:getLightStrength()         end;
  if  item.getLightDistance         then  data.LightDistance         =  item:getLightDistance()         end;
  if  item.getFatigueChange         then  data.FatigueChange         =  item:getFatigueChange()         end;
  if  item.getCurrentCondition      then  data.CurrentCondition      =  item:getCurrentCondition()      end;
  if  item.getCustomMenuOption      then  data.CustomMenuOption      =  item:getCustomMenuOption()      end;
  if  item.getTooltip               then  data.Tooltip               =  item:getTooltip()               end;
  if  item.getDisplayCategory       then  data.DisplayCategory       =  item:getDisplayCategory()       end;
  if  item.getHaveBeenRepaired      then  data.HaveBeenRepaired      =  item:getHaveBeenRepaired()      end;
  if  item.getReplaceOnBreak        then  data.ReplaceOnBreak        =  item:getReplaceOnBreak()        end;
  if  item.getDisplayName           then  data.DisplayName           =  item:getDisplayName()           end;
  if  item.getBreakSound            then  data.BreakSound            =  item:getBreakSound()            end;
  if  item.getAlcoholPower          then  data.AlcoholPower          =  item:getAlcoholPower()          end;
  if  item.getBandagePower          then  data.BandagePower          =  item:getBandagePower()          end;
  if  item.getReduceInfectionPower  then  data.ReduceInfectionPower  =  item:getReduceInfectionPower()  end;
  if  item.getContentsWeight        then  data.ContentsWeight        =  item:getContentsWeight()        end;
  if  item.getEquippedWeight        then  data.EquippedWeight        =  item:getEquippedWeight()        end;
  if  item.getUnequippedWeight      then  data.UnequippedWeight      =  item:getUnequippedWeight()      end;
  if  item.getKeyId                 then  data.KeyId                 =  item:getKeyId()                 end;
  if  item.getRemoteControlID       then  data.RemoteControlID       =  item:getRemoteControlID()       end;
  if  item.getRemoteRange           then  data.RemoteRange           =  item:getRemoteRange()           end;
  if  item.getExplosionSound        then  data.ExplosionSound        =  item:getExplosionSound()        end;
  if  item.getCountDownSound        then  data.CountDownSound        =  item:getCountDownSound()        end;
  if  item.getColorRed              then  data.ColorRed              =  item:getColorRed()              end;
  if  item.getColorGreen            then  data.ColorGreen            =  item:getColorGreen()            end;
  if  item.getColorBlue             then  data.ColorBlue             =  item:getColorBlue()             end;
  if  item.getEvolvedRecipeName     then  data.EvolvedRecipeName     =  item:getEvolvedRecipeName()     end;
  if not recipe.ingredientData then recipe.ingredientData = {} end
  if not recipe.ingredientData[item:getFullType()] then recipe.ingredientData[item:getFullType()]= {} end
  table.insert(recipe.ingredientData[item:getFullType()], data);
end



---
--- Sucht nach dem passenden Material und verbraucht es
---
BCCrafTec.consumeMaterial = function(player, object)
  player = getSpecificPlayer(player);
  local inventory = player:getInventory();
  local recipe = object:getModData()["recipe"];
  local removed = false;
  for part,amount in pairs(recipe.ingredients) do
    if not recipe.ingredientsAdded then recipe.ingredientsAdded = {}; end
    if not recipe.ingredientsAdded[part] then recipe.ingredientsAdded[part] = 0; end
    amount = amount - recipe.ingredientsAdded[part];
    local checkGround = 0;
    -- Wenn Material fehlt, muss es auf dem Boden im Suchradius liegen
    if inventory:getNumberOfItem(part) < amount then
      checkGround = amount - inventory:getNumberOfItem(part);
    end
    for i=1,(amount - checkGround) do
      local item = inventory:FindAndReturn(part);
      BCCrafTec.storeItemInformation(recipe, item);
      inventory:Remove(item);
      recipe.ingredientsAdded[part] = recipe.ingredientsAdded[part] + 1;
    end
    -- Suche so oft wie die Menge an fehlender Materialien...
    if checkGround > 0 then
      -- ... innerhalb 3x3 Zellen um den Spieler herum danach
      for x=math.floor(player:getX())-1,math.floor(player:getX())+1 do
        for y=math.floor(player:getY())-1,math.floor(player:getY())+1 do
          local square = getCell():getGridSquare(x,y,math.floor(player:getZ()));
          local wobs = square and square:getWorldObjects() or nil;
          -- Wenn passendes Material gefunden wird, nutze es für die Baustelle 
          if wobs ~= nil then
            local itemToRemove = {};
            for m=0, wobs:size()-1 do
              local o = wobs:get(m);
              if instanceof(o, "IsoWorldInventoryObject") and o:getItem():getFullType() == part then
                table.insert(itemToRemove, o);
                checkGround = checkGround - 1;
                if checkGround == 0 then
                  break;
                end
              end
            end
            for i,v in pairs(itemToRemove) do
              BCCrafTec.storeItemInformation(recipe, v);
              square:transmitRemoveItemFromSquare(v);
              square:removeWorldObject(v);
              recipe.ingredientsAdded[part] = recipe.ingredientsAdded[part] + 1;
              removed = true
            end
            if checkGround == 0 then
              break;
            end
            itemToRemove = {};
          end
        end
        if checkGround == 0 then
          break;
        end
      end
    end
  end
  if removed then ISInventoryPage.dirtyUI() end
end



--- Erstellt das Kontext-Menü für Bauprojekte
BCCrafTec.makeTooltip = function(player, recipe)
  local toolTip = ISToolTip:new();
  toolTip:initialise();
  toolTip:setName(getText("Tooltip_CrafTec__NewBuilding")..": "..getText(recipe.name));
  local images = BCCrafTec.getImages(getSpecificPlayer(player), recipe);
  toolTip:setTexture(images.west);
  local desc = "";
  local needsTools = false;
  for _,tools in pairs(recipe.tools or {}) do
    if not needsTools then
      needsTools = true;
      desc = desc .. getText("Tooltip_CrafTec__RequiredTools")..": <LINE> ";
    end
    local first = true;
    desc = desc .. "  - ";
    for _,tool in pairs(bcUtils.split(tools, "/")) do
      local item = BCCrafTec.GetItemInstance(tool);
      if not first then
        desc = desc .. " / ";
      end
      local color = "";
      if ISBuildMenu.countMaterial(player, tool) <= 0 then
        color = " <RED> ";
      else
        color = " <GREEN> ";
      end
      desc = desc .. color..item:getDisplayName().." <RGB:1,1,1> ";
      first = false;
    end
    desc = desc .. " <LINE> ";
  end
  if recipe.started then
    -- Tooltip für bereits angelegte Baustellen
    desc = desc .. getText("Tooltip_CrafTec__RequiredMaterial")..": <LINE> ";
    for ing,amount in pairs(recipe.ingredients) do
      local color = "";
      local item = BCCrafTec.GetItemInstance(ing);
      local avail = ISBuildMenu.countMaterial(player, ing);
      if avail + (recipe.ingredientsAdded and recipe.ingredientsAdded[ing] or 0) < amount then
        color = " <RED> ";
      else
        color = " <GREEN> ";
      end
      desc = desc .. "  - "..color..item:getDisplayName()..": "..((recipe.ingredientsAdded and recipe.ingredientsAdded[ing]) or 0).."+"..avail.."/"..amount.." <RGB:1,1,1>  <LINE> ";
    end
  else
    -- Tooltip für die Einträge im Baumenü
    desc = desc .. getText("Tooltip_CrafTec__RequiredMaterial")..": <LINE> ";
    for ing,amount in pairs(recipe.ingredients) do
      local color = "";
      local item = BCCrafTec.GetItemInstance(ing);
      local avail = ISBuildMenu.countMaterial(player, ing);
      if (avail or 0) < amount then
        color = " <RED> ";
      else
        color = " <GREEN> ";
      end
      desc = desc .. "  - "..color..item:getDisplayName()..": "..(avail or 0).."/"..amount.." <RGB:1,1,1>  <LINE> ";
    end
  end
  toolTip.lackProfession = false
  toolTip.lackSkill = false
  for k,profession in pairs(recipe.requirements) do
    if getSpecificPlayer(player):getDescriptor():getProfession() == k then
      desc = desc .. " <GREEN> "..getText(k).." <RGB:1,1,1> <LINE> ";
    elseif k == 'any' then
      desc = desc .. " <GREEN> "..getText("Tooltip_CrafTec__AnyProfession").." <RGB:1,1,1> <LINE> ";
    else
      desc = desc .. " <RED> "..getText(k).." <RGB:1,1,1> <LINE> ";
      toolTip.lackProfession = true
    end
    for k,skill in pairs(profession) do
      if k ~= "any" then
        if getSpecificPlayer(player):getPerkLevel(Perks.FromString(k)) >= skill.level then
          desc = desc .. " <GREEN> "..getText(k).." "..skill["level"].." <RGB:1,1,1> <LINE> ";
        else
          desc = desc .. " <RED> "..getText(k).." "..skill["level"].." <RGB:1,1,1> <LINE> ";
          toolTip.lackSkill = true
        end
      end
      if recipe.started then
        desc = desc .. "    "..getText("Tooltip_CrafTec__Progress")..": "..skill["progress"].." / "..skill["time"].." <LINE> ";
      else
        desc = desc .. "    "..getText("Tooltip_CrafTec__Duration")..": "..skill["time"].." <LINE> ";
      end
    end
  end
  toolTip.description = desc;
  return toolTip;
end



--- Erzeugt ein neues Item-Objekt
BCCrafTec.GetItemInstance = function(type)
  if not BCCrafTec.ItemInstances then BCCrafTec.ItemInstances = {} end
  local item = BCCrafTec.ItemInstances[type];
  if not item then
    item = InventoryItemFactory.CreateItem(type);
    if item then
      BCCrafTec.ItemInstances[type] = item;
      BCCrafTec.ItemInstances[item:getFullType()] = item;
    else
      print("[CrafTec] ERROR! Item not found: "..type);
    end
  end
  return item;
end



--- Fehlende Einträge in den Bauprojekt-Definitionen ergänzen, wenn möglich
BCCrafTec.sanitizeRecipe = function(recipe)
  for _,pval in pairs(recipe.requirements) do
    for _,sval in pairs(pval) do
      sval.progress = sval.progress or 0;
    end
  end
  if not recipe.tools then recipe.tools = {} end
  if not recipe.data then recipe.data = {} end
  if not recipe.data.modData then recipe.data.modData = {} end
end



--- EventHandler für OnFillWorldObjectContextMenu-Event.
--- Erzeugt das CrafTec-Baumenü und entfernt alle Vanilla-Baumenüs
BCCrafTec.WorldMenu = function(player, context, worldObjects)
  context:removeOptionByName(getText("ContextMenu_Build"));
  context:removeOptionByName(getText("ContextMenu_MetalWelding"));
  local firstObject;
  for _,o in ipairs(worldObjects) do
    if not firstObject then firstObject = o end
  end
  worldObjects = firstObject:getSquare():getObjects();
  for i=0,worldObjects:size()-1 do
    local object = worldObjects:get(i);
    if instanceof(object, "IsoThumpable") then
      local md = object:getModData();
      if md.recipe then
        local o = context:addOption(getText("Tooltip_CrafTec__Continue")..": "..getText(md.recipe.name), player, BCCrafTec.buildCrafTec, object);
        o.toolTip = BCCrafTec.makeTooltip(player, md.recipe);
        if o.toolTip.lackSkill then
          context:addOption(getText("Tooltip_CrafTec__Continue")..": "..getText(md.recipe.name).." "..getText("Tooltip_CrafTec__Risky"), player, BCCrafTec.buildCrafTecLackSkill, object);
        end
        local o = context:addOption(getText("Tooltip_CrafTec__Deconstruct")..": "..getText(md.recipe.name), player, BCCrafTec.deconstructCrafTec, object);
        o.toolTip = BCCrafTec.makeTooltip(player, md.recipe);
      end
    end
  end
  local subMenu = ISContextMenu:getNew(context);
  local buildOption = context:addOption(getText("Tooltip_CrafTec__NewBuilding"));
  context:addSubMenu(buildOption, subMenu);
  BCCrafTec.doMenuRecursive(subMenu, BCCrafTec.Recipes, player);
end



--- Durch alle Menüebenen iterieren und Einträge erzeugen
BCCrafTec.doMenuRecursive = function(menu, recipes, player)
  for name,recipe in pairs(recipes) do
    if name ~= "isCategory" then
      if recipe.isCategory then
        local subMenu = ISContextMenu:getNew(menu);
        local subMenuOption = menu:addOption(getText(name));
        menu:addSubMenu(subMenuOption, subMenu);
        BCCrafTec.doMenuRecursive(subMenu, recipe, player);
      else
        BCCrafTec.sanitizeRecipe(recipe);
        local o = menu:addOption(getText(name), player, BCCrafTec.startCrafTec, recipe);
        o.toolTip = BCCrafTec.makeTooltip(player, recipe);
      end
    end
  end
end


Events.OnFillWorldObjectContextMenu.Add(BCCrafTec.WorldMenu);



---
--- Prüfen, ob ein Item aus der Gruppe "Hammer" vorhanden ist, anstatt nur Base.Hammer
---
--local function predicateNotBroken(item)
--  return not item:isBroken()
--end
--local hasHammer = playerInv:containsTagEvalRecurse("Hammer", predicateNotBroken)
--]]
