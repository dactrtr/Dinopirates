import 'entities/space/EnergyCanister'

class('EnergyMeter').extends(Graphics.sprite)

function EnergyMeter:init(ship)
    self.distanceFromShip = 48
    self.xPos = ship.x - self.distanceFromShip
    self.yPos = ship.y - 12
    self.lastEnergy = nil

    self.canister = EnergyCanister(self.xPos, self.yPos)
    self:moveTo(self.xPos, ship.y)
    self:setZIndex(ZIndex.ui + 1)
    self:updateEnergy(ship)
    self:add()
end

function EnergyMeter:updateEnergy(ship)
    if self.lastEnergy == ship.energy then return end
    self.lastEnergy = ship.energy

    local maxHeight = 42
    local width = 8
    local barH = (ship.energy / ship.energyTotal) * maxHeight
    local img = Graphics.image.new(width, maxHeight)
    Graphics.pushContext(img)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillRect(0, 0, width, barH)
    Graphics.popContext()
    self:setImage(img, Graphics.kImageFlippedY)

    if ship.energy >= ship.energyTotal then
        self:setRotation(0)
        self.canister:setRotation(0)
    end
end

function EnergyMeter:drain(ship)
    if ship.energy > 0 and ship.mode == 'fighter' then
        local mov = math.random(-1, 1)
        self:moveBy(mov, mov)
        self.canister:moveBy(mov, mov)
        self:updateEnergy(ship)
    end
end

function EnergyMeter:fill(ship, amount)
    if ship.mode == 'travel' then
        local mov = math.random(-10, 10)
        self:setRotation(mov)
        self.canister:setRotation(mov)
        ship.energy += amount
    end
    self:updateEnergy(ship)
end

function EnergyMeter:resetPosition(shipX, shipY)
    self.xPos = shipX - self.distanceFromShip
    self.yPos = shipY - 12
    self:setRotation(0)
    self.canister:setRotation(0)
end

function EnergyMeter:update()
    local lf = Config.Space.shipMoveLerp
    local nx = self.x + (self.xPos - self.x) * lf
    local ny = self.y + (self.yPos - self.y) * lf
    if math.abs(nx - self.x) > 0.5 or math.abs(ny - self.y) > 0.5 then
        self:moveTo(nx, ny)
        self.canister:moveTo(nx + 2, ny)
    end
end

function EnergyMeter:remove()
    if self.canister then self.canister:remove() end
    EnergyMeter.super.remove(self)
end
