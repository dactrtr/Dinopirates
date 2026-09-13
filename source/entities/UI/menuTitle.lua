
MenuTitle = {}
class('MenuTitle').extends(NobleSprite)

function MenuTitle:init(x, y, type, zIndex)
  MenuTitle.super.init(self,'assets/images/screens/menuTitle', true)

  -- Set size BEFORE animation states (required by NobleEngine)
  self:setSize(180, 56)

  -- Set image draw mode for the sprite (not global)
  self:setImageDrawMode(Graphics.kDrawModeCopy)

  --- animation states
  self.animation:addState('defContinue', 1, 1)
  self.animation:addState('selContinue', 2, 2)
  self.animation:addState('defNewGame', 3, 3)
  self.animation:addState('selNewGame', 4, 4)
  self.animation:addState('defDeleteGame', 5, 5)
  self.animation:addState('selDeleteGame', 6, 6)
  self.animation:addState('defAchievements', 7, 7)
  self.animation:addState('selAchievements', 8, 8)
  self.animation:addState('defCredits', 9, 9)
  self.animation:addState('selCredits', 10, 10)
  self.animation:addState('defPlayground', 11, 11)
  self.animation:addState('selPlayground', 12, 12)
  self.animation:setState(type)

  -- Glitch effect state (see setSelected/update/draw below).
  self.isSelected = false
  self.isGlitchBursting = false
  self.glitchImage = nil
  self.glitchFramesUntilBurst = 0
  self.glitchBurstFrameCount = 0

  -- position and z-index
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x,y)
end

--- Marks this menu item as selected or not, switching its visual state and
--- enabling/disabling the periodic VCR-glitch flicker (selected items only).
-- @string defaultState Animation state name to use when not selected.
-- @string selectedState Animation state name to use when selected.
-- @bool selected Whether this item is currently the selected menu item.
function MenuTitle:setSelected(defaultState, selectedState, selected)
  self.animation:setState(selected and selectedState or defaultState)

  if selected and not self.isSelected then
    -- Newly selected: roll an initial random wait so the glitch doesn't
    -- fire in lockstep with the selection change.
    local glitchConfig = Config.UI.titleGlitch
    self.glitchFramesUntilBurst = math.random(glitchConfig.burstIntervalMinFrames, glitchConfig.burstIntervalMaxFrames)
  elseif not selected then
    -- Deselected (including mid-burst): cancel any in-progress glitch immediately.
    self.isGlitchBursting = false
    self.glitchImage = nil
    self.glitchBurstFrameCount = 0
  end

  self.isSelected = selected
end

function MenuTitle:update()
  MenuTitle.super.update(self)

  if not self.isSelected then return end

  local glitchConfig = Config.UI.titleGlitch

  if self.isGlitchBursting then
    self.glitchBurstFrameCount += 1

    if self.glitchBurstFrameCount > glitchConfig.burstDurationFrames then
      -- Burst finished: go back to idle and roll the next wait.
      self.isGlitchBursting = false
      self.glitchImage = nil
      self.glitchBurstFrameCount = 0
      self.glitchFramesUntilBurst = math.random(glitchConfig.burstIntervalMinFrames, glitchConfig.burstIntervalMaxFrames)
    elseif ((self.glitchBurstFrameCount - 1) % glitchConfig.burstRegenIntervalFrames) == 0 then
      -- Regenerate the distorted image on this tick of the burst.
      local baseImage = self.animation.imageTable:getImage(self.animation.current.startFrame)
      self.glitchImage = baseImage:vcrPauseFilterImage()
    end

    self:markDirty()
  else
    self.glitchFramesUntilBurst -= 1
    if self.glitchFramesUntilBurst <= 0 then
      self.isGlitchBursting = true
      self.glitchBurstFrameCount = 1
      local baseImage = self.animation.imageTable:getImage(self.animation.current.startFrame)
      self.glitchImage = baseImage:vcrPauseFilterImage()
      self:markDirty()
    end
  end
end

function MenuTitle:draw()
  if self.isGlitchBursting and self.glitchImage ~= nil then
    self.glitchImage:draw(0, 0)
    self:markDirty()
  else
    MenuTitle.super.draw(self)
  end
end
