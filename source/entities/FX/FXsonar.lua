
class('FXsonar').extends(Graphics.sprite)

local sonar = Graphics.image.new(400,240)

function FXsonar:init(x, y)
	
	self:moveTo(400/2,240/2)
	self:setImage(sonar)
	self:setZIndex(13)
	self:add()	
end

function FXsonar:activate(x,y)
	local function pulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			circle = Graphics.drawCircleAtPoint( x, y, 10 )
		Graphics.popContext()
	end
	local function removePulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			circle = Graphics.drawCircleAtPoint( x, y, 10 )
		Graphics.popContext()
	end
	local function pulse1()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			circle = Graphics.drawCircleAtPoint( x, y, 25 )
		Graphics.popContext()
	end
	local function removePulse1()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			circle = Graphics.drawCircleAtPoint( x, y, 25 )
		Graphics.popContext()
	end
	local function pulse2()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			circle = Graphics.drawCircleAtPoint( x, y, 35 )
		Graphics.popContext()
	end
	local function removePulse2()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			circle = Graphics.drawCircleAtPoint( x, y, 35 )
		Graphics.popContext()
	end
	playdate.timer.performAfterDelay(200, pulse)
	playdate.timer.performAfterDelay(250, removePulse)
	playdate.timer.performAfterDelay(300, pulse1)
	playdate.timer.performAfterDelay(350, removePulse1)
	playdate.timer.performAfterDelay(400, pulse2)
	playdate.timer.performAfterDelay(450, removePulse2)
	--- Mark: TODO this could be optmized to just a few functions xD
end

