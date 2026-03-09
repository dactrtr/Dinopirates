# Enemies and Combat Documentation

This document explains the enemy AI system and the rhythm-based "Dance Scene" combat system.

---

## 👾 Enemy AI & Global Data

Enemies (like the `Brocorat`) inherit from the base `Enemy` class and are influenced by global stats stored in `PlayerData`.

### 1. Global Enemy Data (`PlayerData.EnemiesData`)
Located in `source/assets/data/PlayerDataTables.lua`, these values scale the difficulty of the game:
- **`powerLevel`**: (1-20) Increases enemy detection range and determines difficulty profiles in the Dance Scene.
- **`sightRadius`**: (Base 50) The distance at which an enemy can detect the player.
- **`isEvolved`**: A boolean flag indicating if enemies have reached a more dangerous state.

### 2. Detection & Movement
- **`search(player)`**: Checks if the player is within `sightRadius`. If detected, triggers `blindSearch`.
- **`blindSearch(player)`**: Moves the enemy directly toward the player's current X/Y.
- **`linealSearch(player)`**: An alternative AI where enemies only move if the player is aligned on the same X or Y axis.
- **Speed Scaling**: `updateMoveSpeed()` adjusts enemy speed based on the player's battery and darkness. They slow down significantly when the player is in darkness with low battery.
- **Group Separation**: Enemies (group `enemy`) are distinct from Crew Members (group `crewMember`). This separation prevents the player from unintentionally triggering combat-specific logic (like the Dance Scene) when interacting with crew members.
- **Movement Tokens**: Like CrewMembers, enemies use `movementFrames` to throttle their updates for performance.

### 3. Special Behaviors
- **Sonar**: `sonar()` makes enemies "shine" when the player is nearby, focused, and in darkness, providing visual feedback of their presence.
- **Projectile (Plungerang)**: Hit detection logic in `projectile.lua` includes `CollideGroups.enemy`. If hit, `hitEntity(other)` is called, which typically blinds/stuns the enemy for 60 frames.
- **Blinding**: `blind(frames)` temporarily stops enemy movement when hit by a light flash or projectile.
- **Edible Props**: Some enemies can "eat" certain `PropItem` objects if their `powerLevel` is high enough.

---

## 💃 Dance Scene (Combat System)

When a player collides with an enemy, the game transitions to the `DanceScene`.

### 1. The Transition
In `collisions.lua`, hitting an `Enemy` calls `self:fight()`, which:
- Increments `PlayerData.amountDances`.
- Stores info about the encounter in `PlayerData.lastEnemyTouched` (ID, Type, Position).
- Transitions the scene to `DanceScene`.

### 2. Difficulty Profiles
The `DanceScene` selects a pattern profile based on `PlayerData.EnemiesData.powerLevel`:
- **Basic** (1-5): Slow BPM (16), 4 buttons, mostly arrows.
- **Evolve** (6-12): Faster BPM (24), 6 buttons, mixed input.
- **Badass** (13-19): Very fast BPM (28), 8 buttons, tough patterns.
- **Boss** (20): Max speed BPM (32), 12 buttons, high button spam.

### 3. Rhythm Mechanics
- **ButtonPress**: Sprites move from right to left across the screen.
- **HitZone**: The area on the left where the player must press the corresponding button.
- **Balance Bar**: A "tug-of-war" indicator.
    - **Correct Press**: Moves balance toward the **Win** side. `A/B` buttons deal damage to enemy HP; **Arrows** increase evade power/accuracy.
    - **Wrong Press/Miss**: Moves balance toward the **Lose** side.
- **Animations**: `EnemyRatDance` and `PlayerDance` change animations based on inputs and hits.

### 4. Outcomes
- **Win**: The enemy is removed from the world via `findAndKillEnemyById`, player gains 60 calories, and transitions back to the maze.
- **Lose**: Transitions to the `TitleScene` (Game Over).

> [!IMPORTANT]
> The `determineDifficultyUpgrade()` function in `DanceScene` uses a weighted calculation of Player **Sanity**, **Power**, and **Calories** to decide if an encounter should be harder than the base level.

---

## 🛠️ Love2D Porting Guide: Rhythm Combat

This section details implementation of the **DanceScene** mechanics in Love2D.

### 1. Input Handling (`Noble.Input` vs. `love.keypressed`)
Playdate uses a table-based `inputHandler` with callbacks like `AButtonDown`.
- **Love2D Implementation**:
    - Use the standard `love.keypressed(key)` callback in your Scene state.
    - **Mapping**:
        ```lua
        function DanceScene:keypressed(key)
            if key == "return" or key == "space" then
                self:input("aButton")
            elseif key == "escape" or key == "shift" then
                self:input("bButton")
            elseif key == "left" then self:input("leftButton")
            elseif key == "right" then self:input("rightButton")
            elseif key == "up" then self:input("upButton")
            elseif key == "down" then self:input("downButton")
            end
        end
        ```
    - The `DanceScene.lua` logic for `scene:danceStep(key)` can be reused almost exactly once the input is routed.

### 2. Visual Primitives & Drawing
The scene relies on `Graphics.drawRect`, `drawLine`, and `drawCentered` (Playdate SDK).
- **Love2D Implementation**:
    - **Primitives**: Use `love.graphics.rectangle('line', ...)` and `love.graphics.line(...)`.
    - **Images**: Playdate images have methods like `drawCentered(x, y)`. In Love2D, `love.graphics.draw(img, x, y)` draws from the top-left.
        - **Correction**: To draw centered: `love.graphics.draw(img, x - img:getWidth()/2, y - img:getHeight()/2)`.

### 3. Scene Lifecycle
The game uses `NobleScene` for management (`init`, `enter`, `update`, `exit`).
- **Love2D Implementation**:
    - Use a library like **Hump Gamestate**. The method names `enter`, `update`, `draw`, `leave` map very closely to Noble's lifecycle.
    - **Transitions**: Complex transitions (like `MetroNexus`) are specific to Noble. You will need to implement custom screen wipes (e.g., a simple fade-to-black or sliding rectangle) in Love2D.

### 4. Randomness (RNG)
The scene seeds RNG using `playdate.getCurrentTimeMilliseconds()` to ensure unique difficulty rolls.
- **Love2D Implementation**:
    - Use `math.randomseed(os.time())` in `love.load()`.
    - Lua's `math.random` works consistently across both platforms.

### 5. Hit Detection
The `HitZone` checks for overlapping sprites (`overlappingSprites()`).
- **Love2D Implementation**:
    - Since `ButtonPress` objects are simple moving entities (not full physics bodies), you can use simple AABB (Rectangle) intersection checks in `update()`:
    ```lua
    function checkOverlap(a, b)
        return a.x < b.x + b.w and a.x + a.w > b.x and
               a.y < b.y + b.h and a.y + a.h > b.y
    end
    ```
