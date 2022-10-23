class('Player').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  -- Right
  local Right = Graphics.sprite.new()
  Right.imagetable = Graphics.imagetable.new('assets/images/player/player-right')
  Right.animation = Graphics.animation.loop.new(100, Right.imagetable, true)
  -- Left
  local Left = Graphics.sprite.new()
  Left.imagetable = Graphics.imagetable.new('assets/images/player/player-left')
  Left.animation = Graphics.animation.loop.new(100, Left.imagetable, true)
  -- Up
  local Up = Graphics.sprite.new()
  Up.imagetable = Graphics.imagetable.new('assets/images/player/player-up')
  Up.animation = Graphics.animation.loop.new(100, Up.imagetable, true)
  -- Down
  local Down = Graphics.sprite.new()
  Down.imagetable = Graphics.imagetable.new('assets/images/player/player-down')
  Down.animation = Graphics.animation.loop.new(100, Down.imagetable, true)
  -- Idle
  local Idle = Graphics.sprite.new()
  Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)


function Player:init(x, y, toasts, speed)
  self:setImage(Idle.animation:image())
  self:setZIndex(3)
  self:moveTo(x,y)
  self:setCollideRect(4,24, 40,24)
  self:setCollidesWithGroups(1)
  self:setGroups(2)
  
  -- Mark: Custom properties
  self.speed = speed
  self.toasts = toasts
  
  self:add()   
end 

function Player:collisionResponse()
  return "freeze"
end

function Player:move(direction)
  self.direction = direction
  local movementX = 0
  local movementY = 0
  
  if (direction == "left") then
    self:setImage(Left.animation:image())
    movementX = self.x - self.speed
    movementY = self.y
  elseif (direction == "right") then
    self:setImage(Right.animation:image())
    movementX = self.x + self.speed
    movementY = self.y
  elseif (direction == "up") then
    self:setImage(Up.animation:image())
    movementX = self.x 
    movementY = self.y - self.speed
  elseif (direction == "down") then
    self:setImage(Down.animation:image())
    movementX = self.x 
    movementY = self.y + self.speed
  end
  
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  if lenght > 0 then
     for index, collision in pairs(collisions) do
       local collideObject = collision['other']
       if collideObject:isa(Enemy) then
         collideObject:remove() --same method for the enemies
       end
    end
  end
  
end

function Player:update()
  self:setImage(Idle.animation:image())
  if self.toasts < 1 then
    self.toasts = 0
  end
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    
    self:move("up")
        
  elseif playdate.buttonIsPressed(playdate.kButtonDown) then
    
    self:move("down")
        
  elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
    self:move("left")
    
  elseif playdate.buttonIsPressed(playdate.kButtonRight) then
    self:move("right")

  end
end