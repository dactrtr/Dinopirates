-- Ability system for player
-- Executes different abilities based on the active item selected in the ingame menu

function Player:useAbility()
    -- Check if player is in valid state
    if not self.isAlive or PlayerData.isGaming ~= true then
        return
    end
    
    -- Check if player has items
    if not PlayerData.items or table.getSize(PlayerData.items) == 0 then
        printDebug("No items available!")
        return
    end
    
    -- Get the currently selected item
    local activeItem = PlayerData.activeItem
    
    -- Execute ability based on active item
    if activeItem == 1 then
        -- Lamp ability
        self:useLampAbility()
    elseif activeItem == 2 then
        -- Boot ability (Dash)
        self:useBootAbility()
    elseif activeItem == 3 then
        -- Plunger ability (Plunge)
        self:usePlungeAbility()
    else
        printDebug("Unknown item selected: " .. tostring(activeItem))
    end
end

-- Lamp ability - Light Burst
function Player:useLampAbility()
    -- Call the light burst function
    self:lightBurst()
end

-- Boot ability - Dash attack
function Player:useBootAbility()
    -- Call the existing dash function
    self:dash()
end

-- Plunger ability - Boomerang projectile
function Player:usePlungeAbility()
    -- Call the new plunge function
    self:plunge()
end
