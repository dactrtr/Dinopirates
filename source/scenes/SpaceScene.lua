SpaceScene = {}
class("SpaceScene").extends(NobleScene)

SpaceScene.backgroundColor = Graphics.kColorBlack


-- TODO:
-- [ ] make vector meteorites (must be like this, check animators
-- [ ] think about a cat functionality
-- [ ] add a energy system to the engine and lasers
-- [ ] move the shooting logic to the ship (?)
 
-- SCRAPPED:
-- [-] find a way to fix the Z-index order
-- [-] add rockets to the back of the ship

-- DONE:
-- [x] fix laser positions and update for a new FX instead of words, smaller than 16px maybe?
-- [x] set a limit movement to the crosshair






-- import "entities/cockpit"
import "entities/ship/ship"
import "entities/ship/crosshair"
import "entities/ship/laser"
import "entities/FX/FXlaser"
import "entities/space/meteorite"
import "entities/space/star"
import "entities/space/planets"

-- import "entities/testEntity"
local playerX = 200
local playerY = 232
local shipX = 200
local shipY = 150 
local shipSpeed = 0 -- change this value with the crank
local spaceSpeed = shipSpeed/50
-- local  = 0
-- local playerTranslation = 4

local cheat = CheatCode("up", "up", "up", "down")

laserColor =  Graphics.kColorWhite

-- MARK: Zindex
local zBG = 1
zPlanets = 2
local zFX = 10
local zMain = 12
blinkSpeed = math.random(10,500)

function SpaceScene:init()
    SpaceScene.super.init(self)
    -- Mark: Utilities
    cheat.onComplete = function()
        
     print("THATS A CHEAT CODE") 
    end
    -- Mark: Entities
    
    ship = Ship( shipX, shipY, 4, shipSpeed, zMain)
    crosshair = Crosshair( shipX, shipY - 16, 6, 6)
    
    -- Mark: Lasers
    laser = Laser(zFX)
    fxlaser = FXlaser(zFX)
    
    -- Mark: Planets
    -- p1 = Planet(math.random(20,380),math.random(20,220), "ring", math.random(1,2), ship, 40)
    -- p2 = Planet(math.random(20,380),math.random(20,220), "moon", math.random(1,2), ship, 5)
    -- p3 = Planet(math.random(20,380),math.random(20,220), "prism", 0.5, ship, 25)
    
    -- local p4 = Planet(math.random(20,380),math.random(20,220), "meteor", 1, ship, 5, 3)
    -- local p5 = Planet(math.random(20,380),math.random(20,220), "meteor", 1, ship, 8, 4)
    p6 = Planet(math.random(20,380),math.random(20,220), "meteor", 1, ship, 12, 9)
    -- Mark: Screen & HUDS
   
    -- Mark: Non interactive elements
    
    -- MarK: Background/map
    
    -- this crap has to be a vector graphics inside a iteration for more info check star.lua
    
    s10 = Star(RandomScreen("x"),RandomScreen("y"))
    s11 = Star(RandomScreen("x"),RandomScreen("y"))
    s12 = Star(RandomScreen("x"),RandomScreen("y"))
    s13 = Star(RandomScreen("x"),RandomScreen("y"))
    s14 = Star(RandomScreen("x"),RandomScreen("y"))
    s15 = Star(RandomScreen("x"),RandomScreen("y"))
    s16 = Star(RandomScreen("x"),RandomScreen("y"))
    s17 = Star(RandomScreen("x"),RandomScreen("y"))
    s18 = Star(RandomScreen("x"),RandomScreen("y"))
    s19 = Star(RandomScreen("x"),RandomScreen("y"))
    
    
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
    
    -- set custom font
    Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
    Graphics.drawText(ship.speed .. ship.mode, 2, 20)
    
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
        if(ship.mode == "fighter")then
            fxlaser:Single(shipX,shipY)
            laser:draw(laserColor,ship)
        end
        
    end,
    AButtonHold = function()			-- Runs every frame while the player is holding button down.
        -- Your code here
        if(ship.mode == "fighter")then
            fxlaser:clearFX() -- this could be inside the A press or even the entity itself
        end
        
    end,
    AButtonHeld = function()			-- Runs after button is held for 1 second.
        -- Your code here
        
    end,
    AButtonUp = function()				-- Runs once when button is released.
        -- Your code here
        print(ship.energy)
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
        ship.speed = ship.speed + 1
    end,
    BButtonUp = function()
       
    end,

    -- D-pad left
    --
    leftButtonDown = function()
        -- Your code here
        
        ship:setRotation(-20)
        if(ship.mode == "fighter")then
            fxlaser:setRotation(-20)
        end
        
    end,
    leftButtonHold = function()
        -- Your code here
        crosshair:move("left")
    end,
    leftButtonUp = function()
        -- Your code here
        
        ship:setRotation(0)
        if(ship.mode == "fighter")then
            fxlaser:setRotation(0)
        end
    end,

    -- D-pad right
    --
    rightButtonDown = function()
        -- Your code here
        ship:setRotation(20)
        if(ship.mode == "fighter")then
            fxlaser:setRotation(20)
        end
    end,
    rightButtonHold = function()
        -- Your code here
        crosshair:move("right")
    end,
    rightButtonUp = function()
        -- Your code here
        ship:setRotation(0)
        if(ship.mode == "fighter")then
            fxlaser:setRotation(0)
        end
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
        ship.changeMode = true
        crosshair.changeMode = true
        ship.mode = "fighter"
        ship:moveTo(shipX, shipY)
    end,
    crankUndocked = function()						-- Runs once when when crank is undocked.
        -- Your code here
        ship.changeMode = true
        crosshair.changeMode = true
        ship.mode = "travel"
        ship:moveTo(shipX, shipY+10)
        ship.speed = 0
    end
    
    
}

