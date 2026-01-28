Enemy = {}
class('Enemy').extends(NobleSprite)

import 'entities/FX/FXsonar'

--- Actualiza la velocidad de movimiento del enemigo según la batería del jugador
-- La velocidad se ajusta en rangos: 0 (detenido), 1-20 (50%), 21-60 (70%), 61-100 (100%)
-- Slowdown adicional en oscuridad con batería baja
function Enemy:updateMoveSpeed()
    if PlayerData.battery == 0 and PlayerData.isInDarkness == true then
        self.moveSpeed = 0.2
    elseif PlayerData.battery <= 20 and PlayerData.isInDarkness == true then
        self.moveSpeed = 0.5 * self.initialSpeed
    elseif PlayerData.battery <= 60 and PlayerData.isInDarkness == true then
        self.moveSpeed = 0.7 * self.initialSpeed
    else
        self.moveSpeed = self.initialSpeed
    end
    
    -- Additional slowdown in darkness with low battery
    if PlayerData.battery < 10 and PlayerData.isInDarkness == true then
        self.moveSpeed = 0.5
    end
end

-- Add tokens (1 token = ~1 second of movement at 30fps)
function Enemy:addMovementTokens(amount)
    local FRAMES_PER_TOKEN = 30
    if not self.movementFrames then self.movementFrames = 0 end
    self.movementFrames = self.movementFrames + (amount * FRAMES_PER_TOKEN)
end

-- Add raw frames directly (for player movement sync - more efficient)
function Enemy:addMovementFrames(frames)
    if not self.movementFrames then self.movementFrames = 0 end
    -- Cap at reasonable max to prevent accumulation (3 seconds = 90 frames)
    self.movementFrames = math.min(self.movementFrames + frames, 90)
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

--- Búsqueda lineal: el enemigo se mueve solo si está alineado horizontal o verticalmente
-- @param player table Referencia al objeto jugador
function Enemy:linealSearch(player)
    self.player = player
    self:updateMoveSpeed()
    
    local movementX = self.x
    local movementY = self.y
    
    if math.abs(self.y - self.player.y) < self.viewRange then
        movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
        self:moveCollision(movementX, self.y, self.player)
    end
    
    if math.abs(self.x - self.player.x) < self.viewRange then
        movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed
        self:moveCollision(self.x, movementY, self.player)
    end
end

--- Maneja el movimiento con colisiones y efectos de rebote
-- @param movementX number Posición X objetivo
-- @param movementY number Posición Y objetivo
-- @param player table Referencia al objeto jugador
function Enemy:moveCollision(movementX, movementY, player)
    -- Speed is now managed by updateMoveSpeed() called before this function

    local actualX, actualY, collisions, length = self:moveWithCollisions(movementX, movementY)
    local bounceFactor = 3
    if length > 0 then
        for index, collision in pairs(collisions) do
            local collideObject = collision['other']
            
            -- Bounce effect here
            if collideObject:isa(Box) or collideObject:isa(PropItem) or collideObject:isa(Enemy) then
                
                if collideObject:isa(Brocorat) then
                    -- add function to enemies be able to eat themselves
                end
                if collideObject:isa(PropItem) and collideObject.isEdible == true then
                    self.powerLevel += 1
                    if (collideObject.type ~= "holeLeft" and collideObject.type ~= "holeRight" and collideObject.type ~= "holeDown" and collideObject.type ~= "holeTop") and self.powerLevel > 25 then
                        collideObject:destroyProp(collideObject.id) 
                        self.powerLevel -= 5
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
    elseif other:isa(Box) or other:isa(PropItem) then
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