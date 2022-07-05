local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)

-- Mark: imagetables for movement animation
  -- Right
  local Right = gfx.sprite.new()
  Right.imagetable = gfx.imagetable.new('assets/images/player/player-right')
  Right.animation = gfx.animation.loop.new(100, Right.imagetable, true)
  -- Left
  local Left = gfx.sprite.new()
  Left.imagetable = gfx.imagetable.new('assets/images/player/player-left')
  Left.animation = gfx.animation.loop.new(100, Left.imagetable, true)
  -- Up
  local Up = gfx.sprite.new()
  Up.imagetable = gfx.imagetable.new('assets/images/player/player-up')
  Up.animation = gfx.animation.loop.new(100, Up.imagetable, true)
  -- Down
  local Down = gfx.sprite.new()
  Down.imagetable = gfx.imagetable.new('assets/images/player/player-down')
  Down.animation = gfx.animation.loop.new(100, Down.imagetable, true)
  -- Idle
  local Idle = gfx.sprite.new()
  Idle.imagetable = gfx.imagetable.new('assets/images/player/player-idle')
  Idle.animation = gfx.animation.loop.new(600, Idle.imagetable, true)


function Player:init(x, y, toasts, speed)
  self:setImage(Idle.animation:image())
  self:setZIndex(2)
  self:moveTo(x,y)
  self:setCollideRect(0,0, 48,48)
  self:setCollidesWithGroups(1)
  self:setGroups(2)
  
  -- Mark: Custom properties
  self.speed = speed
  self.toasts = toasts
  
  self:add()   
end 

function Player:collisionResponse()
  return "overlap" 
end


function Player:update()
  self:setImage(Idle.animation:image())
  if self.toasts < 1 then
    self.toasts = 0
  end
  if pd.buttonIsPressed(pd.kButtonUp) then
    self:setImage(Up.animation:image())
    if self.y > (8+self:getSize()/2) then
      self:moveWithCollisions(self.x, self.y - self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonDown) then
    self:setImage(Down.animation:image())
    if self.y < 228-self:getSize()/2 then
      self:moveWithCollisions(self.x, self.y + self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonLeft) then
    self:setImage(Left.animation:image())
      if self.x > 120+self:getSize()/2 then
        self:moveWithCollisions(self.x - self.speed, self.y)
      end
    
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self:setImage(Right.animation:image())

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