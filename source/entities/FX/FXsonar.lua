
class('FXsonar').extends(Graphics.sprite)

local sonar = Graphics.image.new(400,240)

function FXsonar:init(x, y)
	
	self:moveTo(400/2,240/2)
	self:setImage(sonar)
	self:setZIndex(13)
	self:add()	
end

function FXsonar:activate(x, y, type)
	local function pulse(radius)
		Graphics.pushContext(sonar)
		Graphics.setColor(Graphics.kColorWhite)
		circle = Graphics.drawCircleAtPoint(x, y, radius)
		Graphics.popContext()
	end

	local function removePulse(radius)
		Graphics.pushContext(sonar)
		Graphics.setColor(Graphics.kColorClear)
		circle = Graphics.drawCircleAtPoint(x, y, radius)
		Graphics.popContext()
	end

	local delays = {200, 250, 300, 350, 400, 450}
	local radii = {10, 25, 35}

	for i = 1, #delays do
		local radiusIndex = math.ceil(i / 2)
		local pulseFunction = i % 2 == 1 and pulse or removePulse
		playdate.timer.performAfterDelay(delays[i], function()
			pulseFunction(radii[radiusIndex])
		end)
	end
end

