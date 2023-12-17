
class('BatteryCanister').extends(Graphics.sprite)

local canister = Graphics.image.new("assets/images/ui/BatteryTank.png")

function BatteryCanister:init(x,y,Zindex)
	self:moveTo(x,y)
	self:setImage(canister)
	self:setZIndex(Zindex)
	self:add()	
	
end

function BatteryCanister:update()
end

