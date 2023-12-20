-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

class('Box').extends(playdate.graphics.sprite)

function Utilities.getZero()
	return 0
end

-- mark: Draw collider boxes (walls)

function Box:draw(x, y, width, height) 
	cx, cy, width, height = self:getCollideBounds()
	Graphics.setColor(playdate.graphics.kColorWhite)
	Graphics.fillRect(cx, cy, width, height)
	Graphics.drawRect(cx, cy, width, height)
end

function addBlock(x,y,w,h)
	block = Box()
	block:setSize(w, h)
	block:moveTo(x, y)
	block:setCenter(0,0)
	block:addSprite()
	block:setCollideRect(0,0,w,h)
	block:setGroups(CollideGroups.wall)
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

function debugScreen()
	if debug then
		textOverlay = Graphics.image.new(400,240)
		Graphics.lockFocus(textOverlay)
		Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
		Graphics.drawText("デバッグモード!!", 2, 0, playdate.graphics.font.kLanguageJapanese)
		Graphics.drawText("Energy: " .. ship.energy .. " /Speed: " .. ship.speed .. " /Position: " .. ship.width .. " " .. ship.y, 2, 20)
		Graphics.drawText("crank: " .. playdate.getCrankChange(), 2, 40)
		if playdate.accelerometerIsRunning() then
			accelStatus = "true"
			accelDataX , accelDataY, accelDataZ = playdate.readAccelerometer()
			
			Graphics.drawText("Accelerometer: " .. accelStatus, 2, 60)
			Graphics.drawText("AccelerometerX: " .. accelDataX, 2, 80)
			Graphics.drawText("AccelerometerY: " .. accelDataY, 2, 100)
			Graphics.drawText("AccelerometerZ: " .. accelDataZ, 2, 120)
		else
			Graphics.drawText("Accelerometer: " .. "false", 2, 60)
		end
		Graphics.unlockFocus()
		textOverlay:draw(0,0)
	end
end

function debugScreenMaze(player)
	local Xpos = 40
	local Ypos = 4
	if debug then
		if player.isAlive then
			status = "Alive"
		else
			status = "Dead"
		end
		textOverlay = Graphics.image.new(400,240)
		Graphics.lockFocus(textOverlay)
			Graphics.setColor(Graphics.kColorBlack)
			Graphics.fillRect(0, 0, 280,40)
		Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
		Graphics.drawText("デバッグモード!!", 2, 1, playdate.graphics.font.kLanguageJapanese)
		Graphics.drawText("Battery level: " .. player.battery .. " / Status: " .. status , 2, (Ypos+16))
		
		Graphics.unlockFocus()
		textOverlay:draw(Xpos,Ypos)
	end
end

