
class('FXsonar').extends(Graphics.sprite)

local sonar = Graphics.image.new(400,240)

function FXsonar:init(x, y)
	
	self:moveTo(400/2,240/2)
	self:setImage(sonar)
	self:setZIndex(13)
	self:add()	
end

function FXsonar:activate(x,y)
	print(x .. "," .. y)
	local function pulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			circle = Graphics.drawCircleAtPoint( x, y, 30 )
		Graphics.popContext()
	end
	local function removePulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			circle = Graphics.drawCircleAtPoint( x, y, 30 )
		Graphics.popContext()
	end
	playdate.timer.performAfterDelay(500, pulse)
	
	playdate.timer.performAfterDelay(1000, removePulse)
end

