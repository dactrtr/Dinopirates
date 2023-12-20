
class('FXsonar').extends(Graphics.sprite)

local sonar = Graphics.image.new(80,80)

function FXsonar:init(x, y)
	
	--self.speed = player.speed
	--self.player = player
	self:moveTo(x,y)
	--self:setCollidesWithGroups(1)
	self:setImage(sonar)
	self:setZIndex(13)
	self:add()	
end

function FXsonar:activate(x,y)
	print(x .. "," .. y)
	local function pulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorWhite)
			circle = Graphics.drawCircleAtPoint( 40, 40, 30 )
		Graphics.popContext()
	end
	local function removePulse()
		Graphics.pushContext(sonar)
			Graphics.setColor(Graphics.kColorClear)
			circle = Graphics.drawCircleAtPoint( 40, 40, 30 )
		Graphics.popContext()
	end
	playdate.timer.performAfterDelay(500, pulse)
	
	playdate.timer.performAfterDelay(1000, removePulse)
end
function FXsonar:update()
	--print("Aqui estoy " .. self.x .. "," .. self.y)
	-- Graphics.pushContext(sonar)
	-- 	Graphics.setColor(Graphics.kColorWhite)
	-- 	Graphics.drawCircleAtPoint( 40, 40, 30 )
	-- Graphics.popContext()
end
