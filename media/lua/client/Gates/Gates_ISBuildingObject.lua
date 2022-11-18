NSSprite = "carpentry_02_80";
EWSprite = "carpentry_02_81";
PoleSprite = "carpentry_02_83"; --PoleSprite = "fencing_01_13";

GateProperties = {
  stopOnWalk = false,
  stopOnRun = false,
  caloriesModifier = 1,
  maxTime = 0 ,
  animationDuration = 2,
  soundPlayed = "shoveling",
  thumpDmg = 8,
  maxHealth = 200,
  animationPonderator = 12
}

function isModEnabled(modname)
  local actmods = getActivatedMods();
  for i=0, actmods:size()-1, 1 do
    if actmods:get(i) == modname then
      return true;
    end
  end
  return false;
end

function AbsoluteValue(number)
  if(number < 0) then
    return (number * -1);
  else
    return number;
  end
end
function StrReplace(thisString, findThis, replaceWithThis)
  return string.gsub(thisString, "("..findThis..")", replaceWithThis);
end

function IsIn(big,small)
  local temp = StrReplace(big,small,"");
  if(temp == big) then
    return false
  else
    return true;
  end
end

function GategetNextSquare(square, dir)
  if(not square) then return false end
  if(dir == 'N') then
    return getCell():getGridSquare(square:getX(),square:getY()-1,square:getZ());
  elseif(dir == 'S') then
    return getCell():getGridSquare(square:getX(),square:getY()+1,square:getZ());
  elseif(dir == 'E') then
    return getCell():getGridSquare(square:getX()+1,square:getY(),square:getZ());
  elseif(dir == 'W') then
    return getCell():getGridSquare(square:getX()-1,square:getY(),square:getZ());
  elseif(dir == 'U') then
    return getCell():getOrCreateGridSquare(square:getX(),square:getY(),square:getZ()+1);
  elseif(dir == 'D') then
    return getCell():getOrCreateGridSquare(square:getX(),square:getY(),square:getZ()-1);
  end
end



function addWallOnSquare(square, sprite, isNorth)
  if(square == nil) then return false end
  local Wall = newWall(square, sprite, isNorth);
  square:AddSpecialObject(Wall);
  Wall:transmitCompleteItemToServer();
end

function addPoleOnSquare(square, isNorth)
  if(square == nil) then return false end
  local Wall = newWall(square, PoleSprite, isNorth)
  square:AddSpecialObject(Wall)
  Wall:transmitCompleteItemToServer()
end

function removeWallOnSquare(square, obj)
  if obj and square then
    square:transmitRemoveItemFromSquare(obj)
    square:RemoveTileObject(obj)
  end
end


function newWall(square, sprite, isNorth)
  local Wall = IsoThumpable.new(getCell(), square, sprite, isNorth, {})
  Wall:setCanPassThrough(false)
  Wall:setCanBarricade(false)
  Wall:setThumpDmg(GateProperties.thumpDmg)
  Wall:setMaxHealth(GateProperties.maxHealth)
  Wall:setIsContainer(false)
  Wall:setIsDoor(false)
  Wall:setIsDoorFrame(false)
  Wall:setCrossSpeed(1.0)
  Wall:setBlockAllTheSquare(false)
  Wall:setName("Object")
  Wall:setIsDismantable(false)
  Wall:setCanBePlastered(false)
  Wall:setIsHoppable(false)
  if (isModEnabled("LogWallUpgrade")) then
    Wall:setIsThumpable(false)
  else
    Wall:setIsThumpable(true)
  end
  Wall:setModData({})
  Wall:setBreakSound("breakdoor");
  return Wall;
end

function GateCheckForLogWallGate(player, context, worldobjects, test)
  GateOptionShown = false;
  local player = getSpecificPlayer(player);
  local square = player:getCurrentSquare();
  GateFloorObjectMenu(square,context);
  local fsquare = square:getTileInDirection(player:getDir());
  if(fsquare) then GateFloorObjectMenu(fsquare,context); end

end

function SquareHasLogWall(square)
  if(square:getModData().isGate) then return false end
  for i=0,square:getObjects():size()-1 do
    local o = square:getObjects():get(i)
    if (tostring(o:getType()) == "wall") and (o:getSprite():getName() == EWSprite) or (o:getSprite():getName() == NSSprite) then
      return o;
    end
  end
  return false;
end

function SquareHasGate(square)
  if(square == nil) then
    print("SquareHasGate received a nil square");
    return false;
  end
  for i=0,square:getObjects():size()-1 do
    local o = square:getObjects():get(i)
    if (tostring(o:getType()) == "wall") and (square:getModData().isGate) and (o:getSprite():getName() == NSSprite or o:getSprite():getName() == EWSprite) then
      return o;
    end
  end
  return false;
end


function GateFloorObjectMenu(square,context)
  if(square ~= nil) then
    for i=0,square:getObjects():size()-1 do
      local o = square:getObjects():get(i)
      local sprite = o:getSprite()
      print(tostring(not GateOptionShown ) ..",".. tostring((o:getType()) ) ..",".. tostring(CanCreateGate(square)) ..",".. tostring(square:getModData().isGate ~= true))
      print(tostring((sprite ~= nil)) ..",".. tostring((sprite:getName() == NSSprite) ) )
      if (sprite ~= nil) and ((sprite:getName() == NSSprite) or (sprite:getName() == EWSprite)) then
        if (not GateOptionShown ) and (tostring(o:getType()) == "wall") and (square:getModData().GatePos ~= nil) and (square:getModData().isGate == true) and (square:getModData().openGate ~= true) then
          context:addOption("Open Gate", nil, ToggleGate, square, "open");
          GateOptionShown = true;
        elseif (not GateOptionShown ) and (tostring(o:getType()) == "wall") and CanCreateGate(square) and (square:getModData().isGate ~= true) then
          local player = getPlayer();
          local saw = player:getInventory():FindAndReturn("Saw");
          local hammer = player:getInventory():FindAndReturn("Hammer");
          local ropecount = player:getInventory():getItemsFromType("Rope");
          local sheetropecount = player:getInventory():getItemsFromType("SheetRope");
          local logcount = player:getInventory():getItemsFromType("Log");
          print("counts: "..tostring(ropecount:size()) .. "," ..tostring(logcount:size()) .." saw is " .. tostring(saw) .." hammer is " .. tostring(hammer));
          if(saw and hammer) and (logcount:size() >= 2) and ((ropecount:size() >= 2) or (sheetropecount:size() >= 8)) then
            context:addOption("Build a Gate", square, NolanGate.CreateGate, getPlayer(), 1000, square);
            GateOptionShown = true;
          end
        end
      end
      if (not GateOptionShown ) and (square:getModData().openGate == true) and (square:getModData().isGate == true) then
        context:addOption("Close Gate", nil, ToggleGate, square, "close");
        GateOptionShown = true;
      end
    end
  end
end

function OpenGateSquare(square)
  local o = SquareHasGate(square);
  USquare = GategetNextSquare(square,"U");
  USquare:getModData().isGate = true;
  addWallOnSquare(USquare,o:getSprite():getName(), o:getNorth());
  removeWallOnSquare(square,o);
  square:getModData().openGate = true;
  square:transmitModdata();
  USquare:transmitModdata();
end

function CloseGateSquare(square)
  USquare = GategetNextSquare(square,"U");
  local o = SquareHasGate(USquare);
  removeWallOnSquare(USquare,o);
  addWallOnSquare(square,o:getSprite():getName(), o:getNorth());
  square:getModData().openGate = nil;
  square:transmitModdata();
end

function OpenGate(square)
  local o = SquareHasGate(square);
  if not o then
    print("SquareHasGate did not return a square");
    return false
  end
  if(o:getSprite():getName() == EWSprite) then
    Wsquare = GategetNextSquare(square,"W");
    WWsquare = GategetNextSquare(Wsquare,"W");
    Esquare = GategetNextSquare(square,"E");
    EEsquare = GategetNextSquare(Esquare,"E");
    if(square:getModData().GatePos == 'Middle') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Esquare);
      OpenGateSquare(Wsquare);
    elseif(square:getModData().GatePos == 'Left') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Esquare);
      OpenGateSquare(EEsquare);
    elseif(square:getModData().GatePos == 'Right') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Wsquare);
      OpenGateSquare(WWsquare);
    else
      print("EWSprite no gate position found:" .. tostring(square:getModData().GatePos));
      return false;
    end;
  elseif(o:getSprite():getName() == NSSprite) then
    Nsquare = GategetNextSquare(square,"N");
    Ssquare = GategetNextSquare(square,"S");
    NNsquare = GategetNextSquare(Nsquare,"N");
    SSsquare = GategetNextSquare(Ssquare,"S");
    if(square:getModData().GatePos == 'Middle') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Ssquare);
      OpenGateSquare(Nsquare);
    elseif(square:getModData().GatePos == 'Left') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Nsquare);
      OpenGateSquare(NNsquare);
    elseif(square:getModData().GatePos == 'Right') then
      --getPlayer():Say("W");
      OpenGateSquare(square);
      OpenGateSquare(Ssquare);
      OpenGateSquare(SSsquare);
    else
      print(" NSSprite no gate position found: "..tostring(square:getModData().GatePos) .. " (" .. tostring(square:getModData().isGate) .. ")");
      return false;
    end;
  else
    print("unknown sprite");
  end
  getSoundManager():PlayWorldSound("Gates_Open", false, square, 0.2, 60, 0.2, false) ;
end

function CloseGate(square)
  local o = SquareHasGate(GategetNextSquare(square,"U"));
  if not o then
    print("couldnt get above wall")
    return false
  end
  if(o:getSprite():getName() == EWSprite) then
    Wsquare = GategetNextSquare(square,"W");
    WWsquare = GategetNextSquare(Wsquare,"W");
    Esquare = GategetNextSquare(square,"E");
    EEsquare = GategetNextSquare(Esquare,"E");
    if(square:getModData().GatePos == 'Middle') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Esquare);
      CloseGateSquare(Wsquare);
    elseif(square:getModData().GatePos == 'Left') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Esquare);
      CloseGateSquare(EEsquare);
    elseif(square:getModData().GatePos == 'Right') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Wsquare);
      CloseGateSquare(WWsquare);
    else
      print("EWSprite unknown gate pos")
      return false;
    end;
  elseif(o:getSprite():getName() == NSSprite) then
    Nsquare = GategetNextSquare(square,"N");
    Ssquare = GategetNextSquare(square,"S");
    NNsquare = GategetNextSquare(Nsquare,"N");
    SSsquare = GategetNextSquare(Ssquare,"S");
    if(square:getModData().GatePos == 'Middle') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Ssquare);
      CloseGateSquare(Nsquare);
    elseif(square:getModData().GatePos == 'Left') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Nsquare);
      CloseGateSquare(NNsquare);
    elseif(square:getModData().GatePos == 'Right') then
      --getPlayer():Say("W");
      CloseGateSquare(square);
      CloseGateSquare(Ssquare);
      CloseGateSquare(SSsquare);
    else
      print("NSSprite no gate position found: "..tostring(square:getModData().GatePos) .. " (" .. tostring(square:getModData().isGate) .. ")");
      return false;
    end;
  else
    print("unknown sprite")
  end
  getSoundManager():PlayWorldSound("Gates_Close", false, square, 0.2, 60, 0.2, false) ;
end

function CreateGate(square)
  local o = SquareHasLogWall(square);
  if not o then return false end
  if(o:getSprite():getName() == EWSprite) then
    --getPlayer():Say("EWSprite");
    Wsquare = GategetNextSquare(square,"W");
    WWsquare = GategetNextSquare(Wsquare,"W");
    Esquare = GategetNextSquare(square,"E");
    EEsquare = GategetNextSquare(Esquare,"E");
    if(Esquare and SquareHasLogWall(Esquare)) and (Wsquare and SquareHasLogWall(Wsquare)) then
      --getPlayer():Say("M");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Middle";
      Esquare:getModData().isGate = true;
      Esquare:getModData().GatePos = "Right";
      Wsquare:getModData().isGate = true;
      Wsquare:getModData().GatePos = "Left";
      LSquare = Wsquare;
      RSquare = GategetNextSquare(Esquare,"E");
    elseif(Esquare and SquareHasLogWall(Esquare)) and (EEsquare and SquareHasLogWall(EEsquare)) then
      --getPlayer():Say("E");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Left";
      Esquare:getModData().isGate = true;
      Esquare:getModData().GatePos = "Middle";
      EEsquare:getModData().isGate = true;
      EEsquare:getModData().GatePos = "Right";
      LSquare = square;
      RSquare = GategetNextSquare(EEsquare,"E");
    elseif(Wsquare and SquareHasLogWall(Wsquare)) and (WWsquare and SquareHasLogWall(WWsquare)) then
      --getPlayer():Say("W");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Right";
      Wsquare:getModData().isGate = true;
      Wsquare:getModData().GatePos = "Middle";
      WWsquare:getModData().isGate = true;
      WWsquare:getModData().GatePos = "Left";
      LSquare = WWsquare;
      RSquare = GategetNextSquare(square,"E");
    else
      return false;
    end;
    addPoleOnSquare(LSquare,true);
    addPoleOnSquare(RSquare,true);
    addPoleOnSquare(GategetNextSquare(LSquare,"U"),true);
    addPoleOnSquare(GategetNextSquare(RSquare,"U"),true);
    Wsquare:transmitModdata();
    WWsquare:transmitModdata();
    Esquare:transmitModdata();
    EEsquare:transmitModdata();
    square:transmitModdata();
  elseif(o:getSprite():getName() == NSSprite) then
    --getPlayer():Say("NSSprite");
    Nsquare = GategetNextSquare(square,"N");
    Ssquare = GategetNextSquare(square,"S");
    NNsquare = GategetNextSquare(Nsquare,"N");
    SSsquare = GategetNextSquare(Ssquare,"S");
    if(Ssquare and SquareHasLogWall(Ssquare)) and (Nsquare and SquareHasLogWall(Nsquare)) then
      --getPlayer():Say("M");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Middle";
      Ssquare:getModData().isGate = true;
      Ssquare:getModData().GatePos = "Left";
      Nsquare:getModData().isGate = true;
      Nsquare:getModData().GatePos = "Right";
      LSquare = GategetNextSquare(Ssquare,"S");
      RSquare = Nsquare;
    elseif(Ssquare and SquareHasLogWall(Ssquare)) and (SSsquare and SquareHasLogWall(SSsquare)) then
      --getPlayer():Say("S");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Right";
      Ssquare:getModData().isGate = true;
      Ssquare:getModData().GatePos = "Middle";
      SSsquare:getModData().isGate = true;
      SSsquare:getModData().GatePos = "Left";
      LSquare = GategetNextSquare(SSsquare,"S");
      RSquare = square;
    elseif(Nsquare and SquareHasLogWall(Nsquare)) and (NNsquare and SquareHasLogWall(NNsquare)) then
      --getPlayer():Say("N");
      square:getModData().isGate = true;
      square:getModData().GatePos = "Left";
      Nsquare:getModData().isGate = true;
      Nsquare:getModData().GatePos = "Middle";
      NNsquare:getModData().isGate = true;
      NNsquare:getModData().GatePos = "Right";
      LSquare = GategetNextSquare(square,"S");
      RSquare = square;
    else
      return false;
    end;
    addPoleOnSquare(LSquare,o:getNorth());
    addPoleOnSquare(RSquare,o:getNorth());
    addPoleOnSquare(GategetNextSquare(LSquare,"U"),o:getNorth());
    addPoleOnSquare(GategetNextSquare(RSquare,"U"),o:getNorth());
    Nsquare:transmitModdata();
    NNsquare:transmitModdata();
    Ssquare:transmitModdata();
    SSsquare:transmitModdata();
    square:transmitModdata();
  else
    return false;
  end
  local inv = getPlayer():getInventory();
  local ropecount = inv:getItemsFromType("Rope");
  local sheetropecount = inv:getItemsFromType("SheetRope");
  if(ropecount:size() >= 2) then
    for i=1,2 do
      inv:Remove(inv:FindAndReturn("Rope"));
    end
  elseif(sheetropecount:size() >= 8) then
    for i=1,8 do
      inv:Remove(inv:FindAndReturn("SheetRope"));
    end
  end
  inv:Remove(inv:FindAndReturn("Log"));
  inv:Remove(inv:FindAndReturn("Log"));
end

function CanCreateGate(square)
  local o = SquareHasLogWall(square);
  if not o then return false end
  if(o:getSprite():getName() == EWSprite) then
    Wsquare = GategetNextSquare(square,"W");
    WWsquare = GategetNextSquare(Wsquare,"W");
    Esquare = GategetNextSquare(square,"E");
    EEsquare = GategetNextSquare(Esquare,"E");
    if(Wsquare and SquareHasLogWall(Wsquare)) and (WWsquare and SquareHasLogWall(WWsquare)) then
      --getPlayer():Say("W");
      return true;
    elseif(Esquare and SquareHasLogWall(Esquare)) and (EEsquare and SquareHasLogWall(EEsquare)) then
      --getPlayer():Say("W");
      return true;
    elseif(Esquare and SquareHasLogWall(Esquare)) and (Wsquare and SquareHasLogWall(Wsquare)) then
      return true;
    else
      return false;
    end;
  elseif(o:getSprite():getName() == NSSprite) then
    Nsquare = GategetNextSquare(square,"N");
    Ssquare = GategetNextSquare(square,"S");
    NNsquare = GategetNextSquare(Nsquare,"N");
    SSsquare = GategetNextSquare(Ssquare,"S");
    if(Nsquare and SquareHasLogWall(Nsquare)) and (NNsquare and SquareHasLogWall(NNsquare)) then
      --getPlayer():Say("W");
      return true;
    elseif(Ssquare and SquareHasLogWall(Ssquare)) and (SSsquare and SquareHasLogWall(SSsquare)) then
      --getPlayer():Say("W");
      return true;
    elseif(Ssquare and SquareHasLogWall(Ssquare)) and (Nsquare and SquareHasLogWall(Nsquare)) then
      return true;
    else
      return false;
    end;
  else
  end
  return false;
end

function ToggleGate(test,square,mode)
  local player = getPlayer();
  if(square) and (mode == "open") then
    OpenGate(square);
  elseif(square) and (mode == "close") then
    CloseGate(square);
  elseif(square) and (mode == "create") then
    CreateGate(square);
  end
end


Ticks = 0;
function GateOnPlayerUpdate(player)
  Ticks = Ticks + 1;
  if(Ticks % 40 == 0) then
    local result = player:getCurrentSquare():getModData().isGate;
    local result2 = player:getCurrentSquare():getModData().GatePos;
  end
end
Events.OnFillWorldObjectContextMenu.Add(GateCheckForLogWallGate)
--Events.OnPlayerUpdate.Add(GateOnPlayerUpdate);
