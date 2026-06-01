function Player:initAnimations()
  local frameDurationWalk = 8
  self.animation:addState('idle', 41, 52)
  self.animation.idle.frameDuration = 12
  
  self.animation:addState('right', 11, 15)
  self.animation.right.frameDuration = frameDurationWalk 
  
  self.animation:addState('left', 1, 5)
  self.animation.left.frameDuration = frameDurationWalk 
  
  self.animation:addState('down', 26, 30)
  self.animation.down.frameDuration = frameDurationWalk 
  
  self.animation:addState('up', 21, 25)
  self.animation.up.frameDuration = frameDurationWalk 
  
  self.animation:addState('lampIdle', 53, 64)
  self.animation.lampIdle.frameDuration = frameDurationWalk
  
  self.animation:addState('lampRight', 16, 20)
  self.animation.lampRight.frameDuration = frameDurationWalk
  
  self.animation:addState('lampLeft', 6, 10)
  self.animation.lampLeft.frameDuration = frameDurationWalk
  
  self.animation:addState('lampDown', 31, 35)
  self.animation.lampDown.frameDuration = frameDurationWalk
  
  self.animation:addState('charge', 36, 40)
  self.animation.charge.frameDuration = 12
  
  self.animation:addState('tinyIdle', 73, 81)
  self.animation.tinyIdle.frameDuration = frameDurationWalk/2
  
  self.animation:addState('tinyRight', 82, 84)
  self.animation.tinyRight.frameDuration = frameDurationWalk/2
  
  self.animation:addState('tinyLeft', 85, 87)
  self.animation.tinyLeft.frameDuration = frameDurationWalk/2
  
  self.animation:addState('tinyDown', 88, 90)
  self.animation.tinyDown.frameDuration = frameDurationWalk/2
  
  self.animation:addState('tinyUp', 91, 93)
  self.animation.tinyUp.frameDuration = frameDurationWalk/2
  
  self.animation:addState('transformTo', 94, 99, 'tinyIdle')
  self.animation.transformTo.frameDuration = 4
  
  self.animation:addState('transformCycle', 100, 105)
  self.animation.transformCycle.frameDuration = 3
  
  self.animation:addState('slideRight', 115, 116)
  self.animation.slideRight.frameDuration = 3
  
  self.animation:addState('slideLeft', 117, 118)
  self.animation.slideLeft.frameDuration = 3

  self.animation:addState('slideDown', 119, 120)
  self.animation.slideDown.frameDuration = 3

  self.animation:addState('slideUp', 121, 122)
  self.animation.slideUp.frameDuration = 3

  self.animation:addState('slideExitRight', 123, 127, 'idle')
  self.animation.slideExitRight.frameDuration = 3

  self.animation:addState('slideExitLeft', 128, 132, 'idle')
  self.animation.slideExitLeft.frameDuration = 4

  self.animation:addState('slideExitUp', 137, 141, 'idle')
  self.animation.slideExitUp.frameDuration = 4

  self.animation:addState('slideExitDown', 133, 136, 'idle')
  self.animation.slideExitDown.frameDuration = 4
  
  self.animation:addState('slideTiny', 142, 145)
  self.animation.slideTiny.frameDuration = 4
  
  self.animation:addState('sleep', 147, 148)
  self.animation.sleep.frameDuration = 18
  
  if PlayerData.fromTitle then
    self.animation:setState('sleep')
  elseif (PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false) then
    self.animation:setState('lampIdle')
  elseif PlayerData.isTiny == true then
    self.animation:setState('tinyIdle')
  else
    self.animation:setState('idle')
  end
  
end

