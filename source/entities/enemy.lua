
Enemy = {}

class('Enemy').extends(Graphics.sprite)

local enemy = Graphics.sprite.new()
Enemy.imagetable = Graphics.imagetable.new('assets/images/enemies/brocorat')
Enemy.animation = Graphics.animation.loop.new(100, Enemy.imagetable, true)

function Enemy:init(x, y, moveSpeed, Zindex)
  self:setImage(Enemy.animation:image())
  self:moveTo(x,y)
  self:setCollideRect(0,0, 32,32)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self:setGroups(1)
  self:setZIndex(Zindex)
  self:add()
end

function Enemy:search(player)
  
  self.player = player
  
  if self.player.x < self.x then
    self:moveBy(-self.moveSpeed,0)
  elseif self.player.x > self.x then
    self:moveBy(self.moveSpeed,0)
  elseif self.player.x == self.x then
    -- maybe animation?
  end
  
  if self.player.y > self.y then
    self:moveBy(0,self.moveSpeed)
  elseif self.player.y < self.y then
    self:moveBy(0,-self.moveSpeed)
  elseif self.player.y == self.y then
  -- maybe animation?
  
  end
end

function Enemy:update()
  self:setImage(Enemy.animation:image())
  
  -- local actualX, actualY, collisions, lenght = self:moveWithCollisions(self.x - self.moveSpeed, self.y)
  
  -- if collisions['other'] then
  --   print(self.x, collisions.type)
  -- end
  
end

function Enemy:collisionResponse()
  --return "freeze"
end