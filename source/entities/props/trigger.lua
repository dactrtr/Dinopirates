Trigger = {}
class('Trigger').extends(Graphics.sprite)

function Trigger:init(x, y, width, height, script, position, room)
  self.script = script
  self.position = position
  self.room = room
  self:setCollideRect(0, 0, width,height)
  self:setZIndex(3)
  self:moveTo(x, y)
  self:setGroups(3)
  self:add(x,y)
end

function Trigger:returnScript()
    self:clearCollideRect()
    levels[self.room].floor.triggers[self.position].usedTrigger = true
    return self.script
end
