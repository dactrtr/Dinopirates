--
-- DeadScene.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "DeadScene" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




DeadScene = {}
class("DeadScene").extends(NobleScene)
local scene = DeadScene

local menu
local crankTick = 0
local bg = nil



-- It is recommended that you declare, but don't yet define,
-- your scene-specific varibles and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `DeadScene.variable2`.
-- ...
--

-- This is the background color of this scene.
scene.backgroundColor = Graphics.kColorWhite

DeadScene.inputHandler = {
	upButtonDown = function()
		menu:selectPrevious()
	end,
	downButtonDown = function()
		menu:selectNext()
	end,
	cranked = function(change, _)
		crankTick = crankTick + change
		if crankTick > Config.Input.crankMenuThreshold then
			crankTick = 0
			menu:selectNext()
		elseif crankTick < -Config.Input.crankMenuThreshold then
			crankTick = 0
			menu:selectPrevious()
		end
	end,
	AButtonDown = function()
		menu:click()
	end
}

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function scene:init()
	scene.super.init(self)
	bg = Graphics.image.new('assets/images/screens/dead-screen.png')
	menu = Noble.Menu.new(
		true,
		Noble.Text.ALIGN_RIGHT,
		false,
		nil,
		2,16
	)
	menu:addItem("Exit", function() 
		Noble.transition(TitleScene) 
	end)
	menu:addItem("Retry", function()
		RunState.startRun()
		Noble.transition(MazeScene)
	 end)
	menu:select("Exit")
	
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)
	-- Your code here
end

-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
	-- Your code here
	
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	local msg = "they caught you"
	if PlayerData.deathCause == "sanity" then
		msg = "you lost your mind"
	elseif PlayerData.deathCause == "void" then
		msg = "you fell into the void"
	end
	if bg then
		Graphics.lockFocus(bg)
			Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
			Graphics.drawText(msg, 2, 220)
		Graphics.unlockFocus()
		bg:draw(0, 0)
	else
		-- No dead-screen art yet: draw the message directly on the scene background.
		Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
		Graphics.drawText(msg, 2, 220)
	end
	menu:draw(400, 60)
end

-- This runs once per frame, and is meant for drawing code.
function scene:drawBackground()
	scene.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
	-- Your code here
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	-- Your code here
end

function scene:pause()
	scene.super.pause(self)
	-- Your code here
end
function scene:resume()
	scene.super.resume(self)
	-- Your code here
end