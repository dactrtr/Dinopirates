
PlayerMouth = {}
class('PlayerMouth').extends(NobleSprite)

function PlayerMouth:init(x,y,status)
  PlayerMouth.super.init(self, "assets/images/player/mouth.png")

  self:setZIndex(2)
  self:moveTo(x, y)
  self.status = status

  self:add()
end

function PlayerMouth:update()
  
end
