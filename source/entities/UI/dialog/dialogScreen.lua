import "entities/UI/dialog/videoFeed"

local dialogbox <const> = Graphics.image.new('assets/images/ui/dialog/dialogbox.png')

local dialogtext <const> = Graphics.image.new(250, 64)
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
	self:moveTo( 16, 165)
	self:setCenter(0,0)
	dialogbg = dialogBG()
	screenimg = imageScreen()
end



function dialogScreen:addScreen(scriptName)
	-- Buscar el diálogo por nombre
	for i, scriptEntry in ipairs(script) do
		if scriptEntry.name == scriptName then
			dialogPosition = i
			PlayerData.isTalking = true
			self:nextDialog()
			return
		end
	end

	-- Not found: don't leave isTalking stuck true (the caller usually sets it before
	-- calling addScreen) — a bad/missing name must not soft-lock input on the next A-press.
	printDebug("⚠️ Warning: Dialog '" .. tostring(scriptName) .. "' not found")
	PlayerData.isTalking = false
	PlayerData.isGaming = true
end
function dialogScreen:nextDialog()
	local entry = script[dialogPosition]
	if not entry then
		-- Defensive: dialogPosition is nil/stale (e.g. a prior addScreen() with a bad
		-- name left state inconsistent). Close cleanly instead of crashing on `.dialog`.
		printDebug("⚠️ dialogScreen:nextDialog with no active dialog (dialogPosition=" .. tostring(dialogPosition) .. ")")
		self:removeAll()
		return
	end
	dialogbg:add()
	local dialogArray = entry.dialog
	if video ~= nil then
		video:remove()
	end
	self:setImage(dialogtext)
	if table.getsize(dialogArray) ~= nil then
		
		if dialogcounter <= table.getsize(dialogArray)then
			if videoActive == false then
				local videoState = dialogArray[dialogcounter].video
				if PlayerData.isTiny == true then
					-- Check if a tiny version of this state exists, otherwise fallback to 'tiny'
					video = videoFeed(400,240,videoState .. '-tiny', ZIndex.alert)
				else	
					video = videoFeed(400,240,videoState, ZIndex.alert)
				end
				videoActive = true
			end
			
			if dialogArray[dialogcounter].screen  then
				screenimg:addScreenfeed(dialogArray[dialogcounter].screen)
			else
				screenimg:remove()
			end
			
			local lang = Panels.vars.lang
			local shinonome = Graphics.font.new('assets/fonts/KH-Dot-Akihabara-16')
			Graphics.setFont(shinonome, 'normal')
			dialogtext:clear(Graphics.kColorClear)
			Graphics.pushContext(dialogtext)
				local textString = Graphics.getLocalizedText(script[dialogPosition].dialog[dialogcounter].text, lang)
				Graphics.drawTextInRect(textString, 0, 0, dialogtext.width, dialogtext.height)
			Graphics.popContext()
			
			self:add()
			dialogcounter += 1
			videoActive = false
		else
			dialogcounter = 1
			self:removeAll()
		end
	end
end

function dialogScreen:removeAll()
	PlayerData.isTalking = false
	PlayerData.isGaming = true
	videoActive = false
	if dialogbg ~= nil then dialogbg:remove() end
	if video ~= nil then video:remove() end
	if screenimg ~= nil then screenimg:remove() end
	self:remove()
end