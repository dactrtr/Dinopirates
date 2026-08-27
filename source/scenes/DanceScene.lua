DanceScene = {}
class("DanceScene").extends(NobleScene)
local scene = DanceScene
scene.backgroundColor = Graphics.kColorBlack
DanceScene.debugMode = false

import "entities/UI/battle/buttonPress"
import "entities/UI/battle/hitZone"
import "entities/UI/battle/playerDance"
import "entities/UI/battle/backgroundDance"
import "entities/UI/battle/enemyRatDance"
import "entities/UI/battle/buttonCover"
import "entities/UI/battle/winIndicator"
import "entities/UI/battle/loseIndicator"
import "entities/UI/battle/resultsScreen"
import "entities/UI/battle/accuracyIndicator"

local lifes = nil

local screenCenterX = 200

-- File-scoped sprite references (declared here to allow cleanup in exit)
local hitzone = nil
local playerDance = nil
local enemyDance = nil
local buttonCover = nil
local winIndicator = nil
local loseIndicator = nil
local backgroundDance = nil
local resultsScreen = nil
local accuracyIndicator = nil
local sequence = nil
local barWidth = 8
local barHeight = 10
local barY = 56
local condition = nil

local battleMusicBasic = nil
local currentBattleMusic = nil
local kickSound = nil
local snareSound = nil

-- Enemy Pattern Profiles

local EnemyPatterns = {
    basic = {
        weights = { arrows = 0.8, aButton = 0.2, bButton = 0.0 },
        style = "arrow_heavy",
        phaseLength = 10
    },
    evolve = {
        weights = { arrows = 0.6, aButton = 0.2, bButton = 0.2 },
        style = "mixed",
        phaseLength = 10
    },
    badass = {
         weights = { arrows = 0.4, aButton = 0.3, bButton = 0.3 },
         style = "tough",
         phaseLength = 8
     },
    boss = {
        weights = { arrows = 0.2, aButton = 0.4, bButton = 0.4 },
        style = "button_spam",
        phaseLength = 6
    }
}

-- Helper: pick a random D-pad arrow key
local function pickArrow()
    local arrows = { "leftButton", "upButton", "rightButton", "downButton" }
    return arrows[math.random(#arrows)]
end

-- Helper: pick next pattern key given a profile
local function getPatternKey(profile)
    local weights = profile.weights
    local rand = math.random()
    local sum = weights.arrows + weights.aButton + weights.bButton
    local choice = rand * sum

    if choice < weights.arrows then
        local result = pickArrow()
        printDebug("Pattern: ARROW -> " .. result)
        return result
    elseif choice < weights.arrows + weights.aButton then
        printDebug("Pattern: A button")
        return "aButton"
    else
        printDebug("Pattern: B button")
        return "bButton"
    end
end

function scene:init()
    scene.super.init(self)
    playdate.display.setRefreshRate(50)
    -- Seed RNG with Playdate's current time in milliseconds (SDK 2.0+)
    -- This makes the probability roll different each run.
    if playdate and playdate.getCurrentTimeMilliseconds then
        math.randomseed(playdate.getCurrentTimeMilliseconds())
    else
        math.randomseed(1) -- fallback: deterministic
    end

    -- default bpm, can be upgraded later
    self.bpm = 16
    self.ButtonPressed = nil
    self.buttonText = "none"
    self.accuracy = 0
    self.totalAccuracy = 0
    self.enemyHP = 50
    self.evadePower = 30
    self.condition = nil
    self.enemyType = nil
    self.enemyEvolving = nil
    lifes = 3

    -- counters for correct presses
    self.correctButtonPresses = {
        aButton = 0,
        bButton = 0,
        leftButton = 0,
        rightButton = 0,
        upButton = 0,
        downButton = 0
    }

    self.balancePosition = 0 -- range -max to +max
    self.balanceMaxOffset = self.enemyHP -- enemy life/difficulty

    -- defaults for button count (may change on enter)
    self.numberOfButtons = 4

    battleMusicBasic = playdate.sound.fileplayer.new('assets/sounds/music/battle_music_test_ima')
    if battleMusicBasic then
        battleMusicBasic:setVolume(0.7)
    end

    kickSound = playdate.sound.sampleplayer.new('assets/sounds/music/drums/kick_test_ima')
    if kickSound then
        kickSound:setVolume(0.8)
    end

    snareSound = playdate.sound.sampleplayer.new('assets/sounds/music/drums/snare_test_ima')
    if snareSound then
        snareSound:setVolume(0.8)
    end
end

function scene:enter()
    scene.super.enter(self)
    local startPoint = 400
    condition = nil
    if sequence then sequence:stop() end
    sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
    sequence:start()

    -- Difficulty is deterministic: the enemy tier scales with how many crew members have
    -- been recruited so far (see determineEnemyType() + Config.Dance crew thresholds).
    if DanceScene.debugMode then
        self.enemyType = "basic"
    else
        self.enemyType = self:determineEnemyType()
    end
    local diffConfig = Config.Dance[self.enemyType] or Config.Dance.basic
    self.bpm = diffConfig.bpm
    self.numberOfButtons = diffConfig.buttons
    self.enemyEvolving = (self.enemyType ~= "basic")
    printDebug("Dance difficulty: " .. self.enemyType .. " (crew=" ..
        ((PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0) .. ")")

   -- Create ButtonPress instances using enemy pattern profile
   self.buttons = {}
   local profile = EnemyPatterns[self.enemyType] or EnemyPatterns.basic
   local canFight = PlayerData.skills and PlayerData.skills.canFight

   -- Provider: arrows-only until the canFight skill is unlocked, then the
   -- difficulty-weighted A/B pool.
   local function keyProvider()
       if canFight then
           return getPatternKey(profile)
       else
           return pickArrow()
       end
   end

   for i = 1, self.numberOfButtons do
       local b = ButtonPress(self.bpm, startPoint + self.bpm, keyProvider)
       table.insert(self.buttons, b)
   end

    -- Other entities
    hitzone = HitZone(40,30, self.bpm)

    -- Swap to the *Fight spritesheet when canFight is on; fall back to the
    -- base asset if the Fight PNG does not exist yet (dev-time probe; imagetable.new
    -- resolves the -table-W-H naming and returns nil instead of crashing).
    local function resolveFightPath(basePath, useFight)
        if not useFight then return basePath end
        local fightPath = basePath .. 'Fight'
        if Graphics.imagetable.new(fightPath) then
            return fightPath
        end
        return basePath
    end

    local charBase = PlayerData.isTiny
        and 'assets/images/ui/battle/playerDanceTiny'
        or  'assets/images/ui/battle/playerDance'
    playerDance = PlayerDance(self.bpm, resolveFightPath(charBase, canFight))

    -- Enemy spritesheet changes with the difficulty tier (Config.Dance[tier].sprite).
    -- Placeholder art: probe the tier sheet and fall back to the base enemyDance sheet
    -- until the per-tier PNG is authored, so a missing asset never crashes. A bosscolli
    -- encounter overrides the tier and uses its dedicated sheet.
    local enemyBase
    if PlayerData.lastEnemyTouched and PlayerData.lastEnemyTouched.type == "bosscolli" then
        enemyBase = 'assets/images/ui/battle/enemyBosscolliDance'
    else
        local tierSheet = (Config.Dance[self.enemyType] and Config.Dance[self.enemyType].sprite)
            or 'assets/images/ui/battle/enemyDance'
        enemyBase = Graphics.imagetable.new(tierSheet)
            and tierSheet
            or 'assets/images/ui/battle/enemyDance'
    end
    enemyDance = EnemyRatDance(self.bpm, self.enemyType, self.enemyEvolving, resolveFightPath(enemyBase, canFight))
    buttonCover = ButtonCover()
    winIndicator = WinIndicator(screenCenterX + self.balanceMaxOffset + 2*barWidth , barY + barHeight / 2 - 6)
    loseIndicator = LoseIndicator(screenCenterX - self.balanceMaxOffset - 2*barWidth , barY + barHeight / 2 - 6)
    backgroundDance = BackgroundDance(resolveFightPath('assets/images/ui/battle/background', canFight))
    resultsScreen = ResultsScreen()
    accuracyIndicator = AccuracyIndicator()

    if MazeScene.backgroundMusic and MazeScene.backgroundMusic:isPlaying() then
        MazeScene.backgroundMusic:stop()
    end

    if currentBattleMusic then
        currentBattleMusic:stop()
        currentBattleMusic = nil
    end

    if self.enemyType == "basic" and battleMusicBasic then
        currentBattleMusic = battleMusicBasic
        currentBattleMusic:play(0)
    end
end

function scene:start()
    scene.super.start(self)

    -- Stagger movement delays for all created buttons
    local delayStep = 300
    for i, btn in ipairs(self.buttons or {}) do
        btn:movementDelay((i-1) * delayStep)
    end
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)
    if (PlayerData.isDancing == false and condition == nil) or not hitzone then
        if resultsScreen and condition == nil then resultsScreen:loadingScreen() end
        return
    end
    local collisions = hitzone:overlappingSprites()
    if table.getsize(collisions) > 0 then
        if self.ButtonPressed == nil then
            
            self.accuracy += 1
            -- Clamp accuracy to reasonable maximum
            --self.accuracy = math.min(self.accuracy, 100)
            
            if self.accuracy > 5 then
                self.balancePosition -= 0.3 
            end
            enemyDance:changeAnimation(collisions[1].buttonKey)
            
            -- self.balancePosition -= 0.3 
            
        elseif collisions[1].buttonKey == self.ButtonPressed then
            
            if self.ButtonPressed == "aButton" or self.ButtonPressed == "bButton" then
               enemyDance:attackAnimation(collisions[1].buttonKey)
               self.enemyHP -= 10
               self.balancePosition += 5
                
            elseif self.ButtonPressed == "leftButton" or self.ButtonPressed == "rightButton" or self.ButtonPressed == "downButton" or self.ButtonPressed == "upButton" then
                
               self.balancePosition += self.accuracy 
               self.totalAccuracy += self.accuracy
               self.evadePower = self.totalAccuracy
            end
            
            -- Mark: change animation player and enemies
            playerDance:changeAnimation(self.ButtonPressed)

            collisions[1]:hit()

            -- Accuracy pop-up: deeper into the hit window (higher self.accuracy) = PERFECT.
            if accuracyIndicator then
                local perfectMin = (Config.Dance and Config.Dance.accuracyPerfectMin) or 4
                accuracyIndicator:show(self.accuracy >= perfectMin and 'perfect' or 'good')
            end

            self:incrementCorrectPress(self.ButtonPressed)
        else

            self.buttonText = "wrong"
            collisions[1]:hit()
            self.balancePosition -= 5
            if accuracyIndicator then accuracyIndicator:show('miss') end

        end
        self.ButtonPressed = nil
    else
        self.accuracy = 0
    end

    -- MISS pop-up for any button that scrolled off the left edge without being pressed.
    if accuracyIndicator and self.buttons then
        for _, btn in ipairs(self.buttons) do
            if btn.missedPass then
                btn.missedPass = false
                accuracyIndicator:show('miss')
            end
        end
    end

    
    -- Mark: debug rendering
    debugTextX = 240
    if debug == true then
        
        Graphics.drawText(PlayerData.lastEnemyTouched.id,debugTextX,30)
        Graphics.drawText(PlayerData.lastEnemyTouched.type,debugTextX+30,30)
        Graphics.drawText(lifes,debugTextX,50)
        Graphics.drawText(self.buttonText,debugTextX,70)
        Graphics.drawText(self.accuracy,debugTextX,90)
        Graphics.drawText(self.totalAccuracy,debugTextX,110)
        
        local y = 130
        for btn, count in pairs(self.correctButtonPresses) do
            Graphics.drawText(btn .. ": " .. count, debugTextX, y)
            y += 15
        end
    end
    -- Visualize win/lose threshold positions
   if debug == true then
       local loseX = screenCenterX - self.balanceMaxOffset - barWidth / 2
       local winX = screenCenterX + self.balanceMaxOffset - barWidth / 2
       local markerY = barY
       local markerW = (self.balanceMaxOffset * 2) + barWidth
       local markerH = barHeight
   
       -- Draw full range background (e.g., a faint filled rect behind the bar)
       Graphics.setColor(Graphics.kColorBlack)
       Graphics.drawRect(loseX, markerY, markerW, markerH)
   
       -- Optional: mark win and lose thresholds more visibly
       Graphics.drawLine(winX + barWidth / 2, markerY, winX + barWidth / 2, markerY + markerH)
       Graphics.drawLine(loseX + barWidth / 2, markerY, loseX + barWidth / 2, markerY + markerH)
   end
    
    
    if self.evadePower == 0 then
        
    end

   -- Normalize values (assume max enemy HP = 100, max lifes = 3)
   -- Clamp lifes to valid range
   lifes = math.max(0, math.min(3, lifes))
   
   local enemyFactor = (100 - self.enemyHP) / 100 -- closer to 1 as enemy weakens
   local playerFactor = (3 - lifes) / 3           -- closer to 1 as player weakens
   
   -- Calculate final X offset: enemyFactor pulls right, playerFactor pulls left
   local balanceOffset = (enemyFactor - playerFactor) * self.balanceMaxOffset -- range -50 to +50
   
   -- Generate balance bar image if needed
   if not self.balanceBarImage then
       self.balanceBarImage = Graphics.image.new('assets/images/ui/battle/nudgeIndicator')
   end
   
   -- Clamp balancePosition to max range
   self.balancePosition = math.max(-self.balanceMaxOffset, math.min(self.balanceMaxOffset, self.balancePosition))
   local balanceOffset = self.balancePosition
   
   -- Draw the image-based bar instead 
   self.balanceBarImage:drawCentered(screenCenterX + balanceOffset - barWidth / 2, barY)
   
   -- Check win or lose condition based on position
   if self.balancePosition >= self.balanceMaxOffset then
      
      resultsScreen:win()
      PlayerData.isDancing = false
      condition = "win"
      
            
   end
   
   if self.balancePosition <= -self.balanceMaxOffset then
      
      resultsScreen:lose()
      PlayerData.isDancing = false
      condition = "lose"
      
   end
    
end

function scene:exit()
	scene.super.exit(self)

    -- Remove battle sprites
    if hitzone then hitzone:remove() hitzone = nil end
    if playerDance then playerDance:remove() playerDance = nil end
    if enemyDance then enemyDance:remove() enemyDance = nil end
    if buttonCover then buttonCover:remove() buttonCover = nil end
    if winIndicator then winIndicator:remove() winIndicator = nil end
    if loseIndicator then loseIndicator:remove() loseIndicator = nil end
    if backgroundDance then backgroundDance:remove() backgroundDance = nil end
    if resultsScreen then resultsScreen:remove() resultsScreen = nil end
    if accuracyIndicator then accuracyIndicator:remove() accuracyIndicator = nil end

    if self.buttons then
        for _, btn in ipairs(self.buttons) do
            if btn then btn:remove() end
        end
        self.buttons = nil
    end

    DanceScene.debugMode = false

    -- Player reset
    PlayerData.healthPoints = 2

	Noble.Input.setCrankIndicatorStatus(false)
    if sequence then sequence:stop() end
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start()

    if currentBattleMusic then
        currentBattleMusic:stop()
        currentBattleMusic = nil
    end

    SaveSystem.save()
end

function scene:finish()
	scene.super.finish(self)
end

function scene:determineEnemyType()
    -- Enemy tier scales with crew recruited (meta-progression). More crew = tougher fights.
    local crew = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0

    if crew >= Config.Dance.crewBoss then
        return "boss"
    elseif crew >= Config.Dance.crewBadass then
        return "badass"
    elseif crew >= Config.Dance.crewEvolve then
        return "evolve"
    else
        return "basic"
    end
end

function scene:incrementCorrectPress(button)
    if self.correctButtonPresses[button] ~= nil then
        self.correctButtonPresses[button] += 1
    end
end
function scene:clearButton()
    self.ButtonPressed = nil
end
function scene:danceStep(inputStep)
    self.ButtonPressed = inputStep
end

function scene:checkDanceResults()
   if condition == "win" then
      condition = nil
      self.totalAccuracy = 0

      if DanceScene.debugMode then
          Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)
          return
      end

      -- Find an enemy and kill it
      findAndKillEnemyById(PlayerData.lastEnemyTouched.id)
      -- health regain
      
      PlayerData.healthPoints = math.min(PlayerData.healthPoints + PlayerData.healedHP, Config.Player.maxHealthPoints)
      -- captures player position and goes back to the original room
      PlayerData.playerSpawn.x = PlayerData.playerExit.x
      PlayerData.playerSpawn.y = PlayerData.playerExit.y
      PlayerData.returningInPlace = true  -- resume at the fight spot, not at a door
      
      -- Sets the power level of the enemies
      PlayerData.amountDances += 1
      PlayerData.calories = math.min((PlayerData.calories or 0) + 60, Config.Dance.caloriesMax)
      
      -- transition to the original room
      self.returnRoom = MazeScene
      RunState.goTo(RunState.currentNodeId)  -- re-enter the room we left for the fight
      
      Noble.transition(self.returnRoom, 0.3, Noble.Transition.Default)  
      
   elseif (condition == "lose") then
      condition = nil
      PlayerData.deathCause = "hp"
      Noble.transition(DeadScene, 0.3, Noble.Transition.MetroNexus)
   end   
end

function scene:startBattle()
   resultsScreen:empty()
   PlayerData.isDancing = true
   enemyDance:setIdle()
end


scene.inputHandler = {

    -- A button
    --
    AButtonDown = function()			-- Runs once when button is pressed.
        -- Your code here
        if  PlayerData.isDancing == false and condition == nil then
            scene:startBattle()
            return
        end
        if snareSound and PlayerData.isDancing then
            snareSound:play(1)
        end
        scene:danceStep("aButton")
        scene:checkDanceResults()
    end,
    AButtonHold = function()			-- Runs every frame while the player is holding button down.
        -- Your code here
    end,
    AButtonHeld = function()			-- Runs after button is held for 1 second.
        -- Your code here
    end,
    AButtonUp = function()				-- Runs once when button is released.
        -- Your code here
        scene:clearButton()
    end,

    -- B button
    --
    BButtonDown = function()
        -- Your code here
        scene:danceStep("bButton")
    end,
    BButtonHeld = function()
        -- Your code here
    end,
    BButtonHold = function()
        -- Your code here
    end,
    BButtonUp = function()
       scene:clearButton()
    end,

    -- D-pad left
    --
    leftButtonDown = function()
        -- Your code here
        if kickSound and PlayerData.isDancing then
            kickSound:play(1)
        end
        scene:danceStep("leftButton")
    end,
    leftButtonHold = function()
        -- Your code here
    end,
    leftButtonUp = function()
        scene:clearButton()
    end,

    -- D-pad right
    --
    rightButtonDown = function()
        -- Your code here
        if kickSound and PlayerData.isDancing then
            kickSound:play(1)
        end
        scene:danceStep("rightButton")
    end,
    rightButtonHold = function()
        -- Your code here
    end,
    rightButtonUp = function()
        scene:clearButton()
    end,

    -- D-pad up
    --
    upButtonDown = function()
        -- Your code here
        if kickSound and PlayerData.isDancing then
            kickSound:play(1)
        end
        scene:danceStep("upButton")
    end,
    upButtonHold = function()
        -- Your code here
    end,
    upButtonUp = function()
        scene:clearButton()
    end,

    -- D-pad down
    --
    downButtonDown = function()
        -- Your code here
        if kickSound and PlayerData.isDancing then
            kickSound:play(1)
        end
        scene:danceStep("downButton")
    end,
    downButtonHold = function()
        -- Your code here
    end,
    downButtonUp = function()
        scene:clearButton()
    end,

    -- Crank
    --
    cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
        -- Your code here
    end,
    crankDocked = function()						-- Runs once when when crank is docked.
        -- Your code here
    end,
    crankUndocked = function()						-- Runs once when when crank is undocked.
        -- Your code here
    end
}

