class('Planet').extends(Graphics.sprite)

local Moon = Graphics.sprite.new()
Moon.imagetable = Graphics.imagetable.new('assets/images/space/planets/moon')
local Phase = Graphics.sprite.new()
Phase.imagetable = Graphics.imagetable.new('assets/images/space/planets/phase')

function Planet:init(x, y, planet)
  
  Moon.animation = Graphics.animation.loop.new(100, Moon.imagetable, true)
  Phase.animation = Graphics.animation.loop.new(100, Phase.imagetable, true)
  
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
  -- input handler
  local movementX = self.x
  local movementY = self.y
  -- borders
  local topY = 240
  local bottomY = 0
  local leftX = 0
  local rightX = 400
  -- button press, cross direction
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
  -- button press, diagonal direction
  if playdate.buttonIsPressed( playdate.kButtonUp ) and playdate.buttonIsPressed( playdate.kButtonLeft )
  then
    movementX = self.x + self.xspeed
    movementY = self.y - self.yspeed
  end
  if playdate.buttonIsPressed( playdate.kButtonUp ) and playdate.buttonIsPressed( playdate.kButtonRight )
  then
    movementX = self.x - self.xspeed
    movementY = self.y - self.yspeed
  end
  if (playdate.buttonIsPressed( playdate.kButtonDown )) and playdate.buttonIsPressed( playdate.kButtonRight )
  then
    movementX = self.x - self.xspeed
    movementY = self.y + self.yspeed
  end
  if (playdate.buttonIsPressed( playdate.kButtonDown )) and playdate.buttonIsPressed( playdate.kButtonLeft )
   then
    movementX = self.x + self.xspeed
    movementY = self.y + self.yspeed
  end
  -- Mark: out of bounds rules
  
  -- if movementY < bottomY then
  -- elseif (movementY > topY) then
  -- end
  -- 
  -- if movementX < leftX then
  -- elseif (movementX > rightX) then
  -- end
  
  self:moveTo(movementX, movementY)
end



