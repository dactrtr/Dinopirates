class("sonarHud").extends(NobleSprite)


function sonarHud:init(x, y, zIndex, player)
	sonarHud.super.init(self,'assets/images/ui/sonar.png', true)
	self.animation:addState('idle', 2, 5)
	self.animation.idle.frameDuration = 12
	self.animation:addState('empty', 1, 2)
	self.animation.empty.frameDuration = 12
	self:setSize(20,12)
	self:setZIndex(zIndex)
	self.player = player
	self.indicatorPosition = indicator
	self:add(x,y)
end
function sonarHud:update()
	if PlayerData.battery < 20 then
		self.animation:setState('empty')
	else
		self.animation:setState('idle')
	end
end


