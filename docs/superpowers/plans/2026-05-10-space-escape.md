# Space Escape Runner — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert SpaceScene into an infinite escape runner with scrolling meteorite parallax, a speed/danger system, and a 3-hit health display.

**Architecture:** Two fixed meteorite pools (near/far) scroll left each frame; d-pad input adds an inverted parallax offset. A `danger` float fills when speed is below threshold and triggers game over at 1.0. Collision with meteorites reduces a 3-point health counter. All tunable values live in `Config.Space`.

**Tech Stack:** Lua, Playdate SDK, Noble Engine. No test runner — validate by compiling with `pdc` and checking in simulator.

> **CLAUDE.md rule:** Never run `git commit`. Skip all commit steps.

---

## File Map

| Action   | File                                          | Responsibility                              |
|----------|-----------------------------------------------|---------------------------------------------|
| Modify   | `source/assets/data/Config.lua`               | Add all new Config.Space tunable values     |
| Modify   | `source/entities/space/Meteorite.lua`         | Add `scrollBy()` + collision rect           |
| Create   | `source/entities/space/DangerBar.lua`         | Procedural danger bar sprite                |
| Create   | `source/entities/space/HealthDisplay.lua`     | 3-dot health display sprite                 |
| Modify   | `source/entities/space/Ship.lua`              | Add `setCollideRect`, cap boost at maxSpeed |
| Modify   | `source/scenes/SpaceScene.lua`                | Pools, speed decay, danger, collision, game over |

**Task dependency:**
- Task 1 (Config) must run first.
- Tasks 2, 3, 4, 5 are independent — run in parallel after Task 1.
- Task 6 (SpaceScene) depends on Tasks 2–5 all complete.

---

## Task 1: Config.Space additions

**Files:**
- Modify: `source/assets/data/Config.lua`

- [ ] **Open `source/assets/data/Config.lua` and replace the `Config.Space` block** (currently ends at line ~221) with:

```lua
Config.Space = {
    crosshairSpeed        = 4,
    lerpFactor            = 0.08,
    accelSensitivity      = 1.2,
    shipMoveLerp          = 0.12,
    accelIdleThreshold    = 0.005,
    accelIdleFrames       = 2,
    accelCenterReturnLerp = 0.04,

    -- speed & danger
    speedDecay            = 0.05,
    maxSpeed              = 20,
    minSpeed              = 3,
    dangerFillRate        = 0.002,
    dangerDrainRate       = 0.003,

    -- meteorite pools
    meteoriteNearCount    = 6,
    meteoriteFarCount     = 5,
    meteoriteNearSpeed    = 3,
    meteoriteFarSpeed     = 1.5,
    meteoriteSpeedMult    = 0.2,
    parallaxSpeed         = 3,
    meteoriteFarParallax  = 0.5,
    meteoriteFarScale     = 0.6,

    -- collision
    invincibilityFrames   = 60,
}
```

- [ ] **Compile to verify no syntax errors:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

---

## Task 2: Meteorite — scrollBy + collision rect

**Files:**
- Modify: `source/entities/space/Meteorite.lua`

- [ ] **Replace the entire file** with:

```lua
class('Meteorite').extends(NobleSprite)

function Meteorite:init(x, y, speed)
    Meteorite.super.init(self, 'assets/images/space/meteorite', true)

    self.animation:addState('spin', 1, 4)
    self.animation.spin.frameDuration = speed or 4

    self:setGroups(1)
    self:setCollideRect(8, 8, 32, 32)
    self:setZIndex(ZIndex.props)
    self:add(x, y)
end

function Meteorite:updateSpeed(speed)
    self.animation.spin.frameDuration = speed
end

function Meteorite:scrollBy(dx, dy)
    local nx = self.x + dx
    local ny = self.y + dy
    if nx < -48 then
        nx = 424 + math.random(0, 50)
        ny = math.random(8, 232)
    end
    self:moveTo(nx, ny)
end
```

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

---

## Task 3: DangerBar entity

**Files:**
- Create: `source/entities/space/DangerBar.lua`

- [ ] **Create `source/entities/space/DangerBar.lua`** with:

```lua
class('DangerBar').extends(Graphics.sprite)

function DangerBar:init()
    self.lastDanger = -1
    self:setZIndex(ZIndex.ui + 5)
    self:moveTo(390, 120)
    self:update(0)
    self:add()
end

function DangerBar:update(danger)
    if danger == self.lastDanger then return end
    self.lastDanger = danger
    local img = Graphics.image.new(4, 224, Graphics.kColorClear)
    Graphics.pushContext(img)
        Graphics.setColor(Graphics.kColorWhite)
        local fillH = math.floor(danger * 224)
        Graphics.fillRect(0, 224 - fillH, 4, fillH)
    Graphics.popContext()
    self:setImage(img)
end
```

> Position math: bar is 4px wide. 8px margin from right (400) → right edge at 392 → center at 390. Height 224 = 240 − 8 top − 8 bottom. Fills bottom-up.

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

---

## Task 4: HealthDisplay entity

**Files:**
- Create: `source/entities/space/HealthDisplay.lua`

- [ ] **Create `source/entities/space/HealthDisplay.lua`** with:

```lua
class('HealthDisplay').extends(Graphics.sprite)

function HealthDisplay:init(x, y)
    self.lastHealth = -1
    self:setZIndex(ZIndex.ui + 2)
    self:moveTo(x, y)
    self:update(3)
    self:add()
end

function HealthDisplay:update(health)
    if health == self.lastHealth then return end
    self.lastHealth = health
    local img = Graphics.image.new(24, 8, Graphics.kColorClear)
    Graphics.pushContext(img)
        for i = 1, 3 do
            local cx = (i - 1) * 8 + 4
            local cy = 4
            if i <= health then
                Graphics.setColor(Graphics.kColorWhite)
                Graphics.fillCircleAtPoint(cx, cy, 2)
            else
                Graphics.setColor(Graphics.kColorWhite)
                Graphics.drawCircleAtPoint(cx, cy, 2)
            end
        end
    Graphics.popContext()
    self:setImage(img)
end
```

> Sprite is 24×8px: 3 circles of 4px diameter with 2px margin each side = 8px slot each. `lastHealth = -1` forces the first draw.

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

---

## Task 5: Ship — collision rect + boost cap

**Files:**
- Modify: `source/entities/space/Ship.lua`

- [ ] **In `Ship:init()`, add `setCollideRect` after `setGroups`** (around line 19):

```lua
    self:setGroups(2)
    self:setCollideRect(20, 10, 40, 40)
```

> Collision rect is the inner 40×40 area of the 80×60 sprite, offset 20px from left and 10px from top. Avoids wing tips triggering hits on near misses.

- [ ] **In `Ship:boost()`, replace the speed increment** to respect `maxSpeed`:

```lua
function Ship:boost(mode)
    if self.energy > 0 and self.mode == mode then
        self.speed  = math.min(self.speed + 1, Config.Space.maxSpeed)
        self.energy -= 1
    end
end
```

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

---

## Task 6: SpaceScene — full integration

**Files:**
- Modify: `source/scenes/SpaceScene.lua`

> This task replaces the entire file. Read the current file first to confirm you're not on a stale version, then replace it wholesale.

- [ ] **Replace `source/scenes/SpaceScene.lua`** with the following complete file:

```lua
import 'entities/space/Ship'
import 'entities/space/Crosshair'
import 'entities/space/FXspeed'
import 'entities/space/Meteorite'
import 'entities/space/Laser'
import 'entities/space/EnergyMeter'
import 'entities/space/DangerBar'
import 'entities/space/HealthDisplay'

SpaceScene = {}
class('SpaceScene').extends(NobleScene)
local scene = SpaceScene

scene.backgroundColor = Graphics.kColorBlack

local ship          = nil
local crosshair     = nil
local fxspeed       = nil
local laser         = nil
local energy        = nil
local dangerBar     = nil
local healthDisplay = nil

local meteoritesNear = {}
local meteoritesFar  = {}

local cursorX    = 200
local cursorY    = 120
local baseAx     = 0
local baseAy     = 0
local calibrated = false
local prevAx     = 0
local prevAy     = 0
local idleFrames = 0

local danger    = 0
local health    = 3
local invFrames = 0

local shipX = 200
local shipY = 150

function scene:init()
    scene.super.init(self)
end

function scene:enter()
    scene.super.enter(self)

    cursorX    = 200
    cursorY    = 120
    baseAx     = 0
    baseAy     = 0
    calibrated = false
    prevAx     = 0
    prevAy     = 0
    idleFrames = 0
    danger     = 0
    health     = 3
    invFrames  = 0

    ship      = Ship(shipX, shipY, 4, 0, ZIndex.player)
    crosshair = Crosshair(200, 134)
    fxspeed   = FXspeed()
    laser     = Laser()
    energy    = EnergyMeter(ship)

    for i = 1, Config.Space.meteoriteNearCount do
        meteoritesNear[i] = Meteorite(math.random(0, 400), math.random(8, 232), 3)
    end
    for i = 1, Config.Space.meteoriteFarCount do
        local m = Meteorite(math.random(0, 400), math.random(8, 232), 6)
        m:setScale(Config.Space.meteoriteFarScale)
        meteoritesFar[i] = m
    end

    dangerBar     = DangerBar()
    healthDisplay = HealthDisplay(energy.xPos - 28, energy.yPos)

    playdate.startAccelerometer()
end

function scene:start()
    scene.super.start(self)
end

function scene:update()
    scene.super.update(self)

    if ship == nil then return end

    -- crosshair: fighter mode only
    if ship.mode == 'fighter' then
        local ax, ay = playdate.readAccelerometer()
        ax = ax or 0
        ay = ay or 0

        if not calibrated and (ax ~= 0 or ay ~= 0) then
            baseAx     = ax
            baseAy     = ay
            calibrated = true
        end

        local accelMoving = math.abs(ax - prevAx) >= Config.Space.accelIdleThreshold
                         or math.abs(ay - prevAy) >= Config.Space.accelIdleThreshold

        local spd   = Config.Space.crosshairSpeed
        local moved = false
        if playdate.buttonIsPressed(playdate.kButtonUp)    then cursorY = math.max(0,   cursorY - spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonDown)  then cursorY = math.min(240, cursorY + spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonLeft)  then cursorX = math.max(0,   cursorX - spd) moved = true end
        if playdate.buttonIsPressed(playdate.kButtonRight) then cursorX = math.min(400, cursorX + spd) moved = true end

        local sens = Config.Space.accelSensitivity
        if moved then
            baseAx = ax - (cursorX - 200) / (200 * sens)
            baseAy = ay - (cursorY - 120) / (120 * sens)
            calibrated = true
        end

        if accelMoving or moved then
            idleFrames = 0
        else
            idleFrames = idleFrames + 1
            if idleFrames >= Config.Space.accelIdleFrames and calibrated then
                local lr = Config.Space.accelCenterReturnLerp
                baseAx = baseAx + (ax - baseAx) * lr
                baseAy = baseAy + (ay - baseAy) * lr
            end
        end
        prevAx = ax
        prevAy = ay

        local targetX = math.max(0, math.min(400, 200 + (ax - baseAx) * 200 * sens))
        local targetY = math.max(0, math.min(240, 120 + (ay - baseAy) * 120 * sens))
        local lf      = Config.Space.lerpFactor
        cursorX = cursorX + (targetX - cursorX) * lf
        cursorY = cursorY + (targetY - cursorY) * lf

        crosshair:moveTo(cursorX, cursorY)
    end

    -- speed decay: fighter mode only; travel mode holds speed
    if ship.mode == 'fighter' then
        ship.speed = math.max(0, ship.speed - Config.Space.speedDecay)
    end

    -- danger bar
    if ship.speed < Config.Space.minSpeed then
        danger = math.min(1, danger + Config.Space.dangerFillRate)
    else
        danger = math.max(0, danger - Config.Space.dangerDrainRate)
    end
    dangerBar:update(danger)
    if danger >= 1 then
        Noble.transition(TitleScene)
        return
    end

    -- meteorite scroll + parallax
    local py, px = 0, 0
    if playdate.buttonIsPressed(playdate.kButtonUp)    then py =  Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonDown)  then py = -Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonLeft)  then px =  Config.Space.parallaxSpeed end
    if playdate.buttonIsPressed(playdate.kButtonRight) then px = -Config.Space.parallaxSpeed end

    local nearDX  = -(Config.Space.meteoriteNearSpeed + ship.speed * Config.Space.meteoriteSpeedMult)
    local farDX   = -(Config.Space.meteoriteFarSpeed  + ship.speed * Config.Space.meteoriteSpeedMult)
    local farMult = Config.Space.meteoriteFarParallax

    for i = 1, #meteoritesNear do
        meteoritesNear[i]:scrollBy(nearDX + px, py)
    end
    for i = 1, #meteoritesFar do
        meteoritesFar[i]:scrollBy(farDX + px * farMult, py * farMult)
    end

    -- collision detection
    if invFrames > 0 then
        invFrames -= 1
    else
        local hit = false
        for i = 1, #meteoritesNear do
            if ship:overlapsWithSprite(meteoritesNear[i]) then hit = true break end
        end
        if not hit then
            for i = 1, #meteoritesFar do
                if ship:overlapsWithSprite(meteoritesFar[i]) then hit = true break end
            end
        end
        if hit then
            health    -= 1
            invFrames  = Config.Space.invincibilityFrames
            healthDisplay:update(health)
            if health <= 0 then
                Noble.transition(TitleScene)
                return
            end
        end
    end
end

function scene:exit()
    scene.super.exit(self)

    playdate.stopAccelerometer()

    if ship          then ship:remove()          ship          = nil end
    if crosshair     then crosshair:remove()     crosshair     = nil end
    if fxspeed       then fxspeed:remove()       fxspeed       = nil end
    if laser         then laser:remove()         laser         = nil end
    if energy        then energy:remove()        energy        = nil end
    if dangerBar     then dangerBar:remove()     dangerBar     = nil end
    if healthDisplay then healthDisplay:remove() healthDisplay = nil end

    for i = 1, #meteoritesNear do meteoritesNear[i]:remove() end
    for i = 1, #meteoritesFar  do meteoritesFar[i]:remove()  end
    meteoritesNear = {}
    meteoritesFar  = {}
end

function scene:finish()
    scene.super.finish(self)
    Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

scene.inputHandler = {
    AButtonDown = function()
        if ship and ship.mode == 'fighter' then
            laser:draw(ship, crosshair, energy)
        end
    end,

    BButtonDown = function()
        if ship and ship.mode == 'fighter' and ship.energy > 1 then
            fxspeed.animation:setState('startSpeed')
        end
    end,
    BButtonHeld = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 then
            fxspeed.animation:setState('loopSpeed')
        else
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonHold = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 then
            ship:boost('fighter')
            energy:drain(ship)
        end
        if ship.energy == 0 then
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonUp = function()
        if ship == nil or ship.mode ~= 'fighter' then return end
        if ship.energy > 0 and ship.speed > 0 then
            fxspeed.animation:setState('stopSpeed')
        elseif ship.energy == 0 then
            fxspeed.animation:setState('initial')
        end
    end,

    leftButtonDown  = function() if ship then ship:move('left')    end end,
    leftButtonUp    = function() if ship then ship:move('default') end end,
    rightButtonDown = function() if ship then ship:move('right')   end end,
    rightButtonUp   = function() if ship then ship:move('default') end end,
    upButtonDown    = function() if ship then ship:move('up')      end end,
    upButtonUp      = function() if ship then ship:move('default') end end,
    downButtonDown  = function() if ship then ship:move('down')    end end,
    downButtonUp    = function() if ship then ship:move('default') end end,

    cranked = function(change, _)
        if ship and ship.mode == 'travel' and ship.energy <= 100 and playdate.getCrankTicks(3) > 0 then
            energy:fill(ship, 1)
        end
    end,

    crankDocked = function()
        if ship == nil then return end
        ship.changeMode = true
        ship.mode       = 'fighter'
        ship.animation:setState('travelToFighter')
        ship:setTarget(shipX, shipY)
        energy:resetPosition(shipX, shipY)
        if healthDisplay then healthDisplay:moveTo(energy.xPos - 28, energy.yPos) end
        calibrated = false
    end,

    crankUndocked = function()
        if ship == nil then return end
        ship.changeMode = true
        ship.mode       = 'travel'
        ship.animation:setState('fighterToTravel')
        ship:setTarget(shipX, shipY + 20)
        energy:resetPosition(shipX, shipY + 20)
        if healthDisplay then healthDisplay:moveTo(energy.xPos - 28, energy.yPos) end
        cursorX    = 200
        cursorY    = 120
        calibrated = false
        if crosshair then crosshair:moveTo(200, 120) end
    end,
}
```

> **Note:** `ship.speed = 0` is removed from `crankUndocked`. In travel mode, speed holds at its current value — the player accumulated it by boosting and should keep it while charging.

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

- [ ] **Open in simulator and verify:**
  - Meteorites scroll left from the start.
  - Moving the ship with d-pad: meteorites shift in the opposite direction (parallax).
  - Danger bar (right side) starts filling when ship is slow; drains when boosting.
  - Hitting a meteorite removes one health dot (left of canister). Three hits → TitleScene.
  - Danger bar full → TitleScene.
  - Pulling out the crank (travel mode): meteorites still scroll, speed holds, no decay.
  - Cranking in travel mode fills energy. Docking crank resumes fighter mode.
