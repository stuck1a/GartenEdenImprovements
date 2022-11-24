local function addSprayPaintDistribution()
  utils.addItemDistributions({
    {
      Items = {
        'Base.SpraycanWhite',
        'Base.SpraycanRed',
        'Base.SpraycanBlue',
        'Base.SpraycanGreen',
        'Base.SpraycanOrange',
        'Base.SpraycanViolet',
        'Base.SpraycanYellow',
        'Base.SpraycanBlack'
      },
      Distributions = {
        { 'SchoolLockers', 0.5 },
        { 'ClassroomDesk', 0.25 },
        { 'CratePaint', 2 },
        { 'CrateTools', 1 },
        { 'GarageTools', 1 },
        { 'MechanicShelfTools', 2 }
      }
    }
  })
end

Events.OnPreDistributionMerge.Add(addSprayPaintDistribution)