local function addMoreTraitsDistribution()
  utils.addItemDistributions({
    {
      Items = {
        'MoreTraits.MedicalMag1',
        'MoreTraits.MedicalMag2',
        'MoreTraits.MedicalMag3',
        'MoreTraits.MedicalMag4',
        'MoreTraits.AntiqueMag1',
        'MoreTraits.AntiqueMag2',
        'MoreTraits.AntiqueMag3'
      },
      Distributions = {
        {'BookstoreBooks', 0.1},
        {'MagazineRackMixed', 0.1},
        {'PostOfficeMagazines', 0.1},
        {'PostOfficeBooks', 0.1},
        {'PostOfficeNewspapers', 0.1},
        {'CrateNewspapers', 0.1},
        {'MagazineRackMaps', 0.1},
        {'MagazineRackMixed', 0.1},
        {'GunStoreMagazineRack', 0.1},
        {'CrateMagazines', 0.1},
        {'LibraryBooks', 0.1}
      }
    }
  })
end

Events.OnPreDistributionMerge.Add(addMoreTraitsDistribution)