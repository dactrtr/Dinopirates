# Props & Items Documentation

This document details the environment objects (Props) and collectibles (Items) that populate the game world.

---

## 📦 Items (Pickups)
Items are specialized sprites that grant the player new abilities or resources upon contact.

### 1. Item Types & Rendering
Items are implemented in `entities/items/Items.lua` directly inheriting from the game's sprite system. 
- **Tileset**: `assets/images/items/items-key-table-32-32.png`
- **Size & Colliders**: Every item has a visual size and collision box of `32x32` pixels. They are all rendered on the `ZIndex.items` layer.
- **Animation States / Frames**: All item animations operate at an 8-frame duration.
  - **`boots`**: (Frames 1-3) Prevents falling into holes if battery is available.
  - **`plunger`**: (Frames 4-6) Prevents sliding on slime.
  - **`lamp`**: (Frames 7-9) Enables visibility in dark rooms and triggers sanity regen logic.
  - **`notes`**: (Frames 10-12) Story-relevant item. Updates `PlayerData.skills`.
  - **`keycard`**: (Frames 13-15) Grants access to doors with matching `keyNumber`.
  - **`itemgift`**: (Frames 16-18) A generic delivery item that updates `PlayerData.items` (e.g., `hasPlunger:true`).

### 2. Positioning & Dynamic Grants (LDtk)
Items are positioned using LDtk level data. In `MazeScene.lua`, any LDtk entity that resides on the `"Items"` layer or has the custom field `cf.isItem == true` is instantiated as:
`Items(x, y, type, keyNumber, cf.grants)`

For dynamic items (`itemgift` and `notes`), they use a `grants` custom field to directly update `PlayerData`.
- **Format**: `"key1:value1,key2:value2"` (e.g., `"hasPlunger:true"` or `"canFlash:true"`).
- **Conditional Rendering**: In `MazeScene.lua`, items with a `grants` field are only spawned if the player **does not** already possess the granted item/skill. This ensures objects disappear from the world permanently once collected.

### 3. Collection & Interaction Flow
When the player collides with an Item (handled in `entities/player/collisions.lua`):
1. **Removal**: The `other:removeAll()` method is called on the item. This instantly disables the item's `FXsonar` (visual ping) and removes the sprite from the active scene.
2. **Player Grant logic**: A corresponding "grab" function (`self:grabKey()`, `self:grabBoots()`, `self:grabItemGift()`, etc. located in `entities/player/items.lua`) is invoked on the Player object.
3. **Data update**: This modifies the universal `PlayerData` state (e.g. `PlayerData.items.hasPlunger = true`, or `PlayerData.keys[keyNumber] = true`), applying the game logic.

---

## 🖼️ PropItem System
Props represent the interactive furniture and environmental details.

### 1. Visuals and States
Props share a single image sheet (`props.png`) and use animation states like `chair`, `table`, `microwave`, `fridge`, etc.
- **Debris**: When a prop is destroyed, its state changes to `debris`.
- **Z-Index**: Props dynamically update their Z-Index based on their Y position (`update()` loop) unless they are "flat" (like blood or holes) or special (like minifiers).
- **Configuration System**: `PropItem:init` uses a centralized `propConfigs` table to manage properties and colliders based on the prop `type`.
  - **Colliders**: Specific `collideRect` values are defined for unique shapes (e.g., trees, screens). Others use a default `(2, 10, 28, 18)`.
  - **Properties**: Flags like `isEdible`, `isHole`, and `isSlime` are derived from this configuration.
  - **Z-Index Overrides**: Certain props are set to a static `ZIndex.props` if they are non-collidable, destroyed, or environmental (holes/slime).

### 2. Environmental Hazards & Utility
- **Holes**: Defined by type (e.g., `holeCenter`, `holeLeft`).
    - **Falling**: In `collisions.lua`, hitting a hole without boots/battery triggers `self:fallBelow()`.
    - **Walking**: With boots, the player drains battery but remains in the room.
- **Minifiers**: Special pods used to change the player's size (`isTiny`) via a two-stage interaction:
    1.  **Locking**: Standing on a minifier displays "Press A". Pressing A centers the player and locks movement (`isGaming = false`).
    2.  **Transformation**: The player must manually rotate the physical **crank** to change size. Rotating counter-clockwise shrinks the player, while clockwise returns them to normal size. The `transformCycle` animation plays during this phase.
    3.  **Breakout**: If the player is locked in the minifier state (after pressing A), they can press **B** at any time to cancel the process, hide the HUD, and restore normal movement.
    4.  **Completion**: Once the target size is reached, movement is restored automatically and the player can walk away.
- **Slime (Tiles 89–97)**: Environmental hazard that causes the player to slide continuously without manual control until an obstacle or clear tile is reached.
    - **Detection**: Slime is detected **via the tilemap**, not via prop collisions. Tile IDs `89` through `97` represent slime tiles. The function `GetTileUnderPlayer(px, py)` (found in `Utilities.lua`) samples the tile ID using the player's 16x16 footprint (feet level).
    - **Triggering**: Evaluated per frame via `Player:checkSlimeTile()`. If on slime and unequipped (no Plunger), `self:startSliding(direction)` fires. The `direction` inherits the player's current facing direction when they touch the slime.
    - **Sliding Behavior**: 
        - **Locks Control**: `isSliding = true`, preventing standard input handling.
        - **Speed**: Movement is fixed at `slidingSpeed = 4` (faster than a walk, slower than a dash).
        - **Animations**: The system dynamically changes the animation state based on direction (e.g., `slideRight`, `slideDown`) or context (`slideTiny` if `PlayerData.isTiny`).
    - **Leaving Slime (Stopping Mechanics)**: The slide logic calls `self:endSliding(hitWall)` if either of two conditions is met:
        1. **Tile Departure**: The 16x16 footprint is no longer sampling a valid slime tile.
        2. **Wall Collision**: The player's bounding box hits a solid obstacle (e.g., wall, solid prop).
    - **State Re-establishment**: When an exit occurs:
        - Internal tracking `self.isSliding = false` and `self.slidingDirection = nil` is cleared.
        - Facing resets `PlayerData.direction = 'idle'`.
        - **Exit Animations**: An exit animation completes the motion visually (`slideExitRight`, `slideExitLeft`, `slideExitUp`, `slideExitDown`). If `isTiny` is true, it simply resets to `idle()`.
    - **Wall Collision Handling (`slideHitWall`)**: An important edge case. If the player slides into a wall *while still standing on slime*, `self.slideHitWall = true` is set. This blocks the game from immediately re-triggering the slide process every frame, effectively pinning the player against the wall until they manually provide directional input to walk away or start a new slide.
    - **Antislip Protection**: If the player has the **plunger** item (`PlayerData.items.hasPlunger`), `checkSlimeTile()` returns early and the player walks normally, unaffected.

### 3. Destruction & Persistence
Props can be destroyed by certain enemies or effects.
- **`destroyProp(id)`**: Uses the unique LDtk IID to find and mark the prop as destroyed in the global level data.
- **Persistence**: `MazeScene.lua` checks the `destroyed` custom field when spawning props, ensuring they remain rubble if previously broken.

---

## 👥 Entity Interactions

Different entities have distinct rules for interacting with the environment:

- **CrewMember**: Now has its own dedicated collision group (`crewMember`).
    - **Solid Collisions**: Collide and slide against solid props (chairs, tables, cabinets), walls, and other **Enemies**. Colliding with enemies triggers their "bounce" logic.
    - **Pass-through**: Pass through non-solid props (Minifier pods, blood, debris), pickup items (Keycards, items), and triggers.
- **Enemies (Brocorat)**: Standard enemies may have different rules, such as being able to "eat" certain edible props depending on their power level.

> [!TIP]
> Items use a `FXsonar` instance to "ping" their location, helping the player find them in low-visibility or dark areas.

---

## 🛠️ Love2D Porting Guide

This section details specific implementation differences when porting the **PropItem** and **Item** systems from the Playdate SDK (Lua) to Love2D.

### 1. Sprite System (`NobleSprite` vs. Love2D)
The game uses `NobleSprite`, a wrapper around the Playdate SDK's `playdate.graphics.sprite`.
- **Playdate**: Sprites are objects managed by the system list (`gfx.sprite.update()`). They have built-in methods for drawing, collision, and dirty rect updates.
- **Love2D Implementation**:
    - **Base Object**: You will need a standard Class implementation (like `middleclass` or `classic`) for `PropItem`.
    - **Drawing**: Instead of automatic drawing, `PropItem` instances should be stored in a table (e.g., `self.props` in the Scene) and iterated over in `love.draw()`.
    - **Animation**: Use a library like `anim8`. The Playdate code uses `imagetables` (sequence of images). In Love2D, this translates to a **Sprite Atlas** (single large image) with **Quads**.
    - **Asset Path**: `assets/images/props/props` should be loaded as a single `Image` object, and the frames defined as `Quad`s based on a grid (32x32 mostly).

### 2. Item Management & Rendering in Love2D
When implementing **Items** in Love2D, several core rendering concepts differ from Playdate's SDK:
- **Tilesets and Quads**: Since Items use a single `assets/images/items/items-key-table-32-32.png` file, you need to load the image once and use `love.graphics.newQuad` to map to the correct 32x32 regions. You can use a library like `anim8` to construct the 3-frame animations for `boot`, `plunger`, `lamp`, etc., replicating the 8-frame duration.
- **Spawning via LDtk**: Iterating through room data (parsed via a JSON or LDtk library), read the `"Items"` layer and instantiate your `Item` class with `(x, y, type, keyNumber, grants)`.
- **Despawning / Collection Mechanics**: When bump.lua detects a collision between the Player and an Item, invoke your Lua port of `removeAll()`:
  - This should immediately drop the `Item` from the `world:remove(item)` (bump.lua tracking) and the scene's draw list `table.remove(scene.items, i)`.
  - Afterwards, invoke the localized Player functions to push the new abilities to the global `PlayerData` structure.

### 3. Collision System
Playdate's sprite system handles collisions internally with `moveWithCollisions`.
- **Logic**: `PropItem.lua` sets a collision rect using `setCollideRect(x, y, w, h)`.
- **Love2D Implementation**:
    - Use a physics/collision library like **Bump.lua** (AABB collisions).
    - **Initialization**: When creating a prop or an item, add it to the Bump world: `world:add(entity, entity.x, entity.y, entity.w, entity.h)`.
    - **Update**: Sync the Bump world position if the prop moves (rare for static props, but relevant for "pushed" objects).
    - **Groups/Filters**: The `setGroups(3)` call in Playdate corresponds to collision layers or filters in Bump. Ensure Props and Items are in a "Solid" or "Item" layer that the Player checks against for resolving intersections.

### 3. Z-Indexing (Depth Sorting)
Playdate sprites have a `zIndex` property and the system automatically sorts draw order.
- **Logic**: Most props update their Z-Index every frame in `update()`: `self:setZIndex(self.y)`. This creates a pseudo-3D effect where objects lower on screen are drawn on top of objects higher up.
- **Love2D Implementation**:
    - Love2D does **not** sort automatically.
    - You must manually sort the table of entities before drawing:
    ```lua
    table.sort(scene.entities, function(a, b) return a.y + a.height < b.y + b.height end)
    ```
    - **Static Z-Index**: Props with `isStaticZIndex = true` (like holes or rugs) should be drawn first (background layer) or forced to a low index to ensure characters always walk *on top* of them.

### 4. Input & Mechanics (The Crank)
The **Minifier** prop relies on the physical Playdate Crank.
- **Playdate**: `playdate.getCrankPositions()` controls the shrinking/growing logic.
- **Love2D Implementation**:
    - Remap this mechanic since standard controllers lack a crank.
    - **Mouse**: Scroll wheel up/down.
    - **Keyboard/Gamepad**: Hold `L/R Triggers` or use `Up/Down` keys to simulate rotation.
    - **Visuals**: The UI usage of the crank indicator should be replaced with a relevant prompt (e.g., "Scroll" or "Hit Triggers").

### 5. Global Configuration
The `propConfigs` table in `PropItem.lua` is critical data that defines collision boxes and behaviors (isHole, isEdible).
- **Action**: **Copy this table exactly**. It is pure data and engine-agnostic.
- Ensure your `PropItem` constructor in Love2D reads from this table to set the `isHole` and collider values correctly.

### 6. Specific Prop Behaviors
- **Holes**: In Love2D, implement "Edges". If a player's center point is within a Hole's bounding box, trigger the fall logic.
- **Slime Sliding (Tile-Based)**:
    Slime is **not** a prop — it is detected by reading tile IDs from the tilemap. Tiles `89` through `97` are slime.
    - **Detection**: Each frame, read the tile under the player from `tileMapData` and check if it's a slime ID.
    - **State Machine**: Implement an `isSliding` flag in your Player class that overrides WASD/Joystick input.
    - **Love2D Implementation**:
        ```lua
        -- 1. Define slime tile IDs
        local SLIME_TILE_IDS = {}
        for i = 89, 97 do SLIME_TILE_IDS[i] = true end

        local TILE_SIZE = 16

        -- 2. Get the tile ID under any pixel position
        function getTileAt(tileData, px, py)
            local col = math.floor(px / TILE_SIZE) + 1
            local row = math.floor(py / TILE_SIZE) + 1
            if tileData[row] then return tileData[row][col] end
            return nil
        end

        -- 3. Check for slime every frame (call in love.update)
        function Player:checkSlimeTile(tileData)
            if self.isSliding or self.isDashing then return end

            local tileID = getTileAt(tileData, self.x, self.y)
            if tileID and SLIME_TILE_IDS[tileID] then
                if self.hasPlunger then return end  -- immune
                self:startSliding(self.direction)
            end
        end

        -- 4. Sliding update loop
        function Player:updateSliding(tileData, world)
            if not self.isSliding then return end

            local dx, dy = 0, 0
            if     self.slideDir == "left"  then dx = -self.slideSpeed
            elseif self.slideDir == "right" then dx =  self.slideSpeed
            elseif self.slideDir == "up"    then dy = -self.slideSpeed
            elseif self.slideDir == "down"  then dy =  self.slideSpeed
            end

            local goalX, goalY = self.x + dx, self.y + dy
            local actualX, actualY, cols, len = world:move(
                self, goalX, goalY, self.collisionFilter
            )
            self.x, self.y = actualX, actualY

            -- Stop if hitting a solid or leaving slime
            local tileID = getTileAt(tileData, actualX, actualY)
            local onSlime = tileID and SLIME_TILE_IDS[tileID]
            local hitWall = (len > 0)
            
            if hitWall or not onSlime then
                self:endSliding(hitWall)
            end
        end

        -- 5. Sliding State Re-establishment (Crucial for Porting)
        function Player:endSliding(hitWall)
            self.isSliding = false
            self.slideDir = nil
            self.direction = "idle"  -- Ensures player resets correctly
            
            -- Prevent auto-re-slide if pinned to a wall while on slime
            if hitWall then
                self.slideHitWall = true
            end
            
            -- Important: Trigger exit animations based on last slide direction here!
            -- Example: self.animation:gotoState('slideExitRight') or self:idle() if tiny
        end
        ```
    - **Handling `slideHitWall`**: Your movement logic must explicitly reset `self.slideHitWall = false` when the player presses a directional key, ensuring they can escape the pinned state.
    - **Key difference vs. old system**: No `PropItem.isSlime` checks needed. The tilemap is the single source of truth for slime detection.
