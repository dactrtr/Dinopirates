class('Star').extends(Graphics.sprite)
-- this must be done as a vector graphics instead of sprites
local Shiny = Graphics.sprite.new()
Shiny.imagetable = Graphics.imagetable.new('assets/images/space/star')

function Star:init(x, y, speed)
  
  local blinkSpeed = math.random(10,500)
  Shiny.animation = Graphics.animation.loop.new(blinkSpeed, Shiny.imagetable, true)
  
  initialX = x
  initialY = y
  
  if speed == nil then
    self.xspeed = 1
    self.yspeed = 1
  else
    self.xspeed = speed
    self.yspeed = speed
  end
  
  initialSpeed = speed
  self:setImage(Shiny.animation:image())
  self:moveTo(x,y)
  self:setGroups(1)
  self:setZIndex(1)
  self:add()
  
end

function Star:update()
  self:setImage(Shiny.animation:image())
  -- input handler
  local movementX = self.x
  local movementY = self.y
  -- borders
  local topY = 230
  local bottomY = 8
  local leftX = 8
  local rightX = 392
  -- button press
  if playdate.buttonIsPressed( playdate.kButtonUp ) 
  then
    movementX = self.x 
    movementY = self.y - self.yspeed
    
  end
  if (playdate.buttonIsPressed( playdate.kButtonDown )) then
    movementX = self.x 
    movementY = self.y + self.yspeed
    
  end
  if (playdate.buttonIsPressed( playdate.kButtonLeft )) then
    movementY = self.y 
    movementX = self.x + self.xspeed
    
  end
  if (playdate.buttonIsPressed( playdate.kButtonRight )) then
    movementY = self.y 
    movementX = self.x - self.xspeed
  end
  
  if movementY < bottomY then
    movementY = topY - 1
  elseif (movementY > topY) then
    movementY = bottomY + 1
  end
  
  if movementX < leftX then
    movementX = rightX - 1
  elseif (movementX > rightX) then
    movementX = leftX + 1
  end
  
  self:moveTo(movementX, movementY)
  --self:reset()
end

function Star:reset()
  local speed = 1
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
