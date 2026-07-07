BackgroundDance ={}
class('BackgroundDance').extends(NobleSprite)

function BackgroundDance:init(spritePath)
	BackgroundDance.super.init(self, spritePath or 'assets/images/ui/battle/background',true)
	
	if bpm == nil then
		bpm = 6
	end
	local frameduration = bpm
	-- Mark: animation states
	self.animation:addState('cover',1,1)
	self.animation.cover.frameDuration = frameduration
	
	self:setZIndex(1)
	
	self.animation:setState('cover')
	self:setSize(400, 240)
	self:add(200, 120)
	
end
