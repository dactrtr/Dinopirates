
local gfx <const> = playdate.graphics

PlayerEyes = {}
class('PlayerEyes').extends(NobleSprite)

local normal = gfx.image.new("assets/images/player/eyes.png")
local blink = gfx.image.new("assets/images/player/eyes-blink.png")
local death = gfx.image.new("assets/images/player/eyes-death.png")

function PlayerEyes:init(x,y,status)
  PlayerEyes.super.init(self, "assets/images/player/body.png")

  self:setImage(normal)
  self:setZIndex(2)
  self:moveTo(x, y)
  self.status = status

  self:add()
end

function PlayerEyes:update()
  if self.status == "dead" then
    self:setImage(death)
  else
    self:setImage(normal)
  end
end
