-- Light Burst ability for player
-- Activates when lamp is equipped and affects entities within light cone

function Player:lightBurst()
    -- Check if light burst is on cooldown
    if self.lightBurstCooldown and playdate.getCurrentTimeMilliseconds() < self.lightBurstCooldown then
        printDebug("Light burst on cooldown!")
        return
    end
    
    -- Check if player is in valid state
    if not self.isAlive or PlayerData.isGaming ~= true then
        return
    end
    
    -- Check if lamp is available (item + skill)
    if not PlayerData.items.hasLamp or not PlayerData.skills.canFlash then
        printDebug("No lamp or flash skill available!")
        return
    end
    
    -- Light burst is directional, like the plungerang: do nothing while idle.
    -- Checked before consuming battery so a held-while-idle B can charge instead.
    local direction = PlayerData.direction
    if direction == 'idle' or direction == nil then
        return
    end

    -- Check if battery meets minimum threshold
    if PlayerData.battery < Config.LightBurst.minBattery then
        printDebug("⚠️ Not enough battery! Need " .. Config.LightBurst.minBattery .. "% (current: " .. PlayerData.battery .. ")")
        return
    end

    -- Block the flash if its self-damage would leave the player without life.
    -- The cost ignores invincibility, so it is always real; refuse to fire when lethal.
    local selfDamage = Config.LightBurst.selfDamage or 0
    if selfDamage > 0 and (PlayerData.healthPoints - selfDamage) < (PlayerData.danceThresholdHP or 5) then
        printDebug("🚫 Flash blocked: not enough HP (self-damage would leave the player without life)")
        return
    end

    printDebug("💡 Light burst activated!")

    -- Consume battery
    local batteryCost = Config.LightBurst.batteryCost
    PlayerData.battery = PlayerData.battery - batteryCost
    printDebug("🔋 Battery consumed: -" .. batteryCost .. " (remaining: " .. PlayerData.battery .. ")")

    -- Show the light cone
    PlayerData.showLightCone = true

    -- Create light cone polygon
    local lightPolygon = self:createLightCone(direction)

    if not lightPolygon then
        PlayerData.showLightCone = false
        return
    end
    
    -- Get entities within light cone
    local affectedEntities = self:getEntitiesInLightCone(lightPolygon)
    
    -- Apply effects to affected entities
    for _, entity in ipairs(affectedEntities) do
        self:affectEntity(entity)
    end
    
    if #affectedEntities == 0 then
        printDebug("No entities affected by light burst")
    end

    -- The flash burns the player: it always costs HP and ignores invincibility.
    -- The lethal case was already rejected in the validations above, so this can
    -- never drop the player below the dance threshold.
    if selfDamage > 0 then
        PlayerData.healthPoints -= selfDamage
        printDebug("🔥 Flash self-damage: -" .. selfDamage .. " HP (now " .. PlayerData.healthPoints .. ")")
    end

    self.lightBurstCooldown = playdate.getCurrentTimeMilliseconds() + Config.LightBurst.cooldown
    self.lightConeHideTime = playdate.getCurrentTimeMilliseconds() + Config.LightBurst.displayTime
    
    -- Distribute motion tokens to enemies/crew (only happens because the flash actually fired)
    self:distributeMovementTokens(Config.Player.movementTokensPerAction)
    
    printDebug("✅ Light burst completed!")
end

function Player:createLightCone(direction)
    -- Don't create cone if idle
    if direction == 'idle' or direction == nil then
        return nil
    end
    
    -- Use same parameters as FXshadow.lua
    local ix = PlayerData.x
    local iy = PlayerData.y
    local d = Config.LightBurst.coneDistance
    local h = Config.LightBurst.coneHeight
    
    -- Adjust distance depending on direction
    if direction == 'left' or direction == 'down' then
        d = d * -1
    end
    
    -- Create polygon based on direction
    local lightCone
    if direction == 'left' or direction == 'right' then
        lightCone = playdate.geometry.polygon.new(
            ix, iy,
            ix + d, iy - 4*h,
            ix + 1.1*d, iy - 3.5*h,
            ix + 1.2*d, iy - 2*h,
            ix + 1.25*d, iy,
            ix + 1.2*d, iy + 2*h,
            ix + 1.1*d, iy + 3.5*h,
            ix + d, iy + 4*h,
            ix, iy
        )
    elseif direction == 'up' or direction == 'down' then
        lightCone = playdate.geometry.polygon.new(
            ix, iy,
            ix - 4*h, iy - d,
            ix - 3.5*h, iy - 1.1*d,
            ix - 2*h, iy - 1.2*d,
            ix, iy - 1.25*d,
            ix + 2*h, iy - 1.2*d,
            ix + 3.5*h, iy - 1.1*d,
            ix + 4*h, iy - d,
            ix, iy
        )
    end
    
    if lightCone then
        lightCone:close()
    end
    
    return lightCone
end

function Player:getEntitiesInLightCone(lightPolygon)
    local affectedEntities = {}
    local allSprites = Graphics.sprite.getAllSprites()
    
    for _, sprite in ipairs(allSprites) do
        -- Check if sprite is an enemy or crew member
        if sprite:isa(CrewMember) then
            -- Check if entity is within the light cone
            if lightPolygon:containsPoint(sprite.x, sprite.y) then
                table.insert(affectedEntities, sprite)
            end
        end
    end
    
    return affectedEntities
end

function Player:affectEntity(entity)
    local blindDuration = Config.LightBurst.blindDuration
    
    if entity:isa(Brocorat) or entity:isa(Bosscolli) then
        -- For enemies, print that they were blinded with their ID
        local enemyId = entity.id or "unknown"
        printDebug("👁️ Enemy blinded! ID: " .. tostring(enemyId))
        
        -- If enemies also have blinding implementation, call it here
        if entity.blind then
            entity:blind(blindDuration)
        end
    elseif entity:isa(CrewMember) then
        -- For crew members, call the blind method
        local crewId = entity.crewId or entity.iid or "unknown"
        printDebug("👁️ Crew member blinded! ID: " .. tostring(crewId))
        
        if entity.blind then
            entity:blind(blindDuration)
        end
    end
end
