class('Ship').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local shipDefault= Graphics.image.new("assets/images/ship/ship-default.png")
  local shipDown= Graphics.image.new("assets/images/ship/ship-down.png")
  local shipUp= Graphics.image.new("assets/images/ship/ship-up.png")
  
  local shipTravelTransition = Graphics.sprite.new()
  shipTravelTransition.imagetable = Graphics.imagetable.new('assets/images/ship/ship-travel')
  shipTravelTransition.animation = Graphics.animation.loop.new(300, shipTravelTransition.imagetable, true)
  
  local shipFighterTransition = Graphics.sprite.new()
  shipFighterTransition.imagetable = Graphics.imagetable.new('assets/images/ship/ship-fighter')
  shipFighterTransition.animation = Graphics.animation.loop.new(300, shipFighterTransition.imagetable, true)
  
  local shipFighterIdle = Graphics.sprite.new()
  shipFighterIdle.imagetable = Graphics.imagetable.new('assets/images/ship/ship-fighter-idle')
  shipFighterIdle.animation = Graphics.animation.loop.new(300, shipFighterIdle.imagetable, true)
  
  local shipFighterDown = Graphics.sprite.new()
  shipFighterDown.imagetable = Graphics.imagetable.new('assets/images/ship/ship-fighter-down')
  shipFighterDown.animation = Graphics.animation.loop.new(300, shipFighterDown.imagetable, true)
  
  local shipFighterUp = Graphics.sprite.new()
  shipFighterUp.imagetable = Graphics.imagetable.new('assets/images/ship/ship-fighter-up')
  shipFighterUp.animation = Graphics.animation.loop.new(300, shipFighterUp.imagetable, true)
  
  local shipTravelIdle = Graphics.sprite.new()
  shipTravelIdle.imagetable = Graphics.imagetable.new('assets/images/ship/ship-travel-idle')
  shipTravelIdle.animation = Graphics.animation.loop.new(300, shipTravelIdle.imagetable, true)
  
  local shipTravelDown = Graphics.sprite.new()
  shipTravelDown.imagetable = Graphics.imagetable.new('assets/images/ship/ship-travel-down')
  shipTravelDown.animation = Graphics.animation.loop.new(300, shipTravelDown.imagetable, true)
  
  local shipTravelUp = Graphics.sprite.new()
  shipTravelUp.imagetable = Graphics.imagetable.new('assets/images/ship/ship-travel-up')
  shipTravelUp.animation = Graphics.animation.loop.new(300, shipTravelUp.imagetable, true)
  
function Ship:init(startX, startY, hull, speed, zIndex)
  self:setImage(shipDefault)
  self:setZIndex(zIndex)
  self:moveTo(startX,startY)
  -- self:setCollideRect(4,24, 40,24)
  -- self:setCollidesWithGroups(1)
  self:setGroups(2)
  
  -- Mark: Custom properties
  self.speed = speed
  self.mode = "fighter"
  self.changeMode = false
  self.direction = "default"
  self.energy = 100
  self.energyTotal = 100
  
  -- Mark: Shooters
  self.shooter01 = { x = self.x - 28 ,y = self.y - 8 }
  self.shooter02 = { x = self.x + 28 ,y = self.y - 8 }
  self.shooter03 = { x = self.x - 28 ,y = self.y + 8 }
  self.shooter04 = { x = self.x + 28 ,y = self.y + 8 }
  
  
  
  self:add()   
end 

-- function Player:collisionResponse()
--   return "freeze"
-- end
-- Mark: check this with the new transitions
function Ship:move(direction)
  self.direction = direction
  if (direction == "default") then
    if self.mode == "fighter" then
      self:setImage(shipFighterIdle.animation:image())
    elseif self.mode == "travel" then
      self:setImage(shipTravelIdle.animation:image())
    end
  elseif (direction == "down") then
    if self.mode == "fighter" then
      self:setImage(shipFighterDown.animation:image())
    elseif self.mode == "travel" then
      self:setImage(shipTravelDown.animation:image())
    end
  elseif (direction == "up") then
    if self.mode == "fighter" then
      self:setImage(shipFighterUp.animation:image())
    elseif self.mode == "travel" then
      self:setImage(shipTravelUp.animation:image())
    end
  end
end

function Ship:boost(mode) -- only boost when is in the defined mode
  if self.energy > 0 and ship.mode == mode then
    self.speed += 1
    self.energy -= 1 
  end
end

function Ship:update()
  
  -- fuel
  if self.energy <= 0 then
    -- print("no fuel")
  end
  
  if(self.changeMode == true)  then
    self.changeMode= false
  else
    if(self.mode == "fighter") and self.direction == "default" then
      self:setImage(shipFighterIdle.animation:image())
    elseif (self.mode == "travel")  and self.direction == "default" then
      self:setImage(shipTravelIdle.animation:image())
    end
  end
 
end
