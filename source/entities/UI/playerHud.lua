playerHud = {}
class("playerHud").extends(Graphics.sprite)

import "entities/player/battery"
local batteryIndicator = nil

function playerHud:init(player)
	self:moveTo(0,0)
	
	batteryIndicator = Battery(20,10, player, ZIndex.ui)
	--self:add()
end

function playerHud:removeAll()
	print('remove ui')
	self:remove()
	batteryIndicator:removeAll()
end
