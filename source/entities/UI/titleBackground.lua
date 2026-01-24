
TitleBackground = {}
class('TitleBackground').extends(NobleSprite)

function TitleBackground:init(x, y, zIndex)
  TitleBackground.super.init(self,'assets/images/screens/title-background', true)
  
  -- Set size BEFORE animation states (required by NobleEngine)
  self:setSize(400, 240)
  
  -- Set image draw mode for the sprite
  self:setImageDrawMode(Graphics.kDrawModeCopy)
  
  --- animation states - one for each menu option
  local frameDefault = 4
  self.animation:addState('continue', 1, 1)
  self.animation.continue.frameDuration = frameDefault
  self.animation:addState('deleteGame', 3, 3)
  self.animation.deleteGame.frameDuration = frameDefault
  self.animation:addState('newGame', 6, 6)
  self.animation.newGame.frameDuration = frameDefault
  self.animation:addState('achievements', 8, 8)
  self.animation.achievements.frameDuration = frameDefault
  -- Default to first frame
  self.animation:setState('continue')
  
  -- position and z-index
  self:setZIndex(zIndex)
  self:setCenter(0.5, 0.5)
  self:add(x, y)
end

function TitleBackground:changeState(state)
  if self.animation then
    self.animation:setState(state)
  end
end
