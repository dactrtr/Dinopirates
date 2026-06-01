# SpaceScene — Escape Runner Design Spec

## Goal

Transform SpaceScene into an infinite escape runner. The player must maintain speed above a threshold by boosting (fighter mode) and charging (travel mode) while dodging meteorites. Losing all health or letting the danger bar fill sends the player back to TitleScene.

---

## Files

**New:**
```
source/entities/space/DangerBar.lua
source/entities/space/HealthDisplay.lua
```

**Modified:**
```
source/entities/space/Meteorite.lua     — add scrollBy(dx, dy) + wrap
source/scenes/SpaceScene.lua            — pools, speed decay, danger, collision, game over
source/assets/data/Config.lua           — all new tunable values
```

---

## Config

All new values added to `Config.Space` in `Config.lua`:

```lua
-- speed
speedDecay            = 0.05,   -- speed lost per frame in fighter mode
maxSpeed              = 20,     -- cap for ship.speed
minSpeed              = 3,      -- threshold below which danger fills

-- danger
dangerFillRate        = 0.002,  -- danger gained per frame when speed < minSpeed
dangerDrainRate       = 0.003,  -- danger lost per frame when speed >= minSpeed

-- meteorites
meteoriteNearCount    = 6,      -- sprites in foreground layer
meteoriteFarCount     = 5,      -- sprites in background layer
meteoriteNearSpeed    = 3,      -- px/frame base scroll, foreground
meteoriteFarSpeed     = 1.5,    -- px/frame base scroll, background
meteoriteSpeedMult    = 0.2,    -- ship.speed contribution to scroll
parallaxSpeed         = 3,      -- px/frame per d-pad direction
meteoriteFarParallax  = 0.5,    -- background layer parallax multiplier (foreground = 1.0)
meteoriteFarScale     = 0.6,    -- background sprite scale for depth

-- collision
invincibilityFrames   = 60,     -- frames of iframes after a hit (~1.5s at 40fps)
```

---

## Speed & Danger System

### Speed decay

`ship.speed` is an existing float on the Ship entity.

- **Fighter mode (crank docked):** each frame, `ship.speed` decreases by `speedDecay`. Clamped to 0.
- **Travel mode (crank undocked):** no decay — speed holds at its current value while charging.
- **Boost (B hold, fighter mode):** adds +1/frame as before, capped at `maxSpeed`.

### Danger bar

`danger` is a new float (0→1) managed in SpaceScene.

- Fills at `dangerFillRate` per frame when `ship.speed < minSpeed`.
- Drains at `dangerDrainRate` per frame when `ship.speed >= minSpeed`.
- Clamped 0→1.
- At 1.0: `Noble.transition(TitleScene)`.
- `DangerBar:update(danger)` is called whenever danger changes.

---

## Meteorite Pool & Parallax

### Pools

Two fixed arrays in SpaceScene:
- `meteoritesNear` — `meteoriteNearCount` Meteorite sprites
- `meteoritesFar`  — `meteoriteFarCount` Meteorite sprites, scaled to `meteoriteFarScale`

On `enter()`: meteorites are distributed at random positions across the screen.

### Scroll per frame

Each meteorite is moved via `scrollBy(dx, dy)` (new method on Meteorite):

```
dx_near = -(meteoriteNearSpeed + ship.speed * meteoriteSpeedMult)
dx_far  = -(meteoriteFarSpeed  + ship.speed * meteoriteSpeedMult)
```

**Wrap:** when `x < -48` → `x = 424 + math.random(0, 50)`, `y = math.random(8, 232)`.

### Parallax from d-pad

While a direction button is held in `update()`, an offset is added to all meteorites that frame, opposite to the input direction:

| Input  | Offset applied to meteorites |
|--------|------------------------------|
| Up     | +parallaxSpeed in Y          |
| Down   | −parallaxSpeed in Y          |
| Left   | +parallaxSpeed in X          |
| Right  | −parallaxSpeed in X          |

Near layer receives full offset. Far layer receives `offset * meteoriteFarParallax`.

This is separate from ship direction animations (those continue as before).

### Meteorite:scrollBy(dx, dy)

New method replaces direct `moveTo` calls from the scene:

```lua
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

---

## Collision & Health

### State in SpaceScene

```lua
local health              = 3
local invincibilityFrames = 0
```

### Per-frame detection

In `update()`, after moving meteorites:

1. If `invincibilityFrames > 0`: decrement, skip collision.
2. Otherwise: iterate over all meteorites in both pools.
3. On `ship:overlapsWithSprite(meteorite)`:
   - `health -= 1`
   - `invincibilityFrames = Config.Space.invincibilityFrames`
   - `healthDisplay:update(health)`
   - If `health <= 0`: `Noble.transition(TitleScene)`
   - Break (one hit per frame max).

Meteorites need a collision rect set in `Meteorite:init()`:
```lua
self:setCollideRect(8, 8, 32, 32)  -- inner rect, avoids edge of sprite
```

---

## New Entities

### DangerBar (`entities/space/DangerBar.lua`)

`Graphics.sprite`, procedurally drawn.

- **Position:** x = 390, y = 120 (4px wide bar, right edge at x=392, 8px from screen right).
- **Size:** 4 × 224px (240 − 8 top − 8 bottom margin).
- Filled white from bottom up proportional to `danger`.
- `update(danger)` redraws only when value changes (tracks `lastDanger`).

```lua
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

### HealthDisplay (`entities/space/HealthDisplay.lua`)

`Graphics.sprite`, procedurally drawn. Can be replaced with an image later.

- **Size:** 24 × 8px (3 circles × 8px each: 4px diameter + 2px margin all sides).
- **Position:** managed by SpaceScene, set to `(canister.x - 16, canister.y)`.
- `update(health)` fills circles for remaining health, draws outlines for lost health.
- Repositioned in SpaceScene whenever `energy:resetPosition` is called (crankDocked / crankUndocked).

```lua
function HealthDisplay:update(health)
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

---

## SpaceScene update() flow

```
1. Read accelerometer + move crosshair  (existing)
2. Speed decay if fighter mode
3. Update danger → DangerBar:update()
4. Check danger game over
5. Move all meteorites (scroll dx + parallax from d-pad buttons)
6. Check collisions if invincibilityFrames == 0
7. Check health game over
```

---

## Crank handlers

`crankDocked` and `crankUndocked` already call `energy:resetPosition(shipX, shipY)`. SpaceScene also calls `healthDisplay:moveTo(...)` there to keep the health dots anchored to the canister.

---

## Imports

`SpaceScene.lua` adds:
```lua
import 'entities/space/DangerBar'
import 'entities/space/HealthDisplay'
```

---

## Out of scope

- Explosion effect on meteorite hit (asset `explosion-table-36-36.png` available for future use).
- Score or distance counter.
- Meteorite hit reaction animation on ship.
