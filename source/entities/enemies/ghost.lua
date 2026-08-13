-- Ghost: a CrewMember subclass that only manifests when the player's sanity is low.
-- It flees like a crew member (reusing the inherited search -> escape flee AI and the
-- shared movement-token system) but has its own spritesheet, no hat, and is banished
-- (removed + counted) when the player touches it while it is revealed.
--
-- Visibility/collision are gated on PlayerData.sanity < Config.Ghost.revealThreshold:
-- above the threshold the ghost is invisible and intangible; below it, it appears and
-- runs the full inherited crew update. Ghosts are authored per-room in LDtk and respawn
-- on re-entry (no persistence).

Ghost = {}
class('Ghost').extends(CrewMember)

function Ghost:init(x, y, moveSpeed, Zindex, player, iid, room)
	-- Reach the grandparent (NobleSprite) so we load our OWN spritesheet and skip
	-- CrewMember:init (which would create a hat and hiding config). self.hat stays nil.
	CrewMember.super.init(self, 'assets/images/enemies/ghost', true)

	-- Error handling: fall back to the configured default flee speed.
	if moveSpeed == nil then
		moveSpeed = Config.Ghost.defaultSpeed
	end

	-- MARK: Animation states (same state names the inherited escape/search use).
	-- Frame ranges mirror CrewMember's as placeholders until the ghost sheet exists.
	-- No 'hide' state: ghosts never hide (see Ghost:enterHiding override below).
	self.animation:addState('walk', 1, 4)
	self.animation.walk.frameDuration = 8
	self.animation:addState('idle', 5, 8)
	self.animation.idle.frameDuration = 6
	-- 'vanish' plays once when the ghost is banished (same frames as CrewMember's 'stunned'),
	-- then removes the ghost via onComplete. loop=false freezes on the last frame; the guard
	-- ensures remove() runs exactly once (onComplete re-fires every frame at the end otherwise).
	self.animation:addState('vanish', 15, 18, nil, false, function()
		if self.isRemoved then return end
		self.isRemoved = true
		self:remove()
	end)
	self.animation.vanish.frameDuration = 6

	self:setSize(48, 48)
	self:moveTo(x, y)
	local gcr = Config.Ghost.collideRect
	self:setCollideRect(gcr.x, gcr.y, gcr.w, gcr.h)

	self.room = room
	self.moveSpeed = moveSpeed
	self.initialSpeed = moveSpeed
	self.damage = 0
	self.player = player
	self.Zindex = Zindex
	self.iid = iid

	-- Performance: staggered per-ghost update offset (mirrors CrewMember).
	self.updateFrameCounter = math.random(0, 2)

	-- Collision groups: same as crew so player contact is detectable.
	self:setGroups(CollideGroups.crewMember)
	self:setCollidesWithGroups({
		CollideGroups.props,
		CollideGroups.wall,
		CollideGroups.enemy,
		CollideGroups.crewMember,
		CollideGroups.player
	})

	self:setZIndex(self.Zindex)
	self:add(x, y)

	-- Movement-token banking (fed by Player:distributeMovement* because Ghost isa CrewMember).
	self.movementFrames = 0

	-- Bounce/redirect fields the inherited moveCollision reads. Reuse Config.CrewMember.*
	-- so the bounce math matches real crew.
	self.bounceDirection = nil
	self.bounceFrames = 0
	self.lastCollisionAxis = nil
	self.cornerDetectionThreshold = Config.CrewMember.cornerDetectionThreshold
	self.recentBounceCount = 0
	self.bounceCountDecayFrames = 0
	self.bounceCountDecayRate = Config.CrewMember.bounceCountDecayRate
	-- Ghosts never hide: keep the wall-bounce redirect but make the hide threshold unreachable,
	-- so the inherited moveCollision never takes its enterHiding branch. (enterHiding is also
	-- overridden to a no-op below as a defensive guard.)
	self.bouncesRequiredToHide = math.huge

	-- Vision radius the inherited flee decision (search -> isPlayerOutOfVision) reads. Despite the
	-- name it is NOT about hiding; it MUST be set or the ghost crashes on its first AI tick.
	self.hidingVisionRange = Config.CrewMember.hidingVisionRange
	self.isHiding = false  -- always false for ghosts; kept so inherited update() guards read a bool

	-- Blind/stun fields the inherited update reads.
	self.isBlinded = false
	self.blindFrames = 0
	self.blindDuration = Config.CrewMember.blindDuration

	-- Store original collide rect for restoration after the sanity gate zeroes it.
	self.originalCollideRect = Config.Ghost.collideRect

	-- Banish/vanish state: while vanishing the ghost plays its 'vanish' animation and is
	-- removed on completion. isRemoved guards the one-shot removal.
	self.isVanishing = false
	self.isRemoved = false

	-- Start hidden: revealed only once update() re-evaluates the sanity gate.
	self:setVisible(false)
	self:setCollideRect(0, 0, 0, 0)

	printDebug("👻 Ghost spawned with IID:", self.iid)
end

-- Overrides CrewMember:update to add the sanity gate.
function Ghost:update()
	-- Mid-vanish: stay visible and let the 'vanish' animation play to completion (its
	-- onComplete removes the ghost). Skip the sanity gate and the flee AI entirely.
	if self.isVanishing then return end

	local revealed = PlayerData.sanity < Config.Ghost.revealThreshold

	if revealed then
		-- Manifest: show + make touchable on the transition, then run the inherited crew AI.
		if not self:isVisible() then
			self:setVisible(true)
			local gcr = Config.Ghost.collideRect
			self:setCollideRect(gcr.x, gcr.y, gcr.w, gcr.h)
		end
		CrewMember.update(self)
	else
		-- Sanity recovered above the threshold. isVisible() means the ghost had manifested
		-- this cycle, so it fades out with the vanish animation (same as a touch banish, but
		-- it is NOT counted). If it never manifested (still hidden since spawn), it just stays
		-- dormant — invisible and intangible — until sanity drops again.
		if self:isVisible() then
			self:beginVanish()
		else
			self:setCollideRect(0, 0, 0, 0)
			self.movementFrames = 0
		end
	end
end

-- Ghosts never hide. The inherited moveCollision would call enterHiding after repeated corner
-- bounces; bouncesRequiredToHide is set to math.huge so that never happens, and this no-op is a
-- defensive guard in case any other inherited path invokes it (there is no 'hide' animation state).
function Ghost:enterHiding()
	-- intentionally does nothing
end

-- Shared vanish routine: become untouchable, stop fleeing, and play the 'vanish' animation
-- to completion (its onComplete removes the ghost). Kept visible so the animation is seen.
-- Guarded so it only starts once.
function Ghost:beginVanish()
	if self.isVanishing then return end
	self.isVanishing = true

	self:setVisible(true)
	self:setCollideRect(0, 0, 0, 0)
	self.movementFrames = 0
	self.animation:setState('vanish')
end

-- Touch handler: count the banish (and grant the achievement at the cap), then start the
-- shared vanish sequence. Guard against re-triggering while already vanishing.
function Ghost:banish()
	if self.isVanishing then return end

	PlayerData.GhostData.banished += 1
	if PlayerData.GhostData.banished >= Config.Ghost.achievementCount then
		-- Safe no-op until the achievement id is registered in achievementData.
		Utilities.grantAchievementIfNeeded(Config.Ghost.achievementId)
	end

	printDebug("👻 Ghost banished! Total:", PlayerData.GhostData.banished)
	self:beginVanish()
end

-- Overrides CrewMember:collisionResponse. A ghost is incorporeal: it phases through props,
-- items, enemies, and other crew, and passes over holes (hole tiles are walkable, so they
-- never get a wall collider). Only walls (Box) stop it — 'slide' so it still moves along a
-- wall while fleeing. Holes need no special case here: with no collider on hole tiles, the
-- ghost drifts over them freely. Player contact still banishes via the player's own
-- collisionResponse (invoked from the inherited moveCollision), unaffected by 'overlap'.
function Ghost:collisionResponse(other)
	if other:isa(Box) then
		return 'slide'
	end
	return 'overlap'
end
