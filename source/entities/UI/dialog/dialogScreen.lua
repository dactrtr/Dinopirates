import "entities/UI/dialog/videoFeed"

local dialogbox <const> = Graphics.image.new('assets/images/ui/dialog/dialogbox.png')

-- Loaded once, here, for the same reason dialogbox is: this .fnt is 264KB, and it used to be
-- re-read from disk inside nextDialog() on EVERY dialog line, which is what made each line
-- hitch.
local dialogFont <const> = Graphics.font.new('assets/fonts/KH-Dot-Akihabara-16')

local dialogtext <const> = Graphics.image.new(250, 64)
local screen <const> = Graphics.image.new(277,146)
-- Built on first use and then reused for the rest of the game. Constructing a videoFeed
-- reloads a 26-frame, 58KB imagetable from disk (Noble.Animation.new has no cache), so
-- rebuilding it per line was the other half of the hitch.
local video = nil
local screenImg = nil
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
	self:setImage(dialogtext)
	if table.getsize(dialogArray) ~= nil then

		if dialogcounter <= table.getsize(dialogArray)then
			local videoState = dialogArray[dialogcounter].video
			if PlayerData.isTiny == true then
				videoState = videoState .. '-tiny'
			end
			-- Build once, then just switch state. Every face -- including the '-tiny'
			-- variants -- is already registered on this one animation object, so changing
			-- portrait costs nothing and never touches the disk.
			if video == nil then
				video = videoFeed(400, 240, videoState, ZIndex.alert)
			else
				video.animation:setState(videoState)
				video:add(400, 240)
			end

			if dialogArray[dialogcounter].screen  then
				screenimg:addScreenfeed(dialogArray[dialogcounter].screen)
			else
				screenimg:remove()
			end

			local lang = Panels.vars.lang
			dialogtext:clear(Graphics.kColorClear)
			Graphics.pushContext(dialogtext)
				-- setFont inside the context: popContext restores the previous font, so the
				-- global default set in main.lua survives. It used to be set globally here
				-- and never restored, so every text drawn after the first dialog of a
				-- playthrough silently switched typeface.
				Graphics.setFont(dialogFont, 'normal')
				local textString = Graphics.getLocalizedText(script[dialogPosition].dialog[dialogcounter].text, lang)
				Graphics.drawTextInRect(textString, 0, 0, dialogtext.width, dialogtext.height)
			Graphics.popContext()

			self:add()
			dialogcounter += 1
		else
			dialogcounter = 1
			self:removeAll()
		end
	end
end

function dialogScreen:removeAll()
	PlayerData.isTalking = false
	PlayerData.isGaming = true
	-- `video` is only removed from the scene, never nil'd: keeping the object alive is what
	-- lets the next dialog reuse it instead of reloading its imagetable.
	if dialogbg ~= nil then dialogbg:remove() end
	if video ~= nil then video:remove() end
	if screenimg ~= nil then screenimg:remove() end
	self:remove()
end