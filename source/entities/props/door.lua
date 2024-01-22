Door = {}
class('Door').extends(NobleSprite)

function Door:init(x, y, direction, status, zIndex)
  local isHorizontal = direction == 'top' or direction == 'down'
  local asset = isHorizontal and 'assets/images/props/door-horizontal' or 'assets/images/props/door-vertical'
  local sizeX, sizeY = isHorizontal and 56 or 10, isHorizontal and 10 or 56
  local rectX, rectY, rectW, rectH = isHorizontal and 12 or 4, isHorizontal and 4 or 12, 24, 18
  
  Door.super.init(self, asset, true)
  self:setSize(sizeX, sizeY)
  self:setCollideRect(rectX, rectY, rectW, rectH)
  
  local animationStates = {
    {name = 'normalClosed', startFrame = 18, endFrame = 18},
    {name = 'reverseClosed', startFrame = 9, endFrame = 9},
    {name = 'normalOpen', startFrame = 10, endFrame = 10},
    {name = 'reverseOpen', startFrame = 1, endFrame = 1}
  }
  
  for _, state in ipairs(animationStates) do
    self.animation:addState(state.name, state.startFrame, state.endFrame)
    self.animation[state.name].frameDuration = 12
  end
  
  local isNormal = direction == 'top' or direction == 'right'
  local statePrefix = isNormal and 'normal' or 'reverse'
  self.animation:setState(statePrefix .. (status == 'closed' and 'Closed' or 'Open'))
  
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x, y)
end
