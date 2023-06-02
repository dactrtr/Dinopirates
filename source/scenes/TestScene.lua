TestScene = {}
class("TestScene").extends(NobleScene)

TestScene.backgroundColor = Graphics.kColorWhite

function TestScene:init()
	TestScene.super.init(self)
    
    
    
end


function TestScene:enter()
	TestScene.super.enter(self)

	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start()

    -- self:addSprite(player)
end

function TestScene:start()
	TestScene.super.start(self)

	-- menu:activate()
	-- Noble.Input.setCrankIndicatorStatus(true)


end

function TestScene:drawBackground()
	TestScene.super.drawBackground(self)

	-- background:draw(0, 0)
end

function TestScene:update()
	TestScene.super.update(self)
end

function TestScene:exit()
	TestScene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function TestScene:finish()
	TestScene.super.finish(self)
end

TestScene.inputHandler = {

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

