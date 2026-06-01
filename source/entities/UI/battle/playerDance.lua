PlayerDance ={}
class('PlayerDance').extends(NobleSprite)

function PlayerDance:init(bpm, spritePath)
	PlayerDance.super.init(self, spritePath or 'assets/images/ui/battle/playerDance', true)
	
	if bpm == nil or bpm == 0 then
		bpm = 6
	end
	local frameduration = bpm/2
	-- Mark: animation states
	self.animation:addState('idle', 1, 5)
	self.animation.idle.frameDuration = frameduration
	self.animation:addState('jump', 5, 9, 'idle')
	self.animation.jump.frameDuration = frameduration
	self.animation:addState('crouch', 11, 15, 'idle')
	self.animation.crouch.frameDuration = frameduration
	self.animation:addState('left', 16, 20, 'idle')
	self.animation.left.frameDuration = frameduration
	self.animation:addState('right', 21, 24, 'idle')
	self.animation.right.frameDuration = frameduration
	
	self.animation:setState('idle')
	self:setZIndex(6)
	self:setSize(246, 214)
	--self:setCollideRect(0, 0, 10, 40)
	self:setCenter(0,0)
	self:add(0, 26)
	
end
function PlayerDance:changeAnimation(input)
	local animationMap = {
		upButton = "jump",
		downButton = "crouch",
		leftButton = "left",
		rightButton = "right"
	}

	local newState = animationMap[input]
	if newState then
		self.animation:setState(newState)
	end
end
function PlayerDance:update()
	
end