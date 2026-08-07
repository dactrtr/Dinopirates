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

  self.animation:addState('dashRight', 65, 68)
  self.animation.dashRight.frameDuration = 3

  self.animation:addState('dashLeft', 69, 72)
  self.animation.dashLeft.frameDuration = 3

  self.animation:addState('dashUp', 65, 68)
  self.animation.dashUp.frameDuration = 3

  self.animation:addState('dashDown', 65, 68)
  self.animation.dashDown.frameDuration = 3

  self.animation:addState('idleTiny', 73, 81)
  self.animation.idleTiny.frameDuration = frameDurationWalk/2
  
  self.animation:addState('rightTiny', 82, 84)
  self.animation.rightTiny.frameDuration = frameDurationWalk/2
  
  self.animation:addState('leftTiny', 85, 87)
  self.animation.leftTiny.frameDuration = frameDurationWalk/2
  
  self.animation:addState('downTiny', 88, 90)
  self.animation.downTiny.frameDuration = frameDurationWalk/2
  
  self.animation:addState('upTiny', 91, 93)
  self.animation.upTiny.frameDuration = frameDurationWalk/2
  
  self.animation:addState('transformTo', 94, 99, 'idleTiny')
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
  
  self.animation:addState('sleep', 146, 147)
  self.animation.sleep.frameDuration = 18

  self.animation:addState('sleepTiny', 160, 161)
  self.animation.sleepTiny.frameDuration = 18

  -- Balancing (about to fall/slide). Placeholder: reuse the sleep frames until dedicated art
  -- exists. balancingTiny mirrors the tiny/normal split like sleep/sleepTiny.
  self.animation:addState('balancing', 115, 116)
  self.animation.balancing.frameDuration = 18
  
  self.animation:addState('chargeTiny', 112, 114)
  self.animation.chargeTiny.frameDuration = 18

  self.animation:addState('balancingTiny', 162, 163)
  self.animation.balancingTiny.frameDuration = 18

  self.animation:addState('shootLeft', 148, 150, 'noLegLeft')
  self.animation.shootLeft.frameDuration = 4

  self.animation:addState('shootRight', 151, 153, 'noLegRight')
  self.animation.shootRight.frameDuration = 4
  
  self.animation:addState('noLegLeft', 149, 150)
  self.animation.noLegLeft.frameDuration = 4
  
  self.animation:addState('noLegRight', 152, 153)
  self.animation.noLegRight.frameDuration = 4
  
  self.animation:addState('eating', 154, 157)
  self.animation.eating.frameDuration = 8
  
  self.animation:addState('shock', 158, 159)
  self.animation.shock.frameDuration = 8
  
  if PlayerData.fromTitle then
    self.animation:setState(PlayerData.isTiny and 'sleepTiny' or 'sleep')
  elseif (PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false) then
    self.animation:setState('lampIdle')
  elseif PlayerData.isTiny == true then
    self.animation:setState('idleTiny')
  else
    self.animation:setState('idle')
  end
  
end

