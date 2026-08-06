Enemy = {}
class('Enemy').extends(NobleSprite)

import 'entities/FX/FXsonar'

--- Actualiza la velocidad de movimiento del enemigo según la batería del jugador
-- La velocidad se ajusta en rangos: 0 (detenido), 1-20 (50%), 21-60 (70%), 61-100 (100%)
-- Slowdown adicional en oscuridad con batería baja
function Enemy:updateMoveSpeed()
    if PlayerData.battery == 0 and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryEmpty
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdLow and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryLow * self.initialSpeed
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdMid and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryMid * self.initialSpeed
    else
        self.moveSpeed = self.initialSpeed
    end

    -- Additional slowdown in darkness with low battery
    if PlayerData.battery < Config.Enemy.batteryThresholdCritical and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedCritical
    end
end

-- Add tokens (1 token = ~1 second of movement at 30fps)
function Enemy:addMovementTokens(amount)
    if not self.movementFrames then self.movementFrames = 0 end
    self.movementFrames = self.movementFrames + (amount * Config.CrewMember.framesPerToken)
end

-- Add raw frames directly (for player movement sync - more efficient)
function Enemy:addMovementFrames(frames)
    if not self.movementFrames then self.movementFrames = 0 end
    -- Cap at reasonable max to prevent accumulation (3 seconds = 90 frames)
    self.movementFrames = math.min(self.movementFrames + frames, Config.CrewMember.movementFramesCap)
end

--- Búsqueda ciega: el enemigo se mueve directamente hacia el jugador
-- @param player table Referencia al objeto jugador
function Enemy:blindSearch(player)
    self.player = player
    self:updateMoveSpeed()
    
    local movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
    local movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed

    self.animation:setState('walk')
    self:moveCollision(movementX, movementY, self.player)
end

--- Maneja el movimiento con colisiones y efectos de rebote
-- @param movementX number Posición X objetivo
-- @param movementY number Posición Y objetivo
-- @param player table Referencia al objeto jugador
function Enemy:moveCollision(movementX, movementY, player)
    -- Speed is now managed by updateMoveSpeed() called before this function

    -- Holes (IntGrid 3) are walkable tiles with no physical collider, so
    -- moveWithCollisions won't stop the enemy. Sample the target tile and refuse
    -- to step onto a hole — the enemy halts at the edge instead of crossing it.
    if IsHoleAt(movementX, movementY) then
        return
    end

    -- Capture position before moving so the vision cone heading (facingX/Y) can be
    -- derived from the real movement delta (see below).
    local preX, preY = self.x, self.y

    local actualX, actualY, collisions, length = self:moveWithCollisions(movementX, movementY)
    local bounceFactor = Config.Enemy.bounceFactor
    if length > 0 then
        for index, collision in pairs(collisions) do
            local collideObject = collision['other']
            
            -- Bounce effect for DYNAMIC objects only (props / other enemies).
            -- Walls (Box) are intentionally excluded: they now use a 'slide'
            -- collision response, so applying the manual pushback here would fight
            -- the slide and reproduce the wall-oscillation bug.
            if collideObject:isa(PropItem) or collideObject:isa(Enemy) then

                if collideObject:isa(Brocorat) then
                    -- add function to enemies be able to eat themselves
                end
                if collideObject:isa(PropItem) and collideObject.isEdible == true then
                    self.powerLevel += 1
                    if (collideObject.type ~= "holeLeft" and collideObject.type ~= "holeRight" and collideObject.type ~= "holeDown" and collideObject.type ~= "holeTop") and self.powerLevel > Config.Enemy.eatPropPowerThreshold then
                        collideObject:destroyProp(collideObject.id)
                        self.powerLevel -= Config.Enemy.eatPropPowerPenalty
                    end
                end
                
                local normal = collision['normal']
                if normal then
                    -- Push back 5 pixels in the opposite direction
                    local bounceX = self.x + (normal.dx * bounceFactor)
                    local bounceY = self.y + (normal.dy * bounceFactor)
                    self:moveTo(bounceX, bounceY)
                end
            elseif collideObject:isa(Player) then
                -- Trigger player interaction when enemy moves into player
                collideObject:collisionResponse(self)
            end
        end
    end

    -- Update the heading the enemy "looks" toward from its real movement delta.
    -- The vision cone in perceive() reads facingX/Y. When the enemy is blocked and
    -- did not actually move, keep the previous heading.
    local deltaX = self.x - preX
    local deltaY = self.y - preY
    if deltaX ~= 0 or deltaY ~= 0 then
        self.facingX = (deltaX > 0 and 1) or (deltaX < 0 and -1) or 0
        self.facingY = (deltaY > 0 and 1) or (deltaY < 0 and -1) or 0
    end
end

-- Blinds the enemy for a specific number of frames
function Enemy:blind(frames)
    self.blindFrames = frames or 60
    self.isBlinded = true
    
    -- Reset movement frames to stop current movement
    self.movementFrames = 0
    
    -- Visual feedback
    if self.animation then
        self.animation:setState('idle')
    end
    
    printDebug("✨ Enemy blinded! Frames:", self.blindFrames)
end

function Enemy:collisionResponse(other)
    if other:isa(Items) or other:isa(Trigger) then
        return 'overlap'
    elseif other:isa(Box) then
        -- Walls: slide along the surface instead of freezing dead. This lets the
        -- enemy round a wall corner on the free axis (continuing toward its target)
        -- instead of grinding straight into it. Was 'freeze', which — combined with
        -- the manual bounce below — made the enemy oscillate against walls.
        return 'slide'
    elseif other:isa(PropItem) then
        return 'freeze'
    elseif other:isa(Player) then
        return 'overlap'
    else
        return 'freeze'
    end
end

function Enemy:sonar()
    if (PlayerData.x - 60) > (self.x) or (PlayerData.x + 60) < (self.x) then
        if PlayerData.isFocused == true and PlayerData.isInDarkness == true and PlayerData.sanity > 0 then
            self.animation.shine.frameDuration = math.random(1,16)
            self.animation:setState('shine')
            self:setZIndex(10)
        else
            self:setZIndex(self.Zindex)
            self.animation:setState('idle')
        end
    end
end

-- ==========================================================================
-- Stealth-hunter AI: perception (sight + hearing), state machine, movement.
-- All tunables live in Config.Enemy.Perception — no magic numbers here.
-- ==========================================================================

local TILE_SIZE = Config.Tiles.size

-- World pixel -> 1-based tile index (matches GetTileUnderPlayer in Utilities.lua).
local function worldToTile(coord)
    return math.floor(coord / TILE_SIZE) + 1
end

-- Center world position of a 1-based tile (used to path toward lastKnownTile).
local function tileCenter(tileX, tileY)
    return (tileX - 1) * TILE_SIZE + TILE_SIZE / 2,
           (tileY - 1) * TILE_SIZE + TILE_SIZE / 2
end

-- Sight-range multiplier from the player's light state. Lit = seen from afar;
-- darkness shrinks the range down to nearly blind at empty battery.
local function sightLightFactor()
    local P = Config.Enemy.Perception
    local lit = PlayerData.battery > 0 and PlayerData.isInDarkness == false
    if lit then
        return P.lightFactorLit
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdCritical then
        return P.lightFactorDark
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdMid then
        return P.lightFactorDim
    else
        return P.lightFactorDim
    end
end

-- Omnidirectional hearing radius from the player's noise (dash = loud, walk =
-- medium, idle = silent). No cone, no line of sight — sound rounds corners.
local function hearRange(player)
    local P = Config.Enemy.Perception
    local range
    if player.isDashing == true then
        range = P.hearDash
    elseif PlayerData.direction ~= "idle" then
        range = P.hearWalk
    else
        range = P.hearIdle
    end
    return range
end

--- Two-sense detection model. Sight is directional (cone), precise, gated by
-- light and walls, and yields an exact position -> CHASE. Hearing is
-- omnidirectional, fuzzy, driven by player noise, and yields an approximate
-- position -> INVESTIGATE. If either sense fires, the player is perceived.
-- @return table { seen = bool, sense = "sight"|"hearing"|nil, tile = {x,y}|nil }
function Enemy:perceive(player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    -- isTiny halves both senses (kept from the old range-halving behavior).
    local tinyMult = PlayerData.isTiny and 0.5 or 1

    local playerTile = { x = worldToTile(player.x), y = worldToTile(player.y) }

    -- --- Sight: cone + line of sight + light-scaled range ---
    local sightRange = self.sightRadius * sightLightFactor() * tinyMult
    if dist <= sightRange then
        -- Heading defaults to "down" until the enemy has moved at least once.
        local fx = self.facingX or 0
        local fy = self.facingY or 1
        if fx == 0 and fy == 0 then fy = 1 end

        local inCone
        if dist == 0 then
            inCone = true
        else
            local fmag = math.sqrt(fx * fx + fy * fy)
            local cosAng = (fx * dx + fy * dy) / (fmag * dist)
            if cosAng < -1 then cosAng = -1 elseif cosAng > 1 then cosAng = 1 end
            local angle = math.deg(math.acos(cosAng))
            inCone = angle <= Config.Enemy.Perception.coneHalfAngle
        end

        if inCone and HasLineOfSight(self.x, self.y, player.x, player.y) then
            return { seen = true, sense = "sight", tile = playerTile }
        end
    end

    -- --- Hearing: omnidirectional radius from player noise ---
    local hr = hearRange(player) * tinyMult
    if hr > 0 and dist <= hr then
        return { seen = true, sense = "hearing", tile = playerTile }
    end

    return { seen = false }
end

-- Step one tile toward a world target using the pathfinder. Feeds the resulting
-- direction into the existing moveCollision (preserving bounce / eat-props /
-- hole-halt). Returns false when no path exists so the caller can fall back.
function Enemy:stepTowardWorld(targetX, targetY, player)
    local dirX, dirY = Pathing.stepToward(self.x, self.y, targetX, targetY)
    if dirX == nil then
        return false  -- boxed in / no path
    end
    if dirX == 0 and dirY == 0 then
        return true   -- already on the target tile
    end
    local moveX = self.x + dirX * self.moveSpeed
    local moveY = self.y + dirY * self.moveSpeed
    self.animation:setState('walk')
    self:moveCollision(moveX, moveY, player)
    return true
end

--- State machine PATROL -> CHASE -> INVESTIGATE -> GIVE UP, run once per AI turn
-- (respecting the caller's movementFrames/token gating and the every-3-frames
-- throttle). Drives movement through the existing moveCollision.
function Enemy:tick(player)
    self.player = player
    if self.aiState == nil then self.aiState = "patrol" end
    if self.investigateTimer == nil then self.investigateTimer = 0 end
    self:updateMoveSpeed()

    local p = self:perceive(player)

    -- Perception updates state and memory.
    if p.seen and p.sense == "sight" then
        -- Exact position -> chase directly, refresh last-known every turn.
        self.aiState = "chase"
        self.lastKnownTile = p.tile
        self.investigateTimer = 0
    elseif p.seen and p.sense == "hearing" then
        -- Heard but not seen -> go look (unless already chasing on sight).
        if self.aiState ~= "chase" then
            self.aiState = "investigate"
            self.investigateTimer = 0
        end
        self.lastKnownTile = p.tile
    else
        -- Perceived nothing this turn: a chaser drops to investigating last-known.
        if self.aiState == "chase" then
            self.aiState = "investigate"
            self.investigateTimer = 0
        end
    end

    -- State behavior drives movement.
    if self.aiState == "chase" then
        -- If already adjacent, beeline (blindSearch) for the final approach;
        -- otherwise path around walls. Fall back to blindSearch if boxed in.
        if math.abs(player.x - self.x) <= TILE_SIZE and math.abs(player.y - self.y) <= TILE_SIZE then
            self:blindSearch(player)
        elseif not self:stepTowardWorld(player.x, player.y, player) then
            self:blindSearch(player)
        end

    elseif self.aiState == "investigate" then
        local target = self.lastKnownTile
        if not target then
            self.aiState = "patrol"
        else
            local enemyTileX = worldToTile(self.x)
            local enemyTileY = worldToTile(self.y)
            if enemyTileX == target.x and enemyTileY == target.y then
                -- Arrived at last-known: look around until the timeout, then give up.
                self.animation:setState('idle')
                self.investigateTimer = self.investigateTimer + 3
                if self.investigateTimer >= Config.Enemy.Perception.investigateTimeout then
                    self.aiState = "patrol"
                    self.lastKnownTile = nil
                    self.investigateTimer = 0
                end
            else
                local tx, ty = tileCenter(target.x, target.y)
                if not self:stepTowardWorld(tx, ty, player) then
                    -- Cannot reach last-known: count it toward giving up.
                    self.investigateTimer = self.investigateTimer + 3
                    if self.investigateTimer >= Config.Enemy.Perception.investigateTimeout then
                        self.aiState = "patrol"
                        self.lastKnownTile = nil
                        self.investigateTimer = 0
                    end
                end
            end
        end
    end
    -- PATROL: no movement; the subclass update() handles the idle animation.
end

-- Debug overlay (drawn only when the global `debug` flag is on): vision cone with
-- its light-scaled range, hearing radius, state label, lastKnownTile mark, and the
-- current path from Pathing. Zero release cost — gated by the caller.
function Enemy:drawDebug()
    if debug ~= true then return end

    local P = Config.Enemy.Perception

    -- Effective sight range (light + tiny scaled) and cone heading.
    local tinyMult = PlayerData.isTiny and 0.5 or 1
    local sightRange = self.sightRadius * sightLightFactor() * tinyMult
    local fx = self.facingX or 0
    local fy = self.facingY or 1
    if fx == 0 and fy == 0 then fy = 1 end
    local heading = math.atan(fy, fx)          -- radians
    local half = math.rad(P.coneHalfAngle)

    Graphics.setColor(Graphics.kColorBlack)

    -- Cone edges + arc.
    local aLeft  = heading - half
    local aRight = heading + half
    Graphics.drawLine(self.x, self.y,
        self.x + math.cos(aLeft)  * sightRange, self.y + math.sin(aLeft)  * sightRange)
    Graphics.drawLine(self.x, self.y,
        self.x + math.cos(aRight) * sightRange, self.y + math.sin(aRight) * sightRange)
    Graphics.drawArc(self.x, self.y, sightRange,
        math.deg(aLeft) + 90, math.deg(aRight) + 90)

    -- Hearing radius (grows while the player dashes).
    if self.player then
        local hr = hearRange(self.player) * tinyMult
        if hr > 0 then
            Graphics.drawCircleAtPoint(self.x, self.y, hr)
        end
    end

    -- lastKnownTile mark.
    if self.lastKnownTile then
        local lx, ly = tileCenter(self.lastKnownTile.x, self.lastKnownTile.y)
        Graphics.drawLine(lx - 3, ly - 3, lx + 3, ly + 3)
        Graphics.drawLine(lx - 3, ly + 3, lx + 3, ly - 3)
    end

    -- Path dots.
    local path = Pathing.debugPath()
    if path then
        for _, t in ipairs(path) do
            local px, py = tileCenter(t.x, t.y)
            Graphics.fillCircleAtPoint(px, py, 1)
        end
    end

    -- State label above the enemy.
    Graphics.drawText(string.upper(self.aiState or "patrol"), self.x - 16, self.y - 28)
end