# Doors & Keys Documentation

This document explains how the maze navigation works through doors and the security system using keys.

---

## 🚪 Door System

Doors in this game are more than just sprites; they handle the heavy lifting for level transitions.

### 1. Types & Directions
Doors are initialized based on their location in the room:
- **Directions**: `top`, `down`, `left`, `right`.
- **Stairs**: Special "doors" for vertical movement between floors (`upper` and `lower`).
- **Positions**: Positions and dimensions are dynamically loaded from LDtk entities (using coordinates, `width`, and `height`), with hardcoded fallbacks for standard cardinal directions.

### 2. Room Transitions
Transitions are handled via `Door:goTo()` and `Door:prevRoom(direction)`:
- **`prevRoom`**: Calculates where the player should spawn in the **next** room based on where they left the current one (e.g., exiting "top" spawns you at the "bottom" - Y=196 - of the next room). It also sets `PlayerData.lastRoom`.
- **Navigation**: Uses `Noble.transition` to move to the scene class identified by the room number (e.g. `Floor220`), which is looked up via `RoomTranslate`.

### 3. LDtk Loading
Doors are generated dynamically in `MazeScene.lua` via `CreateDoorsFromLDTK(currentRoom)`:
- It uses the LDtk `neighbourLevels` data to determine where each door leads.
- It converts LDTK cardinal letters (`n`, `s`, `e`, `w`) and stair symbols (`>`, `<`) into internal game directions.

---

## 🔐 Key System

The game features a locking mechanism that gates progress.

### 1. Locking Mechanisms
- A door can be initialized with a `keyNumber`.
- In `collisions.lua`, when a player hits a `closed` door:
    - It checks `PlayerData.keys[requiredKey]`.
    - If `true`, the door allows passage and transitions the player.
    - If `false`, it shows the `"nokeys"` dialog screen.

### 2. Global State
Keys are stored in `PlayerData.keys` as a map of indices (e.g., `{[1] = true}`). This ensures that keys collected on one floor or room are available throughout the game world.

> [!NOTE]
> Collision response for doors is actually handled in `player/collisions.lua`, which calls the transition logic directly if the door is open or the key is present.
