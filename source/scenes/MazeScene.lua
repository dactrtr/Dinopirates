--
-- MazeScene.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "MazeScene" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MazeScene = {
}
class("MazeScene").extends(NobleScene)
--local scene = MazeScene
local room = 1 -- Level in table position

import "entities/player/player"
import "entities/enemies/enemy"
import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/items/Items'
import "entities/FX/FXshadow"
import "entities/UI/playerHud"
import "entities/UI/map"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `MazeScene.variable2`.
-- ...
--

-- Mark: player related
local player = nil
local shadow = nil
-- Mark: enemies related
local brocorat = nil
-- Mark: environment related
local chair = nil
local chair1 = nil
local exitTopDoor = nil
local exitDownDoor = nil
local exitLeftDoor = nil
local exitRightDoor = nil
-- Mark: Key items
local lvlKey = nil
-- Mark: UI
local uiScreen = nil
local map = nil
-- Mark: Utilities
local cheat = CheatCode("up", "up", "up", "down")

-- This is the background color of this scene.
MazeScene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitioning away from another scene.
function MazeScene:init()
	MazeScene.super.init(self)
	debug = levels[room].floor.debug
	cheat.onComplete = function()
		PlayerData.battery = 100
	end
	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function MazeScene:enter()
	MazeScene.super.enter(self)
	-- Your code here
	sequence = Sequence.new():from(0):to(50, 1.5, Ease.outBounce)
	sequence:start()
	
	PlayerData.room = levels[room].floor.floorNumber
	rooms[PlayerData.room].visited = true
	
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
	exitTopDoor = Door('top', 'open', TitleScene, ZIndex.props)
	exitLeftDoor = Door('left', 'open',MazeScene ,ZIndex.props)
	exitRightDoor = Door('right', 'open',MazeScene01 ,ZIndex.props)
	exitDownDoor = Door('down', 'open',MazeScene01 ,ZIndex.props)
	
	-- Mark: Props
	chair = PropItem(250, 150, ZIndex.props)
	lvlKey = Items(150, 120)
	-- Mark: Player
	player = Player(80, 80, 1, ZIndex.player)
	
	-- Mark: FX
	shadow = FXshadow(200, 120, player, 70,levels[room].floor.light, ZIndex.fx)
	
	-- Mark: UI
	uiScreen = playerHud(player, true)
	map = Map()
	-- Mark: Enemies from table
	local enemies = levels[room].floor.enemies
	
	for _, enemyData in ipairs(enemies) do
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
	--Test
	
end

-- This runs once a transition from another scene is complete.
function MazeScene:start()
	MazeScene.super.start(self)
	
end

-- This runs once per frame.
function MazeScene:update()
	MazeScene.super.update(self)
	-- Mark: DEBUG
	-- Mark: cheat code
	cheat:update()
	
	-- Mark: Crank notification
	if PlayerData.battery == 0  and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:draw(0, 0)
	end
	
	
end


-- This runs once per frame, and is meant for drawing code.
function MazeScene:drawBackground()
	MazeScene.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function MazeScene:exit()
	MazeScene.super.exit(self)
	debug = false
	rooms[PlayerData.room].visited = false
end

-- This runs once a transition to another scene completes.
function MazeScene:finish()
	MazeScene.super.finish(self)
	-- Your code here
end

function MazeScene:pause()
	MazeScene.super.pause(self)
	-- Your code here
end

-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- scene.inputHandler = someOtherInputHandler
-- OR
MazeScene.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		-- Your code here
	end,
	AButtonUp = function()				-- Runs once when button is released.
		-- Your code here
	end,

	-- B button
	--
	BButtonDown = function()
		
	end,
	BButtonHeld = function()
		
		player.loadingPower = true
	end,
	BButtonHold = function()
	end,
	BButtonUp = function()
		player.loadingPower = false
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		
	end,
	leftButtonHold = function()
		if player.isAlive then
			player:move("left")
			shadow:move("left")
		end
	end,
	leftButtonUp = function()
		player:idle()
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		
	end,
	rightButtonHold = function()
		if player.isAlive then
			player:move("right")
			shadow:move("right")
		end
	end,
	rightButtonUp = function()
		player:idle()
	end,

	-- D-pad up
	--
	upButtonDown = function()

	end,
	upButtonHold = function()
		if player.isAlive then
			player:move("up")
			shadow:move("up")
		end
	end,
	upButtonUp = function()
		player:idle()
	end,

	-- D-pad down
	--
	downButtonDown = function()

	end,
	downButtonHold = function()
		if player.isAlive then
			player:move("down")
			shadow:move("down")
		end
	end,
	downButtonUp = function()
		player:idle()
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
