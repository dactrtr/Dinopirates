
Hats = {}
class('Hats').extends(NobleSprite)

function Hats:init(x, y, type, zIndex)
  Hats.super.init(self,'assets/images/props/hats', true)
  -- error handling
  if type == nil then
    type = 'CM001'
  end
  --- animation states
  self.animation:addState('CM001', 1, 1)
  self.animation:addState('CM002', 2, 2)
  self.animation:addState('CM003', 3, 3)
  self.animation:setState(type)
  -- position and z-index
  self:setSize(20, 16)
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x,y)
end


