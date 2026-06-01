import 'libraries/noble/Noble'
import 'libraries/panels/Panels'
-- import 'libraries/ldtk/LDtk'
import 'achievements/all'

import 'assets/data/Config'

import 'utilities/Utilities'
-- import 'utilities/PauseMenu'
import 'utilities/SaveSystem'

import 'scenes/DeadScene'
import 'scenes/MazeScene'
import 'scenes/DanceScene'
import 'scenes/Floors'
import 'scenes/SpaceScene'
import 'scenes/TestScene'
import 'scenes/CreditsScene'
import 'scenes/CockpitScene'
import 'scenes/TitleScene'

import 'assets/data/PlayerDataTables'
import 'assets/data/levels'
import 'assets/data/tilemap'
import 'assets/data/script'

achievementData = import 'assets/data/achievements'
local configToast = import 'assets/data/toastConfig'

achievements.initialize(achievementData)
achievements.forceSaveOnGrantOrRevoke=true
local config = {
   toastOnGrant = true,
   miniMode = true,
   toastFromTop = true,
}

achievements.toasts.initialize(configToast)

Noble.Settings.setup({
	Difficulty = "Medium",
	playerSlot = 1
})

Noble.showFPS = false

Noble.GameData.setup({
	Score = 0,
},1)

Panels.vars.lang = "en"
debugMenu = false
debug = false
diagonalMovement = true
shinonome = Graphics.font.new('assets/fonts/JF-Dot-Shinonome16')
Graphics.setFont(shinonome, 'normal')

Panels.Settings.path = ""
ZIndex = Config.ZIndex
CollideGroups = Config.CollideGroups

-- playdate.datastore.write(PlayerDataOriginal, 'playerOriginal', true) -- Removed: using code-based reset now

SaveSystem.createOriginalBackup()

-- Initialize room index for fast lookups (O(1) instead of O(n))
roomsByIid = {}
if levelsLDTK then
	for _, room in ipairs(levelsLDTK) do
		if room and room.uniqueIdentifer then
			roomsByIid[room.uniqueIdentifer] = room
		end
	end
end

local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem("Title", function()
	Noble.transition(TitleScene,0.3, Noble.Transition.MetroNexus)
end)
-- local menuItem, error = menu:addMenuItem("Lang", function()
-- 	Utilities.switchLang()
-- end)
local menuItem, error = menu:addMenuItem("debug", function()
	debug = Utilities.toggle(debug)
	debugMenu = Utilities.toggle(debugMenu)
	if debug == true then
		if Noble.showFPS == false then
			Noble.showFPS = true
		else 
			Noble.showFPS = false
		end
	end
end)

playdate.display.setRefreshRate(50)
timers = playdate.timer

function playdate.deviceDidWake()
	MazeScene.onDeviceSleep()
end

Noble.new(TitleScene, 0.3, Noble.Transition.MetroNexus)