
Enemy = {}
class('Enemy').extends(NobleSprite)

import 'entities/FX/FXsonar'

function Enemy:blindSearch(player)
    self.player = player
    local movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
    local movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed

    self.animation:setState('walk')
    self:moveCollision(movementX, movementY, self.player)
end

function Enemy:linealSearch(player)
    if PlayerData.battery == 0 then
      self.moveSpeed = 0
    elseif PlayerData.battery > 60 then
      self.moveSpeed = self.initialSpeed
    end
    self.player = player
    local movementX = self.x
    local movementY = self.y
    
    if math.abs(self.y - self.player.y) < self.viewRange then
        movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
        self:moveCollision(movementX, self.y, self.player)
    end
    
    if math.abs(self.x - self.player.x) < self.viewRange then
        movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed
        self:moveCollision(self.x, movementY, self.player)
    end
end

function Enemy:moveCollision(movementX,movementY, player)
  
  if PlayerData.battery < 10 and PlayerData.isInDarkness == true then
    self.moveSpeed = 0
  elseif PlayerData.battery > 60  and PlayerData.isInDarkness == true then
    self.moveSpeed = self.initialSpeed
  end
  
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

function Enemy:sonar() -- Mark: Delete this
  if PlayerData.isFocused == true and PlayerData.isInDarkness == true and PlayerData.sanity > 0 then
    self.animation:setState('shine')
    self:setZIndex(10)
  else
    self:setZIndex(ZIndex.enemy)
    self.animation:setState('idle')
  end
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
  self.animation:addState('shine', 9, 12)
  self.animation.shine.frameDuration = 6
  
  self:setSize(32,32)
  self:moveTo(x,y)
  self:setCollideRect(4,8, 24,24)
  
  self.moveSpeed = moveSpeed
  self.initialSpeed = moveSpeed
  self.player = player
  self.Zindex = Zindex
  self:setGroups(CollideGroups.enemy)
  self:setCollidesWithGroups(
  {
    CollideGroups.player,
    CollideGroups.props,
    CollideGroups.wall,
    CollideGroups.enemy
  })
  self:setZIndex(self.Zindex)
  self:add(x,y)
end

function Brocorat:search(player)
  self:blindSearch(player)
end
  
function Brocorat:update()
  if PlayerData.isActive == true then
    self:search(self.player)
  end
  self:sonar()
  
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
  self.viewRange = 10
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
  if PlayerData.isActive == true then
    self:search(self.player)
  end
  if PlayerData.sonarActive == true  then
    self:sonar()
  end
end

