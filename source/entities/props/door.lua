Door = {}
class('Door').extends(NobleSprite)

function Door:init(x, y, direction, status, zIndex)
  if direction == 'top' or direction == 'down' then
    Door.super.init(self,'assets/images/props/door-horizontal', true)
    self:setSize( 56, 10)
    self:setCollideRect(12, 4, 24, 18)
  elseif direction == 'left' or 'right' then
    Door.super.init(self,'assets/images/props/door-vertical', true)
    self:setSize( 10, 56)
    self:setCollideRect(4, 12, 18, 24)
  end
  --- animation states
  self.animation:addState('normalClosed', 18, 18)
  self.animation.normalClosed.frameDuration = 12
  self.animation:addState('reverseClosed', 9, 9)
  self.animation.reverseClosed.frameDuration = 12
  self.animation:addState('normalOpen', 10, 10)
  self.animation.normalOpen.frameDuration = 12
  self.animation:addState('reverseOpen', 1, 1)
  self.animation.reverseOpen.frameDuration = 12
  self.animation:addState('normalOpening', 18, 10)
  self.animation.normalOpening.frameDuration = 12
  self.animation:addState('reverseOpening', 9, 1)
  self.animation.reverseOpening.frameDuration = 12
  self.animation:addState('normalClosing', 10, 18)
  self.animation.normalClosing.frameDuration = 12
  self.animation:addState('reverseClosing', 1, 9)
  self.animation.reverseClosing.frameDuration = 12
  
  if direction == 'top' or direction == 'right' then
    if status == 'closed' then
      self.animation:setState('normalClosed')
    elseif status == 'open'  then
      self.animation:setState('normalOpen')
    end
    --self.animation:setState('normal')
  elseif direction == 'left' or direction == 'down' then
    if status == 'closed' then
      self.animation:setState('reverseClosed')
    elseif status == 'open'  then
      self.animation:setState('reverseOpen')
    end
  end
  
  -- position and z-index
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x,y)
end
