
Enemy = {}
class('Enemy').extends(Graphics.sprite)

function Enemy:init(x, y, moveSpeed)
  local enemyImage = Graphics.image.new("assets/images/Untitled.png")
  self:setImage(enemyImage)
  self:moveTo(x,y)
  self:setCollideRect(0,0, self:getSize())
  self.moveSpeed = moveSpeed
  self:setGroups(1)
  self:setZIndex(2)
  
  self:add()
end

function Enemy:update()
  -- self:moveBy(-self.moveSpeed, 0)
  -- print("enemy")
  self:moveWithCollisions(self.x - self.moveSpeed, self.y)
  -- if collisions['other']:isa(Player) then
    -- print(self.x, collisions.type)
  -- end
  if self.x<128 then
    self:moveTo(400, self.y)
  end
end

function Enemy:collisionResponse()
  return "freeze"
end