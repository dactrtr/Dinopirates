import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/InitialScene'
import 'scenes/SpaceScene'
import 'scenes/TestScene'
import 'scenes/TitleScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})
local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem("Hola", function()
	print("Hola")
end)
local menuItem, error = menu:addMenuItem("LLEICOV", function()
	print("LLEICOV!")
end)
local menuItem, error = menu:addMenuItem("Dat menu", function()
	print("夢に向かって頑張れ！")
end)
-- Noble.showFPS = true
playdate.display.setRefreshRate(60)
timers = playdate.timer
--Noble.new(InitialScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
--Noble.new(SpaceScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
-- Noble.new(TestScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
Noble.new(TitleScene, 0.5, Noble.TransitionType.DIP_TO_BLACK)