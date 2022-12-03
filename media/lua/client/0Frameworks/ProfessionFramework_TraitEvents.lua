--
-- Experimental framework
-- Modifies various apsects of the selection screen, allowing for traits with requirements
-- (ie: only allowed for specific professions, or to have other traits selected first).
-- Requires ProfessionFramework.ExperimentalFeatures = true
--

local PF = ProfessionFramework
if not PF.ExperimentalFeatures then return end

local oldOnSelectProf = CharacterCreationProfession.onSelectProf
local oldCreate = CharacterCreationProfession.create
local oldAddTrait = CharacterCreationProfession.addTrait
local oldRemoveTrait = CharacterCreationProfession.removeTrait
local tableContains = utils.tableContains
local tableCopyData = utils.tableCopyData
local NORMAL = 0
local FILTERED = 1
local SELECTED = 2


---
--- Returns a table of currently selected trait names
---
local function getSelected(self)
  local result = {}
  if not self.listboxTraitSelected then return result end
  for i,v in ipairs(self.listboxTraitSelected.items) do table.insert(result, v.item:getType()) end
  return result
end


---
--- Check if the trait is positive or negative and return corresponding ListBox
---
local function goodOrBad(self, trait)
  if not trait:isFree() and trait:getCost() < 0 then return self.listboxBadTrait end
  return self.listboxTrait
end



---
--- adds a previously filtered trait back into the ListBox
---
local function addFiltered(self, trait)
  PF.log(PF.DEBUG, 'Unfiltering '.. trait:getType())
  self.filteredTraits[trait:getType()] = NORMAL
  local list = goodOrBad(self, trait)
  list:addItem(trait:getLabel(), trait)
end



---
--- Removes a filtered trait from the ListBox
---
local function removeFiltered(self, trait)
  PF.log(PF.DEBUG, 'Filtering '.. trait:getType())
  self.filteredTraits[trait:getType()] = FILTERED
  local list = goodOrBad(self, trait)
  list:removeItem(trait:getLabel())
  for i,v in ipairs(list.items) do
    if v.item:getType() == trait:getType() then
      PF.log(PF.WARN, 'Failed to filter trait. Attempting again. (listbox bug?)')
      list:removeItem(trait:getLabel())
    end
  end
  for i,v in ipairs(list.items) do
    if v.item:getType() == trait:getType() then
      PF.log(PF.ERROR, 'Trait failed to remove twice. Not good.')
    end
  end
end



---
--- Checks whether a trait is restricted due to the chosen profession
---
local function isDirty(self, profession)
  local restricted = ProfessionFramework.getRestrictedTraits(profession, getSelected(self))
  for i,v in ipairs(self.listboxTraitSelected.items) do
    if tableContains(restricted, v.item:getType()) then return i end
  end
  return nil
end



local function removeSelected(self, profession)
  while true do
    local index = isDirty(self, profession)
    if not index then break end
    self.listboxTraitSelected.selected = index
    local trait = self.listboxTraitSelected.items[index].item
    self.filteredTraits[trait:getType()] = NORMAL
    self:removeTrait(true)
  end
end


---
--- Callback for sorting countable values in descendant order
---
local function alphaSort(a, b)
  return a.text < b.text
end


---
--- Filters selected and available traits
---
local function filterTraits(self, profession)
  local restricted = PF.getRestrictedTraits(profession, getSelected(self))
  PF.log(PF.DEBUG, 'Filtering Traits.....')
  for trait, value in pairs(self.filteredTraits) do
    if value == FILTERED then addFiltered(self, TraitFactory.getTrait(trait)) end
  end
  for _, trait in ipairs(restricted) do removeFiltered(self, TraitFactory.getTrait(trait)) end
  if ProfessionFramework.ALPHASORT then
    table.sort(self.listboxTrait.items, alphaSort)
    table.sort(self.listboxBadTrait.items, alphaSort)
  else
    CharacterCreationMain.sort(self.listboxTrait.items);
    CharacterCreationMain.invertSort(self.listboxBadTrait.items);
  end
end


---
--- Overload version of ISUISelectProfession constructor
--- Applies the active filter list before the parent call.
---
function CharacterCreationProfession:create()
  self.filteredTraits = { }
  for trait, details in pairs(ProfessionFramework.Traits) do self.filteredTraits[trait] = NORMAL end
  oldCreate(self)
end



function CharacterCreationProfession:addTrait(bad, nofilter)
  PF.log(PF.DEBUG, 'Removing trait nofilter:'..tostring(nofilter))
  oldAddTrait(self, bad)
  if nofilter ~= true then filterTraits(self, self.profession:getType()) end
end



function CharacterCreationProfession:removeTrait(nofilter)
  PF.log(PF.DEBUG, 'Removing trait nofilter:'..tostring(nofilter))
  PF.log(PF.DEBUG, 'Index is: '.. tostring(self.listboxTraitSelected.selected))
  local trait = self.listboxTraitSelected.items[self.listboxTraitSelected.selected]
  PF.log(PF.DEBUG, 'Trait is: '..tostring(trait.text))
  oldRemoveTrait(self)
  removeSelected(self, self.profession:getType())
  if nofilter ~= true then filterTraits(self, self.profession:getType()) end
end



function CharacterCreationProfession:onSelectProf(item)
  local profession = item:getType()
  PF.log(PF.DEBUG, 'New Profession selected: '.. profession)
  oldOnSelectProf(self, item)
  removeSelected(self, profession)
  filterTraits(self, profession)
end



---
--- Extend existing profession objects
---
if not ProfessionFramework.COMPATIBILITY_MODE then
  local oldDoClothingCombo = CharacterCreationMain.doClothingCombo
  function CharacterCreationMain:doClothingCombo(definition, erasePrevious)
    if not self.clothingPanel then return end
    local selected = getSelected(MainScreen.instance.charCreationProfession)
    definition = tableCopyData(definition)
    for _, trait in ipairs(selected) do repeat
      local details = ProfessionFramework.getTrait(trait)
      if not details or not details.clothing then break end
      for location, clothes in pairs(details.clothing) do
        if definition[location] then
          for _,c in ipairs(clothes) do
            local items =  definition[location].items
            if not tableContains(items, c) then table.insert(items, c) end
          end
        else
          -- copy so we dont insert and modify original
          definition[locaiton] = { items = tableCopyData(clothes) }
        end
      end
    until true end
    oldDoClothingCombo(self, definition, erasePrevious)
  end
end