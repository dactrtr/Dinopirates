# Player Systems — Comprehensive Documentation

Complete documentation of all player subsystems. Configuration values live in `Config.lua`; state data lives in `PlayerData` (see `PLAYERDATA_REFERENCE.md`).

---

## 1. Movement

**Files**: `entities/player/movement.lua`, `entities/player/init.lua`

### Base speed

`self.speed` is initialized with the `speed` argument passed to `Player:init()`. In `MazeScene`, that value comes from `Config.Player.speed = 2` (px/frame).

### Direction and displacement

`Player:move(direction)` is called every frame from the `MazeScene` input handler when the player presses a direction button. It calculates the target:

```
left  → movementX = self.x - self.speed
right → movementX = self.x + self.speed
up    → movementY = self.y - self.speed
down  → movementY = self.y + self.speed
```

Effective movement is resolved with `self:moveWithCollisions(movementX, movementY)`, which returns `actualX, actualY, collisions, length`. The player can collide with: `enemy`, `props`, `items`, `wall`, `crewMember`.

### Movement blockers

`Player:move()` returns without doing anything if:
- `PlayerData.isGaming == false`
- `self.isSliding == true`
- `self.isPlunging == true`
- `self.isAlive == false`
- `PlayerData.isCharging == true`

### Speed modifiers (applied in `Player:update()`)

| Condition | Multiplier | Effective speed (base 2) |
|---|---|---|
| Normal | 1.0 | 2 px/frame |
| In darkness without lamp | `Config.Player.speedDarkNoLamp = 0.7` | 1.4 px/frame |
| In darkness with lamp and low battery (`< 20`) | `Config.Player.speedLowBattery = 0.8` | 1.6 px/frame |

Reduced speed is applied by writing `self.speed = multiplier * self.initialSpeed`. When battery rises above the threshold, `self.speed` returns to `self.initialSpeed`.

### `isActive` and HUD update

Each time `Player:move()` executes successfully, `PlayerData.isActive = true` is set at the start. At the end of `Player:update()`, it is reset to `false`. This pulses the turn-based signal (see section 11).

---

## 2. Battery

**Files**: `entities/player/sanity.lua` (drain/charge), `entities/player/movement.lua` (drain on movement), `entities/player/hole.lua` (drain in holes), `entities/player/lightburst.lua`

### Range and limits

- Min: `0`, Max: `100`
- Forced clamp in `Player:update()`: if `battery < 0 → 0`; if `battery >= 100 → 100`.

### Drain rates

| Situation | Rate | When applied |
|---|---|---|
| Moving in darkness | `Config.Battery.drainMovementDark = 0.5` per frame | `Player:move()`, only if `isInDarkness == true` |
| Crossing hole (normal size) | `Config.Battery.drainHoleNormal = 0.5` per frame | `checkHoleTile()`, only if `isActive` |
| Crossing hole (tiny) | `Config.Battery.drainHoleTiny = 0.2` per frame | `checkHoleTile()` / `checkTinyHoleTile()`, only if `isActive` |
| Using LightBurst | `Config.LightBurst.batteryCost = 10` (fixed cost) | `lightBurst()` on activation |
| Walking with DWatch | `0.5` per frame (disabled) | Flag `DRAIN_BATTERY_ON_WALK = false` in `movement.lua` |

### Charging via crank

`Player:chargeBattery(amount)` adds `amount` to `PlayerData.battery` and sets `PlayerData.isActive = true`. This allows enemies to move while the player charges without moving. Also triggers the `charge` animation. `Player:fillBattery()` directly sets `battery = 100` (called when picking up items).

### Thresholds and their effects

Thresholds are centralized in `Config.Battery` and referenced by multiple systems:

| Threshold | Value | System using it | Effect |
|---|---|---|---|
| `thresholdCritical` | 10 | Enemy AI, CrewMember AI | Enemies cap their speed; CrewMember stops |
| `thresholdLow` | 20 | Sanity, Player speed, Enemy AI | Sanity loses `lossLowBattery`×2 pts/tick; speed reduced to 80%; enemies slow down |
| `thresholdMid` | 60 | Sanity, Enemy AI, CrewMember | Sanity loses `lossMidBattery`×1 pt/tick; CrewMember restores movement |
| `batteryThresholdHigh` (Sanity) | 50 | Sanity | Sanity regenerates `gainHighBattery`×2 pts/tick |

---

## 3. Sanity

**File**: `entities/player/sanity.lua`

### Tick timer

`Player:sanityCheck()` (called from `Player:init()`) creates a `playdate.timer.keyRepeatTimerWithDelay` with:
- Initial delay: `Config.Sanity.tickInterval = 2000` ms
- Repeat interval: `Config.Sanity.tickInterval = 2000` ms

The tick fires every 2 seconds while the player exists in the scene.

### Tick logic

On each tick, in order:

1. **Sanity loss** (only if `isInDarkness == true`):
   - `battery < batteryThresholdLow (20)` → `sanity -= lossLowBattery (2) * self.sanityLoss`
   - `battery < batteryThresholdMid (40)` → `sanity -= lossMidBattery (1) * self.sanityLoss`
   - (Conditions are mutually exclusive: the more severe is evaluated first)

2. **sanityCounter**: If `sanity <= 0` and it was previously `> 0`, increments `PlayerData.sanityCounter` by 1 and calls `Utilities.checkSanityAchievements()`.

3. **Sanity gain**:
   - `battery > batteryThresholdHigh (50)` OR `isInDarkness == false` → `sanity += gainHighBattery (2) * self.sanityLoss`

4. Clamp: `sanity = math.clamp(sanity, 0, 100)`.

`self.sanityLoss` is `1` by default (initialized in `init.lua`). It is a multiplier that could be scaled in the future.

### sanityCounter and powerLevel scaling

`PlayerData.sanityCounter` is a cumulative lifetime counter. Each time sanity reaches 0, the counter increases. In `DanceScene`, `determineDifficultyUpgrade()` uses `sanityCounter` (together with `powerLevel` and `calories`) in a weighted formula to decide whether the difficulty level scales. When it scales, `PlayerData.EnemiesData.powerLevel` increments (maximum 20), which increases enemy detection radius and rhythm difficulty in DanceScene.

---

## 4. Health

**File**: `entities/player/collisions.lua`, `entities/player/state.lua`

### Value and damage sources

`PlayerData.healthPoints` (default: `3`). It is reduced in `collisionResponse` when the player collides with a `Brocorat` and is not in an invincibility state:

```lua
PlayerData.healthPoints -= (other.damage or 1)
```

Health is **capped at `Config.Player.maxHealthPoints` (10)** — the `HealthIndicator` HUD
draws up to 10 dots. The cap is enforced in three places: an upper clamp in `Player:update()`,
the microwave cook loop, and the `DanceScene` win heal (all via `math.min`).

### Recovery (microwave + DanceScene)

There are two ways to restore HP:

1. **Winning a `DanceScene`** restores `PlayerData.healedHP` (clamped to the cap) and kills
   the enemy.
2. **Cooking food at a microwave** — pick up `food` items, stand on a `microwave` prop, press
   **A**, and crank: each `Config.Microwave.crankPerFood` ticks consumes 1 food for
   `+Config.Microwave.hpPerFood` HP (and a `+caloriesPerFood` calorie byproduct). It auto-stops
   at full HP or 0 food; **B** cancels. The mechanic mirrors the minifier. There is no passive
   regen and no instant heal pickup. See `MICROWAVE_AND_FOOD.md` for the full system.

### Combat threshold

If `healthPoints < danceThresholdHP (1)` after taking damage, `self:fight()` is called → transition to `DanceScene`. If `healthPoints >= danceThresholdHP`, the player only receives knockback and temporary invincibility.

### Invincibility

`Player:startInvincibility(duration)` sets `self.isInvincible = true` and `self.invincibilityTimer = duration`. In `Player:update()`, the timer decrements by `1000 / refreshRate` ms per frame. During invincibility, the sprite flickers (shown/hidden based on `flickerRate = 100` ms). The standard duration is `Config.Invincibility.duration = 1000` ms.

### Knockback

`Player:applyKnockback(enemyX, enemyY)`:

```lua
local k = Config.Player.knockbackDistance  -- 2 px
dx = (self.x > enemyX) and k or -k
dy = (self.y > enemyY) and k or -k
self:moveWithCollisions(self.x + dx, self.y + dy)
```

The player moves 2 px away from the enemy on both X and Y simultaneously. If coordinates are equal on an axis, there is no push on that axis.

### Dead state

`Player:dead()` sets `self.isAlive = false`, waits 1000 ms, and calls `Noble.transition(DeadScene)`. It is triggered when `DanceScene` conditions result in defeat or a special trigger.

---

## 5. Calories and Pedometer

**File**: `entities/player/state.lua` (`pedometer()` and `burnCalories()` functions)

### Configuration

```
Config.Pedometer.stepsPerMovement = 0.5   -- steps added per each call to move()
Config.Pedometer.stepsToTrigger   = 200   -- threshold to burn calories
Config.Pedometer.caloriesPerBurn  = 10    -- calories lost when threshold is reached
```

### Flow

Each time `Player:move()` completes (after `moveWithCollisions`), it calls `Player:pedometer()`:

1. `PlayerData.steps += 0.5`
2. `PlayerData.totalSteps += 0.5`
3. If `steps >= 200` → reset `steps = 0`, call `burnCalories(10)` → `PlayerData.calories -= 10`

### What calories are used for

`PlayerData.calories` is one of the three inputs to the `DanceScene` difficulty system. In `determineDifficultyUpgrade()` it is normalized against `Config.Dance.caloriesMax = 500` and weighted with `Config.Dance.weightCalories = 0.20` to calculate the probability of scaling the combat level.

Besides the pedometer burn, calories are **gained** by cooking food at a microwave
(`+Config.Microwave.caloriesPerFood` per food) and by winning a `DanceScene` (`+60`); both
gains are clamped to `Config.Dance.caloriesMax`. Note the per-tick crank burn
(`burnCalories(1)`) is skipped while cooking so the cooking byproduct is not cancelled out —
see `MICROWAVE_AND_FOOD.md`. Because higher calories raise dance difficulty, healing at a
microwave makes the next fight harder.

---

## 6. Transformation (tiny/big)

**Files**: `entities/player/state.lua`, `entities/player/init.lua`, `entities/player/collisions.lua`

### shrink() — becoming small

```lua
function Player:shrink()
    PlayerData.isTiny = true
    local crt = Config.Player.collideRectTiny  -- {x=19, y=32, w=10, h=10}
    self:setCollideRect(crt.x, crt.y, crt.w, crt.h)
    self.animation:setState('transformTo')
end
```

`transformTo` is a one-shot animation that automatically transitions to `tinyIdle` when finished.

### grow() — becoming big

```lua
function Player:grow()
    PlayerData.isTiny = false
    local cr = Config.Player.collideRect  -- {x=8, y=24, w=30, h=24}
    self:setCollideRect(cr.x, cr.y, cr.w, cr.h)
    self:idle()
end
```

### collideRect by size

| State | Rect (x, y, w, h) | Collision area |
|---|---|---|
| Normal | `{8, 24, 30, 24}` | 30×24 px, offset downward |
| Tiny | `{19, 32, 10, 10}` | 10×10 px, centered in the lower part of the sprite |

### What changes in tiny mode

- **Speed**: Does not change directly, but holes only drain `drainHoleTiny = 0.2` (vs `0.5`).
- **Animations**: All states use the `tiny` prefix (`tinyIdle`, `tinyLeft`, `tinyRight`, `tinyUp`, `tinyDown`, `slideTiny`). Frame duration reduced to half (`frameDurationWalk/2 = 4`).
- **Special holes**: `checkTinyHoleTile()` detects tiles with IntGrid ID `32` (tinyHole). Only the tiny player falls into these holes; the normal player ignores them.
- **Pneumatic tubes**: `collisionResponse` allows `riseAbove()` when colliding with `PropItem.isTube == true` only if `isTiny == true`. Otherwise it returns `'freeze'`.
- **Minifier**: The transformation is triggered from `Player:startMinifying()` using the crank. `PlayerData.actualPlayerSize` goes from `playerSize (10)` to `0` (tiny) or vice versa.
- **Plungerang blocked**: `Player:plunge()` returns without executing if `PlayerData.isTiny == true`.
- **Microwave cooking blocked**: `Player:startCooking()` returns without executing if `PlayerData.isTiny == true` (cooking is big-only; the "Press A" prompt is also hidden while tiny).

---

## 7. LightBurst

**File**: `entities/player/lightburst.lua`

### Parameters (Config.LightBurst)

```
batteryCost   = 10    -- battery consumed
cooldown      = 1000  -- ms between uses
displayTime   = 1000  -- ms the cone remains visible
coneDistance  = 200   -- px forward (cone projection)
coneHeight    = 12    -- lateral scale factor
blindDuration = 60    -- frames enemies remain blind
selfDamage    = 1     -- HP the player loses each time the flash fires (0 = off)
```

### Activation conditions

- `PlayerData.items.hasLamp == true` AND `PlayerData.skills.canFlash == true`
- Cooldown expired
- `PlayerData.battery >= 10`
- `PlayerData.direction != 'idle'`
- Triggered by B while in darkness (`useAbility()` routes to the lamp when `isInDarkness`)

### Cone geometry (playdate.geometry.polygon)

The cone is built in `createLightCone(direction)`. Let `ix, iy` be the player position, `d = coneDistance (200)`, `h = coneHeight (12)`:

For `direction == 'left'` or `'right'` (d is negative for left):
```
Vertices: (ix, iy), (ix+d, iy-4h), (ix+1.1d, iy-3.5h),
          (ix+1.2d, iy-2h), (ix+1.25d, iy), (ix+1.2d, iy+2h),
          (ix+1.1d, iy+3.5h), (ix+d, iy+4h), (ix, iy)
```

For `direction == 'up'` or `'down'` (d is negative for down):
```
Vertices: (ix, iy), (ix-4h, iy-d), (ix-3.5h, iy-1.1d),
          (ix-2h, iy-1.2d), (ix, iy-1.25d), (ix+2h, iy-1.2d),
          (ix+3.5h, iy-1.1d), (ix+4h, iy-d), (ix, iy)
```

The polygon is closed with `lightCone:close()`.

### Self-damage

Each time the flash actually fires it costs the player `Config.LightBurst.selfDamage` HP
(default `1`; set to `0` to disable). The cost is **always real** — it ignores
invincibility (`self.isInvincible`).

Because it cannot be absorbed, the flash is **refused** when it would be lethal: during the
validations (right after the battery check) `lightBurst()` returns early if
`healthPoints - selfDamage` would fall below `PlayerData.danceThresholdHP`. No battery is
consumed and the cone never appears. As a result the HP deduction that runs after the cone
resolves can never drop the player into the DanceScene.

### Entity detection

`getEntitiesInLightCone(polygon)` iterates all sprites in the scene. It only checks `CrewMember` (not Brocorat directly). Uses `lightPolygon:containsPoint(sprite.x, sprite.y)`.

`affectEntity(entity)` calls `entity:blind(blindDuration)` for both `Brocorat`/`Bosscolli` and `CrewMember` that are within the cone.

### Additional effects

- `PlayerData.showLightCone = true` → FXshadow draws the cone visually.
- `lightConeHideTime = getCurrentTimeMilliseconds() + displayTime` → in `update()`, when reached, `showLightCone = false`.
- `distributeMovementTokens(Config.Player.movementTokensPerAction)` → grants movement tokens (5) to all enemies/crew because the flash actually fired.

---

## 8. Plungerang

**Files**: `entities/player/plunge.lua`, `entities/player/projectile.lua`

### Parameters (Config.Projectile)

```
maxDistance   = 100  -- maximum px before returning
speed         = 8    -- px/frame
blindDuration = 60   -- frames of blindness when hitting an enemy
```

### Activation conditions (Player:plunge)

- `PlayerData.items.hasPlunger == true` AND `PlayerData.skills.canPlungerang == true`
- `PlayerData.isTiny == false`
- `self.isPlunging == false` (only one projectile at a time)
- `self.hasProjectile == true` (not lost)
- `PlayerData.direction != 'idle'`
- Triggered by B while in a lit room (`useAbility()` routes to the plungerang when not `isInDarkness`)

### Projectile logic (Projectile:update)

**Outbound phase** (`returning == false`):
- Moves `speed = 8` px/frame in `direction`.
- On collision with `CrewMember`: calls `stunInfinite()`, the projectile is lost (`self.player.hasProjectile = false`, `isPlunging = false`, `remove()`).
- On collision with `Enemy`: calls `hitEntity()` → `entity:blind(60)`, starts `returning = true`.
- On collision with `PropItem` or `Box`: starts `returning = true`.
- When `distanceTravelled >= maxDistance (100)`: starts `returning = true`.

**Return phase** (`returning == true`):
- Calculates `dx, dy` toward the player's current position.
- Moves `speed = 8` px/frame in that direction.
- When `dist < speed`: caught → `onCaught()` → `Projectile:remove()` → `Player:onProjectileCaught()` → `isPlunging = false`, `projectile = nil`.

### Movement blocking

`self.isPlunging == true` blocks `Player:move()` (and `checkSlimeTile()`). Movement is unblocked only when the projectile is caught (or lost). **If the projectile is lost by hitting a CrewMember, `hasProjectile = false` persists** — the player cannot use Plungerang until recovered (logic not currently implemented beyond a debug message).

---

## 9. Slime sliding

**File**: `entities/player/sliding.lua`

### Detection

`Player:checkSlimeTile()` is called in `update()`. Calls `IsPlayerOnSlime(self.x, self.y)` (a utility function that tile-samples the player's foot area, IDs 89–97). Detection is skipped if:
- `isSliding` or `isPlunging` are active.
- `slideHitWall == true` (just bounced off a wall).
- `PlayerData.items.hasPlunger == true` (slime immunity).

### Slide start

`Player:startSliding(direction)` sets:
```lua
self.isSliding = true
self.slidingDirection = direction  -- direction the player was moving
self.slidingSpeed = 4              -- hardcoded, faster than normal speed (~2)
```

The slide direction is inherited from `direction` param → `self.direction` → `PlayerData.direction`, in that order.

### Automatic movement (updateSliding)

Each frame while `isSliding == true`, applies `slidingSpeed = 4` in `slidingDirection` without player input. Updates animation:
- Normal: `slideLeft`, `slideRight`, `slideUp`, `slideDown`
- Tiny: `slideTiny` (no directional distinction)

The slide ends (`endSliding`) if:
- `hitSolid == true` (collision with wall, or PropItem that is not a minifier)
- `not stillOnSlime` (the player left the slime tiles)

`endSliding(hitWall)`:
- If `hitWall == true` → `slideHitWall = true` (prevents immediate re-slide)
- Exit animation (normal): `slideExitRight/Left/Up/Down` (one-shot → `idle`)
- Tiny: directly `idle()`
- `PlayerData.direction = 'idle'`

`slideHitWall` is automatically cleared when the player gives a direction again in `Player:move()` (`self.slideHitWall = false`).

---

## 10. Turn-based sync — isActive

**File**: `entities/player/init.lua`, `entities/player/movement.lua`, `entities/player/sanity.lua`

### Principle

The world "moves when the player moves". Enemies and CrewMembers do not continuously update their AI; they only do so when the player performs an action.

### isActive signal

`PlayerData.isActive` is a boolean that is pulsed (true → false) each frame:

| Who sets it to `true` | Reason |
|---|---|
| `Player:move()` at the start | The player moved |
| `Player:chargeBattery()` | The player charged battery (also moves the world) |

At the end of `Player:update()` it is reset: `PlayerData.isActive = false`.

### distributeMovementFrames(frames)

Called inside `Player:move()` after `moveWithCollisions`, with `frames = Config.Player.movementFramesPerAction = 3`. Only executes if `PlayerData.isActive == true` (redundant but explicit guard). Iterates all sprites in the scene and calls `sprite:addMovementFrames(frames)` on those that are `Brocorat` or `CrewMember`.

### distributeMovementTokens(amount)

Called by a B ability **when it actually fires**, with `amount = Config.Player.movementTokensPerAction` (5): `lightBurst()` (flash), `plunge()` (plungerang), `endGrappleCharge()` (grapple launch), and `activateDarkReveal()` (dark reveal). Unlike `distributeMovementFrames`, it does NOT check `isActive` — it always iterates all sprites. Calls `sprite:addMovementTokens(amount)`. Merely pressing B, or holding B to charge while idle, grants nothing.

| Function | When | Amount | isActive guard |
|---|---|---|---|
| `distributeMovementFrames` | On each successful `move()` | 3 frames | Yes |
| `distributeMovementTokens` | When a B ability fires (flash / plungerang / grapple / dark reveal) | 5 tokens | No |

---

## 11. Animation state machine

**File**: `entities/player/animations.lua`

All states are defined in `Player:initAnimations()` on `self.animation` (Noble Engine `AnimatedSprite`). Each state has a frame range in the imagetable and a `frameDuration` (Playdate frames per animation frame).

### Available states

| State | Frames | frameDuration | Auto-transition |
|---|---|---|---|
| `idle` | 41–52 | 12 | — |
| `right` | 11–15 | 8 | — |
| `left` | 1–5 | 8 | — |
| `down` | 26–30 | 8 | — |
| `up` | 21–25 | 8 | — |
| `lampIdle` | 53–64 | 8 | — |
| `lampRight` | 16–20 | 8 | — |
| `lampLeft` | 6–10 | 8 | — |
| `lampDown` | 31–35 | 8 | — |
| `charge` | 36–40 | 12 | — |
| `tinyIdle` | 73–81 | 4 | — |
| `tinyRight` | 82–84 | 4 | — |
| `tinyLeft` | 85–87 | 4 | — |
| `tinyDown` | 88–90 | 4 | — |
| `tinyUp` | 91–93 | 4 | — |
| `transformTo` | 94–99 | 4 | → `tinyIdle` |
| `transformCycle` | 100–105 | 3 | — |
| `slideRight` | 115–116 | 3 | — |
| `slideLeft` | 117–118 | 3 | — |
| `slideDown` | 119–120 | 3 | — |
| `slideUp` | 121–122 | 3 | — |
| `slideExitRight` | 123–127 | 3 | → `idle` |
| `slideExitLeft` | 128–132 | 4 | → `idle` |
| `slideExitUp` | 137–141 | 4 | → `idle` |
| `slideExitDown` | 133–136 | 4 | → `idle` |
| `slideTiny` | 142–145 | 4 | — |
| `sleep` | 147–148 | 18 | — |

### How darkness/tiny affect state selection

In `Player:move(direction)`, state selection follows this priority:

```
1. isTiny == true?            → use tinyXxx state
2. hasLamp and isInDarkness?  → use lampXxx state
3. Default                    → use base state (left, right, up, down)
```

Note: The `lampUp` state does not exist. In darkness with lamp moving upward, the generic `up` state is used.

In `Player:idle()`:
```
1. isTiny?                    → tinyIdle
2. hasLamp and isInDarkness?  → lampIdle
3. Default                    → idle
```

### Initial state

In `initAnimations()`, after defining all states:
```
PlayerData.fromTitle == true → sleep
hasLamp and isInDarkness and not isTiny → lampIdle
isTiny → tinyIdle
Default → idle
```

### Sleeping states

`Player:startSleeping()` sets `self.isSleeping = true` and state `sleep`. In `update()`, if `isSleeping`, only button presses are processed to wake up (2 presses of any button are required). `Player:wake()` → `isSleeping = false`, `idle()`, `isGaming = true`.

---

## 12. Dead state

**File**: `entities/player/state.lua`

`Player:dead()`:
1. `self.isAlive = false` — blocks `move()` and `useAbility()`.
2. After 1000 ms (timer): `Noble.transition(DeadScene)`.

Conditions that lead to `dead()`:
- Defeat result in `DanceScene` (the scene calls `Player:dead()` in the defeat callback).
- Special triggers in the level (not documented here).

Falling into a hole without boots and without an available lower room also results in `Noble.transition(DeadScene)` directly from `state.lua:fallBelow()`.

---

## 13. Notes for Love2D port

### Movement and collisions

`moveWithCollisions(x, y)` → replace with `bump.lua`:
```lua
local actualX, actualY, cols, len = world:move(self, goalX, goalY, collisionFilter)
```
Collision groups (`setGroups`, `setCollidesWithGroups`) become a `collisionFilter(item, other)` function.

### Input

- D-pad → `WASD` or arrow keys mapping to `Player:move("left"|"right"|"up"|"down")`
- A button → `Space` or `Enter`
- Crank → mouse wheel or `Q`/`E` keys

### Timers

`playdate.getCurrentTimeMilliseconds()` → `love.timer.getTime() * 1000` (Love2D returns seconds).

`playdate.timer.keyRepeatTimerWithDelay(delay, interval, fn)` → implement with an accumulator in `love.update(dt)`:
```lua
self.sanityTimer = (self.sanityTimer or 0) + dt * 1000
if self.sanityTimer >= 2000 then
    self.sanityTimer = 0
    checkSanity()
end
```

### Animations

Noble Engine `AnimatedSprite` with imagetable → use `anim8` or similar. States and their frame ranges are fully documented in section 12.

### Cone geometry (LightBurst)

`playdate.geometry.polygon:containsPoint(x, y)` → implement Point-in-Polygon with Ray Casting:
```lua
function pointInPolygon(vertices, px, py)
    local inside = false
    local j = #vertices
    for i = 1, #vertices do
        local xi, yi = vertices[i][1], vertices[i][2]
        local xj, yj = vertices[j][1], vertices[j][2]
        if ((yi > py) ~= (yj > py)) and
           (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end
```

### Turn-based sync

`isActive` and `distributeMovementFrames` are pure Lua logic, not dependent on the SDK. Preserve exactly. In Love2D, enemies must check `PlayerData.isActive` in their `update()`.

### Z-sorting

Noble Engine sorts sprites automatically by ZIndex. In Love2D, implement in `love.draw()`:
```lua
table.sort(entities, function(a, b) return a.y < b.y end)
for _, e in ipairs(entities) do e:draw() end
```

### Invincibility (flickering)

`playdate.display.getRefreshRate()` → `love.graphics.getStats()` does not apply; use `dt` directly:
```lua
self.invincibilityTimer = self.invincibilityTimer - dt * 1000
local visible = math.floor(self.invincibilityTimer / 100) % 2 == 0
self:setVisible(visible)
```
