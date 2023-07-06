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
local Meteor5 = Graphics.sprite.new()
Meteor5.imagetable = Graphics.imagetable.new('assets/images/space/star-5')
local Meteor6 = Graphics.sprite.new()
Meteor6.imagetable = Graphics.imagetable.new('assets/images/space/star-6')

function Planet:init(x, y, planetType, speed, ship, position, repetition)
  -- Info:
  -- speed: how much the planet move in the X-Y axis compared to the ship, default 1 (this should change with the distance)
  -- position : when the planet will get "closer" to the ship
  -- repetition : amount of times the planet or asteroid will re appear randomly
  
  
  Moon.animation = Graphics.animation.loop.new(100, Moon.imagetable, true)
  
  Destroyed.animation = Graphics.animation.loop.new(100, Destroyed.imagetable, true)
  
  Prism.animation = Graphics.animation.loop.new(100, Prism.imagetable, true)
  
  Ring.animation = Graphics.animation.loop.new(100, Ring.imagetable, true)
  
  Meteor1.animation = Graphics.animation.loop.new(blinkSpeed, Meteor1.imagetable, true)
  Meteor2.animation = Graphics.animation.loop.new(100, Meteor2.imagetable, true)
  Meteor3.animation = Graphics.animation.loop.new(200, Meteor3.imagetable, true)
  Meteor4.animation = Graphics.animation.loop.new(300, Meteor4.imagetable, true)
  Meteor5.animation = Graphics.animation.loop.new(400, Meteor5.imagetable, true)
  Meteor6.animation = Graphics.animation.loop.new(500, Meteor6.imagetable, true)
  
  
  self.rep = 1
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
    self.positionZ = 0
  else
    self.positionZ = position
  end
  
  
  -- checks the type of planet and assigns a initial image
  if self.planet == "moon" then
    planetImage = Moon.animation:image()
  elseif self.planet == "destroyed" then
    planetImage = Destroyed.animation:image()
  elseif self.planet == "prism" then
    planetImage = Prism.animation:image()
  elseif self.planet == "ring" then
    planetImage = Ring.animation:image()
  elseif self.planet == "meteor" then
    planetImage = Meteor1.animation:image()
  end
  
  self.indexlayer = 0
  self.distance = self.positionZ * 7
  
  self:setImage(planetImage)
  
  self:moveTo(x,y)
  self:setGroups(1)
  self:setZIndex(zPlanets)
  self:add()
  
end

function Planet:restart()
  self:setImage(Meteor1.animation:image())
  self:moveTo(math.random(20,380),math.random(20,220))
  self.distance = self.positionZ * 7
  print("restarted")
  -- restart speed
end
function Planet:update()
  
  -- input handler
  local movementX = self.x
  local movementY = self.y
  
  -- borders
  local topY = 240
  local bottomY = 0
  local leftX = 0
  local rightX = 400
  
  self.ownSpeed = ship.speed
  
  if self.planet == "meteor" then
    
    if ship.energy >= 0 then
      
      if (self.distance - ship.speed) <= self.positionZ * 7 then
        self.indexlayer = 1
        self:setImage(Meteor1.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 6) and ((self.distance - ship.speed) <= self.positionZ * 7)then
        self.indexlayer = 2
        self:setImage(Meteor2.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 5) and ((self.distance - ship.speed) <= self.positionZ * 6)then
        self.indexlayer = 3
        self:setImage(Meteor3.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 4) and ((self.distance - ship.speed) <= self.positionZ * 5)then
        self.indexlayer = 4
        self:setImage(Meteor4.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 3) and ((self.distance - ship.speed) <= self.positionZ * 4)then
        self.indexlayer = 5
        self:setImage(Meteor5.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 2) and ((self.distance - ship.speed) <= self.positionZ * 3)then
        self.indexlayer = 6
        self:setImage(Meteor6.animation:image())
      end
      if ((self.distance - ship.speed) <= self.positionZ * 1) then
        self.indexlayer = 7
        self:setImage(Meteor6.animation:image())
        -- esta es la parte donde si se repetir el elemento llama al restart, pero cae en este if cada frame, deberian poner un flag para que corra solo una vez?
        
        -- if self.rep < self.repetition then
        --   self.rep += 1
        --   self:restart()
        -- end
      end
      if (self.distance - ship.speed) < 0 then
        self:remove()
      end
      
    end
    
    
  end
  
  if ship.mode == "fighter" then
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
end



