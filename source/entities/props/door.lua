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

local function setRectValues(direction)
  local rectValues = {
    down = {8, -4, 36, 12},
    top = {4, 8, 36, 12},
    left = {6, 8, 12, 36},
    right = {-8, 8, 12, 36}
  }
  return table.unpack(rectValues[direction])
end

function Door:init(direction, status, nextRoom, zIndex)
  self.nextRoom = nextRoom
  self.direction = direction
  local isHorizontal = direction == 'top' or direction == 'down'
  local asset = isHorizontal and 'assets/images/props/door-horizontal' or 'assets/images/props/door-vertical'
  local sizeX, sizeY = isHorizontal and 56 or 10, isHorizontal and 10 or 56
  local rectX, rectY, rectW, rectH = setRectValues(direction)

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
  Noble.transition(self.nextRoom)
end
function Door:prevRoom(direction)
    PlayerData.lastRoom = direction
    local spawnCoordinates = {
        top = {x = 200, y = 180},
        down = {x = 200, y = 32},
        right = {x = 40, y = 116},
        left = {x = 350, y = 120}
    }
    PlayerData.playerSpawn.x = spawnCoordinates[direction].x
    PlayerData.playerSpawn.y = spawnCoordinates[direction].y
end