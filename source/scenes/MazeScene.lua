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

import "entities/player/init"

import "assets/comics/comicsData"

import "entities/enemies/brocorat"
import "entities/enemies/crewmember"

import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/props/trigger'

import 'entities/items/Items'

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
	-- Your code here
	
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
	-- Your code here
	
	
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
	tilesMap = Graphics.imagetable.new('assets/images/tile/tile')
	map = Graphics.tilemap.new()
	map:setImageTable(tilesMap) 
	-- map:setSize(16,9)
	
	-- MARK: UI
	inGameEquip = inGameMenu()

	renderTileMap(tileMapData[PlayerData.actualTilemap], map)
	
	floor = Graphics.sprite.new()
	floor:setZIndex(1)
	floor:setTilemap(map)
	floor:moveTo(0, 0) -- Top-left corner
	floor:setCenter(0, 0) -- Anchor top-left instead of center
	floor:add()
	
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
	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			for _, item in ipairs(entitiesList) do
				local cf = item.customFields or {}
	
				-- Detect if it belongs to Items layer, is an item type, or is a Keys entity
				local isKeyEntity = (entityType == "Keys" or item.layer == "Keys")
				local isItemEntity = (item.layer == "Items" or cf.isItem == true)
				
				if isKeyEntity or isItemEntity then
					local x, y = item.x, item.y
					
					-- For Keys entities, type is always keycard
					local type
					if isKeyEntity then
						type = "keycard"
					else
						type = (cf.type or entityType):lower()
					end
					
					-- Get KeyNumber (try both uppercase and lowercase)
					local keyNumber = cf.KeyNumber or cf.keyNumber
					
					local itemRequirements = {
						keycard = "keys",  -- Changed to check keys table
						lamp = "items.hasLamp",
						radio = "items.hasRadio",
						notes = "items.hasNotes",
						boots= "items.hasBoots",
						plunger = "items.hasPlunger"
					}
					
					-- Special handling for keycards with key numbers
					local shouldGenerate = false
					if type == "keycard" then
						-- For keycards, check if player doesn't have this specific key
						local keyNum = keyNumber or 1
						shouldGenerate = not PlayerData.keys[keyNum]
						printDebug("🔑 Checking keycard generation - KeyNumber:", keyNum, "shouldGenerate:", shouldGenerate)
					elseif cf.grants then
						-- If item has a grants field, check if player already has those items/skills
						shouldGenerate = true
						for pair in string.gmatch(cf.grants, "([^,]+)") do
							local key, value = string.match(pair, "([^:]+):([^:]+)")
							if key and value then
								key = key:gsub("%s+", "")
								-- Check both items and skills tables
								if PlayerData.items[key] == true or PlayerData.skills[key] == true then
									shouldGenerate = false
									break
								end
							end
						end
					elseif itemRequirements[type] then
						-- For other items, check the boolean flag in items table
						local itemPath = itemRequirements[type]
						if itemPath:match("^items%.") then
							-- Extract the field name after "items."
							local fieldName = itemPath:match("^items%.(.+)$")
							shouldGenerate = PlayerData.items[fieldName] == false
						else
							shouldGenerate = PlayerData[itemPath] == false
						end
					end
					
					-- Generate item if player doesn't have it
					if shouldGenerate then
						printDebug("✅ Generating item:", type, "at position (", x, ",", y, ") with keyNumber:", keyNumber, "grants:", cf.grants)
						Items(x, y, type, keyNumber, cf.grants)
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
	PlayerData.isGaming = true
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	
	-- Performance: Only update cheat code when player is gaming
	if PlayerData.isGaming == true then
		cheat:update()
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
	if PlayerData.battery == 0 and PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and (PlayerData.isTalking == false and PlayerData.isCutscene == false) and PlayerData.isGaming == true then
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
	if shadow then
		shadow:removeAll()
	end
	
	for _, collider in ipairs(tileColliders) do
		collider:remove()
	end
	tileColliders = {}
	
	Graphics.sprite.removeAll()
	
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
	-- Your code here
	SaveSystem.save()
	
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
		if PlayerData.isTalking == true then
			player:displayDialog()
		elseif player.currentTrigger and PlayerData.isGaming == true then
			local trigger = player.currentTrigger
			PlayerData.isGaming = false
			PlayerData.isTalking = true
			player.dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)
			Utilities.grantAchievementIfNeeded(trigger.script)
		end
		
		-- Seleccionar item cuando está en el menú de equipamiento
		if PlayerData.isEquiping == true then
			inGameEquip:selectItem()
		end

		-- Trigger minifier if ready
		if PlayerData.readyToShrink == true and PlayerData.isGaming == true then
			player:startMinifying()
		end
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		-- Your code here
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
		-- Close equipment menu if open
		if PlayerData.isGaming == false and PlayerData.isEquiping == true then
			PlayerData.isGaming = true
			PlayerData.isEquiping = false
			inGameEquip:closeMenu()
		-- Break out of minifier if blocked
		elseif PlayerData.isGaming == false and PlayerData.readyToShrink == true then
			player:finishMinifying()
		-- Trigger ability based on selected item
		elseif PlayerData.isGaming == true and player.isAlive == true then
			player:useAbility()
		end
		player:distributeMovementTokens(5) 
		-- playerFocus() -- Commented out for ability system
	end,
	BButtonHeld = function()
		
		
	end,
	BButtonHold = function()
		
	end,
	BButtonUp = function()
		-- playerDefocus() -- Commented out for dash attack
	end,
	-- D-pad left
	--
	leftButtonDown = function()
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'left'
			scene:movePlayer('left')
		end
		if PlayerData.isEquiping == true then
			inGameEquip:prevItem()
		end
	end,
	leftButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'left') then
			scene:movePlayer('left')
		end
	end,
	leftButtonUp = function()
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
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'right'
			scene:movePlayer('right')
		end
		if PlayerData.isEquiping == true then
			inGameEquip:nextItem()
		end
	end,
	rightButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'right') then
			scene:movePlayer('right')
		end
	end,
	rightButtonUp = function()
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
		
		if ticksValue > 0 then
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
