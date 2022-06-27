local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlayerMouth').extends(gfx.sprite)

local normal = gfx.image.new("assets/player/mouth.png")

function PlayerMouth:init(x,y,status)
  self:setImage(normal)
  self:setZIndex(2)
  self:moveTo(x, y)
  self.status = status
  self:add()
end

function PlayerMouth:update()
  
end
