function Player:useAbility()
    if not self.isAlive or PlayerData.isGaming ~= true then
        return
    end
    if self:isOnHole() then return end  -- on a hole the player may only walk
    if PlayerData.isInDarkness then
        self:useLampAbility()
    else
        self:usePlungeAbility()
    end
end

function Player:useLampAbility()
    self:lightBurst()
end

function Player:usePlungeAbility()
    self:plunge()
end

function Player:beginDarkCharge()
    if not PlayerData.isInDarkness or not PlayerData.items.hasLamp then return end
    if self:isOnHole() then return end  -- on a hole the player may only walk
    if PlayerData.battery < Config.DarkReveal.minBattery then return end
    if self.isDarkCharging then return end
    self.isDarkCharging = true
    self.darkCrankAccum = 0
    self.uiHud.animation:setState('crankClock')
    self.uiHud:setVisible(true)
end

function Player:addDarkCrankDelta(delta)
    if not self.isDarkCharging then return end
    if delta > 0 then self.darkCrankAccum += delta end
end

function Player:endDarkCharge()
    if not self.isDarkCharging then return end
    self.isDarkCharging = false
    self.uiHud:setRotation(0)
    self.uiHud:setVisible(false)
    if self:isOnHole() then self.darkCrankAccum = 0; return end  -- walked onto a hole: cancel, no skill
    if self.darkCrankAccum >= Config.DarkReveal.crankThreshold and PlayerData.battery >= Config.DarkReveal.minBattery then
        self:activateDarkReveal()
    else
        self:useLampAbility()
    end
    self.darkCrankAccum = 0
end

function Player:activateDarkReveal()
    -- Block the reveal if its self-damage would leave the player without life.
    -- The cost ignores invincibility, so it is always real; refuse to fire when lethal.
    local selfDamage = Config.DarkReveal.selfDamage or 0
    if selfDamage > 0 and (PlayerData.healthPoints - selfDamage) < (PlayerData.danceThresholdHP or Config.Player.danceThresholdHP) then
        printDebug("🚫 Dark reveal blocked: not enough HP (self-damage would leave the player without life)")
        return
    end

    PlayerData.battery = 0
    PlayerData.rechargeBlocked = true
    PlayerData.showFullLight = true

    -- Play the shock animation on activation; revert to idle after shockDuration, but
    -- only if the player hasn't started another animation (e.g. walking) in the meantime.
    self.animation:setState('shock')
    playdate.timer.performAfterDelay(Config.DarkReveal.shockDuration, function()
        if self.animation.currentName == 'shock' then
            self:idle()
        end
    end)

    -- The reveal burns the player: it always costs HP and ignores invincibility.
    -- The lethal case was already rejected above, so this can never drop the
    -- player below the dance threshold.
    if selfDamage > 0 then
        PlayerData.healthPoints -= selfDamage
        printDebug("🔥 Dark reveal self-damage: -" .. selfDamage .. " HP (now " .. PlayerData.healthPoints .. ")")
    end

    -- Grant enemy/crew movement tokens now that the dark reveal actually activated
    self:distributeMovementTokens(Config.Player.movementTokensPerAction)

    playdate.timer.performAfterDelay(Config.DarkReveal.revealDuration, function()
        PlayerData.showFullLight = false

        playdate.timer.performAfterDelay(Config.DarkReveal.rechargeBlockDuration, function()
            PlayerData.rechargeBlocked = false
        end)
    end)
end
