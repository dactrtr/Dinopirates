class('Laser').extends(Graphics.sprite)

function Laser:init(...)
  
  local bgFX = Graphics.image.new(400, 240)
  -- self:moveTo(ship.shooter01.x - 10, ship.shooter01.y + 10)
  self:setZIndex(1) 

end

function Laser:shoot(laserBlink,ship)
  self.laserBlink = laserBlink
  local modX = 0
  local modY = 0
  
  -- Rotating shooters magic
   if playdate.buttonIsPressed("left") then
      modY = 8
      modX = 2
   end
   if playdate.buttonIsPressed("right") then
      modY = - 8
      modX = - 2
   end
   
   Graphics.pushContext(bgFX)
   Graphics.setColor(laserBlink)
   Graphics.setLineWidth(1)
   Graphics.setLineCapStyle(Graphics.kLineCapStyleButt)
   
   Graphics.drawLine(ship.shooter01.x, ship.shooter01.y + modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter02.x, ship.shooter02.y - modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter03.x - modX, ship.shooter03.y + modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter04.x, ship.shooter04.y - modY, crosshair.x,crosshair.y)
   Graphics.popContext()
   -- Laser:add()
   
end

