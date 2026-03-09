-- Dash attack module for player
-- Allows player to dash 10 pixels in their last facing direction
-- Bounces back 5 pixels on collision

function Player:dash()
    -- Validate that boots are equipped (activeItem == 2)
    if PlayerData.activeItem ~= 2 then
        printDebug("Dash requires boots to be equipped!")
        return
    end

    -- Check if can dash (item + skill)
    if not PlayerData.items.hasBoots or not PlayerData.skills.canDash or PlayerData.isTiny == true then
        printDebug("Skill 'Dash' not available!")
        return
    end
    
    -- Check if dash is on cooldown
    if self.dashCooldown and playdate.getCurrentTimeMilliseconds() < self.dashCooldown then
        printDebug("Dash on cooldown!")
        return
    end
    
    -- Check if already dashing
    if self.isDashing then
        return
    end
    
    -- Check if player is in valid state
    if not self.isAlive or PlayerData.isGaming ~= true then
        return
    end
    
    -- Get the last direction the player was facing
    local direction = PlayerData.direction
    
    -- Don't dash if player is idle or hasn't moved yet
    if direction == 'idle' or direction == nil then
        printDebug("No direction to dash!")
        return
    end
    -- Check if there's enough battery 
    local batteryCost = 10
    if PlayerData.battery < batteryCost then
        printDebug("⚠️ Not enough battery! Need " .. batteryCost .. " battery (current: " .. PlayerData.battery .. ")")
        return
    end
    
    -- Consume battery
    PlayerData.battery = PlayerData.battery - batteryCost
    printDebug("🔋 Battery consumed: -" .. batteryCost .. " (remaining: " .. PlayerData.battery .. ")")
    
    printDebug("🏃 Dash started in direction: " .. direction)
    
    -- Set dash state
    self.isDashing = true
    self.dashDirection = direction
    self.dashProgress = 0
    self.dashSpeed = 6  -- Pixels per frame (32 total / 4 frames = 8 per frame)
    self.dashTotalDistance = 56
    self.dashBounceDistance = 16
    
    -- Set animation state for the direction
    if direction == "left" then
        self.animation:setState('dashLeft')
    elseif direction == "right" then
        self.animation:setState('dashRight')
    elseif direction == "up" then
        self.animation:setState('dashUp')
    elseif direction == "down" then
        self.animation:setState('dashDown')
    end
    
    -- Set cooldown (500ms = 0.5 seconds)
    self.dashCooldown = playdate.getCurrentTimeMilliseconds() + 500
end

function Player:updateDash()
    if not self.isDashing then
        return
    end
    
    -- Calculate movement for this frame
    local moveX = 0
    local moveY = 0
    
    if self.dashDirection == "left" then
        moveX = -self.dashSpeed
    elseif self.dashDirection == "right" then
        moveX = self.dashSpeed
    elseif self.dashDirection == "up" then
        moveY = -self.dashSpeed
    elseif self.dashDirection == "down" then
        moveY = self.dashSpeed
    end
    
    -- Try to move
    local targetX = self.x + moveX
    local targetY = self.y + moveY
    local actualX, actualY, collisions, length = self:moveWithCollisions(targetX, targetY)
    
    -- Update UI position
    self.uiHud:moveTo(actualX + self.playerUIX, actualY - self.playerUIY)
    
    -- Filter collisions to only count solid objects (ignore triggers and items)
    local hasSolidCollision = false
    local hitBoxProp = nil
    
    if length > 0 then
        for i = 1, length do
            local other = collisions[i].other
            -- Only count collision if it's NOT a trigger or item
            -- Solid objects: walls, boxes, closed doors, enemies
            
            -- If it's a PropItem with type 'box' and it's not destroyed, count it as solid
            if other:isa(PropItem) then
                if other.type == 'box' and not other.isDestroyed then
                    hasSolidCollision = true
                    hitBoxProp = other
                    break
                end
            elseif not other:isa(Trigger) and not other:isa(Items) then
                hasSolidCollision = true
                break
            end
        end
    end
    
    -- Check if we hit a solid object
    if hasSolidCollision then
        -- If we hit a destructible box prop, destroy it!
        if hitBoxProp then
            hitBoxProp:hitBoxDash()
        end
        
        -- Collision detected, bounce back
        local bounceX = actualX
        local bounceY = actualY
        
        if self.dashDirection == "left" then
            bounceX = actualX + self.dashBounceDistance
        elseif self.dashDirection == "right" then
            bounceX = actualX - self.dashBounceDistance
        elseif self.dashDirection == "up" then
            bounceY = actualY + self.dashBounceDistance
        elseif self.dashDirection == "down" then
            bounceY = actualY - self.dashBounceDistance
        end
        
        self:moveWithCollisions(bounceX, bounceY)
        self.uiHud:moveTo(bounceX + self.playerUIX, bounceY - self.playerUIY)
        
        printDebug("Dash collided! Bouncing back.")
        self:endDash()
        return
    end
    
    -- Update progress
    self.dashProgress = self.dashProgress + self.dashSpeed
    
    -- Check if dash is complete
    if self.dashProgress >= self.dashTotalDistance then
        printDebug("Dash successful!")
        self:endDash()
    end
end

function Player:endDash()
    self.isDashing = false
    self.dashDirection = nil
    self.dashProgress = 0
    
    -- Restore appropriate idle animation after dash
    if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true then
        self.animation:setState('lampIdle')
    else
        self.animation:setState('idle')
    end
    
    printDebug("✅ Dash completed!")
end
