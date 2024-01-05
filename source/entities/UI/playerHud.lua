playerHud = {}
class("playerHud").extends(Graphics.sprite)

import "entities/UI/battery"
import "entities/UI/keyHud"
import "entities/UI/sonarHud"
import "entities/UI/sanityHud"

local batteryIndicator = nil
local keyIndicator = nil
local sonarIndicator = nil
local sanityIndicator = nil

function playerHud:init(player)	
	batteryIndicator = Battery(12, 10, player, ZIndex.ui, true)
	keyIndicator = keyHud(11, 24, ZIndex.ui, player)
	sonarIndicator = sonarHud(32, 10, ZIndex.ui, player, true)
	sanityIndicator = sanityHud(32, 10, ZIndex.ui, player, true)

end

function playerHud:removeAll()
	self:remove()
	batteryIndicator:removeAll()
end
function playerHud:update()
end

