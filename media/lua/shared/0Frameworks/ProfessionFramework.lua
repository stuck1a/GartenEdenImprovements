ProfessionFramework = {
  VERSION = "1.00-stable",
  AUTHOR = "Fenris_Wolf (refactored by stuck1a)",
  Professions = {},
  Traits = {},
  RemoveDefaultProfessions = false,
  RemoveDefaultTraits = false,
  AlwaysUseStartingKits = true,
  LogLevel = 1,
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
  LogLevelStrings = { [0] = "ERROR", [1] = "WARN", [2] = "INFO", [3] = "DEBUG"},
  log = function(level, text)
    if level > ProfessionFramework.LogLevel then return end
    local prefix = "[ProfessionFramework]"..ProfessionFramework.LogLevelStrings[level]..": "
    print(prefix..text)
  end
}
local oldDoTraits = BaseGameCharacterDetails.DoTraits
local oldDoProfessions = BaseGameCharacterDetails.DoProfessions


---
--- Registers a profession with the profession framework.
---
--- @param type string  Profession name
--- @param details table Profession details
---        @field cost number  Number of points this profession starts with
---        @field xp table  List of perks, and the experience levels for each
---        @field traits table  Traits this profession starts with
---        @field recipes table  List of recipes this profession starts with
---        @field inventory table  Items the profession starts with (in the inventory)
---                                Keys = item names, Values = amount
---        @field square table  Items the profession starts with (on the ground)
---                             Keys = item names, Values = amount
---        @field OnNewGame function  Callback when the character is created
---                                      Params: player IsoPlayer, square IsoGridSquare, professionName string
---
ProfessionFramework.addProfession = function(type, details)
  ProfessionFramework.Professions[type] = details
end


---
--- Returns profession details
--- @param type string  Target profession name
---
ProfessionFramework.getProfession = function(type)
  return ProfessionFramework.Professions[type]
end


---
--- Registers a trait with the profession framework
--- @param type string  Trait name
--- @param details table Trait details
---        @field cost number  Number of points this trait costs
---        @field name string  Name of the trait or its translation entry
---        @field description string  Trait description or its translation entry
---        @field xp table  List of perks, and the experience levels for each
---        @field removeInMP boolean  Single player mode only
---        @field requiresSleepEnabled boolean  If trait requires sleep enabled in sandbox settings to select
---        @field profession boolean If this is a 'profession trait' (non-selectable)
---        @field swap string  Name of another trait to swap this one with OnNewGame
---                            This should really only be used for the 'special' traits
---        @field exclude table  List of traits this one should be mutually exclusive with
---        @field add table  Additional traits which will be gained when selecting this trait
---        @field inventory table  Items this trait starts with (in inventory)
---                                Keys = item names, Values = amount
---        @field square table  Items this trait starts with (on the ground)
---                             Keys = item names, Values = amount
---        @field OnNewGame function  Called if a new character which uses this trait is created
---                                   Params: player IsoPlayer, square IsoGridSquare, professionName string
---        @field OnGameStart function  OnGameStart-Callback for characters which uses this trait
---                                     Params: traitName string
---
ProfessionFramework.addTrait = function(type, details)
  ProfessionFramework.Traits[type] = details
end


---
--- Returns trait details
--- @param type string Trait name
---
ProfessionFramework.getTrait = function(type)
  return ProfessionFramework.Traits[type]
end


---
--- OnGameBoot-Handler
--- Sets up all 'special traits' so they can be used as profession traits.
--- This creates traits such as Brave2, sets the mutually exclusive so a player with brave2 cant
--- select brave or cowardly, and flags brave2 to be replaced with the real brave with the OnNewGame
--- event so it will function properly.
---
ProfessionFramework.doTraits = function()
  oldDoTraits()
  local sleepOK = (isClient() or isServer()) and getServerOptions():getBoolean("SleepAllowed") and getServerOptions():getBoolean("SleepNeeded")
  for ttype, details in pairs(ProfessionFramework.Traits) do
    local remove = details.removeInMP or false
    if details.requiresSleepEnabled and not sleepOK then remove = false end
    local this = TraitFactory.getTrait(ttype)
    if this then
      ProfessionFramework.log(ProfessionFramework.INFO, "Adjusting Trait "..ttype)
      if details.cost then
        ProfessionFramework.log(ProfessionFramework.WARN, "Cost can not be adjusted for already existing trait "..ttype)
      end
      if details.name then
        ProfessionFramework.log(ProfessionFramework.WARN, "Name can not be adjusted for already existing trait "..ttype)
      end
      if details.description then
        ProfessionFramework.log(ProfessionFramework.WARN, "Description can not be adjusted for already existing trait "..ttype)
      end
      if details.profession then
        ProfessionFramework.log(ProfessionFramework.WARN, "Profession flag can not be adjusted for already existing trait "..ttype)
      end
    else
      ProfessionFramework.log(ProfessionFramework.INFO, "Adding Trait "..ttype)
      this = TraitFactory.addTrait(ttype, getText(details.name), (details.cost or 0), getText(details.description), (details.profession or false), remove)
    end
    if details.xp then
      for perk, bonus in pairs(details.xp) do
        this:addXPBoost(perk, bonus)
      end
    end
    if details.recipes then
      local free = this:getFreeRecipes()
      for _, recipe in ipairs(details.recipes) do
        free:add(recipe)
      end
    end
  end
  for ttype, details in pairs(ProfessionFramework.Traits) do
    local exclude = details.exclude or {}
    for _, name in ipairs(exclude) do
      TraitFactory.setMutualExclusive(ttype, name)
    end
  end
  TraitFactory.sortList()
  for ttype, details in pairs(ProfessionFramework.Traits) do
    BaseGameCharacterDetails.SetTraitDescription(TraitFactory.getTrait(ttype))
  end
end


---
--- OnGameBoot-Handler
--- Sets up all professions added with the ProfessionFramework.addProfession() function.
--- If a profession already exists with the ProfessionFactory (default game professions) it edits the
--- values, if not it registers the new profession.
---
ProfessionFramework.doProfessions = function()
  if not ProfessionFramework.RemoveDefaultProfessions then oldDoProfessions() end
  for ptype, details in pairs(ProfessionFramework.Professions) do
    local this = ProfessionFactory.getProfession(ptype)
    if this then
      ProfessionFramework.log(ProfessionFramework.INFO, "Adjusting Profession "..ptype)
      this:setName((details.name or this:getName()))
      this:setCost((details.cost or this:getCost()))
      this:setIconPath((details.icon or this:getIconPath()))
    else
      ProfessionFramework.log(ProfessionFramework.INFO, "Adding Profession "..ptype)
      this = ProfessionFactory.addProfession(ptype, (getText(details.name) or "Unknown"), (details.icon or ""), (details.cost or 0))
    end
    if details.xp then
      for perk, bonus in pairs(details.xp) do
        this:addXPBoost(perk, bonus)
      end
    end
    if details.traits then
      local current = this:getFreeTraits()
      for _, trait in ipairs(details.traits) do
        if not current:contains(trait) then this:addFreeTrait(trait) end
      end
    end
    if details.recipes then
      local free = this:getFreeRecipes()
      for _, recipe in ipairs(details.recipes) do
        free:add(recipe)
      end
    end
    BaseGameCharacterDetails.SetProfessionDescription(this)
  end
end


---
--- OnNewGame-Handler
--- Adds starting kits for any profession and traits
---
ProfessionFramework.addStartingKit = function(player, square, details)
  local inventory = player:getInventory()
  if SandboxVars.StarterKit or ProfessionFramework.AlwaysUseStartingKits then
    if details.inventory then
      for item, count in pairs(details.inventory) do
        if getScriptManager():FindItem(item) then
          inventory:AddItems(item, count)
        end
      end
    end
    if details.square then
      for item, count in pairs(details.square) do
        if getScriptManager():FindItem(item) then
          for i=1, count do
            square:AddWorldInventoryItem(item, 0, 0, 0)
          end
        end
      end
      ISInventoryPage.dirtyUI()
    end
  end
end


-- overwrite the old functions for proper respawn character creation
BaseGameCharacterDetails.DoTraits = ProfessionFramework.doTraits
BaseGameCharacterDetails.DoProfessions = ProfessionFramework.doProfessions
-- remove the old event callbacks
Events.OnGameBoot.Remove(oldDoTraits)
Events.OnGameBoot.Remove(oldDoProfessions)
-- mount new callbacks
Events.OnGameBoot.Add(ProfessionFramework.doTraits)
Events.OnGameBoot.Add(ProfessionFramework.doProfessions)
