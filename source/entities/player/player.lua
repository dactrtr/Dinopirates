Player = {}
class('Player').extends(NobleSprite)


function Player:init(x, y, battery, speed, Zindex)
  Player.super.init(self,'assets/images/player/player', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 1, 4)
  self.animation:addState('right', 5, 7)
  self.animation:addState('left', 8, 10)
  self.animation:addState('down', 11, 13)
  self.animation:addState('up', 14, 16)
  self.animation:addState('dead', 17, 18)
  self.animation.idle.frameDuration = 12
  self.animation.right.frameDuration = 12
  self.animation.left.frameDuration = 12
  self.animation.up.frameDuration = 12
  self.animation.down.frameDuration = 12
  self.animation.dead.frameDuration = 12
  self.animation:setState('idle')
  
  -- Mark: basic properties
  self:setSize(48, 52)
  self:setZIndex(Zindex)
  self:moveTo(x,y)
  self:setCollideRect(4,24, 40,24)
  self:setCollidesWithGroups(
    {
      CollideGroups.enemy,
      CollideGroups.props,
      CollideGroups.items,
      CollideGroups.wall
    })
  self:setGroups(CollideGroups.player)
  
  -- Mark: Custom properties
  self.speed = speed
  self.battery = 100
  self.isAlive = true
  self.hasKey = false
  self:add(x, y)   
end 

function Player:collisionResponse(other)
  --print('hit')
  
  if other:isa(Enemy) then
    return self:dead()
  elseif other:isa(Box) then
    return 'freeze' 
  elseif other:isa(Items) then
    --self:collisionResponse('overlap') 
    return print('you got a card')
  end
end

function Player:idle()
  if self.isAlive then
    self.animation:setState('idle')
  end
end
function Player:dead()
  self.isAlive = false
  self.animation:setState('dead')
  local function deathScreen()
  
    Noble.transition(DeadScene)
  
  end
  playdate.timer.performAfterDelay(800, deathScreen)
end

function Player:move(direction)
  if self.isAlive == true then
    self.direction = direction
    local movementX = 0
    local movementY = 0
    
    self:drainBattery(1)
    
    if (direction == "left") then
      self.animation:setState('left')
      movementX = self.x - self.speed
      movementY = self.y
    elseif (direction == "right") then
      self.animation:setState('right')
      movementX = self.x + self.speed
      movementY = self.y
    elseif (direction == "up") then
      self.animation:setState('up')
      movementX = self.x 
      movementY = self.y - self.speed
    elseif (direction == "down") then
      self.animation:setState('down')
      movementX = self.x 
      movementY = self.y + self.speed
    end
    local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  end
  
end

function Player:drainBattery(amount)
  self.battery -= amount
end
function Player:update()
  
  -- Mark: battery bounds
 if self.battery < 0 then
   self.battery = 0
 elseif self.battery >= 100 then
   self.battery = 100
 end
end