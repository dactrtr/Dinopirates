

Trigger = {}
class('Trigger').extends(Graphics.sprite)

function Trigger:init(x, y, width, height, script)
  self.script = script
  self:setCollideRect(0, 0, width,height)
  self:setZIndex(3)
  self:moveTo(x, y)
  self:setGroups(3)
  self:add(x,y)
end

function Trigger:returnScript()
    self:remove()
    return self.script
end
