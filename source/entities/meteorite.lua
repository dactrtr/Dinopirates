class('Meteorite').extends(Graphics.sprite)


local Small = Graphics.sprite.new()
Small.imagetable = Graphics.imagetable.new('assets/images/space/smeteorite')
Small.animation = Graphics.animation.loop.new(200, Small.imagetable, true)
-- Medium
local Medium = Graphics.sprite.new()
Medium.imagetable = Graphics.imagetable.new('assets/images/space/mmeteorite')
Medium.animation = Graphics.animation.loop.new(200, Medium.imagetable, true)
-- Large
local Large = Graphics.sprite.new()
Large.imagetable = Graphics.imagetable.new('assets/images/space/lmeteorite')
Large.animation = Graphics.animation.loop.new(200, Large.imagetable, true)
-- Xlarge
local XLarge= Graphics.sprite.new()
XLarge.imagetable = Graphics.imagetable.new('assets/images/space/xlmeteorite')
XLarge.animation = Graphics.animation.loop.new(200, XLarge.imagetable, true)
-- XXlarge
local XXLarge = Graphics.sprite.new()
XXLarge.imagetable = Graphics.imagetable.new('assets/images/space/xxlmeteorite')
XXLarge.animation = Graphics.animation.loop.new(200, XXLarge.imagetable, true)

local MeteoriteImage = Graphics.sprite.new()

function Meteorite:init(x, y, moveSpeed)
  self:setImage(Small.animation:image())
  self:moveTo(x,y)
  self.moveSpeed = moveSpeed
  self:setGroups(1)
  self:setZIndex(1)
  
  self:add()
end

function Meteorite:zoom(moveSpeed)
  self.moveSpeed = moveSpeed
  
  if (self.moveSpeed < 200) then
    self:setImage(Small.animation:image())
  elseif (self.moveSpeed < 400) then
    self:setImage(Medium.animation:image())
  elseif (self.moveSpeed < 600) then
    self:setImage(Large.animation:image())
  elseif (self.moveSpeed < 800) then
    self:setImage(XLarge.animation:image())
  elseif (self.moveSpeed < 1000) then
    self:setImage(XXLarge.animation:image())
  elseif(self.moveSpeed > 1001) then
    self:remove() -- Reset function
  end
end

function Meteorite:update()
end

