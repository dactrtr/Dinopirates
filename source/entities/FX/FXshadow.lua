
class('FXshadow').extends(Graphics.sprite)

local shadow = Graphics.image.new(800,480)
Graphics.pushContext(shadow)
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.setDitherPattern(0.01, Graphics.image.kDitherTypeBayer8x8)
	Graphics.fillRect(0, 0, shadow:getSize())
Graphics.popContext()
-- this could be a function like the tiles
-- local light = Graphics.image.new("assets/images/fx/light100.png")
-- local light100 = Graphics.image.new("assets/images/fx/light100.png")
-- local light80 = Graphics.image.new("assets/images/fx/light80.png")
-- local light60 = Graphics.image.new("assets/images/fx/light60.png")
-- local light40 = Graphics.image.new("assets/images/fx/light40.png")
-- local light20 = Graphics.image.new("assets/images/fx/light20.png")

function FXshadow:init(x, y, player)
	
	self.speed = player.speed
	self.player = player
	self:moveTo(x,y)
	self:setCollideRect(380,240, 40,24)
	self:setCollidesWithGroups(1)
	self:setImage(shadow)
	self:setZIndex(10)
	self:add()	
end

function FXshadow:move(direction)
  self.direction = direction
  local movementX = 0
  local movementY = 0
  
  if (direction == "left") then
	movementX = self.x - self.speed
	movementY = self.y
  elseif (direction == "right") then
	movementX = self.x + self.speed
	movementY = self.y
  elseif (direction == "up") then
	movementX = self.x 
	movementY = self.y - self.speed
  elseif (direction == "down") then
	movementX = self.x 
	movementY = self.y + self.speed
  end
  
  local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
end

function FXshadow:update()
	local battery = self.player.battery
	local shadowMask = shadow:getMaskImage()
	Graphics.pushContext( shadowMask )
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.setDitherPattern(0.8, Graphics.image.kDitherTypeBayer8x8)
	Graphics.fillCircleAtPoint(400, 240, battery/2)
	Graphics.popContext()
	if battery < 50 then
		shadow:clearMask()
	end
	print(battery)
end
