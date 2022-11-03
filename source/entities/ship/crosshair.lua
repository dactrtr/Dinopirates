class('Crosshair').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local crosshair= Graphics.image.new("assets/images/ui/crosshair.png")
  
function Crosshair:init(x, y, xspeed, yspeed)
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
  
  if (direction == "up") then
    movementX = self.x 
    movementY = self.y + self.yspeed
    
  elseif (direction == "down") then
    movementX = self.x 
    movementY = self.y - self.yspeed
    
  elseif (direction == "left") then
    movementX = self.x - self.xspeed
    movementY = self.y 
  elseif (direction == "right") then
    movementX = self.x + self.yspeed
    movementY = self.y 
  end
  if movementY < 80 then
    movementY = 80
  end
  if movementY > 150 then
    movementY = 150
  end
  self:moveTo(movementX, movementY)
  
end

function Crosshair:update()
-- print("active")
end