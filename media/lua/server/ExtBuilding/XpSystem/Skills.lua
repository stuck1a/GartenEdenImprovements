if not SkillBook then require 'XpSystem/XPSystem_SkillBook' end
if not Recipe then require 'recipecode' end


-- SKILLS
local aNewSkills = {
  ['Masonry'] = Perks.Masonry,
}


-- DISTRIBUTIONS
local ItemDist = {
  -- Vol. 1 Books
  {
    Items = { 'BookMasonry1' },
    Distributions = {
      { 'BookstoreBooks',  10},
      { 'ToolStoreBooks',  10},
      { 'LibraryBooks',  8},
      { 'PostOfficeBooks',  6},
      { 'ClassroomMisc',  2},
      { 'ClassroomShelves',  2},
      { 'ClassroomShelves',  2},
      { 'LivingRoomShelf',  2},
      { 'LivingRoomShelfNoTapes',  2},
      { 'ShelfGeneric',  2},
      { 'CrateBooks',  6},
      { 'EngineerTools',  2},
      { 'GardenStoreMisc',  4},
      { 'Homesteading',  4}
    },
    VehicleDistributions = {
      { 'PostalTruckBed', 6 },
    }
  },
  -- Vol. 2 Books
  {
    Items = { 'BookMasonry2' },
    Distributions = {
      { 'BookstoreBooks',  8},
      { 'ToolStoreBooks',  8},
      { 'LibraryBooks',  6},
      { 'PostOfficeBooks',  4},
      { 'ClassroomMisc',  1},
      { 'ClassroomShelves',  1},
      { 'LivingRoomShelf',  1},
      { 'LivingRoomShelfNoTapes',  1},
      { 'ShelfGeneric',  1},
      { 'CrateBooks',  4},
      { 'EngineerTools',  1},
      { 'GardenStoreMisc',  2},
      { 'Homesteading',  2}
    },
    VehicleDistributions = {
      { 'PostalTruckBed', 4 },
    }
  },
  -- Vol. 3 Books
  {
    Items = { 'BookMasonry3' },
    Distributions = {
      { 'BookstoreBooks',  6},
      { 'ToolStoreBooks',  6},
      { 'LibraryBooks',  4},
      { 'PostOfficeBooks',  2},
      { 'ClassroomMisc',  0.5},
      { 'ClassroomShelves',  0.5},
      { 'LivingRoomShelf',  0.5},
      { 'LivingRoomShelfNoTapes',  0.5},
      { 'ShelfGeneric',  0.5},
      { 'CrateBooks',  2},
      { 'EngineerTools',  0.5},
      { 'GardenStoreMisc',  1},
      { 'Homesteading',  1}
    },
    VehicleDistributions = {
      { 'PostalTruckBed', 2 },
    }
  },
  -- Vol. 4 Books
  {
    Items = { 'BookMasonry4' },
    Distributions = {
      { 'BookstoreBooks',  4},
      { 'ToolStoreBooks',  4},
      { 'LibraryBooks',  2},
      { 'PostOfficeBooks',  1},
      { 'ClassroomMisc',  0.1},
      { 'ClassroomShelves',  0.1},
      { 'LivingRoomShelf',  0.1},
      { 'LivingRoomShelfNoTapes',  0.1},
      { 'ShelfGeneric',  0.1},
      { 'CrateBooks',  1},
      { 'EngineerTools',  0.1},
      { 'GardenStoreMisc',  0.5},
      { 'Homesteading',  0.5}
    },
    VehicleDistributions = {
      { 'PostalTruckBed', 1 },
    }
  },
  -- Vol. 5 Books
  {
    Items = { 'BookMasonry5' },
    Distributions = {
      { 'BookstoreBooks',  2},
      { 'ToolStoreBooks',  2},
      { 'LibraryBooks',  1},
      { 'PostOfficeBooks',  0.5},
      { 'ClassroomMisc',  0.01},
      { 'ClassroomShelves',  0.01},
      { 'LivingRoomShelf',  0.01},
      { 'LivingRoomShelfNoTapes',  0.01},
      { 'ShelfGeneric',  0.01},
      { 'CrateBooks',  0.5},
      { 'EngineerTools',  0.01},
      { 'GardenStoreMisc',  0.1},
      { 'Homesteading',  0.1}
    },
    VehicleDistributions = {
      { 'PostalTruckBed', 0.5 },
    }
  },
}




local ProceduralDistributions, VehicleDistributions = ProceduralDistributions, VehicleDistributions
local SkillBook, Recipe, insert = SkillBook, Recipe, table.insert

local function getLootTable(strLootTableName) return ProceduralDistributions.list[strLootTableName] end
local function getVehicleLootTable(strLootTableName) return VehicleDistributions[strLootTableName] end

local function insertItem(tLootTable, strItem, iWeight)
  insert(tLootTable.items, strItem)
  insert(tLootTable.items, iWeight)
end

local function preDistributionMerge()
  for i=1, #ItemDist do
    if ItemDist[i].Distributions ~= nil then
      for j=1, #(ItemDist[i].Distributions) do
        for k=1, #(ItemDist[i].Items) do
          local tLootTable = getLootTable(ItemDist[i].Distributions[j][1])
          local strItem = ItemDist[i].Items[k]
          local iWeight = ItemDist[i].Distributions[j][2]
          insertItem(tLootTable, strItem, iWeight)
        end
      end
    end
    if ItemDist[i].VehicleDistributions ~= nil then
      for j=1, #(ItemDist[i].VehicleDistributions) do
        for k=1, #(ItemDist[i].Items) do
          local tLootTable = getVehicleLootTable(ItemDist[i].VehicleDistributions[j][1])
          local strItem = ItemDist[i].Items[k]
          local iWeight = ItemDist[i].VehicleDistributions[j][2]
          insertItem(tLootTable, strItem, iWeight)
        end
      end
    end
  end
end


for sSkillName,oPerk in aNewSkills do
  if SkillBook ~= nil then
    SkillBook[sSkillName] = {
      perk = oPerk,
      maxMultiplier1 = 3,
      maxMultiplier2 = 5,
      maxMultiplier3 = 8,
      maxMultiplier4 = 12,
      maxMultiplier5 = 16
    }
  end
  if Recipe.OnGiveXP ~= nil then
    Recipe.OnGiveXP[sSkillName..'5']  = function(_, _, _, player) player:getXp():AddXP(oPerk,  5) end
    Recipe.OnGiveXP[sSkillName..'10'] = function(_, _, _, player) player:getXp():AddXP(oPerk, 10) end
    Recipe.OnGiveXP[sSkillName..'15'] = function(_, _, _, player) player:getXp():AddXP(oPerk, 15) end
    Recipe.OnGiveXP[sSkillName..'20'] = function(_, _, _, player) player:getXp():AddXP(oPerk, 20) end
    Recipe.OnGiveXP[sSkillName..'25'] = function(_, _, _, player) player:getXp():AddXP(oPerk, 25) end
  end
end

Events.OnPreDistributionMerge.Add(preDistributionMerge)