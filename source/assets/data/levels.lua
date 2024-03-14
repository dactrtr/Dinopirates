levels = {
	{
		floor = {
			level = 1,
			visited = false,
			floorNumber = 1,
			tile = 1,
			light = 0.1,
			shadow = false,
			triggers = {
				-- {
				-- 	usedTrigger = false,
				-- 	x = 170,
				-- 	y = 150,
				-- 	width = 60,
				-- 	height = 30,
				-- 	script = 2
				-- },
				-- {
				-- 	usedTrigger = false,
				-- 	x = 220,
				-- 	y = 100,
				-- 	width = 60,
				-- 	height = 30,
				-- 	script = 3
				-- },
				-- {
				-- 	usedTrigger = false,
				-- 	x = 200,
				-- 	y = 55,
				-- 	width = 60,
				-- 	height = 30,
				-- 	script = 4
				-- },
			},
			enemies = {
				-- {
				-- 	name = "brocorat",
				-- 	x = 280,
				-- 	y = 160,
				-- 	speed = 0.7
				-- },
				-- {
				-- 	name = "frogcolli",
				-- 	x = 200,
				-- 	y = 120,
				-- 	speed = 3
				-- },
				-- {
				-- 	name = "frogcolli",
				-- 	x = 200,
				-- 	y = 40,
				-- 	speed = 3
				-- }
			
			},
			doors = {
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor06,
				}
			},
			items = {
				{
					type = 'radio',
					x = 230,
					y = 80
				}
			},
			props = {
				{
					type = 'chair',
					x = 140,
					y = 200,
				},
				{
					type = 'chair',
					x = 160,
					y = 160
				},
				{
					type = 'fellchair',
					x = 232,
					y = 192
				},
				{
					type = 'chair',
					x = 170,
					y = 120
				},
				{
					type = 'chair',
					x = 210,
					y = 124
				},
				{
					type = 'chair',
					x = 275,
					y = 170
				},
				{
					type = 'fellchair',
					x = 280,
					y = 124
				},
				{
					type = 'chair',
					x = 300,
					y = 20
				},
				{
					type = 'fellchair',
					x = 60,
					y = 35
				},
				{
					type = 'chair',
					x = 60,
					y = 135
				},
				{
					type = 'chair',
					x = 90,
					y = 210
				},
				{
					type = 'table',
					x = 360,
					y = 210
				},
				{
					type = 'table',
					x = 95,
					y = 30
				},
				{
					type = 'table',
					x = 145,
					y = 60
				},
			}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 2,
			light = 0.4,
			shadow = false,
			triggers = {
				{
					usedTrigger = false,
					x = 180,
					y = 165,
					width = 40,
					height = 10,
					script = 5
				},
				
			},
			enemies = {
				-- {
				-- 	name = "brocorat",
				-- 	x = 280,
				-- 	y = 160,
				-- 	speed = 0.7
				-- },
				-- {
				-- 	name = "frogcolli",
				-- 	x = 200,
				-- 	y = 120,
				-- 	speed = 3
				-- },
				-- {
				-- 	name = "frogcolli",
				-- 	x = 200,
				-- 	y = 40,
				-- 	speed = 3
				-- }
			
			},
			doors = {
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor07,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = Floor03,
				},
			},
			items = {
				-- {
				-- 	type = 'keycard',
				-- 	x = 50,
				-- 	y = 100
				-- }
			},
			props = {
				{
					type = 'blood',
					x = 80,
					y = 150,
					nocollide = true
				},
				{
					type = 'blood2',
					x = 160,
					y = 50,
					nocollide = true
				},
				{
					type = 'blood2',
					x = 90,
					y = 140,
					nocollide = true
				},
				{
					type = 'blood',
					x = 140,
					y = 40,
					nocollide = true
				}
			}
		}
	},
	-- repeat
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 3,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'left',
					open = 'open',
					leadsTo = Floor02,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor08,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 4,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'right',
					open = 'open',
					leadsTo = Floor05,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor09,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 5,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {{
					direction = 'left',
					open = 'open',
					leadsTo = Floor04,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor10,
				},},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 6,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor01,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor11,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 7,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor02,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 8,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor03,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor13,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 9,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor04,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor14,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 10,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor05,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = Floor15,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 11,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'right',
					open = 'open',
					leadsTo = Floor12,
				},
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor06,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 12,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'left',
					open = 'open',
					leadsTo = Floor11,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = Floor13,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 13,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor08,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = Floor14,
				},
				{
					direction = 'left',
					open = 'open',
					leadsTo = Floor12,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 14,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'left',
					open = 'open',
					leadsTo = Floor13,
				},
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor09,
				},
			},
			items = {},
			props = {}
		}
	},
	{
		floor = {
			level = 1,
			visited = false,
			tile = 2,
			floorNumber = 15,
			light = 0.4,
			shadow = false,
			enemies = {},
			triggers = {},
			doors = {
				{
					direction = 'top',
					open = 'open',
					leadsTo = Floor10,
				},
			},
			items = {},
			props = {}
		}
	},
}