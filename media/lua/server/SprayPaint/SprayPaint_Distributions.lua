local function addSprayPaintDistribution()
  UtilsSrv.addItemDistributions({
    -- Cans
    {
      Items = {
        "Base.SpraycanWhite",
        "Base.SpraycanRed",
        "Base.SpraycanBlue",
        "Base.SpraycanGreen",
        "Base.SpraycanOrange",
        "Base.SpraycanViolet",
        "Base.SpraycanYellow",
        "Base.SpraycanBlack"
      },
      Distributions = {
        {"SchoolLockers", 0.5},
        {"ClassroomDesk", 0.25},
        {"CratePaint", 2},
        {"CrateTools", 1},
        {"GarageTools", 1},
        {"MechanicShelfTools", 2}
      }
    },
    -- Chalk
    {
      Items = {
        "Base.ChalkWhite",
        "Base.ChalkRed",
        "Base.ChalkBlue",
        "Base.ChalkGreen",
        "Base.ChalkOrange",
        "Base.ChalkViolet",
        "Base.ChalkYellow",
        "Base.ChalkCyan"
      },
      Distributions = {
        {"SchoolLockers", 1},
        {"ClassroomDesk", 0.5},
        {"ClassroomMisc", 2},
        {"CratePaint", 1},
        {"CrateTools", 0.5},
        {"GarageTools", 0.5},
        {"GigamartSchool", 10},
        {"CrateOfficeSupplies", 0.5}
      }
    }
  })
end

Events.OnPreDistributionMerge.Add(addSprayPaintDistribution)
