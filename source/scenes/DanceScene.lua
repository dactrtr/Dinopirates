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

-- Helper: pick next pattern key given a profile
local function getPatternKey(profile)
    local weights = profile.weights
    local rand = math.random()
    local sum = weights.arrows + weights.aButton + weights.bButton
    local choice = rand * sum

    if choice < weights.arrows then
        local arrows = { "leftButton", "upButton", "rightButton", "downButton" }
        local result = arrows[math.random(#arrows)]
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

-- Helper: calculate the probability (0-100) to upgrade difficulty
function scene:determineDifficultyUpgrade()
    -- Get safe values from PlayerData (use 0 as fallback)
    local sanity = PlayerData.sanityCounter or 0
    local power = (PlayerData.EnemiesData and PlayerData.EnemiesData.powerLevel) or 0
    local calories = PlayerData.calories or 0

    -- Normalize each input into [0,1] using assumed maxima.
    -- Tweak these maxima to fit your game's real ranges for better results.
    local sanityNorm   = math.max(0, math.min(1, sanity   / Config.Dance.sanityMax))
    local powerNorm    = math.max(0, math.min(1, power    / Config.Dance.powerMax))
    local caloriesNorm = math.max(0, math.min(1, calories / Config.Dance.caloriesMax))

    local weightSanity   = Config.Dance.weightSanity
    local weightPower    = Config.Dance.weightPower
    local weightCalories = Config.Dance.weightCalories

    -- Combined normalized score
    local normalizedScore = (sanityNorm * weightSanity) + (powerNorm * weightPower) + (caloriesNorm * weightCalories)

    -- Convert to percentage probability
    local probability = normalizedScore * 100

    -- Clamp to [0,100]
    probability = math.max(0, math.min(100, probability))

    return probability
end

function scene:enter()
    scene.super.enter(self)
    local startPoint = 400
    condition = nil
    if sequence then sequence:stop() end
    sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
    sequence:start()

    if DanceScene.debugMode then
        self.enemyType = "basic"
        self.bpm = Config.Dance.basic.bpm
        self.numberOfButtons = Config.Dance.basic.buttons
        self.enemyEvolving = false
    else
        -- Decide whether to upgrade difficulty based on PlayerData
        local chance = self:determineDifficultyUpgrade()
        local roll = math.random(0, 100)

        if roll <= chance then
            self.enemyType = self:determineEnemyType()
            local diffConfig = Config.Dance[self.enemyType] or Config.Dance.basic
            self.bpm = diffConfig.bpm
            self.numberOfButtons = diffConfig.buttons
            self.enemyEvolving = true
            printDebug("Difficulty UPGRADED to " .. self.enemyType .. " (roll=" .. roll .. ", chance=" .. chance .. ")")
        else
            self.enemyType = "basic"
            self.enemyEvolving = false
            self.bpm = Config.Dance.basic.bpm
            self.numberOfButtons = Config.Dance.basic.buttons
            printDebug("Difficulty KEPT: basic (roll=" .. roll .. ", chance=" .. chance .. ")")
        end
    end

   -- Create ButtonPress instances using enemy pattern profile
   self.buttons = {}
   local profile = EnemyPatterns[self.enemyType] or EnemyPatterns.basic
   
   -- define a provider function that always pulls from this profile
   local function keyProvider()
       return getPatternKey(profile)
   end
   
   for i = 1, self.numberOfButtons do
       local b = ButtonPress(self.bpm, startPoint + self.bpm, keyProvider)
       table.insert(self.buttons, b)
   end

    -- Other entities
    hitzone = HitZone(40,30, self.bpm)

    local charPath = PlayerData.isTiny
        and 'assets/images/ui/battle/playerDanceTiny'
        or  'assets/images/ui/battle/playerDance'
    playerDance = PlayerDance(self.bpm, charPath)

    local enemyPath = (PlayerData.lastEnemyTouched and PlayerData.lastEnemyTouched.type == "bosscolli")
        and 'assets/images/ui/battle/enemyBosscolliDance'
        or  'assets/images/ui/battle/enemyDance'
    enemyDance = EnemyRatDance(self.bpm, self.enemyType, self.enemyEvolving, enemyPath)
    buttonCover = ButtonCover()
    winIndicator = WinIndicator(screenCenterX + self.balanceMaxOffset + 2*barWidth , barY + barHeight / 2 - 6)
    loseIndicator = LoseIndicator(screenCenterX - self.balanceMaxOffset - 2*barWidth , barY + barHeight / 2 - 6)
    backgroundDance = BackgroundDance()
    resultsScreen = ResultsScreen()

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
            
            self:incrementCorrectPress(self.ButtonPressed)
        else
           
            self.buttonText = "wrong"
            collisions[1]:hit()
            self.balancePosition -= 5 
            
        end
        self.ButtonPressed = nil
    else
        self.accuracy = 0
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
    local pwr = PlayerData.EnemiesData.powerLevel

    if pwr >= 1 and pwr <= 5 then
        return "basic"
    elseif pwr >= 6 and pwr <= 12 then
        return "evolve"
    elseif pwr >= 13 and pwr <= 19 then
        return "badass"
    elseif pwr == 20 then
        return "boss"
    else
        return "basic" -- fallback safety
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
      
      -- Sets the power level of the enemies
      PlayerData.amountDances += 1
      PlayerData.calories = math.min((PlayerData.calories or 0) + 60, Config.Dance.caloriesMax)
      
      -- transition to the original room
      self.returnRoom = RoomTranslate(PlayerData.saveLevel)
      
      Noble.transition(self.returnRoom, 0.3, Noble.Transition.Default)  
      
   elseif (condition == "lose") then
      condition = nil
      
      Noble.transition(TitleScene,0.3, Noble.Transition.MetroNexus) 
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

