
class('FXshadow').extends(Graphics.sprite)

local shadow = Graphics.image.new(400,240)


function FXshadow:init(x, y, player)
	
	self.speed = player.speed
	self.player = player
	self:moveTo(x,y)
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
  
  
end

function FXshadow:update()
	
	local battery = self.player.battery*2
	
	local shadowMask = shadow:getMaskImage()
	local maskSize = 50
	local lightAmount = 0
	local globalLightAmount = 0.03
	if battery > 60 and battery <= 120 then
		maskSize = 45
		lightAmount = 0.1
	elseif battery > 40 and battery <= 60 then
		maskSize = 40
		lightAmount = 0.3
	elseif battery > 20 and battery <= 40 then
		maskSize = 35
		lightAmount = 0.5
	elseif battery > 0 and battery <= 20 then
		maskSize = 30
		lightAmount = 0.7
	elseif battery == 0 then
		maskSize = 25
		lightAmount = 0.9
	end
	Graphics.pushContext(shadow)
	
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(globalLightAmount, Graphics.image.kDitherTypeBayer8x8)
		Graphics.fillRect(0, 0, shadow:getSize())
		
	Graphics.popContext()
	shadow:addMask()
	Graphics.pushContext( shadowMask )
	
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(lightAmount, Graphics.image.kDitherTypeBayer8x8)
		Graphics.fillCircleAtPoint(self.player.x, self.player.y, maskSize)
		
	Graphics.popContext()
	
end
