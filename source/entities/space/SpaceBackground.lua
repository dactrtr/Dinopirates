SpaceBackground = {}
class('SpaceBackground').extends(NobleSprite)

-- Animated backdrop for SpaceScene. The imagetable base path resolves the
-- `-table-W-H` suffix automatically; the frame count is read from the loaded
-- imagetable so any sheet the artist drops in works without code changes.
--
-- The caller (SpaceScene) probes Graphics.imagetable.new(basePath) first and only
-- constructs this when the asset exists, so missing art falls back to the scene's
-- black background instead of crashing.
function SpaceBackground:init(basePath, frameDuration)
	SpaceBackground.super.init(self, basePath, true)

	local dur = frameDuration or 6
	local frames = (self.animation.imageTable and #self.animation.imageTable) or 1

	self.animation:addState('idle', 1, frames)
	self.animation.idle.frameDuration = dur

	self.animation:setState('idle')
	self:setZIndex(ZIndex.background or 0)
	self:setSize(400, 240)
	self:setCenter(0, 0)
	self:add(0, 0)
end

function SpaceBackground:update()

end
