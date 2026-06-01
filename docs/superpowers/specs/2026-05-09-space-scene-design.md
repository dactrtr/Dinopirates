# SpaceScene — Design Spec

## Goal

Restore the space mini-game as a Noble Engine scene (`SpaceScene`), reusing all logic from the deleted StarScene/Ship/Crosshair implementation with targeted improvements: unified file layout, NobleSprite upgrades, lerp-based crosshair spring, and global variable fixes.

## Architecture

| File | Role |
|------|------|
| `source/scenes/SpaceScene.lua` | Noble scene — lifecycle, input, update loop |
| `source/entities/space/Ship.lua` | NobleSprite — animated ship, two-mode system |
| `source/entities/space/Crosshair.lua` | NobleSprite — cursor, d-pad + accelerometer + lerp spring |
| `source/entities/space/FXspeed.lua` | NobleSprite — full-screen speed effect |
| `source/entities/space/Meteorite.lua` | NobleSprite — scrolling meteorite |
| `source/entities/space/Laser.lua` | Graphics.sprite — procedural laser lines |
| `source/entities/space/EnergyMeter.lua` | Graphics.sprite — procedural energy bar |

All entities live under `source/entities/space/`. Previously they were split across `entities/ship/`, `entities/FX/`, and `entities/space/`.

## Config

`Config.Space` added to `source/assets/data/Config.lua`:

```lua
Config.Space = {
    crosshairSpeed   = 4,
    lerpFactor       = 0.08,
    accelSensitivity = 1.2,
}
```

## Ship Entity

**Asset:** `assets/images/space/ship` (was `assets/images/ship/ship`)

**Animation states** — single frame per state, same names and frame numbers as original. The new `ship-table-80-60.png` is the same spritesheet, so all frame numbers are valid:
```lua
self.animation:addState('fighter',        9,  9)
self.animation:addState('travel',         5,  5)
self.animation:addState('fighterdown',    3,  3)
self.animation:addState('fighterup',      4,  4)
self.animation:addState('traveldown',     1,  1)
self.animation:addState('travelup',       2,  2)
self.animation:addState('travelToFighter',5,  9, 'fighter', 3)
self.animation:addState('fighterToTravel',9, 13, 'travel',  3)
self.animation:addState('fighterleft',   15, 15)
self.animation:addState('fighterright',  14, 14)
```

**Fix — mode transition only fires on change:**
The original called `setState('travelToFighter')` every frame while in idle, interrupting direction animations. New behavior: track `self.lastMode` and `self.lastDirection`; fire the transition setState only when either value changes.

**Everything else restored as-is:** `move(direction)`, `boost(mode)`, shooter positions, `energy`, `energyTotal`, `mode`, `speed`.

## Crosshair Entity

**Upgrade:** `Graphics.sprite` → `NobleSprite`

**Asset:** `assets/images/ui/crosshair` — original image recovered from git history.

**Behavior by mode:**

- **Fighter** (crank undocked): moves with d-pad and accelerometer; continuous lerp spring toward center (200, 120).
- **Travel** (crank docked): locked at center; accelerometer ignored.

**Spring — lerp replacing step-based:**
```lua
-- old: if self.x > centerX then self:moveBy(-2, 0) end
-- new (in update, fighter mode):
cursorX = cursorX + (200 - cursorX) * Config.Space.lerpFactor
cursorY = cursorY + (120 - cursorY) * Config.Space.lerpFactor
self:moveTo(cursorX, cursorY)
```

**Accelerometer** follows CockpitScene pattern: calibrate on first non-zero reading, re-anchor base when d-pad moves, combine with lerp target.

## FXspeed Entity

Restored as-is. Only change: asset path.
```lua
-- old: 'assets/images/fx/fx-speed'
-- new: 'assets/images/space/fx-speed'
```
States unchanged: `initial(1,1)`, `startSpeed(1,8)`, `loopSpeed(9,14)`, `stopSpeed(15,22,'initial')`.

## Meteorite Entity

**Upgrade:** `Graphics.animation.loop` → `NobleSprite` animation system.
```lua
Meteorite.super.init(self, 'assets/images/space/meteorite', true)
self.animation:addState('spin', 1, 4)
self.animation.spin.frameDuration = speed
```
Scrolling movement and screen-wrap logic restored as-is.

## Laser Entity

Restored as-is (procedural `Graphics.drawLine` to ship's 4 shooter points toward crosshair). Removed debug `print` statements. The new `explosion-table-36-36.png` asset is available for a future hit effect.

## EnergyMeter Entity

**Fix — instance variables replacing globals:**
```lua
-- old: distanceFromShip, xPos, yPos, canister (module-level globals)
-- new: self.distanceFromShip, self.xPos, self.yPos, self.canister
```
`drain()`, `fill()`, `resetPosition()`, `updateEnergy()` logic restored as-is.

**EnergyCanister:** restored as a separate `Graphics.sprite` using `assets/images/ui/EnergyTank` — image recovered from git history. Lives as `self.canister` (instance variable, not global).

## SpaceScene

Follows CockpitScene structure exactly.

**Lifecycle:**
- `init()` — scene setup, `backgroundColor = Graphics.kColorBlack`
- `enter()` — spawn all entities, `playdate.startAccelerometer()`, reset crosshair position
- `start()` — `scene.super.start(self)` only
- `update()` — accelerometer read + lerp crosshair movement (fighter mode only)
- `exit()` — remove all entities, `playdate.stopAccelerometer()`
- `finish()` — `Graphics.setImageDrawMode(Graphics.kDrawModeCopy)`

**Crank mode switching** (restored from StarScene):
- `crankUndocked` → fighter mode, ship moves to fighter position, start accelerometer
- `crankDocked` → travel mode, ship moves to travel position, stop accelerometer, lock crosshair at center

**Input handler** (restored from StarScene, improved):
- D-pad `ButtonDown` → `ship:move(dir)`, re-anchor accelerometer base
- D-pad `ButtonUp` → `ship:move('default')`
- D-pad `ButtonHold` → crosshair moves (fighter mode only)
- `AButtonDown` → `laser:draw()` in fighter mode
- `BButtonDown` → `fxspeed:setState('startSpeed')` if energy > 1
- `BButtonHeld` / `BButtonHold` → boost if energy > 0, drain energy
- `BButtonUp` → stop speed FX
- `cranked` → fill energy in travel mode

## Documentation

After implementation, write `source/DOCS/SPACE_SCENE.md` covering: scene lifecycle, entity roles, crank mode system, crosshair accelerometer behavior, energy system, laser mechanic.

## No Test Runner

Validate in Playdate simulator: verify crank mode switching, crosshair spring, ship direction animations, FX speed effect, energy drain/fill.
