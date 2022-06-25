local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(gfx.sprite)

-- Mark: imagetables
local Right = gfx.sprite.new()
Right.imagetable = gfx.imagetable.new('assets/player/player-right')
Right.animation = gfx.animation.loop.new(100, Right.imagetable, true)
-- local Left = gfx.image.new("assets/32_hero_left.png")

function Player:init(x, y, toasts, speed)
  self:setImage(Right.animation:image())
  self.speed = speed
  self:moveTo(x,y)
  self:setCollideRect(0,0, 48,48)
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
    -- self:setImage(Left)
      if self.x > 128 then
        self:moveWithCollisions(self.x - self.speed, self.y)
      end
    
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self:setImage(Right.animation:image())

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