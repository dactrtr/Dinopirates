
class('FXshadow').extends(Graphics.sprite)

local shadow = Graphics.image.new(400,240)


function FXshadow:init(player, lightSize, globalLightAmount, Zindex)
	self.speed = player.speed
	self.player = player
	self.lightSize = lightSize
	self.shouldRefresh = true
	self:moveTo(200,120)
	self:setCollidesWithGroups(1)
	self:setImage(shadow)
	self:setZIndex(Zindex)
	self.globalLightAmount = globalLightAmount
	self:add()	
	self:refresh()
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
  self:refresh()
end

function FXshadow:refresh()
	
	local battery = PlayerData.battery*2
	
	local shadowMask = shadow:getMaskImage()
	local lightSource = shadow:getMaskImage()
	local lightSourceAmount = 0
	local lightSourceSize = 35
	local maskSize = self.lightSize
	local decreaseSize = maskSize/10
	local lightAmount = self.globalLightAmount
	shadow:clear(Graphics.kColorClear)
	
	-- Mark: Draw polygons
	local Direction = PlayerData.direction
	local ix = PlayerData.x
	local iy = PlayerData.y
	local d = 120
	local h = 8
	local centerX = 0 
	local centerY = 0
	if Direction == 'left' or Direction == 'down' then
		d = d * -1
	end
	if Direction == 'left' then
		centerX = -18
	end
	
	local Light = playdate.geometry.polygon.new(ix ,iy )
	if Direction == 'left' or Direction == 'right'then
		Light = playdate.geometry.polygon.new(
			ix ,iy ,
			ix + d, iy - 4*h, 
			ix + 1.1*d, iy - 3.5*h, 
			ix + 1.2*d, iy - 2*h, 
			ix + 1.25*d, iy, 
			ix + 1.2*d, iy + 2*h,
			ix + 1.1*d, iy + 3.5*h,
			ix + d, iy + 4*h,
			ix, iy
		)	
		Light:close()
	elseif (Direction == 'up' or Direction == 'down') then
		Light = playdate.geometry.polygon.new(
			ix ,iy,
			ix - 4*h, iy - d, 
			ix - 3.5*h, iy - 1.1*d,
			ix - 2*h, iy - 1.2*d, 
			ix , iy - 1.25*d, 
			ix + 2*h, iy - 1.2*d,
			ix + 3.5*h, iy - 1.1*d,
			ix + 4*h, iy - d,
			ix, iy
		)	
		Light:close()
	end
	
	
	if PlayerData.hasLamp == true then
		
		if battery > 120 and battery <= 160 then
			maskSize -= decreaseSize*1
			lightAmount = 0.2
			lightSourceSize = 35
			lightSourceAmount = 0.1
			self.globalLightAmount = 0.08
		elseif battery > 80 and battery <= 120 then
			maskSize -= decreaseSize*2
			lightAmount = 0.5
			lightSourceSize = 30
			lightSourceAmount = 0.3
			self.globalLightAmount = 0.06
		elseif battery > 40 and battery <= 80 then
			maskSize -= decreaseSize*3
			lightAmount = 0.7
			lightSourceSize = 25
			lightSourceAmount = 0.0
			self.globalLightAmount = 0.04
		elseif battery > 0 and battery <= 40 then
			maskSize -= decreaseSize*4
			lightAmount = 0.9
			lightSourceSize = 20
			lightSourceAmount = 0.7
			self.globalLightAmount = 0.02
		elseif battery <= 0 then
			maskSize -= decreaseSize*5
			lightAmount = 1
			lightSourceSize = 15
			lightSourceAmount = 0.9
			self.globalLightAmount = 0.01
		end
		--Graphics.drawArc(PlayerData.x, PlayerData.y, 30, 0, 1)
			

	else
		maskSize = 50
		lightAmount = 1
		lightSourceSize = 15
		lightSourceAmount = 0.9
	end
	-- Mark: fills the screen with a dither pattern
	Graphics.pushContext(shadow)
	
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(self.globalLightAmount, Graphics.image.kDitherTypeBayer8x8)
		Graphics.fillRect(0, 0, shadow:getSize())
		
	Graphics.popContext()
	
	-- Mark: add a mask with a less dither pattern
	shadow:addMask()
	Graphics.pushContext( shadowMask )
	
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(lightAmount, Graphics.image.kDitherTypeBayer8x8)
		if Direction == 'idle' then
			Graphics.fillCircleAtPoint(self.player.x, self.player.y, maskSize)
		else
			Graphics.fillPolygon(Light)
			Graphics.drawPolygon(Light)
		end
		
	Graphics.popContext()
	
	-- Mark: add a mask with a even less dither pattern
	shadow:addMask()
	Graphics.pushContext( lightSource )
	
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(lightSourceAmount, Graphics.image.kDitherTypeBayer8x8)
		if Direction == 'idle' then
			Graphics.fillCircleAtPoint(self.player.x, self.player.y, lightSourceSize)
		else
			Graphics.fillCircleAtPoint(self.player.x + centerX, self.player.y, lightSourceSize - 8)
		end
		
	Graphics.popContext()
	print(ix .." ".. iy)
	
end

function idleLight()
	
	
end
