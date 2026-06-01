playerHud = {}
class("playerHud").extends(NobleSprite)

import "entities/UI/battery"
import "entities/UI/keyHud"
import "entities/UI/sanityHud"
import "entities/UI/healthIndicator"

local batteryIndicator = nil
local keyIndicator = nil
local sanityIndicator = nil
local healthIndicator = nil

-- local background <const> = Graphics.image.new('assets/images/ui/statusbar.png')

function playerHud:init(player)	
	playerHud.super.init(self,'assets/images/ui/UIHud', true)
	self.player = player
	
	-- Mark: animation states
	local frameduration = 12
	self.animation:addState('sanity100', 1, 1)
	self.animation.sanity100.frameDuration =  frameduration
	self.animation:addState('sanity80', 3, 4)
	self.animation.sanity80.frameDuration = frameduration
	self.animation:addState('sanity60', 5, 6)
	self.animation.sanity60.frameDuration = frameduration
	self.animation:addState('sanity40', 7, 9)
	self.animation.sanity40.frameDuration = frameduration
	self.animation:addState('sanity20', 10, 11)
	self.animation.sanity20.frameDuration = frameduration
	self.animation:addState('sanity0', 12, 13)
	self.animation.sanity0.frameDuration = frameduration
	self.animation.sanity20.frameDuration = frameduration
	self.animation:addState('flash', 14, 15)
	self.animation.flash.frameDuration = 4
	self.animation:setState('sanity100')
	
	self:setSize(35,15)
	self:setCenter(0.5, 0.5)
	self:setZIndex(ZIndex.hud)
	
	local x = 0
	local y = 0
	if player then
		x = player.x
		local yOffset = -36
		if PlayerData.isTiny then
			yOffset = -22
		end
		y = player.y + yOffset
	end
	
	self:moveTo(x, y)
	
	self.batteryIndicator = Battery(x,y, player, ZIndex.hud+1)
	self.healthIndicator = HealthIndicator(x, y, player, ZIndex.hud+2)
	self:add()
end

function playerHud:update()
	if self.player then
		local tx = self.player.x
		local yOffset = -36
		if PlayerData.isTiny then
			yOffset = -22
		end
		local ty = self.player.y + yOffset

		local wx, wy = 0, 0
		if self.player.isDarkCharging and math.abs(playdate.getCrankChange()) > 0
			and self.player.darkCrankAccum < Config.DarkReveal.crankThreshold then
			wx = math.random(-2, 2)
			wy = math.random(-2, 2)
		end

		self:moveTo(tx + wx, ty + wy)

		if self.batteryIndicator then
			self.batteryIndicator:moveTo(tx + wx, ty - 3 + wy)
		end

		if self.healthIndicator then
			self.healthIndicator:moveTo(tx + wx, ty + wy)
		end
	end

	local hasDWatch = PlayerData.items.hasDWatch
	if hasDWatch then
		self:setVisible(true)
		if self.batteryIndicator then self.batteryIndicator:setVisible(true) end
		if self.healthIndicator then self.healthIndicator:setVisible(true) end

		if self.player.isDarkCharging and self.player.darkCrankAccum >= Config.DarkReveal.crankThreshold then
			self.animation:setState('flash')
		else
			local sanity = PlayerData.sanity
			if sanity > 80 then
				self.animation:setState('sanity100')
			elseif sanity > 60 then
				self.animation:setState('sanity80')
			elseif sanity > 40 then
				self.animation:setState('sanity60')
			elseif sanity > 20 then
				self.animation:setState('sanity40')
			elseif sanity > 0 then
				self.animation:setState('sanity20')
			else
				self.animation:setState('sanity0')
			end
		end
	else
		self:setVisible(false)
		if self.batteryIndicator then self.batteryIndicator:setVisible(false) end
		if self.healthIndicator then self.healthIndicator:setVisible(false) end
	end
end

function playerHud:removeAll()
	if self.batteryIndicator then
		self.batteryIndicator:remove()
	end
	if self.healthIndicator then
		self.healthIndicator:remove()
	end
	self:remove()
end

