# Level Loading & Room Translation

This document explains the technical flow of how rooms are loaded from data and how the game transitions between them.

---

## 🗺️ Data Source: `levels.lua`
The game uses a large table called `levelsLDTK` (exported from LDtk) as its world database. Each entry in this table contains:
- **`identifier`**: The room name (e.g., "Room_8").
- **`customFields`**: Critical metadata like `level`, `roomNumber`, `shadow` (darkness), and `tile` (tilemap ID).
- **`entities`**: A list of all objects to spawn (Doors, Props, Enemies, etc.) with their coordinates and custom fields.
- **`neighbourLevels`**: Structural data used to create doors and walls.

---

## 🔢 Room Numbering & Translation

The game uses a "Full Room Number" system to identify unique locations:
**`RoomNumber = (Level * 100) + InternalRoomID`**
*Example: Level 4, Room 8 becomes Room 408.*

### `RoomTranslate(roomNumber)`
Located in `utilities/Utilities.lua`, this function is the "bridge" between numeric IDs and the scene classes defined in the game:
```lua
function RoomTranslate(roomNumber)
    local floorClass = "Floor" .. roomNumber
    return _G[floorClass]
end
```
It looks up the string `"Floor408"` in the global Lua table `_G` and returns the class, which is then used by `Noble.transition`.

---

## 🏗️ The `MazeScene` Loading Flow

When a transition occurs, `MazeScene` goes through a specific lifecycle to build the room:

### 1. Finding the Room (`setFloor`)
Before Entering, the game searches `levelsLDTK` for the entry matching the desired `level` and `roomNumber` to get its index in the table.

### 2. Room Setup (`enter`)
- **Metadata**: Sets `PlayerData.isInDarkness` and `PlayerData.actualTilemap` based on room fields.
- **Environment**: Renders the `tilemap` and creates the `FXshadow` if the room is dark.
- **Walls & Doors**: Calls `CreateTileColliders` (for walls) and `CreateDoorsFromLDTK`. Walls are automatically generated from non-walkable tiles in the tilemap.

### 3. Entity Spawning
The scene iterates through the room's `entities` table:
- **Props**: Spawns `PropItem` instances, checking if they were previously `destroyed`.
- **Items**: Spawns `Items` (pickups) only if the player doesn't already have them. For `itemgift` and `notes`, it checks the `grants` field to see if the player owns the specific items or skills listed.
- **Enemies**: Spawns `Brocorat`, `Bosscolli`, or `CrewMember` based on their `dead` or `isTaken` status.

---

## 🔄 Persistence
State changes are saved back into the `levelsLDTK` table (or mirrored in `PlayerData`):
- When an enemy is killed or a prop is broken, the `customFields` in the active `levelsLDTK` entry are updated.
- `MazeScene:finish()` calls `SaveSystem.save()`, ensuring these changes persist across game restarts.

> [!TIP]
> The dynamic wall system in `Utilities.lua` is what allows rooms to feel connected; it hides the 12px wall sprites only where a neighbor is detected in LDtk.
