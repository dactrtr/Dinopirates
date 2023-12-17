class('Cockpit').extends(Graphics.sprite)

  -- Animations
-- local IdlePlayer = Graphics.sprite.new()
-- IdlePlayer.imagetable = Graphics.imagetable.new('assets/ship/ship.png')
-- IdlePlayer.animation = Graphics.animation.loop.new(700, IdlePlayer.imagetable, true)
local CockpitImage= Graphics.image.new("assets/images/ship/ship.png")

function Cockpit:init(x, y, hull)
  self:setImage(CockpitImage)
  self:setZIndex(4)
  self:moveTo(x+2,y-8)

  self:add()   
end 


function Cockpit:update()
  -- self:setImage(IdlePlayer.animation:image())
end
