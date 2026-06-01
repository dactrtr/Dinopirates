-- Player hole and tiny-hole tile handling.
-- Mirrors the old PropItem isHole collision logic but driven by tile detection.

-- True while the player is standing on a hole tile. While on a hole the player may only walk:
-- no skill activation and no battery recharge (see abilities/grapple/sanity guards).
function Player:isOnHole()
    if IsPlayerOnHole(self.x, self.y) then return true end
    if PlayerData.isTiny and IsPlayerOnTinyHole(self.x, self.y) then return true end
    return false
end

function Player:checkHoleTile()
    -- Guard: skip if already transitioning or in a special movement state
    -- (grapple pull flies the player over holes instead of falling in)
    if self.isSliding or self.isPlunging or self.isFalling or self.isGrapplePulling then
        return
    end

    if not IsPlayerOnHole(self.x, self.y) then
        return
    end

    if PlayerData.items.hasBoots == true and PlayerData.battery > 0 then
        -- Only drain battery when the player is actively moving
        -- (preserves the "time moves when you move" contract)
        if PlayerData.isActive then
            if PlayerData.isTiny == true then
                self:drainBattery(Config.Battery.drainHoleTiny)
            else
                self:drainBattery(Config.Battery.drainHoleNormal)
            end
        end
    else
        -- Set flag BEFORE fallBelow() to block re-entry on subsequent frames
        -- while the Noble.transition() is still in progress.
        self.isFalling = true
        self:fallBelow()
    end
end

-- Same logic as checkHoleTile but for tiny-only holes (IntGrid 32).
-- Normal-size players walk over tiny holes as if they were floor.
function Player:checkTinyHoleTile()
    if not PlayerData.isTiny then return end
    if self.isSliding or self.isPlunging or self.isFalling or self.isGrapplePulling then
        return
    end

    if not IsPlayerOnTinyHole(self.x, self.y) then
        return
    end

    if PlayerData.items.hasBoots == true and PlayerData.battery > 0 then
        if PlayerData.isActive then
            self:drainBattery(Config.Battery.drainHoleTiny)
        end
    else
        self.isFalling = true
        self:fallBelow()
    end
end
