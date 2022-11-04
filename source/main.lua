import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/InitialScene'
import 'scenes/SpaceScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})

-- Noble.showFPS = true
playdate.display.setRefreshRate(60)

-- Noble.new(InitialScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)
Noble.new(SpaceScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)