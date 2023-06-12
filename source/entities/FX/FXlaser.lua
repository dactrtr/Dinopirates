class('FXlaser').extends(Graphics.sprite)

 local shoot = Graphics.sprite.new()
 shoot.imagetable = Graphics.imagetable.new('assets/images/fx/shootfx-table-80-40')
 shoot.animation = Graphics.animation.loop.new(100, shoot.imagetable, true)

function FXlaser:Single(x,y) --VFX
  self:setImage(shoot.animation:image())
  
  
  
 self:moveTo(x,y)
 self:add()
 -- timer callback
  -- timers.performAfterDelay(1000, clear)
end

function FXlaser:init(...)
  self:setImage(shoot.animation:image())
  self:setZIndex(2) 
  
end

function FXlaser:clearFX()
  self:remove()
end

clear = function()
  self:clearFX()
end



