import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/InitialScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})

Noble.showFPS = true

Noble.new(InitialScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)