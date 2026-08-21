-- Player instability glitch: once PlayerData.sanityCounter crosses
-- Config.Sanity.dangerCounterThreshold, the player sprite periodically flickers with the
-- same VCR-pause distortion filter used on the title screen (see entities/UI/menuTitle.lua
-- and docs/superpowers/specs/2026-08-20-title-glitch-effect-design.md), but on a much
-- longer, rarer cadence (Config.Player.glitch).
--
-- Unlike MenuTitle (whose states are single fixed frames, safe to fully replace during a
-- burst), the player is constantly mid-animation. Player:draw() below always performs the
-- normal, untouched animated draw first (so gameplay's real animation state keeps
-- advancing/rendering exactly as it does without this feature), then — only while a burst
-- is active — draws a periodically-regenerated filtered snapshot on top, so the glitch
-- visibly tracks whatever pose the player is actually in.
--
-- The threshold check latches once true (self.isGlitchActive) since sanityCounter never
-- decreases — no need to ever re-check or deactivate it once crossed.

function Player:initGlitch()
	self.isGlitchActive = false
	self.isGlitchBursting = false
	self.glitchImage = nil
	self.glitchFramesUntilBurst = 0
	self.glitchBurstFrameCount = 0
end

function Player:updateGlitch()
	if not self.isGlitchActive then
		if PlayerData.sanityCounter <= Config.Sanity.dangerCounterThreshold then return end
		-- Just crossed the threshold: activate and roll the first wait.
		self.isGlitchActive = true
		local glitchConfig = Config.Player.glitch
		self.glitchFramesUntilBurst = math.random(glitchConfig.burstIntervalMinFrames, glitchConfig.burstIntervalMaxFrames)
	end

	local glitchConfig = Config.Player.glitch

	if self.isGlitchBursting then
		self.glitchBurstFrameCount += 1

		if self.glitchBurstFrameCount > glitchConfig.burstDurationFrames then
			-- Burst finished: go back to idle and roll the next wait.
			self.isGlitchBursting = false
			self.glitchImage = nil
			self.glitchBurstFrameCount = 0
			self.glitchFramesUntilBurst = math.random(glitchConfig.burstIntervalMinFrames, glitchConfig.burstIntervalMaxFrames)
		elseif ((self.glitchBurstFrameCount - 1) % glitchConfig.burstRegenIntervalFrames) == 0 then
			-- Regenerate the distorted image on this tick of the burst, tracking whatever
			-- frame the player is currently animating.
			local baseImage = self.animation.imageTable:getImage(self.animation.currentFrame)
			self.glitchImage = baseImage:vcrPauseFilterImage()
		end
	else
		self.glitchFramesUntilBurst -= 1
		if self.glitchFramesUntilBurst <= 0 then
			self.isGlitchBursting = true
			self.glitchBurstFrameCount = 1
			local baseImage = self.animation.imageTable:getImage(self.animation.currentFrame)
			self.glitchImage = baseImage:vcrPauseFilterImage()
		end
	end
end

function Player:draw()
	Player.super.draw(self)

	if self.isGlitchBursting and self.glitchImage ~= nil then
		self.glitchImage:draw(0, 0)
	end

	self:markDirty()
end
