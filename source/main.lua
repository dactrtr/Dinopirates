-- import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"


import "entities/player"
import "entities/player-hud"
import "entities/enemy"
import "entities/toast-bar"

local pd <const> = playdate
local gfx <const> = pd.graphics

player = Player(180,80,4,4)
toastbar = ToastBar(player.toasts)
player_hud = PlayerHud("normal")

enemy_1 = Enemy(150, 80, 1)
enemy_2 = Enemy(430,60, 3)
enemy_3 = Enemy(410,80, 2)

-- Mark: assets
border = gfx.image.new("assets/border.png")

function pd.update() 
  gfx.clear()
  gfx.sprite.update()
  border:draw(112,0)
  local collisions = gfx.sprite.allOverlappingSprites()
  if collisions[1] then
    player_hud.status = "dead"
    toastbar.toasts -= 1
    
  elseif collisions[1] == nil then
    player_hud.status = "normal"
  end
  
  -- print(collisions[1])
 

  -- for i=1,6 do
  --   card_Holder:draw(0,100+20*i)
  -- end

  gfx.drawText("Cards List", 20, 104) -- make text smaller
  pd.drawFPS(380, 10)
		
end

