ExtBuildingContextMenu = ExtBuildingContextMenu or {}


-- SUBCATEGORY ENTRIES:
--[[
DisplayNameTranslationString = {
  --isCategory = true,
  Entry1 = { ... },
  Entry2 = { ... },
  ...
}
--]]

-- RECIPE ENTRIES (none of them are mandatory. Specify only these which differs from targetClass' default values):
--[[
ContextMenu_ReinforcedBox = {
  targetClass = 'ISWoodenContainer',  -- will use 'ISBuildingObject' if not set
  name = 'ContextMenu_ReinforcedBox',
  buildTime = 500,
  baseHealth = 1000,
  mainMaterial = 'wood',
  breakSound = 'BreakObject',
  completionSound = 'BuildWoodenStructureMedium',
  sprites = {
    sprite = 'carpentry_02_17',
    north = 'carpentry_02_18',
    south = 'carpentry_02_19',
    north = 'carpentry_02_20',
    corner = 'carpentry_02_21',
    damaged = 'carpentry_05_17',
    tiers = {
      [1] = {
        requires = { ['Woodwork'] = 4, ['NetalWelding'] = 3 },
        sprite = 'carpentry_03_17',
        north = 'carpentry_03_18',
        south = 'carpentry_03_19',
        north = 'carpentry_03_20'
      },
      [2] = {
        requires = { ['Woodwork'] = 7, ['NetalWelding'] = 5 },
        sprite = 'carpentry_03_17',
        north = 'carpentry_03_18',
        south = 'carpentry_03_19',
        north = 'carpentry_03_20',
        corner = 'carpentry_02_21'
      },
      -- add as many tiers as wanted. The one with the highest ID whose skill requirements are ALL met will be used
    },
  },
  -- of course this makes only sense if targetClass will make any use of it as well
  additionalFields = {
    lockDigitsAmount = 4
  }

  properties = {
    canBeLockedByPadlock = true
  },
  modData = {
    -- any item with tag 'Hammer' will work, but tooltip will display name of 'Base.Hammer' only
    ['keep:' .. UtilsSrv.ConcatItemTypes({'Hammer'})] = 'Base.Hammer',
    ['keep:Base.Torch/MyMod.LargeTorch'] = 'Base.Torch',
    ['need:Base.Plank'] = 8,
    ['need:Base.Nails'] = 12,
    ['need:Base.IronPlate'] = 4,
    -- any drainable item must use the 'use:" prefix. Will consume 4 units.
    ['use:Base.WeldingStab/MyMod.WeldingStab2'] = 4,
    ['requires:Woodwork'] = 2,
    ['requires:MetalWelding'] = 1,
    ['xp:Woodwork'] = 5,
    ['xp:MetalWelding'] = 5
  }
}
--]]





---
--- This table will be used in ExtBuilding_ContextMenu.lua
--- to create all submenus and their recipes of the new build menu
---
ExtBuildingContextMenu.BuildingRecipes = {
  ContextMenu_ExtBuilding_Cat__Architecture = {
    ContextMenu_ExtBuilding_Cat__Walls = {
      ContextMenu_ExtBuilding_Cat__WoodenWalls = {
        -- Holzwand
        -- Holzsäule
        -- Holztürrahmen
        -- Baumstammwall
      },
      ContextMenu_ExtBuilding_Cat__MetalWalls = {
        -- Metallwandrahmen
        -- Metallsäule
        -- Metalltürrahmen
      },
      ContextMenu_ExtBuilding_Cat__StoneWalls = {
        -- Steinwand
        -- Steinsäule
        -- Steintürrahmen
      },
      ContextMenu_ExtBuilding_Cat__GlasWalls = {
        -- Vollglaswand
        -- Panoramaglaswand
        -- Schaufenster
      },
    },
    ContextMenu_ExtBuilding_Cat__Doors = {
      ContextMenu_ExtBuilding_Cat__WoodenDoors = {
        -- Holztür
        -- Holztor
        -- Baumstammtor
      },
      ContextMenu_ExtBuilding_Cat__MetalDoors = {
        -- Metalltür
        -- Sicherheitstür
        -- Eisenstangentür
        -- Eisenstangen-Tor
        -- Maschendrahtzaun-Tor
      },
    },
    ContextMenu_ExtBuilding_Cat__Flooring = {
      ContextMenu_ExtBuilding_Cat__WoodenFlooring = {
        -- Holzboden
      },
      ContextMenu_ExtBuilding_Cat__MetalFlooring = {
        -- Metallboden
      },
      ContextMenu_ExtBuilding_Cat__StoneFlooring = {
        -- Steinboden
      },
    },
    ContextMenu_ExtBuilding_Cat__Roofing = {
      -- Dachschindeln
    },
    ContextMenu_ExtBuilding_Cat__Windows = {
      -- Holzfenster
      -- Kachelfenster
      -- Metallfenster
    },
    ContextMenu_ExtBuilding_Cat__LowFences = {
      -- Lattenzaun
      -- Holzzaun
      -- Niedriger Maschendrahtzaun
      -- Geländer
    },
    ContextMenu_ExtBuilding_Cat__HighFences = {
      -- Hoher Maschendrahtzaun
      -- Eisenstangenzaun
      -- Stacheldrahtzaun
    },
    ContextMenu_ExtBuilding_Cat__Stairs = {
      -- Holztreppe
      -- Steintreppe
      -- Metalltreppe
    },
  },
  ContextMenu_ExtBuilding_Cat__Furniture = {
    ContextMenu_ExtBuilding_Cat__Chairs = {
      -- Holzstuhl
    },
    ContextMenu_ExtBuilding_Cat__Tables = {
      -- Kleiner Holztisch
      -- Kleiner Holztisch mit Kommode
      -- Großer Holztisch
      -- Lowboard
    },
    ContextMenu_ExtBuilding_Cat__Bars = {
      ContextMenu_ExtBuilding_Cat__WoodenBars = {
        -- Holztheke
        -- Holzecktheke
      },
      ContextMenu_ExtBuilding_Cat__MetalBars = {
        -- Metalltheke
        -- Metallecktheke
      },
    },
    ContextMenu_ExtBuilding_Cat__Dressers = {
      -- Holzkommode
    },
    ContextMenu_ExtBuilding_Cat__Shelves = {
      ContextMenu_ExtBuilding_Cat__WoodenShelves = {
        -- Einfaches Holzregal
        -- Doppeltes Holzregal
        -- Kleines Bücherregal
        -- Großes Bücherregal
      },
      ContextMenu_ExtBuilding_Cat__MetalShelves = {
        -- Metallregal
      },
    },
    ContextMenu_ExtBuilding_Cat__Cabinets = {
      ContextMenu_ExtBuilding_Cat__WoodenCabinets = {
        -- Wohnzimmerschrank
        -- Kleiderschrank
      },
      ContextMenu_ExtBuilding_Cat__MetalCabinets = {
        -- Spind
        -- Werkzeugschrank
      },
    },
    ContextMenu_ExtBuilding_Cat__Beds = {
      -- Einzelbett
      -- Doppelbett
      -- Etagenbett
    },
  },
  ContextMenu_ExtBuilding_Cat__Container = {
    -- Holzkiste
    -- Metallkiste
  },
  ContextMenu_ExtBuilding_Cat__Technology = {
    {
      name = 'ContextMenu_ExtBuilding_Obj__WaterWell',
      desc = 'Tooltip_ExtBuilding__WaterWell',
      targetClass = 'ISWaterWell'
    },
    -- Generator
    -- Kühlschrank
    -- Radio
    -- Fernseher
    -- Ofen
    -- Herd
    -- Lampe
  },
  ContextMenu_ExtBuilding_Cat__Outdoor = {
    ContextMenu_ExtBuilding_Cat__Street = {
      -- Briefkasten
      -- Postbox
      -- Laterne
      -- Mülltonne
      -- Müllcontainer
    },
    ContextMenu_ExtBuilding_Cat__Garden = {
      -- Blumenbeet
      -- Steinbeet
    },
    ContextMenu_ExtBuilding_Cat__Ladders = {
      -- Holzleiter
      -- Metallleiter
    },
  },
  ContextMenu_ExtBuilding_Cat__Decoration = {
    ContextMenu_ExtBuilding_Cat__DecoOutdoor = {
      -- Gartenzwerg
      -- Flamingo
      -- Spielplatzrutsche
      -- Spielplatzkreisel
    },
    ContextMenu_ExtBuilding_Cat__DecoIndoor = {
      -- Wanduhr
      -- Post-Its
      -- Tafel
      -- Landkarte
    },
  },
  ContextMenu_ExtBuilding_Cat__Misc = {
    -- Steinhaufen
    -- Holzpfosten
    -- Holzkreuz
  },
}