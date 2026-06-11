-- Plunge skill for player
-- Fires a boomerang projectile and locks movement until caught

function Player:plunge()
    -- Check if can plunge (item + skill)
    if not PlayerData.items.hasPlunger or not PlayerData.skills.canPlungerang then
        printDebug("Skill 'Plunge' not available!")
        return
    end

    -- Prevent plungerang if tiny
    if PlayerData.isTiny then
        printDebug("Too small to throw the plungerang!")
        return
    end
    
    -- Only one projectile at a time
    if self.isPlunging then
        printDebug("Already plunging!")
        return
    end

    -- Check if player has the projectile
    if not self.hasProjectile then
        printDebug("You lost your boomerang! Go find it.")
        return
    end
    
    -- Check for valid state
    if not self.isAlive or PlayerData.isGaming ~= true then
        return
    end

    -- Check direction - don't fire if idle
    local direction = PlayerData.direction
    if direction == 'idle' or direction == nil then
        printDebug("Cannot plunge in idle state")
        return
    end
    
    printDebug("🪠 Plunge skill activated!")
    
    self.isPlunging = true

    -- Create the projectile
    self.projectile = Projectile(self, direction)

    -- Grant enemy/crew movement tokens now that the plungerang actually fired
    self:distributeMovementTokens(Config.Player.movementTokensPerAction)

    -- Hold the shoot pose while the plungerang is out. It persists (whether the player
    -- holds or releases a direction) until the boomerang is back in hand, then Player:idle()
    -- snaps to idle. Only left/right have shoot art, so a vertical throw uses the right pose.
    self.shootDir = (direction == 'left') and 'left' or 'right'
    self.animation:setState(self.shootDir == 'left' and 'shootLeft' or 'shootRight')
end

function Player:onProjectileCaught()
    self.isPlunging = false
    self.projectile = nil
    -- Drop the throw pose once the plungerang is back in hand.
    self:idle()
    printDebug("✅ Plunge skill completed!")
end
