	--1
table.insert(levelsLDTK, {
  identifier = "Room_1",
  uniqueIdentifer = "bfb67140-96d0-11f1-ad82-3f89976fa342",
  neighbourLevels = {
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "e"
    },
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "n"
    },
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "w"
    },
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 1,
    tile = 1,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "StartDown",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Lamp = {
      {
        id = "Lamp",
        iid = "bfb69854-96d0-11f1-ad82-67cc62b30e7e",
        x = 228,
        y = 84,
        width = 32,
        height = 32,
        customFields = {
          type = "lamp",
          isItem = true
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "079863b0-96d0-11f1-ad82-d9dd52471a07",
        x = 268,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      }
    },
    Microwave = {
      {
        id = "Microwave",
        iid = "0a424e00-96d0-11f1-ad82-c56d82c875a8",
        x = 84,
        y = 68,
        width = 32,
        height = 32,
        customFields = {
          type = "microwave",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      }
    },
    Food = {
      {
        id = "Food",
        iid = "0e0410f0-96d0-11f1-ad82-298f259de645",
        x = 324,
        y = 60,
        width = 32,
        height = 32,
        customFields = {
          type = "food",
          grants = "hasitemname:bool",
          isItem = true
        }
      }
    },
    PneumaticTube = {
      {
        id = "PneumaticTube",
        iid = "cbb8c120-96d0-11f1-ad82-5332d2a51eed",
        x = 284,
        y = 76,
        width = 32,
        height = 32,
        customFields = {
          type = "pneumaticTube",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Tube = {
      {
        id = "Tube",
        iid = "d5516b60-96d0-11f1-ad82-e3b447c88955",
        x = 284,
        y = 44,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "d635ff00-96d0-11f1-ad82-895f3e67cf88",
        x = 284,
        y = 12,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "bfb69857-96d0-11f1-ad82-1f192d5b24b6",
        x = 68,
        y = 100,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "bfb69859-96d0-11f1-ad82-2b5f16e72a8b",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985a-96d0-11f1-ad82-5de2ba31323d",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985b-96d0-11f1-ad82-5d7ef3a9195d",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985c-96d0-11f1-ad82-ebda792ff8f0",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985d-96d0-11f1-ad82-43735b45f2ec",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985e-96d0-11f1-ad82-578136606ef2",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb6985f-96d0-11f1-ad82-07133c980a6b",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb69860-96d0-11f1-ad82-afc7b5b93419",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb69861-96d0-11f1-ad82-f57420f5b019",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb69862-96d0-11f1-ad82-6fff52620b06",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb69863-96d0-11f1-ad82-b5c1478dc1e8",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bfb69864-96d0-11f1-ad82-1fb5de7f40a5",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--2
table.insert(levelsLDTK, {
  identifier = "Room_2",
  uniqueIdentifer = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
  neighbourLevels = {
    {
      levelIid = "a82c8680-48b0-11f1-9f4d-49a4be703c65",
      dir = "n"
    },
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "e"
    },
    {
      levelIid = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a",
      dir = "ne"
    },
    {
      levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
      dir = "w"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "s"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 2,
    tile = 2,
    DoorsConnection = {
      "Down",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Triggers = {
      {
        id = "Triggers",
        iid = "04803a80-ac70-11f0-ae64-7fad2120052d",
        x = 156,
        y = 116,
        width = 40,
        height = 40,
        customFields = {
          script = "giftFor100",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "0f48b230-ac70-11f0-ae64-49bfdc9ab6ce",
        x = 228,
        y = 100,
        width = 40,
        height = 40,
        customFields = {
          script = "giftFor233",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "7d672b30-ac70-11f0-ae64-79d729daa857",
        x = 332,
        y = 188,
        width = 88,
        height = 64,
        customFields = {
          script = "entranceMess",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "54d22370-d380-11f0-88fd-914d0158f881",
        x = 196,
        y = 140,
        width = 32,
        height = 32,
        customFields = {
          script = "myGift",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {
            "run>=1"
          }
        }
      },
      {
        id = "Triggers",
        iid = "d86c3bd0-fa90-11f0-88fd-7de014001b21",
        x = 180,
        y = 60,
        width = 96,
        height = 24,
        customFields = {
          script = "whyXmas",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {
            "isTiny:hugeXmas"
          },
          SpawnConditions = {}
        }
      }
    },
    ItemGift = {
      {
        id = "ItemGift",
        iid = "ab0e6080-d380-11f0-88fd-23cdcf2dde52",
        x = 196,
        y = 140,
        width = 32,
        height = 32,
        customFields = {
          type = "itemGift",
          grants = "hasDWatch:true",
          isItem = true,
          SpawnConditions = {
            "run>=1"
          }
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "a6eb3090-48b0-11f1-89a8-87e2ffc3bcd6",
        x = 44,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = true
        }
      }
    },
    Box = {
      {
        id = "Box",
        iid = "f2aa63d0-48b0-11f1-a37f-c922cea0b4bc",
        x = 92,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "b3283eb0-ac70-11f0-8539-f3c8ed5b1669",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b620e540-ac70-11f0-8539-71a575f15bb9",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4cb79cf0-48b0-11f1-98a2-dfecb9a10b6c",
        x = 72,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "55eb6ae0-48b0-11f1-98a2-4b4928ab4032",
        x = 376,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "5b7f4760-48b0-11f1-8344-5388973b6c72",
        x = 396,
        y = 216,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--3
table.insert(levelsLDTK, {
  identifier = "Room_3",
  uniqueIdentifer = "bf654080-ac70-11f0-997a-e578ba2da2ac",
  neighbourLevels = {
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "w"
    },
    {
      levelIid = "a82c8680-48b0-11f1-9f4d-49a4be703c65",
      dir = "nw"
    },
    {
      levelIid = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a",
      dir = "n"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "sw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "s"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 3,
    tile = 3,
    DoorsConnection = {
      "Left",
      "Down"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    TKNotes = {
      {
        id = "TKNotes",
        iid = "9cf74490-21a0-11f1-b443-cb698825c644",
        x = 188,
        y = 44,
        width = 120,
        height = 32,
        customFields = {
          String = "Elementos de cocina"
        }
      },
      {
        id = "TKNotes",
        iid = "b13c7a10-21a0-11f1-b443-431cf9e7ab86",
        x = 292,
        y = 100,
        width = 56,
        height = 32,
        customFields = {
          String = "Pasada solo en tiny"
        }
      }
    },
    Triggers = {
      {
        id = "Triggers",
        iid = "c9660040-ac70-11f0-ae64-094e17987f94",
        x = 92,
        y = 60,
        width = 56,
        height = 32,
        customFields = {
          script = "microwaveBurn",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "f2317670-ac70-11f0-ae64-133829c2c353",
        x = 252,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          script = "kitchenWeapons",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {
            "isTiny:tinyKnife"
          },
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "3a47bf50-ac70-11f0-ae64-474c236a6fd7",
        x = 340,
        y = 108,
        width = 56,
        height = 48,
        customFields = {
          script = "inneficientCutting",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "a059dac0-ac70-11f0-ae64-f1ee9dff56d1",
        x = 44,
        y = 196,
        width = 48,
        height = 40,
        customFields = {
          script = "justBoxes",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "26163fe0-ac70-11f0-8398-53067febe16c",
        x = 204,
        y = 204,
        width = 64,
        height = 40,
        customFields = {
          script = "notnormalBrocoli",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {
            "runCount>=2:notTheFirstTime"
          },
          SpawnConditions = {}
        }
      }
    },
    Box = {
      {
        id = "Box",
        iid = "5ff38f00-21a0-11f1-8318-7fc02d4297e0",
        x = 44,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Lamp = {
      {
        id = "Lamp",
        iid = "f05c9f40-6fc0-11f1-a708-e973129e086d",
        x = 340,
        y = 180,
        width = 32,
        height = 32,
        customFields = {
          type = "lamp",
          isItem = true
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "bb73a870-ac70-11f0-8539-03f7dfb4cdc8",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bf724d50-ac70-11f0-8539-137cb38eca29",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e1699320-d380-11f0-a276-052d46aa38e7",
        x = 344,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "49e32660-fa90-11f0-9f0d-3381c910a0b4",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "49b942b0-48b0-11f1-8344-c3ad89410636",
        x = 4,
        y = 216,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    },
    PortalDoors = {
      {
        id = "PortalDoors",
        iid = "25b7b320-48b0-11f1-b2c1-f3c6cc9fc228",
        x = 152,
        y = 56,
        width = 16,
        height = 16,
        customFields = {
          PortalID = 1,
          SpawnX = 200,
          SpawnY = 184,
          Conditions = {
            "isTiny:true"
          },
          BlockedDialog = "cabinetHole",
          DestRoom = "Room_81"
        }
      }
    }
  }
})
	--4
table.insert(levelsLDTK, {
  identifier = "Room_4",
  uniqueIdentifer = "e0227920-96d0-11f1-ad82-1da941d0a645",
  neighbourLevels = {
    {
      levelIid = "bfb67140-96d0-11f1-ad82-3f89976fa342",
      dir = "w"
    },
    {
      levelIid = "c2a74570-96d0-11f1-ad82-97f41ea8aab4",
      dir = "e"
    },
    {
      levelIid = "f02f6040-96d0-11f1-ad82-e3a055f1db21",
      dir = "se"
    },
    {
      levelIid = "e361a2b0-96d0-11f1-ad82-d786a9f051e2",
      dir = "ne"
    },
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "nw"
    },
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 4,
    tile = 4,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Ghost = {
      {
        id = "Ghost",
        iid = "79d71880-96d0-11f1-ad82-df1e49c85d60",
        x = 292,
        y = 180,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "e022792f-96d0-11f1-ad82-6f6327058eab",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227930-96d0-11f1-ad82-e56d7bf2cccb",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227931-96d0-11f1-ad82-c7cea2a6ccf8",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227932-96d0-11f1-ad82-f59826f992c1",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227934-96d0-11f1-ad82-f5d0c329c357",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227935-96d0-11f1-ad82-4b91caec99f8",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227936-96d0-11f1-ad82-cd9da1036bf3",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227937-96d0-11f1-ad82-270e11cca35c",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e0227938-96d0-11f1-ad82-87469424476a",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e022793a-96d0-11f1-ad82-e9a8dbe22585",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--5
table.insert(levelsLDTK, {
  identifier = "Room_5",
  uniqueIdentifer = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
  neighbourLevels = {
    {
      levelIid = "bfb67140-96d0-11f1-ad82-3f89976fa342",
      dir = "s"
    },
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "se"
    },
    {
      levelIid = "3749f990-96d0-11f1-ad82-37b089cf31e4",
      dir = "n"
    },
    {
      levelIid = "d6f65070-96d0-11f1-ad82-fd242e02b2f1",
      dir = "ne"
    },
    {
      levelIid = "c94585e0-96d0-11f1-ad82-8dd23b4e8a68",
      dir = "nw"
    },
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 5,
    tile = 5,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Ghost = {
      {
        id = "Ghost",
        iid = "7b2d0b90-96d0-11f1-ad82-09097eba62c0",
        x = 356,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "36aeb157-96d0-11f1-ad82-25383a516ae3",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aeb158-96d0-11f1-ad82-f118b31d0d6e",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aeb159-96d0-11f1-ad82-055300908783",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aeb15a-96d0-11f1-ad82-b30b5a92c175",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aeb15b-96d0-11f1-ad82-59776acf02bb",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed860-96d0-11f1-ad82-df4c532c4cf9",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed861-96d0-11f1-ad82-5937e2661809",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed862-96d0-11f1-ad82-2f5f1be0e5dc",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed863-96d0-11f1-ad82-112d4f428e40",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed864-96d0-11f1-ad82-4bee62ee6c72",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed865-96d0-11f1-ad82-79a386c6362e",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "36aed866-96d0-11f1-ad82-b7aa68357d64",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--6
table.insert(levelsLDTK, {
  identifier = "Room_6",
  uniqueIdentifer = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
  neighbourLevels = {
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "e"
    },
    {
      levelIid = "a82c8680-48b0-11f1-9f4d-49a4be703c65",
      dir = "ne"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 6,
    tile = 6,
    DoorsConnection = {
      "Top",
      "Down",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "Final",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    NPC = {
      {
        id = "NPC",
        iid = "32432300-48b0-11f1-8344-ebd86adccf0e",
        x = 60,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          type = "cat",
          conditionalScripts = {},
          sourceFeed = 0,
          hasGranted = false,
          forceSpawn = true,
          triggerScene = "Cockpit"
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "1a8bacb0-48b0-11f1-98a2-2561eede9954",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "f581b2c0-48b0-11f1-9b23-75e99064c294",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ff2b4cf0-48b0-11f1-9b23-4b2aea2d7b16",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--7
table.insert(levelsLDTK, {
  identifier = "Room_7",
  uniqueIdentifer = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
  neighbourLevels = {
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "n"
    },
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "ne"
    },
    {
      levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "e"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = "intro",
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 7,
    tile = 7,
    DoorsConnection = {
      "Top"
    },
    play = "Enter",
    procGen = true,
    roomRole = "Start",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Triggers = {
      {
        id = "Triggers",
        iid = "c7870a30-ac70-11f0-998c-2944db77c3b4",
        x = 204,
        y = 132,
        width = 88,
        height = 40,
        customFields = {
          script = "wakeup",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {
            nil
          },
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "04397810-ac70-11f0-ae64-891aa0cc0d18",
        x = 92,
        y = 108,
        width = 48,
        height = 40,
        customFields = {
          script = "justBoxes",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "05b2a150-21a0-11f1-8318-ef983af2b1a2",
        x = 292,
        y = 140,
        width = 40,
        height = 40,
        customFields = {
          script = "justBoxes",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      }
    },
    Box = {
      {
        id = "Box",
        iid = "f1bb3db0-21a0-11f1-8318-8978489998a1",
        x = 92,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "f354f080-21a0-11f1-8318-792ececf426d",
        x = 292,
        y = 140,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "ad890930-ac70-11f0-8539-b927b406cff9",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "5d2b7f20-48b0-11f1-98a2-150987991932",
        x = 376,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "60540f50-48b0-11f1-98a2-ad97249578aa",
        x = 72,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--8
table.insert(levelsLDTK, {
  identifier = "Room_8",
  uniqueIdentifer = "d8b90440-ac70-11f0-997a-77d867841568",
  neighbourLevels = {
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "nw"
    },
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "n"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "w"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "s"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "e"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = "pick-the-device",
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 8,
    tile = 8,
    DoorsConnection = {
      "Top",
      "Down",
      "Right"
    },
    play = "Cutscene",
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Triggers = {
      {
        id = "Triggers",
        iid = "1966a940-fa90-11f0-bb17-4bab457c7082",
        x = 214,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          script = "pick-the-device",
          usedTrigger = false,
          type = "Cutscene",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "fc22d7e0-6fc0-11f1-a708-0f64cf814c0c",
        x = 348,
        y = 84,
        width = 32,
        height = 32,
        customFields = {
          script = "flashCrewMember",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      }
    },
    Radio = {
      {
        id = "Radio",
        iid = "d912a690-48b0-11f1-b67e-b3bd8fef5a8f",
        x = 214,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          type = "radio",
          isItem = true
        }
      }
    },
    Notes = {
      {
        id = "Notes",
        iid = "f8714190-6fc0-11f1-a708-5de4593edd8d",
        x = 348,
        y = 84,
        width = 32,
        height = 32,
        customFields = {
          type = "notes",
          grants = "canDance:true",
          isItem = true,
          SpawnConditions = {}
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "07b70f50-ac70-11f0-8539-35ff95bfdbdf",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c5a75a30-ac70-11f0-8539-6130c4fb1bfd",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c25a9ea0-d380-11f0-a276-5f29b940eae6",
        x = 344,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3bc2f830-fa90-11f0-9f0d-dd4b46089fc2",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "da7eecd0-48b0-11f1-89a8-cfa129ae6a84",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "43d61a00-48b0-11f1-a37f-6d7f7ddf4a15",
        x = 88,
        y = 234,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "88dd5c90-6fc0-11f1-8c51-113a2bb0ae04",
        x = 396,
        y = 40,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--9
table.insert(levelsLDTK, {
  identifier = "Room_9",
  uniqueIdentifer = "af4d7e50-6fc0-11f1-989d-8151041b4734",
  neighbourLevels = {
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "e"
    },
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "n"
    },
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "w"
    },
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "s"
    }
  },
  customFields = {
    shadow = false,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 9,
    tile = 9,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "StartUp",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    TubeExit = {
      {
        id = "TubeExit",
        iid = "e602f690-6fc0-11f1-90a3-07815a3b0243",
        x = 324,
        y = 180,
        width = 32,
        height = 32,
        customFields = {
          type = "TubeExit",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "8186e0b0-96d0-11f1-ad82-95d83dc2697b",
        x = 132,
        y = 68,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      }
    },
    Box = {
      {
        id = "Box",
        iid = "888f4320-96d0-11f1-ad82-91b5864e3056",
        x = 28,
        y = 204,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "8a7e9000-96d0-11f1-ad82-233ceb06860d",
        x = 84,
        y = 28,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "8cc9df90-96d0-11f1-ad82-c5bca26de414",
        x = 372,
        y = 52,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "8d8e4100-96d0-11f1-ad82-cf32821d1aea",
        x = 332,
        y = 28,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "8ef9b7e0-96d0-11f1-ad82-89096913903b",
        x = 84,
        y = 212,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "af4da560-6fc0-11f1-989d-cdee7b47a7a1",
        x = 68,
        y = 100,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "af4da564-6fc0-11f1-989d-9b10dae8155e",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "af4da565-6fc0-11f1-989d-e569b633a73f",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "af4da566-6fc0-11f1-989d-0f8a38709c36",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "af4da567-6fc0-11f1-989d-a14e745f4ad6",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "63376b20-96d0-11f1-8259-9d5a7be014a5",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "78018810-96d0-11f1-8259-71280a48a613",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "79caaf50-96d0-11f1-8259-2571c33c5ddd",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7beec7d0-96d0-11f1-8259-67ee15f9de54",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7dfd5c80-96d0-11f1-8259-2703138c14b8",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "801d5650-96d0-11f1-8259-99d6a1004336",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85a75620-96d0-11f1-8259-d192e98f0088",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "88296d20-96d0-11f1-8259-9dd3d6395e74",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--10
table.insert(levelsLDTK, {
  identifier = "Room_10",
  uniqueIdentifer = "326d5080-48b0-11f1-a37f-1b74e05a8681",
  neighbourLevels = {
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "n"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "ne"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 10,
    tile = 10,
    DoorsConnection = {
      "Top",
      "Down",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Triggers = {
      {
        id = "Triggers",
        iid = "a08811a0-6fc0-11f1-a708-f7aab4cf528d",
        x = 108,
        y = 200,
        width = 32,
        height = 32,
        customFields = {
          script = "minifier",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "fb5d1a40-6fc0-11f1-a708-c33a306889c2",
        x = 132,
        y = 24,
        width = 16,
        height = 16,
        customFields = {
          script = "TinySpaces",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "e47dfc70-6fc0-11f1-a708-57ea21846123",
        x = 36,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      }
    },
    Notes = {
      {
        id = "Notes",
        iid = "f2684690-6fc0-11f1-a708-e1d6abd78072",
        x = 108,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "notes",
          grants = "canDance:true",
          isItem = true,
          SpawnConditions = {}
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "9cf2e5a0-6fc0-11f1-8c51-43df57f56df0",
        x = 276,
        y = 108,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = true
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "326d5092-48b0-11f1-a37f-056bd4dafd81",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "326d5094-48b0-11f1-a37f-1587cb0c57d1",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "326d5095-48b0-11f1-a37f-d3b770885b24",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--11
table.insert(levelsLDTK, {
  identifier = "Room_11",
  uniqueIdentifer = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
  neighbourLevels = {
    {
      levelIid = "af4d7e50-6fc0-11f1-989d-8151041b4734",
      dir = "w"
    },
    {
      levelIid = "c3452bc0-96d0-11f1-ad82-7d92ff7c3566",
      dir = "e"
    },
    {
      levelIid = "8bf06710-96d0-11f1-ad82-bdd18e131dc9",
      dir = "se"
    },
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "nw"
    },
    {
      levelIid = "ce5ca500-96d0-11f1-ad82-8920f4b02239",
      dir = "ne"
    },
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "sw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 11,
    tile = 11,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "d995fd73-96d0-11f1-ad82-eb02c23052c6",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd74-96d0-11f1-ad82-d7f941538ec4",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd75-96d0-11f1-ad82-757e8ce76fde",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd76-96d0-11f1-ad82-3d87707acd27",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd77-96d0-11f1-ad82-177006d78933",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd78-96d0-11f1-ad82-3bb0a5226be6",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd79-96d0-11f1-ad82-fda36d1c5f7a",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd7a-96d0-11f1-ad82-e1525b0754cb",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd7b-96d0-11f1-ad82-9d652ee30c4c",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd7c-96d0-11f1-ad82-a1d4e5ae15dd",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd7d-96d0-11f1-ad82-1513101ce4ea",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d995fd7e-96d0-11f1-ad82-71b3833d8699",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--12
table.insert(levelsLDTK, {
  identifier = "Room_12",
  uniqueIdentifer = "197eebe0-96d0-11f1-ad82-255366b1b178",
  neighbourLevels = {
    {
      levelIid = "af4d7e50-6fc0-11f1-989d-8151041b4734",
      dir = "s"
    },
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "se"
    },
    {
      levelIid = "b5c92cd0-96d0-11f1-ad82-25889d3e8df8",
      dir = "n"
    },
    {
      levelIid = "9ecf2ec0-96d0-11f1-ad82-bdebf0f90720",
      dir = "nw"
    },
    {
      levelIid = "96c561e0-96d0-11f1-ad82-ad17bbc84496",
      dir = "ne"
    },
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "sw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 12,
    tile = 12,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "197f12f6-96d0-11f1-ad82-2b661d32abf9",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12f7-96d0-11f1-ad82-2b4192a07f5c",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12f8-96d0-11f1-ad82-91e2206868c5",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12f9-96d0-11f1-ad82-b14f518e7493",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12fa-96d0-11f1-ad82-dd47967480f9",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12fb-96d0-11f1-ad82-f500a883fc8e",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12fc-96d0-11f1-ad82-07d97c9f434f",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12fd-96d0-11f1-ad82-a1ae0e7ecf9d",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12fe-96d0-11f1-ad82-15e7ff80ee6d",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f12ff-96d0-11f1-ad82-9f0346ec4860",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f1300-96d0-11f1-ad82-e1824768b50b",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "197f1301-96d0-11f1-ad82-df353b0e395e",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--13
table.insert(levelsLDTK, {
  identifier = "Room_13",
  uniqueIdentifer = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
  neighbourLevels = {
    {
      levelIid = "af4d7e50-6fc0-11f1-989d-8151041b4734",
      dir = "e"
    },
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "ne"
    },
    {
      levelIid = "a82bba60-96d0-11f1-ad82-b70855d72905",
      dir = "nw"
    },
    {
      levelIid = "b6e23520-96d0-11f1-ad82-c73ecd08d0da",
      dir = "sw"
    },
    {
      levelIid = "4845d070-96d0-11f1-ad82-217644174562",
      dir = "w"
    },
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 13,
    tile = 13,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "2125b137-96d0-11f1-ad82-2b3726eb3095",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125b138-96d0-11f1-ad82-558281f00377",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d840-96d0-11f1-ad82-871737f6c465",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d841-96d0-11f1-ad82-c950b58edefd",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d842-96d0-11f1-ad82-831b3378465c",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d843-96d0-11f1-ad82-0100cf9bf128",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d844-96d0-11f1-ad82-55569cd6fd72",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d845-96d0-11f1-ad82-d52ad974a8c9",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d846-96d0-11f1-ad82-bd4114670382",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d847-96d0-11f1-ad82-270bed8ca20e",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d848-96d0-11f1-ad82-a120deb0732d",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2125d849-96d0-11f1-ad82-a51ea77185a4",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--14
table.insert(levelsLDTK, {
  identifier = "Room_14",
  uniqueIdentifer = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
  neighbourLevels = {
    {
      levelIid = "af4d7e50-6fc0-11f1-989d-8151041b4734",
      dir = "n"
    },
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "ne"
    },
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "nw"
    },
    {
      levelIid = "bbc5eba0-96d0-11f1-ad82-f58bb6f3d06a",
      dir = "s"
    },
    {
      levelIid = "85150810-96d0-11f1-ad82-01cd0a6eb18e",
      dir = "se"
    },
    {
      levelIid = "7e8000e0-96d0-11f1-ad82-f369c7cf3df8",
      dir = "sw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 14,
    tile = 14,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "2a2ace07-96d0-11f1-ad82-b79b9fea4d92",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace08-96d0-11f1-ad82-8b2df0c1025b",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace09-96d0-11f1-ad82-77d98fc04026",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0a-96d0-11f1-ad82-3575842192a5",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0b-96d0-11f1-ad82-3d60847c675a",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0c-96d0-11f1-ad82-cda463e8d518",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0d-96d0-11f1-ad82-6f11300a5942",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0e-96d0-11f1-ad82-ef3f1091df5e",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace0f-96d0-11f1-ad82-df1ae5d8f2e1",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace10-96d0-11f1-ad82-abe133adb813",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace11-96d0-11f1-ad82-c503c5266b73",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "2a2ace12-96d0-11f1-ad82-337902ed867b",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--15
table.insert(levelsLDTK, {
  identifier = "Room_15",
  uniqueIdentifer = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
  neighbourLevels = {
    {
      levelIid = "bfb67140-96d0-11f1-ad82-3f89976fa342",
      dir = "e"
    },
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "ne"
    },
    {
      levelIid = "206f7330-96d0-11f1-ad82-275c2a8b39b9",
      dir = "w"
    },
    {
      levelIid = "6f779590-96d0-11f1-ad82-e9ac94736365",
      dir = "nw"
    },
    {
      levelIid = "75f4cf00-96d0-11f1-ad82-092e0aa551b5",
      dir = "sw"
    },
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "se"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 15,
    tile = 15,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Ghost = {
      {
        id = "Ghost",
        iid = "7c4b73e0-96d0-11f1-ad82-63e385463f0c",
        x = 108,
        y = 52,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "39589ba7-96d0-11f1-ad82-0b2a1b27fbcc",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589ba8-96d0-11f1-ad82-57c698234847",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589ba9-96d0-11f1-ad82-cbf2556beb44",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589baa-96d0-11f1-ad82-7913776a49ca",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bab-96d0-11f1-ad82-1f7af1122b9b",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bac-96d0-11f1-ad82-53a8f2d242ef",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bad-96d0-11f1-ad82-b7ec61be4591",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bae-96d0-11f1-ad82-8d3ce86a7f10",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589baf-96d0-11f1-ad82-d1362252bb49",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bb0-96d0-11f1-ad82-ed5937026657",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bb1-96d0-11f1-ad82-4d45ffa2a093",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "39589bb2-96d0-11f1-ad82-c56b6fa917f9",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--16
table.insert(levelsLDTK, {
  identifier = "Room_16",
  uniqueIdentifer = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
  neighbourLevels = {
    {
      levelIid = "bfb67140-96d0-11f1-ad82-3f89976fa342",
      dir = "n"
    },
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "ne"
    },
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "nw"
    },
    {
      levelIid = "fa27f350-96d0-11f1-ad82-f52ab256a7ef",
      dir = "s"
    },
    {
      levelIid = "02e961e0-96d0-11f1-ad82-d9257f2f4abf",
      dir = "se"
    },
    {
      levelIid = "d8aba2a0-96d0-11f1-ad82-27bb13a10c31",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 16,
    tile = 16,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Ghost = {
      {
        id = "Ghost",
        iid = "78fc9700-96d0-11f1-ad82-e32633301f32",
        x = 68,
        y = 60,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "3d0f8927-96d0-11f1-ad82-418cc260eba9",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f8928-96d0-11f1-ad82-db165dff6357",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f8929-96d0-11f1-ad82-754ae5851c20",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892a-96d0-11f1-ad82-6d4a28929caa",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892b-96d0-11f1-ad82-15765fc8b1c8",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892c-96d0-11f1-ad82-01266478c151",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892d-96d0-11f1-ad82-27ba8bc2e540",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892e-96d0-11f1-ad82-530923ef14ad",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f892f-96d0-11f1-ad82-7de78f8db2b5",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0f8930-96d0-11f1-ad82-fb89c5b5ce0a",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0fb030-96d0-11f1-ad82-8f16af6c40d9",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3d0fb031-96d0-11f1-ad82-878a83cf2355",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--17
table.insert(levelsLDTK, {
  identifier = "Room_17",
  uniqueIdentifer = "c2a74570-96d0-11f1-ad82-97f41ea8aab4",
  neighbourLevels = {
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "w"
    },
    {
      levelIid = "f02f6040-96d0-11f1-ad82-e3a055f1db21",
      dir = "s"
    },
    {
      levelIid = "e361a2b0-96d0-11f1-ad82-d786a9f051e2",
      dir = "n"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 17,
    tile = 17,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "617a10d0-96d0-11f1-ad82-e1dc40523c5d",
        x = 52,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "66ef5020-96d0-11f1-ad82-1d719df90f17",
        x = 324,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "884cb9b0-96d0-11f1-ad82-071f667a503f",
        x = 308,
        y = 60,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "c2a74577-96d0-11f1-ad82-f1ebf923089b",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c2a74578-96d0-11f1-ad82-af2215eef117",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c2a7457a-96d0-11f1-ad82-bd598cac6d65",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c2a7457e-96d0-11f1-ad82-cfe055b96e5c",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--18
table.insert(levelsLDTK, {
  identifier = "Room_18",
  uniqueIdentifer = "fa27f350-96d0-11f1-ad82-f52ab256a7ef",
  neighbourLevels = {
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "n"
    },
    {
      levelIid = "02e961e0-96d0-11f1-ad82-d9257f2f4abf",
      dir = "e"
    },
    {
      levelIid = "d8aba2a0-96d0-11f1-ad82-27bb13a10c31",
      dir = "w"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 18,
    tile = 18,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "55f12f50-96d0-11f1-ad82-9701edc4310b",
        x = 324,
        y = 60,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Brocorat = {
      {
        id = "Brocorat",
        iid = "56cc2600-96d0-11f1-ad82-9b8ea8040506",
        x = 84,
        y = 172,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "851dc0e0-96d0-11f1-ad82-878a2a4c8752",
        x = 332,
        y = 180,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "fa27f357-96d0-11f1-ad82-0d5c194f8ec9",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "fa27f358-96d0-11f1-ad82-21a310d9c930",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "fa27f359-96d0-11f1-ad82-5fa2443e53ca",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "fa27f35a-96d0-11f1-ad82-4307f596f8d4",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "fa27f35e-96d0-11f1-ad82-4996ebab9109",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "fa281a60-96d0-11f1-ad82-258c29ee08c9",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--19
table.insert(levelsLDTK, {
  identifier = "Room_19",
  uniqueIdentifer = "206f7330-96d0-11f1-ad82-275c2a8b39b9",
  neighbourLevels = {
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "e"
    },
    {
      levelIid = "6f779590-96d0-11f1-ad82-e9ac94736365",
      dir = "n"
    },
    {
      levelIid = "75f4cf00-96d0-11f1-ad82-092e0aa551b5",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 19,
    tile = 19,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "5a016060-96d0-11f1-ad82-e717f0638192",
        x = 324,
        y = 164,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "70fa9250-96d0-11f1-ad82-5daca763479a",
        x = 44,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "7fbeefc0-96d0-11f1-ad82-a17967694d4d",
        x = 68,
        y = 188,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "206f9a45-96d0-11f1-ad82-1bfbabe861c6",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "206f9a46-96d0-11f1-ad82-779da5402e87",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "206f9a48-96d0-11f1-ad82-ff0b9b0b07aa",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "206f9a49-96d0-11f1-ad82-5fdc2a4d4b37",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "206f9a4c-96d0-11f1-ad82-73c52c9bd129",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "206f9a4f-96d0-11f1-ad82-9de360d59986",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--20
table.insert(levelsLDTK, {
  identifier = "Room_20",
  uniqueIdentifer = "bd739520-6fc0-11f1-b67a-b3124c589208",
  neighbourLevels = {},
  customFields = {
    shadow = false,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 20,
    tile = 20,
    DoorsConnection = {
      "Top",
      "Right",
      "Left",
      "Down"
    },
    play = nil,
    procGen = false,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Box = {
      {
        id = "Box",
        iid = "392cf760-6fc0-11f1-81c8-079adf67aa66",
        x = 156,
        y = 204,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Box",
        iid = "3a5d3a00-6fc0-11f1-81c8-992bd2cfb4f2",
        x = 156,
        y = 172,
        width = 32,
        height = 32,
        customFields = {
          type = "box",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "401a57c0-6fc0-11f1-81c8-6d07dc2b645b",
        x = 44,
        y = 44,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      },
      {
        id = "Minifier",
        iid = "43a81260-6fc0-11f1-81c8-c9e2321e3370",
        x = 252,
        y = 36,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = false
        }
      }
    },
    Brocorat = {
      {
        id = "Brocorat",
        iid = "30a10230-6fc0-11f1-81c8-6556572588e3",
        x = 308,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "320c7910-6fc0-11f1-81c8-27949d5cf5c8",
        x = 316,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = true
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "334af060-6fc0-11f1-90a3-274ba50284e2",
        x = 196,
        y = 60,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "bd739527-6fc0-11f1-b67a-d13bea61f4ab",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = 1
        }
      },
      {
        id = "Doors",
        iid = "bd739528-6fc0-11f1-b67a-d1836793325f",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "cdbfa400-6fc0-11f1-b67a-1908dbacfbfb",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d95508a0-6fc0-11f1-b67a-fbe217718057",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--21
table.insert(levelsLDTK, {
  identifier = "Room_21",
  uniqueIdentifer = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
  neighbourLevels = {
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "w"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 21,
    tile = 21,
    DoorsConnection = {
      "Top",
      "Left",
      "Down"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    PneumaticTube = {
      {
        id = "PneumaticTube",
        iid = "6bb5e9a0-6fc0-11f1-8c51-27af4cec03f9",
        x = 356,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "pneumaticTube",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Tube = {
      {
        id = "Tube",
        iid = "6f6b7790-6fc0-11f1-8c51-31e79f0e84bd",
        x = 356,
        y = 164,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "718c34b0-6fc0-11f1-8c51-23eb1f76cd70",
        x = 356,
        y = 132,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "722d56b0-6fc0-11f1-8c51-b9d128b8ef51",
        x = 356,
        y = 100,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "72a45b70-6fc0-11f1-8c51-85e5b82e16b9",
        x = 356,
        y = 68,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "735c60d0-6fc0-11f1-8c51-196031bbe7c7",
        x = 356,
        y = 36,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      },
      {
        id = "Tube",
        iid = "74743970-6fc0-11f1-8c51-81939792c0ee",
        x = 356,
        y = 4,
        width = 32,
        height = 32,
        customFields = {
          type = "Tube",
          nocollider = false,
          destroyed = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "17ea8a60-6fc0-11f1-a708-21a3ebcb94e2",
        x = 100,
        y = 108,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "f1f1d876-6fc0-11f1-b67a-f56453e35b9e",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = 1
        }
      },
      {
        id = "Doors",
        iid = "f1f1d877-6fc0-11f1-b67a-69b19dbe1fb4",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "f1f1d878-6fc0-11f1-b67a-7b5c0514feb1",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "949c9050-6fc0-11f1-8c51-0715749fdbc0",
        x = 4,
        y = 40,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--22
table.insert(levelsLDTK, {
  identifier = "Room_22",
  uniqueIdentifer = "3749f990-96d0-11f1-ad82-37b089cf31e4",
  neighbourLevels = {
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "s"
    },
    {
      levelIid = "d6f65070-96d0-11f1-ad82-fd242e02b2f1",
      dir = "e"
    },
    {
      levelIid = "c94585e0-96d0-11f1-ad82-8dd23b4e8a68",
      dir = "w"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 22,
    tile = 22,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "5d688030-96d0-11f1-ad82-495392816c73",
        x = 276,
        y = 76,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "6cd77580-96d0-11f1-ad82-3f6f45620c55",
        x = 116,
        y = 140,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "8b9506e0-96d0-11f1-ad82-c5571363d1cd",
        x = 348,
        y = 164,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "3749f997-96d0-11f1-ad82-896eeaf9d6b1",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f998-96d0-11f1-ad82-4b7fed3b62bb",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f999-96d0-11f1-ad82-f111d2af2049",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99a-96d0-11f1-ad82-b936cc80e990",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99b-96d0-11f1-ad82-0756a067471a",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99c-96d0-11f1-ad82-43179736b208",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99d-96d0-11f1-ad82-1359904df0ee",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99e-96d0-11f1-ad82-7555f0d138ee",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "3749f99f-96d0-11f1-ad82-a759704ae00d",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "374a20a0-96d0-11f1-ad82-793502875ff5",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "374a20a1-96d0-11f1-ad82-21bfbd30b596",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "374a20a2-96d0-11f1-ad82-af5a1e85795d",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--23
table.insert(levelsLDTK, {
  identifier = "Room_23",
  uniqueIdentifer = "4845d070-96d0-11f1-ad82-217644174562",
  neighbourLevels = {
    {
      levelIid = "a82bba60-96d0-11f1-ad82-b70855d72905",
      dir = "n"
    },
    {
      levelIid = "b6e23520-96d0-11f1-ad82-c73ecd08d0da",
      dir = "s"
    },
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "e"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 23,
    tile = 23,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "3604bae0-96d0-11f1-ad82-b16a71924339",
        x = 60,
        y = 180,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "4845d077-96d0-11f1-ad82-d53bb542e860",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4845d078-96d0-11f1-ad82-c5c5fe5c4f92",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4845d07a-96d0-11f1-ad82-db2348f8d6e3",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4845d07b-96d0-11f1-ad82-ed949995a187",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4845d07e-96d0-11f1-ad82-4f32a19619af",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "4845d081-96d0-11f1-ad82-83bc64610e64",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--24
table.insert(levelsLDTK, {
  identifier = "Room_24",
  uniqueIdentifer = "b5c92cd0-96d0-11f1-ad82-25889d3e8df8",
  neighbourLevels = {
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "s"
    },
    {
      levelIid = "9ecf2ec0-96d0-11f1-ad82-bdebf0f90720",
      dir = "w"
    },
    {
      levelIid = "96c561e0-96d0-11f1-ad82-ad17bbc84496",
      dir = "e"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 24,
    tile = 24,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "3aa719d0-96d0-11f1-ad82-1de994561935",
        x = 276,
        y = 188,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "b5c92cd7-96d0-11f1-ad82-c99691a7b5ef",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cd8-96d0-11f1-ad82-05422a88fc34",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cd9-96d0-11f1-ad82-09365a26e535",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cda-96d0-11f1-ad82-cd10715a8fde",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cdb-96d0-11f1-ad82-01cce72ef559",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cdc-96d0-11f1-ad82-a7b16a416f03",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cdd-96d0-11f1-ad82-1d11f61d76e7",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cde-96d0-11f1-ad82-5b2cf9c4be80",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92cdf-96d0-11f1-ad82-db24af60bf7d",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92ce0-96d0-11f1-ad82-7fdbd2c98b14",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92ce1-96d0-11f1-ad82-bb7ed1e83e88",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b5c92ce2-96d0-11f1-ad82-71dd144e826f",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--25
table.insert(levelsLDTK, {
  identifier = "Room_25",
  uniqueIdentifer = "bbc5eba0-96d0-11f1-ad82-f58bb6f3d06a",
  neighbourLevels = {
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "n"
    },
    {
      levelIid = "85150810-96d0-11f1-ad82-01cd0a6eb18e",
      dir = "e"
    },
    {
      levelIid = "7e8000e0-96d0-11f1-ad82-f369c7cf3df8",
      dir = "w"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 25,
    tile = 25,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "2ef0e6c0-96d0-11f1-ad82-476fd3e756d2",
        x = 332,
        y = 52,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "bbc5eba7-96d0-11f1-ad82-9fdfa42e1439",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bbc5eba8-96d0-11f1-ad82-79bafbd70777",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bbc5eba9-96d0-11f1-ad82-4b239586f0dc",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bbc5ebaa-96d0-11f1-ad82-fb66411a48f3",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bbc5ebae-96d0-11f1-ad82-df0fe3e1d89f",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "bbc612b2-96d0-11f1-ad82-43055120bb0f",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--26
table.insert(levelsLDTK, {
  identifier = "Room_26",
  uniqueIdentifer = "c3452bc0-96d0-11f1-ad82-7d92ff7c3566",
  neighbourLevels = {
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "w"
    },
    {
      levelIid = "8bf06710-96d0-11f1-ad82-bdd18e131dc9",
      dir = "s"
    },
    {
      levelIid = "ce5ca500-96d0-11f1-ad82-8920f4b02239",
      dir = "n"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 26,
    tile = 26,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "26739790-96d0-11f1-ad82-33f12521a59f",
        x = 124,
        y = 60,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "c3452bc7-96d0-11f1-ad82-31667284fb2f",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c3452bc8-96d0-11f1-ad82-5be06b9f548b",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c3452bca-96d0-11f1-ad82-cd18f4fa4284",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c3452bce-96d0-11f1-ad82-93c2eb11cafb",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c3452bcf-96d0-11f1-ad82-7516124140f1",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c3452bd0-96d0-11f1-ad82-4bd578615585",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--27
table.insert(levelsLDTK, {
  identifier = "Room_27",
  uniqueIdentifer = "c94585e0-96d0-11f1-ad82-8dd23b4e8a68",
  neighbourLevels = {
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "se"
    },
    {
      levelIid = "3749f990-96d0-11f1-ad82-37b089cf31e4",
      dir = "e"
    },
    {
      levelIid = "6f779590-96d0-11f1-ad82-e9ac94736365",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 27,
    tile = 27,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "5c7594b0-96d0-11f1-ad82-d35a36573cd1",
        x = 324,
        y = 180,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "6e235670-96d0-11f1-ad82-8bf460266437",
        x = 60,
        y = 52,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "8ce5f0e0-96d0-11f1-ad82-8913e5ccc7ca",
        x = 300,
        y = 68,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "c94585e7-96d0-11f1-ad82-f7a6ae30277e",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c94585e8-96d0-11f1-ad82-b39c3829e5fa",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c94585e9-96d0-11f1-ad82-5fd8717b94e2",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c94585ea-96d0-11f1-ad82-c33987bb35a7",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c94585eb-96d0-11f1-ad82-77e65fd10f03",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf0-96d0-11f1-ad82-fb53a3f0157a",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf1-96d0-11f1-ad82-9fa3a1ab00ba",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf2-96d0-11f1-ad82-bbe060860315",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf3-96d0-11f1-ad82-0b9f51edfa6f",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf4-96d0-11f1-ad82-7b992851047f",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf5-96d0-11f1-ad82-59425d37ee1d",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "c945acf6-96d0-11f1-ad82-ebfbcc8203fd",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--28
table.insert(levelsLDTK, {
  identifier = "Room_28",
  uniqueIdentifer = "d6f65070-96d0-11f1-ad82-fd242e02b2f1",
  neighbourLevels = {
    {
      levelIid = "e361a2b0-96d0-11f1-ad82-d786a9f051e2",
      dir = "se"
    },
    {
      levelIid = "36aeb150-96d0-11f1-ad82-b10fc3715a0d",
      dir = "sw"
    },
    {
      levelIid = "3749f990-96d0-11f1-ad82-37b089cf31e4",
      dir = "w"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 28,
    tile = 28,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "5ed1ad20-96d0-11f1-ad82-876bd97c0d8e",
        x = 124,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "6aaf8c70-96d0-11f1-ad82-b9227b7dce61",
        x = 348,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "8a8f2fa0-96d0-11f1-ad82-c55e275155c1",
        x = 52,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "d6f65077-96d0-11f1-ad82-abb03e8aed69",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f65078-96d0-11f1-ad82-ed788ecb06e0",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f65079-96d0-11f1-ad82-3d1593006dc6",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507a-96d0-11f1-ad82-f5d9bc96ee3b",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507b-96d0-11f1-ad82-1b3a4b10ca72",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507c-96d0-11f1-ad82-578199d4dc6a",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507d-96d0-11f1-ad82-3f0c8d1f9cba",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507e-96d0-11f1-ad82-7789ef4c3ed1",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f6507f-96d0-11f1-ad82-776c983e1b94",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f65080-96d0-11f1-ad82-ab7a7698dc22",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f65081-96d0-11f1-ad82-e5e402717ae8",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d6f65082-96d0-11f1-ad82-7d951005c196",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--29
table.insert(levelsLDTK, {
  identifier = "Room_29",
  uniqueIdentifer = "e361a2b0-96d0-11f1-ad82-d786a9f051e2",
  neighbourLevels = {
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "sw"
    },
    {
      levelIid = "c2a74570-96d0-11f1-ad82-97f41ea8aab4",
      dir = "s"
    },
    {
      levelIid = "d6f65070-96d0-11f1-ad82-fd242e02b2f1",
      dir = "nw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 29,
    tile = 29,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "604dc5d0-96d0-11f1-ad82-45b9bdd6cbe0",
        x = 340,
        y = 60,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "6871f880-96d0-11f1-ad82-0fd9b9c028d6",
        x = 44,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "89501ff0-96d0-11f1-ad82-53f4ac02804b",
        x = 308,
        y = 164,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "e361a2b7-96d0-11f1-ad82-e1487188b1d4",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e361a2b8-96d0-11f1-ad82-cf018849963a",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e361a2b9-96d0-11f1-ad82-abdc97241b1a",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "e361a2ba-96d0-11f1-ad82-73647090bd79",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--30
table.insert(levelsLDTK, {
  identifier = "Room_30",
  uniqueIdentifer = "f02f6040-96d0-11f1-ad82-e3a055f1db21",
  neighbourLevels = {
    {
      levelIid = "e0227920-96d0-11f1-ad82-1da941d0a645",
      dir = "nw"
    },
    {
      levelIid = "c2a74570-96d0-11f1-ad82-97f41ea8aab4",
      dir = "n"
    },
    {
      levelIid = "02e961e0-96d0-11f1-ad82-d9257f2f4abf",
      dir = "sw"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 30,
    tile = 30,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "626a3d30-96d0-11f1-ad82-09fbb84993d4",
        x = 340,
        y = 52,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "65905c60-96d0-11f1-ad82-c3e7b3870758",
        x = 108,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "874b9d60-96d0-11f1-ad82-5b49d5eb956a",
        x = 300,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "f02f6047-96d0-11f1-ad82-6793298c911d",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "f02f6048-96d0-11f1-ad82-b366d49e717a",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "f02f6049-96d0-11f1-ad82-41543854bb12",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "f02f604a-96d0-11f1-ad82-7147b9ec179c",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--31
table.insert(levelsLDTK, {
  identifier = "Room_31",
  uniqueIdentifer = "02e961e0-96d0-11f1-ad82-d9257f2f4abf",
  neighbourLevels = {
    {
      levelIid = "f02f6040-96d0-11f1-ad82-e3a055f1db21",
      dir = "ne"
    },
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "nw"
    },
    {
      levelIid = "fa27f350-96d0-11f1-ad82-f52ab256a7ef",
      dir = "w"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 31,
    tile = 31,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "52fca770-96d0-11f1-ad82-6f4fd74b5bb6",
        x = 116,
        y = 60,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "5422d7f0-96d0-11f1-ad82-9bc81993b782",
        x = 292,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "86304250-96d0-11f1-ad82-616ffb916546",
        x = 348,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "02e961e7-96d0-11f1-ad82-316680478703",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "02e961e8-96d0-11f1-ad82-0d9fc2c545a7",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "02e961e9-96d0-11f1-ad82-f9c4617c0271",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "02e961ea-96d0-11f1-ad82-abc7dfd2bbe6",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "02e961eb-96d0-11f1-ad82-57419a078912",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "02e961ec-96d0-11f1-ad82-9323a7fdc654",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--32
table.insert(levelsLDTK, {
  identifier = "Room_32",
  uniqueIdentifer = "6f779590-96d0-11f1-ad82-e9ac94736365",
  neighbourLevels = {
    {
      levelIid = "c94585e0-96d0-11f1-ad82-8dd23b4e8a68",
      dir = "ne"
    },
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "se"
    },
    {
      levelIid = "206f7330-96d0-11f1-ad82-275c2a8b39b9",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 32,
    tile = 32,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "5b2ebcd0-96d0-11f1-ad82-89fcc260ac74",
        x = 60,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "6f916560-96d0-11f1-ad82-bfbb649e00a4",
        x = 332,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "8e477cb0-96d0-11f1-ad82-6b858c8b9f36",
        x = 68,
        y = 44,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "6f779597-96d0-11f1-ad82-8b5cc0a74d54",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "6f779598-96d0-11f1-ad82-3de99bbbc781",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "6f779599-96d0-11f1-ad82-dbac8df7fb6a",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "6f77959a-96d0-11f1-ad82-1138781bd857",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "6f77959b-96d0-11f1-ad82-8bb25d5ece27",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "6f77959c-96d0-11f1-ad82-e38830d646c2",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--33
table.insert(levelsLDTK, {
  identifier = "Room_33",
  uniqueIdentifer = "75f4cf00-96d0-11f1-ad82-092e0aa551b5",
  neighbourLevels = {
    {
      levelIid = "39589ba0-96d0-11f1-ad82-85b08eec6ff7",
      dir = "ne"
    },
    {
      levelIid = "206f7330-96d0-11f1-ad82-275c2a8b39b9",
      dir = "n"
    },
    {
      levelIid = "d8aba2a0-96d0-11f1-ad82-27bb13a10c31",
      dir = "se"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 33,
    tile = 33,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "58e87650-96d0-11f1-ad82-d1bfa3d53e7c",
        x = 68,
        y = 36,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "72336070-96d0-11f1-ad82-6157d6b2e173",
        x = 332,
        y = 180,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "8226a0f0-96d0-11f1-ad82-ebe7e5065d31",
        x = 84,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "75f4cf07-96d0-11f1-ad82-bf665841e756",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "75f4cf08-96d0-11f1-ad82-bd0f7f4bc3d1",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "75f4cf09-96d0-11f1-ad82-1de2b392f9d6",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "75f4cf0a-96d0-11f1-ad82-ffc93788d424",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "75f4cf0b-96d0-11f1-ad82-2575ac471348",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "75f4cf0c-96d0-11f1-ad82-6dcb752cbccc",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--34
table.insert(levelsLDTK, {
  identifier = "Room_34",
  uniqueIdentifer = "7e8000e0-96d0-11f1-ad82-f369c7cf3df8",
  neighbourLevels = {
    {
      levelIid = "b6e23520-96d0-11f1-ad82-c73ecd08d0da",
      dir = "nw"
    },
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "ne"
    },
    {
      levelIid = "bbc5eba0-96d0-11f1-ad82-f58bb6f3d06a",
      dir = "e"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 34,
    tile = 34,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "31db5c80-96d0-11f1-ad82-9579e98d9616",
        x = 36,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "7e8027f1-96d0-11f1-ad82-57aa3530e1ba",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7e8027f2-96d0-11f1-ad82-f72ab9d46dc8",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7e8027f3-96d0-11f1-ad82-bd83659f5f00",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7e8027f4-96d0-11f1-ad82-69bde8cfd846",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7e8027f5-96d0-11f1-ad82-abc76ef4ef8f",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "7e8027f6-96d0-11f1-ad82-ddef7b775963",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--35
table.insert(levelsLDTK, {
  identifier = "Room_35",
  uniqueIdentifer = "85150810-96d0-11f1-ad82-01cd0a6eb18e",
  neighbourLevels = {
    {
      levelIid = "8bf06710-96d0-11f1-ad82-bdd18e131dc9",
      dir = "ne"
    },
    {
      levelIid = "2a2ace00-96d0-11f1-ad82-f535a8702a37",
      dir = "nw"
    },
    {
      levelIid = "bbc5eba0-96d0-11f1-ad82-f58bb6f3d06a",
      dir = "w"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 35,
    tile = 35,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "2b3f0250-96d0-11f1-ad82-b312103078ca",
        x = 44,
        y = 188,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "85152f21-96d0-11f1-ad82-8f9e4b1ac401",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85152f22-96d0-11f1-ad82-b932302865f4",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85152f23-96d0-11f1-ad82-e9bc230d7df2",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85152f24-96d0-11f1-ad82-bdcca0987893",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85152f25-96d0-11f1-ad82-f95699fa983b",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "85152f26-96d0-11f1-ad82-a12a650169dc",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--36
table.insert(levelsLDTK, {
  identifier = "Room_36",
  uniqueIdentifer = "8bf06710-96d0-11f1-ad82-bdd18e131dc9",
  neighbourLevels = {
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "nw"
    },
    {
      levelIid = "c3452bc0-96d0-11f1-ad82-7d92ff7c3566",
      dir = "n"
    },
    {
      levelIid = "85150810-96d0-11f1-ad82-01cd0a6eb18e",
      dir = "sw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 36,
    tile = 36,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "28eb7560-96d0-11f1-ad82-35932bd46567",
        x = 316,
        y = 172,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "8bf06717-96d0-11f1-ad82-8ba2799aa333",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "8bf06718-96d0-11f1-ad82-b1eedab972ff",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "8bf06719-96d0-11f1-ad82-bf5d9d5785dd",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "8bf0671a-96d0-11f1-ad82-438fd1918466",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "8bf0671b-96d0-11f1-ad82-9de223ad33b6",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "8bf0671c-96d0-11f1-ad82-fffbe186d26a",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      }
    }
  }
})
	--37
table.insert(levelsLDTK, {
  identifier = "Room_37",
  uniqueIdentifer = "96c561e0-96d0-11f1-ad82-ad17bbc84496",
  neighbourLevels = {
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "sw"
    },
    {
      levelIid = "b5c92cd0-96d0-11f1-ad82-25889d3e8df8",
      dir = "w"
    },
    {
      levelIid = "ce5ca500-96d0-11f1-ad82-8920f4b02239",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 37,
    tile = 37,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "3c37f300-96d0-11f1-ad82-67be0a32015a",
        x = 140,
        y = 188,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "96c561e7-96d0-11f1-ad82-9521538098fc",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561e8-96d0-11f1-ad82-bf4f3155d2ac",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561e9-96d0-11f1-ad82-118573d865b4",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561ea-96d0-11f1-ad82-d3dab02d5494",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561eb-96d0-11f1-ad82-e723340ed202",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561ec-96d0-11f1-ad82-e5028f534827",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561ed-96d0-11f1-ad82-1b7bb1e5e046",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561ee-96d0-11f1-ad82-adc9e0cc0c01",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561ef-96d0-11f1-ad82-8582fa53a3a5",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561f0-96d0-11f1-ad82-8594803f4fa7",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561f1-96d0-11f1-ad82-dff7f4f40a5d",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "96c561f2-96d0-11f1-ad82-81bad4e6ec7b",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--38
table.insert(levelsLDTK, {
  identifier = "Room_38",
  uniqueIdentifer = "9ecf2ec0-96d0-11f1-ad82-bdebf0f90720",
  neighbourLevels = {
    {
      levelIid = "197eebe0-96d0-11f1-ad82-255366b1b178",
      dir = "se"
    },
    {
      levelIid = "b5c92cd0-96d0-11f1-ad82-25889d3e8df8",
      dir = "e"
    },
    {
      levelIid = "a82bba60-96d0-11f1-ad82-b70855d72905",
      dir = "sw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 38,
    tile = 38,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "39088500-96d0-11f1-ad82-a974b5bd7578",
        x = 276,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "9ecf2ec7-96d0-11f1-ad82-a5268f9ecfbd",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ec8-96d0-11f1-ad82-938de8a841f8",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ec9-96d0-11f1-ad82-23aed822caf5",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2eca-96d0-11f1-ad82-9167ce952364",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ecb-96d0-11f1-ad82-9548eda90c6e",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ecc-96d0-11f1-ad82-e16d70d91c8c",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ecd-96d0-11f1-ad82-175a9682795c",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ece-96d0-11f1-ad82-b71f83f38cb7",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ecf-96d0-11f1-ad82-9bc301af6f7e",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf2ed0-96d0-11f1-ad82-d157a318bed8",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf55d0-96d0-11f1-ad82-3f0fb014f84b",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "9ecf55d1-96d0-11f1-ad82-a913334b3757",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--39
table.insert(levelsLDTK, {
  identifier = "Room_39",
  uniqueIdentifer = "a82bba60-96d0-11f1-ad82-b70855d72905",
  neighbourLevels = {
    {
      levelIid = "9ecf2ec0-96d0-11f1-ad82-bdebf0f90720",
      dir = "ne"
    },
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "se"
    },
    {
      levelIid = "4845d070-96d0-11f1-ad82-217644174562",
      dir = "s"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 39,
    tile = 39,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "375333e0-96d0-11f1-ad82-47694e9c7188",
        x = 348,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "a82bba67-96d0-11f1-ad82-f1efc4b37f9f",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba68-96d0-11f1-ad82-0bd48dbf8a73",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba69-96d0-11f1-ad82-2d52c9c67212",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6a-96d0-11f1-ad82-c33b3e3a4257",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6b-96d0-11f1-ad82-639c591e7b7c",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6c-96d0-11f1-ad82-ad947d558876",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6d-96d0-11f1-ad82-ff08f2d5c754",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6e-96d0-11f1-ad82-1da8b46be237",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba6f-96d0-11f1-ad82-53d3f69ebd0b",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba70-96d0-11f1-ad82-39dc0489c0ab",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba71-96d0-11f1-ad82-e1a92702dd5e",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "a82bba72-96d0-11f1-ad82-4d21029ef17f",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--40
table.insert(levelsLDTK, {
  identifier = "Room_40",
  uniqueIdentifer = "b6e23520-96d0-11f1-ad82-c73ecd08d0da",
  neighbourLevels = {
    {
      levelIid = "2125b130-96d0-11f1-ad82-81c4cee9fd1a",
      dir = "ne"
    },
    {
      levelIid = "4845d070-96d0-11f1-ad82-217644174562",
      dir = "n"
    },
    {
      levelIid = "7e8000e0-96d0-11f1-ad82-f369c7cf3df8",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 40,
    tile = 40,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "34904350-96d0-11f1-ad82-35b583d43403",
        x = 356,
        y = 188,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "b6e23527-96d0-11f1-ad82-ebc3655c6991",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e23528-96d0-11f1-ad82-9b8ae2b5da85",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e23529-96d0-11f1-ad82-cd8371c577ce",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e2352a-96d0-11f1-ad82-e5059cbb5969",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c30-96d0-11f1-ad82-f59b366a5aee",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c31-96d0-11f1-ad82-f91a6284963b",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c32-96d0-11f1-ad82-2d998f3822e6",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c33-96d0-11f1-ad82-f3db316e7c9c",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c34-96d0-11f1-ad82-c9ff78538e0a",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c35-96d0-11f1-ad82-7d845a7fc2e6",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c36-96d0-11f1-ad82-2b62e4ac7cd4",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "b6e25c37-96d0-11f1-ad82-2bbc6e6fda66",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--41
table.insert(levelsLDTK, {
  identifier = "Room_41",
  uniqueIdentifer = "ce5ca500-96d0-11f1-ad82-8920f4b02239",
  neighbourLevels = {
    {
      levelIid = "d995d660-96d0-11f1-ad82-7bd6ddf00333",
      dir = "sw"
    },
    {
      levelIid = "c3452bc0-96d0-11f1-ad82-7d92ff7c3566",
      dir = "s"
    },
    {
      levelIid = "96c561e0-96d0-11f1-ad82-ad17bbc84496",
      dir = "nw"
    }
  },
  customFields = {
    shadow = false,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 41,
    tile = 41,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "3f86a8d0-96d0-11f1-ad82-77907f6b8892",
        x = 52,
        y = 36,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "ce5ca507-96d0-11f1-ad82-5f38d9834bfb",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca508-96d0-11f1-ad82-db59b26c56c5",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca509-96d0-11f1-ad82-312d2bbbcafe",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50a-96d0-11f1-ad82-bdb51624944c",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50b-96d0-11f1-ad82-87667d4f7ed8",
        x = 396,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50c-96d0-11f1-ad82-9187796aeeb2",
        x = 88,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50d-96d0-11f1-ad82-0d85f2c74681",
        x = 328,
        y = 236,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50e-96d0-11f1-ad82-f994b2ff8bed",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca50f-96d0-11f1-ad82-43811238cd14",
        x = 4,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca510-96d0-11f1-ad82-e76da02dd2f8",
        x = 4,
        y = 56,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca511-96d0-11f1-ad82-afc19bbe0fbc",
        x = 396,
        y = 200,
        width = 8,
        height = 16,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ce5ca512-96d0-11f1-ad82-79fd97040c7b",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--42
table.insert(levelsLDTK, {
  identifier = "Room_42",
  uniqueIdentifer = "d8aba2a0-96d0-11f1-ad82-27bb13a10c31",
  neighbourLevels = {
    {
      levelIid = "75f4cf00-96d0-11f1-ad82-092e0aa551b5",
      dir = "nw"
    },
    {
      levelIid = "3d0f8920-96d0-11f1-ad82-6736b96083c7",
      dir = "ne"
    },
    {
      levelIid = "fa27f350-96d0-11f1-ad82-f52ab256a7ef",
      dir = "e"
    }
  },
  customFields = {
    shadow = true,
    light = 0.1,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 42,
    tile = 42,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Brocorat = {
      {
        id = "Brocorat",
        iid = "57dc5d80-96d0-11f1-ad82-f97e2df09999",
        x = 324,
        y = 188,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    CrewMember = {
      {
        id = "CrewMember",
        iid = "73bff3e0-96d0-11f1-ad82-a9010d3d93e1",
        x = 52,
        y = 180,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Ghost = {
      {
        id = "Ghost",
        iid = "83d7fa70-96d0-11f1-ad82-ff942dab79df",
        x = 324,
        y = 52,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "d8aba2a7-96d0-11f1-ad82-3729539f521e",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d8aba2a8-96d0-11f1-ad82-fdcc0b084ae3",
        x = 200,
        y = 4,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d8aba2a9-96d0-11f1-ad82-e7e20183ec6b",
        x = 88,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d8aba2aa-96d0-11f1-ad82-c1314584334c",
        x = 396,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d8aba2ab-96d0-11f1-ad82-a56205c7a9e4",
        x = 4,
        y = 120,
        width = 8,
        height = 48,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d8aba2ac-96d0-11f1-ad82-ab82e6680c1d",
        x = 328,
        y = 4,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      }
    }
  }
})
	--81
table.insert(levelsLDTK, {
  identifier = "Room_81",
  uniqueIdentifer = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a",
  neighbourLevels = {
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "sw"
    },
    {
      levelIid = "a82c8680-48b0-11f1-9f4d-49a4be703c65",
      dir = "w"
    },
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "s"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 81,
    tile = 81,
    DoorsConnection = {
      "Down"
    },
    play = nil,
    procGen = false,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    PortalDoors = {
      {
        id = "PortalDoors",
        iid = "6ac094f0-48b0-11f1-b2c1-99bd8a09616d",
        x = 200,
        y = 216,
        width = 112,
        height = 16,
        customFields = {
          PortalID = 1,
          SpawnX = 161,
          SpawnY = 128,
          Conditions = {},
          BlockedDialog = nil,
          DestRoom = "Room_3"
        }
      }
    }
  }
})
