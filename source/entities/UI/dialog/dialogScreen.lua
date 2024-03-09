


import "entities/UI/dialog/videoFeed"

local dialogbox <const> = Graphics.image.new('assets/images/ui/dialog/dialogbox.png')

local dialogtext <const> = Graphics.image.new(260,80)
local screen <const> = Graphics.image.new(277,146)
local video = nil
local screenImg = nil
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

imageScreen = {}
class("imageScreen").extends(Graphics.sprite)

function imageScreen:init()
	self:setZIndex(ZIndex.alert+1)
	self:moveTo( 50, 4)
	self:setCenter(0,0)
end
function imageScreen:addScreenfeed(screen)
	self:setImage(screen)
	self:add()
end

dialogScreen = {}
class("dialogScreen").extends(Graphics.sprite)

function dialogScreen:init(position)
	self:setZIndex(ZIndex.alert+1)
	self:moveTo( 20, 170)
	self:setCenter(0,0)
	dialogbg = dialogBG()
	screenimg = imageScreen()
end



function dialogScreen:addScreen(scriptPosition)
	dialogPosition = scriptPosition
	self:nextDialog()
end
function dialogScreen:nextDialog()
	dialogbg:add()
	local dialogArray = script[dialogPosition].dialog
	if video ~= nil then
		video:remove()
	end
	self:setImage(dialogtext)
	if dialogcounter <= table.getSize(dialogArray)then
		if videoActive == false then
			video = videoFeed(400,240,dialogArray[dialogcounter].video, ZIndex.alert)
			videoActive = true
		end
		
		if dialogArray[dialogcounter].screen  then
			screenimg:addScreenfeed(dialogArray[dialogcounter].screen)
		else
			screenimg:remove()
		end
		
		dialogtext:clear(Graphics.kColorClear)
		Graphics.pushContext(dialogtext)
			Graphics.drawTextInRect(script[dialogPosition].dialog[dialogcounter].text, 0, 0, 255, 78)
		Graphics.popContext()
		
		self:add()
		dialogcounter += 1
		videoActive = false
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
	screenimg:remove()
	self:remove()
end