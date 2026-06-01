# Enemies and Combat

Comprehensive documentation of the enemy AI system, combat mechanics, and the rhythm combat system (DanceScene).

---

## Base Enemy Class

File: `source/entities/enemies/enemy.lua`

`Enemy` extends `NobleSprite` and acts as the base class for all enemies in the game. It is not instantiated directly; subclasses (such as `Brocorat`) extend this class and add their own AI logic via the `search()` method.

### Relevant Fields (initialized in subclasses)

| Field | Type | Description |
|-------|------|-------------|
| `self.moveSpeed` | number | Current movement speed (may be modified by `updateMoveSpeed()`) |
| `self.initialSpeed` | number | Original base speed; used as reference when recalculating `moveSpeed` |
| `self.powerLevel` | number | Enemy's local power level; influences ability to eat props |
| `self.stunProc` | number | Stun threshold: `moveSpeed * Config.Enemy.stunProcMultiplier` (20). If `stunProc <= 1`, the enemy stops moving |
| `self.movementFrames` | number | Available movement frames (turn-based token system) |
| `self.updateFrameCounter` | number | Frame counter for AI throttling (every 3 frames in Brocorat) |
| `self.isBlinded` | boolean | Whether the enemy is temporarily blinded |
| `self.blindFrames` | number | Remaining frames of blindness |
| `self.sightRadius` | number | Detection radius calculated at initialization |
| `self.player` | table | Reference to the Player object |
| `self.Zindex` | number | Enemy's original Z-index |

---

## updateMoveSpeed()

Adjusts `self.moveSpeed` based on the player's battery level and whether the room is in darkness. Called at the start of `blindSearch()` and `linealSearch()` before calculating movement.

```lua
function Enemy:updateMoveSpeed()
    if PlayerData.battery == 0 and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryEmpty       -- 0.2 (absolute)
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdLow and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryLow * self.initialSpeed  -- 0.5 × initialSpeed
    elseif PlayerData.battery <= Config.Enemy.batteryThresholdMid and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedBatteryMid * self.initialSpeed  -- 0.7 × initialSpeed
    else
        self.moveSpeed = self.initialSpeed
    end

    -- Additional override for critically low battery in darkness
    if PlayerData.battery < Config.Enemy.batteryThresholdCritical and PlayerData.isInDarkness == true then
        self.moveSpeed = Config.Enemy.moveSpeedCritical           -- 0.5 (absolute)
    end
end
```

### Battery Threshold and Resulting Speed Table

| Condition | Battery (%) | Darkness | Resulting Speed |
|-----------|-------------|----------|-----------------|
| Empty battery | == 0 | yes | 0.2 px/frame (absolute) |
| Critical battery | < 10 | yes | 0.5 px/frame (absolute, final override) |
| Low battery | <= 20 | yes | `initialSpeed × 0.5` |
| Mid battery | <= 60 | yes | `initialSpeed × 0.7` |
| Normal / no darkness | any | no | `initialSpeed` (unmodified) |

The shared threshold values are:
- `Config.Battery.thresholdCritical = 10`
- `Config.Battery.thresholdLow = 20`
- `Config.Battery.thresholdMid = 60`

The critical battery override (`< 10`) is evaluated **after** all other conditionals, overwriting any previously assigned value from the main block.

---

## AI Methods

### blindSearch(player)

The enemy moves directly toward the player's current position on both axes (X and Y) simultaneously. It does not account for obstacles beyond collision resolution in `moveCollision()`.

```lua
function Enemy:blindSearch(player)
    self.player = player
    self:updateMoveSpeed()

    local movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
    local movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed

    self.animation:setState('walk')
    self:moveCollision(movementX, movementY, self.player)
end
```

Movement is purely diagonal: `moveSpeed` is subtracted or added to both axes independently. There is no diagonal vector normalization.

### linealSearch(player)

The enemy only moves if the player is aligned on the same horizontal or vertical axis, within a margin equal to `self.viewRange`.

```lua
function Enemy:linealSearch(player)
    self.player = player
    self:updateMoveSpeed()

    local movementX = self.x
    local movementY = self.y

    if math.abs(self.y - self.player.y) < self.viewRange then
        movementX = self.player.x <= self.x and self.x - self.moveSpeed or self.x + self.moveSpeed
        self:moveCollision(movementX, self.y, self.player)
    end

    if math.abs(self.x - self.player.x) < self.viewRange then
        movementY = self.player.y <= self.y and self.y - self.moveSpeed or self.y + self.moveSpeed
        self:moveCollision(self.x, movementY, self.player)
    end
end
```

Exact logic:
- If the Y difference between player and enemy is less than `viewRange`, the enemy pursues along X.
- If the X difference is less than `viewRange`, the enemy pursues along Y.
- Both conditions can be true simultaneously (when the player is close on both axes), causing two `moveCollision` calls in the same frame.

> `viewRange` is not defined in the base Enemy class; each subclass is responsible for defining it. In the current `Brocorat` code, `sightRadius` is used directly in `search()` without calling `linealSearch()`.

### search(player)

`search()` is not implemented in the base `Enemy` class. Each subclass defines it:

- **Brocorat**: checks if the player is within the `sightRadius` square (or `sightRadius/2` in tiny mode) and calls `blindSearch()`.
- **CrewMember**: opposite logic — calls `escape()` to move away from the player.

---

## moveCollision()

Moves the enemy to the target coordinates and resolves collisions. After `moveWithCollisions()`, it iterates over all collided objects:

```lua
function Enemy:moveCollision(movementX, movementY, player)
    local actualX, actualY, collisions, length = self:moveWithCollisions(movementX, movementY)
    local bounceFactor = Config.Enemy.bounceFactor   -- 3 px

    if length > 0 then
        for index, collision in pairs(collisions) do
            local collideObject = collision['other']

            if collideObject:isa(Box) or collideObject:isa(PropItem) or collideObject:isa(Enemy) then
                -- Edible prop: enemy increases its local powerLevel
                if collideObject:isa(PropItem) and collideObject.isEdible == true then
                    self.powerLevel += 1
                    if (not a hole type) and self.powerLevel > Config.Enemy.eatPropPowerThreshold then
                        collideObject:destroyProp(collideObject.id)
                        self.powerLevel -= Config.Enemy.eatPropPowerPenalty
                    end
                end

                -- Bounce: push enemy 3 px in direction opposite to collision normal
                local normal = collision['normal']
                if normal then
                    local bounceX = self.x + (normal.dx * bounceFactor)
                    local bounceY = self.y + (normal.dy * bounceFactor)
                    self:moveTo(bounceX, bounceY)
                end

            elseif collideObject:isa(Player) then
                collideObject:collisionResponse(self)
            end
        end
    end
end
```

### Key Points of moveCollision()

- **Bounce distance**: exactly `3 px` in the direction of the collision normal (`Config.Enemy.bounceFactor = 3`).
- **Wall handling**: Collisions with `Box` (walls) trigger the 3 px bounce. The effective final position after bouncing may land inside the wall; the collision engine will resolve the overlap in the next frame.
- **Edible props**: When colliding with a `PropItem` that has `isEdible == true`, the enemy's local `powerLevel` increases by 1. If it exceeds `Config.Enemy.eatPropPowerThreshold` (25) and the prop is not a hole type, the prop is destroyed and `powerLevel` decreases by `Config.Enemy.eatPropPowerPenalty` (5).
- **Player collision**: If the collided object is the player, `collideObject:collisionResponse(self)` is called (player logic, not enemy logic).

---

## movementFrames System

Enemies use a turn-based "movement frames" system that synchronizes their activity with the player's.

### Frame Distribution

Frames are distributed by the external system (MazeScene/Player) when the player moves. The relevant constant is:

```
Config.Player.movementFramesPerAction = 3
```

Each player action distributes 3 movement frames to active enemies and CrewMembers in the room.

### Consumption in update()

In `Brocorat:update()`:
```lua
if self.movementFrames > 0 then
    self.movementFrames = self.movementFrames - 1   -- consumes 1 frame per tick
    if self.updateFrameCounter == 0 then
        self:search(self.player)                     -- runs AI only when counter is 0
    end
else
    -- idle animation when no frames available
end
```

### 3-Frame Throttle

`updateFrameCounter` cycles from 0 to 2 with a random initial offset (`math.random(0, 2)`). The AI (`search()`) only runs when `updateFrameCounter == 0`, that is, 1 out of every 3 frames. This reduces CPU cost when multiple enemies are on screen.

```lua
self.updateFrameCounter = (self.updateFrameCounter + 1) % 3
```

### Accumulated Frame Cap

In `addMovementFrames()`, frames are capped at a maximum:
```
Config.CrewMember.movementFramesCap = 90   -- ~3 seconds at 30 fps
```

This cap applies to both `Enemy:addMovementFrames()` and `CrewMember:addMovementFrames()`.

---

## stunProc — Stun Threshold

`stunProc` is calculated in the Brocorat constructor:
```lua
self.stunProc = moveSpeed * Config.Enemy.stunProcMultiplier   -- moveSpeed × 20
```

Its use in `Brocorat:search()`:
```lua
if self.stunProc > 1 then
    -- execute search and pursuit
end
```

### Meaning

`stunProc` represents a minimum effective movement speed. If `moveSpeed` is very low (below `1/20 = 0.05`), `stunProc` falls below 1 and the enemy becomes immobilized: its `search()` block never executes. In practice, with current speed values (minimum 0.2 px/frame), `stunProc` never drops below 4, so the low-`moveSpeed` stun system does not activate under normal conditions. It is a safeguard for when `moveSpeed` approaches 0.

---

## blind() and sonar()

### blind(frames)

Temporarily stops the enemy for a specified number of frames:

```lua
function Enemy:blind(frames)
    self.blindFrames = frames or 60
    self.isBlinded = true
    self.movementFrames = 0       -- cancels pending movement immediately
    self.animation:setState('idle')
end
```

- The default value is 60 frames.
- `Config.LightBurst.blindDuration = 60` (lamp flash).
- `Config.Projectile.blindDuration = 60` (plungerang).
- In `Brocorat:update()`, if `isBlinded == true`, the method returns early without executing any AI or movement logic.

### sonar()

Defined in `enemy.lua` but **currently inactive**: the call in `brocorat.lua` is commented out (`-- self:sonar()`).

Defined behavior (for reference):
- Activates if the player is more than 60 px away on X: `(PlayerData.x - 60) > self.x` OR `(PlayerData.x + 60) < self.x`.
- If `PlayerData.isFocused == true` AND `PlayerData.isInDarkness == true` AND `PlayerData.sanity > 0`: changes animation to `'shine'` (frames 9–14) with a random `frameDuration` between 1–16 and raises ZIndex to 10.
- If conditions are not met: restores the original ZIndex and returns to `'idle'`.

---

## Brocorat

File: `source/entities/enemies/brocorat.lua`

`Brocorat` is the main enemy subclass in the game. It extends `Enemy`.

### Constructor

```lua
function Brocorat:init(x, y, moveSpeed, Zindex, player, ID)
```

| Parameter | Description |
|-----------|-------------|
| `x, y` | Initial position in px |
| `moveSpeed` | Base speed (defaults to 1 if nil) |
| `Zindex` | Rendering layer |
| `player` | Reference to the Player object |
| `ID` | LDtk identifier for the enemy |

### Initialized Fields

```lua
self.type = "Enemy"
self.id = ID
self.powerLevel = PlayerData.EnemiesData.powerLevel + PlayerData.sanityCounter
self.stunProc = moveSpeed * Config.Enemy.stunProcMultiplier        -- moveSpeed × 20
self.moveSpeed = moveSpeed
self.initialSpeed = moveSpeed
self.damage = 1
self.sightRadius = math.max(
    Config.Enemy.sightRadiusMin,                                   -- minimum: 50
    PlayerData.EnemiesData.sightRadius + self.powerLevel * Config.Enemy.sightRadiusPerPowerLevel
    --  base (150)                         + powerLevel × 3
)
self.updateFrameCounter = math.random(0, 2)  -- random offset for staggering
```

- **Size**: 32×32 px.
- **Collide rect**: (0, 0, 32, 32).
- **Groups**: `CollideGroups.enemy` (group 2).
- **Collides with**: player (1), props (3), wall (5), enemy (2).

### Animation States

| State | Frames | Loop |
|-------|--------|------|
| `idle` | 4–4 | yes (frameDuration=6) |
| `walk` | 1–8 | returns to 'idle' (frameDuration=6) |
| `empty` | 15–15 | yes (frameDuration=6) |
| `shine` | 9–14 | yes (frameDuration=6) |
| `eaten` | 16–16 | yes (frameDuration=6) |

### sightRadius Reduction with isTiny

When `PlayerData.isTiny == true`, the effective detection radius is halved:

```lua
function Brocorat:search(player)
    if self.stunProc > 1 then
        if PlayerData.isTiny == true then
            local tinySight = self.sightRadius / 2
            -- checks square of tinySight
        else
            -- checks square of normal sightRadius
        end
    end
end
```

Detection is a square (AABB), not a circle: both `player.x` and `player.y` must be within the range `[self.x - radius, self.x + radius]` × `[self.y - radius, self.y + radius]`.

### update() Loop

```lua
function Brocorat:update()
    self:setZIndex(self.y)                          -- dynamic y-sort
    self.updateFrameCounter = (self.updateFrameCounter + 1) % 3

    if self.movementFrames == nil then self.movementFrames = 0 end

    -- 1. Blinded state takes full priority
    if self.isBlinded then
        self.blindFrames = self.blindFrames - 1
        if self.blindFrames <= 0 then
            self.isBlinded = false
        end
        return  -- early exit, no AI executes
    end

    -- 2. Movement frame consumption
    if self.movementFrames > 0 then
        self.movementFrames = self.movementFrames - 1
        if self.updateFrameCounter == 0 then
            self:search(self.player)               -- AI every 3 frames
        end
    else
        -- idle if no pending frames
        if state is not 'idle' or 'shine' then
            self.animation:setState('idle')
        end
    end
end
```

---

## Combat Trigger — Player → Fight → DanceScene

The full chain of events when a player collides with a Brocorat:

### 1. Collision Detected

In `source/entities/player/collisions.lua`, `Player:collisionResponse(other)`:

```lua
if other:isa(Enemy) then
    if other:isa(Brocorat) then
        -- Save data of the touched enemy
        PlayerData.lastEnemyTouched.type = "Brocorat"
        PlayerData.lastEnemyTouched.id   = other.id
        PlayerData.lastEnemyTouched.x    = other.x
        PlayerData.lastEnemyTouched.y    = other.y

        if not self.isInvincible then
            PlayerData.healthPoints -= (other.damage or 1)

            if PlayerData.healthPoints < (PlayerData.danceThresholdHP or 5) then
                self:fight()                       -- → DanceScene
            else
                self:startInvincibility(Config.Invincibility.duration)  -- 1000 ms
                self:applyKnockback(other.x, other.y)
            end
        end

        return 'overlap'
    end
end
```

### 2. PlayerData.lastEnemyTouched Update

The `lastEnemyTouched` struct (defined in `PlayerDataTables.lua`):
```lua
lastEnemyTouched = {
    type = nil,   -- "Brocorat"
    id   = nil,   -- LDtk enemy ID
    x    = nil,   -- X position at time of contact
    y    = nil,   -- Y position at time of contact
}
```

Populated in `collisions.lua` before calling `fight()`. `DanceScene` reads these values to know which enemy is being fought.

### 3. fight() and Transition to DanceScene

`fight()` (defined in `player/state.lua`) only increments `PlayerData.amountDances` and calls `Noble.transition(DanceScene)`. It does not store `lastEnemyTouched` (that already happened in the previous step).

### 4. Dance Threshold vs. Invincibility

- `PlayerData.danceThresholdHP` defaults to `1` (defined in `PlayerDataTables.lua`).
- If `healthPoints >= danceThresholdHP` after subtracting damage: only 1000 ms invincibility and knockback are applied; no DanceScene.
- If `healthPoints < danceThresholdHP` (i.e., 0 or negative): `fight()` is called.

---

## powerLevel and EnemiesData System

### EnemiesData — All Fields

Defined in `PlayerDataTables.lua`:

```lua
EnemiesData = {
    powerLevel  = 1,                             -- 1-20; scales DanceScene difficulty and sightRadius
    sightRadius = Config.Enemy.sightRadiusBase,  -- 150 px; global base detection radius
    isEvolved   = false,                         -- reserved; not currently used for AI logic
}
```

### Per-Enemy sightRadius Formula

Calculated in the Brocorat constructor:
```
sightRadius = max(50, PlayerData.EnemiesData.sightRadius + powerLevel × 3)
```

Where local `powerLevel` = `PlayerData.EnemiesData.powerLevel + PlayerData.sanityCounter`.

Example: with global powerLevel=5, sanityCounter=3, sightRadiusBase=150:
- local `powerLevel` = 5 + 3 = 8
- `sightRadius` = max(50, 150 + 8×3) = max(50, 174) = **174 px**

### How powerLevel Scales with sanityCounter

`PlayerData.sanityCounter` increments every time the player's sanity reaches 0. Each time `sanityCounter` increases, all Brocorats spawned from that point onward will have a higher local `powerLevel` and therefore a larger `sightRadius`.

DanceScene difficulty also scales with `powerLevel`. The difficulty selector (`determineDifficultyUpgrade()` in `DanceScene`) performs a weighted roll using `sanityCounter` (normalized against 100), `powerLevel` (normalized against 20), and `calories` (normalized against 500).

### DanceScene Difficulty Profiles

| Profile | BPM | Buttons | powerLevel Range |
|---------|-----|---------|-----------------|
| basic | 16 | 4 | 1–5 |
| evolve | 24 | 6 | 6–12 |
| badass | 28 | 8 | 13–19 |
| boss | 32 | 12 | 20 |

The roll is probabilistic: a high powerLevel increases the chance of a harder profile but does not guarantee it. A failed roll always falls back to `"basic"`.

---

## Spawning in MazeScene

In `MazeScene:enter()`, Brocorats are spawned by iterating over `levelsLDTK[floor].entities.Brocorat`. The skip condition:

```lua
-- skip if enemy is already dead
if not entityData.customFields.dead then
    -- spawn Brocorat(x, y, moveSpeed, Zindex, player, iid)
end
```

If `customFields.dead == true`, the enemy is not instantiated.

---

## Persisting the dead State in levelsLDTK

When an enemy dies (at the end of DanceScene, via `findAndKillEnemyById`):
1. `levelsLDTK` is searched for the Brocorat whose `iid` matches `PlayerData.lastEnemyTouched.id`.
2. `customFields.dead = true` is set on the `levelsLDTK` entry.
3. `SaveSystem.save()` serializes the modified entity fields (including `dead`) into the datastore.
4. In `SaveSystem.load()`, on game boot, `dead = true` is applied to the fresh `levelsLDTK` table, preventing re-spawning.

---

## Notes for Love2D Port

### Enemy AI

- `blindSearch` and `linealSearch` are pure Lua with no SDK dependencies; they can be copied directly.
- Replace `self:moveWithCollisions(x, y)` with the Love2D collision system (Box2D via `love.physics`, or manual AABB).
- The 3 px bounce (`bounceFactor`) can be implemented by adding `normal * 3` to the position after detecting a collision.

### Turn-Based System (movementFrames)

- The pattern `movementFrames > 0` → `movementFrames -= 1` → execute AI is SDK-independent.
- The distribution of 3 frames per player action (`movementFramesPerAction = 3`) is called from the player movement system; replicate the same call after each movement.

### updateFrameCounter Throttle

- The `(counter + 1) % 3` cycle is standard Lua; works unchanged in Love2D.
- The random initial offset `math.random(0, 2)` prevents all enemies from updating on the same frame.

### Invincibility and Blink

```lua
-- In Player:update(dt) for Love2D:
if self.isInvincible then
    self.invincibilityTimer = self.invincibilityTimer - dt * 1000  -- keep units in ms
    self.visible = math.floor(self.invincibilityTimer / 100) % 2 ~= 0
    if self.invincibilityTimer <= 0 then
        self.isInvincible = false
        self.visible = true
    end
end
```

### Transition to DanceScene

Replace `Noble.transition(DanceScene)` with the transition call of your chosen state manager (e.g., `Gamestate.switch(DanceScene)` with HUMP).
