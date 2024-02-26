
Items = {}
class('Items').extends(NobleSprite)

import 'entities/FX/FXsonar'

function Items:init(x, y, type)
  Items.super.init(self,'assets/images/items/item-key', true)
  --- animation states
  self.animation:addState('keycard', 1, 20)
  self.animation.keycard.frameDuration = 8 
  self.animation:addState('lamp', 21, 25)
  self.animation.lamp.frameDuration = 8 
  self:setSize(48, 48)
  self:setCollideRect(8,8, 32,24)
  self:setZIndex(ZIndex.props)
  self.type = type
  self.animation:setState(type)
  sonar = FXsonar(self.x,self.y)
  self:setGroups(3)
  
  self:add(x,y)
end

function Items:sonar(x,y)
 -- sonar:activate(self.x,self.y,'key')
end

function Items:update()
  -- if PlayerData.sonarActive == true  then
  --    self:sonar('key')
  --  end
end


