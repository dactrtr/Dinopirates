# SpaceScene — Space Escape

**File**: `scenes/SpaceScene.lua`
**Entities**: `entities/space/`

A space escape sequence. The ship operates in two modes toggled by the crank: **fighter** (crank docked) for combat and evasion, and **travel** (crank undocked) for recharging energy. The game ends if danger reaches maximum or health drops to zero; both conditions lead to TitleScene.

Background: `Graphics.kColorBlack`.

---

## Local State

| Variable | Type | Purpose |
|---|---|---|
| `ship` | Ship | Main ship sprite |
| `crosshair` | Crosshair | Aiming reticle, active only in fighter mode |
| `fxspeed` | FXspeed | Full-screen speed line overlay |
| `laser` | Laser | Full-screen laser line overlay |
| `energy` | EnergyMeter | Vertical energy bar in the HUD |
| `dangerBar` | DangerBar | Vertical danger indicator on the right edge |
| `healthDisplay` | HealthDisplay | Three health circles |
| `meteoritesNear` | table | 14 foreground Meteorite sprites |
| `meteoritesFar` | table | 10 background Meteorite sprites (scale 0.6) |
| `cursorX / cursorY` | number | Current crosshair position |
| `baseAx / baseAy` | number | Accelerometer calibration baseline |
| `calibrated` | bool | Whether the accelerometer has been calibrated |
| `prevAx / prevAy` | number | Accelerometer values from the previous frame (idle detection) |
| `idleFrames` | number | Consecutive frames without movement (for automatic recentering) |
| `danger` | number | 0–1; fills when speed is low |
| `health` | number | Starts at 3; scene ends when it reaches 0 |
| `invFrames` | number | Remaining invincibility frames after a hit |
| `shakeFrames` | number | Remaining screen shake frames after a hit |
| `shipX / shipY` | number | Fixed ship target position (200, 150); lerped toward this |

---

## Scene Lifecycle

### `init()`
Only calls `scene.super.init`. No additional logic.

### `enter()`
1. Resets all state variables to their initial values: `danger = 0`, `health = 3`, `invFrames = 0`, `shakeFrames = 0`, accelerometer uncalibrated.
2. Creates `Ship(shipX, shipY, 4, 0, ZIndex.player)` — hull=4, initial speed=0.
3. Creates `Crosshair(200, 134)`.
4. Creates `FXspeed()`, `Laser()`, `EnergyMeter(ship)`.
5. Creates the near meteorite pool (14 units, base speed `Config.Space.meteoriteNearSpeed = 3`) and far pool (10 units, base speed `Config.Space.meteoriteFarSpeed = 1.5`, scale `Config.Space.meteoriteFarScale = 0.6`).
6. Creates `DangerBar()` and `HealthDisplay(energy.xPos - 28, energy.yPos)`.
7. Calls `playdate.startAccelerometer()`.

### `start()`
Only calls `scene.super.start`. No additional logic.

### `update()`
Returns immediately if `ship == nil`. Each frame:
1. Fighter mode: updates crosshair position with accelerometer + D-pad.
2. Fighter mode: applies speed decay (`speedDecay`).
3. Updates the danger bar based on current speed.
4. If `danger >= 1` → `Noble.transition(TitleScene)`.
5. Applies parallax movement to meteorites based on D-pad.
6. Advances all meteorites via `step(shipBonus)`.
7. Detects collisions (if `invFrames == 0`).
8. Applies shake to the ship if `shakeFrames > 0`.

### `exit()`
1. Calls `playdate.stopAccelerometer()`.
2. Removes and nil-ifies all sprites: `ship`, `crosshair`, `fxspeed`, `laser`, `energy`, `dangerBar`, `healthDisplay`.
3. Removes all meteorites from both pools and clears the tables.

### `finish()`
Resets the draw mode to `Graphics.kDrawModeCopy`.

---

## Ship — Position and Control

The ship (`Ship`) has a fixed target position at `(shipX, shipY) = (200, 150)`. Each frame in `Ship:update()` it lerps toward `(targetX, targetY)` with `Config.Space.shipMoveLerp = 0.12`:
```
nx = x + (targetX - x) * 0.12
ny = y + (targetY - y) * 0.12
```
The ship does not move freely on screen — the D-pad controls the crosshair and meteorite parallax, not the ship position.

**Collider**: rect 20×10 of size 40×40 (`setCollideRect(20, 10, 40, 40)`), sprite size 80×60, collision group 2.

**Firing points** (relative to shipX=200, shipY=150):
| Point | Offset X | Offset Y |
|---|---|---|
| shooter01 | −28 | −8 |
| shooter02 | +28 | −8 |
| shooter03 | −28 | +8 |
| shooter04 | +28 | +8 |

---

## Fighter Mode vs Travel Mode

The crank acts as a mode switch. The transition plays a frame animation before settling.

| Mode | Crank state | Ship target Y | Crosshair | Speed decay |
|---|---|---|---|---|
| `fighter` | docked | 150 (`shipY`) | active | yes (−0.05/frame) |
| `travel` | undocked | 170 (`shipY + 20`) | hidden | no |

**Transition `crankDocked` → fighter**:
1. `ship.mode = 'fighter'`
2. `ship.animation:setState('travelToFighter')` (frames 5→9, speed 3)
3. `ship:setTarget(shipX, shipY)`
4. `energy:resetPosition(shipX, shipY)`, `healthDisplay` repositioned
5. `calibrated = false` — recalibrates the accelerometer

**Transition `crankUndocked` → travel**:
1. `ship.mode = 'travel'`
2. `ship.animation:setState('fighterToTravel')` (frames 9→13, speed 3)
3. `ship:setTarget(shipX, shipY + 20)`
4. `energy:resetPosition(shipX, shipY + 20)`, `healthDisplay` repositioned
5. `cursorX/Y = 200/120`, `calibrated = false`, crosshair resets to center

---

## Crosshair Accelerometer Control (fighter mode)

Only active in fighter mode. Same calibration architecture as CockpitScene.

**Calibration**: first frame with `ax != 0` or `ay != 0` → `baseAx/baseAy = ax/ay`, `calibrated = true`.

**Idle detection**: if `|ax - prevAx| < accelIdleThreshold (0.005)` and `|ay - prevAy| < accelIdleThreshold`, increments `idleFrames`. When `idleFrames >= accelIdleFrames (2)` and `calibrated`, the baseline is gradually lerped toward the current accelerometer values with `accelCenterReturnLerp = 0.04` — this slowly recenters the crosshair without input.

**Base re-anchor (D-pad)**: if the D-pad moves the crosshair, the baseline is recalculated the same way as in CockpitScene.

**Calculation and lerp**:
```
targetX = clamp(0, 400, 200 + (ax - baseAx) * 200 * accelSensitivity)
targetY = clamp(0, 240, 120 + (ay - baseAy) * 120 * accelSensitivity)
cursorX += (targetX - cursorX) * lerpFactor   -- lerpFactor = 0.08
cursorY += (targetY - cursorY) * lerpFactor
```

`Config.Space.crosshairSpeed = 4` px/frame for D-pad.
`Config.Space.accelSensitivity = 1.2`.

---

## Meteorite System

Two independent pools create a depth effect via parallax. Each `Meteorite` uses an integer counter (1–1000) to simulate approaching from deep space.

### Pool Parameters

| Pool | Count | Base Speed | Scale | D-pad Parallax Multiplier |
|---|---|---|---|---|
| Near | 14 | 3 | 1.0 | 1.0× |
| Far | 10 | 1.5 | 0.6 | 0.5× (`meteoriteFarParallax`) |

Far meteorites are created with `m:setScale(0.6)` after initialization.

### Per-frame Advance — `Meteorite:step(extraSpeed)`
```
counter += baseSpeed + extraSpeed
if counter > 1000:
    counter = 1
    reposition at random coordinate (20–380, 20–220)
frame = ceil(counter / 1000 * frameCount)
setImage(frame)
```
`extraSpeed` comes from the ship: `ship.speed * Config.Space.meteoriteSpeedMult (0.2)`. Higher ship speed causes meteorites to approach faster.

### Z-depth System — `Meteorite:getZDepth()`
```
return counter / 1000   -- 0 = far, 1 = at ship level
```

The visible animation frame reflects depth: higher frame = larger meteorite = closer. The sprite grows visually as `counter` advances.

### D-pad Parallax
In fighter mode, the D-pad moves the crosshair (cursorX/Y). At the same time it shifts all meteorites:
- Near: `scrollBy(±parallaxSpeed, ±parallaxSpeed)` = ±3 px
- Far: `scrollBy(±parallaxSpeed * 0.5, ±parallaxSpeed * 0.5)` = ±1.5 px

(The offset is opposite to the D-pad direction: pressing right moves meteorites left, simulating the ship turning.)

---

## Danger System (DangerBar)

The danger bar (`DangerBar`) is a 4×224 px sprite at position `(390, 120)` — right edge of the screen. ZIndex: `ZIndex.ui + 5`. Fills from bottom to top: `fillH = floor(danger * 224)`.

**Per-frame rules (fighter mode)**:
```
if speed < Config.Space.minSpeed (3):
    danger += Config.Space.dangerFillRate (0.002)
if speed >= minSpeed:
    danger -= Config.Space.dangerDrainRate (0.003)
danger = clamp(0, 1)
```

In travel mode no rules are applied — danger holds at its current value.

**Game over**: when `danger >= 1.0` → `Noble.transition(TitleScene)` and immediate return from update.

---

## Health System

`health` starts at 3. Visually represented by `HealthDisplay` (three 8×8 px circles, 8 px apart, positioned 28 px to the left of EnergyMeter).

### Hit Detection
Only active when `invFrames == 0`. Each frame `ship:overlappingSprites()` is called and the result is iterated:
```
for each overlapping sprite:
    if it is in meteoritesNear or meteoritesFar:
        z = meteorite:getZDepth()
        if z >= Config.Space.collisionZoneStart (0.90):
            -> HIT
```
Only meteorites that have completed 90%+ of their approach can deal damage. This prevents unfair hits when a meteorite has just appeared.

### Hit Consequences
```
health -= 1
invFrames = Config.Space.invincibilityFrames (60)
shakeFrames = Config.Space.shakeFrames (25)
healthDisplay:setHealth(health)
if health <= 0:
    Noble.transition(TitleScene)
```

### Invincibility
For 60 frames after a hit, no collision checks are performed (the `invFrames` counter decrements each frame).

### Ship Shake
While `shakeFrames > 0`:
```
mag = ceil(shakeFrames / shakeFrames_total * shakeMagnitude)
ship:moveTo(ship.x + random(-mag, mag), ship.y + random(-mag, mag))
shakeFrames -= 1
```
`shakeMagnitude = 6` px maximum at the start, decays linearly to 0.

---

## Laser and Crosshair (fighter mode)

### Button A — Fire
```lua
AButtonDown → laser:draw(ship, crosshair, energy)
```
Only available in fighter mode. Draws 4 white 1px lines from the ship's firing points toward the crosshair on a 400×240 overlay sprite. After 6ms, the sprite is cleared and `ship.energy -= 10`.

### Button B — Boost
- `BButtonDown` → `fxspeed.animation:setState('startSpeed')`
- `BButtonHeld` → if `ship.energy > 0`: `setState('loopSpeed')`; otherwise: `setState('stopSpeed')`
- `BButtonHold` (each held frame): if `ship.energy > 0`: `ship:boost('fighter')` (+1 speed, −1 energy) + `energy:drain(ship)`
- `BButtonUp` → `setState('stopSpeed')` or `setState('initial')` depending on energy state

`ship.speed` maximum: `Config.Space.maxSpeed = 20`. Boost calls `Ship:boost()`:
```
speed = min(speed + 1, maxSpeed)
energy -= 1
```

---

## EnergyMeter (travel mode)

In travel mode the crank recharges energy:
```lua
cranked: if ship.mode == 'travel' and ship.energy <= 100 and getCrankTicks(3) > 0:
    energy:fill(ship, 1)
```
Every 3 crank ticks adds 1 point of energy.

`ship.energy` starts at 100, maximum 100. Drained −1/frame with boost and −10 per laser shot.

`EnergyMeter` is a vertical 8×42 px bar at `shipX−48, shipY−12`. Fill = `(energy / energyTotal) × 42` px. Lerps its position following the ship with `shipMoveLerp = 0.12`.

---

## Ship Animations (`Ship`)

| State | Frame(s) | Condition |
|---|---|---|
| `fighter` | 9 | Fighter mode idle |
| `travel` | 5 | Travel mode idle |
| `fighterup` | 3 | D-pad up, fighter |
| `fighterdown` | 4 | D-pad down, fighter |
| `fighterleft` | 15 | D-pad left, fighter |
| `fighterright` | 14 | D-pad right, fighter |
| `travelup` | 1 | D-pad up, travel |
| `traveldown` | 2 | D-pad down, travel |
| `travelToFighter` | 5→9 | Travel→fighter transition, speed 3 |
| `fighterToTravel` | 9→13 | Fighter→travel transition, speed 3 |

`Ship:move('default')` returns to the current mode's idle only when the direction actually changed (verified via `lastDirection`). The `changeMode = true` flag prevents the idle reset from applying on the first frame of a mode transition.

---

## FXspeed Animations

| State | Frames | frameDuration | Next |
|---|---|---|---|
| `initial` | 1 | — | — |
| `startSpeed` | 1–8 | 2 | — |
| `loopSpeed` | 9–14 | 4 | — |
| `stopSpeed` | 15–22 | 4 | → `initial` |

---

## Full Input Reference

| Input | Mode | Effect |
|---|---|---|
| Button A | fighter | Fires laser toward crosshair |
| Button B (down) | fighter | Starts `startSpeed` animation |
| Button B (held >1f) | fighter | `loopSpeed` + `ship:boost` + `energy:drain` per frame |
| Button B (up) | fighter | `stopSpeed` or `initial` depending on energy/speed |
| D-pad | fighter | Moves crosshair + meteorite parallax |
| D-pad | travel | Meteorite parallax only |
| Crank (≥3 ticks/detent) | travel | `energy:fill(ship, 1)` per tick |
| Crank docked | either | Switches to fighter mode |
| Crank undocked | either | Switches to travel mode |

---

## UI Layout

| Entity | Position | ZIndex | Notes |
|---|---|---|---|
| Far meteorites ×10 | random | ZIndex.props | Scale 0.6 |
| Near meteorites ×14 | random | ZIndex.props | Scale 1.0 |
| Ship | 200, 150 (lerped) | ZIndex.player | 80×60, collide rect 20,10,40,40 |
| Crosshair | cursorX, cursorY | ZIndex.player − 1 | Fighter mode only |
| FXspeed | 200, 120 | ZIndex.fx | 400×240 overlay |
| Laser | 200, 120 | ZIndex.ui | 400×240 overlay |
| EnergyMeter | shipX−48, shipY−12 | ZIndex.ui + 1 | Vertical bar |
| EnergyCanister | next to EnergyMeter | ZIndex.ui + 2 | Tank icon |
| HealthDisplay | EnergyMeter.xPos−28 | ZIndex.ui + 2 | 3 circles, 8 px apart |
| DangerBar | 390, 120 | ZIndex.ui + 5 | 4×224, right edge |

---

## End Conditions

| Condition | Result |
|---|---|
| `danger >= 1.0` | `Noble.transition(TitleScene)` |
| `health <= 0` | `Noble.transition(TitleScene)` |

There is no victory condition in the current implementation.

---

## Config Reference (`Config.Space`)

| Key | Value | Purpose |
|---|---|---|
| `crosshairSpeed` | 4 | Crosshair px/frame with D-pad |
| `lerpFactor` | 0.08 | Crosshair lerp toward accelerometer target |
| `accelSensitivity` | 1.2 | Accelerometer tilt multiplier |
| `shipMoveLerp` | 0.12 | Ship and EnergyMeter position lerp |
| `accelIdleThreshold` | 0.005 | Minimum accelerometer delta to count as movement |
| `accelIdleFrames` | 2 | Idle frames before auto-recentering begins |
| `accelCenterReturnLerp` | 0.04 | Baseline drift speed toward center |
| `speedDecay` | 0.05 | Speed lost per frame in fighter mode |
| `maxSpeed` | 20 | Speed cap with boost |
| `minSpeed` | 3 | Below this value the danger bar fills |
| `dangerFillRate` | 0.002 | Danger increase per frame when slow |
| `dangerDrainRate` | 0.003 | Danger decrease per frame when fast |
| `meteoriteNearCount` | 14 | Foreground pool size |
| `meteoriteFarCount` | 10 | Background pool size |
| `meteoriteNearSpeed` | 3 | Near pool base approach speed |
| `meteoriteFarSpeed` | 1.5 | Far pool base approach speed |
| `meteoriteSpeedMult` | 0.2 | Ship speed contribution to meteorite extra speed |
| `parallaxSpeed` | 3 | D-pad parallax offset px/frame |
| `meteoriteFarParallax` | 0.5 | Parallax multiplier for the far pool |
| `meteoriteFarScale` | 0.6 | Far pool sprite scale |
| `invincibilityFrames` | 60 | Post-hit immunity frames |
| `collisionZoneStart` | 0.90 | Minimum z-depth for a collision to be valid |
| `shakeFrames` | 25 | Shake duration after a hit |
| `shakeMagnitude` | 6 | Maximum px offset at the start of shake |

---

## Notes — Differences from Love2D / Non-Playdate Environments

- `playdate.startAccelerometer()` / `playdate.stopAccelerometer()` do not exist in Love2D. In a port, replace with an analog joystick or relative mouse movement.
- `playdate.readAccelerometer()` returns `(ax, ay, az)` approximately −1 to 1. Love2D equivalent: `love.joystick:getAxis(1)` / `getAxis(2)`.
- `playdate.getCrankTicks(3)` — the crank is exclusive Playdate hardware. In Love2D it can be simulated with the mouse wheel or a turn button.
- `crankDocked` / `crankUndocked` are Noble Engine callbacks fired when the crank is docked or undocked. No direct equivalent in Love2D.
- `playdate.buttonIsPressed()` is equivalent to `love.keyboard.isDown()`.
- The Playdate sprite system (`Graphics.sprite`) has its own render loop. In Love2D each sprite is drawn manually in `love.draw()`.
