class('Laser').extends(Graphics.sprite)

function Laser:init(zIndex)
  
  laserBG = Graphics.image.new(400, 240)
  laser = Graphics.sprite.new(laserBG)
  laser:setZIndex(zIndex)
  laser:moveTo(200, 120)
  laser:add()

end

function Laser:draw(laserColor,ship)
  if ship.energy > 0 then
    self.laserColor = laserColor
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
     Graphics.pushContext(laserBG)
     
       Graphics.setColor(laserColor)
         Graphics.setLineWidth(1)
         Graphics.setLineCapStyle(Graphics.kLineCapStyleButt)
         
         Graphics.drawLine(ship.shooter01.x, ship.shooter01.y + modY, crosshair.x,crosshair.y)
         
         Graphics.drawLine(ship.shooter02.x, ship.shooter02.y - modY, crosshair.x,crosshair.y)
         
         Graphics.drawLine(ship.shooter03.x - modX, ship.shooter03.y + modY, crosshair.x,crosshair.y)
         
         Graphics.drawLine(ship.shooter04.x, ship.shooter04.y - modY, crosshair.x,crosshair.y)
       
     Graphics.popContext()
     
    timers.performAfterDelay(6, clearLaser)
  end
end

function Laser:off()
  laserBG:clear(Graphics.kColorClear)
end

clearLaser = function ()
  laserBG:clear(Graphics.kColorClear)
  ship.energy -= 10
end