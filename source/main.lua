import 'libraries/noble/Noble'

import 'utilities/Utilities'
import 'utilities/PauseMenu'
import 'scenes/DeadScene'
import 'scenes/MazeScene'
import 'scenes/Floors'
--import 'scenes/StarScene'
import 'scenes/TestScene'
import 'scenes/TitleScene'
import 'assets/data/PlayerData'
import 'assets/data/levels'
import 'assets/data/script'

Noble.Settings.setup({
	Difficulty = "Medium",
})
Noble.showFPS = false

Noble.GameData.setup({
	Score = 0,
})

debug = false

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


if playdate.file.exists('playerSave.json') == false then
	playdate.datastore.write(levels, 'levelOriginal', true)
	playdate.datastore.write(PlayerData, 'playerOriginal', true)
	--PlayerDataSave = PlayerData
	--levelsSave = levels
	print('save copies')
end

local menu = playdate.getSystemMenu()
local menuItem, error = menu:addMenuItem("Title", function()
	Noble.transition(TitleScene)
end)
local menuItem, error = menu:addMenuItem("Delete Save", function()
	playdate.file.delete('playerSave.json')
	playdate.file.delete('PlayerSave.json')
	playdate.file.delete('levelSave.json')
end)
local menuItem, error = menu:addMenuItem("debug", function()
	if debug == false then
		debug = true
	end
	if Noble.showFPS == false then
		Noble.showFPS = true
	else 
		Noble.showFPS = false
	end
end)
playdate.display.setRefreshRate(50)
timers = playdate.timer

Noble.new(TitleScene, 0.5, Noble.TransitionType.DIP_TO_BLACK,{alwaysRedraw=true})