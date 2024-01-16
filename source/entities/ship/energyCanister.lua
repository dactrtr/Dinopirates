
class('EnergyCanister').extends(Graphics.sprite)

local meter = Graphics.image.new("assets/images/ui/EnergyTank.png")

function EnergyCanister:init(x,y,Zindex)
	self:moveTo(x,y)
	self:setImage(meter, "flipY")
	self:setZIndex(12)
	self:add()	
	
end

function EnergyCanister:update()
end
