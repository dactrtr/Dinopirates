# Props & Items Documentation

This document details the environment objects (Props) and collectibles (Items) that populate the game world.

---

## 📦 Items (Pickups)
Items are specialized sprites that grant the player new abilities or resources upon contact.

### 1. Item Types
- **`keycard`**: Grants access to doors with matching `keyNumber`.
- **`lamp`**: Enables visibility in dark rooms and triggers sanity regen logic.
- **`radio` / `notes`**: Story-relevant items.
- **`bag`**: Required to capture CrewMembers.
- **`boots`**: Prevents falling into holes if battery is available.
- **`plunger`**: Prevents sliding on slime.
- **`itemgift`**: A generic delivery item that can grant any boolean flag in `PlayerData.items` (e.g., `hasPlunger:true`).

### 2. Dynamic Grants (LDtk)
Items like `itemgift` and `notes` use a `grants` custom field in LDtk to dynamically update `PlayerData`.
- **Format**: `"key1:value1,key2:value2"` (e.g., `"hasPlunger:true"` or `"canFlash:true"`).
- **Processing**:
    - `itemgift` updates the `PlayerData.items` table.
    - `notes` updates the `PlayerData.skills` table.
- **Conditional Rendering**: In `MazeScene.lua`, items with a `grants` field are only spawned if the player **does not** already possess the granted item/skill. This ensures objects disappear from the world permanently once collected.

### 3. Interaction Flow
In `collisions.lua`:
- Hitting an item usually calls `other:removeAll()`.
- It then calls a corresponding "grab" function on the player (e.g., `self:grabItemGift(other.grants)` or `self:grabNotes(other.grants)`).
- Grabbing an item typically updates a boolean in `PlayerData.items`, `PlayerData.skills`, or `PlayerData.keys`.

---

## 🖼️ PropItem System
Props represent the interactive furniture and environmental details.

### 1. Visuals and States
Props share a single image sheet (`props.png`) and use animation states like `chair`, `table`, `microwave`, `fridge`, etc.
- **Debris**: When a prop is destroyed, its state changes to `debris`.
- **Z-Index**: Props dynamically update their Z-Index based on their Y position (`update()` loop) unless they are "flat" (like blood or holes).

### 2. Environmental Hazards & Utility
- **Holes**: Defined by type (e.g., `holeCenter`, `holeLeft`).
    - **Falling**: In `collisions.lua`, hitting a hole without boots/battery triggers `self:fallBelow()`.
    - **Walking**: With boots, the player drains battery but remains in the room.
- **Minifiers**: Special pods used to change the player's size (`isTiny`) via a two-stage interaction:
    1.  **Locking**: Standing on a minifier displays "Press A". Pressing A centers the player and locks movement (`isGaming = false`).
    2.  **Transformation**: The player must manually rotate the physical **crank** to change size. Rotating counter-clockwise shrinks the player, while clockwise returns them to normal size. The `transformCycle` animation plays during this phase.
    3.  **Breakout**: If the player is locked in the minifier state (after pressing A), they can press **B** at any time to cancel the process, hide the HUD, and restore normal movement.
    4.  **Completion**: Once the target size is reached, movement is restored automatically and the player can walk away.
- **Slime (Tile 46)**: Environmental hazard that causes the player to slide.
    - **Sliding**: When stepped on, the player automatically moves in a straight line at a fixed speed (`slidingSpeed = 4`).
    - **Stopping**: The slide ends if the player hits a solid obstacle (wall, solid prop) or exits the slime patch.
    - **Antislip Protection**: If the player has **plunger**, they can walk over slime normally without consuming battery.
    - **Control**: Manual movement is disabled during a slide.

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
