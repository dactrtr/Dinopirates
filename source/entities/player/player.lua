Player = {}
class('Player').extends(NobleSprite)
import "entities/UI/dialog/dialogScreen"

local dialogUI = nil

function Player:init(x, y, speed, Zindex)
  Player.super.init(self,'assets/images/player/player', true)
  
  -- Mark: animation states
  self.animation:addState('idle', 1, 4)
  self.animation.idle.frameDuration = 24
  
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
  
  if (PlayerData.hasLamp == true and PlayerData.isInDarkness == true) then
    self.animation:setState('lampIdle')
  else
    self.animation:setState('idle')
  end
  
  -- Mark: basic properties
  self:setSize(48, 52)
  self:setZIndex(Zindex)
  self:moveTo(x,y)
  self:setCollideRect(10, 24, 30, 24)
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
  self.initialSanity = PlayerData.sanity
  self.initialBattery = PlayerData.battery
  self.sanityLoss = 10
  self.sanity = PlayerData.sanity
  
  PlayerData.isActive = false
  self.loadingPower = false
  self.isAlive = true
  
  -- Mark: Custom items properties
  PlayerData.battery = PlayerData.battery
  self.hasKey = false
  PlayerData.hasLamp = PlayerData.hasLamp
  PlayerData.isInDarkness = PlayerData.isInDarkness
  
  -- Mark: add to scene
  dialogUI = dialogScreen()
  self:sanityCheck()
  self:add(x, y)   
  
end 

function Player:collisionResponse(other)
  
  if other:isa(Enemy) then
    return self:dead()
  elseif other:isa(Box) then
    return 'freeze' 
  elseif other:isa(Trigger) then
      PlayerData.isTalking = true
      dialogUI:addScreen(other:returnScript(),other.sourceFeed)
    return 'freeze'
  elseif other:isa(Items) and other.type == 'keycard' then
    other:removeAll()
    self:grabKey()
    return 'overlap'
  elseif other:isa(Items) and other.type == 'lamp' then
    other:removeAll()
    self:grabLamp()
    return 'overlap'
  elseif other:isa(Items) and other.type == 'radio' then
    other:removeAll()
    self:grabRadio()
    return 'overlap'
  elseif other:isa(Door) then
    
    other:prevRoom(other.direction)
    other:goTo()
    
    -- if (PlayerData.hasKey == true and other.status == 'closed') or other.status=='open'then
    -- if PlayerData.hasKey == true then
    --   other:prevRoom(other.direction)
    --   other:goTo()
    -- else
    --   PlayerData.isTalking = true
    --   dialogUI:addScreen(1)
    --   return 'freeze'
    -- end
  return 'overlap'
  end
  
  
end

function Player:displayDialog(script)
  dialogUI:nextDialog()
end

function Player:idle()
  if self.isAlive == true then
    if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
      self.animation:setState('lampIdle')
    else
      self.animation:setState('idle')
    end
    PlayerData.direction = 'idle'
  end
end

function Player:sanityCheck()
  
  local function checkSanity()
    
    if PlayerData.battery < 20 and PlayerData.isInDarkness == true then 
      PlayerData.sanity -= 2 * self.sanityLoss
    elseif PlayerData.battery < 40 and PlayerData.isInDarkness == true then
      PlayerData.sanity -= self.sanityLoss
    end
    
    if PlayerData.sanity <= 0 then
      PlayerData.sanity = 0
    end
    if PlayerData.battery > 50 then
      PlayerData.sanity += 2 * self.sanityLoss
    end
    if PlayerData.sanity >= 100 then
      PlayerData.sanity = 100
    end
    
  end
  playdate.timer.keyRepeatTimerWithDelay(2000, 2000, checkSanity)
    
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
  if self.isAlive == true and PlayerData.isCharging == false then
    PlayerData.isActive = true
    self.direction = direction
    local movementX = 0
    local movementY = 0
    
    self:drainBattery(0.5)
    if (direction == "left") then
      if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
        self.animation:setState('lampLeft')
      else
        self.animation:setState('left')
      end
      movementX = self.x - self.speed
      movementY = self.y
    elseif (direction == "right") then
      if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
        self.animation:setState('lampRight')
      else
        self.animation:setState('right')
      end
      movementX = self.x + self.speed
      movementY = self.y
    elseif (direction == "up") then
      if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
        self.animation:setState('up')
      else
        self.animation:setState('up')
      end
      movementX = self.x 
      movementY = self.y - self.speed
    elseif (direction == "down") then
      if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
        self.animation:setState('lampDown')
      else
        self.animation:setState('down')
      end
      movementX = self.x 
      movementY = self.y + self.speed
    end
    local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
    PlayerData.direction = direction
  end
end


function Player:focus()
  if PlayerData.sanity > 0 then
    PlayerData.sanity -= 10 
    PlayerData.isFocused = true
  end
end

function Player:deFocus()
  if PlayerData.isFocused == true then
    PlayerData.isFocused = false
  end
end

function Player:drainBattery(amount)
  if levels[PlayerData.floor].floor.shadow == true then
    PlayerData.battery -= amount
  end
end

function Player:chargeBattery(amount)
  if PlayerData.battery < 100 then
    self.animation:setState('charge')
  else
    self.animation:setState('lampIdle')
  end
  PlayerData.battery += amount
  PlayerData.isActive = true
end

function Player:fillBattery()
    PlayerData.battery = 100
end
function Player:update()
  -- Mark: save actual position
  PlayerData.x = self.x
  PlayerData.y = self.y
  -- Mark: battery bounds
  if PlayerData.battery < 0 then
    PlayerData.battery = 0
  elseif PlayerData.battery >= 100 then
    PlayerData.battery = 100
  end
  -- Mark: Reduce speed in the dark
  if PlayerData.hasLamp == true and PlayerData.isInDarkness == true then
    if PlayerData.battery < 20 then 
      self.speed = 0.5 * self.initialSpeed
    elseif PlayerData.battery > 20 then
      self.speed = self.initialSpeed
    end
  end
  if PlayerData.isInDarkness == true and PlayerData.hasLamp == false then
    self.speed = 0.5 * self.initialSpeed
  end
  PlayerData.isActive = false
end

function Player:grabKey()
  PlayerData.hasKey = true
end

function Player:grabLamp()
  PlayerData.hasLamp = true
  self:fillBattery()
end

function Player:grabRadio()
  PlayerData.hasRadio = true
end