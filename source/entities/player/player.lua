Player = {}
class('Player').extends(NobleSprite)

-- Mark: imagetables for movement animation
  -- Right
  -- local Right = Graphics.sprite.new()
  -- Right.imagetable = Graphics.imagetable.new('assets/images/player/player-right')
  -- Right.animation = Graphics.animation.loop.new(100, Right.imagetable, true)
  -- -- Left
  -- local Left = Graphics.sprite.new()
  -- Left.imagetable = Graphics.imagetable.new('assets/images/player/player-left')
  -- Left.animation = Graphics.animation.loop.new(100, Left.imagetable, true)
  -- -- Up
  -- local Up = Graphics.sprite.new()
  -- Up.imagetable = Graphics.imagetable.new('assets/images/player/player-up')
  -- Up.animation = Graphics.animation.loop.new(100, Up.imagetable, true)
  -- -- Down
  -- local Down = Graphics.sprite.new()
  -- Down.imagetable = Graphics.imagetable.new('assets/images/player/player-down')
  -- Down.animation = Graphics.animation.loop.new(100, Down.imagetable, true)
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  -- -- Dead
  -- local Dead = Graphics.sprite.new()
  -- Dead.imagetable = Graphics.imagetable.new('assets/images/player/player-dead')
  -- Dead.animation = Graphics.animation.loop.new(100, Dead.imagetable, true)


function Player:init(x, y, battery, speed)
  Player.super.init(self,'assets/images/player/player', true)
  
  -- animation states
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
  
  self:setSize(48, 52)
  self:setZIndex(3)
  self:moveTo(x,y)
  self:setCollideRect(4,24, 40,24)
  self:setCollidesWithGroups(1)
  self:setGroups(2)
  
  -- Mark: Custom properties
  self.speed = speed
  self.battery = 100
  self.isAlive = true
  
  self:add(x, y)   
end 

function Player:collisionResponse()
  self:dead()
end

function Player:idle()
  if self.isAlive then
    self.animation:setState('idle')
  end
end
function Player:dead()
  -- self.isAlive = false
  -- self.animation:setState('dead')
end

function Player:move(direction)
  if self.isAlive == true then
    self.direction = direction
    local movementX = 0
    local movementY = 0
    
    self.battery -= 1
    
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
    if lenght > 0 then
       for index, collision in pairs(collisions) do
         local collideObject = collision['other']
         if collideObject:isa(Enemy) then
           collideObject:remove() -- same method for the enemies
         end
      end
    end
  end
  
end

function Player:update()
  
  -- cap battery total
 if self.battery < 0 then
   self.battery = 0
 elseif self.battery >= 100 then
   self.battery = 100
 end
end