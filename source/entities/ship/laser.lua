class('Laser').extends(Graphics.sprite)

local laserZapImg = Graphics.image.new('assets/images/fx/zap.png')
local laserZipImg = Graphics.image.new('assets/images/fx/zip.png')
local laserZopImg = Graphics.image.new('assets/images/fx/zop.png')
local laserZupImg = Graphics.image.new('assets/images/fx/zup.png')



function Laser:init(...)
  -- shoot01Pos = ship.x - 28
  -- shoot02Pos = ship.x + 28
  -- shoot03Pos = ship.y - 8
  -- shoot04Pos = ship.y + 8
  shoot01Pos = ship.x - 28
  shoot02Pos = ship.x + 28
  shoot03Pos = ship.y - 8
  shoot04Pos = ship.y + 8
  
  self:moveTo(shoot01Pos - 10, shoot03Pos + 10)
  self:setZIndex(1)

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
   
   Graphics.drawLine(shoot01Pos, shoot03Pos + modY, crosshair.x,crosshair.y)
   -- Graphics.drawLine(shoot01Pos, shoot04Pos + modY, crosshair.x,crosshair.y)
   -- Graphics.drawLine(shoot02Pos, shoot03Pos - modY, crosshair.x,crosshair.y)
   -- Graphics.drawLine(shoot02Pos, shoot04Pos - modY, crosshair.x,crosshair.y)
   
   
end

function Laser:Single()
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