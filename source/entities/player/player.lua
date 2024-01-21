Player = {}
class('Player').extends(NobleSprite)


function Player:init(x, y, speed, Zindex)
  Player.super.init(self,'assets/images/player/player', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 1, 4)
  self.animation.idle.frameDuration = 12
  
  self.animation:addState('right', 5, 7)
  self.animation.right.frameDuration = 12
  
  self.animation:addState('left', 8, 10)
  self.animation.left.frameDuration = 12
  
  self.animation:addState('down', 11, 13)
  self.animation.down.frameDuration = 12
  
  self.animation:addState('up', 14, 16)
  self.animation.up.frameDuration = 12
  
  self.animation:addState('dead', 17, 18)
  self.animation.dead.frameDuration = 12
  
  self.animation:addState('lampIdle', 19, 22)
  self.animation.lampIdle.frameDuration = 24
  
  self.animation:addState('lampRight', 23, 25)
  self.animation.lampRight.frameDuration = 12
  
  self.animation:addState('lampLeft', 26, 28)
  self.animation.lampLeft.frameDuration = 12
  
  self.animation:addState('lampDown', 29, 31)
  self.animation.lampDown.frameDuration = 12
  
  self.animation:addState('charge', 32, 35)
  self.animation.charge.frameDuration = 12
  
  self.animation:setState('lampIdle')
  
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
  self.initialSpeed = speed
  self.speed = speed
  self.initialSanity = 100
  self.sanityLoss = 10
  self.sanity = 100
  self.isActive = false
  self.loadingPower = false
  self.isAlive = true
  
  -- Mark: Custom items properties
  self.battery = 100
  self.hasKey = false
  self.hasLamp = true
  
  -- Mark: add to scene
  
  self:sanityCheck()
  self:add(x, y)   
  
end 

function Player:collisionResponse(other)
  
  if other:isa(Enemy) then
    return self:dead()
  elseif other:isa(Box) then
    return 'freeze' 
  elseif other:isa(Items) then
    other:removeAll()
    self:grabKey()
    return 'overlap'
    elseif other:isa(Door) then
      if self.hasKey then
        print('be my guest')
      else
        print('no key no door')
      end
    return 'overlap'
  end
end

function Player:idle()
  if self.isAlive then
    if self.hasLamp then
      self.animation:setState('lampIdle')
    else
      self.animation:setState('idle')
    end
  end
end

function Player:sanityCheck()
  
  local function checkSanity()
    
    if self.battery < 20 then
      self.sanity -= 2 * self.sanityLoss
    elseif self.battery < 40 then
      self.sanity -= self.sanityLoss
    end
    
    if self.sanity <= 0 then
      self.sanity = 0
    end
    if self.battery > 50 then
      self.sanity += 2 * self.sanityLoss
    end
    if self.sanity >= 100 then
      self.sanity = 100
    end
    
  end
  playdate.timer.keyRepeatTimerWithDelay(1000, 1000, checkSanity)
    
end

function Player:dead()
  self.isAlive = false
  self.animation:setState('dead')
  local function deathScreen()
  
    Noble.transition(DeadScene)
  
  end
  playdate.timer.performAfterDelay(1000, deathScreen)
end

function Player:move(direction)
  if self.isAlive == true then
    self.isActive = true
    self.direction = direction
    local movementX = 0
    local movementY = 0
    
    self:drainBattery(1)
    
    if (direction == "left") then
      if self.hasLamp then
        self.animation:setState('lampLeft')
      else
        self.animation:setState('left')
      end
      movementX = self.x - self.speed
      movementY = self.y
    elseif (direction == "right") then
      if self.hasLamp then
        self.animation:setState('lampRight')
      else
        self.animation:setState('right')
      end
      movementX = self.x + self.speed
      movementY = self.y
    elseif (direction == "up") then
      if self.hasLamp then
        self.animation:setState('up')
      else
        self.animation:setState('up')
      end
      movementX = self.x 
      movementY = self.y - self.speed
    elseif (direction == "down") then
      if self.hasLamp then
        self.animation:setState('lampDown')
      else
        self.animation:setState('down')
      end
      movementX = self.x 
      movementY = self.y + self.speed
    end
    local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
    
  end
end

function Player:drainBattery(amount)
  self.battery -= amount
end

function Player:chargeBattery(amount)
  if self.battery < 100 then
    self.animation:setState('charge')
  else
    self.animation:setState('lampIdle')
  end
  self.battery += amount
  self.isActive = true
end

function Player:update()
  -- Mark: battery bounds
  if self.battery < 0 then
    self.battery = 0
  elseif self.battery >= 100 then
    self.battery = 100
  end
  if self.battery < 20 then 
    self.speed = 0.5 * self.initialSpeed
  elseif self.battery > 20 then
    self.speed = self.initialSpeed
  end
  self.isActive = false
end

function Player:grabKey()
  self.hasKey = true
end