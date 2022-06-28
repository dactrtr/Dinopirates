InitialScene = {}
class("InitialScene").extends(NobleScene)

InitialScene.baseColor = Graphics.kColorWhite

local player
local toastbar
local player_hud
local enemy_1
local enemy_2
local enemy_3
local border

-- import "CoreLibs/graphics"
-- import "CoreLibs/object"
-- import "CoreLibs/sprites"
-- import "CoreLibs/animation"

import "entities/player"
-- import "entities/player-hud"
-- import "entities/enemy"
-- import "entities/toast-bar"

local pd <const> = playdate
local gfx <const> = pd.graphics

function InitialScene:init()
	InitialScene.super.init(self)

    player = Player(180, 80, 4, 4)

    -- toastbar = ToastBar(player.toasts)
    -- player_hud = PlayerHud("normal")

    -- enemy_1 = Enemy(150, 80, 1)
    -- enemy_2 = Enemy(430,60, 3)
    -- enemy_3 = Enemy(410,80, 2)

    -- Mark: assets
    border = NobleSprite("assets/images/border.png")
    border:setZIndex(1)
    border:moveTo(255, 120)
    self:addSprite(border)

    -- self.addSprite(player_hud)

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

    -- gfx.clear()
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

    -- gfx.drawText("TEST", 20, 104) -- make text smaller
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


