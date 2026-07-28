class("UIHud").extends(NobleSprite)


function UIHud:init(x,y)
    UIHud.super.init(self,'assets/images/ui/interaction.png', true)
    -- Mark: animation states
    local ringDuration = 3
    self.animation:addState('pressA', 1, 6)
    self.animation.pressA.frameDuration = 6
    self.animation:addState('ring', 7, 8, 'ring2')
    self.animation.ring.frameDuration = ringDuration
    self.animation:addState('ring2', 7, 8, 'ring3')
    self.animation.ring2.frameDuration = ringDuration
    self.animation:addState('ring3', 7, 8, 'ring4')
    self.animation.ring3.frameDuration = ringDuration
    self.animation:addState('ring4', 7, 8, 'ring5')
    self.animation.ring4.frameDuration = ringDuration
    self.animation:addState('ring5', 7, 8, 'answer')
    
    self.animation.ring5.frameDuration = ringDuration
    self.animation:addState('answer', 9, 14)
    self.animation.answer.frameDuration = 6
    
    self.animation:addState('crankAntiClock', 15, 18)
    self.animation.crankAntiClock.frameDuration = 6
    
    self.animation:addState('crankClock', 19, 22)
    self.animation.crankClock.frameDuration = 6
    
    self.animation:addState('Investigate', 23, 28)
    self.animation.Investigate.frameDuration = 6
    
    self.animation:addState('Warning', 29, 32)
    self.animation.Warning.frameDuration = 6
    
    self.animation:setState('pressA')
    -- Mark: properties (since are the sames from the sonar hud maybe this should be just a class)
    self:setSize(22,37)
    self:setZIndex(ZIndex.ui)
    self:add(x + 30,y - 30)
    self:setVisible(false)
end

function UIHud:setRing()
    self.animation:setState('ring')
end
function UIHud:setPressA()
    self.animation:setState('pressA')
end
function UIHud:setCrankClock()
    self.animation:setState('crankClock')
end
function UIHud:setCrankAntiClock()
    self.animation:setState('crankAntiClock')
end
function UIHud:setInvestigate()
    self.animation:setState('Investigate')
end

function UIHud:setWarning()
    self.animation:setState('Warning')
    self:setVisible(true)
end


