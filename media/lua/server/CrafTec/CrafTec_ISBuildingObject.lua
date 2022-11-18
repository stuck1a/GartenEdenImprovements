--[[
require "BuildingObjects/ISBuildUtil";
require "BuildingObjects/ISWoodenWall";
require "BuildingObjects/ISDoubleTileFurniture";
require "BuildingObjects/ISWoodenStairs";
require "Frameworks/Utils_Shared";


--
-- Hotfix-Mappings
-- Leitet alle in dem Klassenobjekt als Setter-Properties hinterlegten Werte an die entsprechenden
-- Setter-Funktionen des ISO-Objekts weiter, um dessen Initialisierung zu vereinfachen.
--
buildUtil.setInfo = function(javaObject, ISItem)
	if  javaObject.setCanPassThrough     then  javaObject:setCanPassThrough(ISItem.canPassThrough or false);        end
	if  javaObject.setCanBarricade       then  javaObject:setCanBarricade(ISItem.canBarricade or false);            end
	if  javaObject.setThumpDmg           then  javaObject:setThumpDmg(ISItem.thumpDmg or false);                    end
	if  javaObject.setIsContainer        then  javaObject:setIsContainer(ISItem.isContainer or false);              end
	if  javaObject.setIsDoor             then  javaObject:setIsDoor(ISItem.isDoor or false);                        end
	if  javaObject.setIsDoorFrame        then  javaObject:setIsDoorFrame(ISItem.isDoorFrame or false);              end
	if  javaObject.setCrossSpeed         then  javaObject:setCrossSpeed(ISItem.crossSpeed or 1);                    end
	if  javaObject.setBlockAllTheSquare  then  javaObject:setBlockAllTheSquare(ISItem.blockAllTheSquare or false);  end
	if  javaObject.setName               then  javaObject:setName(ISItem.name or "Object");                         end
	if  javaObject.setIsDismantable      then  javaObject:setIsDismantable(ISItem.dismantable or false);            end
	if  javaObject.setCanBePlastered     then  javaObject:setCanBePlastered(ISItem.canBePlastered or false);        end
	if  javaObject.setIsHoppable         then  javaObject:setIsHoppable(ISItem.hoppable or false);                  end
	if  javaObject.setModData            then  javaObject:setModData(bcUtils.cloneTable(ISItem.modData));           end
	if  javaObject.setIsThumpable        then  javaObject:setIsThumpable(ISItem.isThumpable or true);               end
	if ISItem.containerType and javaObject:getContainer() then
		javaObject:getContainer():setType(ISItem.containerType);
	end
	if ISItem.canBeLockedByPadlock then
		javaObject:setCanBeLockByPadlock(ISItem.canBeLockedByPadlock);
	end
end


--
-- Überladet die Basisklasse für zweiteilige ISOObjekte um eine Mapping-Funktion,
-- um das ISO-Objekt für diesen Spezialfall zu initialisieren.
--
function ISDoubleTileFurniture:setInfo(square, north, sprite)
	local thumpable = IsoThumpable.new(getCell(), square, sprite, north, self);
	buildUtil.setInfo(thumpable, self);
	thumpable:setMaxHealth(self:getHealth());
	thumpable:setBreakSound("breakdoor");
	square:AddSpecialObject(thumpable);
	thumpable:transmitCompleteItemToServer();
	self.javaObject = thumpable;
end


--
-- Überladet die Basisklasse für Treppen ebenfalls um eine Mapping-Funktion,
-- um das ISO-Objekt für diesen Spezialfall zu initialisieren.
--
function ISWoodenStairs:setInfo(square, level, north, sprite, luaobject)
	local pillarSprite = self.pillar;
	if north then pillarSprite = self.pillarNorth end
	local thumpable = square:AddStairs(north, level, sprite, pillarSprite, luaobject);
	square:RecalcAllWithNeighbours(true);        -- Kollisionen neu berechnen
	thumpable:setName("Wooden Stairs");          -- Name des Tooltip-Objekts
	thumpable:setCanBarricade(false);
	thumpable:setIsDismantable(true);
	thumpable:setMaxHealth(self:getHealth());
	thumpable:setIsStairs(true);
	thumpable:setIsThumpable(false)
	thumpable:setBreakSound("breakdoor");
	thumpable:setModData(copyTable(self.modData))
	thumpable:transmitCompleteItemToServer();
	self.javaObject = thumpable;
end


--
-- Klassenobjekt für Baustellen
--
BCCrafTecObject = ISBuildingObject:derive("BCCrafTecObject");


--
-- Funktion für die Vergabe von XP anpassen
--
BCCrafTecObject.addWoodXpOriginal = buildUtil.addWoodXp;
buildUtil.addWoodXp = function(ISItem)
	if ISItem.recipe then return end;
	BCCrafTecObject.addWoodXpOriginal(ISItem);
end


--
-- Erzeugt eine neue Baustelle, d.h. ein Metainfo-Objekt, welches die Baustellen-Details beinhaltet
-- sowie das Overlay-Sprite
--
function BCCrafTecObject:create(x, y, z, north, sprite)
	-- Neues Info-Objekt platzieren und die Baustellen-Daten aus Objektinstanz zuweisen 
  local cell = getWorld():getCell();
  self.sq = cell:getGridSquare(x, y, z);
  self.javaObject = IsoThumpable.new(cell, self.sq, "carpentry_02_56", north, self);
  buildUtil.setInfo(self.javaObject, self);
  self.javaObject:setBreakSound("breakdoor");
	self.sq:AddSpecialObject(self.javaObject);
  self.javaObject:transmitCompleteItemToServer();
	-- Baustelle mit den nun als ModData gespeicherten Infos initialisieren
	self.modData = self.javaObject:getModData();
	self.modData.recipe = bcUtils.cloneTable(self.recipe);
	self.modData.recipe.started = true;
	self.modData.recipe.ingredientsAdded = {};
	self.modData.recipe.x = x;
	self.modData.recipe.y = y;
	self.modData.recipe.z = z;
	self.modData.recipe.north = north;
	self.modData.recipe.sprite = sprite;
	self.modData.recipe.data.nSprite = self.nSprite;
	for k,_ in pairs(self.modData.recipe.ingredients) do
		self.modData.recipe.ingredientsAdded[k] = 0;
	end
  -- Abschließend das Baustellen-Sprite über das Info-Objekt rendern
	self.javaObject:setOverlaySprite("media/textures/CrafTec/BC_scaffold.png", 1, 1, 1, 1, true);
end


--
-- Wrapper für die Funktion, die neue Baustellen anlegt.
-- Vermutlich ist hier eine Routine angedacht, welche der Prozess fehlersicher macht,
-- falls das Anlegen einer Baustelle durch einen schwächelnden Server schief geht.
--
function BCCrafTecObject:tryBuild(x, y, z)
	self:create(x, y, z, self.north, self:getSprite());
end


--
-- Konstruktor
-- Wird von den Bauprojekt-Definitionen aufgerufen.
--
function BCCrafTecObject:new(recipe)
	-- Instanz erzeugen und ModData-Table anlegen, um den Baustellen-Zustand speichern/wiederherstellen zu können
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o:init();
	o.recipe = recipe;
	-- Definierte Sprites eintragen
	local images = BCCrafTec.getImages(getPlayer(), recipe);
	o:setSprite(images.west);
	o:setNorthSprite(images.north);
	o:setEastSprite(images.east);
	o:setSouthSprite(images.south);
	-- Definierte Eigenschaften bzw. Default-Werte eintragen
	o.name = o.recipe.name;
	o.canBarricade = false;
	o.canPassThrough = true;
	o.blockAllTheSquare = true;
	o.dismantable = false;
	o.renderFloorHelper = recipe.data.renderFloorHelper or false;
	o.canBeAlwaysPlaced = recipe.data.canBeAlwaysPlaced or false;
	o.needToBeAgainstWall = recipe.data.needToBeAgainstWall or false;
	o.isValid = recipe.isValid or _G[recipe.resultClass].isValid;
	o.noNeedHammer = true;
  -- Funktion von Treppen borgen, um die Zellen der Baustelle zu erhalten
	o.getSquare2Pos = ISWoodenStairs.getSquare2Pos;
	o.getSquare3Pos = ISWoodenStairs.getSquare3Pos;
	o.getSquareTopPos = ISWoodenStairs.getSquareTopPos;
	return o;
end


--
-- Funktion, welche nach Fertigstellung des Bauprojekts aufgerufen wird,
-- um das Baustellen-Sprite mit dem endgültigen Sprite auszutauschen.
--
function BCCrafTecObject:render(x, y, z, square)
	local data = {};
	data.x = x;
	data.y = y;
	data.z = z;
	data.square = square;
	data.done = false;
	-- WorldCraftingRender-Event übernimmt das rendern von Spezialfällen (DoubleTileFurniture/Treppen)
	triggerEvent("WorldCraftingRender", self, data);
	-- Nur die regulären Fälle werden hier gerendert, falls die EventHandler nicht zuständig waren
	if data.done then return end
	ISBuildingObject.render(self, x, y, z, square);
end


--
-- Handler A vom WorldCraftingRender-Event.
-- Übernimmt das Rendern von Bauprojekten, welche zwei Tiles breit sind .
--
BCCrafTecObject.renderISDoubleFurniture = function(self, data)
	local md = self.recipe;
	if md.resultClass ~= "ISDoubleTileFurniture" then return end;
	local images = BCCrafTec.getImages(getPlayer(), self.recipe);
	for k,v in pairs(images) do
		if not self[k] then
			self[k] = v
		end
	end
	data.done = true;
	ISDoubleTileFurniture.render(self, data.x, data.y, data.z, data.square);
	return;
end


--
-- Handler B vom WorldCraftingRender-Event.
-- Übernimmt das Rendern, wenn eine Treppe gebaut wurde.
--
BCCrafTecObject.renderISWoodenStairs = function(self, data)
	local md = self.recipe;
	if md.resultClass ~= "ISWoodenStairs" then return end;
	local images = BCCrafTec.getImages(getPlayer(), self.recipe);
	for k,v in pairs(images) do
		if not self[k] then
			self[k] = v
		end
	end
	data.done = true;
	ISWoodenStairs.render(self, data.x, data.y, data.z, data.square);
	return;
end


-- Render-Event definieren
LuaEventManager.AddEvent("WorldCraftingRender");
Events.WorldCraftingRender.Add(BCCrafTecObject.renderISDoubleFurniture);
Events.WorldCraftingRender.Add(BCCrafTecObject.renderISWoodenStairs);
--]]
