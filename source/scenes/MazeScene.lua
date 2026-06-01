--
-- Mazescene.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "scene" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MazeScene = {
}
class("MazeScene").extends(NobleScene)

local scene = MazeScene
local room = nil -- Level in table position

MazeScene.backgroundMusic = nil

import "entities/player/init"

import "assets/comics/comicsData"

import "entities/enemies/brocorat"
import "entities/enemies/crewmember"

import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/props/portal_door'
import 'entities/props/trigger'

import 'entities/items/Items'
import 'entities/props/npc'

import "entities/FX/FXshadow"
import "entities/UI/playerHud"
import "entities/UI/inGameMenu"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `scene.variable2`.
-- ...
--



-- MARK: Player related
local player = nil
local shadow = nil
local foregroundSprite = nil
local inGameMenuActive = nil
-- MARK: UI
local uiScreen = nil
local inGameEquip = nil
-- MARK: Utilities
local cheat = CheatCode("up", "up", "up", "down")
-- Mark: variables for crank checking
local crankIsMoving = false
local crankStopTimer = 0
local CRANK_STOP_THRESHOLD = 0.1 -- seconds of inactivity before considering crank stopped
local bButtonDownTime = nil -- ms timestamp when B was pressed; drives custom hold-to-charge (SDK Held is fixed at 1s)
local tileColliders = {}

-- This is the background color of this scene.
scene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitioning away from another scene.
function scene:init()
	scene.super.init(self)
	cheat.onComplete = function()
		Utilities.iddqd()
	end
	playdate.display.setRefreshRate(50)

	if not MazeScene.backgroundMusic then
		MazeScene.backgroundMusic = playdate.sound.fileplayer.new('assets/sounds/music/game/shadow_dino_explore_ima')
		if MazeScene.backgroundMusic then
			MazeScene.backgroundMusic:setVolume(0.5)
		end
	end
end
function scene:setFloor(levelNumber, roomNumber)
	for i, levelData in ipairs(levelsLDTK) do
		if levelData.customFields.level == levelNumber and levelData.customFields.roomNumber == roomNumber then
			room = i
			return
		end
	end
	print("Warning: Level " .. levelNumber .. ", Room " .. roomNumber .. " not found")
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)

	if MazeScene.backgroundMusic and not MazeScene.backgroundMusic:isPlaying() then
		MazeScene.backgroundMusic:play(0)
	end

	PlayerData.isGaming = false
	PlayerData.isEquiping = false
	sequence = Sequence.new():from(0):to(50, 1.5, Ease.outBounce)
	sequence:start()
	
	PlayerData.room = levelsLDTK[room].customFields.roomNumber
	PlayerData.isInDarkness = levelsLDTK[room].customFields.shadow
	PlayerData.floor = room
	
	PlayerData.actualLevel = levelsLDTK[room].customFields.level
	PlayerData.actualRoom = levelsLDTK[room].customFields.roomNumber
	PlayerData.actualTilemap = levelsLDTK[room].customFields.tile 
	levelsLDTK[room].customFields.visited = true
	
	-- MARK: Floor
	local roomBgPath = 'assets/images/rooms/floor' .. PlayerData.actualLevel
	                   .. '/' .. levelsLDTK[room].identifier
	floor = Graphics.sprite.new()
	floor:setImage(Graphics.image.new(roomBgPath))
	floor:setZIndex(1)
	floor:moveTo(200, 120)
	floor:add()

	-- MARK: Foreground
	if levelsLDTK[room].customFields.hasForeground == true then
		local fgPath = 'assets/images/rooms/floor' .. PlayerData.actualLevel
		               .. '/foreground_' .. PlayerData.actualRoom
		local fgImage = Graphics.image.new(fgPath)
		if fgImage then
			foregroundSprite = Graphics.sprite.new()
			foregroundSprite:setImage(fgImage)
			foregroundSprite:setZIndex(ZIndex.foreground)
			foregroundSprite:moveTo(200, 120)
			foregroundSprite:add()
		end
	end

	-- MARK: UI
	inGameEquip = inGameMenu()
	
	-- MARK: Tile Colliders
	if room and levelsLDTK[room] then
		tileColliders = CreateTileColliders(tileMapData[PlayerData.actualTilemap])
	else
		printDebug("❌ ERROR: could not create wall colliders, room or levelsLDTK[room] is nil")
	end
	
	-- MARK: Doors

	
	if room and levelsLDTK[room] then
		local currentRoom = levelsLDTK[room]
		printDebug("✅ CurrentRoom:", currentRoom.identifier)
		printDebug("📍 Level:", currentRoom.customFields.level)
		printDebug("📍 RoomNumber:", currentRoom.customFields.roomNumber)
		
		if currentRoom.neighbourLevels then
			printDebug("👥 Neighbors found:", #currentRoom.neighbourLevels)
			for i, n in ipairs(currentRoom.neighbourLevels) do
				printDebug("  Neighbor", i, "- iid:", n.levelIid, "dir:", n.dir)
			end
		else
			printDebug("❌ neighbourLevels is nil")
		end
		
		CreateDoorsFromLDTK(currentRoom)
		CreatePortalDoorsFromLDTK(currentRoom)
	else
		printDebug("❌ ERROR: room is", room, "or levelsLDTK[room] is nil")
	end
	printDebug("======================")
	
	
	
	-- MARK: Props 
	local entities = levelsLDTK[room].entities
	
	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			for _, prop in ipairs(entitiesList) do
				local cf = prop.customFields or {}
	
				if cf.destroyed ~= nil or cf.nocollider ~= nil then
					local x, y, id = prop.x, prop.y, prop.iid
	
					if cf.destroyed == false or cf.destroyed == nil then
						PropItem(x, y, cf.type , ZIndex.props, cf.nocollider,cf.destroyed, id)
					else
						PropItem(x, y, "debris", ZIndex.props, true, cf.destroyed , id)
					end
				end
			end
		end
	end
	
	-- MARK: Items
	local itemRequirements = {
		keycard = "keys",
		lamp = "items.hasLamp",
		radio = "items.hasRadio",
		notes = "items.hasNotes",
		boots = "items.hasBoots",
		plunger = "items.hasPlunger"
	}

	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			for _, item in ipairs(entitiesList) do
				local cf = item.customFields or {}

				if cf.isItem == true then
					local x, y = item.x, item.y
					local itemType = (cf.type or ""):lower()
					local keyNumber = cf.KeyNumber or cf.keyNumber
					local shouldGenerate = false

					if itemType == "keycard" then
						local keyNum = keyNumber or 1
						shouldGenerate = not PlayerData.keys[keyNum]
						printDebug("Checking keycard - KeyNumber:", keyNum, "shouldGenerate:", shouldGenerate)
					elseif cf.grants then
						shouldGenerate = true
						for pair in string.gmatch(cf.grants, "([^,]+)") do
							local key, value = string.match(pair, "([^:]+):([^:]+)")
							if key and value then
								key = key:gsub("%s+", "")
								if PlayerData.items[key] == true or PlayerData.skills[key] == true then
									shouldGenerate = false
									break
								end
							end
						end
					elseif itemType == "food" then
						-- Food is stackable: persist per-iid via the 'collected' flag
						shouldGenerate = cf.collected ~= true
					elseif itemRequirements[itemType] then
						local itemPath = itemRequirements[itemType]
						if itemPath:match("^items%.") then
							local fieldName = itemPath:match("^items%.(.+)$")
							shouldGenerate = PlayerData.items[fieldName] == false
						else
							shouldGenerate = PlayerData[itemPath] == false
						end
					end

					if shouldGenerate then
						printDebug("Generating item:", itemType, "at (", x, ",", y, ")")
						Items(x, y, itemType, keyNumber, cf.grants, item.iid)
					end
				end
			end
		end
	end
		-- MARK: Player
	local spawnPoint = PlayerData.playerSpawn
	player = Player(spawnPoint.x, spawnPoint.y, PlayerData.speed, ZIndex.player)
	uiScreen = playerHud(player)
	PlayerData.x = player.x
	PlayerData.y = player.y
	PlayerData.direction = 'idle'
	
	-- MARK: FX
	local cf = levelsLDTK[room].customFields or {}
	
	if cf.shadow == true then
		local lightLevel = cf.light or 0
		shadow = FXshadow(player, 70, lightLevel, ZIndex.fx)
		PlayerData.isInDarkness = true
	else
		PlayerData.isInDarkness = false
	end
	
	local cf = levelsLDTK[room].customFields
	if cf.comic_name then
		local comicData = comics[cf.comic_name]
		if comicData then
			if cf.play == "Enter" and cf.comic_wasPlayed == false then
				PlayerData.isCutscene = true
				PlayerData.isGaming = false
			end
			
			Panels.startCutscene(comicData, function()
				PlayerData.isGaming = true
				PlayerData.isCutscene = false
				levelsLDTK[room].customFields.comic_wasPlayed = true
				Utilities.checkStoryAchievement(cf.comic_name)
			end)
		end
	end
	
	
	-- MARK: Enemies
	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			if entityType == "Brocorat" or entityType == "Bosscolli" then
				for _, enemy in ipairs(entitiesList) do
					local cf = enemy.customFields or {}
					local x, y, id = enemy.x, enemy.y, enemy.iid
					local speed = cf.speed
					local dead = cf.dead or false
	
					if not dead then
						if entityType == "Brocorat" then
							Brocorat(x, y, speed, ZIndex.enemy, player, id)
						elseif entityType == "Bosscolli" then
							bosscolli(x, y, speed, ZIndex.enemy, player, id)
						end
					else
						PropItem(x, y, "blood2", ZIndex.props, true)
					end
				end
			end
		end
	end
	
	-- MARK: Crew members 
	
	local entities = levelsLDTK[room].entities
	
	if entities and entities.CrewMember then
		for i, crewData in ipairs(entities.CrewMember) do
			local cf = crewData.customFields or {}
			local x, y = crewData.x, crewData.y
			local speed = cf.speed
			local crewId = cf.crewID or i
			local crewIid = crewData.iid
			local taken = cf.isTaken or false
	
			if not taken then
				CrewMember(x, y, speed, ZIndex.enemy, player, crewIid, room, crewId)
			end
		end
	end
	

	-- MARK: NPCs
	local npcEntities = levelsLDTK[room].entities
	if npcEntities and npcEntities.NPC then
		for _, npcData in ipairs(npcEntities.NPC) do
			local cf = npcData.customFields or {}
			NPC(npcData.x, npcData.y, cf.type or "computer", npcData.iid, room, cf.sourceFeed or 0)
		end
	end

-- MARK: Dialog triggers
	local entities = levelsLDTK[room].entities
	
	if entities and entities.Triggers then
		for i, triggerData in ipairs(entities.Triggers) do
			local cf = triggerData.customFields or {}
			local used = cf.usedTrigger or false
			
			if not used then
				local x = triggerData.x
				local y = triggerData.y
				local width = triggerData.width
				local height = triggerData.height
				local script = cf.script
				local type = cf.type
				
				-- Pasar el iid en lugar del índice
				Trigger(x, y, width, height, script, triggerData.iid, room, type)
			end
		end
	end
end
-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
	self:setDiagonalMovement(diagonalMovement)
	if PlayerData.fromTitle then
		PlayerData.fromTitle = false
		if not PlayerData.isTiny then
			player:startSleeping()
		else
			PlayerData.isGaming = true
		end
	else
		PlayerData.isGaming = true
	end
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	
	-- Performance: Only update cheat code when player is gaming
	if PlayerData.isGaming == true then
		cheat:update()
	end
	
	-- MARK: Custom B hold-to-charge (shorter than the SDK's fixed 1s Held)
	if bButtonDownTime and player and player.isAlive and PlayerData.isGaming == true
		and not player.isDarkCharging and not player.isGrappleCharging then
		local holdDelay = PlayerData.isInDarkness and Config.DarkReveal.holdDelay or Config.Grapple.holdDelay
		if playdate.getCurrentTimeMilliseconds() - bButtonDownTime >= holdDelay then
			if PlayerData.isInDarkness then
				player:beginDarkCharge()
			else
				player:beginGrappleCharge()
			end
		end
	end

	-- MARK: Crank stop detection
	if crankIsMoving then
		crankStopTimer += (1/50) -- Increment by frame time (assuming 50fps)
		
		if crankStopTimer >= CRANK_STOP_THRESHOLD then
			crankIsMoving = false
			crankStopTimer = 0
			-- do something when player stopped cranking
			player:idle()
		end
	end
	
	-- Cutscene input handling
	if PlayerData.isCutscene == true then
		-- Disable game input handlers while cutscene is running
		if Noble.Input.getEnabled() then
			Noble.Input.setEnabled(false)
		end
		Panels.update()
	else
		-- Re-enable game input handlers when cutscene ends
		if not Noble.Input.getEnabled() then
			Noble.Input.setEnabled(true)
		end
	end
	
	-- Mark: Crank notification (only when needed)
	if PlayerData.battery == 0 and PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and (PlayerData.isTalking == false and PlayerData.isCutscene == false) and PlayerData.isGaming == true and PlayerData.isTiny == false and not PlayerData.showFullLight and not PlayerData.rechargeBlocked then
		playdate.ui.crankIndicator:draw(0, 0)
	end
end


-- This runs once per frame, and is meant for drawing code.
function scene:drawBackground()
	scene.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
	
	uiScreen:removeAll()
	floor:remove()
	if foregroundSprite then
		foregroundSprite:remove()
		foregroundSprite = nil
	end
	if shadow then
		shadow:removeAll()
	end
	
	for _, collider in ipairs(tileColliders) do
		collider:remove()
	end
	tileColliders = {}
	
	Graphics.sprite.performOnAllSprites(function(s)
		if s:getZIndex() ~= -32768 then s:remove() end
	end)
	
	PlayerData.playerExit.x = player.x
	PlayerData.playerExit.y = player.y
	
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	-- Your code here
	PlayerData.isGaming = false
	SaveSystem.save()
end

function scene:pause()
	scene.super.pause(self)
	SaveSystem.save()
end

function MazeScene.onDeviceSleep()
	if player and PlayerData.isGaming and not PlayerData.isTiny then
		player:startSleeping()
	end
end

function scene:movePlayer(direction)
	if PlayerData.isTalking == false and PlayerData.isCutscene == false then
		if player.isAlive == true then
			player:move(direction)
			if shadow  then
				shadow:move(direction)
			end
		end
	end
end

-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- scene.inputHandler = someOtherInputHandler
-- OR
scene.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
		if player and player.isSleeping then return end
		if PlayerData.isTalking == true then
			player:displayDialog()
		elseif player.currentTrigger and PlayerData.isGaming == true then
			local trigger = player.currentTrigger
			PlayerData.isGaming = false
			PlayerData.isTalking = true
			player.dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)
			Utilities.grantAchievementIfNeeded(trigger.script)
		end
		
		-- Trigger minifier if ready
		if PlayerData.readyToShrink == true and PlayerData.isGaming == true then
			player:startMinifying()
		end

		-- Trigger microwave cooking if ready
		if PlayerData.readyToCook == true and PlayerData.isGaming == true then
			player:startCooking()
		end
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		if player and player.isSleeping then return end
		if PlayerData.isGaming == true and PlayerData.items.hasDWatch == true then
			inGameEquip:displayMenu(player.x,player.y)
		end
	end,
	AButtonUp = function()				-- Runs once when button is released.
		-- Your code here
	end,

	-- B button
	--

	BButtonDown = function()
		if player and player.isSleeping then return end
		if PlayerData.isGaming == false and PlayerData.isEquiping == true then
			PlayerData.isGaming = true
			PlayerData.isEquiping = false
			inGameEquip:closeMenu()
		elseif PlayerData.isGaming == false and PlayerData.readyToShrink == true then
			player:finishMinifying()
		elseif PlayerData.isGaming == false and PlayerData.readyToCook == true then
			player:finishCooking()
		elseif PlayerData.isGaming == true and player.isAlive == true then
			player:useAbility()
		end
		-- Tokens are granted by each ability when it actually fires (flash / plungerang /
		-- grapple launch), not here — so merely starting a charge while idle costs nothing.
		-- Start the custom hold timer; update() begins the dark charge after holdDelay.
		bButtonDownTime = playdate.getCurrentTimeMilliseconds()
	end,
	BButtonHold = function()
	end,
	BButtonUp = function()
		bButtonDownTime = nil
		if player then
			player:endDarkCharge()
			player:endGrappleCharge()
		end
	end,
	-- D-pad left
	--
	leftButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'left'
			scene:movePlayer('left')
		end
	end,
	leftButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'left') then
			scene:movePlayer('left')
		end
	end,
	leftButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'left' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'right'
			scene:movePlayer('right')
		end
	end,
	rightButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'right') then
			scene:movePlayer('right')
		end
	end,
	rightButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'right' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad up
	--
	upButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'up'
			scene:movePlayer('up')
		end
	end,
	upButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'up') then
			scene:movePlayer('up')
		end
	end,
	upButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'up' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad down
	--
	downButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'down'
			scene:movePlayer('down')
		end
	end,
	downButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'down') then
			scene:movePlayer('down')
		end
	end,
	downButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'down' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)
		-- Reset crank stop detection
		crankIsMoving = true
		crankStopTimer = 0
		
		local ticksValue = playdate.getCrankTicks(4) -- maybe its better use change or acceleratedChange
		if not player.isAlive then return end

		if player.isDarkCharging then
			player:addDarkCrankDelta(change)
			return
		end

		if player.isGrappleCharging then
			player:addGrappleCrankDelta(change)
			return
		end

		-- Cranking burns calories, EXCEPT while cooking at a microwave:
		-- cooking's calorie byproduct (Config.Microwave.caloriesPerFood) must be the
		-- only calorie effect, otherwise this per-tick burn cancels it out.
		local isCooking = (PlayerData.isGaming == false and PlayerData.readyToCook == true)
		if ticksValue > 0 and not isCooking then
			player:burnCalories(1)
		end
		
		if PlayerData.isGaming == true then
			if ticksValue > 0 then
				if PlayerData.battery < 100 and PlayerData.readyToShrink == false and PlayerData.isTiny == false then
					player:chargeBattery(3)
					if shadow then
						shadow:refresh()
					end
				end
			end
		else
			-- Handle microwave cooking when locked on a microwave
			if PlayerData.readyToCook == true then
				if ticksValue ~= 0 then
					player.cookProgress = (player.cookProgress or 0) + math.abs(ticksValue)
					while player.cookProgress >= Config.Microwave.crankPerFood
							and (PlayerData.food or 0) > 0
							and PlayerData.healthPoints < Config.Player.maxHealthPoints do
						player.cookProgress -= Config.Microwave.crankPerFood
						PlayerData.food -= 1
						PlayerData.healthPoints = math.min(PlayerData.healthPoints + Config.Microwave.hpPerFood, Config.Player.maxHealthPoints)
						PlayerData.calories = math.min((PlayerData.calories or 0) + Config.Microwave.caloriesPerFood, Config.Dance.caloriesMax)
					end
					-- Auto-finish when full or out of food
					if PlayerData.healthPoints >= Config.Player.maxHealthPoints or (PlayerData.food or 0) <= 0 then
						player:finishCooking()
					end
				end
			end
			-- Handle manual transformation when locked on minifier
			if PlayerData.readyToShrink == true then
				if ticksValue ~= 0 then
					player:transformCycle()
					
					if not PlayerData.isTiny then
						-- Shrinking (Counter-clockwise)
						if ticksValue < 0 then
							PlayerData.actualPlayerSize -= math.abs(ticksValue)
							if PlayerData.actualPlayerSize <= 0 then
								PlayerData.actualPlayerSize = 0
								player:shrink()
								player:finishMinifying()
							end
						end
					else
						-- Growing (Clockwise)
						if ticksValue > 0 then
							PlayerData.actualPlayerSize += math.abs(ticksValue)
							if PlayerData.actualPlayerSize >= PlayerData.playerSize then
								PlayerData.actualPlayerSize = PlayerData.playerSize
								player:grow()
								player:finishMinifying()
							end
						end
					end
				end
			end
		end
		-- scene:PowerCrank()
		
	end,
	crankDocked = function()	
							-- Runs once when when crank is docked.
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		
	end
}

function MazeScene:setDiagonalMovement(enabled)
	isDiagonalMovementEnabled = enabled
end

function scene:PowerCrank()
    
end
