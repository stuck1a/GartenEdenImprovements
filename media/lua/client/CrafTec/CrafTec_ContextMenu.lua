--[[
require "BuildingObjects/ISBuildingObject"
require "BuildingObjects/RainCollectorBarrel"
require "BuildingObjects/ISWaterWell"
if not BCCrafTec then BCCrafTec = {} end
--]]



---
--- Definitionen der Bauprojekte
---
--[[
BCCrafTec.Recipes = {
  ContextMenu_CrafTec_Obj__Wooden_Crate = {
    name = "Wooden crate",
    resultClass = "ISWoodenContainer",
    ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 2 },
    images = {
      Woodwork = {
        [0] = { west = "carpentry_01_19", north = "carpentry_01_20", east = "carpentry_01_21" },
        [7] = { west = "carpentry_01_16", north = "carpentry_01_17", east = "carpentry_01_18" }
      }
    },
    tools = {"Base.Hammer/Base.HammerStone"},
    requirements = { any = { Woodwork = { level = 3, time = 60 } } },
    data = { canBeAlwaysPlaced = true, renderFloorHelper = true }
  },
  ContextMenu_CrafTec_Cat__Indoor = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__Bar = {
      isCategory = true,
      ContextMenu_CrafTec_Obj__Bar_Element = {
        name = "Bar",
        resultClass = "ISWoodenContainer",
        ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4 },
        images = {
          Woodwork = {
            [0] = { west = "carpentry_02_35", north = "carpentry_02_37", east = "carpentry_02_39", south = "carpentry_02_33" },
            [4] = { west = "carpentry_02_27", north = "carpentry_02_29", east = "carpentry_02_31", south = "carpentry_02_25" },
            [7] = { west = "carpentry_02_19", north = "carpentry_02_21", east = "carpentry_02_23", south = "carpentry_02_17" }
          }
        },
        tools = {"Base.Hammer/Base.HammerStone"},
        requirements = { any = { Woodwork = { level = 7, time = 60 } } },
        data = { canBeAlwaysPlaced = true }
      },
      ContextMenu_CrafTec_Obj__Bar_Corner = {
        name = "Bar",
        resultClass = "ISWoodenContainer",
        ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4 },
        images = {
          Woodwork = {
            [0] = { west = "carpentry_02_34", north = "carpentry_02_36", east = "carpentry_02_38", south = "carpentry_02_32" },
            [4] = { west = "carpentry_02_26", north = "carpentry_02_28", east = "carpentry_02_30", south = "carpentry_02_24" },
            [7] = { west = "carpentry_02_18", north = "carpentry_02_20", east = "carpentry_02_22", south = "carpentry_02_16" }
          }
        },
        tools = {"Base.Hammer/Base.HammerStone"},
        data = { canBeAlwaysPlaced = true },
        requirements = { any = { Woodwork = { level = 7, time = 60 } } },
      }
    },
    ContextMenu_CrafTec_Obj__Bed = {
      name = "Bed",
      resultClass = "ISDoubleTileFurniture",
      ingredients = { ["Base.Plank"] = 6, ["Base.Nails"] = 4, ["Base.Mattress"] = 1 },
      images = {
        any = { west = "carpentry_02_73", sprite2 = "carpentry_02_72", north = "carpentry_02_74", northSprite2 = "carpentry_02_75" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 4, time = 80 } } },
    },
    ContextMenu_CrafTec_Obj__Bookcase = {
      name = "Bookcase",
      resultClass = "ISSimpleFurniture",
      ingredients ={ ["Base.Plank"] = 5, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_02_65", north = "carpentry_02_64", east = "carpentry_02_66", south = "carpentry_02_67" },
          [7]= { west = "furniture_shelving_01_41", north = "furniture_shelving_01_40", east = "furniture_shelving_01_42", south = "furniture_shelving_01_43" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 5, time = 60 } } },
      data = { canBeAlwaysPlaced = true, isContainer = true, containerType = "shelves" }
    },
    ContextMenu_CrafTec_Obj__SmallBookcase = {
      name = "Small bookcase",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 3, ["Base.Nails"] = 3 },
      images = {
        any = { west = "furniture_shelving_01_23", north = "furniture_shelving_01_19" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 3, time = 30 } } },
      data = { canBeAlwaysPlaced = true, isContainer = true, containerType = "shelves" }
    },
    ContextMenu_CrafTec_Obj__Shelves = {
      name = "Shelf",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 1, ["Base.Nails"] = 2 },
      images = {
        any = { west = "carpentry_02_68", north = "carpentry_02_69" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 30 } } },
      data = { isContainer = true, containerType = "shelves", needToBeAgainstWall = true, blockAllTheSquare = false }
    },
    ContextMenu_CrafTec_Obj__DoubleShelves = {
      name = "Two shelves",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 4 },
      images = {
        any = { west = "furniture_shelving_01_2", north = "furniture_shelving_01_1" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 4, time = 30 } } },
      data = { isContainer = true, containerType = "shelves", needToBeAgainstWall = true, blockAllTheSquare = false }
    },
    ContextMenu_CrafTec_Obj__Small_Table = {
      name = "Small table",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 5, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_01_60" },
          [4] = { west = "carpentry_01_61" },
          [7] = { west = "carpentry_01_62" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 3, time = 60 } } },
    },
    ContextMenu_CrafTec_Obj__Large_Table = {
      name = "Large table",
      resultClass = "ISDoubleTileFurniture",
      ingredients = { ["Base.Plank"] = 6, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_01_25", sprite2 = "carpentry_01_24", north = "carpentry_01_26", northSprite2 = "carpentry_01_27" },
          [4] = { west = "carpentry_01_29", sprite2 = "carpentry_01_28", north = "carpentry_01_30", northSprite2 = "carpentry_01_31" },
          [7] = { west = "carpentry_01_33", sprite2 = "carpentry_01_32", north = "carpentry_01_34", northSprite2 = "carpentry_01_35" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 4, time = 90 } } },
    },
    ContextMenu_CrafTec_Obj__Table_with_Drawer = {
      name = "Table with drawer",
      resultClass = "ISWoodenContainer",
      ingredients = { ["Base.Plank"] = 5, ["Base.Nails"] = 4, ["Base.Drawer"] = 1 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_02_0", north = "carpentry_02_2", east = "carpentry_02_3", south = "carpentry_02_1" },
          [4] = { west = "carpentry_02_4", north = "carpentry_02_6", east = "carpentry_02_7", south = "carpentry_02_5" },
          [7] = { west = "carpentry_02_8", north = "carpentry_02_10", east = "carpentry_02_11", south = "carpentry_02_9" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 5, time = 60 } } },
      data = { isContainer = true }
    },
    ContextMenu_CrafTec_Obj__Wooden_Chair = {
      name = "Wooden chair",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 5, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_01_36", north = "carpentry_01_38", east = "carpentry_01_37", south = "carpentry_01_39" },
          [4] = { west = "carpentry_01_40", north = "carpentry_01_42", east = "carpentry_01_43", south = "carpentry_01_41" },
          [7] = { west = "carpentry_01_45", north = "carpentry_01_44", east = "carpentry_01_47", south = "carpentry_01_46" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 30 } } },
      data = { canPassThrough = true }
    }
  },
  ContextMenu_CrafTec_Cat__Outdoor = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__Lamp_on_Pillar = {
      name = "Lamp on pillar",
      resultClass = "ISLightSource",
      ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 4, ["Base.Torch"] = 1, ["Base.Rope"] = 1 },
      images = {
        any = { west = "carpentry_02_61", north = "carpentry_02_60", east = "carpentry_02_62", south = "carpentry_02_59" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 4, time = 40 } } },
      data = { offsetX = 5, offsetY = 5, fuel = "Base.Battery", baseItem = "Base.Torch", radius = 10 }
    },
    ContextMenu_CrafTec_Obj__Rain_Collector_Barrel_Small = {
      name = "Rain collector",
      resultClass = "RainCollectorBarrel",
      ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 4, ["Base.Garbagebag"] = 2 },
      images = {
        any = { west = "carpentry_02_54", north = "carpentry_02_54" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 4, time = 60 } } },
      data = { waterMax = (RainCollectorBarrel and RainCollectorBarrel.smallWaterMax) or 40 * 4 },
    },
    ContextMenu_CrafTec_Obj__Rain_Collector_Barrel_Large = {
      name = "Rain collector",
      resultClass = "RainCollectorBarrel",
      ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4, ["Base.Garbagebag"] = 4 },
      images = {
        any = { west = "carpentry_02_52", north = "carpentry_02_52" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 7, time = 90 } } },
      data = { waterMax = (RainCollectorBarrel and RainCollectorBarrel.largeWaterMax) or 100 * 4 }
    },
    ContextMenu_CrafTec_Obj__Sign = {
      name = "Sign",
      resultClass = "ISSimpleFurniture",
      ingredients = { ["Base.Plank"] = 3, ["Base.Nails"] = 3 },
      images = {
        any = { west = "constructedobjects_signs_01_27", north = "constructedobjects_signs_01_11" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 1, time = 10 } } },
      data = { blockAllTheSquare = false }
    }
  },
  ContextMenu_CrafTec_Cat__Fence = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__Wooden_Stake = {
      name = "Wooden stake",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.Plank"] = 1, ["Base.Nails"] = 2 },
      images = {
        any = { west = "fencing_01_19", north = "fencing_01_19" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 5, time = 20 } } },
      data = { canPassThrough = true, canBarricade = false, canBeAlwaysPlaced = true }
    },
    ContextMenu_CrafTec_Obj__Wooden_Fence = {
      name = "Wooden fence",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 3 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_02_40", north = "carpentry_02_41", corner = "carpentry_02_43" },
          [4] = { west = "carpentry_02_44", north = "carpentry_02_45", corner = "carpentry_02_47" },
          [7] = { west = "carpentry_02_48", north = "carpentry_02_49", corner = "carpentry_02_51" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 30 } } },
      data = { hoppable = true, isThumpable = false }
    },
    ContextMenu_CrafTec_Obj__Barbed_Fence = {
      name = "Barbed fence",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.BarbedWire"] = 1 },
      images = {
        any = { west = "fencing_01_20", north = "fencing_01_20" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 5, time = 30 } } },
    },
    ContextMenu_CrafTec_Obj__Sand_Bag_Wall = {
      name = "Sandbag wall",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.Sandbag"] = 3 },
      images = {
        any = { west = "carpentry_02_12", north = "carpentry_02_13", east = "carpentry_02_14", south = "carpentry_02_15" }
      },
      tools = {},
      requirements = { any = { any = { level = 0, time = 10 } } },
      data = { hoppable = true, renderFloorHelper = true }
    },
    ContextMenu_CrafTec_Obj__Gravel_Bag_Wall = {
      name = "Gravelbag wall",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.Gravelbag"] = 3 },
      images = {
        any = { west = "carpentry_02_12", north = "carpentry_02_13", east = "carpentry_02_14", south = "carpentry_02_15" }
      },
      tools = {},
      requirements = { any = { any = { level = 0, time = 10 } } },
      data = { hoppable = true, renderFloorHelper = true,
      }
    }
  },
  ContextMenu_CrafTec_Cat__Floor = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__Wooden_Floor = {
      name = "Wooden floor",
      resultClass = "ISWoodenFloor",
      ingredients = { ["Base.Plank"] = 1, ["Base.Nails"] = 1 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_02_58", north = "carpentry_02_58" },
          [4] = { west = "carpentry_02_57", north = "carpentry_02_57" },
          [7] = { west = "carpentry_02_56", north = "carpentry_02_56" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 1, time = 15, progress = 0 } } }
    }
  },
  ContextMenu_CrafTec_Cat__Stairs = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__Stairs = {
      name = "Wooden stairs",
      resultClass = "ISWoodenStairs",
      ingredients = { ["Base.Plank"] = 8, ["Base.Nails"] = 8 },
      images = {
        any = { west = "fixtures_stairs_01_16", sprite2 = "fixtures_stairs_01_17", sprite3 = "fixtures_stairs_01_18", north = "fixtures_stairs_01_24", northSprite2 = "fixtures_stairs_01_25", northSprite3 = "fixtures_stairs_01_26", pillar = "fixtures_stairs_01_22", pillarNorth = "fixtures_stairs_01_23" }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 6, time = 240, progress = 0 } } }
    }
  },
  ContextMenu_CrafTec_Cat__Walls = {
    isCategory = true,
    ContextMenu_CrafTec_Cat__Log_Wall = {
      isCategory = true,
      ContextMenu_CrafTec_Obj__Log_Wall_With_Sheets = {
        name = "Logwall",
        resultClass = "ISWoodenWall",
        ingredients = { ["Base.Log"] = 4, ["Base.RippedSheets"] = 4 },
        images = {
          any = { west = "carpentry_02_80", north = "carpentry_02_81" }
        },
        tools = {},
        requirements = { any = { any = { level = 0, time = 30, progress = 0 } } },
        data = { canBarricade = false }
      },
      ContextMenu_CrafTec_Obj__Log_Wall_With_Twine = {
        name = "Logwall",
        resultClass = "ISWoodenWall",
        ingredients = { ["Base.Log"] = 4, ["Base.Twine"] = 4 },
        images = {
          any = { west = "carpentry_02_80", north = "carpentry_02_81" }
        },
        tools = {},
        requirements = { any = { any = { level = 0, time = 30, progress = 0 } } },
        data = { canBarricade = false }
      },
      ContextMenu_CrafTec_Obj__Log_Wall_With_Rope = {
        name = "Logwall",
        resultClass = "ISWoodenWall",
        ingredients = { ["Base.Log"] = 4, ["Base.Rope"] = 2 },
        images = {
          any = { west = "carpentry_02_80", north = "carpentry_02_81" }
        },
        tools = {},
        requirements = { any = { any = { level = 0, time = 30, progress = 0 } } },
        data = { canBarricade = false }
      }
    },
    ContextMenu_CrafTec_Obj__Wooden_Door = {
      name = "Wooden door",
      resultClass = "ISWoodenDoor",
      ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4, ["Base.Hinge"] = 2, ["Base.Doorknob"] = 1 },
      images = {
        Woodwork = {
          [0] = { west = "carpentry_01_48", north = "carpentry_01_49", open = "carpentry_01_50", openNorth = "carpentry_01_51" },
          [4] = { west = "carpentry_01_52", north = "carpentry_01_53", open = "carpentry_01_54", openNorth = "carpentry_01_55" },
          [7] = { west = "carpentry_01_56", north = "carpentry_01_57", open = "carpentry_01_58", openNorth = "carpentry_01_59" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 30, progress = 0 } } },
    },
    ContextMenu_CrafTec_Obj__Door_Frame = {
      name = "Door frame",
      resultClass = "ISWoodenDoorFrame",
      ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "walls_exterior_wooden_01_54", north = "walls_exterior_wooden_01_55", corner = "walls_exterior_wooden_01_27" },
          [4] = { west = "walls_exterior_wooden_01_50", north = "walls_exterior_wooden_01_51", corner = "walls_exterior_wooden_01_27" },
          [7] = { west = "walls_exterior_wooden_01_34", north = "walls_exterior_wooden_01_35", corner = "walls_exterior_wooden_01_27" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 60, progress = 0 } } },
      data = { canBePlastered = true, modData = { wallType = "doorframe" } }
    },
    ContextMenu_CrafTec_Obj__Windows_Frame = {
      name = "Window frame",
      resultClass = "ISWoodenWall",
      ingredients = { ["Base.Plank"] = 4, ["Base.Nails"] = 4 },
      images = {
        Woodwork = {
          [0] = { west = "walls_exterior_wooden_01_52", north = "walls_exterior_wooden_01_53", corner = "walls_exterior_wooden_01_27" },
          [4] = { west = "walls_exterior_wooden_01_48", north = "walls_exterior_wooden_01_49", corner = "walls_exterior_wooden_01_27" },
          [7] = { west = "walls_exterior_wooden_01_32", north = "walls_exterior_wooden_01_33", corner = "walls_exterior_wooden_01_27" }
        }
      },
      tools = {"Base.Hammer/Base.HammerStone"},
      requirements = { any = { Woodwork = { level = 2, time = 30, progress = 0 } } },
      data = { canBePlastered = true, hoppable = true, isThumpable = false }
    },
  }
}
--]]




--[[
BCCrafTec.Recipes = {
  ContextMenu_CrafTec_Cat__Architecture = {
    isCategory = true,
    ContextMenu_CrafTec_Cat__Walls = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenWalls = {
        isCategory = true,
        ContextMenu_CrafTec_Obj__WoodenWall = {
          name = "ContextMenu_CrafTec_Obj__WoodenWall",
          resultClass = "ISWoodenWall",
          ingredients = { ["Base.Plank"] = 3, ["Base.Nails"] = 3 },
          images = {
            Woodwork = {
              [0] = { west = "walls_exterior_wooden_01_44", north = "walls_exterior_wooden_01_45", corner = "walls_exterior_wooden_01_27" },
              [4] = { west = "walls_exterior_wooden_01_40", north = "walls_exterior_wooden_01_41", corner = "walls_exterior_wooden_01_27" },
              [7] = { west = "walls_exterior_wooden_01_24", north = "walls_exterior_wooden_01_25", corner = "walls_exterior_wooden_01_27" }
            }
          },
          tools = {"Base.Hammer/Base.HammerStone"},
          requirements = { any = { Woodwork = { level = 2, time = 30, progress = 0 } } },
          data = { canBarricade = false, modData = { wallType = "wall" } }
        },
        ContextMenu_CrafTec_Obj__WoodenPillar = {
          name = "ContextMenu_CrafTec_Obj__WoodenPillar",
          resultClass = "ISWoodenWall",
          ingredients = { ["Base.Plank"] = 2, ["Base.Nails"] = 3 },
          images = {
            any = { west = "walls_exterior_wooden_01_27", north = "walls_exterior_wooden_01_27" }
          },
          tools = {"Base.Hammer/Base.HammerStone"},
          requirements = { any = { Woodwork = { level = 2, time = 30, progress = 0 } } },
          data = { canPassThrough = true, canBarricade = false }
        },
        -- Holztürrahmen
        -- Baumstammwall
      },
      ContextMenu_CrafTec_Cat__MetalWalls = {
        isCategory = true,
        -- Metallwandrahmen
        -- Metallsäule
        -- Metalltürrahmen
      },
      ContextMenu_CrafTec_Cat__StoneWalls = {
        isCategory = true,
        -- Steinwand
        -- Steinsäule
        -- Steintürrahmen
      },
      ContextMenu_CrafTec_Cat__GlasWalls = {
        isCategory = true,
        -- Vollglaswand
        -- Panoramaglaswand
        -- Schaufenster
      },
    },
    ContextMenu_CrafTec_Cat__Doors = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenDoors = {
        isCategory = true,
        -- Holztür
        -- Holztor
        -- Baumstammtor
      },
      ContextMenu_CrafTec_Cat__MetalDoors = {
        isCategory = true,
        -- Metalltür
        -- Sicherheitstür
        -- Eisenstangentür
        -- Eisenstangen-Tor
        -- Maschendrahtzaun-Tor
      },
    },
    ContextMenu_CrafTec_Cat__Flooring = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenFlooring = {
        isCategory = true,
        -- Holzboden
      },
      ContextMenu_CrafTec_Cat__MetalFlooring = {
        isCategory = true,
        -- Metallboden
      },
      ContextMenu_CrafTec_Cat__StoneFlooring = {
        isCategory = true,
        -- Steinboden
      },
    },
    ContextMenu_CrafTec_Cat__Roofing = {
      isCategory = true,
      -- Dachschindeln
    },
    ContextMenu_CrafTec_Cat__Windows = {
      isCategory = true,
      -- Holzenster
      -- Kachelfenster
      -- Metallfenster
    },
    ContextMenu_CrafTec_Cat__LowFences = {
      isCategory = true,
      -- Lattenzaun
      -- Holzzaun
      -- Niedriger Maschendrahtzaun
      -- Geländer
    },
    ContextMenu_CrafTec_Cat__HighFences = {
      isCategory = true,
      -- Hoher Maschendrahtzaun
      -- Eisenstangenzaun
      -- Stacheldrahtzaun
    },
    ContextMenu_CrafTec_Cat__Stairs = {
      isCategory = true,
      -- Holztreppe
      -- Steintreppe
      -- Metalltreppe
    },
  },
  ContextMenu_CrafTec_Cat__Furniture = {
    isCategory = true,
    ContextMenu_CrafTec_Cat__Chairs = {
      isCategory = true,
      -- Holzstuhl
    },
    ContextMenu_CrafTec_Cat__Tables = {
      isCategory = true,
      -- Kleiner Holztisch
      -- Kleiner Holztisch mit Kommode
      -- Großer Holztisch
      -- Lowboard
    },
    ContextMenu_CrafTec_Cat__Bars = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenBars = {
        isCategory = true,
        -- Holztheke
        -- Holzecktheke
      },
      ContextMenu_CrafTec_Cat__MetalBars = {
        isCategory = true,
        -- Metalltheke
        -- Metallecktheke
      },
    },
    ContextMenu_CrafTec_Cat__Dressers = {
      isCategory = true,
      -- Holzkommode
    },
    ContextMenu_CrafTec_Cat__Shelves = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenShelves = {
        isCategory = true,
        -- Einfaches Holzregal
        -- Doppeltes Holzregal
        -- Kleines Bücherregal
        -- Großes Bücherregal
      },
      ContextMenu_CrafTec_Cat__MetalShelves = {
        isCategory = true,
        -- Metallregal
      },
    },
    ContextMenu_CrafTec_Cat__Cabinets = {
      isCategory = true,
      ContextMenu_CrafTec_Cat__WoodenCabinets = {
        isCategory = true,
        -- Wohnzimmerschrank
        -- Kleiderschrank
      },
      ContextMenu_CrafTec_Cat__MetalCabinets = {
        isCategory = true,
        -- Spind
        -- Werkzeugschrank
      },
    },
    ContextMenu_CrafTec_Cat__Beds = {
      isCategory = true,
      -- Einzelbett
      -- Doppelbett
      -- Etagenbett
    },
  },
  ContextMenu_CrafTec_Cat__Container = {
    isCategory = true,
    -- Holzkiste
    -- Metallkiste
  },
  ContextMenu_CrafTec_Cat__Technology = {
    isCategory = true,
    ContextMenu_CrafTec_Obj__WaterWell = {
      name = "ContextMenu_CrafTec_Obj__WaterWell",
      resultClass = "ISWaterWell",
      images = { west = "garteneden_tech_01_0", north = "garteneden_tech_01_0" },
      tools = { "Base.Hammer/Base.HammerStone", "Base.Saw", "Base.Shovel" },
      ingredients = { ["Base.Rope"] = 5, ["Base.Plank"] = 5, ["Base.Nails"] = 10, ["Base.Gravelbag"] = 2, ["Base.BucketEmpty"] = 1 },
      requirements = {
        any = { Woodwork = { level = 7, time = 100, progress = 0 }, any = { level = 0, time = 50, progress = 0 } }
      },
      data = { waterMax = (ISWaterWell and ISWaterWell.waterMax) or 9999 }
    },
    -- Generator
    -- Kühlschrank
    -- Radio
    -- Fernseher
    -- Ofen
    -- Herd
    -- Lampe
  },
  ContextMenu_CrafTec_Cat__Outdoor = {
    isCategory = true,
    ContextMenu_CrafTec_Cat__Street = {
      isCategory = true,
      -- Briefkasten
      -- Postbox
      -- Laterne
      -- Mülltonne
      -- Müllcontainer
    },
    ContextMenu_CrafTec_Cat__Garden = {
      isCategory = true,
      -- Blumenbeet
      -- Steinbeet
    },
    ContextMenu_CrafTec_Cat__Ladders = {
      isCategory = true,
      -- Holzleiter
      -- Metallleiter
    },
  },
  ContextMenu_CrafTec_Cat__Decoration = {
    isCategory = true,
    ContextMenu_CrafTec_Cat__DecoOutdoor = {
      isCategory = true,
      -- Gartenzwerg
      -- Flamingo
      -- Spielplatzrutsche
      -- Spielplatzkreisel
    },
    ContextMenu_CrafTec_Cat__DecoIndoor = {
      isCategory = true,
      -- Wanduhr
      -- Post-Its
      -- Tafel
      -- Landkarte
    },
  },
  ContextMenu_CrafTec_Cat__Misc = {
    isCategory = true,
     -- Steinhaufen
     -- Holzpfosten
     -- Holzkreuz
  },
}
--]]
