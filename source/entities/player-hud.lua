import "entities/player-face/player-eyes"
import "entities/player-face/player-mouth"
import "entities/player-face/player-body"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlayerHud').extends(gfx.sprite)

local hud = gfx.image.new("images/player/hud.png")

local eyes = PlayerEyes(58,34,status)
local mouth = PlayerMouth(70,46,status)
local Body = PlayerBody(54,41,status)


function PlayerHud:init(status)
  self:setImage(hud)
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

