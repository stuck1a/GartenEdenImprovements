function setTrapDown(items, result, player)
  local theTraptoSet;
  for i=0, items:size()-1 do theTraptoSet = items:get(i) end
  local AlreadyTrapOnSquare = false
  if player:getCurrentSquare():getModData().isTrapSet == true then
    local Objs = player:getCurrentSquare():getObjects()
    for i=0, Objs:size()-1 do
      if Objs:get(i):getWorldObjectIndex() ~= -1 then
        if (Objs:get(i):getItem() ~= nil) and (Objs:get(i):getItem():getModData().isSet == true or Objs:get(i):getModData().isSet == true) then
          AlreadyTrapOnSquare = true
        end
      end
    end
  end
  if AlreadyTrapOnSquare == false then
    player:getCurrentSquare():getModData().isTrapSet = true
    player:getCurrentSquare():transmitModdata()
    player:getInventory():Remove(theTraptoSet)
    theTraptoSet = player:getCurrentSquare():AddWorldInventoryItem(theTraptoSet, 0.5, 0.5, 0)
    player:getModData().immuneToTrap = true
    theTraptoSet:getModData().isSet = true
    theTraptoSet:getWorldItem():getModData().isSet = true
    theTraptoSet:getWorldItem():transmitModData()
    sendClientCommand("Traps", "SetTrap", player, {x = player:getX(), y = player:getY(), z = player:getZ(), trapid = theTraptoSet:getWorldItem():getKeyId()})
  else
    player:Say(getText("UI_Traps_AlreadyPlaced"))
  end
end


local function getRandomBodyPart(player)
  local parttohurt;
  local r = ZombRand(11)
  if r == 0 then parttohurt = BodyPartType.LowerLeg_L
  elseif r == 1 then parttohurt = BodyPartType.LowerLeg_R
  elseif r == 2 then parttohurt = BodyPartType.UpperLeg_R
  elseif r == 3 then parttohurt = BodyPartType.UpperLeg_L
  elseif r == 4 then parttohurt = BodyPartType.UpperArm_R
  elseif r == 5 then parttohurt = BodyPartType.UpperArm_L
  elseif r == 6 then parttohurt = BodyPartType.Head
  elseif r == 7 then parttohurt = BodyPartType.Torso_Lower
  elseif r == 8 then parttohurt = BodyPartType.Torso_Upper
  elseif r == 9 then parttohurt = BodyPartType.ForeArm_L
  else parttohurt = BodyPartType.ForeArm_R end
  return player:getBodyDamage():getBodyPart(parttohurt)
end


local function getTextureFor(name)
  local item = getPlayer():getInventory():AddItem(name)
  local texture = item:getTexture()
  getPlayer():getInventory():Remove(item)
  return texture
end


local function handleTrap(player, trap)
  if (trap:getType() == "BearTrap") and (trap:getModData().isSet == true or trap:getWorldItem():getModData().isSet == true) then
    local BP
    if ZombRand(2) == 0 then
      BP = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L)
    else
      BP = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R)
    end
    if ZombRand(2) == 0 then
      BP:setFractureTime(100)
    else
      BP:generateDeepWound()
    end
    BP:AddDamage(ZombRand(25) + 40)
    trap:getModData().isSet = false
    trap:getWorldItem():getModData().isSet = false
    player:getCurrentSquare():getModData().isTrapSet = false
    player:getCurrentSquare():transmitModdata()
    player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem())
    trap:getWorldItem():removeFromSquare()
    local newtrap = player:getInventory():AddItem("Base."..trap:getType().."Closed")
    player:getCurrentSquare():AddWorldInventoryItem(newtrap, 0.5, 0.5, 0);
    player:getInventory():Remove(newtrap)
    getSoundManager():PlayWorldSound("Traps_BearTrap", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false)
  elseif (trap:getType() == "SpikeTrap") and (trap:getModData().isSet == true) then
    local BP
    BP = player:getBodyDamage():getBodyPart(BodyPartType.Foot_L)
    BP:generateDeepWound();
    BP = player:getBodyDamage():getBodyPart(BodyPartType.Foot_R)
    BP:generateDeepWound()
    BP:AddDamage(ZombRand(25) + 40)
    trap:getModData().isSet = false
    trap:getWorldItem():getModData().isSet = false
    player:getCurrentSquare():getModData().isTrapSet = false
    player:getCurrentSquare():transmitModdata()
    player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem())
    trap:getWorldItem():removeFromSquare()
    local newtrap = player:getInventory():AddItem("Base."..trap:getType().."Closed")
    player:getCurrentSquare():AddWorldInventoryItem(newtrap, 0.5, 0.5, 0)
    player:getInventory():Remove(newtrap);
    getSoundManager():PlayWorldSound("Traps_Stabbing", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false)
  elseif (trap:getType() == "PropaneTrap") and (trap:getModData().isSet == true) then
    local BP;
    BP = getRandomBodyPart(player)
    BP:AddDamage(ZombRand(25) + 40)
    BP:setBurned()
    BP = getRandomBodyPart(player)
    BP:AddDamage(ZombRand(25) + 40)
    BP:setBurned()
    trap:getModData().isSet = false
    trap:getWorldItem():getModData().isSet = false
    player:getCurrentSquare():getModData().isTrapSet = false
    player:getCurrentSquare():transmitModdata()
    player:getCurrentSquare():explode()
    player:getCurrentSquare():explode()
    player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem())
    trap:getWorldItem():removeFromSquare()
    getSoundManager():PlayWorldSound("Traps_Explosion", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false)
  end
end


local function checkForTrap(player)
  if player:getCurrentSquare() ~= nil then
    if (player:getCurrentSquare():getModData().isTrapSet == true) and (player:getModData().immuneToTrap ~= true) then
      local Objs = player:getCurrentSquare():getObjects()
      for i=0, Objs:size()-1 do
        if Objs:get(i):getWorldObjectIndex() ~= -1 then
          if (Objs:get(i):getItem() ~= nil) and (Objs:get(i):getItem():getModData().isSet == true or Objs:get(i):getModData().isSet == false) then
            handleTrap(player,Objs:get(i):getItem())
          end
        end
      end
    elseif (player:getCurrentSquare():getModData().isTrapSet == nil) or (player:getCurrentSquare():getModData().isTrapSet == false) or (player:getModData().immuneToTrap == nil) then
      player:getModData().immuneToTrap = false
    end
  end
end


local function trapupdateThePlayer(player)
  checkForTrap(player)
  player:getInventory():Remove("Nothing")
end


Events.OnPlayerUpdate.Add(trapupdateThePlayer)
