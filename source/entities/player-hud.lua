import "entities/player-face/player-eyes"
import "entities/player-face/player-mouth"
import "entities/player-face/player-body"


class('PlayerHud').extends(Graphics.sprite)

local eyes = PlayerEyes(58,34, status)
local mouth = PlayerMouth(70,46, status)
local Body = PlayerBody(54,41, status)

local normal = Graphics.image.new("assets/images/player/hud.png")


function PlayerHud:init(status)
  self:setImage(normal)
  self:moveTo(56, 40)
  self.status = status

  self:add()
end

function PlayerHud:update()
  if self.status=="dead" then
    eyes.status = "dead"
  else
    eyes.status = "normal"
  end
end

