import "utilities/SaveSystem"
import "entities/ui/menuTitle"
import "entities/ui/titleBackground"

TitleScene = {}
class("TitleScene").extends(NobleScene)
local scene = TitleScene

local menuItems = {}
local selectedIndex = 1
local crankTick = 0
local background = nil
local isDebugMenu = false
local versionSprite = nil

local menuNavigationSoundUpFx = nil
local menuNavigationSoundDownFx = nil
local menuBackgroundMusic = nil

scene.backgroundColor = Graphics.kColorWhite

local function updateMenuSelection()
	for i, item in ipairs(menuItems) do
		if item.sprite then
			if i == selectedIndex then
				item.sprite.animation:setState(item.selectedState)
			else
				item.sprite.animation:setState(item.defaultState)
			end
		end
	end

	if background and menuItems[selectedIndex] then
		background:changeState(menuItems[selectedIndex].backgroundState)
	end
end

local function selectPrevious()
	selectedIndex = selectedIndex - 1
	if selectedIndex < 1 then
		selectedIndex = #menuItems
	end
	updateMenuSelection()
end

local function selectNext()
	selectedIndex = selectedIndex + 1
	if selectedIndex > #menuItems then
		selectedIndex = 1
	end
	updateMenuSelection()
end

local function executeSelected()
	if menuItems[selectedIndex] and menuItems[selectedIndex].action then
		menuItems[selectedIndex].action()
	end
end

TitleScene.inputHandler = {
	upButtonDown = function()
		selectPrevious()
		if menuNavigationSoundUpFx then
			menuNavigationSoundUpFx:play()
		end
	end,
	downButtonDown = function()
		selectNext()
		if menuNavigationSoundDownFx then
			menuNavigationSoundDownFx:play()
		end
	end,
	cranked = function(change, _)
		crankTick = crankTick + change
		if crankTick > Config.Input.crankMenuThreshold then
			crankTick = 0
			selectNext()
			if menuNavigationSoundDownFx then
				menuNavigationSoundDownFx:play()
			end
		elseif crankTick < -Config.Input.crankMenuThreshold then
			crankTick = 0
			selectPrevious()
			if menuNavigationSoundUpFx then
				menuNavigationSoundUpFx:play()
			end
		end
	end,
	AButtonDown = function()
		executeSelected()
	end
}

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitioning away from another scene.
function scene:init()
	scene.super.init(self)
	
	-- Crear backup del estado original de levelsLDTK (solo una vez)
	SaveSystem.createOriginalBackup()
	
	-- Initialize original state if needed (legacy, puedes removerlo después)
	if not playdate.file.exists('levelOriginal.json') then
		playdate.datastore.write(PlayerDataOriginal, 'playerOriginal', true)
	end

	menuNavigationSoundUpFx = playdate.sound.sampleplayer.new('assets/sounds/menu_up_ima.wav')
	if menuNavigationSoundUpFx then
		menuNavigationSoundUpFx:setVolume(0.5)
	end
	menuNavigationSoundDownFx = playdate.sound.sampleplayer.new('assets/sounds/menu_down_ima.wav')
	if menuNavigationSoundDownFx then
		menuNavigationSoundDownFx:setVolume(0.5)
	end

	menuBackgroundMusic = playdate.sound.fileplayer.new('assets/sounds/music/game/shadow_dino_explore_intro_ima')
	if menuBackgroundMusic then
		menuBackgroundMusic:setVolume(0.4)
	end
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)
	PlayerData.isGaming = false
	
	Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
	menuItems = {}
	isDebugMenu = (debugMenu == true)

	local version = "* Demo " .. playdate.metadata.version .. "*"
	local vw, vh = Graphics.getTextSize(version)
	local versionImage = Graphics.image.new(vw + 4, vh + 4, Graphics.kColorClear)
	Graphics.pushContext(versionImage)
		Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
		Graphics.drawText(version, 0, 0)
	Graphics.popContext()
	versionSprite = Graphics.sprite.new(versionImage)
	versionSprite:setZIndex(200)
	versionSprite:moveTo(400 - vw / 2 - 2, vh / 2 + 2)
	versionSprite:add()

	if isDebugMenu then
		-- Debug mode: text-only menu, no background or sprites
		table.insert(menuItems, {
			label  = "COCKPIT",
			action = function()
				Noble.transition(CockpitScene, 0.3, Noble.Transition.MetroNexus)
			end
		})
		table.insert(menuItems, {
			label  = "SPACE",
			action = function()
				Noble.transition(SpaceScene, 0.3, Noble.Transition.MetroNexus)
			end
		})
		table.insert(menuItems, {
			label  = "GAME",
			action = function()
				SaveSystem.reset()
				PlayerData.fromTitle = true
				Noble.transition(Floor407, 1, Noble.Transition.Spotlight, {
					x = 200, y = 120,
					xExit = PlayerData.playerSpawn.x,
					yExit = PlayerData.playerSpawn.y,
					holdTime = 0.25, ease = Ease.outInQuad
				})
			end
		})
		table.insert(menuItems, {
			label  = "PLAYGROUND",
			action = function()
				PlayerData.playerSpawn.x = 200
				PlayerData.playerSpawn.y = 200
				Noble.transition(Floor409, 0.3, Noble.Transition.MetroNexus)
			end
		})
		table.insert(menuItems, {
			label  = "DANCE",
			action = function()
				PlayerData.lastEnemyTouched = { id = "debug", type = "basic", x = 200, y = 120 }
				PlayerData.isDancing = false
				DanceScene.debugMode = true
				Noble.transition(DanceScene, 0.3, Noble.Transition.MetroNexus)
			end
		})
		
	else
		background = TitleBackground(200, 120, 1)

		local startY = 120
		local startX = 88
		local spacing = 20
		local currentY = startY

		local hasSave = playdate.file.exists('gameState.json')

		if hasSave then
			local continueSprite = MenuTitle(startX, currentY, 'defContinue', 100)
			table.insert(menuItems, {
				sprite = continueSprite,
				defaultState = 'defContinue',
				selectedState = 'selContinue',
				backgroundState = 'continue',
				action = function()
					local success, savedLevel = SaveSystem.load()
					if success and savedLevel then
						printDebug("📍 Cargando nivel guardado:", savedLevel)
						local nextScene = RoomTranslate(savedLevel)
						if nextScene then
							PlayerData.fromTitle = true
							Noble.transition(nextScene, 1, Noble.Transition.Spotlight, {
								x = 200, y = 120,
								xExit = PlayerData.playerSpawn.x,
								yExit = PlayerData.playerSpawn.y,
								holdTime = 0.25, ease = Ease.outInQuad
							})
						else
							printDebug("❌ ERROR: No se encontró la escena Floor" .. savedLevel)
							Noble.transition(Floor120, 1, Noble.Transition.Default)
						end
					else
						printDebug("❌ Error cargando el save")
					end
				end
			})
			currentY = currentY + spacing
		end

		if hasSave then
			local deleteSprite = MenuTitle(startX, currentY, 'defDeleteGame', 100)
			table.insert(menuItems, {
				sprite = deleteSprite,
				defaultState = 'defDeleteGame',
				selectedState = 'selDeleteGame',
				backgroundState = 'deleteGame',
				action = function()
					SaveSystem.delete()
					Utilities.clearAllAchievements()
					Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)
				end
			})
			currentY = currentY + spacing
		end

		local newGameSprite = MenuTitle(startX, currentY, 'defNewGame', 100)
		table.insert(menuItems, {
			sprite = newGameSprite,
			defaultState = 'defNewGame',
			selectedState = 'selNewGame',
			backgroundState = 'newGame',
			action = function()
				SaveSystem.reset()
				PlayerData.fromTitle = true
				Noble.transition(Floor407, 1, Noble.Transition.Spotlight, {
					x = 200, y = 120,
					xExit = PlayerData.playerSpawn.x,
					yExit = PlayerData.playerSpawn.y,
					holdTime = 0.25, ease = Ease.outInQuad
				})
			end
		})
		currentY = currentY + spacing

		local achievementsSprite = MenuTitle(startX, currentY, 'defAchievements', 100)
		table.insert(menuItems, {
			sprite = achievementsSprite,
			defaultState = 'defAchievements',
			selectedState = 'selAchievements',
			backgroundState = 'achievements',
			action = function()
				Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
				achievements.viewer.launch()
			end
		})
		currentY = currentY + spacing

		local creditsSprite = MenuTitle(startX, currentY, 'defCredits', 100)
		table.insert(menuItems, {
			sprite = creditsSprite,
			defaultState = 'defCredits',
			selectedState = 'selCredits',
			backgroundState = 'achievements',
			action = function()
				Noble.transition(CreditsScene, 0.3, Noble.Transition.MetroNexus)
			end
		})
	end

	selectedIndex = 1
	updateMenuSelection()

	if menuBackgroundMusic then
		menuBackgroundMusic:play(0)
	end
end

-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)

	if isDebugMenu then
		Graphics.drawTextAligned("*[ DEBUG MODE ]*", 200, 80, kTextAlignment.center)
		for i, item in ipairs(menuItems) do
			local label = i == selectedIndex and ("*> " .. item.label .. " <*") or ("  " .. item.label)
			Graphics.drawTextAligned(label, 200, 110 + (i - 1) * 20, kTextAlignment.center)
		end
	end
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
	for _, item in ipairs(menuItems) do
		if item.sprite then item.sprite:remove() end
	end
	menuItems = {}
	if background then background:remove() background = nil end
	if versionSprite then versionSprite:remove() versionSprite = nil end
	if menuBackgroundMusic and menuBackgroundMusic:isPlaying() then
		menuBackgroundMusic:stop()
	end
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

function scene:pause()
	scene.super.pause(self)
end

function scene:resume()
	scene.super.resume(self)
end