SpaceScene = {}
class("SpaceScene").extends(NobleScene)

SpaceScene.backgroundColor = Graphics.kColorBlack


-- TODO:
-- [ ] make vector meteorites (must be like this)
-- [x] set a limit movement to the crosshair
-- [ ] fix laser positions and update for a new FX instead of words, smaller than 16px maybe?
-- [-] add rockets to the back of the ship
-- [ ] think about a cat functionality


-- import "entities/cockpit"
import "entities/ship/ship"
import "entities/ship/crosshair"
import "entities/ship/laser"
import "entities/FX/FXlaser"

-- import "entities/testEntity"


local playerX = 200
local playerY = 232
local shipX = 200
local shipY = 150 --change this value with the crank
-- local  = 0
local playerTranslation = 4

local cheat = CheatCode("up", "up", "up", "down")

laserColor =  Graphics.kColorWhite

function SpaceScene:init()
    SpaceScene.super.init(self)
    -- Mark: Utilities
    cheat.onComplete = function()
        
     print("THATS A CHEAT CODE") 
     -- laserBlink = Graphics.KColorWhite
    end
    -- Mark: Entities
    
    ship = Ship( shipX, shipY, 4, "default", 6)
    crosshair = Crosshair( shipX, shipY - 16, 6, 6)
    
    -- Mark: Lasers
    laser = Laser()
    fxlaser = FXlaser()
    
    -- Mark: meteorites (should have their own function and be generated randomly in each init) or a animation of a space   
    
    -- Mark: Screen & HUDS
   
    -- Mark: Non interactive elements
    
    -- MarK: Background/map
    
    -- Mark: weird functions
    
    -- test = TestEntity()
end


function SpaceScene:enter()
    SpaceScene.super.enter(self)

    sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
    sequence:start()

end

function SpaceScene:start()
    SpaceScene.super.start(self)

end

function SpaceScene:drawBackground()
    SpaceScene.super.drawBackground(self)

end

function SpaceScene:update()
    cheat:update()
    SpaceScene.super.update(self)
   
   
    -- background
    
    
    
    
    
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
        
        fxlaser:Single(shipX,shipY)
        -- fxlaser02:Single(ship.shooter02.x,ship.shooter02.y)
       --  fxlaser03:Single(ship.shooter03.x, ship.shooter03.y)
        -- fxlaser04:Single(ship.shooter04.x, ship.shooter04.y)
        
        laser:draw(laserColor,ship)
        
    end,
    AButtonHold = function()			-- Runs every frame while the player is holding button down.
        -- Your code here
        
        fxlaser:clearFX() -- this could be inside the A press or even the entity itself
       
        
    end,
    AButtonHeld = function()			-- Runs after button is held for 1 second.
        -- Your code here
        
    end,
    AButtonUp = function()				-- Runs once when button is released.
        -- Your code here
        
        fxlaser:clearFX()
      
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
        fxlaser:setRotation(-20)
        -- cockpit:setRotation(20)
        -- player:setRotation(20)
    end,
    leftButtonHold = function()
        -- Your code here
        crosshair:move("left")
       -- meteorite:moveBy(playerTranslation, 0)
    end,
    leftButtonUp = function()
        ship:setRotation(0)
        fxlaser:setRotation(0)
    end,

    -- D-pad right
    --
    rightButtonDown = function()
        -- Your code here
        ship:setRotation(20)
        fxlaser:setRotation(20)
    end,
    rightButtonHold = function()
        -- Your code here
        crosshair:move("right")
    end,
    rightButtonUp = function()
        ship:setRotation(0)
        fxlaser:setRotation(0)
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
        -- meteorite:moveBy(0, -playerTranslation)
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

