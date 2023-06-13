class('Meteorite').extends(Graphics.sprite)


local Meteo = Graphics.sprite.new()
Meteo.imagetable = Graphics.imagetable.new('assets/images/space/meteorite')



function Meteorite:init(x, y, speed)
  
  Meteo.animation = Graphics.animation.loop.new(speed, Meteo.imagetable, true)
  
  self:setImage(Meteo.animation:image())
  self:moveTo(x,y)
  -- self.Speed = speed nil
  -- self.moveSpeed = moveSpeed
  self:setGroups(1)
  self:setZIndex(1)
  self:add()
end

function Meteorite:update()
  self:setImage(Meteo.animation:image())
end

function Meteorite:updateSpeed(speed)
  Meteo.animation.delay = speed
end
-- copy crosshair movement logic

