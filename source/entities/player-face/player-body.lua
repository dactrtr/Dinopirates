local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlayerBody').extends(gfx.sprite)

local normal = gfx.image.new("images/player/body.png")

function PlayerBody:init(x,y,status)
  self:setImage(normal)
  self:setZIndex(1)
  self:moveTo(x, y)
  self.status = status
  self:add()
end

function PlayerBody:update()
  
end
