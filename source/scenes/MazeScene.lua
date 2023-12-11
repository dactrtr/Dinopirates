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
local player = nil
local enemy = nil
local shadow = nil
local chair = nil
local cheat = CheatCode("up", "up", "up", "down")
-- This is the background color of this scene.
MazeScene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function MazeScene:init()
	MazeScene.super.init(self)
	debug = false
	cheat.onComplete = function()
		print(debug)
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
	-- border = NobleSprite("assets/images/border-map.png")
	-- border:setZIndex(1)
	-- border:moveTo(255, 120)
	-- self:addSprite(border)
	
	-- Mark: Props
	chair = PropItem(150, 150, 3)
	-- Mark: Entities
	player = Player(200, 120, 4, 1)
	enemy = Enemy(280,60,0)
	--Test
	shadow = FXshadow(player.x, player.y, player)
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
	player:idle()
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
	enemy:remove()
	
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
	end,
	leftButtonUp = function()
		
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		
	end,
	rightButtonHold = function()
		player:move("right")
		shadow:move("right")
	end,
	rightButtonUp = function()
		
	end,

	-- D-pad up
	--
	upButtonDown = function()

	end,
	upButtonHold = function()
		player:move("up")
		shadow:move("up")
	end,
	upButtonUp = function()

	end,

	-- D-pad down
	--
	downButtonDown = function()

	end,
	downButtonHold = function()
		player:move("down")
		shadow:move("down")
	end,
	downButtonUp = function()

	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		
		-- TODO: turn this into a function
		print("Battery player " .. player.battery)
		if playdate.getCrankTicks(3) > 0 then
			player.battery +=1
		
		end
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
		--ship.changeMode = true
		
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		--ship.changeMode = true
		
	end
}
