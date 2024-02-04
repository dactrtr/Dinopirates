keyHud = {}
class("keyHud").extends(Graphics.sprite)

local keyIndicator = Graphics.image.new('assets/images/ui/key.png')

function keyHud:init(x, y, zIndex, player)
	self.player = player
	
	self:moveTo(x,y)	
	self:setImage(keyIndicator)
	self:setZIndex(zIndex)
	self:add()
end

function keyHud:update()
	if PlayerData.hasKey == false then
		self:setImage(nil)
	else
		self:setImage(keyIndicator)
	end
end


