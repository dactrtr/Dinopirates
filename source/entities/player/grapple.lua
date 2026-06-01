-- Grappling Hook: charged plungerang for lit rooms.
-- Hold B + crank to charge, release to fire in the faced direction. The hook
-- ignores every sprite and only reacts to tile value 33 (Config.Tiles.IntGrid.grapplePoint):
-- on contact it pulls the player (fast slide) to that tile; otherwise it returns like a boomerang.

-- ===== Projectile =====
GrappleHook = {}
class('GrappleHook').extends(NobleSprite)

function GrappleHook:init(player, direction, maxDistance)
    local px, py = player:getPosition()
    GrappleHook.super.init(self, 'assets/images/items/projectile-table-24-24', true)

    self.player = player
    self.direction = direction
    self.maxDistance = maxDistance
    self.distanceTravelled = 0
    self.returning = false
    self.speed = Config.Grapple.projectileSpeed

    self:setZIndex(ZIndex.player + 10)
    self:setSize(24, 24)
    -- No setGroups / setCollidesWithGroups: zero sprite interaction by design.

    self:add(px, py + 16)

    self.animation:addState('spin', 1, 4)
    self.animation.spin.frameDuration = 4
    self.animation:setState('spin')

    printDebug("🪝 Grapple hook launched, dir: " .. tostring(direction) .. " dist: " .. tostring(maxDistance))
end

function GrappleHook:update()
    if self.returning then
        local dx = self.player.x - self.x
        local dy = self.player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist <= self.speed then
            self:remove()
            if self.player.onGrappleFinished then self.player:onGrappleFinished() end
        else
            self:moveTo(self.x + (dx/dist)*self.speed, self.y + (dy/dist)*self.speed)
        end
        return
    end

    -- Fly out in the launch direction (no sprite collisions; detection is tile sampling).
    local moveX, moveY = 0, 0
    if self.direction == 'left' then moveX = -self.speed
    elseif self.direction == 'right' then moveX = self.speed
    elseif self.direction == 'up' then moveY = -self.speed
    elseif self.direction == 'down' then moveY = self.speed
    end
    self:moveTo(self.x + moveX, self.y + moveY)

    -- Sample the tile under the hook's center.
    local tile = GetTileUnderPlayer(self.x, self.y)
    if tile == Config.Tiles.IntGrid.grapplePoint then
        local ts = Config.Tiles.size
        local cx = math.floor(self.x / ts) * ts + ts / 2
        local cy = math.floor(self.y / ts) * ts + ts / 2
        -- Aim so the player's feet (not the sprite center) settle on the tile center.
        self.player:startGrapplePull(cx, cy - Config.Player.feetOffsetY)
        self:remove()
        if self.player.onGrappleFinished then self.player:onGrappleFinished() end
        return
    elseif not IsTileWalkable(tile) then
        -- Hit a wall (or left the map) — bounce back like the boomerang.
        self.returning = true
        return
    end

    self.distanceTravelled += self.speed
    if self.distanceTravelled >= self.maxDistance then
        self.returning = true
    end
end

-- ===== Rope (black line drawn from the player to the hook) =====
-- The camera is fixed (world space == screen space, like FXshadow), so the sprite is sized to
-- the line's bounding box each frame and the line is drawn in the sprite's local coordinates.
GrappleRope = {}
class('GrappleRope').extends(Graphics.sprite)

function GrappleRope:init(player, hook)
    GrappleRope.super.init(self)
    self.player = player
    self.hook = hook
    self:setCenter(0, 0)                 -- position == top-left, so local coords map to world
    self:setZIndex(ZIndex.player + 9)    -- above the player, just under the hook (player + 10)
    self:add()
    self:refreshBounds()
end

function GrappleRope:refreshBounds()
    -- Anchor on the player's lower body, reusing the same feet offset as the grapple landing.
    local x1, y1 = self.player.x, self.player.y + Config.Player.feetOffsetY
    local x2, y2 = self.hook.x, self.hook.y       -- hook sprite center
    local pad = Config.Grapple.ropeWidth
    local minX = math.min(x1, x2) - pad
    local minY = math.min(y1, y2) - pad
    self:setSize(math.abs(x2 - x1) + pad * 2, math.abs(y2 - y1) + pad * 2)
    self:moveTo(minX, minY)
    -- Endpoints relative to the sprite's top-left.
    self.p1x, self.p1y = x1 - minX, y1 - minY
    self.p2x, self.p2y = x2 - minX, y2 - minY
    self:markDirty()
end

function GrappleRope:update()
    self:refreshBounds()
end

function GrappleRope:draw()
    Graphics.pushContext()
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.setLineWidth(Config.Grapple.ropeWidth)
        Graphics.drawLine(self.p1x, self.p1y, self.p2x, self.p2y)
    Graphics.popContext()
end

-- ===== Player charge / fire =====
function Player:beginGrappleCharge()
    if PlayerData.isInDarkness then return end
    if self:isOnHole() then return end  -- on a hole the player may only walk
    if not PlayerData.items.hasPlunger or not PlayerData.skills.canPlungerang then return end
    if not self.hasProjectile then return end  -- lost to a CrewMember; recover it before grappling
    if PlayerData.isTiny then return end
    if not self.isAlive or PlayerData.isGaming ~= true then return end
    if self.isGrappleCharging or self.isPlunging or self.isGrapplePulling or self.isGrappling then return end

    self.isGrappleCharging = true
    self.grappleCrankAccum = 0
    self.uiHud.animation:setState('crankClock')
    self.uiHud:setVisible(true)
end

function Player:addGrappleCrankDelta(delta)
    if not self.isGrappleCharging then return end
    if delta > 0 then self.grappleCrankAccum += delta end
end

function Player:endGrappleCharge()
    if not self.isGrappleCharging then return end
    self.isGrappleCharging = false
    self.uiHud:setRotation(0)
    self.uiHud:setVisible(false)

    local dir = self.direction
    if dir == 'idle' or dir == nil then
        self.grappleCrankAccum = 0
        return
    end
    if self:isOnHole() then self.grappleCrankAccum = 0; return end  -- walked onto a hole: cancel, no skill

    local g = Config.Grapple
    local distance = g.minDistance + self.grappleCrankAccum * g.pixelsPerDegree
    if distance > g.maxDistance then distance = g.maxDistance end
    self.grappleCrankAccum = 0

    self.isGrappling = true
    self.grappleHook = GrappleHook(self, dir, distance)
    self.grappleRope = GrappleRope(self, self.grappleHook)
    -- Grant enemy/crew movement tokens now that the grapple actually launched
    self:distributeMovementTokens(Config.Player.movementTokensPerAction)
    self:idle()
end

function Player:onGrappleFinished()
    self.isGrappling = false
    self.grappleHook = nil
    if self.grappleRope then
        self.grappleRope:remove()
        self.grappleRope = nil
    end
end

-- ===== Player pull (fast slide to the tile) =====
function Player:startGrapplePull(targetX, targetY)
    self.grappleTargetX = targetX
    self.grappleTargetY = targetY
    self.isGrapplePulling = true
end

function Player:updateGrapplePull()
    if not self.isGrapplePulling then return end

    local dx = self.grappleTargetX - self.x
    local dy = self.grappleTargetY - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local speed = Config.Grapple.pullSpeed

    if dist <= speed then
        self:moveTo(self.grappleTargetX, self.grappleTargetY)
        self.uiHud:moveTo(self.x + self.playerUIX, self.y - self.playerUIY)
        self.isGrapplePulling = false
        PlayerData.direction = 'idle'
        self:idle()
    else
        -- Face the pull direction so the player isn't frozen mid-slide.
        if math.abs(dx) > math.abs(dy) then
            self.animation:setState(dx < 0 and 'left' or 'right')
        else
            self.animation:setState(dy < 0 and 'up' or 'down')
        end
        local nx = self.x + (dx/dist)*speed
        local ny = self.y + (dy/dist)*speed
        self:moveTo(nx, ny)
        self.uiHud:moveTo(self.x + self.playerUIX, self.y - self.playerUIY)
    end
end
