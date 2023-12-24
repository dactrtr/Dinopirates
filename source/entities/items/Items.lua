
Items
 = {}
class('Items').extends(NobleSprite)

import 'entities/FX/FXsonar'

function Items:init(x, y, zIndex)
  Items.super.init(self,'assets/images/items/item-key', true)
  --- animation states
  self.animation:addState('idle', 1, 20)
  self.animation:setState('idle')
  self.animation.idle.frameDuration = 8  -- position and z-index
  self:setSize(48, 48)
  self:setCollideRect(8,8, 32,24)
  self:setZIndex(zIndex)
  
  self:setGroups(3)
  
  self:add(x,y)
end
function Items:sonar(x,y)
  local sonar = FXsonar(self.x,self.y)
  sonar:activate(self.x,self.y,'key')
end
function Items:update()
end

