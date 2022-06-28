local pd <const> = playdate
local gfx <const> = playdate.graphics

Player = {}
class('Player').extends(Graphics.sprite)

-- Mark: imagetables for movement animation
  -- Right
  local right = Noble.Animation.new("assets/images/player/player-right")
  right:addState("right", 0, 2)
  -- right:setState("right")

  -- Left
  local Left = Noble.Animation.new("assets/images/player/player-left")
  Left:addState("left", 0, 2)
  -- Left:setState("Left")
  -- Up
  local up = Noble.Animation.new("assets/images/player/player-up")
  up:addState("up", 0, 2)
  -- up:setState("up")
  
  -- Down
  local down = Noble.Animation.new("assets/images/player/player-down")
  down:addState("down", 0, 2)
  -- down:setState("down")

  -- Idle
  local idle = Noble.Animation.new("assets/images/player/player-idle")
  idle:addState("idle", 0, 3)
  -- idle:setState("idle")


function Player:init(x, y, toasts, speed)
  Player.super.init(self)

  -- self:setImage(Idle.animation:image())
  self.animation = idle
  self:setZIndex(2)
  self:moveTo(x,y)
  self:setCollideRect(0, 0, 48, 48)
  self:setCollidesWithGroups(1)
  self:setGroups(2)

  -- Mark: Custom properties
  self.speed = speed
  self.toasts = toasts

end

function Player:collisionResponse()
  return "overlap" 
end


function Player:update()
  self.animation = idle
  
  if self.toasts < 1 then
    self.toasts = 0
  end

  if pd.buttonIsPressed(pd.kButtonUp) then
    self.animation = up
    if self.y > (4+self:getSize()/2) then
      self:moveWithCollisions(self.x, self.y - self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonDown) then
    self.animation = down
    if self.y < 236-self:getSize()/2 then
      self:moveWithCollisions(self.x, self.y + self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonLeft) then
    self.animation = left
    
    if self.x > 116+self:getSize()/2 then
      self:moveWithCollisions(self.x - self.speed, self.y)
    end
    
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self.animation = right

    if self.x < 396-self:getSize()/2 then
      
      -- TODO:turn this into a method
        local actualX, actualY, collisions, lenght = self:moveWithCollisions(self.x + self.speed, self.y)
          if lenght > 0 then
            for index, collision in pairs(collisions) do
              local collideObject = collision['other']
              if collideObject:isa(Enemy) then
                collideObject:remove()
              end
          end
        end
    end
  end
    
end