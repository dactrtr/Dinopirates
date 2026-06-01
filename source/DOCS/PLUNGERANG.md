# Plungerang

The player's boomerang projectile system. It is split across two files: skill activation in `plunge.lua` and the projectile entity in `projectile.lua`.

---

## Entry Point — `Player:plunge()` (`entities/player/plunge.lua`)

The skill is activated when the player presses B in a lit room (in darkness, B fires
the lamp instead — see `entities/player/abilities.lua`).

### Validations in Order

```
1. PlayerData.items.hasPlunger == true (has the item)
2. PlayerData.skills.canPlungerang == true (has the skill)
3. PlayerData.isTiny == false          (cannot throw in tiny mode)
4. self.isPlunging == false            (no projectile currently in flight)
5. self.hasProjectile == true          (has the projectile; if lost, cannot throw)
6. self.isAlive == true
7. PlayerData.isGaming == true
8. PlayerData.direction != 'idle' AND direction != nil  (must be moving)
```

If all validations pass:
```lua
self.isPlunging = true
self.projectile = Projectile(self, direction)
self:idle()    -- locks player movement by setting idle state
```

### `Player:onProjectileCaught()`

Called by the projectile when it returns to the player:
```lua
self.isPlunging = false
self.projectile = nil
```

---

## `Projectile` Class (`entities/player/projectile.lua`)

Extends `NobleSprite`. Image: `assets/images/items/projectile-table-24-24`.

### Constructor

```lua
Projectile(player, direction)
```

| Parameter | Description |
|---|---|
| `player` | Reference to the player sprite |
| `direction` | `"left"`, `"right"`, `"up"`, or `"down"` |

Initial properties:

| Property | Initial Value | Source |
|---|---|---|
| `self.startX`, `self.startY` | Current player position | `player:getPosition()` |
| `self.direction` | Launch direction | parameter |
| `self.distanceTravelled` | 0 | — |
| `self.maxDistance` | 100 px | `Config.Projectile.maxDistance` |
| `self.returning` | `false` | — |
| `self.speed` | 8 px/frame | `Config.Projectile.speed` |

Collision setup:
- Sprite size: 24×24 px.
- Collision rect: `{4, 4, 16, 16}` — effective 16×16 centered area.
- Own group: `CollideGroups.items` (4).
- Collides with: `enemy` (2), `props` (3), `wall` (5), `crewMember` (7).
- Added to the world at `(player.x, player.y + 16)`.

Animation:
- State `spin`: frames 1–4, duration 4 per frame.

---

## Movement Logic

### Outgoing Phase

```lua
-- Every frame:
local moveX, moveY = 0, 0
if direction == 'left'  then moveX = -speed  end
if direction == 'right' then moveX =  speed  end
if direction == 'up'    then moveY = -speed  end
if direction == 'down'  then moveY =  speed  end

local actualX, actualY, collisions, length =
    self:moveWithCollisions(self.x + moveX, self.y + moveY)

self.distanceTravelled += speed
if self.distanceTravelled >= maxDistance then
    self.returning = true
end
```

Moves at constant speed in a single direction. `distanceTravelled` accumulates pixels traveled. When `maxDistance` (100 px) is reached, it automatically enters the return phase.

### Return Phase (Homing)

```lua
-- Every frame:
local dx = player.x - self.x
local dy = player.y - self.y
local dist = math.sqrt(dx*dx + dy*dy)

if dist < speed then
    self:onCaught()    -- caught
else
    local vx = (dx / dist) * speed
    local vy = (dy / dist) * speed
    self:moveWithCollisions(self.x + vx, self.y + vy)
end
```

The projectile chases the player's **current** position each frame. If the player moves during the return, the projectile adjusts its trajectory. Catching occurs when the remaining distance is less than `speed` (8 px).

---

## Collisions — Behavior by Target

| Target | What Happens | Effect |
|---|---|---|
| `Enemy` | Immediately enters return phase | `entity:blind(Config.Projectile.blindDuration)` — 60 frames of blindness |
| `PropItem` of type `box` (not destroyed) | Immediately enters return phase | `other:smash()` — destroys the box (persisted via `destroyProp`) |
| Other `PropItem` or `Box` (wall) | Immediately enters return phase | No effect on the prop |
| `CrewMember` | Projectile is destroyed | `player.hasProjectile = false`, `player.isPlunging = false`, `:remove()` |
| Player (catch) | `:onCaught()` → `:remove()` | Calls `player:onProjectileCaught()`, unlocks movement |

### `Projectile:hitEntity(entity)`

```lua
function Projectile:hitEntity(entity)
    if entity.blind then
        entity:blind(Config.Projectile.blindDuration)   -- 60 frames
    end
end
```

Only applies the blind effect. The enemy remains alive; actual combat happens in DanceScene.

### `Projectile:collisionResponse(other)`

Returns `'overlap'` for all targets — the projectile is not physically pushed; all reaction logic is handled in `update()`.

---

## Player Movement Lock During Flight

While `player.isPlunging == true`:
- `Player:plunge()` cannot launch another projectile (guarded by `isPlunging`).
- `player:idle()` is called on launch — the animation stays in idle state.
- D-pad movement input remains active at the input level, but the animation stays idle until `player:onProjectileCaught()` is called.

**Permanent projectile loss:** If the projectile hits a `CrewMember`, `player.hasProjectile` is set to `false`. The player cannot throw again until the item is recovered in the world.

---

## Relevant Constants (`Config.Projectile`)

| Field | Value | Description |
|---|---|---|
| `maxDistance` | 100 px | Distance before automatic return begins |
| `speed` | 8 px/frame | Linear outgoing speed and homing return speed |
| `blindDuration` | 60 frames | Blindness duration when hitting an enemy |

---

## Notes for Porting to Love2D

### Projectile Class Structure

```lua
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(player, direction)
    local self = setmetatable({}, Projectile)
    self.player = player
    self.direction = direction
    self.speed = 8 * 50   -- 8 px/frame × 50fps = 400 px/s
    self.maxDistance = 100
    self.distanceTravelled = 0
    self.returning = false
    self.x = player.x
    self.y = player.y + 16
    world:add(self, self.x - 8, self.y - 8, 16, 16)
    return self
end
```

### Update with dt

```lua
function Projectile:update(dt)
    local move = self.speed * dt
    if self.returning then
        local dx = self.player.x - self.x
        local dy = self.player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < move then
            self:onCaught()
            return
        end
        local vx, vy = (dx/dist)*move, (dy/dist)*move
        self:moveInWorld(vx, vy)
    else
        local dirMap = {
            left={-move,0}, right={move,0}, up={0,-move}, down={0,move}
        }
        local d = dirMap[self.direction]
        self:moveInWorld(d[1], d[2])
        self.distanceTravelled = self.distanceTravelled + move
        if self.distanceTravelled >= self.maxDistance then
            self.returning = true
        end
    end
end
```

### bump.lua Collision Filter

```lua
local function projectileFilter(item, other)
    if other.type == "enemy" or other.type == "wall" or other.type == "prop" then
        return "cross"   -- detect without blocking
    end
    if other.type == "player" and item.returning then
        return "cross"
    end
    return nil  -- ignore
end
```

### Movement Unlock

```lua
function Player:update(dt)
    if self.isPlunging then
        -- Only update the projectile, do not process movement input
        if self.projectile then self.projectile:update(dt) end
        return
    end
    -- Normal input...
end
```
