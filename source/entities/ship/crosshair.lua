class('Crosshair').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local crosshair= Graphics.image.new("assets/images/ui/crosshair.png")
  
function Crosshair:init(x, y, xspeed, yspeed)
  centerY = y
  centerX = x
  self:setImage(crosshair)
  self:setZIndex(2)
  self:moveTo(x,y)  
  -- Mark: Custom properties
  self.xspeed = xspeed
  self.yspeed = yspeed
  
  self:add()   
end 

-- function Player:collisionResponse()
--   return "freeze"
-- end

function Crosshair:move(direction)
  self.direction = direction
  
  local movementX = 0
  local movementX = 0
  -- screen limits
  local topY = 230
  local bottomY = 8
  local leftX = 8
  local rightX = 392
  
  if (direction == "up") then
    movementX = self.x 
    movementY = self.y + self.yspeed
    
  elseif (direction == "down") then
    movementX = self.x 
    movementY = self.y - self.yspeed
    
  elseif (direction == "left") then
    movementX = self.x - self.xspeed
    movementY = self.y 
    self:setRotation(-20)
    
  elseif (direction == "right") then
    movementX = self.x + self.xspeed
    movementY = self.y
    self:setRotation(20) 
  end
  
  -- Border block
  if movementY < bottomY then
    movementY = bottomY
  elseif (movementY > topY) then
    movementY = topY
  end
  
  if movementX < leftX then
    movementX = leftX
  elseif (movementX > rightX) then
    movementX = rightX
  end
 
  
  self:moveTo(movementX, movementY)
  
end

function Crosshair:reset()
  self:setRotation(0)
  local speed = 2
    
  if (self.y > centerY) then  
    self:moveBy(0, -speed)
  elseif (self.y < centerY) then
    self:moveBy(0, speed)
  end
  if (self.x > centerX) then
    self:moveBy(-speed, 0)
  elseif (self.x < centerX) then
    self:moveBy(speed, 0)
  end

end

function Crosshair:update()
  self:reset()
end