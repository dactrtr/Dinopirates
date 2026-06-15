function Player:sanityCheck()

  local function checkSanity()
    local lastSanity = PlayerData.sanity
    local hasLamp = PlayerData.items.hasLamp == true
    local dark = PlayerData.isInDarkness == true
    -- Sanity drains in the dark. With no lamp at all it's total darkness, so you lose
    -- your mind regardless of battery; with a lamp it depends on the charge level.
    if dark and not hasLamp then
      PlayerData.sanity -= Config.Sanity.lossLowBattery * self.sanityLoss
    elseif dark and PlayerData.battery < Config.Sanity.batteryThresholdLow then
      PlayerData.sanity -= Config.Sanity.lossLowBattery * self.sanityLoss
    elseif dark and PlayerData.battery < Config.Sanity.batteryThresholdMid then
      PlayerData.sanity -= Config.Sanity.lossMidBattery * self.sanityLoss
    end

    -- Sanity just reached zero → game over. sanityCounter is preserved (keeps scaling
    -- difficulty and enabling the room-repeat rule).
    if PlayerData.sanity <= 0 and lastSanity > 0 then
      PlayerData.sanityCounter += 1
      PlayerData.sanity = 0
      Utilities.checkSanityAchievements()
      if self.isAlive and PlayerData.isGaming == true then
        self:dead("sanity")
      end
    end

    -- Recover only in the light, or in the dark while the lamp is well charged. A
    -- lampless player can't restore sanity by cranking battery in the dark.
    if not dark or (hasLamp and PlayerData.battery > Config.Sanity.batteryThresholdHigh) then
      PlayerData.sanity += Config.Sanity.gainHighBattery * self.sanityLoss
    end

    if PlayerData.sanity >= Config.Sanity.max then
      PlayerData.sanity = Config.Sanity.max
    end
    
    if PlayerData.sanity <= 0 then
      PlayerData.sanity = 0
    end

    -- Update lastSanity for the next check
    lastSanity = PlayerData.sanity
  end

  playdate.timer.keyRepeatTimerWithDelay(Config.Sanity.tickInterval, Config.Sanity.tickInterval, checkSanity)
end

function Player:drainBattery(amount)
  PlayerData.battery -= amount
end

function Player:chargeBattery(amount)
  if PlayerData.rechargeBlocked then return end
  if self:isOnHole() then return end  -- can't recharge while crossing a hole
  if PlayerData.battery < Config.Battery.max then
    self.animation:setState('charge')
  elseif PlayerData.battery >= Config.Battery.max then
    self:idle()
  end
  PlayerData.battery += amount
  PlayerData.isActive = true
end

function Player:fillBattery()
    PlayerData.battery = Config.Battery.max
end
