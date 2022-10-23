local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlayerCockpit').extends(gfx.sprite)

  -- Idle
local Idle = gfx.sprite.new()
Idle.imagetable = gfx.imagetable.new('assets/images/player/player-idle')
Idle.animation = gfx.animation.loop.new(700, Idle.imagetable, true)


function PlayerCockpit:init(x, y, toasts, speed)
  self:setImage(Idle.animation:image())
  self:setZIndex(3)
  self:moveTo(x,y)
  
  -- Mark: Custom properties
  self:add()   
end 


function PlayerCockpit:update()
  self:setImage(Idle.animation:image())
end
