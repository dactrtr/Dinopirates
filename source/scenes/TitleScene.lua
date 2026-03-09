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

scene.backgroundColor = Graphics.kColorWhite

local function updateMenuSelection()
	for i, item in ipairs(menuItems) do
		if i == selectedIndex then
			item.sprite.animation:setState(item.selectedState)
		else
			item.sprite.animation:setState(item.defaultState)
		end
	end
	
	-- Update background animation based on selected menu item
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
	end,
	downButtonDown = function()
		selectNext()
	end,
	cranked = function(change, _)
		crankTick = crankTick + change
		if crankTick > 30 then
			crankTick = 0
			selectNext()
		elseif crankTick < -30 then
			crankTick = 0
			selectPrevious()
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
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)
	PlayerData.isGaming = false
	
	-- Create animated background
	background = TitleBackground(200, 120, 1)
	
	-- Set image draw mode to properly render sprite transparency
	Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
	
	-- Clear previous menu items
	menuItems = {}
	
	-- Starting Y position for menu items
	local startY = 120
	local startX = 88
	local spacing = 20
	local currentY = startY
	
	-- Add Continue option if save exists
	if playdate.file.exists('gameState.json') then
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
					
					-- Traducir el número de nivel a la escena
					local nextScene = RoomTranslate(savedLevel)
					
					if nextScene then
						Noble.transition(
							nextScene,
							1, Noble.Transition.Spotlight, {
							x = 200,
							y = 120,
							xExit = PlayerData.playerSpawn.x,
							yExit = PlayerData.playerSpawn.y,
							holdTime = 0.25,
							ease = Ease.outInQuad}
						)
					else
						printDebug("❌ ERROR: No se encontró la escena Floor" .. savedLevel)
						-- Fallback a un nivel por defecto
						Noble.transition(Floor120, 1, Noble.Transition.Default)
					end
				else
					printDebug("❌ Error cargando el save")
					-- Opcional: mostrar mensaje de error
				end
			end
		})
		currentY = currentY + spacing
	end
	-- Add Delete Save option if save exists
	if playdate.file.exists('gameState.json') then
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
	
	-- Add New Game option
	local newGameSprite = MenuTitle(startX, currentY, 'defNewGame', 100)
	table.insert(menuItems, {
		sprite = newGameSprite,
		defaultState = 'defNewGame',
		selectedState = 'selNewGame',
		backgroundState = 'newGame',
		action = function()
			SaveSystem.reset()
			
			-- Iniciar en el primer nivel de tu juego
			Noble.transition(
				Floor407,  -- Cambia esto al nivel inicial de tu juego
				1, Noble.Transition.Spotlight, {
				x = 200,
				y = 120,
				xExit = PlayerData.playerSpawn.x,
				yExit = PlayerData.playerSpawn.y,
				holdTime = 0.25,
				ease = Ease.outInQuad
			})
		end
	})
	currentY = currentY + spacing
	
	
	-- Add Achievements option
	local achievementsSprite = MenuTitle(startX, currentY, 'defAchievements', 100)
	table.insert(menuItems, {
		sprite = achievementsSprite,
		defaultState = 'defAchievements',
		selectedState = 'selAchievements',
		backgroundState = 'achievements',
		action = function()
			Graphics.setImageDrawMode(Graphics.kDrawModeCopy) -- hotfix
			achievements.viewer.launch()
		end
	})
	currentY = currentY + spacing
	
	-- Add Playground option only if debug is true
	if debug then
		local playgroundSprite = MenuTitle(startX, currentY, 'defPlayground', 100)
		table.insert(menuItems, {
			sprite = playgroundSprite,
			defaultState = 'defPlayground',
			selectedState = 'selPlayground',
			backgroundState = 'achievements', -- Reuse achievements background (only 4 frames available)
			action = function()
				PlayerData.playerSpawn.x = 200
				PlayerData.playerSpawn.y = 200
				Noble.transition(Floor409, 0.3, Noble.Transition.MetroNexus)
			end
		})
		currentY = currentY + spacing
	end
	
	-- Set initial selection (Continue if exists, otherwise New Game)
	selectedIndex = 1
	updateMenuSelection()
end

-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	drawVersionNumber()
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
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