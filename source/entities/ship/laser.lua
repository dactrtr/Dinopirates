class('Laser').extends(Graphics.sprite)

local laserZapImg = Graphics.image.new('assets/images/fx/zap.png')
local laserZipImg = Graphics.image.new('assets/images/fx/zip.png')
local laserZopImg = Graphics.image.new('assets/images/fx/zop.png')
local laserZupImg = Graphics.image.new('assets/images/fx/zup.png')

function Laser:init(...)
  
  
  -- self:moveTo(ship.shooter01.x - 10, ship.shooter01.y + 10)
  self:setZIndex(7) 

end

function Laser:clearLasersFX()
  self:remove()
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
   
   Graphics.setColor(laserBlink)
   Graphics.setLineWidth(1)
   Graphics.setLineCapStyle(Graphics.kLineCapStyleButt)
   
   Graphics.drawLine(ship.shooter01.x, ship.shooter01.y + modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter02.x, ship.shooter02.y - modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter03.x - modX, ship.shooter03.y + modY, crosshair.x,crosshair.y)
   
   Graphics.drawLine(ship.shooter04.x, ship.shooter04.y - modY, crosshair.x,crosshair.y)
   
   
   
end

function Laser:Single() --VFX
  random = math.random(1,4)
  if random  == 1 then
    self:setImage(laserZapImg)
  elseif (random == 2) then
    self:setImage(laserZipImg)
  elseif (random == 3) then
    self:setImage(laserZopImg)
  elseif (random == 4) then
    self:setImage(laserZupImg)
 end
 self:add()
end