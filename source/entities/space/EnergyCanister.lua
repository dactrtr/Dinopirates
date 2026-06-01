class('EnergyCanister').extends(Graphics.sprite)

local meterImage = Graphics.image.new('assets/images/ui/EnergyTank')

function EnergyCanister:init(x, y)
    self:moveTo(x, y)
    self:setImage(meterImage, Graphics.kImageFlippedY)
    self:setZIndex(ZIndex.ui + 2)
    self:add()
end
