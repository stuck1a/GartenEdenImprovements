if not ExtBuildingContextMenu then ExtBuildingContextMenu = {} end
if not ExtBuildingContextMenu.call then
  ExtBuildingContextMenu.call = function(callback, ...) return callback(...) end
  setmetatable(ExtBuildingContextMenu, {__call = ExtBuildingContextMenu.call})
end


-- SUBMENU ENTRIES:
--[[
DisplayNameTranslationString = {
  { ... },
  { ... },
  ...
}
--]]

-- RECIPE ENTRIES (Basically only targetClass ist mandatory. But there might be another mandatory fields if targetClass is only a generic class for different recipes)
--[[
{
  targetClass = 'ISWoodenContainer',  -- will use 'ISBuildingObject' if not set
  displayName = 'ContextMenu_ReinforcedBox',
  buildTime = 500,
  baseHealth = 1000,
  mainMaterial = 'wood',
  breakSound = 'BreakObject',
  completionSound = 'BuildWoodenStructureMedium',
  sprites = {
    sprite = 'carpentry_02_17',
    north = 'carpentry_02_18',
    south = 'carpentry_02_19',
    east = 'carpentry_02_20',
    open = 'carpentry_02_22,
    corner = 'carpentry_02_21',
    damaged = 'carpentry_05_17',
    },
  },
  properties = {
    canBeLockedByPadlock = true
    myCustomField = myValue  -- of course this makes only sense if the target class will make any use of it as well
  },
  modData = {
    -- any item with tag 'Hammer' will work, but tooltip will display translated name of 'Base.Hammer' only
    ['keep:' .. utils.concatItemTypes({'Hammer'})] = 'Base.Hammer',
    ['keep:Base.Torch/MyMod.LargeTorch'] = 'Base.Torch',
    ['need:Base.Plank'] = 8,
    ['need:Base.Nails'] = 12,
    ['need:Base.IronPlate'] = 4,
    -- any drainable item must use the 'use:" prefix. Value is then the number of uses, not the item count
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
        {
          displayName = 'ContextMenu_Wooden_Wall_Frame',
          targetClass = 'ISWall',
          tooltipDesc = 'Tooltip_craft_woodenWallFrameDesc',
          sprites = {
            sprite = 'carpentry_02_100',
            northSprite = 'carpentry_02_101',
            corner = 'walls_exterior_wooden_01_27'
          },
          isoData = { isoName = 'WoodenWallFrame' },
          properties = {
            canBePlastered = function(o) return getSpecificPlayer(o.player):getPerkLevel(Perks.Woodwork) > 7 end,
            completionSound = 'BuildWoodenStructureLarge'
          },
          modData = {
            ['keep:' .. utils.concatItemTypes({'Hammer'})] = 'Base.Hammer',
            ['keep:' .. utils.concatItemTypes({'Saw'})] = 'Base.Saw',
            ['need:Base.Plank'] = 3,
            ['need:Base.Nails'] = 3,
            ['requires:Woodwork'] = 2,
            ['xp:Woodwork'] = 5
          }
        },
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
      targetClass = 'ISWaterCollector',
      displayName = 'ContextMenu_ExtBuilding_Obj__WaterWell',
      tooltipDesc = 'Tooltip_ExtBuilding__WaterWell',
      buildTime = 700,
      baseHealth = 600,
      mainMaterial = 'stone',
      completionSound = 'BuildFenceCairn',
      isoData = { isoName = 'waterwell' },
      properties = { waterAmount = 50, waterMax = 5000, addWaterPerAction = 5, craftingBank = 'Shoveling' },
      sprites = { sprite = 'garteneden_tech_01_0', northSprite = 'garteneden_tech_01_1' },
      modData = {
        ['keep:' .. utils.concatItemTypes({'Hammer'})] = 'Base.Hammer',
        ['keep:' .. utils.concatItemTypes({'Saw'})] = 'Base.Saw',
        ['keep:' .. utils.concatItemTypes({'DigGrave'})] = 'Base.Shovel',
        ['need:Base.Rope'] = 5,
        ['need:Base.Plank'] = 4,
        ['need:Base.Nails'] = 10,
        ['need:Base.Stone'] = 20,
        ['use:Base.Gravelbag'] = 8,
        ['need:Base.BucketEmpty'] = 1,
        ['requires:Woodwork'] = 7,
        ['requires:Fitness'] = 5,
        ['xp:Woodwork'] = 5,
        ['xp:Fitness'] = 5
      }
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
  }
}