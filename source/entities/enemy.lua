
Enemy = {}

class('Enemy').extends(Graphics.sprite)

local enemy = Graphics.sprite.new()
Enemy.imagetable = Graphics.imagetable.new('assets/images/enemies/brocorat')
Enemy.animation = Graphics.animation.loop.new(100, Enemy.imagetable, true)

function Enemy:init(x, y, moveSpeed)
  self:setImage(Enemy.animation:image())
  self:moveTo(x,y)
  self:setCollideRect(0,0, 32,32)
  self.moveSpeed = moveSpeed
  self:setGroups(1)
  self:setZIndex(2)
  
  self:add()
end

function Enemy:update()
  self:setImage(Enemy.animation:image())
  self:moveBy(-self.moveSpeed, 0)
  -- print("enemy")
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(self.x - self.moveSpeed, self.y)
  if collisions['other'] then
    print(self.x, collisions.type)
  end
  if self.x<128 then
    self:moveTo(400, self.y)
  end
end

function Enemy:collisionResponse()
  return "freeze"
end