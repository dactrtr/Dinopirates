class('PlayerBody').extends(Graphics.sprite)

local normal = Graphics.image.new("assets/images/player/body.png")

function PlayerBody:init(x, y, status)
  self:setImage(normal)
  self:setZIndex(1)
  self:moveTo(x, y)
  self.status = status

  self:add()
end

function PlayerBody:update()
  
end
