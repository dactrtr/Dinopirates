--
-- StarScene.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "StarScene" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

StarScene = {}
class("StarScene").extends(NobleScene)
--local scene = StarScene

import "entities/ship/ship"
import "entities/ship/crosshair"
import "entities/ship/laser"
import "entities/ship/energyMeter"
import "entities/FX/FXlaser"
import "entities/FX/FXspeed"
import "entities/space/meteorite"
import "entities/space/star"
import "entities/space/planets"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific varibles and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `StarScene.variable2`.
-- ...
--
local playerX = nil
local playerY = nil
local shipX = nil
local shipY = nil
local shipSpeed = nil -- change this value with the crank
local spaceSpeed = nil
local cheat = nil
-- This is the background color of this scene.
StarScene.backgroundColor = Graphics.kColorBlack

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function StarScene:init()
	StarScene.super.init(self)
	debug = false
	cheat = CheatCode("up", "up", "up", "down")
	playerX = 200
	playerY = 232
	shipX = 200
	shipY = 150 
	shipSpeed = 0 
	spaceSpeed = shipSpeed/50
	print(debug)
	-- variable1 = 100
	-- StarScene.variable2 = "string"
	-- ...
	cheat.onComplete = function()
		debug = true
		print(debug)
	end
	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function StarScene:enter()
	StarScene.super.enter(self)
	-- Your code here
	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start()
end

-- This runs once a transition from another scene is complete.
function StarScene:start()
	StarScene.super.start(self)
	-- Your code here
	ship = Ship( shipX, shipY, 4, shipSpeed, zMain)
end

-- This runs once per frame.
function StarScene:update()
	StarScene.super.update(self)
	-- Your code here
	cheat:update()
	
end

-- This runs once per frame, and is meant for drawing code.
function StarScene:drawBackground()
	StarScene.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function StarScene:exit()
	StarScene.super.exit(self)
	-- Your code here
end

-- This runs once a transition to another scene completes.
function StarScene:finish()
	StarScene.super.finish(self)
	-- Your code here
end

function StarScene:pause()
	StarScene.super.pause(self)
	-- Your code here
end


-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- scene.inputHandler = someOtherInputHandler
-- OR
StarScene.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
		-- Your code here
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
		-- Your code here
	end,
	BButtonHeld = function()
		-- Your code here
	end,
	BButtonHold = function()
		-- Your code here
	end,
	BButtonUp = function()
		-- Your code here
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		-- Your code here
	end,
	leftButtonHold = function()
		-- Your code here
	end,
	leftButtonUp = function()
		-- Your code here
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		-- Your code here
	end,
	rightButtonHold = function()
		-- Your code here
	end,
	rightButtonUp = function()
		-- Your code here
	end,

	-- D-pad up
	--
	upButtonDown = function()
		-- Your code here
	end,
	upButtonHold = function()
		-- Your code here
	end,
	upButtonUp = function()
		-- Your code here
	end,

	-- D-pad down
	--
	downButtonDown = function()
		-- Your code here
	end,
	downButtonHold = function()
		-- Your code here
	end,
	downButtonUp = function()
		-- Your code here
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		-- Your code here
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
		-- Your code here
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		-- Your code here
	end
}
