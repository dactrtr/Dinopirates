
PropItem = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, type, zIndex)
  PropItem.super.init(self,'assets/images/props/props', true)
  --- animation states
  self.animation:addState('chair', 1, 1)
  self.animation:addState('fellchair', 2, 2)
  self.animation:addState('box', 3, 3)
  self.animation:addState('trash', 4, 4)
  self.animation:addState('toxic', 5, 5)
  self.animation:setState(type)
  -- position and z-index
  self:setSize(32, 32)
  self:setCollideRect(0,8, 32,24)
  self:setZIndex(zIndex)
  
  self:setGroups(3)
  
  self:add(x,y)
end


