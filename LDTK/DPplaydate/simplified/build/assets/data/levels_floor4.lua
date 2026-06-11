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
    TKNotes = {
      {
        id = "TKNotes",
        iid = "6f1ed150-21a0-11f1-b443-37273b02d9b7",
        x = 196,
        y = 76,
        width = 64,
        height = 32,
        customFields = {
          String = "Arbol de navidad y regalos"
        }
      }
    },
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
      },
      {
        id = "Triggers",
        iid = "20aea340-48b0-11f1-b67e-6354679cdabc",
        x = 60,
        y = 84,
        width = 40,
        height = 40,
        customFields = {
          script = "justBoxes",
          usedTrigger = false,
          type = "Story",
          mapPercent = 0,
          conditionalScripts = {},
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
    Box = {
      {
        id = "Box",
        iid = "0ee36e70-48b0-11f1-b67e-0304cf2370db",
        x = 84,
        y = 60,
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
        iid = "101a67d0-48b0-11f1-b67e-cb9384f6940e",
        x = 28,
        y = 100,
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
        iid = "1162c650-48b0-11f1-b67e-f70975554232",
        x = 60,
        y = 84,
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
        iid = "a6eb3090-48b0-11f1-89a8-87e2ffc3bcd6",
        x = 44,
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
          conditionalScripts = {},
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
          DestLevel = 4,
          DestRoom = 81,
          SpawnX = 200,
          SpawnY = 184,
          Conditions = {
            "isTiny:true"
          },
          BlockedDialog = "cabinetHole"
        }
      }
    }
  }
})
	--4
table.insert(levelsLDTK, {
  identifier = "Room_4",
  uniqueIdentifer = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
  neighbourLevels = {},
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
      levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
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
    roomNumber = 5,
    tile = 5,
    DoorsConnection = {
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
  neighbourLevels = {},
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
    roomRole = "Normal",
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
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "e"
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
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
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
    TKNotes = {
      {
        id = "TKNotes",
        iid = "f9ee3fa0-21a0-11f1-b443-c7cced9c425f",
        x = 164,
        y = 108,
        width = 64,
        height = 88,
        customFields = {
          String = "obstaculos"
        }
      },
      {
        id = "TKNotes",
        iid = "14eca620-21a0-11f1-b443-a9f5cdba07f0",
        x = 268,
        y = 116,
        width = 56,
        height = 64,
        customFields = {
          String = "obstaculos"
        }
      },
      {
        id = "TKNotes",
        iid = "2151dde0-21a0-11f1-b443-4f5e750d34c6",
        x = 356,
        y = 196,
        width = 40,
        height = 40,
        customFields = {
          String = "Llave"
        }
      }
    },
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
        iid = "ac81c810-fa90-11f0-bb17-65c231745807",
        x = 260,
        y = 196,
        width = 24,
        height = 48,
        customFields = {
          script = nil,
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {
            "crew>2:twoCM",
            "crew>1:oneCM",
            "crew>=0:noCM"
          },
          SpawnConditions = {}
        }
      }
    },
    TubeExit = {
      {
        id = "TubeExit",
        iid = "9fbc56a0-21a0-11f1-9039-37e7cd6f0338",
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
    Notes = {
      {
        id = "Notes",
        iid = "18c3f520-48b0-11f1-b67e-f71bda3ced77",
        x = 356,
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
    Radio = {
      {
        id = "Radio",
        iid = "d912a690-48b0-11f1-b67e-b3bd8fef5a8f",
        x = 212,
        y = 108,
        width = 32,
        height = 32,
        customFields = {
          type = "radio",
          isItem = true
        }
      }
    },
    Microwave = {
      {
        id = "Microwave",
        iid = "51a224e0-48b0-11f1-98a2-291ad2ba4d9e",
        x = 308,
        y = 204,
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
    Minifier = {
      {
        id = "Minifier",
        iid = "a8596f40-48b0-11f1-98a2-3f686639278d",
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
      levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
      dir = "nw"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = "w"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 9,
    tile = 9,
    DoorsConnection = {
      "Top",
      "Down",
      "Left",
      "Lower"
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
    Minifier = {
      {
        id = "Minifier",
        iid = "21887b30-fa90-11f0-9a41-eb80f350135c",
        x = 100,
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
    NPC = {
      {
        id = "NPC",
        iid = "0ea7c260-21a0-11f1-ba67-7b68c287fc9b",
        x = 364,
        y = 132,
        width = 32,
        height = 32,
        customFields = {
          type = "cat",
          conditionalScripts = {
            "!items.hasLamp:catNoLamp",
            "!items.hasBoots:catNoBoots",
            "true:catWhat"
          },
          sourceFeed = 0,
          hasGranted = false,
          forceSpawn = false,
          triggerScene = "Cockpit"
        }
      },
      {
        id = "NPC",
        iid = "f9918570-48b0-11f1-b3b6-e7169d94681e",
        x = 292,
        y = 36,
        width = 32,
        height = 32,
        customFields = {
          type = "computer",
          conditionalScripts = {
            "true:catWhat"
          },
          sourceFeed = 0,
          hasGranted = false,
          forceSpawn = false,
          triggerScene = "Cockpit"
        }
      }
    },
    Microwave = {
      {
        id = "Microwave",
        iid = "f4f92e10-48b0-11f1-b3b6-6f4db105fcd8",
        x = 356,
        y = 84,
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
        iid = "01ab7460-48b0-11f1-b3b6-af7062196e83",
        x = 292,
        y = 204,
        width = 32,
        height = 32,
        customFields = {
          type = "food",
          grants = "hasitemname:bool",
          isItem = true
        }
      },
      {
        id = "Food",
        iid = "03bf1220-48b0-11f1-b3b6-e7ea6e59f7b0",
        x = 292,
        y = 172,
        width = 32,
        height = 32,
        customFields = {
          type = "food",
          grants = "hasitemname:bool",
          isItem = true
        }
      }
    },
    Plunger = {
      {
        id = "Plunger",
        iid = "8c9a4ee0-48b0-11f1-98a2-5d3443b1ee75",
        x = 68,
        y = 76,
        width = 32,
        height = 32,
        customFields = {
          type = "plunger",
          isItem = true
        }
      }
    },
    Box = {
      {
        id = "Box",
        iid = "521eb5f0-48b0-11f1-9b23-63dda7aa23ba",
        x = 44,
        y = 164,
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
        iid = "54cf5700-48b0-11f1-9b23-8f3535d0631e",
        x = 292,
        y = 92,
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
        iid = "d7770400-48b0-11f1-89a8-99487610e8bd",
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
	--10
table.insert(levelsLDTK, {
  identifier = "Room_10",
  uniqueIdentifer = "672c4d40-ac70-11f0-997a-7b0342bedabe",
  neighbourLevels = {
    {
      levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
      dir = "n"
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
    roomNumber = 10,
    tile = 10,
    DoorsConnection = {
      "Down",
      "Top"
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
        iid = "f6717570-48b0-11f1-98a2-df962a99b954",
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
        iid = "c50b2a70-48b0-11f1-98a2-7d36f693b69b",
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
	--11
table.insert(levelsLDTK, {
  identifier = "Room_11",
  uniqueIdentifer = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
  neighbourLevels = {},
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
    CrewMember = {
      {
        id = "CrewMember",
        iid = "282768a0-48b0-11f1-98a2-1d4cd08822d8",
        x = 108,
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
    Brocorat = {
      {
        id = "Brocorat",
        iid = "29665140-48b0-11f1-98a2-790362c92a73",
        x = 172,
        y = 132,
        width = 32,
        height = 32,
        customFields = {
          speed = 0.5,
          dead = false,
          forceSpawn = false
        }
      }
    },
    Food = {
      {
        id = "Food",
        iid = "2b2b32c0-48b0-11f1-98a2-b5ce0b3571f9",
        x = 292,
        y = 68,
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
      }
    }
  }
})
	--12
table.insert(levelsLDTK, {
  identifier = "Room_12",
  uniqueIdentifer = "6cc9d510-ac70-11f0-997a-191299f9209c",
  neighbourLevels = {},
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
      "Right",
      "Lower"
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
  neighbourLevels = {},
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
      "Right",
      "Lower"
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
  neighbourLevels = {},
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
        iid = "287e6aa0-48b0-11f1-98a2-3b888e751c9b",
        x = 394,
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
      levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
      dir = "n"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 4,
    roomNumber = 15,
    tile = 15,
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
    CrewMember = {
      {
        id = "CrewMember",
        iid = "4c2b6120-48b0-11f1-98a2-238f40a01dc4",
        x = 300,
        y = 124,
        width = 48,
        height = 48,
        customFields = {
          isTaken = false,
          crewID = "100",
          forceSpawn = false
        }
      },
      {
        id = "CrewMember",
        iid = "4d17e400-48b0-11f1-98a2-b5f956bd4853",
        x = 44,
        y = 92,
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
        iid = "0a2f2b70-48b0-11f1-98a2-a1a6cf64a455",
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
        iid = "13eb8a50-48b0-11f1-98a2-8bd76a8dbe19",
        x = 4,
        y = 176,
        width = 8,
        height = 32,
        customFields = {
          NeedsKey = false,
          DoorsConnection = "Left",
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
          DestLevel = 4,
          DestRoom = 3,
          SpawnX = 161,
          SpawnY = 128,
          Conditions = {},
          BlockedDialog = nil
        }
      }
    }
  }
})
