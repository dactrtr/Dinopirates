local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ToastBar').extends(gfx.sprite)

local fullToast = gfx.image.new("images/toast/full.png")
local quarterToast = gfx.image.new("images/toast/quarter.png")
local halfToast = gfx.image.new("images/toast/half.png")
local noToast = gfx.image.new("images/toast/none.png")

function ToastBar:init(toasts)
	self:moveTo(14, 92)
	self:setImage(fullToast)
	self.toasts = toasts
	self:add()
end

function ToastBar:update()
	if self.toasts == 3 then 
		self:setImage(quarterToast)
	end
	if self.toasts == 2 then 
		self:setImage(halfToast)
	end
	if self.toasts == 1 then 
		self:setImage(noToast)
	end
end