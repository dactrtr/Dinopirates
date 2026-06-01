
Items = {}
class('Items').extends(NobleSprite)

import 'entities/FX/FXsonar'

function Items:init(x, y, type, keyNumber, grants, iid)
  Items.super.init(self,'assets/images/items/items-key', true)
  --- animation states
  self.animation:addState('keycard', 13, 15)
  self.animation.keycard.frameDuration = 8 
  self.animation:addState('lamp', 7, 9)
  self.animation.lamp.frameDuration = 8 
  self.animation:addState('itemgift', 16, 18)
  self.animation.itemgift.frameDuration = 8 
  self.animation:addState('notes', 10, 12)
  self.animation.notes.frameDuration = 8
  self.animation:addState('boots', 1, 3)
  self.animation.boots.frameDuration = 8  
  self.animation:addState('plunger', 4, 6)
  self.animation.plunger.frameDuration = 8  
  self.animation:addState('radio', 19, 21)
  self.animation.radio.frameDuration = 8
  -- TODO art: dedicated food frames; reuse 'notes' frames (10-12) as a placeholder for now
  self.animation:addState('food', 22, 24)
  self.animation.food.frameDuration = 8
  self:setSize(32, 32)
  self:setCollideRect(0 ,0, 32, 32)
  self:setZIndex(ZIndex.items)
  self.type = type
  self.keyNumber = keyNumber  -- Store key number for keycards
  self.grants = grants        -- Store grants for itemgift and notes
  self.iid = iid              -- LDtk entity iid for per-instance persistence (food)
  self.animation:setState(type)
  sonar = FXsonar(self.x,self.y)
  self:setGroups(3)
  
  self:add(x,y)
end

function Items:sonar(x,y)
 -- sonar:activate(self.x,self.y,'key')
end

function Items:removeAll()
  sonar:disableFX()
  self:remove()
end



