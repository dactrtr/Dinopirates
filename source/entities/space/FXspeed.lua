class('FXspeed').extends(NobleSprite)

function FXspeed:init()
    FXspeed.super.init(self, 'assets/images/space/fx-speed', true)

    self.animation:addState('initial',    1,  1)
    self.animation:addState('startSpeed', 1,  8)
    self.animation.startSpeed.frameDuration = 2
    self.animation:addState('loopSpeed',  9, 14)
    self.animation.loopSpeed.frameDuration  = 4
    self.animation:addState('stopSpeed', 15, 22, 'initial')
    self.animation.stopSpeed.frameDuration  = 4

    self:setSize(400, 240)
    self:setZIndex(ZIndex.fx)
    self:add(200, 120)
end
