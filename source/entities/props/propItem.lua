
Prop = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, zIndex)
  PropItem.super.init(self,'assets/images/props/props', true)
  --- animation states
  self.animation:addState('chair', 1, 1)
  self.animation:setState('chair')
  -- position and z-index
  self:setSize(32, 32)
  self:setCollideRect(0,8, 32,24)
  self:setZIndex(zIndex)
  
  self:setGroups(3)
  
  self:add(x,y)
end

function PropItem:update()
end

