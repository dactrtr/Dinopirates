-- Player hole and tiny-hole tile handling.
-- Mirrors the old PropItem isHole collision logic but driven by tile detection.

-- Per-frame bookkeeping for the "balancing" grace mechanic. Computes how far the player moved
-- since the last frame (self._graceMove, framerate-independent) and clears each hazard's grace
-- counter once the feet leave that hazard's tile. Runs once per frame from Player:update,
-- BEFORE checkSlimeTile/checkHoleTile accumulate into the counters.
function Player:updateGraceMove()
    local px = self._prevGraceX or self.x
    local py = self._prevGraceY or self.y
    local dx, dy = self.x - px, self.y - py
    self._graceMove = math.sqrt(dx * dx + dy * dy)
    self._prevGraceX, self._prevGraceY = self.x, self.y

    local onHole = IsPlayerOnHole(self.x, self.y)
        or (PlayerData.isTiny and IsPlayerOnTinyHole(self.x, self.y))
    if not onHole then self.holeGracePixels = 0 end
    if not IsPlayerOnSlime(self.x, self.y) then self.slideGracePixels = 0 end
end

-- True once the player has crossed a hazard's WARNING threshold (drives the HUD warning +
-- balancing sprite). Counters are only > 0 while the feet are over the hazard (reset on
-- step-off in updateGraceMove), so `> 0 and >= warningPixels` means "on the hazard and past
-- its warning threshold". With warningPixels = 0 the warning shows the moment the player
-- steps on. The separate fall/slide (activation) thresholds live in checkHoleTile/checkSlimeTile.
function Player:hasBalanceGrace()
    return (self.holeGracePixels > 0 and self.holeGracePixels >= Config.Hole.warningPixels)
        or (self.slideGracePixels > 0 and self.slideGracePixels >= Config.Slide.warningPixels)
end

-- True when the balancing sprite should be shown (grace active AND the config toggle is on).
function Player:isBalancing()
    return Config.Player.balancingSprite == true and self:hasBalanceGrace()
end

-- True while the player is standing on a hole tile. While on a hole the player may only walk:
-- no skill activation and no battery recharge (see abilities/grapple/sanity guards).
function Player:isOnHole()
    if IsPlayerOnHole(self.x, self.y) then return true end
    if PlayerData.isTiny and IsPlayerOnTinyHole(self.x, self.y) then return true end
    return false
end

function Player:checkHoleTile()
    -- Guard: skip if already transitioning or in a special movement state
    -- (grapple pull flies the player over holes instead of falling in)
    if self.isDashing or self.isSliding or self.isPlunging or self.isFalling or self.isGrapplePulling then
        return
    end

    if not IsPlayerOnHole(self.x, self.y) then
        return
    end

    -- Accumulate grace; only fall once the player has moved fallPixels over the hole.
    self.holeGracePixels = self.holeGracePixels + self._graceMove
    if self.holeGracePixels >= Config.Hole.fallPixels then
        -- Set flag BEFORE fallBelow() to block re-entry on subsequent frames
        -- while the Noble.transition() is still in progress. Reset the counter for
        -- symmetry with the slide path (harmless: a fall starts a new run).
        self.holeGracePixels = 0
        self.isFalling = true
        self:fallBelow()
    end
end

-- Same logic as checkHoleTile but for tiny-only holes (IntGrid 32).
-- Normal-size players walk over tiny holes as if they were floor.
function Player:checkTinyHoleTile()
    if not PlayerData.isTiny then return end
    if self.isDashing or self.isSliding or self.isPlunging or self.isFalling or self.isGrapplePulling then
        return
    end

    if not IsPlayerOnTinyHole(self.x, self.y) then
        return
    end

    self.holeGracePixels = self.holeGracePixels + self._graceMove
    if self.holeGracePixels >= Config.Hole.fallPixelsTiny then
        self.holeGracePixels = 0
        self.isFalling = true
        self:fallBelow()
    end
end
