
itemMenu = {}
class("itemMenu").extends(NobleSprite)

function itemMenu:init(__item,__zindex)
	itemMenu.super.init(self,'assets/images/ui/menu/menuitems', true)
	self.item = __item
	
	self.animation:addState('lamp',5,5)
	self.animation:addState('lampSelected',6,6)
	self.animation:addState('boot',3,3)
	self.animation:addState('bootSelected',4,4)
	self.animation:addState('plunger',1,1) -- Placeholder frames
	self.animation:addState('plungerSelected',2,2) -- Placeholder frames
	self.animation:setState(__item)
	self:setZIndex(__zindex)
	self:setSize(32, 32)
	self:setCenter(0,0)
	
end
function itemMenu:update()
	if self.item == "lamp" then
		if PlayerData.activeItem == 1 then
			self.animation:setState('lampSelected')
		else
			self.animation:setState('lamp')
		end
	elseif self.item == "boot" then
		if PlayerData.activeItem == 2 then
			self.animation:setState('bootSelected')
		else
			self.animation:setState('boot')
		end
	elseif self.item == "plunger" then
		if PlayerData.activeItem == 3 then
			self.animation:setState('plungerSelected')
		else
			self.animation:setState('plunger')
		end
	end
end
function itemMenu:show(__x,__y)
	self:add(__x,__y)
end