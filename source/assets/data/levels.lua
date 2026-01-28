levelsLDTK = {
{
	identifier = "Room_8",
	uniqueIdentifer = "d8b90440-ac70-11f0-997a-77d867841568",
	x = 800,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
		"Down"
	  },
	  play = "Cutscene"
	},
	layers = {
	  "BGTilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "07b70f50-ac70-11f0-8539-35ff95bfdbdf",
		  layer = "Doors",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "c5a75a30-ac70-11f0-8539-6130c4fb1bfd",
		  layer = "Doors",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "c25a9ea0-d380-11f0-a276-5f29b940eae6",
		  layer = "Doors",
		  x = 344,
		  y = 4,
		  width = 16,
		  height = 8,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  },
	  CrewMember = {
		{
		  id = "CrewMember",
		  iid = "8366b660-d380-11f0-8084-d509bca39075",
		  layer = "CrewMembers",
		  x = 124,
		  y = 60,
		  width = 48,
		  height = 48,
		  color = 14984818,
		  customFields = {
			isTaken = false,
			crewID = "CM001"
		  }
		},
		{
		  id = "CrewMember",
		  iid = "ab5be230-d380-11f0-88fd-e1d52cbf931c",
		  layer = "CrewMembers",
		  x = 84,
		  y = 116,
		  width = 48,
		  height = 48,
		  color = 14984818,
		  customFields = {
			isTaken = false,
			crewID = "CM012"
		  }
		},
		{
		  id = "CrewMember",
		  iid = "b07c71d0-d380-11f0-88fd-efc30ce22f17",
		  layer = "CrewMembers",
		  x = 228,
		  y = 116,
		  width = 48,
		  height = 48,
		  color = 14984818,
		  customFields = {
			isTaken = false,
			crewID = "CM015"
		  }
		},
		{
		  id = "CrewMember",
		  iid = "b4a58210-d380-11f0-88fd-e74a7cb9ec28",
		  layer = "CrewMembers",
		  x = 268,
		  y = 52,
		  width = 48,
		  height = 48,
		  color = 14984818,
		  customFields = {
			isTaken = false,
			crewID = "CM002"
		  }
		}
	  },
	  Lamp = {
		{
		  id = "Lamp",
		  iid = "73408b10-d380-11f0-88fd-fbddcd5c6de8",
		  layer = "Items",
		  x = 348,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 15389866,
		  customFields = {
			type = "lamp"
		  }
		}
	  },
	  Notes = {
		{
		  id = "Notes",
		  iid = "6552a7b0-d380-11f0-88fd-8d7e941e4618",
		  layer = "Items",
		  x = 356,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 15389866,
		  customFields = {
			type = "notes",
			grants = "canFlash:true"
		  }
		}
	  },
	  ItemGift = {
		{
		  id = "ItemGift",
		  iid = "733afd00-d380-11f0-88fd-bd64032fb015",
		  layer = "Items",
		  x = 276,
		  y = 148,
		  width = 32,
		  height = 32,
		  color = 15389866,
		  customFields = {
			type = "itemGift",
			grants = "has:Plunger"
		  }
		}
	  },
	  Brocorat = {
		{
		  id = "Brocorat",
		  iid = "e2567b60-d380-11f0-a276-63562531dd93",
		  layer = "Enemies",
		  x = 68,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 14120515,
		  customFields = {
			speed = 0.5,
			dead = false
		  }
		}
	  },
	  Minifier = {
		{
		  id = "Minifier",
		  iid = "e2facc00-d380-11f0-88fd-e7a9eaa6c333",
		  layer = "Props",
		  x = 204,
		  y = 84,
		  width = 32,
		  height = 32,
		  color = 2943221,
		  customFields = {
			type = "minifier",
			nocollider = false,
			destroyed = false
		  }
		}
	  },
	  Slime = {
		{
		  id = "Slime",
		  iid = "e6685470-d380-11f0-88fd-db34493a7ee9",
		  layer = "Props",
		  x = 244,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 1578021,
		  customFields = {
			type = "slime",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Slime",
		  iid = "e6c8c3f0-d380-11f0-88fd-47079a9a0ad5",
		  layer = "Props",
		  x = 212,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 1578021,
		  customFields = {
			type = "slime",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Slime",
		  iid = "e810d450-d380-11f0-88fd-5f030745d488",
		  layer = "Props",
		  x = 180,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 1578021,
		  customFields = {
			type = "slime",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Slime",
		  iid = "e8f58f00-d380-11f0-88fd-3115f5984c86",
		  layer = "Props",
		  x = 148,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 1578021,
		  customFields = {
			type = "slime",
			nocollider = false,
			destroyed = false
		  }
		}
	  }
	}
  },
		--
		--
{
	identifier = "Room_1",
	uniqueIdentifer = "69eb2d80-ac70-11f0-989f-95306126bd74",
	x = 0,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_2",
	uniqueIdentifer = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
	x = 400,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "BGTilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "b3283eb0-ac70-11f0-8539-f3c8ed5b1669",
		  layer = "Doors",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "b620e540-ac70-11f0-8539-71a575f15bb9",
		  layer = "Doors",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
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
		  layer = "Triggers",
		  x = 172,
		  y = 100,
		  width = 40,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "giftFor100",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "0f48b230-ac70-11f0-ae64-49bfdc9ab6ce",
		  layer = "Triggers",
		  x = 220,
		  y = 92,
		  width = 40,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "giftFor233",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "7d672b30-ac70-11f0-ae64-79d729daa857",
		  layer = "Triggers",
		  x = 308,
		  y = 180,
		  width = 88,
		  height = 88,
		  color = 16711748,
		  customFields = {
			script = "entranceMess",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "54d22370-d380-11f0-88fd-914d0158f881",
		  layer = "Triggers",
		  x = 196,
		  y = 140,
		  width = 24,
		  height = 24,
		  color = 16711748,
		  customFields = {
			script = "myGift",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		}
	  },
	  ItemGift = {
		{
		  id = "ItemGift",
		  iid = "ab0e6080-d380-11f0-88fd-23cdcf2dde52",
		  layer = "Items",
		  x = 196,
		  y = 140,
		  width = 32,
		  height = 32,
		  color = 15389866,
		  customFields = {
			type = "itemGift",
			grants = "hasDWatch:true"
		  }
		}
	  },
	  Xtree1 = {
		{
		  id = "Xtree1",
		  iid = "0b24fca0-ac70-11f0-985a-61d94463d05b",
		  layer = "Props",
		  x = 164,
		  y = 44,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 196,
		  y = 44,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 164,
		  y = 76,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 196,
		  y = 76,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 140,
		  y = 84,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "gifts",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Gifts",
		  iid = "1693c670-ac70-11f0-985a-51430b780b06",
		  layer = "Props",
		  x = 220,
		  y = 92,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 172,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 108,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "2929ec60-ac70-11f0-985a-4126f85ddd1f",
		  layer = "Props",
		  x = 252,
		  y = 84,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 84,
		  y = 52,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "2f6c18a0-ac70-11f0-985a-a1f4b58b53d7",
		  layer = "Props",
		  x = 300,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "31637bd0-ac70-11f0-985a-7b97c4a1ea96",
		  layer = "Props",
		  x = 140,
		  y = 132,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 36,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "table",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Table",
		  iid = "487d5520-ac70-11f0-985a-cd8cc298fdae",
		  layer = "Props",
		  x = 356,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "table",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Table",
		  iid = "6d93cec0-ac70-11f0-ae64-1be5800770cc",
		  layer = "Props",
		  x = 300,
		  y = 172,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 324,
		  y = 92,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4c9c0520-ac70-11f0-985a-e99f3d0bf46f",
		  layer = "Props",
		  x = 36,
		  y = 180,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4db452f0-ac70-11f0-985a-cfe8262e92fe",
		  layer = "Props",
		  x = 364,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "4fdbc6d0-ac70-11f0-985a-a5601f3ccd47",
		  layer = "Props",
		  x = 92,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "6ed6af00-ac70-11f0-ae64-f7bb28f9916d",
		  layer = "Props",
		  x = 340,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 316,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "53f63110-ac70-11f0-985a-d350bb30470b",
		  layer = "Props",
		  x = 348,
		  y = 164,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "54ba1d50-ac70-11f0-985a-27fb7aa5ea82",
		  layer = "Props",
		  x = 252,
		  y = 188,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "722d2d00-ac70-11f0-ae64-d9f2ef5111fe",
		  layer = "Props",
		  x = 324,
		  y = 164,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 364,
		  y = 164,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "chair"
		  }
		}
	  }
	}
  },
{
	identifier = "Room_3",
	uniqueIdentifer = "bf654080-ac70-11f0-997a-e578ba2da2ac",
	x = 800,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "BGTilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "bb73a870-ac70-11f0-8539-03f7dfb4cdc8",
		  layer = "Doors",
		  x = 8,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Left",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "bf724d50-ac70-11f0-8539-137cb38eca29",
		  layer = "Doors",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "e1699320-d380-11f0-a276-052d46aa38e7",
		  layer = "Doors",
		  x = 344,
		  y = 236,
		  width = 16,
		  height = 8,
		  color = 7552569,
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
		  layer = "Triggers",
		  x = 100,
		  y = 60,
		  width = 56,
		  height = 32,
		  color = 16711748,
		  customFields = {
			script = "microwaveBurn",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "f2317670-ac70-11f0-ae64-133829c2c353",
		  layer = "Triggers",
		  x = 244,
		  y = 108,
		  width = 32,
		  height = 32,
		  color = 16711748,
		  customFields = {
			script = "kitchenWeapons",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = "tinyKnife",
			conditionalScripts = {
			  "isBig:kitchenWeapons",
			  "isTiny:tinyKnife"
			}
		  }
		},
		{
		  id = "Triggers",
		  iid = "3a47bf50-ac70-11f0-ae64-474c236a6fd7",
		  layer = "Triggers",
		  x = 332,
		  y = 100,
		  width = 56,
		  height = 48,
		  color = 16711748,
		  customFields = {
			script = "inneficientCutting",
			usedTrigger = false,
			type = "Story",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "a059dac0-ac70-11f0-ae64-f1ee9dff56d1",
		  layer = "Triggers",
		  x = 44,
		  y = 196,
		  width = 48,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "justBoxes",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		},
		{
		  id = "Triggers",
		  iid = "26163fe0-ac70-11f0-8398-53067febe16c",
		  layer = "Triggers",
		  x = 196,
		  y = 204,
		  width = 96,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "notnormalBrocoli",
			usedTrigger = false,
			type = "Search",
			mapPercent = 0,
			tinyScript = nil,
			conditionalScripts = {}
		  }
		}
	  },
	  Plunger = {
		{
		  id = "Plunger",
		  iid = "6c594530-d380-11f0-88fd-99e8bcab21ec",
		  layer = "Items",
		  x = 324,
		  y = 156,
		  width = 32,
		  height = 32,
		  color = 15389866,
		  customFields = {
			type = "plunger"
		  }
		}
	  },
	  FellTable = {
		{
		  id = "FellTable",
		  iid = "bf46c0e0-ac70-11f0-ae64-597ec6fe672b",
		  layer = "Props",
		  x = 36,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "ffc9fb50-d380-11f0-a276-0f85237af89c",
		  layer = "Props",
		  x = 276,
		  y = 164,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 68,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "01ef6b90-ac70-11f0-ae64-292bbea86898",
		  layer = "Props",
		  x = 324,
		  y = 132,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0601e690-ac70-11f0-ae64-8778a1292c62",
		  layer = "Props",
		  x = 348,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0ed1c290-ac70-11f0-ae64-95329b483a8a",
		  layer = "Props",
		  x = 268,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "0e256780-ac70-11f0-8398-fb5fdad9133f",
		  layer = "Props",
		  x = 196,
		  y = 212,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 100,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 332,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 292,
		  y = 84,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "12214d40-ac70-11f0-8398-31a430f47a22",
		  layer = "Props",
		  x = 228,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "1975acd0-ac70-11f0-8398-9b842ef570b6",
		  layer = "Props",
		  x = 164,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood2",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "1f4d3060-ac70-11f0-8398-2ff5d145c0a9",
		  layer = "Props",
		  x = 204,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 244,
		  y = 108,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 44,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 188,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 188,
		  y = 36,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 156,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d0f28ea0-d380-11f0-a276-170abcc70553",
		  layer = "Props",
		  x = 276,
		  y = 188,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d4288c50-d380-11f0-a276-9bdf43235b7f",
		  layer = "Props",
		  x = 276,
		  y = 124,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d53679e0-d380-11f0-a276-8f2b37a9f3ee",
		  layer = "Props",
		  x = 284,
		  y = 212,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "d78991a0-d380-11f0-a276-f7b032b235ae",
		  layer = "Props",
		  x = 372,
		  y = 172,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 220,
		  y = 60,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "421f6180-ac70-11f0-8398-3187f4a538f2",
		  layer = "Props",
		  x = 316,
		  y = 52,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "f90bc140-d380-11f0-a276-d3e851faf0a1",
		  layer = "Props",
		  x = 276,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		}
	  }
	}
  },
		--
		--
{
	identifier = "Room_4",
	uniqueIdentifer = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
	x = 1200,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_5",
	uniqueIdentifer = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
	x = 1600,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_6",
	uniqueIdentifer = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
	x = 0,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {
	  Keys = {
		{
		  id = "Keys",
		  iid = "1359cb50-ac70-11f0-8539-fd8ed64a41e9",
		  layer = "Keys",
		  x = 312,
		  y = 152,
		  width = 48,
		  height = 48,
		  color = 4073265,
		  customFields = {
			keyNumber = 1
		  }
		}
	  },
	  Doors = {
		{
		  id = "Doors",
		  iid = "e79962a0-ac70-11f0-8539-4594309692bf",
		  layer = "Doors",
		  x = 200,
		  y = 232,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Down",
			KeyNumber = nil
		  }
		}
	  },
	  PlayerSpawnPoints = {
		{
		  id = "PlayerSpawnPoints",
		  iid = "f6878e90-ac70-11f0-aeab-2b25e5ea9b40",
		  layer = "PSpawnPoints",
		  x = 196,
		  y = 196,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		},
		{
		  id = "PlayerSpawnPoints",
		  iid = "fad257a0-ac70-11f0-aeab-1964bd033c45",
		  layer = "PSpawnPoints",
		  x = 196,
		  y = 32,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		}
	  },
	  HoleTop = {
		{
		  id = "HoleTop",
		  iid = "a2dada30-ac70-11f0-aeab-fdd199a31095",
		  layer = "Holes",
		  x = 188,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a3e8a0b0-ac70-11f0-aeab-237958cd4eb9",
		  layer = "Holes",
		  x = 220,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a568ff20-ac70-11f0-aeab-c5fcba3999fe",
		  layer = "Holes",
		  x = 156,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "a7cb5920-ac70-11f0-aeab-a780b82da70f",
		  layer = "Holes",
		  x = 124,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "aee017a0-ac70-11f0-aeab-ffa59df36d35",
		  layer = "Holes",
		  x = 92,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d345b820-ac70-11f0-aeab-ffedc793cee1",
		  layer = "Holes",
		  x = 252,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d3d68670-ac70-11f0-aeab-4dbd9e992dd4",
		  layer = "Holes",
		  x = 284,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "d4a71ce0-ac70-11f0-aeab-81743c8a812b",
		  layer = "Holes",
		  x = 316,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeTop",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleTop",
		  iid = "de04e100-ac70-11f0-aeab-2d997a966a55",
		  layer = "Holes",
		  x = 348,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Holes",
		  x = 60,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Holes",
		  x = 380,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Holes",
		  x = 92,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e6225cf0-ac70-11f0-aeab-99f2faa74e15",
		  layer = "Holes",
		  x = 124,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e6eb7950-ac70-11f0-aeab-55a9edb21eff",
		  layer = "Holes",
		  x = 156,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e83de9f0-ac70-11f0-aeab-7b6e5db28835",
		  layer = "Holes",
		  x = 188,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "e9133b50-ac70-11f0-aeab-457539c30082",
		  layer = "Holes",
		  x = 220,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ea3f8650-ac70-11f0-aeab-b91d3c4f855f",
		  layer = "Holes",
		  x = 252,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "eb246810-ac70-11f0-aeab-a384f29f36dd",
		  layer = "Holes",
		  x = 284,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ec0181a0-ac70-11f0-aeab-3d6ccc7137bf",
		  layer = "Holes",
		  x = 316,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottom",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "HoleBottom",
		  iid = "ecf09c90-ac70-11f0-aeab-b1cd9ef03272",
		  layer = "Holes",
		  x = 348,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Holes",
		  x = 380,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Holes",
		  x = 60,
		  y = 100,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "holeBottomLeft",
			nocollider = false,
			destroyed = false
		  }
		}
	  }
	}
  },
{
	identifier = "Room_7",
	uniqueIdentifer = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
	x = 400,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "ad890930-ac70-11f0-8539-b927b406cff9",
		  layer = "Doors",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  },
	  PlayerSpawnPoints = {
		{
		  id = "PlayerSpawnPoints",
		  iid = "1787d970-ac70-11f0-aeab-f7cfec58e37c",
		  layer = "PSpawnPoints",
		  x = 200,
		  y = 32,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		},
		{
		  id = "PlayerSpawnPoints",
		  iid = "1e8ae4b0-ac70-11f0-aeab-2d9248a855b7",
		  layer = "PSpawnPoints",
		  x = 196,
		  y = 196,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		}
	  },
	  Triggers = {
		{
		  id = "Triggers",
		  iid = "c7870a30-ac70-11f0-998c-2944db77c3b4",
		  layer = "Triggers",
		  x = 204,
		  y = 132,
		  width = 88,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "wakeup",
			usedTrigger = false,
			type = "Story",
		  }
		},
		{
		  id = "Triggers",
		  iid = "cc4b57d0-ac70-11f0-ae64-f1a43cc2526b",
		  layer = "Triggers",
		  x = 292,
		  y = 140,
		  width = 40,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "someTrash",
			usedTrigger = false,
			type = "Search"
		  }
		},
		{
		  id = "Triggers",
		  iid = "04397810-ac70-11f0-ae64-891aa0cc0d18",
		  layer = "Triggers",
		  x = 36,
		  y = 140,
		  width = 48,
		  height = 40,
		  color = 16711748,
		  customFields = {
			script = "justBoxes",
			usedTrigger = false,
			type = "Search"
		  }
		}
	  },
	  Smalltable = {
		{
		  id = "Smalltable",
		  iid = "76ab7410-ac70-11f0-998c-33dc7dd62999",
		  layer = "Props",
		  x = 252,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7828ec50-ac70-11f0-998c-e578b281f438",
		  layer = "Props",
		  x = 148,
		  y = 204,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7c36d370-ac70-11f0-998c-27835b3ae957",
		  layer = "Props",
		  x = 148,
		  y = 188,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "7e6b3fa0-ac70-11f0-998c-83ad0a5e8378",
		  layer = "Props",
		  x = 252,
		  y = 188,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "smallTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Smalltable",
		  iid = "a99b3a10-ac70-11f0-ae64-bbea47082fb4",
		  layer = "Props",
		  x = 36,
		  y = 44,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 156,
		  y = 172,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "87335370-ac70-11f0-998c-972d0c2d0afa",
		  layer = "Props",
		  x = 244,
		  y = 164,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "fellTable",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "FellTable",
		  iid = "9a8dc5b0-ac70-11f0-ae64-330b96106ce8",
		  layer = "Props",
		  x = 92,
		  y = 44,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 164,
		  y = 148,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "trash"
		  }
		},
		{
		  id = "Trash",
		  iid = "91764770-ac70-11f0-998c-ab2da21d72a7",
		  layer = "Props",
		  x = 292,
		  y = 140,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 52,
		  y = 196,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "9d6f61d0-ac70-11f0-ae64-e33789cc7e0e",
		  layer = "Props",
		  x = 76,
		  y = 76,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood",
			nocollider = true,
			destroyed = false
		  }
		},
		{
		  id = "Blood",
		  iid = "f186f080-ac70-11f0-ae64-a96276b15936",
		  layer = "Props",
		  x = 148,
		  y = 76,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 356,
		  y = 188,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "blood2",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "Blood2",
		  iid = "ee1103a0-ac70-11f0-ae64-453fe6771b29",
		  layer = "Props",
		  x = 260,
		  y = 68,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 252,
		  y = 28,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "a3bffb10-ac70-11f0-998c-2bdf4a768139",
		  layer = "Props",
		  x = 284,
		  y = 28,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			type = "kitchenStorage",
			nocollider = false,
			destroyed = false
		  }
		},
		{
		  id = "KitchenStorage",
		  iid = "a474f330-ac70-11f0-998c-efbe99831fb3",
		  layer = "Props",
		  x = 316,
		  y = 28,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 36,
		  y = 140,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "box"
		  }
		},
		{
		  id = "Box",
		  iid = "aa01bcb0-ac70-11f0-998c-dffc56ebfc22",
		  layer = "Props",
		  x = 364,
		  y = 132,
		  width = 32,
		  height = 32,
		  color = 12470831,
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
		  layer = "Props",
		  x = 164,
		  y = 36,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		},
		{
		  id = "Fellchair",
		  iid = "1022f000-ac70-11f0-985a-9b3988f2af57",
		  layer = "Props",
		  x = 364,
		  y = 28,
		  width = 32,
		  height = 32,
		  color = 12470831,
		  customFields = {
			nocollider = false,
			destroyed = false,
			type = "fellchair"
		  }
		}
	  }
	}
  },

{
	identifier = "Room_9",
	uniqueIdentifer = "dab87dc0-ac70-11f0-997a-63497867517d",
	x = 1200,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_10",
	uniqueIdentifer = "672c4d40-ac70-11f0-997a-7b0342bedabe",
	x = 1600,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_11",
	uniqueIdentifer = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
	x = 0,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "df62b960-ac70-11f0-8539-17b12cc94289",
		  layer = "Doors",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "e3337070-ac70-11f0-8539-313aa2731b22",
		  layer = "Doors",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		}
	  },
	  PlayerSpawnPoints = {
		{
		  id = "PlayerSpawnPoints",
		  iid = "df680ff0-ac70-11f0-aeab-afd2a2cd2c79",
		  layer = "PSpawnPoints",
		  x = 364,
		  y = 116,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		},
		{
		  id = "PlayerSpawnPoints",
		  iid = "e5e410e0-ac70-11f0-aeab-eb6302c04c6f",
		  layer = "PSpawnPoints",
		  x = 196,
		  y = 32,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		}
	  }
	}
  },
{
	identifier = "Room_12",
	uniqueIdentifer = "6cc9d510-ac70-11f0-997a-191299f9209c",
	x = 400,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
		"Right"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "c6e3d930-ac70-11f0-8539-e78eb22c7faf",
		  layer = "Doors",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "d4659d20-ac70-11f0-8539-cfb033de52d4",
		  layer = "Doors",
		  x = 8,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Left",
			KeyNumber = nil
		  }
		}
	  },
	  PlayerSpawnPoints = {
		{
		  id = "PlayerSpawnPoints",
		  iid = "d3cd7b30-ac70-11f0-aeab-5594f181cfe1",
		  layer = "PSpawnPoints",
		  x = 364,
		  y = 116,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		},
		{
		  id = "PlayerSpawnPoints",
		  iid = "d980d4f0-ac70-11f0-aeab-29e22f526775",
		  layer = "PSpawnPoints",
		  x = 34,
		  y = 116,
		  width = 48,
		  height = 48,
		  color = 16705377,
		  customFields = {}
		}
	  }
	}
  },
{
	identifier = "Room_13",
	uniqueIdentifer = "715b4410-ac70-11f0-997a-156adb22b715",
	x = 800,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	  light = 0,
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
	layers = {
	  "BGTilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "e35e4010-ac70-11f0-8539-cfa071292c9d",
		  layer = "Doors",
		  x = 8,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Left",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "f2cac460-ac70-11f0-8539-f32c05a0c6fe",
		  layer = "Doors",
		  x = 200,
		  y = 8,
		  width = 48,
		  height = 16,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Top",
			KeyNumber = nil
		  }
		},
		{
		  id = "Doors",
		  iid = "f5938150-ac70-11f0-8539-2555dd027d3e",
		  layer = "Doors",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = true,
			DoorsConnection = "Right",
			KeyNumber = 1
		  }
		}
	  },
	  CrewMember = {
		{
		  id = "CrewMember",
		  iid = "8d8b4e70-d380-11f0-88fd-ff6f09b90ad9",
		  layer = "CrewMembers",
		  x = 124,
		  y = 76,
		  width = 48,
		  height = 48,
		  color = 14984818,
		  customFields = {
			isTaken = false,
			crewID = "CM002"
		  }
		}
	  }
	}
  },
{
	identifier = "Room_14",
	uniqueIdentifer = "6de95960-ac70-11f0-998c-e3108c5f25c9",
	x = 1200,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
		"Left",
		"Right"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {
	  Doors = {
		{
		  id = "Doors",
		  iid = "e9b65690-ac70-11f0-8539-3392c72a1b66",
		  layer = "Doors",
		  x = 8,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = true,
			DoorsConnection = "Left",
			KeyNumber = 1
		  }
		},
		{
		  id = "Doors",
		  iid = "07f5afe0-ac70-11f0-8539-1df82db73e07",
		  layer = "Doors",
		  x = 392,
		  y = 120,
		  width = 16,
		  height = 48,
		  color = 7552569,
		  customFields = {
			NeedsKey = false,
			DoorsConnection = "Right",
			KeyNumber = nil
		  }
		}
	  }
	}
  },
{
	identifier = "Room_15",
	uniqueIdentifer = "708f7320-ac70-11f0-998c-737ddc0c343a",
	x = 1600,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_16",
	uniqueIdentifer = "ae5a31c0-ac70-11f0-9560-a1abd660ccf1",
	x = 0,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74",
		dir = ">"
	  },
	  {
		levelIid = "0c0281e0-ac70-11f0-998c-95fd1ad330a3",
		dir = "<"
	  },
	  {
		levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
		dir = "e"
	  },
	  {
		levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
		dir = "s"
	  },
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "se"
	  }
	},
	customFields = {
	  shadow = true,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 16,
	  tile = 16,
	  DoorsConnection = {},
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_17",
	uniqueIdentifer = "abdd36b0-ac70-11f0-998c-673887a050e6",
	x = 400,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "bab17c70-ac70-11f0-997a-85b3d3c5d229",
		dir = ">"
	  },
	  {
		levelIid = "10505830-ac70-11f0-998c-55d8b4b4f879",
		dir = "<"
	  },
	  {
		levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
		dir = "e"
	  },
	  {
		levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
		dir = "sw"
	  },
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "s"
	  },
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "se"
	  },
	  {
		levelIid = "ae5a31c0-ac70-11f0-9560-a1abd660ccf1",
		dir = "w"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 17,
	  tile = 17,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_18",
	uniqueIdentifer = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
	x = 800,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac",
		dir = ">"
	  },
	  {
		levelIid = "12995dd0-ac70-11f0-998c-1b8631dc4502",
		dir = "<"
	  },
	  {
		levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
		dir = "w"
	  },
	  {
		levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
		dir = "e"
	  },
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "sw"
	  },
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "s"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
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
	  roomNumber = 18,
	  tile = 18,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_19",
	uniqueIdentifer = "310fc980-ac70-11f0-998c-05b91a46387d",
	x = 1200,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "c118e3f0-ac70-11f0-997a-a35ec59b96eb",
		dir = ">"
	  },
	  {
		levelIid = "156e76d0-ac70-11f0-998c-096a39368923",
		dir = "<"
	  },
	  {
		levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
		dir = "w"
	  },
	  {
		levelIid = "35082cd0-ac70-11f0-998c-d16d78429f5c",
		dir = "e"
	  },
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "sw"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "s"
	  },
	  {
		levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
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
	  roomNumber = 19,
	  tile = 19,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_20",
	uniqueIdentifer = "35082cd0-ac70-11f0-998c-d16d78429f5c",
	x = 1600,
	y = 0,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "c2b4e0b0-ac70-11f0-997a-09fdc7fc6323",
		dir = ">"
	  },
	  {
		levelIid = "18297820-ac70-11f0-998c-93854477c827",
		dir = "<"
	  },
	  {
		levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
		dir = "w"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "sw"
	  },
	  {
		levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
		dir = "s"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 20,
	  tile = 20,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_21",
	uniqueIdentifer = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
	x = 0,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf",
		dir = ">"
	  },
	  {
		levelIid = "2139b880-ac70-11f0-998c-f5d424530b7f",
		dir = "<"
	  },
	  {
		levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
		dir = "ne"
	  },
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "e"
	  },
	  {
		levelIid = "46b2e150-ac70-11f0-998c-232538b976f9",
		dir = "s"
	  },
	  {
		levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
		dir = "se"
	  },
	  {
		levelIid = "ae5a31c0-ac70-11f0-9560-a1abd660ccf1",
		dir = "n"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 21,
	  tile = 21,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_22",
	uniqueIdentifer = "3b081ff0-ac70-11f0-998c-67e6b510262c",
	x = 400,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed",
		dir = ">"
	  },
	  {
		levelIid = "23b93777-ac70-11f0-998c-8fe9cae02b21",
		dir = "<"
	  },
	  {
		levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6",
		dir = "n"
	  },
	  {
		levelIid = "2dc4bd30-ac70-11f0-998c-2ba6c3750080",
		dir = "ne"
	  },
	  {
		levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
		dir = "w"
	  },
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "e"
	  },
	  {
		levelIid = "46b2e150-ac70-11f0-998c-232538b976f9",
		dir = "sw"
	  },
	  {
		levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
		dir = "s"
	  },
	  {
		levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
		dir = "se"
	  },
	  {
		levelIid = "ae5a31c0-ac70-11f0-9560-a1abd660ccf1",
		dir = "nw"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 22,
	  tile = 22,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_23",
	uniqueIdentifer = "3d752854-ac70-11f0-998c-5dddbfac239d",
	x = 800,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_24",
	uniqueIdentifer = "40386700-ac70-11f0-998c-e53e1b32800c",
	x = 1200,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_25",
	uniqueIdentifer = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
	x = 1600,
	y = 240,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "2ccecf00-ac70-11f0-998c-cf1ba2f9a183",
		dir = "<"
	  },
	  {
		levelIid = "672c4d40-ac70-11f0-997a-7b0342bedabe",
		dir = ">"
	  },
	  {
		levelIid = "310fc980-ac70-11f0-998c-05b91a46387d",
		dir = "nw"
	  },
	  {
		levelIid = "35082cd0-ac70-11f0-998c-d16d78429f5c",
		dir = "n"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "w"
	  },
	  {
		levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
		dir = "sw"
	  },
	  {
		levelIid = "53674a87-ac70-11f0-998c-83aa3940da82",
		dir = "s"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 25,
	  tile = 25,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_26",
	uniqueIdentifer = "46b2e150-ac70-11f0-998c-232538b976f9",
	x = 0,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "be6fd850-ac70-11f0-998c-4f44b96a410c",
		dir = "<"
	  },
	  {
		levelIid = "68b425c0-ac70-11f0-997a-7732cd72a5cc",
		dir = ">"
	  },
	  {
		levelIid = "37dad4d0-ac70-11f0-998c-e3c63970ecdd",
		dir = "n"
	  },
	  {
		levelIid = "3b081ff0-ac70-11f0-998c-67e6b510262c",
		dir = "ne"
	  },
	  {
		levelIid = "4a0bd050-ac70-11f0-998c-b14d359446e6",
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
	  roomNumber = 26,
	  tile = 26,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_27",
	uniqueIdentifer = "4a0bd050-ac70-11f0-998c-b14d359446e6",
	x = 400,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	  shadow = false,
	  light = 0,
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_28",
	uniqueIdentifer = "4cf534a4-ac70-11f0-998c-6712312c62dc",
	x = 800,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
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
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_29",
	uniqueIdentifer = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
	x = 1200,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "c60e1220-ac70-11f0-998c-cbe47e589876",
		dir = "<"
	  },
	  {
		levelIid = "6de95960-ac70-11f0-998c-e3108c5f25c9",
		dir = ">"
	  },
	  {
		levelIid = "3d752854-ac70-11f0-998c-5dddbfac239d",
		dir = "nw"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "n"
	  },
	  {
		levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
		dir = "ne"
	  },
	  {
		levelIid = "4cf534a4-ac70-11f0-998c-6712312c62dc",
		dir = "w"
	  },
	  {
		levelIid = "53674a87-ac70-11f0-998c-83aa3940da82",
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
	  roomNumber = 29,
	  tile = 29,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  },
{
	identifier = "Room_30",
	uniqueIdentifer = "53674a87-ac70-11f0-998c-83aa3940da82",
	x = 1600,
	y = 480,
	width = 400,
	height = 240,
	bgColor = "#696A79",
	neighbourLevels = {
	  {
		levelIid = "d138f520-ac70-11f0-998c-e18e7b9af98b",
		dir = "<"
	  },
	  {
		levelIid = "708f7320-ac70-11f0-998c-737ddc0c343a",
		dir = ">"
	  },
	  {
		levelIid = "40386700-ac70-11f0-998c-e53e1b32800c",
		dir = "nw"
	  },
	  {
		levelIid = "43980cc0-ac70-11f0-998c-a70f320b4eb0",
		dir = "n"
	  },
	  {
		levelIid = "50a125a0-ac70-11f0-998c-f3b70b95a9ac",
		dir = "w"
	  }
	},
	customFields = {
	  shadow = false,
	  light = 0,
	  visited = false,
	  comic_name = nil,
	  comic_wasPlayed = false,
	  level = 3,
	  roomNumber = 30,
	  tile = 30,
	  DoorsConnection = {
		"Top"
	  },
	  play = nil
	},
	layers = {
	  "Tilemap.png"
	},
	entities = {}
  }
		--
}