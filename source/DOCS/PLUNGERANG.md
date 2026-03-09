# 🪠 Plungerang System

The **Plungerang** is a versatile skill and tool in *Dinopirates*. It functions as a boomerang-style projectile that allows for long-range interactions, enemy stunning, and strategic movement locking.

---

## 🏗️ Core Mechanics

The system is split between two main components:
1.  **Skill Logic**: Located in `entities/player/plunge.lua`. Handles input validation and state management.
2.  **Projectile Entity**: Located in `entities/player/projectile.lua`. Handles physical movement, collisions, and lifecycle.

### 1. Activation (`Player:plunge`)
The skill is triggered when the player uses the **Action** button while the Plunger is equipped.
- **Requirements**:
    - `PlayerData.activeItem == 3` (Plunger equipped).
    - `PlayerData.items.hasPlunger` and `PlayerData.skills.canPlungerang` must be true.
    - **Size Constraint**: The player cannot use the Plungerang while in the `isTiny` state.
    - **One at a Time**: Only one projectile can exist at once (`isPlunging` guard).
    - **Directional Check**: Cannot be fired if the player is in an `idle` state; must have a directional heading.

### 2. Physical Lifecycle
When launched, a `Projectile` sprite is created and follows three distinct phases:
- **Phase A: Launch**: Moves in the player's initial firing direction (Left, Right, Up, Down).
- **Phase B: Maximum Distance**: Travels up to `maxDistance` (default: 100 pixels) before automatically entering the Return phase.
- **Phase C: Return**: Homes in on the player's *current* position, even if the player has moved (though movement is typically locked).

### 3. Movement Locking
While the projectile is in flight:
- The player's `isPlunging` flag is set to `true`.
- The player is set to an `idle` animation state.
- **Locking**: Standard movement and other skills are disabled during this time, creating a tactical risk when missing a target.

---

## 🎯 Interactions & Collisions

The Plungerang interacts differently depending on the target:

| Target | Result | Effect |
| :--- | :--- | :--- |
| **Enemy** | Hit & Return | Blinds/Stuns the enemy for a set duration. Returns immediately. |
| **Props / Walls** | Hit & Return | Bounces off collision box and begins the return phase. |
| **CrewMember** | **Projectile Lost** | The CrewMember "catches" or destroys the tool. `hasProjectile` becomes `false`. |
| **Player (Catch)** | Skill Success | Resets `isPlunging` and allows movement again. |

> [!WARNING]
> **Losing the Plungerang**: If you hit a `CrewMember`, you lose the projectile entirely. You must find it again in the world to restore the skill.

---

## 🛠️ Love2D Porting Guide

Implementing the Plungerang in Love2D requires migrating from Playdate's `NobleSprite` to a standard class system with `bump.lua`.

### 1. Projectile Class Structure
```lua
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(player, direction)
    local self = setmetatable({}, Projectile)
    self.player = player
    self.speed = 480 -- Pixels per second (8 * 60)
    self.returning = false
    self.x, self.y = player.x, player.y
    -- Add to bump world
    world:add(self, self.x, self.y, 16, 16)
    return self
end

function Projectile:update(dt)
    if self.returning then
        -- Homing logic
        local dx, dy = self.player.x - self.x, self.player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < 10 then self:onCaught() end
        
        local vx, vy = (dx/dist) * self.speed, (dy/dist) * self.speed
        self:move(vx * dt, vy * dt)
    else
        -- Linear movement
        -- ...
    end
end
```

### 2. Collision Filter (`bump.lua`)
The Plungerang needs to ignore the player on launch but hit enemies.
```lua
local function plungerFilter(item, other)
    if other.isEnemy or other.isWall then return 'touch' end
    if other.isPlayer and item.returning then return 'touch' end
    return 'cross'
end
```

### 3. State Syncing
Ensure the `Player` state machine handles the lock correctly:
```lua
function Player:update(dt)
    if self.isPlunging then
        -- Skip normal input processing
        return 
    end
    -- Normal movement processing...
end
```

### 4. Input Remapping (The Crank Factor)
On Playdate, shrinking is tied to the crank. In Love2D:
- **Mouse Wheel**: `wheelmoved(x, y)` to toggle size.
- **Keys**: `Q/E` or `[` `]` as digital "crank" substitutes.
- **Vibration**: Add a small screen shake or haptic feedback when the Plungerang hits a wall to maintain the "tactile" feel of the Playdate version.
