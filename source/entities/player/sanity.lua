-- Single global sanity ticker. Driven by ONE persistent timer created at boot
-- (main.lua), not one per Player. The old Player:sanityCheck() created a
-- keyRepeatTimerWithDelay inside every Player:init and never removed it (no stored
-- handle, no remove()); since a fresh Player is built on every room entry
-- (MazeScene.lua) and Noble ticks all SDK timers globally each frame (Noble.lua),
-- after visiting N rooms there were N timers all draining PlayerData.sanity in
-- parallel (N×). This function targets the live player via the global CurrentPlayer
-- (set in Player:init) and is a no-op before any player exists. sanityLoss is a
-- constant (Config.Sanity.baseLoss), so it no longer needs a per-instance field.
function checkSanityGlobal()
  local p = CurrentPlayer
  if not p then return end

  local lastSanity = PlayerData.sanity
  local hasLamp = PlayerData.items.hasLamp == true
  local dark = PlayerData.isInDarkness == true
  local sanityLoss = Config.Sanity.baseLoss
  -- Sanity drains in the dark. With no lamp at all it's total darkness, so you lose
  -- your mind regardless of battery; with a lamp it depends on the charge level.
  if dark and not hasLamp then
    PlayerData.sanity -= Config.Sanity.lossLowBattery * sanityLoss
  elseif dark and PlayerData.battery < Config.Sanity.batteryThresholdLow then
    PlayerData.sanity -= Config.Sanity.lossLowBattery * sanityLoss
  elseif dark and PlayerData.battery < Config.Sanity.batteryThresholdMid then
    PlayerData.sanity -= Config.Sanity.lossMidBattery * sanityLoss
  end

  -- Sanity just reached zero → game over. sanityCounter is preserved (keeps scaling
  -- difficulty and enabling the room-repeat rule).
  if PlayerData.sanity <= 0 and lastSanity > 0 then
    PlayerData.sanityCounter += 1
    PlayerData.sanity = 0
    Utilities.checkSanityAchievements()
    if p.isAlive and PlayerData.isGaming == true then
      p:dead("sanity")
    end
  end

  -- Recover only in the light, or in the dark while the lamp is well charged. A
  -- lampless player can't restore sanity by cranking battery in the dark.
  if not dark or (hasLamp and PlayerData.battery > Config.Sanity.batteryThresholdHigh) then
    PlayerData.sanity += Config.Sanity.gainHighBattery * sanityLoss
  end

  if PlayerData.sanity >= Config.Sanity.max then
    PlayerData.sanity = Config.Sanity.max
  end

  if PlayerData.sanity <= 0 then
    PlayerData.sanity = 0
  end
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
