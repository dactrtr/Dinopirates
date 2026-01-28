-- Projectile for the Plunge skill (Boomerang effect)
Projectile = {}
class('Projectile').extends(NobleSprite)

function Projectile:init(player, direction)
    local px, py = player:getPosition()
    Projectile.super.init(self, 'assets/images/items/projectile-table-24-24', true)
    
    self.player = player
    self.direction = direction
    self.startX = px
    self.startY = py
    self.distanceTravelled = 0
    self.maxDistance = 100 
    self.returning = false
    self.speed = 8 -- Increased speed for better feel
    
    self:setZIndex(ZIndex.player + 10)
    self:setSize(24, 24)
    self:setCollideRect(4, 4, 16, 16)
    self:setGroups(CollideGroups.items)
    self:setCollidesWithGroups({
        CollideGroups.enemy,
        CollideGroups.props,
        CollideGroups.wall,
        CollideGroups.crewMember
    })
    
    -- Set initial position and add to scene
    self:add(px, py + 16)
    
    -- Animation states (assuming the table has some frames)
    self.animation:addState('spin', 1, 4)
    self.animation.spin.frameDuration = 4
    self.animation:setState('spin')
    
    printDebug("🪃 Projectile launched in direction: " .. direction)
end

function Projectile:update()
    if self.returning then
        -- Return to player's current position
        local dx = self.player.x - self.x
        local dy = self.player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < self.speed then
            -- Caught by player
            self:onCaught()
        else
            -- Move towards player
            local vx = (dx / dist) * self.speed
            local vy = (dy / dist) * self.speed
            self:moveWithCollisions(self.x + vx, self.y + vy)
        end
    else
        -- Move in initial direction
        local moveX, moveY = 0, 0
        if self.direction == 'left' then moveX = -self.speed
        elseif self.direction == 'right' then moveX = self.speed
        elseif self.direction == 'up' then moveY = -self.speed
        elseif self.direction == 'down' then moveY = self.speed
        end
        
        local actualX, actualY, collisions, length = self:moveWithCollisions(self.x + moveX, self.y + moveY)
        
        -- Check for hits
        if length > 0 then
            for i = 1, length do
                local other = collisions[i].other
                if other:isa(CrewMember) then
                    printDebug("🎯 Projectile hit CrewMember! Projectile lost.")
                    if other.stunInfinite then
                        other:stunInfinite()
                    end
                    -- Projectile is lost
                    self.player.hasProjectile = false
                    self.player.isPlunging = false -- Unlock movement
                    self:remove()
                    return
                elseif other:isa(Enemy) then
                    self:hitEntity(other)
                    -- Start returning immediately after hit
                    self.returning = true
                    break
                elseif other:isa(PropItem) or other:isa(Box) then
                    printDebug("🧱 Projectile hit prop/wall! Returning.")
                    self.returning = true
                    break
                end
            end
        end
        
        self.distanceTravelled += self.speed
        if self.distanceTravelled >= self.maxDistance then
            self.returning = true
        end
    end
end

function Projectile:hitEntity(entity)
    printDebug("🎯 Projectile hit: " .. tostring(entity))
    if entity.blind then
        -- Use standard blind/stun duration
        entity:blind(60)
    end
end

function Projectile:onCaught()
    printDebug("🪃 Projectile caught!")
    if self.player.onProjectileCaught then
        self.player:onProjectileCaught()
    end
    self:remove()
end

function Projectile:collisionResponse(other)
    if other:isa(CrewMember) or other:isa(Enemy) then
        return 'overlap'
    end
    -- Slide along walls/props if we hit them? 
    -- For now, let's just overlap so it doesn't get stuck
    return 'overlap'
end
