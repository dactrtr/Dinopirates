import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/InitialScene'
import 'scenes/SpaceScene'
import 'scenes/TestScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})

Noble.showFPS = true
playdate.display.setRefreshRate(60)
timers = playdate.timer
 -- Noble.new(InitialScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
Noble.new(SpaceScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
-- Noble.new(TestScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)