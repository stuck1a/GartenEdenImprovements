
--[[
TODO: Fehlende Funktionen für ExtBuilding
  - overwriteHandModel    Callback-Funktionen, wenn möglich dynamisch von genutzten Tools ableiten
  - height                "low"/"medium"/"high" -> Anpassung der LootHeight oder wie das hieß (Bauposition)
--]]





-- SYNTAX AND SEMANTIC OF SUBMENU ENTRIES:
--[[
SubcategoryTranslationStringIdentifier = {
  { ... },
  { ... },
  ...
}
--]]


-- SYNTAX AND SEMANTIC OF RECIPE ENTRIES:
--[[
-- Basically no value is mandatory. But depending on the targetClass used, there will be some.
-- The following shows ALL existing fields. Most classes will use only a couple of them and there are also default values
-- gathered from the targetClass as well as general defaults gathered from the base class ISExtBuildingObject.
-- If a value does not differ from the default value, it can be omitted.
-- General defaults will be overwritten by class level defaults which will be overwritten by recipe level values.
{
  targetClass = 'ISWoodenContainer',    -- will use 'ISBuildingObject' if not set
  requiresRecipe = 'Make Metal Containers',    -- if a recipe script must be learned first to unlock this structure
  displayName = 'ContextMenu_ReinforcedBox',    -- name which will be used in context menus, toolTips, etc.
  buildTime = 500,    -- base value for calculating the duration of the build action
  baseHealth = 1000,    -- base value for calculating the max health value
  mainMaterial = 'wood',    -- decides which skill lvl determines the extra health (allowed is 'wood', 'metal', 'stone' or 'glass')
  breakSound = 'BreakObject',    -- will be played once, if the construction gets destroyed
  thumpSound = 'ZombieThumpGeneric',    -- will be played whenever the object is hit by any character (zombie, player, npc)
  hasSpecialTooltip = false,    -- Set to true for hover tooltips. This requires a mounted DoSpecialTooltip listener within the given targetClass TODO: Allow dynamic listener mount
  craftingBank = 'BuildingGeneric',    -- used sound script while performing the build action (it will alternate with tool sounds of the first two tool requirements defined as modData "keep:" entry. It can be used for regular construction sounds as well as "real" crafting bank sounds.
  completionSound = 'BuildWoodenStructureMedium',    -- will be played once if the construction is completed
  isoData = {
    isoName = 'reinforcedbox',    -- defines the internal name, but also the name of the global map object, if targetClass defines any. If a global object has several subtypes (like in "watercollector"), this might be used to differ between those subtypes (like "waterwell", "rainbarrel"). If there are no subtypes, then it can simply use the same value as its systemName (name of the associated global object system, which must be unique and is usually defined on class level)
    isoType = 'IsoThumpable',    -- The iso object type used for this recipe - influences which Java constructor will be used on object creation
    objectModDataKeys = { 'waterAmount', 'waterMax', 'addWaterPerAction' },    -- names of the properties which shall be stored for the global map objects
  },
  sprites = {
    sprite = 'carpentry_02_17',    -- the base sprite (usually its the west sprite)
    north = 'carpentry_02_18',    -- if layout differs when placed in north direction. Otherwise the base sprite will be used as well.
    south = 'carpentry_02_19',     -- if layout differs when placed in south direction. Otherwise the north/base sprite will be used as well.
    east = 'carpentry_02_20',     -- if layout differs when placed in south direction. Otherwise the base sprite will be used as well.
    open = 'carpentry_02_22,    -- sprite in "opened" state for things like traps, doors, etc
    corner = 'carpentry_02_21',    -- edge sprites for wallLike objects
    damaged = 'carpentry_05_17',    -- Sprite which will be used if the object gets damaged (e.g. by a car)
    },
  },
  -- can be used to define properties like canBePlastered, isHoppable, etc. but also for custom properties.
  -- Each property will the added to the iso object instance on top level.
  -- Within this properties table, callback functions might be defined as long as they return a valid value for
  -- the given property. Such functions will always receive the class object instance as argument.
  properties = {
    canBeLockedByPadlock = true    --- one of the vanilla properties as an example - will influence the behaviour/functionality
    myCustomField = myValue    -- of course this makes only sense if the target class will make any use of it as well
  },
  -- Allows additional checks for the isValid function of the given targetClass. Will receive the square object as argument.
  isValidAddition = function(sq) return sq ~= nil end
  -- forceEquip can be used, to specify, which tools/wearables/materials should be equipped (will also influence toolSound1 and toolSound2)
  -- The values must match the keys of the target modData entries.
  -- If forceEquip is used, no automatic selection will be done, so if one is omitted or invalid, this slot will be ignored.
  forceEquip = {
    ['tool1'] = 'use:Base.BlowTorch/MyMod.LargeBlowTorch',    -- enforces to use BlowTorch as tool1m (and for toolSound1, if a mapping for it exists) instead of the Hammer (which would be chosen by the automation)
    ['tool2'] = 'use:Base.WeldingStab/MyMod.WeldingStab2',    -- enforces to use WeldingStab as tool2 (and for toolSound2, if a mapping for it exists)
    ['wearable'] = 'keep:' .. utils.concatItemTypes({'WeldingMask'})    -- enforces wearing the WeldingMask entry (can also handle more items (like 2,5,3,7) to wear several clothing items
  }
  -- Mainly used to define the requirements to build the structure.
  -- For that, it recognizes keys beginning with keep, need, use, requires and xp.
  -- They have the same meaning like in script files.
  -- This table might be used for any other values as well, but usually, the properties table should suit more for any other.
  -- The order (within each prefix group) will also define the order, in which those items will be displayed in the build menu.
  modData = {
    -- any item with tag 'Hammer' will work, but the build menu will show the translated name of 'Base.Hammer' only
    ['keep:' .. utils.concatItemTypes({'Hammer'})] = 'Base.Hammer',
    ['keep:' .. utils.concatItemTypes({'WeldingMask'})] = 'Base.WeldingMask',
    ['use:Base.WeldingStab/MyMod.WeldingStab2'] = 4,
    ['need:Base.Plank'] = 8,
    ['need:Base.Nails'] = 12,
    ['need:Base.IronPlate'] = 4,
    -- Any drainable item must use the 'use:" prefix. The value then represents the number of uses, not the item count
    ['use:Base.BlowTorch/MyMod.LargeBlowTorch'] = 8,
    -- The skill levels (perks) this recipe requires
    ['requires:Woodwork'] = 2,
    ['requires:MetalWelding'] = 1,
    -- The gained experience - note that this value will be gained a couple of times while the build action processes.
    ['xp:Woodwork'] = 5,
    ['xp:MetalWelding'] = 5
  }
}
--]]


if not ExtBuildingContextMenu then ExtBuildingContextMenu = {} end
if not ExtBuildingContextMenu.call then
  ExtBuildingContextMenu.call = function(callback, ...) return callback(...) end
  setmetatable(ExtBuildingContextMenu, {__call = ExtBuildingContextMenu.call})
end



---
--- This table will be used in ExtBuilding_ContextMenu.lua
--- to create all submenus and their recipes of the new build menu
---
ExtBuildingContextMenu.BuildingRecipes = {
  ContextMenu_ExtBuilding_Cat__Architecture = {
    ContextMenu_ExtBuilding_Cat__Walls = {
      {
        displayName = 'ContextMenu_Wooden_Wall_Frame',
        targetClass = 'ISWall',
        buildTime = 1000,
        tooltipDesc = 'Tooltip_ExtBuilding__WoodenWallFrame',
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
      {
        displayName = 'ContextMenu_MetalWallFrame',
        targetClass = 'ISWall',
        requiresRecipe = 'Make Metal Walls',
        tooltipDesc = 'Tooltip_ExtBuilding__MetalWallFrame',
        thumpSound = 'ZombieThumpMetal',
        sprites = {
          sprite = 'constructedobjects_01_68',
          northSprite = 'constructedobjects_01_69',
          corner = 'constructedobjects_01_51'
        },
        isoData = { isoName = 'MetalWallFrame' },
        properties = {
          completionSound = 'BuildMetalStructureWallFrame'
        },
        modData = {
          ['keep:' .. utils.concatItemTypes({'WeldingMask'})] = 'Base.WeldingMask',
          ['need:Base.MetalBar']= 3,
          ['use:Base.BlowTorch'] = 8,
          ['use:Base.WeldingRods'] = 4,
          ['requires:MetalWelding'] = 3,
          ['xp:MetalWelding'] = 20,
        },
        forceEquip = {
          ['tool1'] = 'use:Base.BlowTorch',
          ['tool2'] = 'use:Base.WeldingRods',
          ['wearable'] = 'keep:' .. utils.concatItemTypes({'WeldingMask'})
        }
      },
      -- Steinwand
      -- Vollglaswand
      -- Panoramaglaswand
      -- Baumstammwall
      -- Holzsäule
      -- Metallsäule
      -- Steinsäule
      -- Holztürrahmen
      -- Metalltürrahmen
      -- Steintürrahmen
    },
    ContextMenu_ExtBuilding_Cat__Doors = {
      -- Holztür
      -- Metalltür
      -- Eisenstangentür
      -- Holztor
      -- Baumstammtor
      -- Eisenstangen-Tor
      -- Maschendrahtzaun-Tor
      -- Sicherheitstür
      },
    ContextMenu_ExtBuilding_Cat__Flooring = {
      -- Holzboden
      -- Metallboden
      -- Steinboden
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
        -- Holztheke
        -- Holzecktheke
        -- Metalltheke
        -- Metallecktheke
    },
    ContextMenu_ExtBuilding_Cat__Dressers = {
      -- Holzkommode
    },
    ContextMenu_ExtBuilding_Cat__Shelves = {
      -- Einfaches Holzregal
      -- Doppeltes Holzregal
      -- Kleines Bücherregal
      -- Großes Bücherregal
      -- Metallregal
    },
    ContextMenu_ExtBuilding_Cat__Cabinets = {
      -- Wohnzimmerschrank
      -- Kleiderschrank
      -- Spind
      -- Werkzeugschrank
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
      buildTime = 2000,
      baseHealth = 600,
      mainMaterial = 'stone',
      completionSound = 'BuildFenceCairn',
      isoData = { isoName = 'waterwell' },
      isValidAddition = function(sq)
        if sq:getZ() ~= 0 then return false end
        -- tile must have any exterior, natural ground (except water) - shovelled or not
        local props = sq:getProperties()
        if props:Is(IsoFlagType.water) then return false end
        for i=1, sq:getObjects():size() do
          local obj = sq:getObjects():get(i-1)
          local objModData = obj:getModData()
          if objModData ~= nil then
            local shovelledSprites = objModData.shovelledSprites
            if shovelledSprites ~= nil then
              for j=1, #shovelledSprites do
                if luautils.stringStarts(shovelledSprites[j], 'blends_natur') then
                  return true
                end
              end
              return false
            else
              local textureName = obj:getTextureName() or 'occupied'
              if (not luautils.stringStarts(textureName, 'floors_exterior_natur')) and (not luautils.stringStarts(textureName, 'blends_natur')) then return false end
            end
          end
        end
        return true
      end,
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