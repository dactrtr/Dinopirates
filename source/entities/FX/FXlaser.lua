class('FXlaser').extends(Graphics.sprite)

local laserZapImg = Graphics.image.new('assets/images/fx/zap.png')
local laserZipImg = Graphics.image.new('assets/images/fx/zip.png')
local laserZopImg = Graphics.image.new('assets/images/fx/zop.png')
local laserZupImg = Graphics.image.new('assets/images/fx/zup.png')
local shoot01 = Graphics.image.new('assets/images/fx/shoot01.png')
local shoot02 = Graphics.image.new('assets/images/fx/shoot02.png')

function FXlaser:Single(x,y,modx,mody) --VFX
  random = math.random(1,4)
  
  -- importante, si esta es solo una animacion con los 4 shooters ya definidos lo unico que tengo que hacer es agregar una rotacio y una correccion cuando se dispara con el boton abajo/arriba presionado, que lo hace mucho mas sencillo, menos modular pero mucho mas sencillo
  self.modY = mody
  
  local posx = x + modx
  local posy = y 
  
-- Mark: end
 self:moveTo(posx,posy)
 self:add()
 -- timer callback
  -- timers.performAfterDelay(1000, clear)
 print(modx)
 print(posx)
end

function FXlaser:init(...)
  
  -- local bgFX = Graphics.image.new(400, 240)
  self:setZIndex(2) 
  
end

function FXlaser:clearFX()
  self:remove()
end

clear = function()
  self:clearFX()
  print("gone")
end



