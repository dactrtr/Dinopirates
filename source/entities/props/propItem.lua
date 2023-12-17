
Prop = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, zIndex)
  PropItem.super.init(self,'assets/images/props/props', true)
  --- animation states
  self.animation:addState('chair', 1, 1)
  self.animation:setState('chair')
  -- position and z-index
  self:setSize(64, 64)
  self:setCollideRect(0,0, 32,32)
  self:setZIndex(zIndex)
  
  self:setGroups(1)
  
  self:add(x,y)
end

function PropItem:update()
end

