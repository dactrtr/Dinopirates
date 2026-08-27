Player = {}
class('Player').extends(NobleSprite)
import "entities/UI/dialog/dialogScreen"
import "entities/UI/UIHud"

import "entities/player/animations"
import "entities/player/collisions"
import "entities/player/movement"
import "entities/player/sanity"
import "entities/player/items"
import "entities/player/state"
import "entities/player/dash"
import "entities/player/abilities"
import "entities/player/lightburst"
import "entities/player/sliding"
import "entities/player/hole"
import "entities/player/projectile"
import "entities/player/plunge"
import "entities/player/grapple"
import "entities/player/glitch"
local dialogUI = nil
local uiHud = nil

function Player:init(x, y, speed, Zindex)
    Player.super.init(self, 'assets/images/player/player', true)
    self:initAnimations()
    self:initGlitch()
    -- MARK: Basic properties
    self:setSize(48, 48)
    self:setZIndex(Zindex)
    self:moveTo(x, y)
    local cr = Config.Player.collideRect
    self:setCollideRect(cr.x, cr.y, cr.w, cr.h)
    if PlayerData.isTiny == true then
        local crt = Config.Player.collideRectTiny
        self:setCollideRect(crt.x, crt.y, crt.w, crt.h)
    end
    self:setCollidesWithGroups(
        {
            CollideGroups.enemy,
            CollideGroups.props,
            CollideGroups.items,
            CollideGroups.wall,
            CollideGroups.crewMember
        })
    self:setGroups(CollideGroups.player)

    -- MARK: Custom properties
    self.initialSpeed = speed
    self.speed = speed
    self.initialSanity = PlayerData.sanity
    self.initialBattery = PlayerData.battery
    self.sanity = PlayerData.sanity
    self.playerUIX = Config.Player.uiOffsetX
    self.playerUIY = Config.Player.uiOffsetY
    self.isBehind = false
    self.direction = PlayerData.direction -- Initialize self.direction
    self.triggerEnteredOnce = false
    self.currentMinifier = nil
    self.currentMicrowave = nil
    self.cookProgress = 0

    -- Performance: Cache for optimization
    self.lastZIndexY = y
    self.lastCheckX = x
    self.lastCheckY = y

    PlayerData.isActive = false
    self.loadingPower = false
    self.isSleeping = false
    self.wakeupPresses = 0
    self.isAlive = true
    self.isInvincible = false
    self.invincibilityTimer = 0
    self.lightBurstCooldown = 0 -- Cooldown timer for light burst
    self.dashCooldown = 0     -- Cooldown timer for dash attack

    -- Dash state variables
    self.isDashing = false
    self.dashDirection = nil
    self.dashProgress = 0
    self.dashSpeed = Config.Dash.speed
    self.dashTotalDistance = Config.Dash.totalDistance
    self.dashBounceDistance = Config.Dash.bounceDistance

    -- Sliding state variables
    self.isSliding = false
    self.slidingDirection = nil
    self.slidingSpeed = Config.Slide.speed
    self.slideHitWall = false  -- Prevents re-slide immediately after hitting a wall

    -- Hole state variable
    self.isFalling = false  -- Prevents fallBelow() firing every frame during transition

    -- Balancing (fall/slide grace) state
    self.holeGracePixels  = 0
    self.slideGracePixels = 0
    self._prevGraceX      = nil
    self._prevGraceY      = nil
    self._graceMove       = 0
    self._warningShown    = false

    self.isPlunging = false
    self.isDarkCharging  = false
    self.darkCrankAccum  = 0
    self.hasProjectile = true
    self.shootDir = 'right'  -- facing of the shoot pose held while the plungerang is out

    -- Grappling hook state variables
    self.isGrappleCharging = false
    self.isGrappling = false
    self.isGrapplePulling = false
    self.grappleCrankAccum = 0

    -- MARK: Add to scene
    self.dialogUI = dialogScreen()
    self.uiHud = UIHud(x, y)
    -- Point the single global sanity ticker (main.lua) at this live player. Reassigning
    -- here also drops the previous player's reference so it can be GC'd — the old
    -- per-Player timer used to pin every past player alive via its closure.
    CurrentPlayer = self
    self:add(x, y)
end

function Player:distributeMovementTokens(amount)
    local allSprites = Graphics.sprite.getAllSprites()
    for _, sprite in ipairs(allSprites) do
        -- Check if sprite is an enemy or crew member
        if sprite:isa(Brocorat) or sprite:isa(CrewMember) then
            if sprite.addMovementTokens then
                sprite:addMovementTokens(amount)
            end
        end
    end
end

-- Efficient version: only runs when player is actively moving
-- Uses isActive flag for performance (already set by movement code)
function Player:distributeMovementFrames(frames)
    -- Only distribute if player is active (moving)
    if not PlayerData.isActive then return end
    
    local allSprites = Graphics.sprite.getAllSprites()
    for _, sprite in ipairs(allSprites) do
        if sprite:isa(Brocorat) or sprite:isa(CrewMember) then
            if sprite.addMovementFrames then
                sprite:addMovementFrames(frames)
            end
        end
    end
end
