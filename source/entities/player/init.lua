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
import "entities/player/abilities"
import "entities/player/lightburst"
import "entities/player/sliding"
import "entities/player/hole"
import "entities/player/projectile"
import "entities/player/plunge"
import "entities/player/grapple"
local dialogUI = nil
local uiHud = nil

function Player:init(x, y, speed, Zindex)
    Player.super.init(self, 'assets/images/player/player', true)
    self:initAnimations()
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
    self.sanityLoss = 1
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

    -- Sliding state variables
    self.isSliding = false
    self.slidingDirection = nil
    self.slidingSpeed = Config.Slide.speed
    self.slideHitWall = false  -- Prevents re-slide immediately after hitting a wall

    -- Hole state variable
    self.isFalling = false  -- Prevents fallBelow() firing every frame during transition

    self.isPlunging = false
    self.isDarkCharging  = false
    self.darkCrankAccum  = 0
    self.hasProjectile = true

    -- Grappling hook state variables
    self.isGrappleCharging = false
    self.isGrappling = false
    self.isGrapplePulling = false
    self.grappleCrankAccum = 0

    -- MARK: Add to scene
    self.dialogUI = dialogScreen()
    self.uiHud = UIHud(x, y)
    self:sanityCheck()
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
