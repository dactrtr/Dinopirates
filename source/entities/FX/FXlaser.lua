class('FXlaser').extends(Graphics.sprite)

local laserZapImg = Graphics.image.new('assets/images/fx/zap.png')
local laserZipImg = Graphics.image.new('assets/images/fx/zip.png')
local laserZopImg = Graphics.image.new('assets/images/fx/zop.png')
local laserZupImg = Graphics.image.new('assets/images/fx/zup.png')

function FXlaser:Single(x,y) --VFX
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
 self:moveTo(x,y)
 self:add()
end

function FXlaser:init(...)
  
  local bgFX = Graphics.image.new(400, 240)
  -- self:moveTo(ship.shooter01.x - 10, ship.shooter01.y + 10)
  self:setZIndex(6) 
  
end

function FXlaser:clearFX()
  self:remove()
end




