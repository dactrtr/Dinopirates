--
-- MazeScene01.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "MazeScene01" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MazeScene01 = {
	
}
class("MazeScene01").extends(NobleScene)
--local scene = MazeScene01

import "entities/player/player"
import "entities/enemies/enemy"
import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/items/Items'
import "entities/FX/FXshadow"
import "entities/UI/playerHud"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `MazeScene01.variable2`.
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
-- Mark: Utilities
local cheat = CheatCode("up", "up", "up", "down")

-- This is the background color of this scene.
MazeScene01.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function MazeScene01:init()
	MazeScene01.super.init(self)
	debug = true
	cheat.onComplete = function()
		PlayerData.battery = 100
	end
	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function MazeScene01:enter()
	MazeScene01.super.enter(self)
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
	
	--Mark: Walls (this can be optimized)
	wallTop = Box(0, 0, 400, 20)
	wallDown = Box(0, 228, 400, 12)
	wallLeft = Box(0, 12, 12, 216)
	wallRight = Box(388, 12, 12, 216)
	-- Mark: doors
	exitTopDoor = Door('down', 'open', MazeScene, ZIndex.props)
	exitRightDoor = Door('left', 'closed',MazeScene, ZIndex.props)
	
	
	-- Mark: Props
	chair = PropItem(250, 150, ZIndex.props)
	lvlKey = Items(150, 120)
	-- Mark: Player
	player = Player(80, 80, 1, ZIndex.player)
	
	-- Mark: FX
	shadow = FXshadow(200, 120, player, 70, 0.1, ZIndex.fx)
	
	-- Mark: UI
	uiScreen = playerHud(player, true)
	
	--Test
	
end

-- This runs once a transition from another scene is complete.
function MazeScene01:start()
	MazeScene01.super.start(self)
	
end

-- This runs once per frame.
function MazeScene01:update()
	MazeScene01.super.update(self)
	-- Mark: DEBUG
	debugScreenMaze(player)
	
	-- Mark: cheat code
	cheat:update()
	
	-- Mark: Crank notification
	if PlayerData.battery == 0  and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:draw(0, 0)
	end
	-- Mark: Stops enemy from moving in the dark
	
	
end


-- This runs once per frame, and is meant for drawing code.
function MazeScene01:drawBackground()
	MazeScene01.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function MazeScene01:exit()
	MazeScene01.super.exit(self)
	debug = false

end

-- This runs once a transition to another scene completes.
function MazeScene01:finish()
	MazeScene01.super.finish(self)
	-- Your code here
end

function MazeScene01:pause()
	MazeScene01.super.pause(self)
	-- Your code here
end

-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- scene.inputHandler = someOtherInputHandler
-- OR
MazeScene01.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
		if PlayerData.battery > 20 then
			brocorat:sonar('enemy')	-- Make it a update method
			frogcolli:sonar('enemy')
			lvlKey:sonar('key')
			player:drainBattery(20)
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