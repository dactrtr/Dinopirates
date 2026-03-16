function Player:sanityCheck()

  local function checkSanity()
    local lastSanity = PlayerData.sanity
    if PlayerData.battery < Config.Sanity.batteryThresholdLow and PlayerData.isInDarkness == true then
      PlayerData.sanity -= Config.Sanity.lossLowBattery * self.sanityLoss
    elseif PlayerData.battery < Config.Sanity.batteryThresholdMid and PlayerData.isInDarkness == true then
      PlayerData.sanity -= Config.Sanity.lossMidBattery * self.sanityLoss
    end

    -- Check if sanity just reached zero
    if PlayerData.sanity <= 0 and lastSanity > 0 then
      PlayerData.sanityCounter += 1
      PlayerData.sanity = 0
      -- Performance: Check achievements only when sanity counter changes
      Utilities.checkSanityAchievements()
    end

    if PlayerData.battery > Config.Sanity.batteryThresholdHigh or PlayerData.isInDarkness == false then
      PlayerData.sanity += Config.Sanity.gainHighBattery * self.sanityLoss
    end

    if PlayerData.sanity >= 100 then
      PlayerData.sanity = 100
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
  if PlayerData.battery < 100 then
    self.animation:setState('charge')
  elseif PlayerData.battery >= 100 then
    self:idle()
  end
  PlayerData.battery += amount
  PlayerData.isActive = true
end

function Player:fillBattery()
    PlayerData.battery = 100
end
