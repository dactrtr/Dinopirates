class('Planet').extends(Graphics.sprite)

local Moon = Graphics.sprite.new()
Moon.imagetable = Graphics.imagetable.new('assets/images/space/planets/moon')

local Destroyed = Graphics.sprite.new()
Destroyed.imagetable = Graphics.imagetable.new('assets/images/space/planets/destroyed')

local Prism = Graphics.sprite.new()
Prism.imagetable = Graphics.imagetable.new('assets/images/space/planets/prism')

local Ring = Graphics.sprite.new()
Ring.imagetable = Graphics.imagetable.new('assets/images/space/planets/ring')

local Meteor1 = Graphics.sprite.new()
Meteor1.imagetable = Graphics.imagetable.new('assets/images/space/star-1')
local Meteor2 = Graphics.sprite.new()
Meteor2.imagetable = Graphics.imagetable.new('assets/images/space/star-2')
local Meteor3 = Graphics.sprite.new()
Meteor3.imagetable = Graphics.imagetable.new('assets/images/space/star-3')
local Meteor4 = Graphics.sprite.new()
Meteor4.imagetable = Graphics.imagetable.new('assets/images/space/star-4')

function Planet:init(x, y, planetType, speed, ship, position)
  
  Moon.animation = Graphics.animation.loop.new(100, Moon.imagetable, true)
  
  Destroyed.animation = Graphics.animation.loop.new(100, Destroyed.imagetable, true)
  
  Prism.animation = Graphics.animation.loop.new(100, Prism.imagetable, true)
  
  Ring.animation = Graphics.animation.loop.new(100, Ring.imagetable, true)
  
  Meteor1.animation = Graphics.animation.loop.new(100, Meteor1.imagetable, true)
  Meteor2.animation = Graphics.animation.loop.new(100, Meteor2.imagetable, true)
  Meteor3.animation = Graphics.animation.loop.new(100, Meteor3.imagetable, true)
  Meteor4.animation = Graphics.animation.loop.new(100, Meteor4.imagetable, true)
  
  initialX = x
  initialY = y
  self.planet = planetType
  
  if speed == nil then
    self.xspeed = 1
    self.yspeed = 1
  else
    self.xspeed = speed
    self.yspeed = speed
  end
  
  if position == nil then 
    self.position = 0
  else
    self.position = position
  end
  
  if self.planet == "moon" then
    self:setImage(Moon.animation:image())
  elseif self.planet == "destroyed" then
    self:setImage(Destroyed.animation:image())
  elseif self.planet == "prism" then
    self:setImage(Prism.animation:image())
  elseif self.planet == "ring" then
    self:setImage(Ring.animation:image())
  elseif self.planet == "meteor" then
    self:setImage(Meteor1.animation:image())
  end
  
  self:moveTo(x,y)
  self:setGroups(1)
  self:setZIndex(2)
  self:add()
end

-- function Planet:status(position)
--   if position > 5 then
--     print("disappear")
--   end
-- end
function Planet:update()
  
  if self.planet == "meteor" then
    print(self.x .. self.y)
    if ship.speed > 10 then
      self:setImage(Meteor2.animation:image())
    end
    if ship.speed > 20 then
      self:setImage(Meteor3.animation:image())
    end
    if ship.speed > 30 then
      self:setImage(Meteor4.animation:image())
    end
  end
  -- self:status()
  if ship.speed > self.position then
    self:remove() -- this should be about the asset loading
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



