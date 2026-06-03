
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
  self.animation:addState('CM004', 4, 4)
  self.animation:addState('CM005', 5, 5)
  self.animation:addState('CM006', 6, 6)
  self.animation:addState('CM007', 7, 7)
  self.animation:addState('CM008', 8, 8)
  self.animation:addState('CM009', 9, 9)
  self.animation:addState('CM010', 10, 10)
  self.animation:addState('CM011', 11, 11)
  self.animation:addState('CM012', 12, 12)
  self.animation:addState('CM013', 13, 13)
  self.animation:addState('CM014', 14, 14)
  self.animation:addState('CM015', 15, 15)
  self.animation:addState('CM016', 16, 16)
  self.animation:addState('CM017', 17, 17)
  self.animation:addState('CM018', 18, 18)
  self.animation:addState('CM019', 19, 19)
  self.animation:addState('CM020', 20, 20)
  self.animation:addState('CM021', 21, 21)
  -- Resolve the hat: accept a number (1..21) or a "CMxxx" string; fall back to CM001
  -- if nil or unknown (e.g. a crew spawn marker without a valid crewID).
  local known = {}
  for i = 1, 21 do known[string.format('CM%03d', i)] = true end
  local n = tonumber(type)
  if n then type = string.format('CM%03d', n) end
  if not (type and known[type]) then type = 'CM001' end
  self.animation:setState(type)
  -- position and z-index
  self:setSize(20, 16)
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x,y)
end


