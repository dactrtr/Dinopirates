local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)


local Right = gfx.image.new("assets/32_hero_right.png")
local Left = gfx.image.new("assets/32_hero_left.png")

function Player:init(x, y, toasts, speed)
  self:setImage(Left)
  self.speed = speed
  self:moveTo(x,y)
  self:setCollideRect(0,0, self:getSize())
  self.toasts = toasts
  self:setGroups(2)
  self:setCollidesWithGroups(1)
  self:add()   
end 

function Player:collisionResponse()
  return "overlap" 
end


function Player:update()
  if self.toasts < 1 then
    self.toasts = 0
  end
  if pd.buttonIsPressed(pd.kButtonUp) then
    if self.y > 18 then
      self:moveWithCollisions(self.x, self.y - self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonDown) then
    if self.y < 220 then
      self:moveWithCollisions(self.x, self.y + self.speed)
    end
        
  elseif pd.buttonIsPressed(pd.kButtonLeft) then
    self:setImage(Left)
      if self.x > 128 then
        self:moveWithCollisions(self.x - self.speed, self.y)
      end
    
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self:setImage(Right)
      if self.x < 382 then
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