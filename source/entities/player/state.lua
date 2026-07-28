function Player:fallBelow()
  -- Falling through a hole starts a NEW run (regenerating the graph), entering at a
  -- "startDown" room instead of softlocking. Meta (items/skills/crew/sanity) persists.
  printDebug("🕳️ Fell through a hole — new run (startDown)")
  PlayerData.returningInPlace = false
  PlayerData.runCount = (PlayerData.runCount or 0) + 1  -- a hole fall starts a new run
  RunState.startRun("startdown")
  Noble.transition(MazeScene, 1.5, Noble.Transition.Imagetable, {
    imagetableEnter = Graphics.imagetable.new('assets/images/screens/transitions/transitionFallEnter'),
    imagetableExit = Graphics.imagetable.new('assets/images/screens/transitions/transitionFallOut'),
  })
end

function Player:riseAbove()
  -- Rising through a tube starts a NEW run, entering at a "startUp" room. Meta persists.
  printDebug("🛗 Rose through a tube — new run (startUp)")
  PlayerData.returningInPlace = false
  PlayerData.runCount = (PlayerData.runCount or 0) + 1  -- a tube rise starts a new run
  RunState.startRun("startup")
  Noble.transition(MazeScene, 1.5, Noble.Transition.Default)
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

function Player:applyKnockback(enemyX, enemyY)
    local k = Config.Player.knockbackDistance
    local dx = 0
    local dy = 0
    if self.x ~= enemyX then
        dx = (self.x > enemyX) and k or -k
    end
    if self.y ~= enemyY then
        dy = (self.y > enemyY) and k or -k
    end
    self:moveWithCollisions(self.x + dx, self.y + dy)
end

function Player:idle()
  if self.isAlive == true then
    -- While the plungerang is away from the player (in flight or lost to a crew), hold the
    -- noLeg pose instead of idling; we only fall through to a real idle once it's back. If
    -- the one-shot shoot animation is still playing, leave it — it auto-advances to noLeg.
    if (self.isPlunging or self.hasProjectile == false) and PlayerData.isTiny == false then
      local cn = self.animation.currentName
      if cn ~= 'shootLeft' and cn ~= 'shootRight' then
        self.animation:setState(self.shootDir == 'left' and 'noLegLeft' or 'noLegRight')
      end
      PlayerData.direction = 'idle'
      return
    end
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

function Player:dead(cause)
  self.isAlive = false
  PlayerData.deathCause = cause or "hp"
  local function deathScreen()
    Noble.transition(DeadScene)
  end
  playdate.timer.performAfterDelay(Config.Player.deathScreenDelay, deathScreen)
end

function Player:focus()
  if PlayerData.sanity > Config.Sanity.focusCost then
    PlayerData.sanity -= Config.Sanity.focusCost
    PlayerData.isFocused = true
  end
end

function Player:shrink()
  PlayerData.isTiny = true
  local crt = Config.Player.collideRectTiny
  self:setCollideRect(crt.x, crt.y, crt.w, crt.h)
  self.animation:setState('transformTo')
end

function Player:grow()
    PlayerData.isTiny = false
    local cr = Config.Player.collideRect
    self:setCollideRect(cr.x, cr.y, cr.w, cr.h)
    self:idle()
end

function Player:startMinifying()
    if not self.currentMinifier or PlayerData.isTalking or not PlayerData.isGaming then return end

    -- Lock player and center
    PlayerData.isGaming = false
    self.triggerEnteredOnce = true -- Stop trigger checks
    
    -- Auto center on minifier
    local targetX = self.currentMinifier.x
    local targetY = self.currentMinifier.y - 10
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

function Player:startCooking()
    if not self.currentMicrowave or PlayerData.isTalking or not PlayerData.isGaming then return end
    -- Cooking is only possible while big — the tiny player can't operate the microwave.
    if PlayerData.isTiny then
        printDebug("Too small to use the microwave!")
        return
    end
    -- Nothing to do? Don't enter cooking.
    if (PlayerData.food or 0) <= 0 or PlayerData.healthPoints >= Config.Player.maxHealthPoints then return end

    -- Lock player and center
    PlayerData.isGaming = false
    self.triggerEnteredOnce = true -- Stop trigger checks

    -- Auto center on microwave
    local targetX = self.currentMicrowave.x
    local targetY = self.currentMicrowave.y - 10
    self:moveTo(targetX, targetY)
    if shadow then shadow:moveTo(targetX, targetY) end

    -- Show crank prompt
    -- Future hook: set a distinct cooking player animation + HUD state here (out of scope for v1).
    self.uiHud:setCrankClock()
    self:showUIHUD()

    -- Reset crank accumulator
    self.cookProgress = 0
end

function Player:finishCooking()
    PlayerData.isGaming = true
    self.triggerEnteredOnce = false
    self.uiHud:setVisible(false)
    self.cookProgress = 0
    -- Leave the eating animation and return to the context-appropriate idle.
    self:idle()
end

function Player:checkMicrowave()
    if self.currentMicrowave then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentMicrowave then
                stillInside = true
                break
            end
        end

        if not stillInside then
            self.uiHud:setVisible(false)
            self.currentMicrowave = nil
            PlayerData.readyToCook = false
        end
    end
end
function Player:pedometer()
  PlayerData.steps += Config.Pedometer.stepsPerMovement
  PlayerData.totalSteps += Config.Pedometer.stepsPerMovement
  if PlayerData.steps >= Config.Pedometer.stepsToTrigger then
    PlayerData.steps = 0
    self:burnCalories(Config.Pedometer.caloriesPerBurn)
  end
end
function Player:burnCalories(calories)
    PlayerData.calories -= calories
end

function Player:deFocus()
  if PlayerData.isFocused == true then
    PlayerData.isFocused = false
  end
end
function Player:showUIHUD()
  -- Base position above the player
  local hudX = self.x + self.playerUIX
  local hudYOffset = Config.Player.hudOffsetY
  if PlayerData.isTiny then
    hudYOffset = Config.Player.hudOffsetYTiny
  end
  local hudY = self.y + hudYOffset -- normal default above player

  -- Adjust for top of screen
  if self.y < Config.Player.hudEdgeTop then
    hudY = self.y + self.playerUIY / 2 -- move down instead of above
  end

  -- Adjust for right edge
  if self.x > Config.Player.hudEdgeRight then
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
    local distanceMoved = math.abs(self.x - self.lastCheckX) + math.abs(self.y - self.lastCheckY)
    local shouldCheckOverlap = distanceMoved > Config.Player.triggerCheckDist or self.currentTrigger ~= nil

    if shouldCheckOverlap then
      self.lastCheckX = self.x
      self.lastCheckY = self.y

      if self.currentTrigger then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentTrigger then
              stillInside = true

              self:showUIHUD()
              if not self.triggerEnteredOnce then
                if self.currentTrigger.type == "Call" then
                  self.uiHud:setRing()
                elseif self.currentTrigger.type == "Search" then
                  self.uiHud:setInvestigate()
                elseif self.currentTrigger.type == nil then
                  self.uiHud:setPressA()
                end
                self.triggerEnteredOnce = true
              end

              break
            end
          end

          if not stillInside then
              self.uiHud:setVisible(false)
              self.currentTrigger = nil
              self.triggerEnteredOnce = false
          end
      end
    end
end

local wakeButtons = {
  playdate.kButtonA, playdate.kButtonB,
  playdate.kButtonUp, playdate.kButtonDown,
  playdate.kButtonLeft, playdate.kButtonRight
}

function Player:update()
  if self.isSleeping then
    for _, btn in ipairs(wakeButtons) do
      if playdate.buttonJustPressed(btn) then
        self:onWakePress()
        break
      end
    end
    return
  end

  -- Update dash movement if dashing
  self:updateDash()

  -- Update sliding movement if on slime
  self:updateSliding()

  -- Update grappling-hook pull if active
  self:updateGrapplePull()

  -- Balancing grace: measure this frame's movement + reset counters when off the hazard.
  self:updateGraceMove()

  -- Check if player is on a slime tile (IDs 89-97)
  self:checkSlimeTile()

  -- Check if player is on a hole tile (IDs 104-115)
  self:checkHoleTile()
  self:checkTinyHoleTile()

  -- Balancing warning HUD + sprite: show the moment grace crosses the warning threshold, hide
  -- when it clears. Driven from update() (not move()) so both the HUD and the balancing sprite
  -- appear on contact and persist even if the player stops on the hazard without pressing a
  -- direction. The _warningShown flag ensures we only hide the HUD we showed (never a
  -- pressA/crank prompt another system put up). setState is idempotent, so re-setting the
  -- balancing pose every frame here (and again in move()) does not restart the animation.
  if self:hasBalanceGrace() then
    self.uiHud:setWarning()
    self._warningShown = true
    if self:isBalancing() then
      self.animation:setState(PlayerData.isTiny and 'balancingTiny' or 'balancing')
    end
  elseif self._warningShown then
    self.uiHud:setVisible(false)
    self._warningShown = false
  end

  -- Hide light cone after display time
  if self.lightConeHideTime and playdate.getCurrentTimeMilliseconds() >= self.lightConeHideTime then
    PlayerData.showLightCone = false
    self.lightConeHideTime = nil
  end


  self:checkForegroundDepth()
  
  self:checkTrigger()
  self:checkMinifier()
  self:checkMicrowave()

  -- if PlayerData.storyCounter == 4 then
  -- PlayerData.isRinging = true
  -- end

  PlayerData.x = self.x
  PlayerData.y = self.y
  if PlayerData.battery < 0 then
    PlayerData.battery = 0
  elseif PlayerData.battery >= Config.Battery.max then
    PlayerData.battery = Config.Battery.max
  end
  if PlayerData.healthPoints > Config.Player.maxHealthPoints then
    PlayerData.healthPoints = Config.Player.maxHealthPoints
  end
  if PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true then
    if PlayerData.battery < Config.Sanity.batteryThresholdLow then
      self.speed = Config.Player.speedLowBattery * self.initialSpeed
    elseif PlayerData.battery > Config.Sanity.batteryThresholdLow then
      self.speed = self.initialSpeed
    end
  end
  if PlayerData.isInDarkness == true and PlayerData.items.hasLamp == false then
    self.speed = Config.Player.speedDarkNoLamp * self.initialSpeed
  end
  if self.isInvincible then
    local refreshRate = playdate.display.getRefreshRate() or 30
    self.invincibilityTimer -= 1000 / refreshRate
    
    -- Visual feedback: Flicker
    if math.floor(self.invincibilityTimer / Config.Invincibility.flickerRate) % 2 == 0 then
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
end

function Player:checkForegroundDepth()
    local TILE_SIZE = Config.Tiles.size
    local hr = Config.Player.collideRectHead
    local headX = self.x - 24 + hr.x + hr.w * 0.5
    local headY = self.y - 24 + hr.y + hr.h * 0.5
    local tX = math.floor(headX / TILE_SIZE) + 1
    local tY = math.floor(headY / TILE_SIZE) + 1

    local tileGrid = tileMapData[PlayerData.actualTilemap]
    local row = tileGrid and tileGrid[tY]
    local id  = row and row[tX] or 0

    local walkable = { [0]=true,[1]=true,[2]=true,[3]=true,[4]=true,[5]=true }
    if not walkable[id] then
        self:setZIndex(ZIndex.foreground + 1)
    else
        self:setZIndex(self.y)
    end
end

function Player:startSleeping()
    self.isSleeping = true
    self.wakeupPresses = 0
    self.animation:setState(PlayerData.isTiny and 'sleepTiny' or 'sleep')
end

function Player:onWakePress()
    self.wakeupPresses += 1
    if self.wakeupPresses >= Config.Player.wakeupPressesRequired then
        self:wake()
    end
end

function Player:wake()
    self.isSleeping = false
    self:idle()
    PlayerData.isGaming = true
end
