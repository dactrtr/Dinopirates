
class('FXsonar').extends(Graphics.sprite)

local sonar = Graphics.image.new(400,240)

function FXsonar:init(x, y)
	self.active = true
	self:moveTo(400/2,240/2)
	self:setImage(sonar)
	self:setZIndex(13)
	self:add()	
end
function FXsonar:disableFX()
	self.active = false
end
function FXsonar:activate(x, y, shape)
	if self.active then
		shape = shape or 'enemy'
	
		local function drawShape(radius)
			Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			if shape == "enemy" then
				circle = Graphics.drawCircleAtPoint(x, y, radius)
			elseif shape == "key" then
				square = Graphics.drawRect(x - radius/2, y - radius/2, radius, radius)
			end
			Graphics.popContext()
		end
	
		local function clearShape(radius)
			Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			if shape == "enemy" then
				circle = Graphics.drawCircleAtPoint(x, y, radius)
			elseif shape == "key" then
				square = Graphics.drawRect(x - radius/2, y - radius/2, radius, radius)
			end
			Graphics.popContext()
		end
	
		local delays = {200, 250, 300, 350, 400, 450}
		local radii = {10, 25, 35}
	
		for i = 1, #delays do
			local radiusIndex = math.ceil(i / 2)
			local drawFunction = i % 2 == 1 and drawShape or clearShape
			playdate.timer.performAfterDelay(delays[i], function()
				drawFunction(radii[radiusIndex])
			end)
		end
	end
end
