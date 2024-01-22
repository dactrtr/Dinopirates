keyHud = {}
class("keyHud").extends(Graphics.sprite)

local keyIndicator = Graphics.image.new('assets/images/ui/key.png')

function keyHud:init(x, y, zIndex, player, indicator)
	self.player = player
	self.indicatorPosition = indicator
	
	self:moveTo(x,y)	
	self:setImage(keyIndicator)
	self:setZIndex(zIndex)
	self:add()
end

function keyHud:update()
	if not self.indicatorPosition then
		self:moveTo(self.player.x + 26, self.player.y - 36)
	end
	if PlayerData.hasKey == false then
		self:setImage(nil)
	else
		self:setImage(keyIndicator)
	end
end


