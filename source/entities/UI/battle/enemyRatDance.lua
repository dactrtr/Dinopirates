EnemyRatDance = {}
class('EnemyRatDance').extends(NobleSprite)

function EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)
	EnemyRatDance.super.init(self, spritePath or 'assets/images/ui/battle/enemyDance', true)
if bpm == nil or bpm == 0 then
		bpm = 6
	end
	self.evolveType = evolveType
	self.isEvolving = isEvolving
	local frameduration = bpm/2
	-- Mark: animation states
	self.animation:addState('evolving', 30, 33)
	self.animation.evolving.frameDuration = frameduration
	
	if self.evolveType == 'basic' then
		
		self.animation:addState('idle', 1, 5)
		self.animation.idle.frameDuration = frameduration
		self.animation:addState('upAttack', 6, 9,'idle')
		self.animation.upAttack.frameDuration = frameduration
		self.animation:addState('leftAttack', 10, 13,'idle')
		self.animation.leftAttack.frameDuration = frameduration
		self.animation:addState('rightAttack', 14, 17,'idle')
		self.animation.rightAttack.frameDuration = frameduration
		self.animation:addState('downAttack', 18, 21,'idle')
		self.animation.downAttack.frameDuration = frameduration
		self.animation:addState('bButton', 22, 25,'idle')
		self.animation.bButton.frameDuration = 3
		self.animation:addState('aButton', 26, 29,'idle')
		self.animation.aButton.frameDuration = 3
		
		self.animation:setState('idle')
		
	elseif self.evolveType == 'evolve'  then
		--list of animations
		self.animation:addState('idle', 1, 5)
		self.animation.idle.frameDuration = frameduration
		self.animation:addState('upAttack', 6, 9,'idle')
		self.animation.upAttack.frameDuration = frameduration
		self.animation:addState('leftAttack', 10, 13,'idle')
		self.animation.leftAttack.frameDuration = frameduration
		self.animation:addState('rightAttack', 14, 17,'idle')
		self.animation.rightAttack.frameDuration = frameduration
		self.animation:addState('downAttack', 18, 21,'idle')
		self.animation.downAttack.frameDuration = frameduration
		self.animation:addState('bButton', 22, 25,'idle')
		self.animation.bButton.frameDuration = 3
		self.animation:addState('aButton', 26, 29,'idle')
		self.animation.aButton.frameDuration = 3
		
		self.animation:setState('idle')
	
	elseif self.evolveType == 'badass'  then
	--list of animations
	self.animation:addState('idle', 1, 5)
	self.animation.idle.frameDuration = frameduration
	self.animation:addState('upAttack', 6, 9,'idle')
	self.animation.upAttack.frameDuration = frameduration
	self.animation:addState('leftAttack', 10, 13,'idle')
	self.animation.leftAttack.frameDuration = frameduration
	self.animation:addState('rightAttack', 14, 17,'idle')
	self.animation.rightAttack.frameDuration = frameduration
	self.animation:addState('downAttack', 18, 21,'idle')
	self.animation.downAttack.frameDuration = frameduration
	self.animation:addState('bButton', 22, 25,'idle')
	self.animation.bButton.frameDuration = 3
	self.animation:addState('aButton', 26, 29,'idle')
	self.animation.aButton.frameDuration = 3
	
	self.animation:setState('idle')
	
	elseif self.evolveType == 'boss'  then
	--list of animations
	self.animation:addState('idle', 1, 5)
	self.animation.idle.frameDuration = frameduration
	self.animation:addState('upAttack', 6, 9,'idle')
	self.animation.upAttack.frameDuration = frameduration
	self.animation:addState('leftAttack', 10, 13,'idle')
	self.animation.leftAttack.frameDuration = frameduration
	self.animation:addState('rightAttack', 14, 17,'idle')
	self.animation.rightAttack.frameDuration = frameduration
	self.animation:addState('downAttack', 18, 21,'idle')
	self.animation.downAttack.frameDuration = frameduration
	self.animation:addState('bButton', 22, 25,'idle')
	self.animation.bButton.frameDuration = 3
	self.animation:addState('aButton', 26, 29,'idle')
	self.animation.aButton.frameDuration = 3
	
	self.animation:setState('idle')
	
	end
	
	
	self:setZIndex(2)
	self:setSize(214, 214)
	self:setCenter(0,0)
	self:add(158, 26)
	
end

function EnemyRatDance:changeAnimation(input)
	local animationMap = {
		downButton = "upAttack",
		upButton = "downAttack",
		leftButton = "leftAttack",
		rightButton = "rightAttack",
	}
	
	local newState = animationMap[input]
	if newState then
		self.animation:setState(newState)
	end
end

function EnemyRatDance:setIdle()
	self.animation:setState('idle')
end
function EnemyRatDance:attackAnimation(input)
	local animationMap = {
		aButton = 'aButton',
		bButton = 'bButton'
	}
	
	local newState = animationMap[input]
	if newState then
		self.animation:setState(newState)
	end
end
