
Enemy = {}
class('Enemy').extends(Graphics.sprite)

import 'entities/FX/FXsonar'

local enemy = Graphics.sprite.new()
Enemy.imagetable = Graphics.imagetable.new('assets/images/enemies/brocorat')
Enemy.animation = Graphics.animation.loop.new(100, Enemy.imagetable, true)

function Enemy:init(x, y, moveSpeed, Zindex)
  self:setImage(Enemy.animation:image())
  self:moveTo(x,y)
  self:setCollideRect(0,0, 32,32)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self:setGroups(CollideGroups.enemy)
  self:setCollidesWithGroups(
  {
    CollideGroups.player,
    CollideGroups.props,
    CollideGroups.wall
  })
  self:setZIndex(Zindex)
  self:add()
end

function Enemy:search(player)
  
  self.player = player
  
  local movementX = 0
  local movementY = 0
  

  if self.player.x <= self.x then
    movementX = self.x - self.moveSpeed
  elseif self.player.x > self.x  then
      movementX = self.x + self.moveSpeed
  end
  if self.player.y <= self.y then
    movementY = self.y - self.moveSpeed
  elseif self.player.y > self.y then
    movementY = self.y + self.moveSpeed
  end

  
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  if lenght > 0 then
    for index, collision in pairs(collisions) do
      local collideObject = collision['other']
      if collideObject:isa(Player) then
        self.player:dead()
      end
      if collideObject:isa(PropItem) then
        self:collisionResponse('slide')
      end
    end
  end
  
end

function Enemy:update()
  self:setImage(Enemy.animation:image()) 
end

function Enemy:collisionResponse()
  --return "freeze"
end

local screenImage = Graphics.image.new(80,80)

function Enemy:sonar(x,y)
  local sonar = FXsonar(self.x,self.y)
  sonar:activate(self.x,self.y)
end