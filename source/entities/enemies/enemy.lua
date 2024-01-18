
Enemy = {}
class('Enemy').extends(NobleSprite)

import 'entities/FX/FXsonar'

function Enemy:blindSearch(player)
  
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
function Enemy:linealSearch(player)
    -- print('lineal')
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

function Enemy:updateSound(player)
  --print(player.x)
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

function Brocorat:init(x, y, moveSpeed, Zindex, player)
  Brocorat.super.init(self,'assets/images/enemies/brocorat', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 4, 4)
  self.animation.idle.frameDuration = 6
  self.animation:addState('walk', 1, 8, 'idle')
  self.animation.walk.frameDuration = 6
  self.animation:addState('empty', 9, 9)
  self.animation.empty.frameDuration = 6
  
  self:setSize(32,32)
  self:moveTo(x,y)
  self:setCollideRect(4,8, 24,24)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self.player = player
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

function Brocorat:search(player)
  self:blindSearch(player)
end
  
function Brocorat:update()
  if self.player.isActive == true then
    self:search(self.player)
  end
end

Frogcolli = {}
class('Frogcolli').extends('Enemy')

function Frogcolli:init(x, y, moveSpeed, Zindex, player)
  Brocorat.super.init(self,'assets/images/enemies/frogcolli', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 5, 6)
  self.animation.idle.frameDuration = 48
  self.animation:addState('walk', 1, 10, 'idle')
  self.animation.walk.frameDuration = 6
  self.animation:addState('empty', 11, 11)
  self.animation.empty.frameDuration = 6
  
  self:setSize(40, 40)
  self:moveTo(x,y)
  self:setCollideRect(4,8, 32, 32)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self.player = player
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

function Frogcolli:search(player)
  self:linealSearch(player)
end
function Frogcolli:update()
  if self.player.isActive == true then
    self:search(self.player)
  end
end