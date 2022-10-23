-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

class('Box').extends(playdate.graphics.sprite)

function Utilities.getZero()
	return 0
end

function Box:draw(x, y, width, height) --move this to a utility
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
	block:setGroups(1)
end