import 'entities/props/hats'

CrewMember = {}
class('CrewMember').extends('NobleSprite')
-- TODO check animation
function CrewMember:init(x, y, moveSpeed, Zindex, player, iid, room, crewId)
	CrewMember.super.init(self, 'assets/images/enemies/crewmember', true)
	
	-- error handling
	if moveSpeed == nil then
		moveSpeed = 1.5
	end
	-- MARK: Animation states
	self.animation:addState('walk', 1, 4)
	self.animation.walk.frameDuration = 8
	self.animation:addState('idle', 5, 8)
	self.animation.idle.frameDuration = 6
	-- self.animation:addState('hide', 9, 11, 'hole')
	self.animation:addState('hide', 12, 13)
	self.animation.hide.frameDuration = 6
	self.animation:addState('stunned', 15, 18)
	self.animation.stunned.frameDuration = 6
	-- self.animation.hole.frameDuration = 4
		
	self:setSize(48, 48)
	self:moveTo(x, y)
	self:setCollideRect(12, 24, 24, 24)
	self.hatDelta = 15
	self.room = room
	self.position = position
	self.moveSpeed = moveSpeed
	self.initialSpeed = moveSpeed
	self.damage = 0
	self.player = player
	self.Zindex = Zindex
	self.crewId = crewId  -- Store the crew member ID
	
	-- Performance: Frame counter for throttling updates
	self.updateFrameCounter = math.random(0, 2) -- Random offset to stagger enemy updates
	
	self:setGroups(CollideGroups.crewMember)
	self:setCollidesWithGroups({
		CollideGroups.props,
		CollideGroups.wall,
		CollideGroups.enemy,
		CollideGroups.crewMember,
		CollideGroups.player
	})
	self.iid = iid
	self:setZIndex(self.Zindex)
	self:add(x, y)
	self.hat = Hats(x,y - self.hatDelta, crewId, 2)
	self.movementFrames = 0 -- Initialize movement frames
	
	-- Bounce/redirect properties
	self.bounceDirection = nil -- Current bounce direction: 'left', 'right', 'up', 'down'
	self.bounceFrames = 0 -- How many frames to maintain bounce direction
	self.lastCollisionAxis = nil -- Track which axis had collision: 'x', 'y', or 'both'
	
	-- ============================================
	-- HIDING STATE CONFIGURATION (Fine-tuning variables)
	-- ============================================
	self.isHiding = false -- Whether the CrewMember is currently hiding
	self.hidingMovementTokensRequired = 3 -- Movement tokens needed to exit hiding (adjust for timing)
	self.hidingMovementTokensAccumulated = 0 -- Accumulated movement tokens while hiding
	self.hidingVisionRange = 80 -- Distance player must be to be considered "out of vision" (pixels)
	self.cornerDetectionThreshold = 0.5 -- Threshold for detecting blocked movement (pixels)
	
	-- Corner/Trapped detection: count bounces to detect being stuck
	self.recentBounceCount = 0 -- How many bounces happened recently  
	self.bounceCountDecayFrames = 0 -- Frames until bounce count decays
	self.bounceCountDecayRate = 30 -- Frames before bounce count resets (if no new bounces)
	self.bouncesRequiredToHide = 2 -- Number of bounces in quick succession to trigger hiding
	-- ============================================
	
	-- Store original collide rect for restoration
	self.originalCollideRect = {x = 12, y = 24, w = 24, h = 24}
	
	-- Blinded state
	self.isBlinded = false
	self.blindFrames = 0
	self.blindDuration = 60 -- Default blind duration in frames (approx 2 seconds)
	
	printDebug("🧩 CrewMember spawned with IID:", self.iid, "CrewID:", crewId)
end

function CrewMember:addMovementTokens(amount)
	local FRAMES_PER_TOKEN = 30
	
	-- If hiding, accumulate tokens for exit check instead of normal movement
	if self.isHiding then
		self.hidingMovementTokensAccumulated = self.hidingMovementTokensAccumulated + amount
		self:checkExitHiding()
	else
		self.movementFrames = self.movementFrames + (amount * FRAMES_PER_TOKEN)
	end
end

-- Add raw frames directly (for player movement sync)
function CrewMember:addMovementFrames(frames)
	-- If hiding, convert frames to tokens and accumulate
	if self.isHiding then
		-- Convert frames to approximate tokens (30 frames = 1 token)
		local tokenEquivalent = frames / 30
		self.hidingMovementTokensAccumulated = self.hidingMovementTokensAccumulated + tokenEquivalent
		self:checkExitHiding()
	else
		-- Cap at reasonable max to prevent accumulation (3 seconds = 90 frames)
		self.movementFrames = math.min(self.movementFrames + frames, 90)
	end
end

function CrewMember:search(player)
	if not self:isPlayerOutOfVision() and not PlayerData.isTiny then
		self:escape(player)
	else
		-- Ensure idle animation if player is not in vision or is tiny
		if self.animation.currentState ~= 'idle' then
			self.animation:setState('idle')
		end
	end
end
function CrewMember:moveCollision(movementX, movementY, player) 
	if PlayerData.battery < 10 and PlayerData.isInDarkness == true then
		self.moveSpeed = 0
	elseif PlayerData.battery > 60 and PlayerData.isInDarkness == true then
		self.moveSpeed = self.initialSpeed
	end
	
	local actualX, actualY, collisions, length = self:moveWithCollisions(movementX, movementY)
	self.hat:moveTo(actualX, actualY - self.hatDelta)
	
	-- Detect if movement was blocked by comparing intended vs actual position
	local blockedX = math.abs(actualX - movementX) > self.cornerDetectionThreshold
	local blockedY = math.abs(actualY - movementY) > self.cornerDetectionThreshold
	
	-- Decay bounce count over time (if no bounces happen)
	if self.bounceCountDecayFrames > 0 then
		self.bounceCountDecayFrames = self.bounceCountDecayFrames - 1
	else
		-- Reset bounce count if enough time passed without bounces
		if self.recentBounceCount > 0 then
			self.recentBounceCount = 0
			-- printDebug("🔄 Bounce count reset") -- Debug
		end
	end
	
	-- Only trigger bounce if we hit something and aren't already bouncing
	if (blockedX or blockedY) and self.bounceFrames <= 0 then
		-- Increment bounce count and reset decay timer
		self.recentBounceCount = self.recentBounceCount + 1
		self.bounceCountDecayFrames = self.bounceCountDecayRate
		
		printDebug("💥 Bounce detected! Count:", self.recentBounceCount, "/ Required:", self.bouncesRequiredToHide) -- Debug
		
		-- Check if enough bounces to trigger hiding (trapped in corner)
		if self.recentBounceCount >= self.bouncesRequiredToHide then
			printDebug("🙈 Too many bounces - entering hiding!") -- Debug
			self:enterHiding()
			return
		end
		
		-- Calculate escape direction from player
		local playerToLeft = self.player.x < self.x
		local playerBelow = self.player.y > self.y
		
		if blockedX and blockedY then
			-- Corner collision - try a random perpendicular direction
			if math.random() > 0.5 then
				self.bounceDirection = playerBelow and 'up' or 'down'
			else
				self.bounceDirection = playerToLeft and 'right' or 'left'
			end
		elseif blockedX then
			-- Horizontal collision (hit left/right wall)
			-- Move up or down, away from player
			self.bounceDirection = playerBelow and 'up' or 'down'
		elseif blockedY then
			-- Vertical collision (hit top/bottom wall)
			-- Move left or right, away from player
			self.bounceDirection = playerToLeft and 'right' or 'left'
		end
		
		-- Set bounce frames (how long to maintain this direction)
		self.bounceFrames = 20
	end

	-- Check for player contact to trigger interaction
	if length > 0 then
		for _, collision in ipairs(collisions) do
			if collision.other:isa(Player) then
				collision.other:collisionResponse(self)
			end
		end
	end
end
function CrewMember:collisionResponse(other)
	-- Physical collisions (walls and props)
	if other:isa(Box) then
		-- Use slide for walls so we can move along them
		return 'slide'
	elseif other:isa(Enemy) then
		-- Slide on enemies (Brocorat, etc.) to trigger bounce
		return 'slide'
	elseif other:isa(PropItem) then
		if other.type == 'minifier' then
			-- Pass through minifiers
			return 'overlap'
		else
			-- Slide on other props (chairs, tables, etc.)
			return 'slide'
		end
	else
		-- Pass through everything else in group 3 (Triggers, Items, etc.)
		-- Note: player and enemy are already ignored via setCollidesWithGroups
		return 'overlap'
	end
end

-- ============================================
-- HIDING STATE FUNCTIONS
-- ============================================

-- Enter hiding state when cornered
function CrewMember:enterHiding()
	if self.isHiding then return end -- Already hiding
	
	self.isHiding = true
	self.hidingMovementTokensAccumulated = 0
	self.consecutiveCornerFrames = 0
	
	-- Change to hiding animation/sprite
	-- TODO: Replace 'empty' with actual hiding animation state when sprite is ready
	self.animation:setState('hide') -- Placeholder: use 'empty' state for now
	
	-- Hide the hat
	if self.hat then
		self.hat:setVisible(false)
	end
	
	-- Remove collider so player can't interact
	self:setCollideRect(0, 0, 0, 0)
	
	-- Remove from enemy collision group
	self:setGroups({})
	
	printDebug("🙈 CrewMember entered hiding state - CrewID:", self.crewId)
end

-- Exit hiding state and return to normal
function CrewMember:exitHiding()
	if not self.isHiding then return end -- Not hiding
	
	self.isHiding = false
	self.hidingMovementTokensAccumulated = 0
	self.consecutiveCornerFrames = 0
	
	-- Restore normal animation
	self.animation:setState('idle')
	
	-- Show the hat again
	if self.hat then
		self.hat:setVisible(true)
	end
	
	-- Restore original collider
	self:setCollideRect(
		self.originalCollideRect.x,
		self.originalCollideRect.y,
		self.originalCollideRect.w,
		self.originalCollideRect.h
	)
	
	-- Restore enemy collision group
	self:setGroups(CollideGroups.enemy)
	
	-- Reset bounce state
	self.bounceDirection = nil
	self.bounceFrames = 0
	
	printDebug("👀 CrewMember exited hiding state - CrewID:", self.crewId)
end

-- Check if conditions are met to exit hiding
function CrewMember:checkExitHiding()
	if not self.isHiding then return end
	
	-- Both conditions must be met:
	-- 1. Player must be out of vision range
	-- 2. Enough movement tokens must have accumulated
	if self:isPlayerOutOfVision() and 
	   self.hidingMovementTokensAccumulated >= self.hidingMovementTokensRequired then
		self:exitHiding()
	end
end

-- Check if player is outside the vision range
function CrewMember:isPlayerOutOfVision()
	if not self.player then return true end
	
	local dx = self.player.x - self.x
	local dy = self.player.y - self.y
	local distance = math.sqrt(dx * dx + dy * dy)
	
	return distance > self.hidingVisionRange
end

function CrewMember:returnScript()
    local roomData = levelsLDTK[self.room]
    local fallbackScript = self.crewId and (self.crewId .. "_tiny") or "default_tiny"
    
    if not roomData or not roomData.entities or not roomData.entities.CrewMember then
        printDebug("⚠️ No CrewMember data found for room:", self.room)
        return fallbackScript
    end
    
    local crewData
    for _, c in ipairs(roomData.entities.CrewMember) do
        if c.iid == self.iid then
            crewData = c
            break
        end
    end

    if not crewData then 
        return fallbackScript
    end

    local cf = crewData.customFields or {}
    
    -- Prioritize tinyScript from LDtk, check script as fallback, then our constructed fallback
    local scriptToReturn = cf.tinyScript or cf.script or fallbackScript
    printDebug("🔍 CrewMember returnScript:", scriptToReturn)
    
    return scriptToReturn
end

function CrewMember:taken()
	local roomData = levelsLDTK[self.room]
	if not roomData or not roomData.entities or not roomData.entities.CrewMember then
		printDebug("⚠️ No CrewMember data found for room:", self.room)
		return
	end

	for _, crewData in ipairs(roomData.entities.CrewMember) do
		local cf = crewData.customFields or {}
		local currentIID = crewData.iid
	
		-- Search for the corresponding CrewMember by its IID (unique LDtk identifier)
		if currentIID == self.iid then
			cf.isTaken = true
			PlayerData.CrewMemberData.amountTaken += 1
			-- Mark the specific crew member as captured in PlayerData using stored crewId
			if self.crewId then
				PlayerData.CrewMemberData.idNumbers[self.crewId] = true
				printDebug("🟢 CrewMember marked as taken:", currentIID, "ID:", self.crewId)
			else
				printDebug("🟢 CrewMember marked as taken:", currentIID, "(no crewId)")
			end
			-- Restore player's projectile
			if self.player then
				self.player.hasProjectile = true
			end
			break
		end
	end

	self:remove()
	if self.hat then
		self.hat:remove()
	end
end

function CrewMember:stunInfinite()
    self.isStunnedInfinitely = true
    self.movementFrames = 0
    self.animation:setState('stunned')
    
    -- Hide the hat while stunned
    if self.hat then
        self.hat:setVisible(false)
    end
    
    printDebug("✨ CrewMember stunned INFINITELY!")
end

-- Blinds the crew member for a specific number of frames
function CrewMember:blind(frames)
    if self.isHiding then return end -- Can't blind if hidden
    
    self.blindFrames = frames or self.blindDuration
    self.isBlinded = true
    
    -- Reset movement frames to stop current movement
    self.movementFrames = 0
    
    -- Visual feedback: use idle or a specific state if available
    self.animation:setState('idle')
    
    printDebug("✨ CrewMember blinded! Frames:", self.blindFrames)
end

function CrewMember:escape(player)
	self.player = player
	local movementX, movementY
	
	-- Check if we're in bounce mode
	if self.bounceFrames > 0 then
		self.bounceFrames = self.bounceFrames - 1
		
		-- Move in the bounce direction
		if self.bounceDirection == 'left' then
			movementX = self.x - self.moveSpeed
			movementY = self.y
		elseif self.bounceDirection == 'right' then
			movementX = self.x + self.moveSpeed
			movementY = self.y
		elseif self.bounceDirection == 'up' then
			movementX = self.x
			movementY = self.y - self.moveSpeed
		elseif self.bounceDirection == 'down' then
			movementX = self.x
			movementY = self.y + self.moveSpeed
		else
			-- Fallback to normal escape
			movementX = self.player.x <= self.x and self.x + self.moveSpeed or self.x - self.moveSpeed
			movementY = self.player.y <= self.y and self.y + self.moveSpeed or self.y - self.moveSpeed
		end
		
		-- Clear bounce direction when frames run out
		if self.bounceFrames <= 0 then
			self.bounceDirection = nil
		end
	else
		-- Normal escape movement (away from player)
		movementX = self.player.x <= self.x and self.x + self.moveSpeed or self.x - self.moveSpeed
		movementY = self.player.y <= self.y and self.y + self.moveSpeed or self.y - self.moveSpeed
	end

	self.animation:setState('walk')
	self:moveCollision(movementX, movementY, self.player)
	
end

function CrewMember:update()
	-- Performance: Only update AI every 3 frames
	self.updateFrameCounter = (self.updateFrameCounter + 1) % 2
	
	-- If hiding, don't move - just check exit conditions periodically
	if self.isHiding then
		-- Check exit conditions every few frames (when tokens are added via addMovementTokens/Frames)
		-- The checkExitHiding is called from those functions, so nothing needed here
		-- Ensure hiding animation stays active
		if self.animation.currentState ~= 'empty' then
			self.animation:setState('hide')
		end
		return
	end
	
	if self.isBlinded or self.isStunnedInfinitely then
		if self.isBlinded then
			self.blindFrames = self.blindFrames - 1
			if self.blindFrames <= 0 then
				self.isBlinded = false
				printDebug("👁️ CrewMember no longer blinded")
			end
		end
		
		-- Ensure stunned animation stays active
		if self.isStunnedInfinitely and self.animation.currentState ~= 'stunned' then
			self.animation:setState('stunned')
		end
		
		-- Return early to skip movement logic while blinded or stunned infinitely
		return
	end

	if self.movementFrames > 0 then
		self.movementFrames = self.movementFrames - 1
		
		-- Performance: Update AI every 2 frames for smoother/faster movement
		if self.updateFrameCounter % 2 == 0 then
			self:search(self.player)
		end
	else
		-- Ensure idle animation
		if self.animation.currentState ~= 'idle' then
			self.animation:setState('idle')
		end
	end
	--self:sonar()
end