
class('FXshadow').extends(Graphics.sprite)

local shadow = Graphics.image.new("assets/images/shadow.png")
shadow:addMask()
local light = Graphics.image.new("assets/images/light.png")

function FXshadow:init(player)
	self:moveTo(200,120)
	self:setImage(shadow)
	self:setZIndex(10)
	self:add()	
	self.player = player
end

function FXshadow:update()
	local shadowMask = shadow:getMaskImage()
	Graphics.pushContext( shadowMask )
		--shadow:getMaskImage():draw(0,0)
		light:drawCentered(self.player.x,self.player.y)	
	Graphics.popContext()
end
