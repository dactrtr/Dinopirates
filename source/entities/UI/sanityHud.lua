class("sanityHud").extends(NobleSprite)


function sanityHud:init(x, y, zIndex, player)
	sanityHud.super.init(self,'assets/images/ui/sanity.png', true)
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
	self:add(x,y)
end
function sanityHud:update()
	local sanity = PlayerData.sanity
	
	local t = Config.Sanity.hudFace
	if sanity < t.insane then
		self.animation:setState('insane')
	elseif sanity < t.mediocre then
		self.animation:setState('mediocre')
	elseif sanity < t.normal then
		self.animation:setState('normal')
	elseif sanity < t.good then
		self.animation:setState('good')
	end
end


