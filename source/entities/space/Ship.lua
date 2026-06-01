class('Ship').extends(NobleSprite)

function Ship:init(startX, startY, hull, speed, zIndex)
    Ship.super.init(self, 'assets/images/space/ship', true)

    self.animation:addState('fighter',         9,  9)
    self.animation:addState('travel',          5,  5)
    self.animation:addState('fighterup',     3,  3)
    self.animation:addState('fighterdown',       4,  4)
    self.animation:addState('travelup',      1,  1)
    self.animation:addState('traveldown',        2,  2)
    self.animation:addState('travelToFighter', 5,  9, 'fighter', 3)
    self.animation:addState('fighterToTravel', 9, 13, 'travel',  3)
    self.animation:addState('fighterleft',    15, 15)
    self.animation:addState('fighterright',   14, 14)

    self:setSize(80, 60)
    self:setZIndex(zIndex)
    self:setGroups(2)
    self:setCollideRect(20, 10, 40, 40)

    self.speed       = speed
    self.mode        = 'fighter'
    self.direction   = 'default'
    self.energy      = 100
    self.energyTotal = 100
    self.changeMode  = false

    self.lastMode      = self.mode
    self.lastDirection = self.direction

    self.targetX = startX
    self.targetY = startY

    self.shooter01 = { x = startX - 28, y = startY - 8 }
    self.shooter02 = { x = startX + 28, y = startY - 8 }
    self.shooter03 = { x = startX - 28, y = startY + 8 }
    self.shooter04 = { x = startX + 28, y = startY + 8 }

    self.animation:setState('fighter')
    self:add(startX, startY)
end

function Ship:setTarget(x, y)
    self.targetX = x
    self.targetY = y
end

function Ship:move(direction)
    self.direction = direction
    if direction == 'default' then
        -- idle transition handled in update()
    elseif direction == 'down' then
        self.animation:setState(self.mode == 'fighter' and 'fighterdown' or 'traveldown')
    elseif direction == 'up' then
        self.animation:setState(self.mode == 'fighter' and 'fighterup' or 'travelup')
    elseif direction == 'left' then
        if self.mode == 'fighter' then self.animation:setState('fighterleft') end
    elseif direction == 'right' then
        if self.mode == 'fighter' then self.animation:setState('fighterright') end
    end
end

function Ship:boost(mode)
    if self.energy > 0 and self.mode == mode then
        self.speed  = math.min(self.speed + 1, Config.Space.maxSpeed)
        self.energy -= 1
    end
end

function Ship:update()
    local dirChanged   = self.direction ~= self.lastDirection
    self.lastMode      = self.mode
    self.lastDirection = self.direction

    local x, y = self:getPosition()
    local lf   = Config.Space.shipMoveLerp
    local nx   = x + (self.targetX - x) * lf
    local ny   = y + (self.targetY - y) * lf
    if math.abs(nx - x) > 0.5 or math.abs(ny - y) > 0.5 then
        self:moveTo(nx, ny)
    end

    if self.changeMode then
        self.changeMode = false
        return
    end

    if self.direction == 'default' and dirChanged then
        self.animation:setState(self.mode == 'fighter' and 'fighter' or 'travel')
    end
end
