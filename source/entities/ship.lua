class('Ship').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local shipImage= Graphics.image.new("assets/ship/small-ship.png")


function Ship:init(x, y, hull, speed)
  self:setImage(shipImage)
  self:setZIndex(3)
  self:moveTo(x,y)
  -- self:setCollideRect(4,24, 40,24)
  -- self:setCollidesWithGroups(1)
  self:setGroups(2)
  
  -- Mark: Custom properties
  self.speed = speed
  
  self:add()   
end 

-- function Player:collisionResponse()
--   return "freeze"
-- end

function Ship:move(direction)
  self.direction = direction
  -- local movementX = 0
  -- local movementY = 0
  -- 
  -- if (direction == "left") then
  --   self:setImage(Left.animation:image())
  --   movementX = self.x - self.speed
  --   movementY = self.y
  -- elseif (direction == "right") then
  --   self:setImage(Right.animation:image())
  --   movementX = self.x + self.speed
  --   movementY = self.y
  -- elseif (direction == "up") then
  --   self:setImage(Up.animation:image())
  --   movementX = self.x 
  --   movementY = self.y - self.speed
  -- elseif (direction == "down") then
  --   self:setImage(Down.animation:image())
  --   movementX = self.x 
  --   movementY = self.y + self.speed
  -- end
  -- 
  -- local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
  -- if lenght > 0 then
  --    for index, collision in pairs(collisions) do
  --      local collideObject = collision['other']
  --      if collideObject:isa(Enemy) then
  --        collideObject:remove() --same method for the enemies
  --      end
  --   end
  -- end
  -- 
end

function Ship:update()
  -- self:setImage(Idle.animation:image())
--   if playdate.buttonIsPressed(playdate.kButtonUp) then
--     
--     self:move("up")
--         
--   elseif playdate.buttonIsPressed(playdate.kButtonDown) then
--     
--     self:move("down")
--         
--   elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
--     self:move("left")
--     
--   elseif playdate.buttonIsPressed(playdate.kButtonRight) then
--     self:move("right")
-- 
--   end
end