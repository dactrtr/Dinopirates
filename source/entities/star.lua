class('Star').extends(Graphics.sprite)

local Shiny = Graphics.sprite.new()
Shiny.imagetable = Graphics.imagetable.new('assets/images/space/star')

function Star:init(x, y, speed)
  
  Shiny.animation = Graphics.animation.loop.new(speed, Shiny.imagetable, true)
  
  self:setImage(Shiny.animation:image())
  self:moveTo(x,y)
  self:setGroups(1)
  self:setZIndex(1)
  self:add()
end

function Star:update()
  self:setImage(Shiny.animation:image())
  -- input handler
  local movementX = 0
  local movementY = 0
  -- button press
  self:moveTo(movementX, movementY)
end



