
class('EnergyMeter').extends(Graphics.sprite)

import "entities/ship/energyCanister"

function EnergyMeter:init(ship)
	distanceFromShip = 48
	self.energyTotal = ship.energyTotal
	xPos = ship.x - distanceFromShip
	yPos = ship.y - 12
	self:moveTo( xPos,ship.y)
	canister = EnergyCanister(xPos ,yPos)
	self:setZIndex(zMain)
	self:updateEnergy(ship.energy)
	self:add()	
	
end

function EnergyMeter:updateEnergy()
	local maxHeight = 42
	local width = 8
	local energybarHeight = (ship.energy / self.energyTotal) * maxHeight
	local energybarImage = Graphics.image.new(width,maxHeight)
	Graphics.pushContext(energybarImage)
		Graphics.setColor(Graphics.kColorWhite)
		Graphics.fillRect(0,0, width, energybarHeight)
	Graphics.popContext()
	self:setZIndex(11)
	self:setImage(energybarImage, "flipY")
	if ship.energy >= ship.energyTotal then
		self:resetRotations()
	end
end

function EnergyMeter:drain()
	if ship.energy > 0 and ship.mode == "fighter" then
		local mov = math.random(-1,1)
		self:moveBy(mov,mov)
		canister:moveBy(mov,mov)
	end
	
end
function EnergyMeter:fill(amount)
	local mov = math.random(-10,10)
	if  ship.mode == "travel" then
		self:setRotation(mov)
		canister:setRotation(mov)
		ship.energy += amount
	end
	self:updateEnergy(ship)
end
function EnergyMeter:update()
		self:updateEnergy()
	if  self.x > (xPos + 2) or self.x < (xPos - 2) or self.y < (yPos - 2) or self.y > (yPos + 2) then
		
		self:moveTo( xPos ,yPos)
		canister:moveTo( xPos + 2,yPos)
	end
	if ship.mode == "travel" then
		yPos = ship.y - 12
		self:moveTo( self.x ,yPos)
		canister:moveTo( self.x + 2,yPos)
	end
end
function EnergyMeter:resetPosition()
	xPos = ship.x - distanceFromShip
	yPos = ship.y - 12
	self:setRotation(0)
	canister:setRotation(0)
	self:moveTo( xPos ,ship.y)
	canister:moveTo( xPos + 2 ,ship.y)
end
function EnergyMeter:resetRotations()
	self:setRotation(0)
	canister:setRotation(0)
end