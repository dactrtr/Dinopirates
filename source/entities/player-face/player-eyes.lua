local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlayerEyes').extends(gfx.sprite)

local normal = gfx.image.new("assets/player/eyes.png")
local blink = gfx.image.new("assets/player/eyes-blink.png")
local death = gfx.image.new("assets/player/eyes-death.png")

function PlayerEyes:init(x,y,status)
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
