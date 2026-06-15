local DRAIN_BATTERY_ON_WALK = false

function Player:move(direction)
  if PlayerData.isGaming == true then
    -- Don't allow normal movement while sliding, plunging, in flight, or being pulled
    if self.isSliding or self.isPlunging or self.isGrapplePulling or self.isGrappling then
      return
    end
    
    if self.isAlive == true and PlayerData.isCharging == false then
      PlayerData.isActive = true
      self.direction = direction
      -- If the player presses a direction while on slime after hitting a wall,
      -- allow a new slide in this direction on the next frame.
      self.slideHitWall = false
      local movementX = 0
      local movementY = 0
      
      -- Drain battery in darkness
      if PlayerData.isInDarkness == true then
        self:drainBattery(Config.Battery.drainMovementDark)
      end

      -- Drain battery with DWatch while walking
      if DRAIN_BATTERY_ON_WALK and PlayerData.items.hasDWatch == true then
        self:drainBattery(Config.Battery.drainDWatchWalk)
      end
      if (direction == "left") then
        if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false then
          self.animation:setState('lampLeft')
        elseif PlayerData.isTiny == true then
            self.animation:setState('tinyLeft')
        else
          self.animation:setState('left')
        end
        movementX = self.x - self.speed
        movementY = self.y
      elseif (direction == "right") then
        if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false then
          self.animation:setState('lampRight')
        elseif PlayerData.isTiny == true then
          self.animation:setState('tinyRight')
        else
          self.animation:setState('right')
        end
        movementX = self.x + self.speed
        movementY = self.y
      elseif (direction == "up") then
        if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false then
          self.animation:setState('up')
        elseif PlayerData.isTiny == true then
          self.animation:setState('tinyUp')
        else
          self.animation:setState('up')
        end
        movementX = self.x 
        movementY = self.y - self.speed
      elseif (direction == "down") then
        if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and  PlayerData.isTiny == false then
          self.animation:setState('lampDown')
        elseif PlayerData.isTiny == true then
          self.animation:setState('tinyDown')
        else
          self.animation:setState('down')
        end 
        movementX = self.x
        movementY = self.y + self.speed
      end

      -- Plungerang is out (lost to a crew, so the player can walk): override the walk
      -- animation with the noLeg pose so it persists until the boomerang returns. Track the
      -- facing on horizontal moves; vertical moves keep the last facing.
      if self.hasProjectile == false and PlayerData.isTiny == false then
        if direction == 'left' then self.shootDir = 'left'
        elseif direction == 'right' then self.shootDir = 'right' end
        self.animation:setState(self.shootDir == 'left' and 'noLegLeft' or 'noLegRight')
      end

      self.uiHud:moveTo(movementX + self.playerUIX, movementY - self.playerUIY)
      
      local actualX, actualY, collisions, lenght = self:moveWithCollisions(movementX, movementY )
      -- Distribute movement frames to NPCs (capped at 90 frames to prevent accumulation)
      self:distributeMovementFrames(Config.Player.movementFramesPerAction)
      PlayerData.direction = direction
      self:pedometer()
    end
  end
end
