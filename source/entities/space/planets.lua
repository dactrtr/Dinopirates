class('Planet').extends(Graphics.sprite)

local Moon = Graphics.sprite.new()
Moon.imagetable = Graphics.imagetable.new('assets/images/space/planets/moon')

function Planet:init(x, y, planet)
  
  Moon.animation = Graphics.animation.loop.new(100, Moon.imagetable, true)
  
  initialX = x
  initialY = y
  self.planet = planet
  if speed == nil then
    self.xspeed = 1
    self.yspeed = 1
  else
    self.xspeed = speed
    self.yspeed = speed
  end
  
  self:setImage(Moon.animation:image())
  self:moveTo(x,y)
  self:setGroups(1)
  self:setZIndex(2)
  self:add()
  
end

function Planet:update()
  if planet == "moon" then
    self:setImage(Moon.animation:image())
  end
  print(self.planet)
  print(self.x)
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
end



