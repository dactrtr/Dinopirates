class('Laser').extends(Graphics.sprite)

function Laser:init()
    self.laserBG = Graphics.image.new(400, 240, Graphics.kColorClear)
    self:setImage(self.laserBG)
    self:setZIndex(ZIndex.ui)
    self:moveTo(200, 120)
    self:add()
end

function Laser:draw(ship, crosshair, energy)
    if ship.energy <= 0 then return end

    local modX, modY = 0, 0
    if playdate.buttonIsPressed(playdate.kButtonLeft)  then modY =  8  modX =  2 end
    if playdate.buttonIsPressed(playdate.kButtonRight) then modY = -8  modX = -2 end

    Graphics.pushContext(self.laserBG)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.setLineWidth(1)
        Graphics.setLineCapStyle(Graphics.kLineCapStyleButt)
        Graphics.drawLine(ship.shooter01.x,        ship.shooter01.y + modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter02.x,        ship.shooter02.y - modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter03.x - modX, ship.shooter03.y + modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter04.x,        ship.shooter04.y - modY, crosshair.x, crosshair.y)
    Graphics.popContext()

    playdate.timer.performAfterDelay(6, function()
        self.laserBG:clear(Graphics.kColorClear)
        ship.energy -= 10
        energy:updateEnergy(ship)
    end)
end

function Laser:off()
    self.laserBG:clear(Graphics.kColorClear)
end
