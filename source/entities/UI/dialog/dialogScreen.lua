


import "entities/UI/dialog/videoFeed"

local dialogbox <const> = Graphics.image.new('assets/images/ui/dialog/dialogbox.png')

local dialogtext <const> = Graphics.image.new(260,80)

local video = nil
local videoActive = false
local dialogcounter = 1
local dialogPosition = nil
dialogBG = {}

class('dialogBG').extends(Graphics.sprite)

function dialogBG:init()
	self:setImage(dialogbox)
	self:setZIndex(ZIndex.alert)
	self:setCenter(0,0)
	self:moveTo(0,138)
	
end

dialogScreen = {}
class("dialogScreen").extends(Graphics.sprite)

function dialogScreen:init(position)
	self:setZIndex(ZIndex.alert+1)
	self:moveTo( 20, 170)
	self:setCenter(0,0)
	dialogbg = dialogBG()
end

function dialogScreen:addScreen(scriptPosition)
	dialogPosition = scriptPosition
	self:nextDialog()
end
function dialogScreen:nextDialog()
	dialogbg:add()
	self:setImage(dialogtext)
	if dialogcounter <= table.getSize(script[dialogPosition].dialog)then
		if videoActive == false then
			video = videoFeed(400,240,ZIndex.alert)
			videoActive = true
		end
		dialogtext:clear(Graphics.kColorClear)
		Graphics.pushContext(dialogtext)
			Graphics.drawTextInRect(script[dialogPosition].dialog[dialogcounter].text, 0, 0, 255, 78)
		Graphics.popContext()
		
		self:add()
		dialogcounter += 1
	else
		dialogcounter = 1
		self:removeAll()
	end
end
function dialogScreen:removeAll()
	PlayerData.isTalking = false
	videoActive = false
	dialogbg:remove()
	video:remove()
	self:remove()
end