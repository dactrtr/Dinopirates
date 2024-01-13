
Enemy = {}
class('Enemy').extends(NobleSprite)

import 'entities/FX/FXsonar'

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

  self.animation:setState('walk')
  
  self:moveCollision(movementX, movementY, self.player)
  
end

function Enemy:moveCollision(movementX,movementY, player)
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  if lenght > 0 then
    for index, collision in pairs(collisions) do
      local collideObject = collision['other']
      if collideObject:isa(Player) then
        if self.player.isAlive then
          self.animation:setState('empty')
          self.player:dead()
        end
      end
    end
  end
end

function Enemy:update()
end

function Enemy:collisionResponse(other)
 if other:isa(Items) then
   return 'overlap'
 elseif other:isa(Box) or other:isa(PropItem) then
   return 'freeze' 
 elseif other:isa(Enemy) then
   
 else
   return 'freeze'
 end
end

local screenImage = Graphics.image.new(80,80)

function Enemy:sonar(type)
  local sonar = FXsonar(self.x,self.y)
  sonar:activate(self.x, self.y, type)
end

Brocorat = {}
class('Brocorat').extends('Enemy')

function Brocorat:init(x, y, moveSpeed, Zindex)
  Brocorat.super.init(self,'assets/images/enemies/brocorat', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 4, 4)
  self.animation.idle.frameDuration = 6
  self.animation:addState('walk', 1, 8, 'idle')
  self.animation.idle.frameDuration = 6
  self.animation:addState('empty', 9, 9)
  self.animation.idle.frameDuration = 6
  
  self:setSize(32,32)
  self:moveTo(x,y)
  self:setCollideRect(4,8, 24,24)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self:setGroups(CollideGroups.enemy)
  self:setCollidesWithGroups(
  {
    CollideGroups.player,
    CollideGroups.props,
    CollideGroups.wall,
    CollideGroups.enemy
  })
  self:setZIndex(Zindex)
  self:add(x,y)
end
