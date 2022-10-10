InitialScene = {}
class("InitialScene").extends(NobleScene)

InitialScene.backgroundColor = Graphics.kColorWhite


local player
local toastbar
local player_hud
local enemy_1
local border 

import "entities/player"
import "entities/player-hud"
import "entities/enemy"
import "entities/toast-bar"

class('Box').extends(playdate.graphics.sprite)

function Box:draw(x, y, width, height)
    local cx, cy, width, height = self:getCollideBounds()
    Graphics.setColor(playdate.graphics.kColorWhite)
    Graphics.fillRect(cx, cy, width, height)
    Graphics.drawRect(cx, cy, width, height)
end
local function addBlock(x,y,w,h)
    local block = Box()
    block:setSize(w, h)
    block:moveTo(x, y)
    block:setCenter(0,0)
    block:addSprite()
    block:setCollideRect(0,0,w,h)
    block:setGroups(1)
end
addBlock(112, 0, 286, 12)
addBlock(112, 228, 286, 12)
addBlock(112, 12, 12, 216)
addBlock(386, 12, 12, 216)


function InitialScene:init()
	InitialScene.super.init(self)
    
    -- Mark: Entities
    player = Player(180, 80, 4, 2)
    enemy_1 = Enemy(180,120,0.3)
    enemy_2 = Enemy(280,60,0)
    toastBar = ToastBar()
    
    -- Mark: Screen & HUDS
    player_hud = PlayerHud("normal")
    

    -- Mark: Non interactive elements
    border = NobleSprite("assets/images/border.png")
    border:setZIndex(1)
    border:moveTo(255, 120)
    self:addSprite(border)
    
    -- MarK: Background/map
    tiles = Graphics.imagetable.new('assets/images/tile/tile')
    map = Graphics.tilemap.new()
    map:setImageTable(tiles)
    map:setSize(11,9)
    
    for y = 1,9 do
        for x = 1,11 do
            map:setTileAtPosition(x,y,5)
        end
    end
    
    floor = Graphics.sprite.new()
    floor:setZIndex(1)
    floor:setTilemap(map)
    floor:moveTo(256, 120)
    floor:add()
    
    
end


function InitialScene:enter()
	InitialScene.super.enter(self)

	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start()

    -- self:addSprite(player)
end

function InitialScene:start()
	InitialScene.super.start(self)

	-- menu:activate()
	-- Noble.Input.setCrankIndicatorStatus(true)


end

function InitialScene:drawBackground()
	InitialScene.super.drawBackground(self)

	-- background:draw(0, 0)
end

function InitialScene:update()
	InitialScene.super.update(self)
    
    
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

function InitialScene:exit()
	InitialScene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function InitialScene:finish()
	InitialScene.super.finish(self)
end

InitialScene.inputHandler = {

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

