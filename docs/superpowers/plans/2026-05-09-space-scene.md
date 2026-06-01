# SpaceScene Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the space mini-game as a Noble Engine scene with Ship, Crosshair, FXspeed, Meteorite, Laser, and EnergyMeter entities — porting from the deleted StarScene with targeted improvements.

**Architecture:** All entities live under `source/entities/space/`. The Crosshair is positioned by `SpaceScene:update()` using the same accelerometer + lerp pattern as CockpitScene. Ship animation transitions only fire on mode/direction changes (not every frame). EnergyMeter global variable leak is fixed with instance variables.

**Tech Stack:** Playdate Lua SDK, Noble Engine (`NobleSprite` for Ship/FXspeed/Meteorite, `Graphics.sprite` for Crosshair/Laser/EnergyMeter). No test runner — validate in simulator.

**IMPORTANT:** Never run `git commit`. Compile with `pdc` to verify after each task.

---

## File Map

| File | Change |
|------|--------|
| `source/assets/data/Config.lua` | Add `Config.Space` block |
| `source/entities/space/Ship.lua` | Create — NobleSprite, all original states, mode-change fix |
| `source/entities/space/Crosshair.lua` | Create — Graphics.sprite, positioned by scene |
| `source/entities/space/FXspeed.lua` | Create — NobleSprite, path update only |
| `source/entities/space/Meteorite.lua` | Create — NobleSprite (upgrade from animation.loop) |
| `source/entities/space/Laser.lua` | Create — procedural lines, no globals |
| `source/entities/space/EnergyCanister.lua` | Create — Graphics.sprite, EnergyTank image |
| `source/entities/space/EnergyMeter.lua` | Create — Graphics.sprite, fixed global variables |
| `source/scenes/SpaceScene.lua` | Create — Noble scene, wires all entities |
| `source/main.lua` | Uncomment/replace StarScene import with SpaceScene |

---

## Task 1: Add Config.Space

**Files:**
- Modify: `source/assets/data/Config.lua`

- [ ] **Step 1: Read lines 209–217 to confirm the end of the file**

```
source/assets/data/Config.lua lines 209–217:
Config.Cockpit = {
    lerpFactor       = 0.15,
    accelSensitivity = 2.0,
    pointerRadius    = 6,
    dpadSpeed        = 3,
    failLimit        = 10,
}

return Config
```

- [ ] **Step 2: Add Config.Space before `return Config`**

Find:
```lua
    failLimit        = 10,    -- max wrong button presses before returning to TitleScene
}

return Config
```

Replace with:
```lua
    failLimit        = 10,    -- max wrong button presses before returning to TitleScene
}

Config.Space = {
    crosshairSpeed   = 4,    -- d-pad pixels per frame
    lerpFactor       = 0.08, -- spring toward accel target (0=frozen, 1=instant)
    accelSensitivity = 1.2,  -- multiplier on raw accelerometer tilt
}

return Config
```

- [ ] **Step 3: Compile**

```bash
cd /Users/dactrtr-mini/Documents/GitHub/Dinopirates
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 2: Ship entity

**Files:**
- Create: `source/entities/space/Ship.lua`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p /Users/dactrtr-mini/Documents/GitHub/Dinopirates/source/entities/space
```

- [ ] **Step 2: Create Ship.lua**

```lua
class('Ship').extends(NobleSprite)

function Ship:init(startX, startY, hull, speed, zIndex)
    Ship.super.init(self, 'assets/images/space/ship', true)

    self.animation:addState('fighter',         9,  9)
    self.animation:addState('travel',          5,  5)
    self.animation:addState('fighterdown',     3,  3)
    self.animation:addState('fighterup',       4,  4)
    self.animation:addState('traveldown',      1,  1)
    self.animation:addState('travelup',        2,  2)
    self.animation:addState('travelToFighter', 5,  9, 'fighter', 3)
    self.animation:addState('fighterToTravel', 9, 13, 'travel',  3)
    self.animation:addState('fighterleft',    15, 15)
    self.animation:addState('fighterright',   14, 14)

    self:setSize(80, 60)
    self:setZIndex(zIndex)
    self:moveTo(startX, startY)
    self:setGroups(2)

    self.speed       = speed
    self.mode        = 'fighter'
    self.direction   = 'default'
    self.energy      = 100
    self.energyTotal = 100
    self.changeMode  = false

    self.lastMode      = nil
    self.lastDirection = nil

    self.shooter01 = { x = startX - 28, y = startY - 8 }
    self.shooter02 = { x = startX + 28, y = startY - 8 }
    self.shooter03 = { x = startX - 28, y = startY + 8 }
    self.shooter04 = { x = startX + 28, y = startY + 8 }

    self:add()
end

function Ship:move(direction)
    self.direction = direction
    if direction == 'default' then
        -- idle transition handled in update()
    elseif direction == 'down' then
        self.animation:setState(self.mode == 'fighter' and 'fighterdown' or 'traveldown')
    elseif direction == 'up' then
        self.animation:setState(self.mode == 'fighter' and 'fighterup' or 'travelup')
    elseif direction == 'left' then
        if self.mode == 'fighter' then self.animation:setState('fighterleft') end
    elseif direction == 'right' then
        if self.mode == 'fighter' then self.animation:setState('fighterright') end
    end
end

function Ship:boost(mode)
    if self.energy > 0 and self.mode == mode then
        self.speed  += 1
        self.energy -= 1
    end
end

function Ship:update()
    local modeChanged = self.mode ~= self.lastMode
    local dirChanged  = self.direction ~= self.lastDirection
    self.lastMode      = self.mode
    self.lastDirection = self.direction

    if self.changeMode then
        self.changeMode = false
        return
    end

    if self.direction == 'default' and (modeChanged or dirChanged) then
        if self.mode == 'fighter' then
            self.animation:setState('travelToFighter', false, self.animation.fighter)
        elseif self.mode == 'travel' then
            self.animation:setState('fighterToTravel', false, self.animation.travel)
        end
    end
end
```

- [ ] **Step 3: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 3: Crosshair entity

**Files:**
- Create: `source/entities/space/Crosshair.lua`

All movement logic lives in SpaceScene:update() — the entity is a thin wrapper around Graphics.sprite. This matches the CockpitScene/CockpitPointer pattern where the scene owns all positional logic.

- [ ] **Step 1: Create Crosshair.lua**

```lua
class('Crosshair').extends(Graphics.sprite)

local crosshairImage = Graphics.image.new('assets/images/ui/crosshair')

function Crosshair:init(x, y)
    self:setImage(crosshairImage)
    self:setZIndex(ZIndex.ui + 10)
    self:moveTo(x, y)
    self:add()
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 4: FXspeed entity

**Files:**
- Create: `source/entities/space/FXspeed.lua`

Direct port from old `entities/FX/FXspeed.lua` — only the asset path changes.

- [ ] **Step 1: Create FXspeed.lua**

```lua
class('FXspeed').extends(NobleSprite)

function FXspeed:init()
    FXspeed.super.init(self, 'assets/images/space/fx-speed', true)

    self.animation:addState('initial',    1,  1)
    self.animation:addState('startSpeed', 1,  8)
    self.animation.startSpeed.frameDuration = 2
    self.animation:addState('loopSpeed',  9, 14)
    self.animation.loopSpeed.frameDuration  = 4
    self.animation:addState('stopSpeed', 15, 22, 'initial')
    self.animation.stopSpeed.frameDuration  = 4

    self:setSize(400, 240)
    self:setZIndex(ZIndex.fx)
    self:add(200, 120)
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 5: Meteorite entity

**Files:**
- Create: `source/entities/space/Meteorite.lua`

Upgrade from `Graphics.animation.loop` to NobleSprite. The old code had a module-level `Meteo` sprite shared across all instances — corrupted if you spawned more than one. Fixed with instance-level animation via NobleSprite.

- [ ] **Step 1: Create Meteorite.lua**

```lua
class('Meteorite').extends(NobleSprite)

function Meteorite:init(x, y, speed)
    Meteorite.super.init(self, 'assets/images/space/meteorite', true)

    self.animation:addState('spin', 1, 4)
    self.animation.spin.frameDuration = speed or 4

    self:setGroups(1)
    self:setZIndex(ZIndex.props)
    self:moveTo(x, y)
    self:add()
end

function Meteorite:updateSpeed(speed)
    self.animation.spin.frameDuration = speed
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 6: Laser entity

**Files:**
- Create: `source/entities/space/Laser.lua`

Direct port of old `entities/ship/laser.lua`. Removes global `crosshair` and `ship` references — both passed as parameters instead. Removes debug `print` statements. Uses `playdate.timer.performAfterDelay` (correct SDK API) instead of old `timers.performAfterDelay`.

- [ ] **Step 1: Create Laser.lua**

```lua
class('Laser').extends(Graphics.sprite)

function Laser:init()
    self.laserBG = Graphics.image.new(400, 240)
    self:setImage(self.laserBG)
    self:setZIndex(ZIndex.ui)
    self:moveTo(200, 120)
    self:add()
end

function Laser:draw(ship, crosshair)
    if ship.energy <= 0 then return end

    local modX, modY = 0, 0
    if playdate.buttonIsPressed(playdate.kButtonLeft)  then modY =  8  modX =  2 end
    if playdate.buttonIsPressed(playdate.kButtonRight) then modY = -8  modX = -2 end

    Graphics.pushContext(self.laserBG)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.setLineWidth(1)
        Graphics.setLineCapStyle(Graphics.kLineCapStyleButt)
        Graphics.drawLine(ship.shooter01.x,        ship.shooter01.y + modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter02.x,        ship.shooter02.y - modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter03.x - modX, ship.shooter03.y + modY, crosshair.x, crosshair.y)
        Graphics.drawLine(ship.shooter04.x,        ship.shooter04.y - modY, crosshair.x, crosshair.y)
    Graphics.popContext()

    playdate.timer.performAfterDelay(6, function()
        self.laserBG:clear(Graphics.kColorClear)
        ship.energy -= 10
    end)
end

function Laser:off()
    self.laserBG:clear(Graphics.kColorClear)
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 7: EnergyCanister entity

**Files:**
- Create: `source/entities/space/EnergyCanister.lua`

Direct port of old `entities/ship/energyCanister.lua` with path update. The image `assets/images/ui/EnergyTank.png` was recovered from git history and exists in the source tree.

- [ ] **Step 1: Create EnergyCanister.lua**

```lua
class('EnergyCanister').extends(Graphics.sprite)

local meterImage = Graphics.image.new('assets/images/ui/EnergyTank')

function EnergyCanister:init(x, y)
    self:moveTo(x, y)
    self:setImage(meterImage, Graphics.kImageFlippedY)
    self:setZIndex(ZIndex.ui + 2)
    self:add()
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 8: EnergyMeter entity

**Files:**
- Create: `source/entities/space/EnergyMeter.lua`

Port of old `entities/ship/energyMeter.lua`. Key fixes:
- `distanceFromShip`, `xPos`, `yPos`, `canister` were module-level globals — now `self.*` instance variables.
- `ship` was accessed as a global in every method — now passed as a parameter.
- `updateEnergy()` only recreates the image when energy actually changes (tracked via `self.lastEnergy`).
- `remove()` overridden to also remove the canister.

- [ ] **Step 1: Create EnergyMeter.lua**

```lua
import 'entities/space/EnergyCanister'

class('EnergyMeter').extends(Graphics.sprite)

function EnergyMeter:init(ship)
    self.distanceFromShip = 48
    self.xPos = ship.x - self.distanceFromShip
    self.yPos = ship.y - 12
    self.lastEnergy = nil

    self.canister = EnergyCanister(self.xPos, self.yPos)
    self:moveTo(self.xPos, ship.y)
    self:setZIndex(ZIndex.ui + 1)
    self:updateEnergy(ship)
    self:add()
end

function EnergyMeter:updateEnergy(ship)
    if self.lastEnergy == ship.energy then return end
    self.lastEnergy = ship.energy

    local maxHeight = 42
    local width = 8
    local barH = (ship.energy / ship.energyTotal) * maxHeight
    local img = Graphics.image.new(width, maxHeight)
    Graphics.pushContext(img)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillRect(0, 0, width, barH)
    Graphics.popContext()
    self:setImage(img, Graphics.kImageFlippedY)

    if ship.energy >= ship.energyTotal then
        self:setRotation(0)
        self.canister:setRotation(0)
    end
end

function EnergyMeter:drain(ship)
    if ship.energy > 0 and ship.mode == 'fighter' then
        local mov = math.random(-1, 1)
        self:moveBy(mov, mov)
        self.canister:moveBy(mov, mov)
        self:updateEnergy(ship)
    end
end

function EnergyMeter:fill(ship, amount)
    if ship.mode == 'travel' then
        local mov = math.random(-10, 10)
        self:setRotation(mov)
        self.canister:setRotation(mov)
        ship.energy += amount
    end
    self:updateEnergy(ship)
end

function EnergyMeter:resetPosition(ship)
    self.xPos = ship.x - self.distanceFromShip
    self.yPos = ship.y - 12
    self:setRotation(0)
    self.canister:setRotation(0)
    self:moveTo(self.xPos, ship.y)
    self.canister:moveTo(self.xPos + 2, ship.y)
end

function EnergyMeter:update()
    if math.abs(self.x - self.xPos) > 2 or math.abs(self.y - self.yPos) > 2 then
        self:moveTo(self.xPos, self.yPos)
        self.canister:moveTo(self.xPos + 2, self.yPos)
    end
end

function EnergyMeter:remove()
    if self.canister then self.canister:remove() end
    EnergyMeter.super.remove(self)
end
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 9: SpaceScene

**Files:**
- Create: `source/scenes/SpaceScene.lua`

The scene owns all movement logic for the crosshair (accelerometer + d-pad + lerp spring) — same pattern as CockpitScene. Ship animation transitions are handled by Ship:update() internally. D-pad hold callbacks are not needed since `buttonIsPressed` in `scene:update()` handles continuous crosshair movement.

- [ ] **Step 1: Create SpaceScene.lua**

```lua
import 'entities/space/Ship'
import 'entities/space/Crosshair'
import 'entities/space/FXspeed'
import 'entities/space/Meteorite'
import 'entities/space/Laser'
import 'entities/space/EnergyMeter'

SpaceScene = {}
class('SpaceScene').extends(NobleScene)
local scene = SpaceScene

scene.backgroundColor = Graphics.kColorBlack

local ship      = nil
local crosshair = nil
local fxspeed   = nil
local laser     = nil
local energy    = nil

local cursorX    = 200
local cursorY    = 120
local baseAx     = 0
local baseAy     = 0
local calibrated = false

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

    ship      = Ship(shipX, shipY, 4, 0, ZIndex.player)
    crosshair = Crosshair(200, 134)
    fxspeed   = FXspeed()
    laser     = Laser()
    energy    = EnergyMeter(ship)

    playdate.startAccelerometer()
end

function scene:start()
    scene.super.start(self)
end

function scene:update()
    scene.super.update(self)

    if ship == nil or ship.mode ~= 'fighter' then return end

    local ax, ay = playdate.readAccelerometer()
    ax = ax or 0
    ay = ay or 0

    if not calibrated and (ax ~= 0 or ay ~= 0) then
        baseAx     = ax
        baseAy     = ay
        calibrated = true
    end

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

    local targetX = math.max(0, math.min(400, 200 + (ax - baseAx) * 200 * sens))
    local targetY = math.max(0, math.min(240, 120 + (ay - baseAy) * 120 * sens))
    local lf      = Config.Space.lerpFactor
    cursorX = cursorX + (targetX - cursorX) * lf
    cursorY = cursorY + (targetY - cursorY) * lf

    crosshair:moveTo(cursorX, cursorY)
end

function scene:exit()
    scene.super.exit(self)

    playdate.stopAccelerometer()

    if ship      then ship:remove()      ship      = nil end
    if crosshair then crosshair:remove() crosshair = nil end
    if fxspeed   then fxspeed:remove()   fxspeed   = nil end
    if laser     then laser:remove()     laser     = nil end
    if energy    then energy:remove()    energy    = nil end
end

function scene:finish()
    scene.super.finish(self)
    Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end

scene.inputHandler = {
    AButtonDown = function()
        if ship and ship.mode == 'fighter' then
            laser:draw(ship, crosshair)
        end
    end,

    BButtonDown = function()
        if ship and ship.energy > 1 then
            fxspeed.animation:setState('startSpeed')
        end
    end,
    BButtonHeld = function()
        if ship == nil then return end
        if ship.energy > 0 then
            fxspeed.animation:setState('loopSpeed')
        else
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonHold = function()
        if ship == nil then return end
        if ship.energy > 0 then
            ship:boost('fighter')
            energy:drain(ship)
        end
        if ship.energy == 0 then
            fxspeed.animation:setState('stopSpeed')
        end
    end,
    BButtonUp = function()
        if ship == nil then return end
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
        ship:moveTo(shipX, shipY)
        energy:resetPosition(ship)
        calibrated = false
    end,

    crankUndocked = function()
        if ship == nil then return end
        ship.changeMode = true
        ship.mode  = 'travel'
        ship.speed = 0
        ship:moveTo(shipX, shipY + 20)
        cursorX    = 200
        cursorY    = 120
        calibrated = false
        if crosshair then crosshair:moveTo(200, 120) end
    end,
}
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 10: Register SpaceScene in main.lua

**Files:**
- Modify: `source/main.lua:16`

- [ ] **Step 1: Replace the commented StarScene import**

Find:
```lua
--import 'scenes/StarScene'
```

Replace with:
```lua
import 'scenes/SpaceScene'
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 11: Verify in simulator

No test runner — visual validation only.

- [ ] **Step 1: Open in simulator**

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

- [ ] **Step 2: Reach SpaceScene**

Temporarily add a transition to SpaceScene from TitleScene (debug menu or cheat code), or modify `Noble.new(TitleScene)` in `main.lua` to `Noble.new(SpaceScene)` for testing. Revert after verifying.

- [ ] **Step 3: Fighter mode checklist (crank docked)**

1. Ship displays at center — `fighter` animation state
2. Crosshair starts at (200, 134)
3. D-pad moves crosshair in correct direction
4. Tilting device moves crosshair via accelerometer
5. Releasing d-pad/flattening device — crosshair springs back toward center
6. D-pad ButtonDown → ship changes to direction animation (fighterup, fighterdown, fighterleft, fighterright)
7. D-pad ButtonUp → ship returns to `travelToFighter` → `fighter` transition
8. A button → laser lines drawn from 4 shooter points to crosshair, clear after ~6ms
9. B button → FXspeed effect plays (startSpeed → loopSpeed while held → stopSpeed on release)
10. B hold → ship.energy drains, EnergyMeter bar decreases

- [ ] **Step 4: Travel mode checklist (crank undocked)**

1. Ship moves to (200, 170), `fighterToTravel` → `travel` animation plays
2. Crosshair snaps to center (200, 120) and stays there
3. D-pad does not move crosshair
4. Crank rotation fills energy — EnergyMeter bar increases, canister shakes
5. B button does NOT trigger laser or boost

- [ ] **Step 5: Mode switch back to fighter**

1. Dock crank → ship returns to (200, 150), `travelToFighter` → `fighter` plays
2. All fighter-mode inputs work again

- [ ] **Step 6: Revert any test-only changes to main.lua**

If you changed `Noble.new(TitleScene)` to `Noble.new(SpaceScene)`, revert it now:
```lua
Noble.new(TitleScene, 0.3, Noble.Transition.MetroNexus)
```

---

## Task 12: Write SPACE_SCENE.md documentation

**Files:**
- Create: `source/DOCS/SPACE_SCENE.md`

- [ ] **Step 1: Write the doc**

```markdown
# SpaceScene

Space mini-game scene. Player controls a ship with a crosshair cursor, fires lasers, and manages energy via the crank.

## Scene Lifecycle

`SpaceScene` follows standard Noble Engine lifecycle: `init → enter → start → update → exit`.

- `enter()` — spawns all entities, starts accelerometer
- `update()` — reads accelerometer, moves crosshair via lerp (fighter mode only)
- `exit()` — removes all entities, stops accelerometer

## Entities

| Entity | File | Role |
|--------|------|------|
| `Ship` | `entities/space/Ship.lua` | NobleSprite — animated ship, two-mode system |
| `Crosshair` | `entities/space/Crosshair.lua` | Graphics.sprite — cursor, positioned by scene |
| `FXspeed` | `entities/space/FXspeed.lua` | NobleSprite — full-screen speed effect |
| `Meteorite` | `entities/space/Meteorite.lua` | NobleSprite — scrolling meteorite obstacle |
| `Laser` | `entities/space/Laser.lua` | Graphics.sprite — procedural laser lines |
| `EnergyMeter` | `entities/space/EnergyMeter.lua` | Graphics.sprite — energy bar (owns EnergyCanister) |

## Crank Mode System

The crank controls the ship's mode:

| Crank | Mode | Behavior |
|-------|------|----------|
| Docked | `fighter` | Crosshair active, laser fires, boost available |
| Undocked | `travel` | Crosshair locked at center, crank fills energy |

Mode changes set `ship.changeMode = true` to suppress Ship:update() animation transitions for one frame (prevents interrupting the mode-switch animation).

## Crosshair Movement

Position is owned entirely by `SpaceScene:update()` — the Crosshair entity is a thin sprite.

In fighter mode each frame:
1. D-pad moves `cursorX`/`cursorY` directly (`Config.Space.crosshairSpeed` px/frame)
2. When d-pad moves, the accelerometer base is re-anchored so the lerp doesn't fight the new position
3. Accelerometer target computed as `200 + (ax - baseAx) * 200 * sensitivity`
4. `cursorX` lerps toward the accel target at `Config.Space.lerpFactor` per frame — produces a spring-back-to-center effect when device is flat

In travel mode the crosshair is locked at (200, 120) and the update returns early.

## Energy System

- `ship.energy` starts at 100, max 100
- **Fighter mode:** A button fires laser (costs 10 energy per shot via 6ms timer). B hold boosts speed (costs 1/frame).
- **Travel mode:** Crank rotation fills energy by 1 per crank tick (3-tick threshold).
- `EnergyMeter` displays a vertical bar. `EnergyCanister` is a decorative sprite attached to the meter.

## Config

All tunable values in `Config.Space`:

```lua
Config.Space = {
    crosshairSpeed   = 4,    -- d-pad pixels per frame
    lerpFactor       = 0.08, -- spring smoothing (0=frozen, 1=instant)
    accelSensitivity = 1.2,  -- multiplier on raw accelerometer tilt
}
```
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.
