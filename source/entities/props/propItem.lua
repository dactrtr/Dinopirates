-- PropCollider removed, integrated into PropItem for performance
PropItem = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, type, zIndex, nocollide, isDestroyed, id)
  PropItem.super.init(self,'assets/images/props/props', true)
  self.type = type
  self.id = id
  
  --- animation states
  self.animation:addState('chair', 1, 1)
  self.animation:addState('fellchair', 2, 2)
  self.animation:addState('box', 3, 3)
  self.animation:addState('trash', 4, 4)
  self.animation:addState('toxic', 5, 5)
  self.animation:addState('table', 6, 6)
  self.animation:addState('fellTable', 7, 7)
  self.animation:addState('blood', 8, 8)
  self.animation:addState('blood2', 9, 9)
  self.animation:addState('deadrat', 10, 10)
  self.animation:addState('xtree-1', 11, 11)
  self.animation:addState('xtree-2', 12, 12)
  self.animation:addState('xtree-3', 13, 13)
  self.animation:addState('xtree-4', 14, 14)
  self.animation:addState('microwave', 15, 15)
  self.animation:addState('gifts', 16, 16)
  self.animation:addState('gift', 17, 17)
  self.animation:addState('smallTable', 18, 18)
  self.animation:addState('fridge1', 19, 19)
  self.animation:addState('fridge2', 20, 20)
  self.animation:addState('kitchenStorage', 21, 21)
  self.animation:addState('pot', 22, 22)
  self.animation:addState('knifeKettle', 23, 23)
  self.animation:addState('holeTopLeft', 24, 24)
  self.animation:addState('holeLeft', 25, 25)
  self.animation:addState('holeBottomLeft', 26, 26)
  self.animation:addState('holeTop', 27, 27)
  self.animation:addState('holeCenter', 28, 28)
  self.animation:addState('holeBottom', 29, 29)
  self.animation:addState('holeTopRight', 30, 30)
  self.animation:addState('holeRight', 31, 31)
  self.animation:addState('holeBottomRight', 32, 32)
  self.animation:addState('debris', 33, 33)
  self.animation:addState('minifier', 45, 45)
  self.animation:addState('slime', 46, 46)
  self.animation:setState(type)
  
  -- Default properties
  self.isEdible = true
  self.isHole = false
  self:setSize(32, 32)
  self.nocollide = nocollide
  self.isDestroyed = isDestroyed
  
  -- HOLE TYPES CONFIGURATION
  local holeTypes = {
    holeLeft = { isHole = true, collideRect = {10, 0, 22, 32} },
    holeRight = { isHole = true, collideRect = {0, 0, 22, 32} },
    holeCenter = { isHole = true, collideRect = {0, 0, 32, 32} },
    holeTopLeft = { isHole = true, collideRect = {10, 10, 22, 22} },
    holeTop = { isHole = true, collideRect = {0, 10, 32, 22} },
    holeTopRight = { isHole = true, collideRect = {0, 10, 22, 22} },
    holeBottomRight = { isHole = true, collideRect = {0, 0, 22, 22} },
    holeBottom = { isHole = true, collideRect = {0, 0, 32, 22} },
    holeBottomLeft = { isHole = true, collideRect = {10, 0, 22, 22} },
    slime = { isSlime = true, collideRect = {0, 0, 32, 32} },
  }

  -- Check if this is a hole early
  if holeTypes[type] then
    self.isHole = holeTypes[type].isHole
    self.isSlime = holeTypes[type].isSlime
    self.isEdible = false
  end

  -- Default collider setup (only if not a hole, not slime and nocollide is false)
  if self.nocollide == false and not self.isHole and not self.isSlime then
    if type == "xtree-1" or type == "xtree-2" then
      self:setCollideRect(2, 26, 28, 4) 
    else
      self:setCollideRect(2, 10, 28, 18)
    end
  end
  
  -- Apply specific hole or slime configuration
  if self.isHole or self.isSlime then
    local config = holeTypes[type]
    if config.collideRect then
      self:setCollideRect(table.unpack(config.collideRect))
    else
      self:clearCollideRect()
    end
    if self.isHole then
      printDebug("🕳️  Hole created:", type, "at", x, y)
    else
      printDebug("💧 Slime created:", type, "at", x, y)
    end
  end

  if self.nocollide == true or self.isDestroyed == true or self.isHole == true or self.isSlime == true or self.type == 'minifier' then
    self:setZIndex(ZIndex.props)
  end

  if self.type == 'minifier' then
    self:setCollideRect(0, 12, 32, 18)
  end
  
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x, y)
end

function PropItem:update()
  if not (self.nocollide == true or self.isDestroyed == true or self.isHole == true or self.isSlime == true or self.type == 'minifier') then
    self:setZIndex(self.y)
  end
end

function PropItem:destroyProp(id)
  findAndDestroyPropById(id) 
  self:clearCollideRect()
  self.animation:setState('debris')
end