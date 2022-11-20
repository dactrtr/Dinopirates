SpaceScene = {}
class("SpaceScene").extends(NobleScene)

SpaceScene.backgroundColor = Graphics.kColorBlack

local playerCockpit
local player_hud
local enemy_1
local border

-- TODO:
-- make vector meteorites
-- set a limit movement to the crosshair
-- review the bottom UI (maybe is using too much space just for nothing)

import "entities/cockpit"
import "entities/ship/ship"
import "entities/player/player"
import "entities/ship/crosshair"
import "entities/meteorite"

class('Box').extends(playdate.graphics.sprite)

local playerX = 200
local playerY = 232
local shipX = 200
local shipY = 120
local playerSpeed = 1
local playerTranslation = 4
local cheat = CheatCode("up", "up", "up")


function SpaceScene:init()
    SpaceScene.super.init(self)
    -- Mark: Entities
    cockpit = Cockpit( playerX, playerY, 4)
    ship = Ship( shipX, shipY, 4, "default")
    player = Player( playerX, playerY , 4, 0)
    crosshair = Crosshair( shipX, shipY-24, 6, 6)
    -- Mark: meteorites (should have their own function and be generated randomly in each init)
    meteorite = Meteorite( 50, 50, playerSpeed)
    meteorite2 = Meteorite( 100, 100, playerSpeed)
    meteorite2:setImageFlip("flipX")
    -- Mark: Screen & HUDS
    border = NobleSprite("assets/images/border-space.png")
    border:setZIndex(1)
    border:moveTo( 200, 120)
    self:addSprite(border)
    -- Mark: Non interactive elements
    
    -- MarK: Background/map
    cheat.onComplete = function() print("cheat") end
    
    
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
    playdate.timer.updateTimers() -- uses timers so make sure you call this
    cheat:update()
    SpaceScene.super.update(self)
    meteorite:zoom(playerSpeed)
    meteorite2:zoom(playerSpeed + 100)
    -- fake timer
    if (playerSpeed > 0) then
        playerSpeed = playerSpeed + 1
    end
    if (playerSpeed > 1000) then
        playerSpeed = 0
    end 
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
        ship:setRotation(-20)
        -- cockpit:setRotation(20)
        -- player:setRotation(20)
    end,
    leftButtonHold = function()
        -- Your code here
        crosshair:move("left")
        meteorite:moveBy(playerTranslation, 0)
        meteorite2:moveBy(playerTranslation, 0)
    end,
    leftButtonUp = function()
        ship:setRotation(0)
    end,

    -- D-pad right
    --
    rightButtonDown = function()
        -- Your code here
        ship:setRotation(20)
        
    end,
    rightButtonHold = function()
        -- Your code here
        crosshair:move("right")
        meteorite:moveBy(-playerTranslation, 0)
        meteorite2:moveBy(-playerTranslation, 0)
    end,
    rightButtonUp = function()
        ship:setRotation(0)
    end,

    -- D-pad up
    --
    upButtonDown = function()
        -- Your code here
        ship:move("up")
    end,
    upButtonHold = function()
        -- Your code here
        crosshair:move("up")
        meteorite:moveBy(0, -playerTranslation)
        meteorite2:moveBy(0, -playerTranslation)
    end,
    upButtonUp = function()
        ship:move("default")
    end,

    -- D-pad down
    --
    downButtonDown = function()
        -- Your code here
        ship:move("down")
    end,
    downButtonHold = function()
        -- Your code here
        crosshair:move("down")
        meteorite:moveBy(0, playerTranslation)
        meteorite2:moveBy(0, playerTranslation)
    end,
    downButtonUp = function()
        ship:move("default")
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

