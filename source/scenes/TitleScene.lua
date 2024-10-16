

TitleScene = {}
class("TitleScene").extends(NobleScene)
local scene = TitleScene

local menu
local crankTick = 0
local bg <const> = Graphics.image.new('assets/images/screens/title-screen.png')
local background <const> = Graphics.sprite.new(bg)
background:moveTo(200,120)


scene.backgroundColor = Graphics.kColorWhite

TitleScene.inputHandler = {
	upButtonDown = function()
		menu:selectPrevious()
	end,
	downButtonDown = function()
		menu:selectNext()
	end,
	cranked = function(change, _)
		crankTick = crankTick + change
		if crankTick > 30 then
			crankTick = 0
			menu:selectNext()
		elseif crankTick < -30 then
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
	-- Check save game
	if playdate.file.exists('playerSave.json') == false then
		playdate.datastore.write(levels, 'levelOriginal', true)
		playdate.datastore.write(PlayerData, 'playerOriginal', true)
	end
	menu = Noble.Menu.new(
			true,
			Noble.Text.ALIGN_LEFT,
			false,
			nil,
			2,16
		)
	
		--menu:addItem("Old Space", function() Noble.transition(SpaceScene) end)
		menu:addItem("New Game", function()
			ResetGame()
			Noble.transition(Floor107)--107 
		 end)
		
		if playdate.file.exists('playerSave.json') == true then
			LoadGame()
			menu:addItem("Continue", function() 
				Noble.transition(RoomTranslate(PlayerData.saveLevel)) 
			end)
		end
		--menu:addItem("Test", function() Noble.transition(TestScene) end)
		menu:select("New Game")
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)
	-- Your code here
	PlayerData.isGaming = false
	self:addSprite(background)
end

-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
	-- Your code here
	
end

-- This runs once per frame.


function scene:update()
	scene.super.update(self)
	-- Your code here
	menu:draw(8, 120)
	Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
	--Graphics.setColor(playdate.graphics.kColorWhite)
	Graphics.drawText("*v 0.1*", 2, 2)
end

-- This runs once per frame, and is meant for drawing code.
-- function scene:drawBackground()
-- 	scene.super.drawBackground(self)
-- 	-- Your code here
-- end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
	-- Your code here
	--Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	-- Your code here
	Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

function scene:pause()
	scene.super.pause(self)
	-- Your code here
end
function scene:resume()
	scene.super.resume(self)
	-- Your code here
end


