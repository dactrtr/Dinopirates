import 'libraries/noble/Noble'

import 'utilities/Utilities'
import 'scenes/DeadScene'
import 'scenes/MazeScene'
import 'scenes/Floors'
--import 'scenes/StarScene'
import 'scenes/TestScene'
import 'scenes/TitleScene'
import 'Data/PlayerData'
import 'Data/levels'
import 'Data/script'

Noble.Settings.setup({
	Difficulty = "Medium",
	debug = false
})
Noble.showFPS = false

Noble.GameData.setup({
	Score = 0,
})

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


function resetData()
	PlayerData.battery = 100
	PlayerData.sanity = 100
	PlayerData.hasKey = false
end


local menu = playdate.getSystemMenu()
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