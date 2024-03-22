levels = {
	{
		floor = {
			level = 1,
			visited = false,
			floorNumber = 1,
			tile = 2,
			light = 0.1,
			shadow = false,
			triggers = {
				{
					usedTrigger = false,
					x = 170,
					y = 150,
					width = 60,
					height = 30,
					script = 2
				},
				{
					usedTrigger = false,
					x = 220,
					y = 100,
					width = 60,
					height = 30,
					script = 3
				},
				{
					usedTrigger = false,
					x = 200,
					y = 55,
					width = 60,
					height = 30,
					script = 4
				},
			},
			enemies = {
			-- 	{
			-- 		name = "brocorat",
			-- 		x = 280,
			-- 		y = 160,
			-- 		speed = 0.7
			-- 	},
			-- 	{
			-- 		name = "frogcolli",
			-- 		x = 200,
			-- 		y = 120,
			-- 		speed = 3
			-- 	},
			-- 	{
			-- 		name = "frogcolli",
			-- 		x = 200,
			-- 		y = 40,
			-- 		speed = 3
			-- 	}
			-- 
			},
			doors = {
				{
					direction = 'down',
					open = 'open',
					leadsTo = 106,
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
				{
					name = "brocorat",
					x = 280,
					y = 160,
					speed = 0.7
				},
				{
					name = "frogcolli",
					x = 200,
					y = 120,
					speed = 3
				},
				
			
			},
			doors = {
				{
					direction = 'down',
					open = 'open',
					leadsTo = 107,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = 103,
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
					leadsTo = 102,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 108,
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
					leadsTo = 105,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 109,
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
					leadsTo = 104,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 110,
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
					leadsTo = 101,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 111,
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
					leadsTo = 102,
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
					leadsTo = 103,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 113,
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
					leadsTo = 104,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 114,
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
					leadsTo = 105,
				},
				{
					direction = 'down',
					open = 'open',
					leadsTo = 115,
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
					leadsTo = 112,
				},
				{
					direction = 'top',
					open = 'open',
					leadsTo = 106,
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
					leadsTo = 111,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = 113,
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
					leadsTo = 108,
				},
				{
					direction = 'right',
					open = 'open',
					leadsTo = 114,
				},
				{
					direction = 'left',
					open = 'open',
					leadsTo = 112,
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
					leadsTo = 113,
				},
				{
					direction = 'top',
					open = 'open',
					leadsTo = 109,
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
					leadsTo = 110,
				},
			},
			items = {},
			props = {}
		}
	},
}