local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)

-- Mark: imagetables for movement animation
  -- Right
  local Right = gfx.sprite.new()
  Right.imagetable = gfx.imagetable.new('assets/images/player/player-right')
  Right.animation = gfx.animation.loop.new(100, Right.imagetable, true)
  -- Left
  local Left = gfx.sprite.new()
  Left.imagetable = gfx.imagetable.new('assets/images/player/player-left')
  Left.animation = gfx.animation.loop.new(100, Left.imagetable, true)
  -- Up
  local Up = gfx.sprite.new()
  Up.imagetable = gfx.imagetable.new('assets/images/player/player-up')
  Up.animation = gfx.animation.loop.new(100, Up.imagetable, true)
  -- Down
  local Down = gfx.sprite.new()
  Down.imagetable = gfx.imagetable.new('assets/images/player/player-down')
  Down.animation = gfx.animation.loop.new(100, Down.imagetable, true)
  -- Idle
  local Idle = gfx.sprite.new()
  Idle.imagetable = gfx.imagetable.new('assets/images/player/player-idle')
  Idle.animation = gfx.animation.loop.new(600, Idle.imagetable, true)


function Player:init(x, y, toasts, speed)
  self:setImage(Idle.animation:image())
  self:setZIndex(3)
  self:moveTo(x,y)
  self:setCollideRect(4,0, 40,48)
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
    movementX = self.x - self.speed
    movementY = self.y
  elseif (direction == "right") then
    movementX = self.x + self.speed
    movementY = self.y
  elseif (direction == "up") then
    movementX = self.x 
    movementY = self.y - self.speed
  elseif (direction == "down") then
    movementX = self.x 
    movementY = self.y + self.speed
  end
  
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  if lenght > 0 then
     for index, collision in pairs(collisions) do
       local collideObject = collision['other']
       -- if collideObject:isa(Enemy) then
       --   collideObject:remove()
       -- end
    end
  end
  
end

function Player:update()
  self:setImage(Idle.animation:image())
  if self.toasts < 1 then
    self.toasts = 0
  end
  if pd.buttonIsPressed(pd.kButtonUp) then
    
    self:setImage(Up.animation:image())
    self:move("up")
        
  elseif pd.buttonIsPressed(pd.kButtonDown) then
    
    self:setImage(Down.animation:image())
    self:move("down")
        
  elseif pd.buttonIsPressed(pd.kButtonLeft) then
    self:setImage(Left.animation:image())
    self:move("left")
    
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self:setImage(Right.animation:image())
    self:move("right")

  end
end