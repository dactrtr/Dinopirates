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
import "entities/player/projectile"
import "entities/player/plunge"
local dialogUI = nil
local uiHud = nil

function Player:init(x, y, speed, Zindex)
    Player.super.init(self, 'assets/images/player/player', true)
    self:initAnimations()
    -- MARK: Basic properties
    self:setSize(48, 52)
    self:setZIndex(Zindex)
    self:moveTo(x, y)
    self:setCollideRect(8, 24, 30, 24)
    if PlayerData.isTiny == true then
        self:setCollideRect(19, 32, 10, 10)
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
    self.playerUIX = 30
    self.playerUIY = 30
    self.isBehind = false
    self.direction = PlayerData.direction -- Initialize self.direction
    self.triggerEnteredOnce = false
    self.currentMinifier = nil

    -- Performance: Cache for optimization
    self.lastZIndexY = y
    self.lastCheckX = x
    self.lastCheckY = y

    PlayerData.isActive = false
    self.loadingPower = false
    self.isAlive = true
    self.isInvincible = false
    self.invincibilityTimer = 0
    self.dashCooldown = 0     -- Cooldown timer for dash attack
    self.lightBurstCooldown = 0 -- Cooldown timer for light burst

    -- Dash state variables
    self.isDashing = false
    self.dashDirection = nil
    self.dashProgress = 0
    self.dashSpeed = 8
    self.dashTotalDistance = 32
    self.dashBounceDistance = 16

    -- Sliding state variables
    self.isSliding = false
    self.slidingDirection = nil
    self.slidingSpeed = 4

    self.isPlunging = false
    self.hasProjectile = true

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
