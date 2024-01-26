Door = {}
class('Door').extends(NobleSprite)

local animationStates = {
  normalClosed = 18,
  reverseClosed = 9,
  normalOpen = 10,
  reverseOpen = 1
}

local positions = {
  right = {x = 397, y = 130},
  left = {x = 3, y = 130},
  down = {x = 205, y = 232},
  top = {x = 205, y = 10}
}

function Door:init(direction, status, zIndex)
  local isHorizontal = direction == 'top' or direction == 'down'
  local asset = isHorizontal and 'assets/images/props/door-horizontal' or 'assets/images/props/door-vertical'
  local sizeX, sizeY = isHorizontal and 56 or 10, isHorizontal and 10 or 56
  local rectX, rectY, rectW, rectH = isHorizontal and 12 or 4, isHorizontal and 4 or 12, 24, 18
  
  Door.super.init(self, asset, true)
  self:setSize(sizeX, sizeY)
  self:setCollideRect(rectX, rectY, rectW, rectH)
  
  for state, frame in pairs(animationStates) do
    self.animation:addState(state, frame, frame)
    self.animation[state].frameDuration = 12
  end
  
  local isNormal = direction == 'top' or direction == 'right'
  local statePrefix = isNormal and 'normal' or 'reverse'
  self.animation:setState(statePrefix .. (status == 'closed' and 'Closed' or 'Open'))
  
  local position = positions[direction]
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(position.x, position.y)
end

function Door:goTo()
  print('be my guest')
  Noble.transition(MazeScene01)
end
