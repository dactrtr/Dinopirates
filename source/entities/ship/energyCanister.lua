
class('EnergyCanister').extends(Graphics.sprite)

local meter = Graphics.image.new("assets/images/ui/EnergyTank.png")

function EnergyCanister:init(x,y)
	self:moveTo(x,y)
	self:setImage(meter)
	self:setZIndex(zMain)
	self:add()	
	
end

function EnergyCanister:update()
end
