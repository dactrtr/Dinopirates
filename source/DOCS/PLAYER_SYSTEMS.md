# Player Systems Documentation

This document explores the `PlayerData` structure and how its values influence the player's movement, survival, and interaction with the game world.

---

## 🔋 Core Resource: Battery
The Battery system is the primary driver of exploration and danger.

- **Consumption**:
    - Drains at **0.5 units per move** when `isInDarkness` is true.
    - Draining occurs in `Player:move` (in `movement.lua`) or via explicit `drainBattery(amount)` calls.
- **Impacts**:
    - **Speed**: If battery < 20 and in darkness, player speed is halved.
    - **Sanity**: Sanity drains faster if battery < 20.
    - **Movement**: If the player is in darkness and has no lamp or battery, they are significantly slowed.
- **Charging**:
    - The player can charge the battery using the crank (via `chargeBattery(amount)`).
    - Charging sets `isActive = true`, allowing enemies to move while the player stays in place.

---

## 🧠 Survival: Sanity & Calories
Sanity and Nutrition represent the player's mental and physical health.

- **Sanity**:
    - **Drain**: Occurs when in darkness with low battery.
    - **Regen**: Recharges if battery > 50 or the player is in light.
    - **Sanity Counter**: Every time sanity hits 0, the `sanityCounter` increments. This increases the global **Enemy Power Level**, making encounters more difficult.
- **Health**:
    - **Representation**: Stored as `healthPoints` (default 10).
    - **HUD**: Represented by 5 hearts, where each heart is 2 points (total 10 bits).
    - **Sync**: Updated in real-time in the HUD via the `HealthIndicator` class.
- **Calories & Steps**:
    - The `pedometer()` tracks steps. 200 steps = 10 calories burned.
    - **Calories** influence the difficulty roll of the `DanceScene`. Higher calories contribute to a higher probability of encountering "Badass" or "Boss" enemy profiles.

---

## 🏎️ State & Synchronization: `isActive`
The `isActive` flag is a critical internal value.

- **Turn-based Sync**: `isActive` is set to `true` whenever the player moves or charges.
- **NPC Movement**: Enemies and CrewMembers only process their AI movement when the player is active. This ensures that the world "moves when you move," allowing for strategic planning during battery management.
- **Tokens**: Moving distributes "Movement Frames" (3 per move) to all sprites, ensuring smooth following without unintended speed accumulation.

---

## 🤏 Transformation: Size & Collisions
- **`isTiny`**:
    - Toggled via the **Minifier** prop.
    - Changes the player's collision rectangle to a smaller **14x14** size.
    - Enables access to "Hole" props.
    - Changing size triggers specific `tiny` animation states for all directions.
- **`isBig`**: Managed via the transformation cycle, though currently less used than the tiny state in the primary maze logic.

---

## ↕️ Level Transitions: Falling & Climbing
Vertical transitions allow the player to move between floors through holes, tubes, or ladders.

### `fallBelow()`
- **Mechanism**:
    1.  Gets current floor from `PlayerData.floor`.
    2.  Validates "Lower" connection in `DoorsConnection`.
    3.  Searches `neighbourLevels` for direction `<`.
    4.  Calculates target room number.
- **Positioning**: Preserves `x` and `y` coordinates for seamless verticality.
- **Visuals**: Uses a specific `transitionFall` imagetable for a falling effect.

### `riseAbove()`
- **Mechanism**: Similar to `fallBelow()` but checks for "Upper" connection and direction `>`.
- **Trigger**: Can be triggered by collision with tubes or ladders.

---

## 🎒 Inventory & Skills
Items and skills can be granted either by picking up a fixed item type or dynamically via a `grants` field in level data (common for `itemgift` and `notes`).

- **Items**:
    - `hasLamp`: Enables vision and sanity regeneration. Grants **Lightburst** skill.
    - `hasBoots`: Provides "Hole" safety; player drains battery to walk over holes instead of falling. Grants **Dash** skill.
    - `hasPlunger`: Provides "Slime" safety; player can walk over slime tiles (IDs 89–97) instead of sliding. Grants **Plungerang** skill. See [PROPS_AND_ITEMS.md](PROPS_AND_ITEMS.md) for sliding mechanics.
    - `hasBag`: Required to capture CrewMembers.
    - `hasRadio` / `hasNotes`: Story-relevant items that enable specific dialogs/video feeds.
    - `hasTools`: Story-relevant or utility item (used for certain environment interactions).
- **Skills**:
    - `canFlash` (Lightburst): Costs **10 battery**. Blinds enemies in a radius. Granted by `hasLamp`.
    - `canDash`: Costs **10 battery**. Enables a fast dash attack with a cooldown. Granted by `hasBoots`.
    - `canPlungerang`: Boomerang skill that can stun enemies or interact with props at a distance. Does not consume battery. Granted by `hasPlunger`. **Movement is locked while the projectile is in flight.** See [PLUNGERANG.md](PLUNGERANG.md) for exhaustive details and Love2D porting.

> [!TIP]
> Always check `PlayerData.isInDarkness`. Most survival mechanics (Sanity drain, Battery drain, Speed debuffs) are gated by this boolean.

---

## 🛠️ Love2D Porting Guide

This section details critical implementation differences when porting the **Player** entity from Playdate SDK (Lua) to Love2D.

### 1. Movement & Collisions (`NobleSprite` vs. Bump.lua)
The Playdate SDK handles collisions internally via `sprite:moveWithCollisions(x, y)`.
- **Playdate**: returns `actualX, actualY, collisions, length`.
- **Love2D Implementation**:
    - **Library**: `bump.lua` is the standard for AABB collisions.
    - **Logic**:
    ```lua
    -- Instead of self:moveWithCollisions(goalX, goalY)
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.collisionFilter)
    self.x, self.y = actualX, actualY
    ```
    - **Filters**: The `self:setGroups()` and `self:setCollidesWithGroups()` logic must be converted to a `collisionFilter` function passed to `world:move`.

### 2. Input Handling
Playdate input is polled via `playdate.buttonIsPressed()`.
- **Love2D Implementation**:
    - **Movement**: Map `WASD` or Arrow Keys to the directional logic in `Player:move(dir)`.
    - **Action (A/B)**: Map `Space/Enter` (A) and `Shift/Esc` (B).
    - **Crank (Minifier)**: The specific mechanic of rotating the crank to shrink/grow needs remapping.
        - **Option A**: Scroll Wheel (Mouse).
        - **Option B**: `Q` and `E` keys to rotate left/right.
        - **Option C**: Gamepad Triggers (L2/R2).

### 3. Sprite System & Animation
- **NobleSprite**: This library abstracts sprite states and animations using `imagetables`.
- **Love2D Implementation**:
    - **Class**: Use a standard class library.
    - **Assets**: Load the player spritesheet (`assets/images/player/player`) as a single `Image`.
    - **Animation**: Use `anim8` to define grids and animations (e.g., `grid('1-4', 1)` for idle).
    - **Z-Indexing**: Love2D does **not** auto-sort. You MUST implement a robust depth-sorting system in your main `love.draw` loop:
    ```lua
    table.sort(entities, function(a,b) return a.y < b.y end)
    ```

### 4. Turn-Based "Active" State
The game uses a pseudo-turn-based system driven by `PlayerData.isActive`.
- **Logic**:
    1.  Player initiates move -> `isActive = true`.
    2.  `distributeMovementTokens(amount)` gives "action points" to enemies.
    3.  Enemies/NPCs only move/update AI if `isActive` was triggered.
- **Porting Note**: This logic is platform-agnostic Lua. **Preserve it exactly**. It ensures the "Time Moves When You Move" mechanic works. Do not switch to a standard `dt` based continuous update for enemies.

### 5. Scene Transitions
    - **Visuals**: The `imagetableEnter/Exit` transitions (like the falling transition) will need to be reimplemented using shaders or simple overlay drawing in Love2D.

### 6. Skills & Abilities
Specific considerations for the three core skills:

-   **Lightburst (`canFlash`)**:
    -   **Cone Geometry**: uses `playdate.geometry.polygon`. In Love2D, simply use a table of vertices: `{x1, y1, x2, y2, ...}`.
    -   **Hit Detection**: The Playdate SDK has `polygon:containsPoint(x, y)`. In Love2D, you must implement a "Point in Polygon" function (Ray Casting algorithm) to check if an entity is inside the light cone vertices.

-   **Dash (`canDash`)**:
    -   **Timers**: Playdate uses `playdate.getCurrentTimeMilliseconds()`. Love2D uses `love.timer.getTime()` (returns seconds). Ensure you convert correctly (e.g., `cooldown = love.timer.getTime() + 0.5`).
    -   **Movement**: During the dash state, calls to `world:move` must happen manually in `update()` based on the dash vector.

-   **Plungerang (`canPlungerang`)**:
    -   **Entity**: The Projectile is a separate `NobleSprite`. In Love2D, it should be its own Class instance added to the scene's entity table.
    -   **Vector Math**: The `dx/dy` approach for homing back to the player is standard Lua logic and works as-is.
    -   **Collision Filter**: Important! The projectile needs a specific Bump filter: it must **cross** (pass through) the player and items, but **touch** (hit) enemies and walls.
### 7. Vertical Transitions (Falling & Climbing)
- **Playdate**: Uses `Noble.transition` with custom image tables.
- **Love2D Implementation**:
    - **Scene Management**: Replace `Noble.transition` with your own (e.g., `SceneManager:switchTo(nextScene, "fall", 1.5)`).
    - **Transitions**: Use shaders (e.g., vertical blur) or simple sprite-based animations for the "fall" or "climb" effects.
    - **Detection**: Use `bump.lua` or `HC` for collision detection with holes/tubes to trigger these transitions.
    - **Optimization**: You can preload adjacent rooms for faster transitions.
    ```lua
    -- Example shader-based fall effect:
    SceneManager:switchTo(nextScene, {
      type = "fall",
      duration = 1.5,
      shader = fallShader,  -- Vertical blur shader
      onComplete = function() self:spawn() end
    })
    ```

### 8. Performance & Other Details
- **Trigger Checks**: To optimize, only check overlapping sprites if the player moved significantly (e.g., > 5 pixels) or if already inside a trigger.
- **Invincibility**: Implement a flicker effect by toggling visibility based on a timer and refresh rate.
- **Speed in Darkness**: Always check `PlayerData.isInDarkness`. Reduce speed (e.g., to 50%) when battery is low (< 20) or when the player has no lamp.
- **Sliding State**: When `isSliding` is active, ignore directional input and apply the sliding vector in the `update` loop.
