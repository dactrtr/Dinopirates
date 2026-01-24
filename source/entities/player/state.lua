function Player:fallBelow()
  print("💀 Player falling...")

  local currentRoomIndex = PlayerData.floor  -- Current index in levelsLDTK
  local lowerRoomNumber, lowerRoomData = GetLowerRoom(currentRoomIndex)

  if not lowerRoomNumber then
    print("⚠️  Cannot fall from this room")
    -- Optional: show message to player
    return
  end

  local nextScene = RoomTranslate(lowerRoomNumber)

  if nextScene then
    -- Keep X and Y position when falling
    PlayerData.playerSpawn.x = self.x
    PlayerData.playerSpawn.y = self.y

    print("✅ Transitioning to room:", lowerRoomNumber)

    Noble.transition(nextScene, 1.5, Noble.Transition.Imagetable, {
      imagetableEnter = Graphics.imagetable.new('assets/images/screens/transitions/transitionFallEnter'),
      imagetableExit = Graphics.imagetable.new('assets/images/screens/transitions/transitionFallOut'),
    })
  else
    print("❌ Scene Floor" .. lowerRoomNumber .. " not found")
    -- Fallback: Player fell into the void, transition to DeadScene
    print("💀 Transitioning to DeadScene (fell into void)")
    Noble.transition(DeadScene, 1.5, Noble.Transition.Default)
  end
end

function Player:riseAbove()
  print("🚀 Player climbing...")

  local currentRoomIndex = PlayerData.floor
  local upperRoomNumber, upperRoomData = GetUpperRoom(currentRoomIndex)

  if not upperRoomNumber then
    print("⚠️  Cannot climb from this room")
    return
  end

  local nextScene = RoomTranslate(upperRoomNumber)

  if nextScene then
    PlayerData.playerSpawn.x = self.x
    PlayerData.playerSpawn.y = self.y

    print("✅ Transitioning to room:", upperRoomNumber)

    Noble.transition(nextScene, 1.5, Noble.Transition.Default)
  else
    print("❌ Scene Floor" .. upperRoomNumber .. " not found")
    print("⚠️  Cannot climb higher (no upper room)")
    -- Do nothing, player stays in current room
  end
end

function Player:displayDialog()
  self.dialogUI:nextDialog()
end

function Player:transformCycle()
    self.animation:setState('transformCycle')
end

function Player:startInvincibility(duration)
    self.isInvincible = true
    self.invincibilityTimer = duration
end

function Player:idle()
  if self.isAlive == true then
    if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true then
      self.animation:setState('lampIdle')
    else
      self.animation:setState('idle')
    end
    
    if PlayerData.isTiny == true then
      self.animation:setState('tinyIdle')
    end
    
    PlayerData.direction = 'idle'
  end
end

function Player:fight()
  PlayerData.amountDances += 1
  Noble.transition(DanceScene)
end

function Player:dead() -- unused
  self.isAlive = false
  local function deathScreen()

    Noble.transition(DeadScene)

  end
  playdate.timer.performAfterDelay(1000, deathScreen)
end

function Player:focus() -- unused
  if PlayerData.sanity > 20 then
    PlayerData.sanity -= 20
    PlayerData.isFocused = true
  end
end

function Player:shrink()
  PlayerData.isTiny = true
  self:setCollideRect(17, 32, 14, 14)
  self.animation:setState('transformTo')
end

function Player:grow()
    PlayerData.isTiny = false
    self:setCollideRect(8, 24, 30, 24)
    self:idle()
end

function Player:startMinifying()
    if not self.currentMinifier or PlayerData.isTalking or not PlayerData.isGaming then return end

    -- Lock player and center
    PlayerData.isGaming = false
    self.triggerEnteredOnce = true -- Stop trigger checks
    
    -- Auto center on minifier
    local targetX = self.currentMinifier.x
    local targetY = self.currentMinifier.y
    self:moveTo(targetX, targetY)
    if shadow then shadow:moveTo(targetX, targetY) end

    -- Show crank prompt
    if not PlayerData.isTiny then
        self.uiHud:setCrankAntiClock()
    else
        self.uiHud:setCrankClock()
    end
    self:showUIHUD()

    -- Reset progress (size goes from playerSize to 0 or vice versa)
    PlayerData.actualPlayerSize = PlayerData.isTiny and 0 or PlayerData.playerSize
end

function Player:finishMinifying()
    PlayerData.isGaming = true
    self.triggerEnteredOnce = false
    self.uiHud:setVisible(false)
end
function Player:pedometer()
  PlayerData.steps += 0.5
  PlayerData.totalSteps += 0.5
  if PlayerData.steps >= 200 then
    PlayerData.steps = 0
    self:burnCalories(10)
  end
end
function Player:burnCalories(calories)
    PlayerData.calories -= calories
end

function Player:deFocus() -- unused
  if PlayerData.isFocused == true then
    PlayerData.isFocused = false
  end
end
function Player:showUIHUD()
  -- Base position above the player
  local hudX = self.x + self.playerUIX
  local hudY = self.y - 40 -- normal default above player

  -- Adjust for top of screen
  if self.y < 60 then
    hudY = self.y + self.playerUIY / 2 -- move down instead of above
  end

  -- Adjust for right edge
  if self.x > 350 then
      hudX = self.x - self.playerUIX -- move to left of player
  end

  self.uiHud:moveTo(hudX, hudY)
  self.uiHud:setVisible(true)
end

function Player:checkMinifier()
    if self.currentMinifier then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentMinifier then
                stillInside = true
                break
            end
        end

        if not stillInside then
            self.uiHud:setVisible(false)
            self.currentMinifier = nil
            PlayerData.readyToShrink = false
        end
    end
end

function Player:checkTrigger()
    -- Check for dialog activation (A button)
    if self.currentTrigger and playdate.buttonJustPressed(playdate.kButtonA) then
        local trigger = self.currentTrigger

        PlayerData.isGaming = false
        PlayerData.isTalking = true
        self.dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)

        Utilities.grantAchievementIfNeeded(trigger.script)
    end

    -- Performance: Only check overlapping sprites if player moved significantly
    local distanceMoved = math.abs(self.x - self.lastCheckX) + math.abs(self.y - self.lastCheckY)
    local shouldCheckOverlap = distanceMoved > 5 or self.currentTrigger ~= nil

    if shouldCheckOverlap then
      self.lastCheckX = self.x
      self.lastCheckY = self.y

      if self.currentTrigger then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentTrigger then
              stillInside = true

              self:showUIHUD()

              -- Solo se activa una vez cuando el jugador entra en el trigger
              if not self.triggerEnteredOnce then
                if self.currentTrigger.type == "Call" then
                  self.uiHud:setRing()
                elseif self.currentTrigger.type == "Search" then
                  self.uiHud:setInvestigate()
                elseif self.currentTrigger.type == nil then
                  self.uiHud:setPressA()
                end
                self.triggerEnteredOnce = true -- Marca que ya se ejecutó
              end

              break
            end
          end

          if not stillInside then
              self.uiHud:setVisible(false)
              self.currentTrigger = nil
              self.triggerEnteredOnce = false -- Reset para el próximo trigger
          end
      end
    end
end

function Player:update()
  -- Update dash movement if dashing
  self:updateDash()
  
  -- Update sliding movement if on slime
  self:updateSliding()

  -- Hide light cone after display time
  if self.lightConeHideTime and playdate.getCurrentTimeMilliseconds() >= self.lightConeHideTime then
    PlayerData.showLightCone = false
    self.lightConeHideTime = nil
  end

  self:setZIndex(self.y)

  self:checkTrigger()
  self:checkMinifier()

  -- if PlayerData.storyCounter == 4 then
  -- PlayerData.isRinging = true
  -- end

  -- Mark: save actual position
  PlayerData.x = self.x
  PlayerData.y = self.y
  -- Mark: battery bounds
  if PlayerData.battery < 0 then
    PlayerData.battery = 0
  elseif PlayerData.battery >= 100 then
    PlayerData.battery = 100
  end
  -- Mark: Reduce speed in the dark
  if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true then
    if PlayerData.battery < 20 then
      self.speed = 0.5 * self.initialSpeed
    elseif PlayerData.battery > 20 then
      self.speed = self.initialSpeed
    end
  end
  if PlayerData.isInDarkness == true and PlayerData.items.hasLamp == false then
    self.speed = 0.5 * self.initialSpeed
  end
  -- Mark: invincibility timer
  if self.isInvincible then
    local refreshRate = playdate.display.getRefreshRate() or 30
    self.invincibilityTimer -= 1000 / refreshRate
    
    -- Visual feedback: Flicker
    if math.floor(self.invincibilityTimer / 100) % 2 == 0 then
        self:setVisible(false)
    else
        self:setVisible(true)
    end
    
    if self.invincibilityTimer <= 0 then
      self.isInvincible = false
      self.invincibilityTimer = 0
      self:setVisible(true)
    end
  end

  PlayerData.isActive = false
  -- Performance: Achievement check removed from update loop (handled by events)
end
