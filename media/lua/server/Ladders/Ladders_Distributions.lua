local function addLaddersDistribution()
  UtilsSrv.addItemDistributions({
    {
      Items = {
        "Base.LaddersMagazine"
      },
      Distributions = {
        {"BookstoreMisc", 2},
        {"CrateMagazines", 1},
        {"LibraryBooks", 1},
        {"LivingRoomShelf", 0.1},
        {"LivingRoomShelfNoTapes", 0.1},
        {"LivingRoomSideTable", 0.1},
        {"LivingRoomSideTableNoRemote", 0.1},
        {"MagazineRackMixed", 1},
        {"PostOfficeMagazines", 1},
        {"ShelfGeneric", 1},
        {"ToolStoreBooks", 2}
      }
    }
  })
end

Events.OnPreDistributionMerge.Add(addLaddersDistribution)
