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

import "entities/player/player"
import "entities/enemies/enemy"
import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/items/Items'
import 'entities/props/trigger'
import "entities/FX/FXshadow"
import "entities/UI/playerHud"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `scene.variable2`.
-- ...
--



-- Mark: player related
local player = nil
local shadow = nil

-- Mark: UI
local uiScreen = nil
-- Mark: Utilities
local cheat = CheatCode("up", "up", "up", "down")

-- This is the background color of this scene.
scene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitioning away from another scene.
function scene:init()
	scene.super.init(self)
	
	cheat.onComplete = function()
	end
	
	-- Your code here
	
end
function scene:setFloor(floor)
	room = floor
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)
	-- Your code here
	
	
	PlayerData.isGaming = true
	sequence = Sequence.new():from(0):to(50, 1.5, Ease.outBounce)
	sequence:start()
	
	PlayerData.room = levels[room].floor.floorNumber
	PlayerData.isInDarkness = levels[room].floor.shadow
	PlayerData.floor = room
	
	PlayerData.actualLevel = levels[room].floor.level
	PlayerData.actualRoom = levels[room].floor.floorNumber
	levels[room].floor.visited = true
	
	-- Mark: floor
	tilesMap = Graphics.imagetable.new('assets/images/tile/tile')
	map = Graphics.tilemap.new()
	map:setImageTable(tilesMap)
	map:setSize(16,9)
	
	-- Mark: floor 
	for y = 1, 9 do
		for x = 1, 16 do
			map:setTileAtPosition(x, y, levels[room].floor.tile)
		end
	end
	
	floor = Graphics.sprite.new()
	floor:setZIndex(1)
	floor:setTilemap(map)
	floor:moveTo(200, 120)
	floor:add()
	
	--Mark: Walls (this can be optimized)
	wallTop = Box(0, 0, 400, 20)
	wallDown = Box(0, 228, 400, 12)
	wallLeft = Box(0, 12, 12, 216)
	wallRight = Box(388, 12, 12, 216)
	
	-- Mark: doors
	local arrayData = levels[room].floor.doors -- Used several times to save variables
	
	for _, doorData in ipairs(arrayData) do
		local direction = doorData.direction
		local open = doorData.open
		local leads = doorData.leadsTo
	
		Door(direction, open, leads, ZIndex.props)
	end
	
	
	-- Mark: Props 
	arrayData = levels[room].floor.props
	
	for _, propData in ipairs(arrayData) do
		local type = propData.type
		local x = propData.x
		local y = propData.y
		local collide = propData.nocollide
		PropItem(x, y, type, ZIndex.props, collide)
	end
	
	-- Mark: Items
	arrayData = levels[room].floor.items
	for _, itemData in ipairs(arrayData) do
		local type = itemData.type
		local x = itemData.x
		local y = itemData.y
		if (type == 'keycard' and PlayerData.hasKey == false) or (type == 'lamp' and PlayerData.hasLamp == false) or (type == 'radio' and PlayerData.hasRadio == false) then
			Items(x, y, type)
		end
	end
	
	-- Mark: Player
	local spawnPoint = PlayerData.playerSpawn
	player = Player(spawnPoint.x, spawnPoint.y, PlayerData.speed, ZIndex.player)
	PlayerData.x = player.x
	PlayerData.y = player.y
	PlayerData.direction = 'idle'
	-- Mark: FX
	if levels[room].floor.shadow == true then
		shadow = FXshadow(player, 70, 0.08, ZIndex.fx)
	else
		--player:fillBattery() -- Mark: dunno why I ws fillin the battery instantly
	end
	
	-- Mark: UI
	uiScreen = playerHud()
	
	-- Mark: Enemies 
	arrayData = levels[room].floor.enemies
	
	for _, enemyData in ipairs(arrayData) do
		local name = enemyData.name
		local x = enemyData.x
		local y = enemyData.y
		local speed = enemyData.speed
	
		if name == "brocorat" then
			Brocorat(x, y, speed, ZIndex.enemy, player)
		elseif name == "frogcolli" then
			Frogcolli(x, y, speed, ZIndex.enemy, player)
		end
	end
	
	-- Mark: dialog triggers
	
	arrayData = levels[room].floor.triggers
	for i, triggerData in ipairs(arrayData) do
		if triggerData.usedTrigger == false then
			local x = triggerData.x
			local y = triggerData.y
			local width = triggerData.width
			local height = triggerData.height
			local script = triggerData.script
			Trigger(x,y,width,height,script, i, room)
		end
	end
end

-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
	
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	-- Mark: cheat code
	cheat:update()
	
	-- Mark: Crank notification
	if PlayerData.battery == 0  and playdate.isCrankDocked() and PlayerData.hasLamp == true then
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
	
	SaveGame()
	

	
	uiScreen:removeAll()
	floor:remove()
	if shadow then
		shadow:removeAll()
	end
	
	Graphics.sprite.removeAll()
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	-- Your code here
	PlayerData.isGaming = false
end

function scene:pause()
	scene.super.pause(self)
	-- Your code here
	SaveGame()
	
end
function scene:movePlayer(direction)
	if PlayerData.isTalking == false then
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
		--print((script[1].dialog[1].text))
		if PlayerData.isTalking == true then
			player:displayDialog()
		end
		-- if PlayerData.hasRadio == true  then
		-- 	PlayerData.sonarActive = true
		-- end
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		-- Your code here
	end,
	AButtonUp = function()				-- Runs once when button is released.
		-- Your code here
		-- if PlayerData.hasRadio == true  then
		-- 	PlayerData.sonarActive = false
		-- end
	end,

	-- B button
	--
	BButtonDown = function()
	
	end,
	BButtonHeld = function()
		
		player.loadingPower = true
		player:focus()
	end,
	BButtonHold = function()
	end,
	BButtonUp = function()
		player.loadingPower = false
		player:deFocus()
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		
	end,
	leftButtonHold = function()
		scene:movePlayer('left')
	end,
	leftButtonUp = function()
		player:idle()
		if shadow then
			shadow:refresh()
		end
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		
	end,
	rightButtonHold = function()
		scene:movePlayer('right')
	end,
	rightButtonUp = function()
		player:idle()
		if shadow then
			shadow:refresh()
		end
	end,

	-- D-pad up
	--
	upButtonDown = function()

	end,
	upButtonHold = function()
		scene:movePlayer('up')
	end,
	upButtonUp = function()
		player:idle()
		if shadow then
			shadow:refresh()
		end
	end,

	-- D-pad down
	--
	downButtonDown = function()

	end,
	downButtonHold = function()
		scene:movePlayer('down')
	end,
	downButtonUp = function()
		player:idle()
		if shadow then
			shadow:refresh()
		end
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		if player.isAlive then
			-- TODO: turn this into a function
			if playdate.getCrankTicks(3) > 0 then
				if player.loadingPower == true then
					print('powa') 
				else
					player:chargeBattery(1)
					if shadow then
						shadow:refresh()
					end
				end
			end
			if player.battery == 100 then
				player:idle()
			end
			
		end
		
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		
	end
}
