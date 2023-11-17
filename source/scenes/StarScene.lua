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
import "entities/FX/FXspeed"
import "entities/space/meteorite"
import "entities/space/star"
import "entities/space/planets"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
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
local laser = nil
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

	cheat.onComplete = function()
		--print(debug)
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
	-- Mark: Ship
	ship = Ship( shipX, shipY, 4, shipSpeed, zMain)
	crosshair = Crosshair( shipX, shipY - 16, 6, 6)
	energyMeter = EnergyMeter(ship)
	laser = Laser(10)
	fxspeed = FXspeed()
	-- Mark: Planets
	p1 = Planet(RandomScreen("x"),RandomScreen("y"), "ring", math.random(1,2), ship, 40)
	p2 = Planet(RandomScreen("x"),RandomScreen("y"), "moon", math.random(1,2), ship, 5)
	p3 = Planet(RandomScreen("x"),RandomScreen("y"), "prism", 0.5, ship, 25)
	
	p4 = Planet(RandomScreen("x"),RandomScreen("y"), "meteor", 1, ship, 5)
	p5 = Planet(RandomScreen("x"),RandomScreen("y"), "meteor", 1, ship, 8)
	p6 = Planet(RandomScreen("x"),RandomScreen("y"), "meteor", 1, ship, 12)
end

-- This runs once per frame.
function StarScene:update()
	StarScene.super.update(self)
	debugScreen()
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
	debug = false
	--Removing all entities
	crosshair:remove()
	ship:remove()
	laser:remove()
	energyMeter:remove()
	--Removing planets
	p1:remove()
	p2:remove()
	p3:remove()
	p4:remove()
	p5:remove()
	p6:remove()
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
		if(ship.mode == "fighter")then
			--fxlaser:Single(shipX,shipY)
			laser:draw(laserColor,ship)
		end
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
		if ship.energy > 1 then
			fxspeed.animation:setState('startSpeed')
		end
	end,
	BButtonHeld = function()
		if ship.energy > 0 then
			fxspeed.animation:setState('loopSpeed')
			print("held")
		elseif ship.energy == 0 then
			fxspeed.animation:setState('stopSpeed')
			print("held 0 aqui esta el problema")
		end
	end,
	BButtonHold = function()
		if ship.energy > 0 then
			ship:boost("fighter")
			energyMeter:drain()
		end
		if ship.energy == 0 then
			fxspeed.animation:setState('stopSpeed')
			print("hold 0")
		end
	end,
	BButtonUp = function()
		if (ship.energy > 0) and (ship.speed > 0)then
			   fxspeed.animation:setState('stopSpeed')
			   print("release 0")
		   elseif ship.energy == 0 then
			   print("release 1")
			   fxspeed.animation:setState('initial')
		   end
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		ship:move("left")
		if(ship.mode == "fighter")then
			--fxlaser:setRotation(-20)
		end
	end,
	leftButtonHold = function()
		crosshair:move("left")
	end,
	leftButtonUp = function()
		ship:move("default")
		if(ship.mode == "fighter")then
			--fxlaser:setRotation(0)
		end
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		ship:move("right")
		if(ship.mode == "fighter")then
			--fxlaser:setRotation(20)
		end
	end,
	rightButtonHold = function()
		crosshair:move("right")
	end,
	rightButtonUp = function()
		ship:move("default")
		if(ship.mode == "fighter")then
			--fxlaser:setRotation(0)
		end
	end,

	-- D-pad up
	--
	upButtonDown = function()
		ship:move("up")
	end,
	upButtonHold = function()
		crosshair:move("up")
	end,
	upButtonUp = function()
		ship:move("default")
	end,

	-- D-pad down
	--
	downButtonDown = function()
		ship:move("down")
	end,
	downButtonHold = function()
		crosshair:move("down")
	end,
	downButtonUp = function()
		ship:move("default")
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		if ship.mode == "travel" and ship.energy <= 100 and playdate.getCrankTicks(3) > 0 then
			energyMeter:fill(1)
		end
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
		ship.changeMode = true
		crosshair.changeMode = true
		ship.mode = "fighter"
		ship:moveTo(shipX, shipY)
		energyMeter:resetPosition()
		playdate.stopAccelerometer()
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		ship.changeMode = true
		crosshair.changeMode = true
		ship.mode = "travel"
		ship.speed = 0 
		ship:moveTo(shipX, shipY + 20)
		playdate.startAccelerometer()
	end
}
