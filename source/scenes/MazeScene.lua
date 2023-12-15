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

MazeScene = {}
class("MazeScene").extends(NobleScene)
--local scene = MazeScene

import "entities/player/player"
import "entities/player/battery"
import "entities/enemy"
import 'entities/props/propItem'
import "entities/FX/FXshadow"

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
local batteryIndicator = nil
-- Mark: enemies related
local brocorat = nil
-- Mark: environment related
local chair = nil

-- Mark: Utilities
local cheat = CheatCode("up", "up", "up", "down")
-- This is the background color of this scene.
MazeScene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function MazeScene:init()
	MazeScene.super.init(self)
	debug = false
	cheat.onComplete = function()
		
	end
	-- Mark: Background
	
	

	
	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function MazeScene:enter()
	MazeScene.super.enter(self)
	-- Your code here
	sequence = Sequence.new():from(0):to(50, 1.5, Ease.outBounce)
	sequence:start()
	tilesMap = Graphics.imagetable.new('assets/images/tile/tile')
	map = Graphics.tilemap.new()
	map:setImageTable(tilesMap)
	map:setSize(16,9)
	
	-- Mark: floor
	for y = 1,9 do
		for x = 1,16 do
			map:setTileAtPosition(x,y,5)
		end
	end
	
	floor = Graphics.sprite.new()
	floor:setZIndex(1)
	floor:setTilemap(map)
	floor:moveTo(200, 120)
	floor:add()
	
	--Mark: Walls
	addBlock(0, 0, 400, 20)
	addBlock(0, 228, 400, 12)
	addBlock(0, 12, 12, 216)
	addBlock(388, 12, 12, 216)
	-- This image need to be changed
	
	
	-- Mark: Props
	chair = PropItem(150, 150, 3)
	-- Mark: Entities
	player = Player(200, 120, 4, 1)
	shadow = FXshadow(player.x, player.y, player)
	batteryIndicator = Battery(20,10, player)
	brocorat = Enemy(280, 60, 0.7)
	--Test
	
end

-- This runs once a transition from another scene is complete.
function MazeScene:start()
	MazeScene.super.start(self)
	
end

-- This runs once per frame.
function MazeScene:update()
	MazeScene.super.update(self)
	-- Your code here
	cheat:update()
	-- Mark: Crank notification
	if player.battery == 0  and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:draw(0, 0)
	end
	
	-- Mark: Stops enemy from moving in the dark
	if player.battery == 0 then
		brocorat.moveSpeed = 0
	elseif player.battery > 60 then
		brocorat.moveSpeed = brocorat.initialSpeed
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
	--Removing all entities
	player:remove()
	floor:remove()
	shadow:remove()
	brocorat:remove()
	batteryIndicator:removeAll()
	
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
		
	end,
	BButtonHold = function()
		
	end,
	BButtonUp = function()
		
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		
	end,
	leftButtonHold = function()
		player:move("left")
		shadow:move("left")
		brocorat:search(player)
	end,
	leftButtonUp = function()
		player:idle()
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		
	end,
	rightButtonHold = function()
		player:move("right")
		shadow:move("right")
		brocorat:search(player)
	end,
	rightButtonUp = function()
		player:idle()
	end,

	-- D-pad up
	--
	upButtonDown = function()

	end,
	upButtonHold = function()
		player:move("up")
		shadow:move("up")
		brocorat:search(player)
	end,
	upButtonUp = function()
		player:idle()
	end,

	-- D-pad down
	--
	downButtonDown = function()

	end,
	downButtonHold = function()
		player:move("down")
		shadow:move("down")
		brocorat:search(player)
	end,
	downButtonUp = function()
		player:idle()
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		
		-- TODO: turn this into a function
		if playdate.getCrankTicks(3) > 0 then
			player.battery +=1
			brocorat:search(player)
		end
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
		--ship.changeMode = true
		
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		--ship.changeMode = true
		
	end
}
