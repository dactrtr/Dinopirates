-- Light Burst ability for player
-- Activates when lamp is equipped and affects entities within light cone

function Player:lightBurst()
    -- Validate that lamp is equipped (activeItem == 1)
    if PlayerData.activeItem ~= 1 then
        printDebug("Light burst requires lamp to be equipped!")
        return
    end
    
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
    
    -- Check if there's enough battery 
    local batteryCost = 10
    if PlayerData.battery < batteryCost then
        printDebug("⚠️ Not enough battery! Need " .. batteryCost .. " battery (current: " .. PlayerData.battery .. ")")
        return
    end
    
    printDebug("💡 Light burst activated!")
    
    -- Consume battery
    PlayerData.battery = PlayerData.battery - batteryCost
    printDebug("🔋 Battery consumed: -" .. batteryCost .. " (remaining: " .. PlayerData.battery .. ")")
    
    -- Show the light cone
    PlayerData.showLightCone = true
    
    -- Get the current direction
    local direction = PlayerData.direction
    
    -- Create light cone polygon
    local lightPolygon = self:createLightCone(direction)
    
    if not lightPolygon then
        printDebug("Cannot create light cone in idle state")
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
    
    -- Set cooldown (1000ms = 1 second)
    self.lightBurstCooldown = playdate.getCurrentTimeMilliseconds() + 1000
    
    -- Hide the light cone after a short delay (1000ms = 1 second)
    self.lightConeHideTime = playdate.getCurrentTimeMilliseconds() + 1000
    
    -- Distribute motion tokens to enemies/crew
    self:distributeMovementTokens(1) -- 1 Token = ~1 second of movement
    
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
    local d = 200     -- Distance the light reaches forward (FX is 120)
    local h = 12      -- Height scaling for the cone shape (FX is 8)
    
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
    -- Define blind duration in frames (60 frames = approx 2 seconds)
    local blindDuration = 60
    
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
