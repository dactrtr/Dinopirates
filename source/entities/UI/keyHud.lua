class("keyHud").extends(Graphics.sprite)

local keyIndicator = Graphics.image.new('assets/images/ui/key.png')

function keyHud:init(x, y, zIndex, player)
	self:moveTo(x,y)	
	self.player = player
	self:setImage(keyIndicator)
	self:setZIndex(zIndex)
	self:add()
end

function keyHud:update()
	if self.player.hasKey == false then
		self:setImage(nil)
	else
		self:setImage(keyIndicator)
	end
end


