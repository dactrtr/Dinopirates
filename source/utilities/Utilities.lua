-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

class('Box').extends(playdate.graphics.sprite)

function Utilities.getZero()
	return 0
end

-- mark: Draw collider boxes (walls)

function Box:init(x, y, width, height) 
	Graphics.setColor(playdate.graphics.kColorWhite)
	Graphics.fillRect(x, y, width, height)
	Graphics.drawRect(x, y, width, height)
	self:setSize(width, height)
	self:moveTo(x, y)
	self:setCenter(0,0)
	self:addSprite()
	self:setCollideRect(0,0,width,height)
	self:setGroups(CollideGroups.wall)
end


-- MARK: Cheat codes

local keys = {
	a = playdate.kButtonA,
	b = playdate.kButtonB,
	up = playdate.kButtonUp,
	down = playdate.kButtonDown,
	left = playdate.kButtonLeft,
	right = playdate.kButtonRight,
}

-- Mark: Cheatcodes
class("CheatCode").extends()

function CheatCode: init(...)
	local seq = {}
	for _, key in ipairs({...}) do
		local v = keys[key]
		assert(v, "CheatCode: unkwnown key given => "..tostring(key))
		table.insert(seq, v)
	end
	self._seq= seq
	self.progress = 1
	self.run_once = false
	self:setTimerDelay(400)
end

function CheatCode:update()
	if self.run_once and self.completed then return end
	
	local _, pressed, _= playdate.getButtonState()
	
	if pressed == 0 then return end
	
	if pressed == self._seq[self.progress] then
		self.progress += 1
		self._timer:reset()
	
		if self.progress > #self._seq then
		  self.completed = true
		  if type(self.onComplete) == "function" then
			self.onComplete()
		  end
		end
	  else
		self:reset()
	  end
end

function CheatCode:reset()
	self.progress = 1
	self._timer:reset()
	self._timer:pause()
end

function CheatCode:setTimerDelay(ms)
  if self._timer then
	self._timer:remove()
  end
  self._timer = playdate.timer.new(ms, function() self:reset() end)
  self._timer:pause()
  self._timer.discardOnCompletion = false
end

function CheatCode:nextIs(key)
  return keys[key] == self._seq[self.progress]
end

function RandomScreen(axis)
	if axis == "x" then
		return math.random(20,380)
	elseif axis == "y" then
		return math.random(20,220)
	end
end

function checkBool(bool)
	local string
	if bool == true then
		print('true')
	elseif (bool == false) then
		print('false')
	end
end
function RoomTranslate(roomNumber)
	local floorClass = "Floor" .. roomNumber
	return _G[floorClass]
end
function SaveGame()
	playdate.datastore.write(levels, 'levelSave', true)
	playdate.datastore.write(PlayerData, 'playerSave', true)
end
function LoadGame()
	PlayerData = playdate.datastore.read('playerSave')
	levels = playdate.datastore.read('levelSave')
end
function ResetGame()
	PlayerData = json.decodeFile('playerOriginal.json')
	levels = playdate.datastore.read('levelOriginal')
end
function DeleteGame()
	playdate.file.delete('playerSave.json')
	playdate.file.delete('levelSave.json')
	playdate.file.delete('playerOriginal.json')
end