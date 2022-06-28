PlayerBody = {}
class('PlayerBody').extends(NobleSprite)

function PlayerBody:init(x, y, status)
  PlayerBody.super.init(self, "assets/images/player/body.png")
  
  self:setZIndex(1)
  self:moveTo(x, y)
  self.status = status

  self:add()
end

function PlayerBody:update()
  
end
