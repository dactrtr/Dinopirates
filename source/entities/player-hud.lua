import "entities/player-face/player-eyes"
import "entities/player-face/player-mouth"
import "entities/player-face/player-body"

class('PlayerHud').extends(Graphics.sprite)





function PlayerHud:init(status)
  self.status = status
  local normal = Graphics.image.new("assets/images/player/hud.png")
  self:setImage(normal)
  self:moveTo(56, 40)
  local eyes = PlayerEyes(58,38, status)
  local mouth = PlayerMouth(70,50, status)
  local Body = PlayerBody(60,41, status)
  self:add()
end

function PlayerHud:update()
  -- if self.status=="dead" then
  --   eyes.status = "dead"
  -- else
  --   eyes.status = "normal"
  -- end
end

