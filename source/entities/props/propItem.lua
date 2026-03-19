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
  self.animation:addState('pcBase', 34, 34)
  self.animation:addState('pcBase2', 36, 36)
  self.animation:addState('pcScreen', 35, 35)
  self.animation:addState('pcScreen2', 41, 41)
  self.animation:addState('pcScreen3', 42, 42)
  self.animation:addState('pcBase3', 40, 40)
  self.animation:addState('pcSiriHappy', 44, 44)
  self.animation:addState('pcSiriSad', 43, 43)
  self.animation:addState('pcLoad', 37, 39)
  self.animation.pcLoad.frameDuration = 12
  self.animation:addState('minifier', 45, 45)
  self.animation:addState('pneumaticTube', 47, 47)
  self.animation:addState('Tube', 48, 48)
  self.animation:addState('TubeExit', 49, 49)
  self.animation:setState(type)
  
  -- Default properties
  self.isEdible = true
  self.isHole = false
  self:setSize(32, 32)
  self.nocollide = nocollide
  self.isDestroyed = isDestroyed
  
  -- PROP CONFIGURATIONS
  local propConfigs = {
    -- Holes (non-edible, specific colliders)
    holeLeft        = { isHole = true,  isEdible = false, collideRect = {10, 0, 22, 32} },
    holeRight       = { isHole = true,  isEdible = false, collideRect = {0, 0, 22, 32} },
    holeCenter      = { isHole = true,  isEdible = false, collideRect = {0, 0, 32, 32} },
    holeTopLeft     = { isHole = true,  isEdible = false, collideRect = {10, 10, 22, 22} },
    holeTop         = { isHole = true,  isEdible = false, collideRect = {0, 10, 32, 22} },
    holeTopRight    = { isHole = true,  isEdible = false, collideRect = {0, 10, 22, 22} },
    holeBottomRight = { isHole = true,  isEdible = false, collideRect = {0, 0, 22, 22} },
    holeBottom      = { isHole = true,  isEdible = false, collideRect = {0, 0, 32, 22} },
    holeBottomLeft  = { isHole = true,  isEdible = false, collideRect = {10, 0, 22, 22} },
    
    -- Special props
    minifier        = { collideRect = {0, 12, 32, 18} },
    pneumaticTube   = { isTube = true, isEdible = false, collideRect = {4, 10, 24, 22} },
    
    -- Props with lower colliders (Trees and PC Screens)
    ["xtree-1"]     = { collideRect = {2, 30, 28, 12} },
    ["xtree-2"]     = { collideRect = {2, 30, 28, 12} },
    pcScreen        = { collideRect = {2, 30, 28, 12} },
    pcScreen2       = { collideRect = {2, 30, 28, 12} },
    pcScreen3       = { collideRect = {2, 30, 28, 12} },
    pcLoad          = { collideRect = {2, 30, 28, 12} },
    pcSiriHappy     = { collideRect = {2, 30, 28, 12} },
    pcSiriSad       = { collideRect = {2, 30, 28, 12} },
  }

  local config = propConfigs[type] or {}
  self.isHole = config.isHole or false
  self.isTube = config.isTube or false
  self.isEdible = config.isEdible ~= false -- defaults to true

  -- Collider setup
  if self.nocollide == false then
    if config.collideRect then
      self:setCollideRect(table.unpack(config.collideRect))
    elseif not self.isHole and not self.isTube then
      -- Default prop collider
      self:setCollideRect(2, 10, 28, 18)
    end
  end

  -- Debug output for holes and tubes
  if self.isHole then
    printDebug("🕳️  Hole created:", type, "at", x, y)
  elseif self.isTube then
    printDebug("🧪 Pneumatic Tube created:", type, "at", x, y)
  end

  -- Set static Z-index for certain types
  self.isStaticZIndex = false

  if self.nocollide or self.isDestroyed or self.isHole or self.type == 'minifier' then
    self.isStaticZIndex = true
    self:setZIndex(ZIndex.props)
  end
  
  if self.type == "Tube" then
    self:clearCollideRect()
    self:setZIndex(700)
    self.isStaticZIndex = true
  end
  
  if not self.isStaticZIndex then
      self:setZIndex(zIndex)
  end

  self:setGroups(3)
  self:add(x, y)
end

function PropItem:update()
  if not self.isStaticZIndex then
    self:setZIndex(self.y)
  end
end

function PropItem:destroyProp(id)
  findAndDestroyPropById(id) 
  self:clearCollideRect()
  self:setZIndex(ZIndex.props)
  self.animation:setState('debris') -- add a new animation for debris
end

function PropItem:hitBoxDash()
  if self.type == "box" and not self.isDestroyed then
    -- Apply optional screen shake/sound here
    playdate.display.setRefreshRate(30) -- small stutter effect
    playdate.timer.performAfterDelay(100, function() playdate.display.setRefreshRate(0) end)
    
    self:destroyProp(self.id)
    self.isDestroyed = true
  end
end