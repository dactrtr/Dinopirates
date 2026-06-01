# Doors and Keys

This document describes the complete door system: the `Door` class, coordinate mapping, the key system, construction from LDtk, and portability notes.

---

## `Door` Class

File: `entities/props/door.lua`

`Door` extends `NobleSprite`. It is the sprite that represents a door on screen and centralizes the room transition logic.

### Constructor

```lua
Door(direction, status, nextRoom, zIndex, keyNumber, x, y, width, height)
```

| Parameter | Type | Description |
|---|---|---|
| `direction` | string | `"top"`, `"down"`, `"left"`, `"right"` |
| `status` | string | `"open"` or `"closed"` |
| `nextRoom` | number | Destination room number (e.g. 220) |
| `zIndex` | number | Render layer — normally `ZIndex.props` (2) |
| `keyNumber` | number or nil | Required key number; `nil` if no key needed |
| `x`, `y` | number or nil | LDTK entity coordinates; if `nil`, falls back to `Config.Doors.positions` |
| `width`, `height` | number or nil | LDTK entity dimensions; if `nil`, calculated by direction |

Internally:
- `self.nextRoom` is resolved with `RoomTranslate(nextRoom)` to get the scene class (e.g. `Floor220`).
- `self:setGroups(3)` — collision group `props` (ID 3).
- The collision rect is assigned from `setRectValues(direction)` when no LDTK dimensions are provided.

### Collision Rectangles by Direction

```
right  → {0, 0, 16, 50}
left   → {0, 0, 14, 50}
down   → {0, 0, 50, 16}
top    → {0, 0, 50, 16}
```

### Default Sprite Size (without LDTK dimensions)

```
horizontal (top/down) → 56×10 px
vertical   (left/right) → 10×56 px
```

---

## `Config.Doors` — Positions and Spawn Coordinates

Defined in `assets/data/Config.lua`.

### `Config.Doors.positions` — Door Sprite Position on Screen

| Direction | x | y |
|---|---|---|
| `right` | 393 | 122 |
| `left` | 4 | 122 |
| `down` | 203 | 228 |
| `top` | 203 | 2 |

These coordinates are the fallback when the LDTK entity does not provide `x`/`y`.

### `Config.Doors.spawnCoords` — Player Spawn Position in Destination Room

| Exit direction | Spawn x | Spawn y |
|---|---|---|
| `top` | 196 | 196 |
| `down` | 196 | 32 |
| `right` | 32 | 116 |
| `left` | 364 | 116 |

The logic: if the player exits through the top (`top`), they spawn at the bottom of the new room (y=196); if they exit through the bottom (`down`), they spawn at the top (y=32), etc. The orthogonal axis preserves the player's actual coordinate.

---

## Key System

Doors can require a key to open.

### Data in LDTK

Each `Doors` entity in LDtk can have:
- `NeedsKey` (`bool`) — if `true`, the door is locked.
- `KeyNumber` (`int`) — number of the required key.

### Global Storage

Keys are stored in `PlayerData.keys`, a table indexed by number:

```lua
PlayerData.keys[1] = true   -- player has key #1
PlayerData.keys[2] = false  -- player does NOT have key #2
```

### Collision Flow (in `player/collisions.lua`)

1. The player collides with a `Door` (door's response: `"overlap"` — no-op).
2. `player/collisions.lua` detects the `Door` type.
3. If `door.status == "closed"`:
   - Checks `PlayerData.keys[door.keyNumber]`.
   - If `true` → allows the transition by calling `door:prevRoom()` + `door:goTo()`.
   - If `false` → shows the `"nokeys"` dialog and returns `'freeze'` to block player movement.
4. If `door.status == "open"` → direct transition.

> The `Door` class always returns `"overlap"` in `collisionResponse`. All actual key and transition logic lives in `player/collisions.lua`.

---

## `Door:prevRoom(direction, playerX, playerY)`

Configures player spawn in the destination room before the transition.

```lua
function Door:prevRoom(direction, playerX, playerY)
    PlayerData.lastRoom = direction
    local sc = Config.Doors.spawnCoords
    local spawnCoordinates = {
        top   = {x = playerX or sc.top.x,   y = sc.top.y  },
        down  = {x = playerX or sc.down.x,  y = sc.down.y },
        right = {x = sc.right.x, y = playerY or sc.right.y},
        left  = {x = sc.left.x,  y = playerY or sc.left.y },
    }
    PlayerData.playerSpawn.x = spawnCoordinates[direction].x
    PlayerData.playerSpawn.y = spawnCoordinates[direction].y
end
```

- For horizontal doors (`left`/`right`), `playerY` is preserved so the player appears at the same height.
- For vertical doors (`top`/`down`), `playerX` is preserved so they appear in the same column.
- `PlayerData.lastRoom` stores the entry direction so the destination scene knows where the player came from.

---

## `Door:goTo()`

Executes the scene transition.

```lua
function Door:goTo()
    Noble.transition(self.nextRoom, 1.5, Noble.Transition.Default)
end
```

- `self.nextRoom` is the scene class (e.g. `Floor220`), obtained in the constructor via `RoomTranslate(nextRoom)`.
- Fade duration: **1.5 seconds**.
- Transition: `Noble.Transition.Default`.

---

## `CreateDoorsFromLDTK(currentRoom)` — Step by Step

Global function defined in `entities/props/door.lua`, called from `MazeScene:enter()`.

**Step 1 — Initial Validation**
- If `currentRoom` is nil → return.
- If `currentRoom.entities.Doors` is empty → return.
- If `currentRoom.neighbourLevels` is nil → return.

**Step 2 — Build Neighbor Map by Direction**

```lua
local neighborsByDir = {}
for _, neighbor in ipairs(neighbourLevels) do
    neighborsByDir[neighbor.dir] = neighbor   -- key: "n", "s", "e", "w", ">", "<"
end
```

**Step 3 — Iterate `Doors` Entities**

For each entity in `currentRoom.entities.Doors`:

1. Read `doorEntity.customFields.DoorsConnection` (e.g. `"top"`, `"right"`, `"lower"`).
2. Convert to LDTK code with `doorDirectionMap`:
   ```lua
   top→"n", down→"s", right→"e", left→"w", upper→">", lower→"<"
   ```
3. Look up the neighbor with `neighborsByDir[ldtkDir]`.
4. If no neighbor → skip (no door is created).
5. Convert `ldtkDir` to internal direction with `ConvertLDTKDirection`.
6. Read `NeedsKey` and `KeyNumber` from the entity's customField.

**Step 4 — Create the Door (cardinal doors only)**

For cardinal directions (`n`, `s`, `e`, `w`):
- Call `FindRoomByIid(neighbor.levelIid)` to get the neighboring room.
- Calculate `leadsTo` with `CalculateLeadsTo`.
- `open = needsKey and "closed" or "open"`.
- Instantiate `Door(direction, open, leadsTo, ZIndex.props, keyNumber, doorEntity.x, doorEntity.y, doorEntity.width, doorEntity.height)`.

**Note on stairs (`>` and `<`):** The `Door` sprite creation is commented out in the code. Stairs are navigated exclusively by `fallBelow()` / `riseAbove()` on the player, which call `GetLowerRoom()` / `GetUpperRoom()`. No Door sprite exists for stairs.

---

## `ConvertLDTKDirection(dir)` — Full Table

| LDTK Input | Internal Output | Visual Meaning |
|---|---|---|
| `">"` | `"down"` | Staircase up (visually at the back of the screen) |
| `"<"` | `"top"` | Staircase down (visually at the top of the screen) |
| `"n"` | `"top"` | North door |
| `"s"` | `"down"` | South door |
| `"e"` | `"right"` | East door |
| `"w"` | `"left"` | West door |
| `"o"` | `"left"` | Alias for west |
| any other | unchanged | Returns the original value |

---

## `CalculateLeadsTo(currentLevel, currentRoomNumber, direction, neighborRoom)` — Formula

```lua
-- Staircase up: level+1, same room number
if direction == ">" then
    result = (currentLevel + 1) * 100 + currentRoomNumber

-- Staircase down: level-1, same room number
elseif direction == "<" then
    result = (currentLevel - 1) * 100 + currentRoomNumber

-- Cardinal door: uses level and roomNumber from the neighbor
else
    local neighborLevel  = neighborRoom.customFields.level or 1
    local neighborRoomNum = neighborRoom.customFields.roomNumber or 0
    result = neighborLevel * 100 + neighborRoomNum
end
```

Example: level 2, room 20 with staircase `">"` → `(2+1)*100 + 20 = 320`.

---

## `FindRoomByIid(iid)` — Hash vs. Linear Search

```lua
function FindRoomByIid(iid)
    -- 1. O(1) hash lookup
    if roomsByIid and roomsByIid[iid] then
        return roomsByIid[iid]
    end

    -- 2. Fallback: O(n) linear search through levelsLDTK
    for i, room in ipairs(levelsLDTK) do
        if room and room.uniqueIdentifer == iid then
            return room
        end
    end
    return nil
end
```

`roomsByIid` is built in `main.lua` at game startup:
```lua
roomsByIid = {}
for _, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer then
        roomsByIid[room.uniqueIdentifer] = room
    end
end
```

The linear search is the fallback for the unlikely case that the hash is unavailable.

---

## Notes for Porting to Love2D

### Doors as bump.lua Sensors

Replace the NobleSprite `Door` sprites with bump.lua sensor rectangles:

```lua
-- Add door as sensor
world:add({type="door", direction="top", leadsTo=220, keyNumber=nil},
           x, y, doorW, doorH)

-- Filter on the player
local function playerFilter(item, other)
    if other.type == "door" then return "cross" end
    return "slide"
end
```

### Room Transition

```lua
-- When overlap with a door is detected:
if col.other.type == "door" then
    local door = col.other
    if door.keyNumber and not PlayerData.keys[door.keyNumber] then
        showDialog("nokeys")
        return
    end
    -- Configure spawn
    PlayerData.lastRoom = door.direction
    local sc = Config.Doors.spawnCoords
    PlayerData.playerSpawn.x = sc[door.direction].x
    PlayerData.playerSpawn.y = sc[door.direction].y
    SceneManager:switchTo(RoomTranslate(door.leadsTo), "fade", 1.5)
end
```

### `PlayerData.keys` — Direct Transfer

The `PlayerData.keys` table is pure Lua and requires no changes for Love2D.

### `Config.Doors.spawnCoords` — Pure Data

The spawn coordinates have no Playdate dependencies and transfer without modification.
