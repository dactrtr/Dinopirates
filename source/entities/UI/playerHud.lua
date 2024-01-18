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

function playerHud:init(player, userUI)	
	-- userUI sets the UI to be in the corner of the screen or over the character
	batteryIndicator = Battery(12, 10, player, ZIndex.ui, userUI)
	keyIndicator = keyHud(11, 24, ZIndex.ui, player)
	sonarIndicator = sonarHud(32, 10, ZIndex.ui, player, userUI)
	sanityIndicator = sanityHud(56, 10, ZIndex.ui, player, userUI)

end

function playerHud:removeAll()
	self:remove()
	batteryIndicator:removeAll()
	sonarIndicator:remove()
	sanityIndicator:remove()
end
function playerHud:update()
end

