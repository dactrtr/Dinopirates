InitialScene = {}
class("InitialScene").extends(NobleScene)

InitialScene.backgroundColor = Graphics.kColorWhite


local player
local toastbar
local player_hud
local enemy_1
local enemy_2
local enemy_3
local border


import "entities/player"
import "entities/player-hud"
import "entities/toast-bar"



function InitialScene:init()
	InitialScene.super.init(self)

    player = Player(180, 80, 4, 4)

    toastbar = ToastBar(player.toasts)

    player_hud = PlayerHud("normal")


    -- Mark: assets
    border = NobleSprite("assets/images/border.png")
    border:setZIndex(1)
    border:moveTo(255, 120)
    self:addSprite(border)
    -- TODO: add colision borders and set as a class
    
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

    -- Graphics.drawText("TEST", 20, 104) -- make text smaller
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
        -- Your code here
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
        -- Your code here
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
        -- Your code here
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
        -- Your code here
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
        -- Your code here
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

