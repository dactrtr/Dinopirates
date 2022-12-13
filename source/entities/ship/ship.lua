class('Ship').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  
  -- -- Idle
  -- local Idle = Graphics.sprite.new()
  -- Idle.imagetable = Graphics.imagetable.new('assets/images/player/player-idle')
  -- Idle.animation = Graphics.animation.loop.new(700, Idle.imagetable, true)
  
  local shipDefault= Graphics.image.new("assets/images/ship/ship-default.png")
  local shipDown= Graphics.image.new("assets/images/ship/ship-down.png")
  local shipUp= Graphics.image.new("assets/images/ship/ship-up.png")
  
function Ship:init(x, y, hull, speed, zIndex)
  self:setImage(shipDefault)
  self:setZIndex(zIndex)
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
  if (direction == "default") then
    self:setImage(shipDefault)
  elseif (direction == "down") then
    self:setImage(shipDown)
  elseif (direction == "up") then
    self:setImage(shipUp)
  end
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