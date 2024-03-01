import 'libraries/noble/Noble'

import 'utilities/Utilities'
import 'scenes/DeadScene'
import 'scenes/MazeScene'
import 'scenes/Floors'
--import 'scenes/StarScene'
import 'scenes/TestScene'
import 'scenes/TitleScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.showFPS = true

Noble.GameData.setup({
	Score = 0,
})
-- Mark: This should be a separate file(JSON)

PlayerData = {
	battery = 100, 
	sanity = 100,
	hasKey = false,
	hasLamp = false,
	hasRadio = false,
	sonarActive = false,
	isActive = false,
	isTalking = false,
	floor = 1,
	room = 1,
	lastRoom = nil,
	playerSpawn ={
		x = 200,
		y = 200,
	}
}
rooms = {
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false },
	{ visited = false }
}
ZIndex = {
	player = 4,
	enemy = 3,
	props = 3,
	fx = 6,
	ui = 10,
	alert = 12
}
CollideGroups = {
	player = 1,
	enemy = 2,
	props = 3,
	items = 4,
	wall = 5
}
levels = {
	{
		floor = {
			tile = 2,
			floorNumber = 7,
			light = 0.1,
			debug = false,
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
					direction = 'top',
					open = 'open',
					leadsTo = Floor02,
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
					y = 200
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
			}
		}
	},
	{
		floor = {
			tile = 2,
			floorNumber = 4,
			light = 0.1,
			debug = false,
			shadow = true,
			triggers = {
				-- {
				-- 	usedTrigger = false,
				-- 	x = 20,
				-- 	y = 20,
				-- 	width = 30,
				-- 	height = 30,
				-- 	script = 2
				-- },
				-- {
				-- 	usedTrigger = false,
				-- 	x = 120,
				-- 	y = 120,
				-- 	width = 30,
				-- 	height = 30,
				-- 	script = 3
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
					leadsTo = Floor01,
				}
			},
			items = {
				{
					type = 'keycard',
					x = 50,
					y = 100
				}
			},
			props = {
				{
					type = 'chair',
					x = 80,
					y = 150
				},
				{
					type = 'toxic',
					x = 160,
					y = 50
				}
			}
		}
	},
	-- repeat
}
script = {
	{
		-- no door key 1
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("door", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("door2", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("door3", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("door4", "en")
			},
			{
				video = 'radiopocket',
				text = Graphics.getLocalizedText("door5", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("door6", "en")
			},
		}
	},
	{
		-- trigger mess
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("mess", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("mess2", "en")
			},
			
		}
	},
	{
		-- trigger mess
		dialog = {
			{
				video = 'player',
				text = Graphics.getLocalizedText("chairs", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("chairs1", "en")
			},
			
		}
	},
	{
		-- trigger mess
		dialog = {
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome1", "en")
			},
			{
				video = 'radio',
				text = Graphics.getLocalizedText("welcome2", "en")
			},
			{
				video = 'player',
				text = Graphics.getLocalizedText("welcome3", "en")
			},
		}
	},
	
}

function resetData()
	PlayerData.battery = 100
	PlayerData.sanity = 100
	PlayerData.hasKey = false
end

local menu = playdate.getSystemMenu()
debug = false
local menuItem, error = menu:addMenuItem("Title", function()
	resetData()
	Noble.transition(TitleScene)
end)
local menuItem, error = menu:addMenuItem("debug", function()
	if Noble.showFPS == false then
		Noble.showFPS = true
	else 
		Noble.showFPS = false
	end
end)
-- Noble.showFPS = true
playdate.display.setRefreshRate(50)
timers = playdate.timer

Noble.new(TitleScene, 0.5, Noble.TransitionType.DIP_TO_BLACK,{alwaysRedraw=true})