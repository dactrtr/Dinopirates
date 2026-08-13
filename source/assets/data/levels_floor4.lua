	--1
table.insert(levelsLDTK, {
  identifier = "Room_1",
  uniqueIdentifer = "69eb2d80-ac70-11f0-989f-95306126bd74",
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
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "s"
    },
    {
      levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
      dir = "sw"
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
    roomNumber = 1,
    tile = 1,
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
    Doors = {
      {
        id = "Doors",
        iid = "e415f5e0-6fc0-11f1-b96e-e7f4eec831c8",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
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
      levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
      dir = "w"
    },
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
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "sw"
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
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
      dir = "e"
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
      levelIid = "bd739520-6fc0-11f1-b67a-b3124c589208",
      dir = "ne"
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
  uniqueIdentifer = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
  neighbourLevels = {
    {
      levelIid = "5d9233e0-6fc0-11f1-b67a-e55e4363b0b6",
      dir = "sw"
    },
    {
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "nw"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "n"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "ne"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "e"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
      dir = "w"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = "se"
    },
    {
      levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
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
    roomNumber = 4,
    tile = 4,
    DoorsConnection = {
      "Right",
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
    Minifier = {
      {
        id = "Minifier",
        iid = "2925e110-48b0-11f1-8344-6fb57014178b",
        x = 332,
        y = 204,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = true
        }
      },
      {
        id = "Minifier",
        iid = "324d52f0-48b0-11f1-8344-29cd947bea73",
        x = 348,
        y = 44,
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
    Food = {
      {
        id = "Food",
        iid = "2eaba5b0-48b0-11f1-8344-1b3639a78649",
        x = 284,
        y = 36,
        width = 32,
        height = 32,
        customFields = {
          type = "food",
          grants = "hasitemname:bool",
          isItem = true
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "e6a14d50-48b0-11f1-98a2-35c152986596",
        x = 336,
        y = 236,
        width = 32,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "098a69e0-48b0-11f1-98a2-47f423465842",
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
	--5
table.insert(levelsLDTK, {
  identifier = "Room_5",
  uniqueIdentifer = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
  neighbourLevels = {
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "w"
    },
    {
      levelIid = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "sw"
    },
    {
      levelIid = "bd739520-6fc0-11f1-b67a-b3124c589208",
      dir = "n"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 5,
    tile = 5,
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
    Doors = {
      {
        id = "Doors",
        iid = "cdde3ac0-48b0-11f1-98a2-1be89f9f9a01",
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
        iid = "fff65380-48b0-11f1-98a2-8d2e177562cb",
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
	--6
table.insert(levelsLDTK, {
  identifier = "Room_6",
  uniqueIdentifer = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
  neighbourLevels = {
    {
      levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
      dir = "ne"
    },
    {
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "e"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
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
      levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
      dir = "nw"
    },
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "n"
    },
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "ne"
    },
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "s"
    },
    {
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "w"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "e"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "se"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
      dir = "sw"
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
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "sw"
    },
    {
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
      dir = "ne"
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
      levelIid = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
      dir = "se"
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
  uniqueIdentifer = "dab87dc0-ac70-11f0-997a-63497867517d",
  neighbourLevels = {
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "e"
    },
    {
      levelIid = "5d9233e0-6fc0-11f1-b67a-e55e4363b0b6",
      dir = "s"
    },
    {
      levelIid = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
      dir = "n"
    },
    {
      levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
      dir = "nw"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "ne"
    },
    {
      levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
      dir = "se"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 9,
    tile = 9,
    DoorsConnection = {
      "Top",
      "Down",
      "Left"
    },
    play = nil,
    procGen = false,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    CrewMember = {
      {
        id = "CrewMember",
        iid = "0c11a640-fa90-11f0-9f0d-c9ca42f46487",
        x = 36,
        y = 28,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "CM001",
          forceSpawn = false
        }
      }
    },
    Brocorat = {
      {
        id = "Brocorat",
        iid = "0531c050-21a0-11f1-ba67-436fa97866a9",
        x = 36,
        y = 204,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "f1da76b0-fa90-11f0-9039-7f762bb19d4f",
        x = 200,
        y = 235,
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
        iid = "d524fbd0-48b0-11f1-98a2-bdd7901b9007",
        x = 336,
        y = 4,
        width = 32,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Top",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "ffb48f40-6fc0-11f1-b67a-432da539a34b",
        x = 200,
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
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "w"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "n"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = "s"
    },
    {
      levelIid = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
      dir = "e"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "ne"
    },
    {
      levelIid = "723b72d0-6fc0-11f1-b67a-9309958fabf9",
      dir = "se"
    },
    {
      levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
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
          script = nil,
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
  uniqueIdentifer = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
  neighbourLevels = {
    {
      levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
      dir = "n"
    },
    {
      levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.2,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 11,
    tile = 11,
    DoorsConnection = {
      "Top",
      "Right",
      "Left"
    },
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
        iid = "282768a0-48b0-11f1-98a2-1d4cd08822d8",
        x = 84,
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
        iid = "da4e0e90-48b0-11f1-98a2-fb3afdfe837c",
        x = 396,
        y = 72,
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
        iid = "f772d780-48b0-11f1-98a2-759e83c74acb",
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
        iid = "2d9b60a0-48b0-11f1-a37f-4d6bace5ffe1",
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
	--12
table.insert(levelsLDTK, {
  identifier = "Room_12",
  uniqueIdentifer = "6cc9d510-ac70-11f0-997a-191299f9209c",
  neighbourLevels = {
    {
      levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
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
    roomNumber = 12,
    tile = 12,
    DoorsConnection = {
      "Left",
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
        iid = "91a372e0-21a0-11f1-9039-ffb9ad47dba6",
        x = 360,
        y = 60,
        width = 48,
        height = 16,
        customFields = {
          script = "tinyfier",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
          SpawnConditions = {}
        }
      },
      {
        id = "Triggers",
        iid = "e5975f10-21a0-11f1-9039-77e3f5c70270",
        x = 340,
        y = 140,
        width = 8,
        height = 40,
        customFields = {
          script = "smallSpaces",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {
            "isTiny:smallSpacesTiny"
          },
          SpawnConditions = {}
        }
      }
    },
    Minifier = {
      {
        id = "Minifier",
        iid = "cef907d0-fa90-11f0-8164-09f23df37bd8",
        x = 356,
        y = 28,
        width = 32,
        height = 32,
        customFields = {
          type = "minifier",
          nocollider = false,
          destroyed = false,
          forceSpawn = true
        }
      },
      {
        id = "Minifier",
        iid = "71aef380-48b0-11f1-8344-bbb0d3bb79bd",
        x = 44,
        y = 36,
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
    CrewMember = {
      {
        id = "CrewMember",
        iid = "4aab4ea0-48b0-11f1-98a2-8fbefa5863ad",
        x = 76,
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
        iid = "c6e3d930-ac70-11f0-8539-e78eb22c7faf",
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
        iid = "e1fe70d0-48b0-11f1-98a2-f11c7095cde6",
        x = 4,
        y = 72,
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
	--13
table.insert(levelsLDTK, {
  identifier = "Room_13",
  uniqueIdentifer = "715b4410-ac70-11f0-997a-156adb22b715",
  neighbourLevels = {
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "nw"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "n"
    },
    {
      levelIid = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
      dir = "ne"
    },
    {
      levelIid = "723b72d0-6fc0-11f1-b67a-9309958fabf9",
      dir = "e"
    },
    {
      levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
      dir = "w"
    }
  },
  customFields = {
    shadow = true,
    light = 0.7,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 13,
    tile = 13,
    DoorsConnection = {
      "Top",
      "Left",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {
      "HasLamp"
    },
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "e35e4010-ac70-11f0-8539-cfa071292c9d",
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
        iid = "f2cac460-ac70-11f0-8539-f32c05a0c6fe",
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
        iid = "5b6513e0-fa90-11f0-b965-f9db40bfdb74",
        x = 396,
        y = 176,
        width = 8,
        height = 32,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--14
table.insert(levelsLDTK, {
  identifier = "Room_14",
  uniqueIdentifer = "6de95960-ac70-11f0-998c-e3108c5f25c9",
  neighbourLevels = {
    {
      levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
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
    roomNumber = 14,
    tile = 14,
    DoorsConnection = {
      "Top",
      "Right",
      "Left"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    TubeExit = {
      {
        id = "TubeExit",
        iid = "4d9917c0-48b0-11f1-98a2-63106ac6403c",
        x = 364,
        y = 28,
        width = 32,
        height = 32,
        customFields = {
          type = "TubeExit",
          nocollider = false,
          destroyed = false
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "e9b65690-ac70-11f0-8539-3392c72a1b66",
        x = 4,
        y = 176,
        width = 8,
        height = 32,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = 1
        }
      },
      {
        id = "Doors",
        iid = "6f73a900-fa90-11f0-b965-0bc3730f853d",
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
        iid = "d0707a20-6fc0-11f1-989d-db5b0204b526",
        x = 396,
        y = 176,
        width = 8,
        height = 32,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Right",
          KeyNumber = nil
        }
      }
    }
  }
})
	--15
table.insert(levelsLDTK, {
  identifier = "Room_15",
  uniqueIdentifer = "708f7320-ac70-11f0-998c-737ddc0c343a",
  neighbourLevels = {
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "n"
    },
    {
      levelIid = "5d9233e0-6fc0-11f1-b67a-e55e4363b0b6",
      dir = "w"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "ne"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
      dir = "nw"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = "e"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 15,
    tile = 15,
    DoorsConnection = {
      "Top",
      "Left",
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
    Doors = {
      {
        id = "Doors",
        iid = "ebfdc080-48b0-11f1-a37f-87e869c0a45e",
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
        iid = "eddc92a0-48b0-11f1-a37f-f5ca81b969af",
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
        iid = "f859f2e0-6fc0-11f1-b96e-07aea1276099",
        x = 336,
        y = 4,
        width = 32,
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
  uniqueIdentifer = "5d9233e0-6fc0-11f1-b67a-e55e4363b0b6",
  neighbourLevels = {
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "ne"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
      dir = "n"
    },
    {
      levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
      dir = "e"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 16,
    tile = 16,
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
    Doors = {
      {
        id = "Doors",
        iid = "aa58c0c0-6fc0-11f1-b67a-996c9da2dfab",
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
        iid = "b3934570-6fc0-11f1-b67a-8d5a19eefbe7",
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
	--17
table.insert(levelsLDTK, {
  identifier = "Room_17",
  uniqueIdentifer = "78785770-6fc0-11f1-b67a-cf9ecaa9adb5",
  neighbourLevels = {
    {
      levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
      dir = "n"
    },
    {
      levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
      dir = "ne"
    },
    {
      levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
      dir = "se"
    },
    {
      levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
      dir = "w"
    },
    {
      levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
      dir = "e"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
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
    roomNumber = 17,
    tile = 17,
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
    Doors = {
      {
        id = "Doors",
        iid = "78785777-6fc0-11f1-b67a-79514b1aa5d6",
        x = 200,
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
        iid = "78785778-6fc0-11f1-b67a-6d0c150ad9d3",
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
        iid = "bca53840-6fc0-11f1-b96e-6d60e73b14e1",
        x = 336,
        y = 236,
        width = 32,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      },
      {
        id = "Doors",
        iid = "d3b5e9d0-6fc0-11f1-b96e-cb34d890b6e2",
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
	--18
table.insert(levelsLDTK, {
  identifier = "Room_18",
  uniqueIdentifer = "723b72d0-6fc0-11f1-b67a-9309958fabf9",
  neighbourLevels = {
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "nw"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = "w"
    },
    {
      levelIid = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
      dir = "n"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 18,
    tile = 18,
    DoorsConnection = {
      "Top",
      "Left"
    },
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
        iid = "723b72d8-6fc0-11f1-b67a-874363e9f815",
        x = 4,
        y = 176,
        width = 8,
        height = 32,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
          KeyNumber = 1
        }
      },
      {
        id = "Doors",
        iid = "723b72d9-6fc0-11f1-b67a-2b8b5df21eb5",
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
	--18
table.insert(levelsLDTK, {
  identifier = "Room_25",
  uniqueIdentifer = "d1edc1a0-6fc0-11f1-90a3-51b4142cd9bd",
  neighbourLevels = {},
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 18,
    tile = 18,
    DoorsConnection = {
      "Top",
      "Left",
      "Down",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "StartDown",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "d1ede8b5-6fc0-11f1-90a3-29c09f95f50f",
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
        iid = "f20f01b0-6fc0-11f1-90a3-fd76c8524431",
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
        iid = "f85f10a0-6fc0-11f1-90a3-f9b54bccf788",
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
        iid = "ff05a400-6fc0-11f1-90a3-5fa59ee388c5",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
          KeyNumber = nil
        }
      }
    }
  }
})
	--19
table.insert(levelsLDTK, {
  identifier = "Room_19",
  uniqueIdentifer = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
  neighbourLevels = {
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "nw"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "w"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = "sw"
    },
    {
      levelIid = "f1f1b160-6fc0-11f1-b67a-957580c04f65",
      dir = "n"
    },
    {
      levelIid = "723b72d0-6fc0-11f1-b67a-9309958fabf9",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 19,
    tile = 19,
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
    Doors = {
      {
        id = "Doors",
        iid = "8312aab6-6fc0-11f1-b67a-bdf997b810ed",
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
        iid = "8312aab7-6fc0-11f1-b67a-b7d52f44ead9",
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
        iid = "10abaff0-6fc0-11f1-b96e-01ed048a45df",
        x = 200,
        y = 236,
        width = 48,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
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
  neighbourLevels = {
    {
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "sw"
    },
    {
      levelIid = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a",
      dir = "w"
    },
    {
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
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
        y = 234,
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
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
      dir = "n"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "w"
    },
    {
      levelIid = "326d5080-48b0-11f1-a37f-1b74e05a8681",
      dir = "sw"
    },
    {
      levelIid = "831283a0-6fc0-11f1-b67a-cf68be7f737f",
      dir = "s"
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
  uniqueIdentifer = "af4d7e50-6fc0-11f1-989d-8151041b4734",
  neighbourLevels = {
    {
      levelIid = "6c078cc0-6fc0-11f1-989d-171d9e0d832f",
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
    roomNumber = 22,
    tile = 22,
    DoorsConnection = {},
    play = nil,
    procGen = true,
    roomRole = "StartUp",
    requiredItems = {},
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
<<<<<<< Updated upstream
    TKNotes = {
      {
        id = "TKNotes",
        iid = "d5c86a40-6fc0-11f1-989d-35b219133546",
        x = 260,
        y = 84,
        width = 32,
        height = 48,
        customFields = {
          String = "player spawn drop"
        }
      }
    },
    Lamp = {
      {
        id = "Lamp",
        iid = "af4da562-6fc0-11f1-989d-77b3e3bfc5f9",
        x = 228,
        y = 84,
        width = 32,
        height = 32,
        customFields = {
          type = "lamp",
          isItem = true
=======
    TubeExit = {
      {
        id = "TubeExit",
        iid = "e602f690-6fc0-11f1-90a3-07815a3b0243",
        x = 364,
        y = 196,
        width = 32,
        height = 32,
        customFields = {
          type = "TubeExit",
          nocollider = false,
          destroyed = false
>>>>>>> Stashed changes
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
      }
    }
  }
})
	--23
table.insert(levelsLDTK, {
  identifier = "Room_23",
  uniqueIdentifer = "6c078cc0-6fc0-11f1-989d-171d9e0d832f",
  neighbourLevels = {
    {
      levelIid = "af4d7e50-6fc0-11f1-989d-8151041b4734",
      dir = "s"
    }
  },
  customFields = {
    shadow = true,
    light = 0.5,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 23,
    tile = 23,
    DoorsConnection = {
      "Top",
      "Down",
      "Right"
    },
    play = nil,
    procGen = true,
    roomRole = "Normal",
    requiredItems = {
      "HasLamp"
    },
    requiredSkills = {},
    hasForeground = true
  },
  entities = {
    TubeExit = {
      {
        id = "TubeExit",
        iid = "6c078cc7-6fc0-11f1-989d-ef5b03520221",
        x = 36,
        y = 204,
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
        iid = "6c078cc9-6fc0-11f1-989d-d583550687bb",
        x = 36,
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
    Doors = {
      {
        id = "Doors",
        iid = "6c078ccb-6fc0-11f1-989d-2984a215336b",
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
        iid = "6c078ccc-6fc0-11f1-989d-4738aa318e4e",
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
        iid = "6c078ccd-6fc0-11f1-989d-33e68e2c9a23",
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
        iid = "6c078cce-6fc0-11f1-989d-655f9f271daf",
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
        iid = "6c078ccf-6fc0-11f1-989d-01f43a61e679",
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
        iid = "6c078cd0-6fc0-11f1-989d-3115cb3c35b5",
        x = 88,
        y = 234,
        width = 16,
        height = 8,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Down",
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
    },
    {
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
      dir = "se"
    },
    {
      levelIid = "bd739520-6fc0-11f1-b67a-b3124c589208",
      dir = "e"
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
