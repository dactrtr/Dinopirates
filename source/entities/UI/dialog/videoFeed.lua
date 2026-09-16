class("videoFeed").extends(NobleSprite)

function videoFeed:init(x,y, sourceFeed,Zindex)
	videoFeed.super.init(self,'assets/images/ui/dialog/videoFeed.png', true)
	-- Mark: animation states
	self.animation:addState('player', 1, 1)
	self.animation.player.frameDuration = 12
	self.animation:addState('player-tiny', 14, 14) 
	self.animation['player-tiny'].frameDuration = 12
	
	self.animation:addState('radioHand', 2, 2)
	self.animation.radioHand.frameDuration = 12
	self.animation:addState('radioHand-tiny', 14, 14) 
	self.animation['radioHand-tiny'].frameDuration = 12
	
	self.animation:addState('radioPocket', 3, 3)
	self.animation.radioPocket.frameDuration = 12
	self.animation:addState('radioPocket-tiny', 3, 3) 
	self.animation['radioPocket-tiny'].frameDuration = 12
	
	self.animation:addState('radioRing', 4, 5)
	self.animation.radioRing.frameDuration = 12
	self.animation:addState('radioRing-tiny', 16, 16) 
	self.animation['radioRing-tiny'].frameDuration = 12
	
	self.animation:addState('notesHand', 6, 6)
	self.animation.notesHand.frameDuration = 12
	self.animation:addState('notesHand-tiny', 17, 17) 
	self.animation['notesHand-tiny'].frameDuration = 12
	
	self.animation:addState('playerWorry', 7, 7)
	self.animation.playerWorry.frameDuration = 12
	self.animation:addState('playerWorry-tiny', 21, 21) 
	self.animation['playerWorry-tiny'].frameDuration = 12
	
	self.animation:addState('playerSurprise', 8, 8)
	self.animation.playerSurprise.frameDuration = 12
	self.animation:addState('playerSurprise-tiny', 15, 15) 
	self.animation['playerSurprise-tiny'].frameDuration = 12
	
	self.animation:addState('playerHappy', 9, 9)
	self.animation.playerHappy.frameDuration = 12
	self.animation:addState('playerHappy-tiny', 22, 22) 
	self.animation['playerHappy-tiny'].frameDuration = 12
	
	self.animation:addState('playerAngry', 10, 10)
	self.animation.playerAngry.frameDuration = 12
	self.animation:addState('playerAngry-tiny', 23, 23) 
	self.animation['playerAngry-tiny'].frameDuration = 12
	
	self.animation:addState('playerSleepy', 11, 11)
	self.animation.playerSleepy.frameDuration = 12
	self.animation:addState('playerSleepy-tiny', 24, 24) 
	self.animation['playerSleepy-tiny'].frameDuration = 12
	
	self.animation:addState('playerScared', 13, 13)
	self.animation.playerScared.frameDuration = 12
	self.animation:addState('playerScared-tiny', 26, 26) 
	self.animation['playerScared-tiny'].frameDuration = 12
	
	self.animation:addState('playerCry', 12, 12)
	self.animation.playerCry.frameDuration = 12
	self.animation:addState('playerCry-tiny', 25, 25) 
	self.animation['playerCry-tiny'].frameDuration = 12
		
	self.animation:addState('watchRing', 18, 18)
	self.animation.watchRing.frameDuration = 12
	self.animation:addState('watchRing-tiny', 18, 18) 
	self.animation['watchRing-tiny'].frameDuration = 12
	self.animation:setState(sourceFeed)
	
	self.animation:addState('crewMember', 19, 19)
	self.animation.crewMember.frameDuration = 12
	self.animation:addState('crewMember-tiny', 20, 20) 
	self.animation['crewMember-tiny'].frameDuration = 12
	
	
	self.animation:setState(sourceFeed)
	
	self:setSize(118*2,94*2) -- this is cuz is not a table
	self:setZIndex(Zindex)
	self:add(x,y)
end



