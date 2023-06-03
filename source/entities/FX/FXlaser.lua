class('FXlaser').extends(Graphics.sprite)

local laserZapImg = Graphics.image.new('assets/images/fx/zap.png')
local laserZipImg = Graphics.image.new('assets/images/fx/zip.png')
local laserZopImg = Graphics.image.new('assets/images/fx/zop.png')
local laserZupImg = Graphics.image.new('assets/images/fx/zup.png')

function FXlaser:Single(x,y) --VFX
  random = math.random(1,4)
  seed = math.random(1,2)
  
  local modX = 0
  local modY = 0
  
  if random  == 1 then
    self:setImage(laserZapImg)
  elseif (random == 2) then
    self:setImage(laserZipImg)
  elseif (random == 3) then
    self:setImage(laserZopImg)
  elseif (random == 4) then
    self:setImage(laserZupImg)
 end
 -- Mark: FX displacement (can be done better)
  if playdate.buttonIsPressed("left") then
     modY = 8
     modX = 8
  end
  if playdate.buttonIsPressed("right") then
     modY = - 8
     modX = - 8
  end
  
  local posx = x + modX
  local posy = y + modY
  
  if (random % 2 == 0) then
    -- self:setRotation(-2)
  else 
    -- self:setRotation(2)
  end
-- Mark: end
 self:moveTo(posx,posy)
 self:add()
end

function FXlaser:init(...)
  
  local bgFX = Graphics.image.new(400, 240)
  self:setZIndex(6) 
  
end

function FXlaser:clearFX()
  self:remove()
end




