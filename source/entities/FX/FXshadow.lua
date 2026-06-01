class('FXshadow').extends(Graphics.sprite)

-- Create a new blank image for shadow rendering
local shadow = Graphics.image.new(400,240)

-- Constructor for the FXshadow class
function FXshadow:init(player, lightSize, globalLightAmount, Zindex)
	self.speed = player.speed                         -- Movement speed based on the player
	self.player = player                               -- Reference to the player object
	self.lightSize = lightSize                         -- Size of the main light mask
	self.shouldRefresh = true
	self:moveTo(200,120)                               -- Position the shadow sprite
	self:setCollidesWithGroups(1)                      -- Set collision group (for interaction or layering)
	self:setImage(shadow)                              -- Set the blank shadow image
	self:setZIndex(Zindex)                             -- Define drawing order
	self.globalLightAmount = globalLightAmount   
	     -- Base dither for global light
	self.lastBattery = -1
	self.lastDirection = ""
	self.lastPlayerX = -1
	self.lastPlayerY = -1
	self.lastLightSizeMulti = -1
	self.lastGlobalLightAmountValue = -1
	self.lastShowLightConeValue = false
	self.lastShowFullLightValue = false

	self:add()
	self:refresh()                                     -- Trigger initial drawing
end

-- Update the direction and refresh the shadow mask
function FXshadow:move(direction)
	self.direction = direction
	local movementX = 0
	local movementY = 0
	
	if direction == "left" then
		movementX = self.x - self.speed
	elseif direction == "right" then
		movementX = self.x + self.speed
	elseif direction == "up" then
		movementY = self.y - self.speed
	elseif direction == "down" then
		movementY = self.y + self.speed
	end
	
	self:refresh() -- Redraw shadow based on new direction
end

-- Redraw the shadow mask depending on player state and light battery level
function FXshadow:refresh()
	local battery = PlayerData.battery * 2 -- Artificially scale battery level
	local lightSizeMulti = PlayerData.isTiny == true and 0.5 or 1
	local direction = PlayerData.direction
	local ix = PlayerData.x
	local iy = PlayerData.y
	local globalLightAmountValue = self.globalLightAmount
	local showLightConeValue = PlayerData.showLightCone == true
	local showFullLightValue = PlayerData.showFullLight == true

	-- Check if anything changed before redrawing
	if not self.shouldRefresh and
	   battery == self.lastBattery and
	   direction == self.lastDirection and
	   ix == self.lastPlayerX and
	   iy == self.lastPlayerY and
	   lightSizeMulti == self.lastLightSizeMulti and
	   globalLightAmountValue == self.lastGlobalLightAmountValue and
	   showLightConeValue == self.lastShowLightConeValue and
	   showFullLightValue == self.lastShowFullLightValue then
		return
	end

	-- Update tracking variables
	self.lastBattery = battery
	self.lastDirection = direction
	self.lastPlayerX = ix
	self.lastPlayerY = iy
	self.lastLightSizeMulti = lightSizeMulti
	self.lastGlobalLightAmountValue = globalLightAmountValue
	self.lastShowLightConeValue = showLightConeValue
	self.lastShowFullLightValue = showFullLightValue
	self.shouldRefresh = false

	-- Create two mask images: one for soft lighting and one for focused light
	local shadowMask = shadow:getMaskImage()
	local lightSource = shadow:getMaskImage()
	
	-- Light parameters that will change based on battery
	local lightSourceAmount = 0
	local lightSourceSize = 35
	local maskSize = self.lightSize * lightSizeMulti
	local decreaseSize = maskSize / 10
	local lightAmount = self.globalLightAmount
	local globalDither = self.globalLightAmount
	
	-- Clear the shadow canvas before drawing
	shadow:clear(Graphics.kColorClear)

	-- === Define directional polygon for light projection ===
	local Direction = PlayerData.direction
	local ix = PlayerData.x
	local iy = PlayerData.y
	local d = 90     -- Distance the light reaches forward
	local h = 8    -- Height scaling for the cone shape
	local centerX = 0 -- Light offset
	local centerY = 0
	
	-- Adjust distance and origin offset depending on direction
	if Direction == 'left' or Direction == 'down' then
		d = d * -1
	end
	if Direction == 'left' then
		centerX = -18
	end

	-- Create a polygon to simulate a light cone based on direction
	local Light = playdate.geometry.polygon.new(ix, iy)
	if Direction == 'left' or Direction == 'right' then
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
	elseif Direction == 'up' or Direction == 'down' then
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

	-- === Adjust lighting based on whether the player has a lamp and remaining battery ===
	if PlayerData.items.hasLamp == true then
		if battery > 120 and battery <= 160 then
			maskSize -= decreaseSize * 1
			lightAmount = 0.2
			lightSourceSize = 35
			lightSourceAmount = 0.1
			globalLightAmount = 0.08
		elseif battery > 80 and battery <= 120 then
			maskSize -= decreaseSize * 2
			lightAmount = 0.5
			lightSourceSize = 30
			lightSourceAmount = 0.3
			globalLightAmount = 0.06
		elseif battery > 40 and battery <= 80 then
			maskSize -= decreaseSize * 3
			lightAmount = 0.7
			lightSourceSize = 25
			lightSourceAmount = 0.0
			globalLightAmount = 0.04
		elseif battery > 0 and battery <= 40 then
			maskSize -= decreaseSize * 4
			lightAmount = 0.9
			lightSourceSize = 20
			lightSourceAmount = 0.7
			globalLightAmount = 0.02
		elseif battery <= 0 then
			maskSize -= decreaseSize * 5
			lightAmount = 1
			lightSourceSize = 15
			lightSourceAmount = 0.9
			globalLightAmount = 0.01
		end
	else
		-- No lamp: minimal visibility
		maskSize = 50
		lightAmount = 1
		lightSourceSize = 15
		lightSourceAmount = 0.9
	end

	-- Override for Lightburst (Flash)
	if PlayerData.showLightCone == true and PlayerData.items.hasLamp == true then
		-- Flash parameters
		d = 200     -- Long distance
		h = 12      -- Wide cone
		
		-- Recalculate polygon with new d/h if direction is not idle
		if Direction == 'left' or Direction == 'down' then
			d = d * -1
		end
		
		-- Recreate polygon with larger dimensions
		if Direction == 'left' or Direction == 'right' then
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
		elseif Direction == 'up' or Direction == 'down' then
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

		-- Set light to maximum brightness (transparent shadow)
		lightAmount = 0
		lightSourceAmount = 0
		globalLightAmount = 0
	end

	-- Override for Dark Reveal skill (full level visibility)
	if PlayerData.showFullLight == true then
		lightAmount = 0
		lightSourceAmount = 0
		globalLightAmount = 0
		globalDither = 0
		maskSize = 800
		Direction = 'idle'
		self.shouldRefresh = true
	end

	-- === Draw global shadow ===
	Graphics.pushContext(shadow)
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(globalDither, Graphics.image.kDitherTypeBayer8x8)
		Graphics.fillRect(0, 0, shadow:getSize()) -- Full screen darkness
	Graphics.popContext()

	-- === Draw the primary light mask (circular or cone) ===
	shadow:addMask()
	Graphics.pushContext(shadowMask)
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(lightAmount, Graphics.image.kDitherTypeBayer8x8)
        if PlayerData.showLightCone == true then
            -- Force refresh if light cone is active
            self.shouldRefresh = true
        end

		-- Only show cone when PlayerData.showLightCone is true, lamp is selected, and not idle
		if Direction == 'idle' then
			Graphics.fillCircleAtPoint(self.player.x, self.player.y, maskSize)
		else
			Graphics.fillPolygon(Light)
			Graphics.drawPolygon(Light)
		end
	Graphics.popContext()

	-- === Draw additional focused light source ===
	shadow:addMask()
	Graphics.pushContext(lightSource)
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.setDitherPattern(lightSourceAmount, Graphics.image.kDitherTypeBayer8x8)
		if Direction == 'idle' then
			Graphics.fillCircleAtPoint(self.player.x, self.player.y, lightSourceSize)
		else
			Graphics.fillCircleAtPoint(self.player.x + centerX, self.player.y, lightSourceSize - 8)
		end
	Graphics.popContext()
end

-- Placeholder for future idle lighting behavior
function FXshadow:idleLight()
end

function FXshadow:update()
    -- refresh() now handles its own change detection, 
    -- but we still call it to check for external state changes
    self:refresh()
end