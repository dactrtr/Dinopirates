Ship = {}
class('Ship').extends(NobleSprite)

-- Mark: imagetables for movement animation
  
function Ship:init(startX, startY, hull, speed, zIndex)
  Ship.super.init(self,'assets/images/ship/ship', true)

  -- animation states  
  self.animation:addState('fighter', 9, 9)
  self.animation:addState('travel', 5, 5)
  self.animation:addState('fighterdown', 3, 3)
  self.animation:addState('fighterup', 4, 4)
  self.animation:addState('traveldown', 1, 1)
  self.animation:addState('travelup', 2, 2)
  self.animation:addState('travelToFighter', 5, 9, 'fighter', 3)
  self.animation:addState('fighterToTravel', 9, 13, 'travel', 3)
  self.animation:addState('fighterleft', 15, 15)
  self.animation:addState('fighterright', 14, 14)
  -- position and z-index
  self:setSize( 80, 60)
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
  
  
  
  self:add(startX,startY)   
end 

-- function Player:collisionResponse()
--   return "freeze"
-- end
-- Mark: check this with the new transitions
function Ship:move(direction)
  self.direction = direction
  
  if (direction == "default") then
    if self.mode == "fighter" then
      self.animation:setState('fighter')
    elseif self.mode == "travel" then
      self.animation:setState('travel')
    end
    
  elseif (direction == "down") then
    if self.mode == "fighter" then
     self.animation:setState('fighterdown')
    elseif self.mode == "travel" then
      self.animation:setState('traveldown')
    end
  elseif (direction == "up") then
    if self.mode == "fighter" then
      self.animation:setState('fighterup')
    elseif self.mode == "travel" then
      self.animation:setState('travelup')
    end
  elseif(direction == "left") then
    if self.mode == "fighter" then
      self.animation:setState('fighterleft')
    elseif self.mode == 'travel' then
      
    end
    elseif(direction == "right") then
    if self.mode == "fighter" then
      self.animation:setState('fighterright')
    elseif self.mode == 'travel' then
      
    end
  end
end

function Ship:boost(mode) -- only boost when is in the defined mode
  if self.energy > 0 and ship.mode == mode then
    self.speed += 1
    self.energy -= 1 
  end
end
function Ship:transform()
    print("change")
end
function Ship:update()
  --print(self.y)
  -- fuel
  if self.energy <= 0 then
    -- print("no fuel")
  end
  
  if(self.changeMode == true)  then
    self.changeMode= false
  else
    if(self.mode == "fighter") and self.direction == "default" then
     -- self:setImage(shipFighterIdle.animation:image())
     --self.animation:setState('fighter')
     self.animation:setState('travelToFighter',false, self.animation.fighter)
    elseif (self.mode == "travel")  and self.direction == "default" then
     -- self:setImage(shipTravelIdle.animation:image())
     self.animation:setState('fighterToTravel',false, self.animation.travel)
    end
  end
 
end
