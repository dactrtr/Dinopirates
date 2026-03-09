
skillInfo = {}
class("skillInfo").extends(NobleSprite)

function skillInfo:init(__item,__zindex)
	skillInfo.super.init(self,'assets/images/ui/menu/skillinfo', true)
	self.item = __item
	
	self.animation:addState('plunder',1,1)
	self.animation:addState('dash',2,2)
	self.animation:addState('flash',3,3)
	-- 'equipped' is a special mode; skip setState until update() resolves it
	if __item ~= 'equipped' then
		self.animation:setState(__item)
	end
	self:setZIndex(__zindex)
	self:setSize(145, 42)
	self:setCenter(0,0)
end

function skillInfo:update()
	local active = PlayerData.activeItem
	if self.item == 'equipped' then
		-- Muestra el banner del item que esté activo en ese momento
		if active == 1 then
			self.animation:setState('flash')
		elseif active == 2 then
			self.animation:setState('dash')
		elseif active == 3 then
			self.animation:setState('plunder')
		end
	elseif self.item == "lamp" then
		if active == 1 then self.animation:setState('flash') end
	elseif self.item == "boot" then
		if active == 2 then self.animation:setState('dash') end
	elseif self.item == "plunger" then
		if active == 3 then self.animation:setState('plunder') end
	end
end

function skillInfo:show(__x,__y)
	self:add(__x,__y)
end