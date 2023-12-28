playerHud = {}
class("playerHud").extends(Graphics.sprite)

import "entities/player/battery"
import "entities/UI/keyHud"
import "entities/UI/sonarHud"

local batteryIndicator = nil
local keyIndicator = nil
local sonarIndicator = nil

function playerHud:init(player)	
	batteryIndicator = Battery(20,10, player, ZIndex.ui)
	keyIndicator = keyHud(11,24,ZIndex.ui, player)
	sonarIndicator = sonarHud(51,10,ZIndex.ui, player)
end

function playerHud:removeAll()
	self:remove()
	batteryIndicator:removeAll()
end
function playerHud:update()
end

