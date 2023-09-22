FXspeed = {}
class('FXspeed').extends(NobleSprite)


function FXspeed:init()
  FXspeed.super.init(self,'assets/images/fx/fx-speed', true)
  -- 
  --animation states
  self.animation:addState('initial',1,1)
  self.animation:addState('startSpeed',1,8)
  self.animation.startSpeed.frameDuration = 2
  self.animation:addState('loopSpeed',9,14)
  self.animation.loopSpeed.frameDuration = 4
  self.animation:addState('stopSpeed',15,22,'initial')
  self.animation.stopSpeed.frameDuration = 4
  -- Position and Z-index
  self:setSize(400,240)
  self:setZIndex(2)
  -- self:moveTo(50,0)
  
  -- Add
  self:add(200,125)
end

function FXspeed:clearFX()
  self:remove()
end

function FXspeed:update()
end



