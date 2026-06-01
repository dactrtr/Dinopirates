-- PropCollider removed, integrated into PropItem for performance
PropItem = {}
class('PropItem').extends(NobleSprite)

function PropItem:init(x, y, type, zIndex, nocollide, isDestroyed, id)
  PropItem.super.init(self,'assets/images/props/props', true)
  self.type = type
  self.id = id
  
  --- animation states
  self.animation:addState('box', 1, 1)
  self.animation:addState('minifier', 5, 6)
  self.animation.minifier.frameDuration = 12
  self.animation:addState('pneumaticTube', 2, 2)
  self.animation:addState('Tube', 3, 3)
  self.animation:addState('TubeExit', 4, 4)
  self.animation:addState('microwave', 7, 7)
  self.animation.microwave.frameDuration = 12
  self.animation:setState(type)
  
  -- Default properties
  self.isEdible = true
  self:setSize(32, 32)
  self.nocollide = nocollide
  self.isDestroyed = isDestroyed
  
  -- PROP CONFIGURATIONS
  local propConfigs = {
    -- Special props
    minifier        = { collideRect = {0, 12, 32, 18} },
    microwave       = { collideRect = {0, 12, 32, 18} }, -- TODO art: dedicated frame (reuses existing 'microwave' frame 15)
    pneumaticTube   = { isTube = true, isEdible = false, collideRect = {4, 10, 24, 22} },
  }

  local config = propConfigs[type] or {}
  self.isTube = config.isTube or false
  self.isEdible = config.isEdible ~= false -- defaults to true

  -- Collider setup
  if self.nocollide == false then
    if config.collideRect then
      self:setCollideRect(table.unpack(config.collideRect))
    elseif not self.isTube then
      -- Default prop collider
      self:setCollideRect(2, 10, 28, 18)
    end
  end

  -- Debug output for tubes
  if self.isTube then
    printDebug("🧪 Pneumatic Tube created:", type, "at", x, y)
  end

  -- Set static Z-index for certain types
  self.isStaticZIndex = false

  if self.nocollide or self.isDestroyed or self.type == 'minifier' or self.type == 'microwave' then
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

function PropItem:smash()
  if self.type == "box" and not self.isDestroyed then
    -- Apply optional screen shake/sound here
    playdate.display.setRefreshRate(30) -- small stutter effect
    playdate.timer.performAfterDelay(100, function() playdate.display.setRefreshRate(0) end)

    self:destroyProp(self.id)
    self.isDestroyed = true
  end
end