	--23
table.insert(levelsLDTK, {
  identifier = "Room_23",
  uniqueIdentifer = "3d752854-ac70-11f0-998c-5dddbfac239d",
  neighbourLevels = {
    {
      levelIid = "271dbf30-ac70-11f0-998c-eff03b419e1f",
      dir = "<"
    },
    {
      levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
      dir = ">"
    },
    {
      levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
      dir = "nw"
    },
    {
      levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
      dir = "n"
    },
    {
      levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
      dir = "ne"
    },
    {
      levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
      dir = "w"
    },
    {
      levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
      dir = "e"
    },
    {
      levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
      dir = "sw"
    },
    {
      levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
      dir = "s"
    },
    {
      levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 3,
    roomNumber = 23,
    tile = 23,
    DoorsConnection = {
      "Upper"
    },
    play = nil,
    hasForeground = true
  },
  entities = {
    PneumaticTube = {
      {
        id = "PneumaticTube",
        iid = "b62df370-fa90-11f0-b30d-935794ec5f17",
        x = 44,
        y = 204,
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
        iid = "b8aed1f0-fa90-11f0-b30d-9767e2593e69",
        x = 44,
        y = 172,
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
        iid = "b97444d0-fa90-11f0-b30d-1516530fbe42",
        x = 44,
        y = 140,
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
        iid = "ba446610-fa90-11f0-b30d-a5d542c284cf",
        x = 44,
        y = 108,
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
        iid = "bddfb540-fa90-11f0-b30d-69e74fd1f321",
        x = 44,
        y = 76,
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
        iid = "781419e0-fa90-11f0-9f0d-9b937fda017f",
        x = 44,
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
        iid = "8a1775b0-fa90-11f0-9f0d-e181ad477a53",
        x = 44,
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
    Doors = {
      {
        id = "Doors",
        iid = "bcc50700-fa90-11f0-9039-e356dc00e5f2",
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
        iid = "c9a6f920-48b0-11f1-b354-c9bfb305a719",
        x = 392,
        y = 136,
        width = 16,
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
	--24
table.insert(levelsLDTK, {
  identifier = "Room_24",
  uniqueIdentifer = "40386700-ac70-11f0-998c-e53e1b32800c",
  neighbourLevels = {
    {
      levelIid = "2a300840-ac70-11f0-998c-8f209da81536",
      dir = "<"
    },
    {
      levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
      dir = ">"
    },
    {
      levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
      dir = "nw"
    },
    {
      levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
      dir = "n"
    },
    {
      levelIid = "35082cd0-ac70-11f0-998c-d16d78429f5c",
      dir = "ne"
    },
    {
      levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
      dir = "w"
    },
    {
      levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
      dir = "e"
    },
    {
      levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
      dir = "sw"
    },
    {
      levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
      dir = "s"
    },
    {
      levelIid = "53674a87-ac70-11f0-998c-83aa3940da82",
      dir = "se"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 3,
    roomNumber = 24,
    tile = 24,
    DoorsConnection = {
      "Top"
    },
    play = nil,
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "c3139fa0-48b0-11f1-b354-ffae97b5bea5",
        x = 8,
        y = 136,
        width = 16,
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
	--27
table.insert(levelsLDTK, {
  identifier = "Room_27",
  uniqueIdentifer = "4a0bd050-ac70-11f0-998c-b14d359446e6",
  neighbourLevels = {
    {
      levelIid = "c0dc4470-ac70-11f0-998c-497612e0536f",
      dir = "<"
    },
    {
      levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
      dir = ">"
    },
    {
      levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
      dir = "nw"
    },
    {
      levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
      dir = "n"
    },
    {
      levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
      dir = "ne"
    },
    {
      levelIid = "46b2e150-ac70-11f0-998c-232538b976f9",
      dir = "w"
    },
    {
      levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
      dir = "e"
    }
  },
  customFields = {
    shadow = true,
    light = 0.15,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 3,
    roomNumber = 27,
    tile = 27,
    DoorsConnection = {
      "Right"
    },
    play = nil,
    hasForeground = true
  },
  entities = {
    Doors = {
      {
        id = "Doors",
        iid = "727b6360-fa90-11f0-9039-d7e644e05329",
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
	--28
table.insert(levelsLDTK, {
  identifier = "Room_28",
  uniqueIdentifer = "4cf534a4-ac70-11f0-998c-6712312c62dc",
  neighbourLevels = {
    {
      levelIid = "c37083e0-ac70-11f0-998c-41014ccafb8f",
      dir = "<"
    },
    {
      levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
      dir = ">"
    },
    {
      levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
      dir = "nw"
    },
    {
      levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
      dir = "n"
    },
    {
      levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
      dir = "ne"
    },
    {
      levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
      dir = "w"
    },
    {
      levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
      dir = "e"
    }
  },
  customFields = {
    shadow = false,
    light = 0,
    visited = false,
    comic_name = nil,
    comic_wasPlayed = false,
    level = 3,
    roomNumber = 28,
    tile = 28,
    DoorsConnection = {
      "Top"
    },
    play = nil,
    hasForeground = true
  },
  entities = {
    Triggers = {
      {
        id = "Triggers",
        iid = "6d20e240-21a0-11f1-9039-c1a6c9bc4d54",
        x = 364,
        y = 116,
        width = 40,
        height = 72,
        customFields = {
          script = "whereDoor",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {}
        }
      },
      {
        id = "Triggers",
        iid = "cfc0fde0-21a0-11f1-9039-b74e4b1613bb",
        x = 108,
        y = 156,
        width = 48,
        height = 48,
        customFields = {
          script = "bigEmptyRoom",
          usedTrigger = false,
          type = "Search",
          mapPercent = 0,
          conditionalScripts = {}
        }
      }
    },
    Doors = {
      {
        id = "Doors",
        iid = "d45ce9f0-fa90-11f0-9039-7ffe57d05b86",
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
        iid = "e1168340-fa90-11f0-9039-43e9ae1c70fa",
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