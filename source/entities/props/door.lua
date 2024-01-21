
door = {}
class('Door').extends(NobleSprite)

function Door:init(x, y, zIndex)
  Door.super.init(self,'assets/images/props/door', true)
  --- animation states
  self.animation:addState('closed', 1, 9)
  self.animation.closed.frameDuration = 12
  self.animation:setState('closed')

  -- position and z-index
  self:setSize( 56, 10)
  self:setCollideRect(0, 4, 48, 20)
  self:setZIndex(zIndex)
  
  self:setGroups(3)
  
  self:add(x,y)
end

function Door:update()
end

