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

function playerHud:init()	
	local x = 320
	local y = 0
	self:setImage(background)
	self:setCenter(0,0)
	self:moveTo(x, y)
	self:setZIndex(6)
	batteryIndicator = Battery(x+16, 11, player, ZIndex.ui, userUI)
	sonarIndicator = sonarHud(x+32, 11, ZIndex.ui, player, userUI)
	sanityIndicator = sanityHud(x+50, 11, ZIndex.ui, player, userUI)
	keyIndicator = keyHud(x+66, 11, ZIndex.ui, player, userUI)
	self:add()
end

function playerHud:update()
end

