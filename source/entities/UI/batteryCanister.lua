
class('BatteryCanister').extends(Graphics.sprite)

local canister <const> = Graphics.image.new("assets/images/ui/BatterySmall.png")

function BatteryCanister:init(x,y,Zindex)
	self:moveTo(x,y)
	self:setImage(canister)
	self:setZIndex(Zindex)
	self:add()	
end


