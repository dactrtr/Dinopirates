class('Crosshair').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local crosshair= Graphics.image.new("assets/images/ui/crosshair.png")
  
function Crosshair:init(x, y, xspeed, yspeed)
  self:setImage(crosshair)
  self:setZIndex(4)
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
  -- self.direction = direction
  -- if direction == "default" then
  --   self:setImage(shipDefault)
  -- elseif (direction== "down") then
  --   self:setImage(shipDown)
  -- elseif (direction== "up") then
  --   self:setImage(shipUp)
  -- end
end

function Crosshair:update()
-- print("active")
end