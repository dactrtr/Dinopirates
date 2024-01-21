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

local background <const> = Graphics.image.new('assets/images/ui/statusbar.png')

function playerHud:init(player, userUI)	
	-- userUI sets the UI to be in the corner of the screen or over the character
	if userUI then
	self:setImage(background)
	self:setCenter(0,0)
	self:moveTo(0, 0)
	self:setZIndex(6)
	end
	batteryIndicator = Battery(16, 11, player, ZIndex.ui, userUI)
	sonarIndicator = sonarHud(32, 11, ZIndex.ui, player, userUI)
	sanityIndicator = sanityHud(50, 11, ZIndex.ui, player, userUI)
	keyIndicator = keyHud(66, 11, ZIndex.ui, player, userUI)
	self:add()
end

function playerHud:removeAll()
	self:remove()
	batteryIndicator:removeAll()
	sonarIndicator:remove()
	sanityIndicator:remove()
end
function playerHud:update()
end

