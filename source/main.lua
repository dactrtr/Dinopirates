import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/InitialScene'
import 'scenes/SpaceScene'
import 'scenes/StarScene'
import 'scenes/TestScene'
import 'scenes/TitleScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})
local menu = playdate.getSystemMenu()
debug = false
local menuItem, error = menu:addMenuItem("Title Menu", function()
	Noble.transition(TitleScene)
end)
local menuItem, error = menu:addMenuItem("debug", function()
	if debug == false then
		debug = true
	else 
		debug = false
	end
end)
local menuItem, error = menu:addMenuItem("Dat menu", function()
	print("夢に向かって頑張れ！")
end)
-- Noble.showFPS = true
playdate.display.setRefreshRate(60)
timers = playdate.timer

Noble.new(TitleScene, 0.5, Noble.TransitionType.DIP_TO_BLACK)