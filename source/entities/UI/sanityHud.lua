class("sanityHud").extends(NobleSprite)


function sanityHud:init(x, y, zIndex, player, indicator)
	sonarHud.super.init(self,'assets/images/ui/sanity.png', true)
	-- Mark: animation states
	self.animation:addState('good', 1, 2)
	self.animation.good.frameDuration = 12
	
	self.animation:addState('normal', 3, 4)
	self.animation.normal.frameDuration = 12
	
	self.animation:addState('mediocre', 5, 6)
	self.animation.mediocre.frameDuration = 12
	
	self.animation:addState('insane', 7, 8)
	self.animation.insane.frameDuration = 12
	
	-- Mark: properties (since are the sames from the sonar hud maybe this should be just a class)
	self:setSize(17,12)
	self:setZIndex(zIndex)
	self.player = player
	self.indicatorPosition = indicator
	self:add(x,y)
end
function sanityHud:update()
	local sanity = self.player.sanity
	if not self.indicatorPosition then
		self:moveTo(self.player.x + 10 , self.player.y - 36)
	end
	if sanity < 30 then
		self.animation:setState('insane')
	elseif sanity < 50 then
		self.animation:setState('mediocre')
	elseif sanity < 80 then
		self.animation:setState('normal')
	elseif sanity < 100 then
		self.animation:setState('good')
	end
end


