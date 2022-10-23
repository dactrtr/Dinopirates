SpaceScene = {}
class("SpaceScene").extends(NobleScene)

SpaceScene.backgroundColor = Graphics.kColorWhite


local playerCockpit
local toastbar
local player_hud
local enemy_1
local border 

import "entities/playerCockpit"

class('Box').extends(playdate.graphics.sprite)




function SpaceScene:init()
    SpaceScene.super.init(self)
    
    -- Mark: Entities
    player = PlayerCockpit(200, 220, 4, 2)
    
    -- Mark: Screen & HUDS
    

    -- Mark: Non interactive elements

    border = NobleSprite("assets/images/border-space.png")
    border:setZIndex(1)
    border:moveTo(255, 120)
    self:addSprite(border)
    
    -- MarK: Background/map
    
end


function SpaceScene:enter()
    SpaceScene.super.enter(self)

    sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
    sequence:start()

    -- self:addSprite(player)
end

function SpaceScene:start()
    SpaceScene.super.start(self)

    -- menu:activate()
    -- Noble.Input.setCrankIndicatorStatus(true)


end

function SpaceScene:drawBackground()
    SpaceScene.super.drawBackground(self)

    -- background:draw(0, 0)
end

function SpaceScene:update()
    SpaceScene.super.update(self)
    
    
    -- Graphics.clear()
    -- gfx.sprite.update()
    -- border:draw(112,0)
    -- local collisions = gfx.sprite.allOverlappingSprites()
    -- if collisions[1] then
    --     player_hud.status = "dead"
    --     toastbar.toasts =  toastbar.toasts - 1
        
    -- elseif collisions[1] == nil then
    --     player_hud.status = "normal"
    -- end
    -- -- print(collisions[1])
    

    -- -- for i=1,6 do
    -- --   card_Holder:draw(0,100+20*i)
    -- -- end

    -- Graphics.drawText("TEST", 20, 104)
    -- pd.drawFPS(380, 10)

end

function SpaceScene:exit()
    SpaceScene.super.exit(self)

    Noble.Input.setCrankIndicatorStatus(false)
    sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
    sequence:start();

end

function SpaceScene:finish()
    SpaceScene.super.finish(self)
end

SpaceScene.inputHandler = {

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

