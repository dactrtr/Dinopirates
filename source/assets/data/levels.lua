levelsLDTK = {
	--1
{
	identifier = "Room_1",
	uniqueIdentifer = "69eb2d80-ac70-11f0-989f-95306126bd74",
	neighbourLevels = {
	  {
		levelIid = "ae5a31c0-ac70-11f0-9560-a1abd660ccf1",
		dir = "<"
	  },
	  {
		levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
		dir = "e"
	  },
	  {
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
		dir = "s"
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "ddfc39a0-ac70-11f0-8539-bf7f1c18638c",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
	--2
{
	identifier = "Room_2",
	uniqueIdentifer = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
	neighbourLevels = {
	  {
		levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
		dir = "<"
	  },
	  {
		levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
		dir = "w"
	  },
	  {
		levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
		dir = "e"
	  },
	  {
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "b3283eb0-ac70-11f0-8539-f3c8ed5b1669",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "b620e540-ac70-11f0-8539-71a575f15bb9",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		}
	  },
	  Triggers = {
		{
		  id = "Triggers",
		  iid = "04803a80-ac70-11f0-ae64-7fad2120052d",
		  x = 172,
		  y = 100,
		  width = 40,
		  height = 40,
		  customFields = {
			script = "giftFor100",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "0f48b230-ac70-11f0-ae64-49bfdc9ab6ce",
		  x = 220,
		  y = 92,
		  width = 40,
		  height = 40,
		  customFields = {
			script = "giftFor233",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "7d672b30-ac70-11f0-ae64-79d729daa857",
		  x = 308,
		  y = 180,
		  width = 88,
		  height = 88,
		  customFields = {
			script = "entranceMess",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
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
			conditionalScripts = {}
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
			}
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
			isItem = true
		  }
		}
	  },
	  Xtree1 = {
		{
		  id = "Xtree1",
		  iid = "0b24fca0-ac70-11f0-985a-61d94463d05b",
		  x = 164,
		  y = 44,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "xtree-1",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Xtree2 = {
		{
		  id = "Xtree2",
		  iid = "0cc60270-ac70-11f0-985a-1d1e859d73df",
		  x = 196,
		  y = 44,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "xtree-2",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Xtree3 = {
		{
		  id = "Xtree3",
		  iid = "0ec1f980-ac70-11f0-985a-a3051c196f4b",
		  x = 164,
		  y = 76,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "xtree-3",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Xtree4 = {
		{
		  id = "Xtree4",
		  iid = "1072ddd0-ac70-11f0-985a-077e223da91c",
		  x = 196,
		  y = 76,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "xtree-4",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Gifts = {
		{
		  id = "Gifts",
		  iid = "13ad2140-ac70-11f0-985a-d1b75f9e1484",
		  x = 140,
		  y = 84,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "gifts",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Gifts",
		  iid = "1693c670-ac70-11f0-985a-51430b780b06",
		  x = 220,
		  y = 92,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "gifts",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Gift = {
		{
		  id = "Gift",
		  iid = "1afcecf0-ac70-11f0-985a-01e2a66cb28c",
		  x = 172,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "gift",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Blood2 = {
		{
		  id = "Blood2",
		  iid = "2652d790-ac70-11f0-985a-25b699999ba6",
		  x = 108,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "2929ec60-ac70-11f0-985a-4126f85ddd1f",
		  x = 252,
		  y = 84,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  Blood = {
		{
		  id = "Blood",
		  iid = "2dcb39e0-ac70-11f0-985a-45f325c18dbd",
		  x = 84,
		  y = 52,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "2f6c18a0-ac70-11f0-985a-a1f4b58b53d7",
		  x = 300,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "31637bd0-ac70-11f0-985a-7b97c4a1ea96",
		  x = 140,
		  y = 132,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  Table = {
		{
		  id = "Table",
		  iid = "46dec050-ac70-11f0-985a-132726764f8b",
		  x = 36,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "table",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Table",
		  iid = "487d5520-ac70-11f0-985a-cd8cc298fdae",
		  x = 356,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "table",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Table",
		  iid = "6d93cec0-ac70-11f0-ae64-1be5800770cc",
		  x = 300,
		  y = 172,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "table",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  FellTable = {
		{
		  id = "FellTable",
		  iid = "4abbfa80-ac70-11f0-985a-7319d2beaa22",
		  x = 324,
		  y = 92,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4c9c0520-ac70-11f0-985a-e99f3d0bf46f",
		  x = 36,
		  y = 180,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4db452f0-ac70-11f0-985a-cfe8262e92fe",
		  x = 364,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4fdbc6d0-ac70-11f0-985a-a5601f3ccd47",
		  x = 92,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "6ed6af00-ac70-11f0-ae64-f7bb28f9916d",
		  x = 340,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Fellchair = {
		{
		  id = "Fellchair",
		  iid = "518e7fe0-ac70-11f0-985a-93391a2015c0",
		  x = 316,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "53f63110-ac70-11f0-985a-d350bb30470b",
		  x = 348,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "54ba1d50-ac70-11f0-985a-27fb7aa5ea82",
		  x = 252,
		  y = 188,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "722d2d00-ac70-11f0-ae64-d9f2ef5111fe",
		  x = 324,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		}
	  },
	  Chair = {
		{
		  id = "Chair",
		  iid = "7626a1c0-ac70-11f0-ae64-a5338e4e288e",
		  x = 364,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "chair"
		  }
		}
	  }
	}
  },
	--3
{
	identifier = "Room_3",
	uniqueIdentifer = "bf654080-ac70-11f0-997a-e578ba2da2ac",
	neighbourLevels = {
	  {
		levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
		dir = "<"
	  },
	  {
		levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
		dir = "w"
	  },
	  {
		levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "bb73a870-ac70-11f0-8539-03f7dfb4cdc8",
		  x = 8,
		  y = 120,
		  width = 16,
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
		  y = 232,
		  width = 48,
		  height = 16,
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
		}
	  },
	  Triggers = {
		{
		  id = "Triggers",
		  iid = "c9660040-ac70-11f0-ae64-094e17987f94",
		  x = 100,
		  y = 60,
		  width = 56,
		  height = 32,
		  customFields = {
			script = "microwaveBurn",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "f2317670-ac70-11f0-ae64-133829c2c353",
		  x = 244,
		  y = 108,
		  width = 32,
		  height = 32,
		  customFields = {
			script = "kitchenWeapons",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {
			  "items.hasLamp:nolamp"
			}
		  }
		},
		{
		  id = "Triggers",
		  iid = "3a47bf50-ac70-11f0-ae64-474c236a6fd7",
		  x = 332,
		  y = 100,
		  width = 56,
		  height = 48,
		  customFields = {
			script = "inneficientCutting",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			conditionalScripts = {}
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
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "26163fe0-ac70-11f0-8398-53067febe16c",
		  x = 196,
		  y = 204,
		  width = 96,
		  height = 40,
		  customFields = {
			script = "notnormalBrocoli",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		}
	  },
	  FellTable = {
		{
		  id = "FellTable",
		  iid = "bf46c0e0-ac70-11f0-ae64-597ec6fe672b",
		  x = 36,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "ffc9fb50-d380-11f0-a276-0f85237af89c",
		  x = 276,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Blood = {
		{
		  id = "Blood",
		  iid = "c2442260-ac70-11f0-ae64-a5f7b1f853f5",
		  x = 68,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "01ef6b90-ac70-11f0-ae64-292bbea86898",
		  x = 324,
		  y = 132,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0601e690-ac70-11f0-ae64-8778a1292c62",
		  x = 348,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0ed1c290-ac70-11f0-ae64-95329b483a8a",
		  x = 268,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0e256780-ac70-11f0-8398-fb5fdad9133f",
		  x = 196,
		  y = 212,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  Microwave = {
		{
		  id = "Microwave",
		  iid = "c7345330-ac70-11f0-ae64-3f2b938fe6d4",
		  x = 100,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "microwave",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  DeadRat = {
		{
		  id = "DeadRat",
		  iid = "f4bef490-ac70-11f0-ae64-d96e07439f33",
		  x = 332,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "deadrat",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Blood2 = {
		{
		  id = "Blood2",
		  iid = "fb5b9ce0-ac70-11f0-ae64-c17f4252e798",
		  x = 292,
		  y = 84,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "12214d40-ac70-11f0-8398-31a430f47a22",
		  x = 228,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "1975acd0-ac70-11f0-8398-9b842ef570b6",
		  x = 164,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "1f4d3060-ac70-11f0-8398-2ff5d145c0a9",
		  x = 204,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  KnifeKettle = {
		{
		  id = "KnifeKettle",
		  iid = "ed4c9040-ac70-11f0-ae64-57af9b96ac8a",
		  x = 244,
		  y = 108,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "knifeKettle",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Box = {
		{
		  id = "Box",
		  iid = "9d998240-ac70-11f0-ae64-fffc401f9f95",
		  x = 44,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		}
	  },
	  Fridge2 = {
		{
		  id = "Fridge2",
		  iid = "35301230-ac70-11f0-8398-8fcdc90b8969",
		  x = 188,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fridge2",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Fridge1 = {
		{
		  id = "Fridge1",
		  iid = "368c94f0-ac70-11f0-8398-27c802cf0097",
		  x = 188,
		  y = 36,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fridge1",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Smalltable = {
		{
		  id = "Smalltable",
		  iid = "39a100e0-ac70-11f0-8398-058ecccabc84",
		  x = 156,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d0f28ea0-d380-11f0-a276-170abcc70553",
		  x = 276,
		  y = 188,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d4288c50-d380-11f0-a276-9bdf43235b7f",
		  x = 276,
		  y = 124,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d53679e0-d380-11f0-a276-8f2b37a9f3ee",
		  x = 284,
		  y = 212,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d78991a0-d380-11f0-a276-f7b032b235ae",
		  x = 260,
		  y = 52,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  KitchenStorage = {
		{
		  id = "KitchenStorage",
		  iid = "3d5fb690-ac70-11f0-8398-89d1822135c2",
		  x = 220,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "421f6180-ac70-11f0-8398-3187f4a538f2",
		  x = 292,
		  y = 60,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "f90bc140-d380-11f0-a276-d3e851faf0a1",
		  x = 276,
		  y = 92,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		}
	  }
	}
  },
	--4
{
	identifier = "Room_4",
	uniqueIdentifer = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
	neighbourLevels = {
	  {
		levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
		dir = "<"
	  },
	  {
		levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
		dir = "w"
	  },
	  {
		levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
		dir = "e"
	  },
	  {
		levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
		dir = "sw"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "s"
	  },
	  {
		levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
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
	  roomNumber = 4,
	  tile = 4,
	  DoorsConnection = {
		"Right",
		"Down"
	  },
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "fcabe850-ac70-11f0-8539-f1bce0538eff",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "ffe408e0-ac70-11f0-8539-89d439e8021b",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
	--5
{
	identifier = "Room_5",
	uniqueIdentifer = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
	neighbourLevels = {
	  {
		levelIid = "35082cd0-ac70-11f0-998c-d16d78429f5c",
		dir = "<"
	  },
	  {
		levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
		dir = "w"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "sw"
	  },
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "f5e5bf00-ac70-11f0-8539-f58c218411b3",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "f8ae06c0-ac70-11f0-8539-9d773c086baf",
		  x = 8,
		  y = 120,
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
  },
	--6
{
	identifier = "Room_6",
	uniqueIdentifer = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
	neighbourLevels = {
	  {
		levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
		dir = "<"
	  },
	  {
		levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
		dir = "n"
	  },
	  {
		levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
		dir = "ne"
	  },
	  {
		levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
		dir = "e"
	  },
	  {
		levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
		dir = "s"
	  },
	  {
		levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
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
		"Lower"
	  },
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "e79962a0-ac70-11f0-8539-4594309692bf",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "da8eb130-ac70-11f0-8539-69febe1f53e0",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  },
	  HoleTop = {
		{
		  id = "HoleTop",
		  iid = "a2dada30-ac70-11f0-aeab-fdd199a31095",
		  x = 188,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a3e8a0b0-ac70-11f0-aeab-237958cd4eb9",
		  x = 220,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a568ff20-ac70-11f0-aeab-c5fcba3999fe",
		  x = 156,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a7cb5920-ac70-11f0-aeab-a780b82da70f",
		  x = 124,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "aee017a0-ac70-11f0-aeab-ffa59df36d35",
		  x = 92,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d345b820-ac70-11f0-aeab-ffedc793cee1",
		  x = 252,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d3d68670-ac70-11f0-aeab-4dbd9e992dd4",
		  x = 284,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d4a71ce0-ac70-11f0-aeab-81743c8a812b",
		  x = 316,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "de04e100-ac70-11f0-aeab-2d997a966a55",
		  x = 348,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleTopLeft = {
		{
		  id = "HoleTopLeft",
		  iid = "b092d0b0-ac70-11f0-aeab-ad75bd810002",
		  x = 60,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTopLeft",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleTopRight = {
		{
		  id = "HoleTopRight",
		  iid = "e10f13c0-ac70-11f0-aeab-77029aa7acec",
		  x = 380,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTopRight",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottom = {
		{
		  id = "HoleBottom",
		  iid = "e56db2f0-ac70-11f0-aeab-9f787fe513a2",
		  x = 92,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e6225cf0-ac70-11f0-aeab-99f2faa74e15",
		  x = 124,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e6eb7950-ac70-11f0-aeab-55a9edb21eff",
		  x = 156,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e83de9f0-ac70-11f0-aeab-7b6e5db28835",
		  x = 188,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e9133b50-ac70-11f0-aeab-457539c30082",
		  x = 220,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ea3f8650-ac70-11f0-aeab-b91d3c4f855f",
		  x = 252,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "eb246810-ac70-11f0-aeab-a384f29f36dd",
		  x = 284,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ec0181a0-ac70-11f0-aeab-3d6ccc7137bf",
		  x = 316,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ecf09c90-ac70-11f0-aeab-b1cd9ef03272",
		  x = 348,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottomRight = {
		{
		  id = "HoleBottomRight",
		  iid = "f0445b70-ac70-11f0-aeab-bbf5e13a5adf",
		  x = 380,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottomRight",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottomLeft = {
		{
		  id = "HoleBottomLeft",
		  iid = "f6654410-ac70-11f0-aeab-a5f97ee214a6",
		  x = 60,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottomLeft",
			nocollider = false,
			destroyed = false
		  }
		}
	  }
	}
  },
	--7
{
	identifier = "Room_7",
	uniqueIdentifer = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
	neighbourLevels = {
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "<"
	  },
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
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
		dir = "w"
	  },
	  {
		levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
		dir = "e"
	  },
	  {
		levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
		dir = "sw"
	  },
	  {
		levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
		dir = "s"
	  },
	  {
		levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
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
	  play = "Enter"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "ad890930-ac70-11f0-8539-b927b406cff9",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  },
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
			}
		  }
		},
		{
		  id = "Triggers",
		  iid = "cc4b57d0-ac70-11f0-ae64-f1a43cc2526b",
		  x = 292,
		  y = 140,
		  width = 40,
		  height = 40,
		  customFields = {
			script = "someTrash",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "04397810-ac70-11f0-ae64-891aa0cc0d18",
		  x = 36,
		  y = 140,
		  width = 48,
		  height = 40,
		  customFields = {
			script = "justBoxes",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		}
	  },
	  Smalltable = {
		{
		  id = "Smalltable",
		  iid = "76ab7410-ac70-11f0-998c-33dc7dd62999",
		  x = 252,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7828ec50-ac70-11f0-998c-e578b281f438",
		  x = 148,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7c36d370-ac70-11f0-998c-27835b3ae957",
		  x = 148,
		  y = 188,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7e6b3fa0-ac70-11f0-998c-83ad0a5e8378",
		  x = 252,
		  y = 188,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "a99b3a10-ac70-11f0-ae64-bbea47082fb4",
		  x = 36,
		  y = 44,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  FellTable = {
		{
		  id = "FellTable",
		  iid = "850b9170-ac70-11f0-998c-afc1a9873d1e",
		  x = 156,
		  y = 172,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "87335370-ac70-11f0-998c-972d0c2d0afa",
		  x = 244,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "9a8dc5b0-ac70-11f0-ae64-330b96106ce8",
		  x = 92,
		  y = 44,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Trash = {
		{
		  id = "Trash",
		  iid = "9019c4b0-ac70-11f0-998c-d97a85026dbd",
		  x = 164,
		  y = 148,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "trash"
		  }
		},
		{
		  id = "Trash",
		  iid = "91764770-ac70-11f0-998c-ab2da21d72a7",
		  x = 292,
		  y = 140,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "trash"
		  }
		}
	  },
	  Blood = {
		{
		  id = "Blood",
		  iid = "93028cc0-ac70-11f0-998c-e7d639f7f96f",
		  x = 52,
		  y = 196,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "9d6f61d0-ac70-11f0-ae64-e33789cc7e0e",
		  x = 76,
		  y = 76,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "f186f080-ac70-11f0-ae64-a96276b15936",
		  x = 148,
		  y = 76,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  Blood2 = {
		{
		  id = "Blood2",
		  iid = "945f3690-ac70-11f0-998c-c1bfd067cd84",
		  x = 356,
		  y = 188,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "ee1103a0-ac70-11f0-ae64-453fe6771b29",
		  x = 260,
		  y = 68,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		}
	  },
	  KitchenStorage = {
		{
		  id = "KitchenStorage",
		  iid = "a331c4d0-ac70-11f0-998c-f77cabc0329c",
		  x = 252,
		  y = 28,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "a3bffb10-ac70-11f0-998c-2bdf4a768139",
		  x = 284,
		  y = 28,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "a474f330-ac70-11f0-998c-efbe99831fb3",
		  x = 316,
		  y = 28,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Box = {
		{
		  id = "Box",
		  iid = "a87f1450-ac70-11f0-998c-2d12bf7a5583",
		  x = 36,
		  y = 140,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		},
		{
		  id = "Box",
		  iid = "aa01bcb0-ac70-11f0-998c-dffc56ebfc22",
		  x = 364,
		  y = 132,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		}
	  },
	  Fellchair = {
		{
		  id = "Fellchair",
		  iid = "0d7905b0-ac70-11f0-985a-d1c872a5fc59",
		  x = 164,
		  y = 36,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "1022f000-ac70-11f0-985a-9b3988f2af57",
		  x = 364,
		  y = 28,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		}
	  }
	}
  },
	--8
{
	identifier = "Room_8",
	uniqueIdentifer = "d8b90440-ac70-11f0-997a-77d867841568",
	neighbourLevels = {
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "<"
	  },
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
		dir = "ne"
	  },
	  {
		levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
		dir = "w"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "e"
	  },
	  {
		levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
		dir = "sw"
	  },
	  {
		levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
		dir = "s"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
		dir = "se"
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
	  play = "Cutscene"
	},
	entities = {
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
		  iid = "1e6d98b0-fa90-11f0-9039-3be58b1a7a15",
		  x = 394,
		  y = 126,
		  width = 8,
		  height = 32,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		}
	  },
	  Triggers = {
		{
		  id = "Triggers",
		  iid = "1966a940-fa90-11f0-bb17-4bab457c7082",
		  x = 214,
		  y = 76,
		  width = 144,
		  height = 32,
		  customFields = {
			script = "firstCall",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			conditionalScripts = {}
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
			script = "reachComputer",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		}
	  },
	  Notes = {
		{
		  id = "Notes",
		  iid = "399a01d0-21a0-11f1-9039-9fe4fcedee83",
		  x = 68,
		  y = 148,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "notes",
			grants = "canDash:true",
			isItem = true
		  }
		}
	  },
	  Boots = {
		{
		  id = "Boots",
		  iid = "d82f3840-21a0-11f1-9039-7b59a08b7645",
		  x = 68,
		  y = 100,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "boots",
			isItem = true
		  }
		}
	  },
	  PcBase2 = {
		{
		  id = "PcBase2",
		  iid = "2438d1a0-fa90-11f0-bb17-470acac3228b",
		  x = 364,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "pcBase2",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  PcSiriSad = {
		{
		  id = "PcSiriSad",
		  iid = "2832e2a0-fa90-11f0-bb17-5defe973a785",
		  x = 364,
		  y = 172,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "pcSiriSad",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  FellTable = {
		{
		  id = "FellTable",
		  iid = "4afbc310-fa90-11f0-bb17-9f9aae871b88",
		  x = 164,
		  y = 76,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Trash = {
		{
		  id = "Trash",
		  iid = "4eb548a0-fa90-11f0-bb17-ddd5be806714",
		  x = 164,
		  y = 164,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "trash"
		  }
		}
	  },
	  Box = {
		{
		  id = "Box",
		  iid = "52d24af0-fa90-11f0-bb17-b19454514619",
		  x = 260,
		  y = 52,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		},
		{
		  id = "Box",
		  iid = "e1dcbc80-fa90-11f0-bb17-abae770f562b",
		  x = 276,
		  y = 180,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		},
		{
		  id = "Box",
		  iid = "e46f9c60-fa90-11f0-bb17-e702b3a82c8e",
		  x = 276,
		  y = 212,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		}
	  }
	}
  },
	--9
{
	identifier = "Room_9",
	uniqueIdentifer = "dab87dc0-ac70-11f0-997a-63497867517d",
	neighbourLevels = {
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "<"
	  },
	  {
		levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
		dir = "nw"
	  },
	  {
		levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
		dir = "n"
	  },
	  {
		levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
		dir = "ne"
	  },
	  {
		levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
		dir = "w"
	  },
	  {
		levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
		dir = "e"
	  },
	  {
		levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
		dir = "sw"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
		dir = "s"
	  },
	  {
		levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
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
	  roomNumber = 9,
	  tile = 9,
	  DoorsConnection = {
		"Top",
		"Down",
		"Left"
	  },
	  play = nil
	},
	entities = {
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
		  iid = "104fb470-fa90-11f0-9039-f5ad4ff8081c",
		  x = 4,
		  y = 128,
		  width = 8,
		  height = 32,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Left",
			KeyNumber = nil
		  }
		}
	  },
	  CrewMember = {
		{
		  id = "CrewMember",
		  iid = "0c11a640-fa90-11f0-9f0d-c9ca42f46487",
		  x = 124,
		  y = 76,
		  width = 48,
		  height = 48,
		  customFields = {
			isTaken = false,
			crewID = "CM001"
		  }
		}
	  },
	  Minifier = {
		{
		  id = "Minifier",
		  iid = "21887b30-fa90-11f0-9a41-eb80f350135c",
		  x = 364,
		  y = 204,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "minifier",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Box = {
		{
		  id = "Box",
		  iid = "272ae500-fa90-11f0-9a41-890edd14f601",
		  x = 244,
		  y = 172,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		},
		{
		  id = "Box",
		  iid = "27cf6260-fa90-11f0-9a41-b3f1e08f1341",
		  x = 204,
		  y = 172,
		  width = 32,
		  height = 32,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		}
	  }
	}
  },
	--10
{
	identifier = "Room_10",
	uniqueIdentifer = "672c4d40-ac70-11f0-997a-7b0342bedabe",
	neighbourLevels = {
	  {
		levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
		dir = "<"
	  },
	  {
		levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
		dir = "nw"
	  },
	  {
		levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
		dir = "n"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "w"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
		dir = "sw"
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "efce9a60-ac70-11f0-8539-8fc5e98ddb65",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "f2730670-ac70-11f0-8539-6b7de2b59e30",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
	--11
{
	identifier = "Room_11",
	uniqueIdentifer = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
	neighbourLevels = {
	  {
		levelIid = "46b2e150-ac70-11f0-998c-232538b976f9",
		dir = "<"
	  },
	  {
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
		dir = "n"
	  },
	  {
		levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
		dir = "ne"
	  },
	  {
		levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
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
	  roomNumber = 11,
	  tile = 11,
	  DoorsConnection = {
		"Top",
		"Right"
	  },
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "df62b960-ac70-11f0-8539-17b12cc94289",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "e3337070-ac70-11f0-8539-313aa2731b22",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
	--12
{
	identifier = "Room_12",
	uniqueIdentifer = "6cc9d510-ac70-11f0-997a-191299f9209c",
	neighbourLevels = {
	  {
		levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
		dir = "<"
	  },
	  {
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
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
		levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
		dir = "w"
	  },
	  {
		levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
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
	  roomNumber = 12,
	  tile = 12,
	  DoorsConnection = {
		"Left",
		"Right",
		"Lower"
	  },
	  play = nil
	},
	entities = {
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
		}
	  },
	  HoleTopRight = {
		{
		  id = "HoleTopRight",
		  iid = "8a3458e0-fa90-11f0-b7cd-c97cf980cc80",
		  x = 84,
		  y = 124,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTopRight",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleTopLeft = {
		{
		  id = "HoleTopLeft",
		  iid = "8db6a1d0-fa90-11f0-b7cd-8157126ec7f4",
		  x = 28,
		  y = 124,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTopLeft",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleTop = {
		{
		  id = "HoleTop",
		  iid = "909ecda0-fa90-11f0-b7cd-ff148e274309",
		  x = 60,
		  y = 124,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottomLeft = {
		{
		  id = "HoleBottomLeft",
		  iid = "9b7af460-fa90-11f0-b7cd-55367eb31a08",
		  x = 28,
		  y = 156,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottomLeft",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottom = {
		{
		  id = "HoleBottom",
		  iid = "a297c930-fa90-11f0-b7cd-231832d6fef2",
		  x = 60,
		  y = 156,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  HoleBottomRight = {
		{
		  id = "HoleBottomRight",
		  iid = "a690a1b0-fa90-11f0-b7cd-3dad7ceb9f19",
		  x = 84,
		  y = 156,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "holeBottomRight",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
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
			conditionalScripts = {}
		  }
		},
		
		{
		  id = "Triggers",
		  iid = "ff2dc230-21a0-11f1-9039-03e34eda3ccc",
		  x = 56,
		  y = 100,
		  width = 80,
		  height = 8,
		  customFields = {
			script = "abigJump",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		}
	  },
	  Plunger = {
		{
		  id = "Plunger",
		  iid = "f84981f0-fa90-11f0-8164-312164d448cc",
		  x = 28,
		  y = 180,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "plunger",
			isItem = true
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
			destroyed = false
		  }
		}
	  }
	}
  },
	--13
{
	identifier = "Room_13",
	uniqueIdentifer = "715b4410-ac70-11f0-997a-156adb22b715",
	neighbourLevels = {
	  {
		levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
		dir = "<"
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
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "ne"
	  },
	  {
		levelIid = "6cc9d510-ac70-11f0-997a-191299f9209c",
		dir = "w"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
		dir = "e"
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
	  play = nil
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
	  },
	  Triggers = {
		{
		  id = "Triggers",
		  iid = "f5c64900-fa90-11f0-bb17-3998f48db633",
		  x = 268,
		  y = 36,
		  width = 24,
		  height = 56,
		  customFields = {
			script = "secondCall",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "e3ff23f0-21a0-11f1-9039-21f5d6ff2f4a",
		  x = 100,
		  y = 116,
		  width = 24,
		  height = 64,
		  customFields = {
			script = "aLamp",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			conditionalScripts = {}
		  }
		}
	  },
	  Lamp = {
		{
		  id = "Lamp",
		  iid = "e0de0dd0-21a0-11f1-9039-3d34a18fc4f7",
		  x = 60,
		  y = 52,
		  width = 32,
		  height = 32,
		  customFields = {
			type = "lamp",
			isItem = true
		  }
		}
	  }
	}
  },
	--14
{
	identifier = "Room_14",
	uniqueIdentifer = "6de95960-ac70-11f0-998c-e3108c5f25c9",
	neighbourLevels = {
	  {
		levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
		dir = "<"
	  },
	  {
		levelIid = "d8b90440-ac70-11f0-997a-77d867841568",
		dir = "nw"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "n"
	  },
	  {
		levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
		dir = "ne"
	  },
	  {
		levelIid = "715b4410-ac70-11f0-997a-156adb22b715",
		dir = "w"
	  },
	  {
		levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
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
	  roomNumber = 14,
	  tile = 14,
	  DoorsConnection = {
		"Top",
		"Right"
	  },
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "e9b65690-ac70-11f0-8539-3392c72a1b66",
		  x = 4,
		  y = 176,
		  width = 8,
		  height = 32,
		  customFields = {
			NeedsKey = true,
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
		}
	  }
	}
  },
	--15
{
	identifier = "Room_15",
	uniqueIdentifer = "708f7320-ac70-11f0-998c-737ddc0c343a",
	neighbourLevels = {
	  {
		levelIid = "53674a87-ac70-11f0-998c-83aa3940da82",
		dir = "<"
	  },
	  {
		levelIid = "dab87dc0-ac70-11f0-997a-63497867517d",
		dir = "nw"
	  },
	  {
		levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
		dir = "n"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
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
	  roomNumber = 15,
	  tile = 15,
	  DoorsConnection = {
		"Top",
		"Left"
	  },
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "e96b78a0-ac70-11f0-8539-993ee6187bfe",
		  x = 8,
		  y = 120,
		  width = 16,
		  height = 48,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Left",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "ec4d14c0-ac70-11f0-8539-cf6c500b6c61",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
	--23
{
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "bcc50700-fa90-11f0-9039-e356dc00e5f2",
		  x = 80,
		  y = 236,
		  width = 32,
		  height = 8,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		}
	  },
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
	  }
	}
  },
	--27
{
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
	  light = 0.2,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 27,
	  tile = 27,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
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
  },
	--28
{
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
	  play = nil
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "d45ce9f0-fa90-11f0-9039-7ffe57d05b86",
		  x = 80,
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
	  },
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
	  }
	}
  }
		--
}