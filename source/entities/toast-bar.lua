
class('ToastBar').extends(Graphics.sprite)

local fullToast = Graphics.image.new("assets/images/toast/full.png")
local quarterToast = Graphics.image.new("assets/images/toast/quarter.png")
local halfToast = Graphics.image.new("assets/images/toast/half.png")
local noToast = Graphics.image.new("assets/images/toast/none.png")

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