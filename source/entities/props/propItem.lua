
PropItem = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, type, zIndex, nocollide)
  PropItem.super.init(self,'assets/images/props/props', true)
  --- animation states
  self.animation:addState('chair', 1, 1)
  self.animation:addState('fellchair', 2, 2)
  self.animation:addState('box', 3, 3)
  self.animation:addState('trash', 4, 4)
  self.animation:addState('toxic', 5, 5)
  self.animation:addState('table', 6, 6)
  self.animation:addState('blood', 7, 7)
  self.animation:addState('blood2', 8, 8)
  self.animation:addState('deadrat', 9, 9)
  self.animation:setState(type)
  -- position and z-index
  self:setSize(32, 32)
  if nocollide == nil then
  self:setCollideRect(0,8, 32,24)
  end
  self:setZIndex(zIndex)
  
  self:setGroups(3)
  
  self:add(x,y)
end


