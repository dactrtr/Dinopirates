
class('PlayerMouth').extends(Graphics.sprite)

local normal = Graphics.image.new("assets/images/player/mouth.png")

function PlayerMouth:init(x,y,status)
  
  self:setImage(normal)
  self:setZIndex(2)
  self:moveTo(x, y)
  self.status = status

  self:add()
end

function PlayerMouth:update()
  
end
