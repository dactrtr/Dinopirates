ButtonPress = {}
class('ButtonPress').extends(NobleSprite)

local BUTTON_KEYS = { "aButton", "bButton", "leftButton", "upButton", "rightButton", "downButton" }

function ButtonPress:init(beats, startPoint, keyProvider)
	ButtonPress.super.init(self, 'assets/images/ui/battle/button', true)

	for i, name in ipairs(BUTTON_KEYS) do
		self.animation:addState(name, i, i)
		self.animation[name].frameDuration = 6
	end
	self.animation:addState("empty", 8, 8)
	self.animation.empty.frameDuration = 6

	self.bpm = beats
	self.startPoint = startPoint
	self.active = false
	self.range = 100
	-- Set true when the button scrolls off the left edge without being pressed (a MISS).
	-- DanceScene polls and clears this to fire the accuracy pop-up. hit() moves the button
	-- back to startPoint, so a pressed button never reaches the wrap branch below.
	self.missedPass = false
	self:setSize(32, 32)
	self:setZIndex(4)
	self:setCollideRect(0, 0, 32, 32)
	self:add(startPoint, 30)

	-- Instead of random, always ask keyProvider (a function passed from DanceScene)
	self.keyProvider = keyProvider
	self.buttonKey = self.keyProvider()  
	self.animation:setState(self.buttonKey)
end

function ButtonPress:hit()
	self.buttonKey = "empty"
	self.animation:setState(self.buttonKey)

	-- Reset to a new key from the provider
	self:moveTo(self.startPoint, self.y)
	self:changeButtonSprite()
end

function ButtonPress:changeButtonSprite()
	local newKey
	repeat
		newKey = self.keyProvider()  -- << ask provider, not random
	until newKey ~= self.buttonKey

	self.buttonKey = newKey
	self.animation:setState(self.buttonKey)
end

function ButtonPress:tryMoveToFreePosition(movementX, movementY)
	local actualX, actualY, collisions, length = self:moveWithCollisions(movementX, movementY)
	if length > 0 then
		for index, collision in pairs(collisions) do
			local collideObject = collision['other']
			if collideObject:isa(ButtonPress) then
				-- handle collision if needed
			end
		end
	end
end

-- This stays in case you want fallback random somewhere else
function ButtonPress.getRandomButtonKey()
	local randomIndex = math.random(1, #BUTTON_KEYS)
	return BUTTON_KEYS[randomIndex]
end

function ButtonPress:movementDelay(delay)
	local function movementDelayed()
		self.active = true
	end
	playdate.timer.performAfterDelay(delay, movementDelayed)
end

function ButtonPress:collisionResponse(other)
	if other:isa(ButtonPress) then
		return 'freeze'
	else
		return 'overlap'
	end
end

function ButtonPress:update()
	if PlayerData.isDancing == true then
		if self.active == true then
			self:tryMoveToFreePosition((self.x - (0.5 * self.bpm / 3)), self.y)

			if self.x <= 32 then
				self.missedPass = true -- scrolled past the hitzone unpressed
				self:moveTo(self.startPoint, self.y)
				self:changeButtonSprite() -- again, pulls from keyProvider
			end
		end
	end
end