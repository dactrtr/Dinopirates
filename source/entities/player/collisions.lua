function Player:collisionResponse(other)

  if other:isa(Enemy) then
    if other:isa(Brocorat) then -- validate candance also
      PlayerData.lastEnemyTouched.type = "Brocorat"
      PlayerData.lastEnemyTouched.id = other.id
      PlayerData.lastEnemyTouched.x = other.x
      PlayerData.lastEnemyTouched.y = other.y
      
      -- Add damage logic
      if not self.isInvincible then
        PlayerData.healthPoints -= (other.damage or 1)
        printDebug("💥 Player hit by Brocorat! HP:", PlayerData.healthPoints)
        
        -- Trigger dance only if HP < threshold
        if PlayerData.healthPoints < (PlayerData.danceThresholdHP or 5) then
          self:fight()
        else
          self:startInvincibility(1000) -- 1 second cooldown
        end
      end
      
      return 'overlap'

    end

  elseif other:isa(CrewMember) then
    if PlayerData.isTiny then
        self.currentTrigger = other
        return 'overlap'
    end
    
    -- Validate having the capture bag
    if PlayerData.CrewMemberData.amountTaken == 0 then
      if other.crewId == 'CM001' then
        -- custom screen here after validating the crewId
      end
      
      
      self.dialogUI:addScreen("gotcha",other.sourceFeed) -- default screen for the 1st time
    end
    other:taken()

  elseif other:isa(Box) then

  return 'freeze'

  elseif other:isa(Trigger) then
  if other.type == "Cutscene" then
      -- Cutscenes trigger automatically
      PlayerData.isGaming = false
      PlayerData.isCutscene = true
      other:returnScript()
      printDebug("🔍 Verificando trigger después de usar:")
      local roomData = levelsLDTK[PlayerData.floor]
      for _, t in ipairs(roomData.entities.Triggers) do
          if t.iid == other.iid then
              printDebug("   usedTrigger:", t.customFields.usedTrigger)
              break
          end
      end
      other:remove()
      Utilities.grantAchievementIfNeeded(other.script)
  elseif other.type == "Search" then
      self.currentTrigger = other
  elseif other.type == "Call" then
      self.currentTrigger = other
  elseif other.type == "Story" then
      PlayerData.isGaming = false
      self.dialogUI:addScreen(other:returnScript(),other.sourceFeed)
  elseif other.type == nil then
      self.currentTrigger = other
  elseif other.type == "Counter" then
      PlayerData.storyCounter += 1
      other:remove()
  end
  return 'overlap'

  elseif other:isa(Items) and other.type == 'keycard' then
    local keyNumber = other.keyNumber or 1  -- Get key number from item
    other:removeAll()
    self:grabKey(keyNumber)
    return 'overlap'

  elseif other:isa(Items) and other.type == 'lamp' then
    other:removeAll()
    self:grabLamp()
    return 'overlap'

  elseif other:isa(Items) and other.type == 'radio' then
    other:removeAll()
    self:grabRadio()
    return 'overlap'

  elseif other:isa(Items) and other.type == 'notes' then
    other:removeAll()
    self:grabNotes(other.grants)
    return 'overlap'

  elseif other:isa(Items) and (other.type == 'itemgift' or other.type == 'itemGift') then
    other:removeAll()
    self:grabItemGift(other.grants)
    return 'overlap'

  elseif other:isa(Items) and other.type == 'bag' then
    other:removeAll()
    self:grabBag()
    return 'overlap'

  elseif other:isa(Items) and other.type == 'honk' then
    other:removeAll()
    self:grabBag()
  return 'overlap'

  elseif other:isa(Items) and other.type == 'tools' then
    other:removeAll()
    self:grabTools()
  return 'overlap'

  elseif other:isa(Items) and other.type == 'boots' then
    other:removeAll()
    self:grabBoots()
  return 'overlap'

  elseif other:isa(Items) and other.type == 'plunger' then
    other:removeAll()
    self:grabPlunger()
  return 'overlap'

  elseif other:isa(PropItem) and other.isHole then
  -- If player has boots with battery, can walk over the hole
  if PlayerData.items.hasBoots == true and PlayerData.battery > 0 then
    if PlayerData.isTiny == true then
      self:drainBattery(0.2)
    else
      self:drainBattery(0.5)
    end
      return 'overlap'
  else
      -- Without boots or without battery = fall
      self:fallBelow()
      return 'overlap'
  end
  
  elseif other:isa(PropItem) and other.type == 'minifier' then
    self.currentMinifier = other
    PlayerData.readyToShrink = true
    self:showUIHUD()
    self.uiHud:setPressA()
    
  return 'overlap'

  elseif other:isa(PropItem) and other.isTube then
    -- Pneumatic tube, allow climbing up if correct DoorsConnection AND player is tiny
    if PlayerData.isTiny == true then
      self:riseAbove()
      return 'overlap'
    else
      return 'freeze'
    end

  elseif other:isa(PropItem) then
  return 'freeze'
  
  elseif other:isa(Door) then

    if other.status == 'open' then
      -- Door is open, allow passage
      other:prevRoom(other.direction, self.x, self.y)
      other:goTo()
      return 'overlap'
    elseif other.status == 'closed' then
      -- Door is closed, check if player has the required key
      local requiredKey = other.keyNumber or 1  -- Default to key 1 if not specified

      if PlayerData.keys[requiredKey] == true then
        -- Player has the correct key
        printDebug("🔓 Door unlocked with key", requiredKey)
        other:prevRoom(other.direction, self.x, self.y)
        other:goTo()
        return 'overlap'
      else
        -- Player doesn't have the required key
        printDebug("🔒 Door locked, requires key", requiredKey)
        self.dialogUI:addScreen("nokeys")
        return 'freeze'
      end
    end

  end
end
