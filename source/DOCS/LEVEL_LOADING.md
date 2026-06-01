# Level Loading and Room Translation

This document describes in full technical detail the complete flow of how rooms are loaded from LDtk-exported data and how the game transitions between them.

---

## 1. Full structure of `levelsLDTK`

`levelsLDTK` is a global Lua array defined in `source/assets/data/levels.lua`. Each entry represents a room in the world. The data is exported from LDtk and split into two files that are imported in order:

```lua
-- source/assets/data/levels.lua
levelsLDTK = {}
import 'assets/data/levels_floor4'
import 'assets/data/levels_floor3'
```

Each array entry has the following complete structure:

```lua
table.insert(levelsLDTK, {
  -- Room name as it appears in LDtk (string)
  identifier = "Room_2",

  -- Unique UUID of the room in LDtk (string). Used for re-matching if array order changes.
  uniqueIdentifer = "bab17c70-ac70-11f0-997a-85b3d3c5d229",

  -- Array of neighboring rooms. Each entry has:
  --   levelIid (string): uniqueIdentifer of the neighboring room
  --   dir (string): LDtk direction ("n","s","e","w","ne","nw","se","sw","<",">")
  neighbourLevels = {
    { levelIid = "abdd36b0-ac70-11f0-998c-673887a050e6", dir = "<" },
    { levelIid = "69eb2d80-ac70-11f0-989f-95306126bd74", dir = "w" },
    { levelIid = "bf654080-ac70-11f0-997a-e578ba2da2ac", dir = "e" },
    { levelIid = "a9a25e80-48b0-11f1-b2c1-f5dd8f6d463a", dir = "ne" },
    { levelIid = "cb0db7f0-ac70-11f0-997a-b9923cff9cbf", dir = "sw" },
    { levelIid = "cf8f2160-ac70-11f0-997a-c71a3a3308ed", dir = "s" },
    { levelIid = "d8b90440-ac70-11f0-997a-77d867841568", dir = "se" },
  },

  customFields = {
    shadow          = false,      -- boolean: whether the room has darkness
    light           = 0,          -- number: light radius when shadow=true (px)
    visited         = false,      -- boolean: whether the player has visited this room (mutated at runtime)
    comic_name      = nil,        -- string|nil: name of the comic/cutscene to play
    comic_wasPlayed = false,      -- boolean: whether the cutscene has already been played (mutated at runtime)
    level           = 4,          -- number: world level/floor (1, 2, 3, 4...)
    roomNumber      = 2,          -- number: room number within the level (0-99)
    tile            = 2,          -- number: index into tileMapData[] for loading IntGrid collision
    DoorsConnection = {           -- array of strings: allowed connections (permission system)
      "Down",                     -- possible values: "Up","Down","Left","Right","Upper","Lower"
      "Right",
    },
    play            = nil,        -- string|nil: when to play the comic ("Enter" = on room entry)
    hasForeground   = true,       -- boolean: whether a separate foreground sprite exists
  },

  -- Room entities, grouped by type (string -> array)
  entities = {
    Doors = {
      {
        id  = "Doors",
        iid = "b3283eb0-ac70-11f0-8539-f3c8ed5b1669",   -- string: unique instance ID
        x   = 200,     -- number: position in pixels
        y   = 236,
        width  = 48,   -- number: hitbox size
        height = 8,
        customFields = {
          NeedsKey      = false,   -- boolean: whether a key is required
          DoorsConnection = "Down",-- string: direction of this door
          KeyNumber     = nil,     -- number|nil: which key is required
        },
      },
    },
    Triggers = {
      {
        id  = "Triggers",
        iid = "04803a80-ac70-11f0-ae64-7fad2120052d",
        x = 156, y = 116, width = 40, height = 40,
        customFields = {
          script            = "giftFor100",  -- string: dialog/script key
          usedTrigger       = false,         -- boolean: whether already activated (mutated at runtime)
          type              = "Search",      -- string: type ("Search","Story")
          mapPercent        = 0,             -- number: map percentage required to unlock
          conditionalScripts = {},           -- array: conditional scripts "state:script"
        },
      },
    },
    Brocorat = {
      {
        id  = "Brocorat",
        iid = "...",
        x = 100, y = 120, width = 32, height = 32,
        customFields = {
          speed = 1,      -- number: enemy speed
          dead  = false,  -- boolean: whether already defeated (mutated at runtime)
        },
      },
    },
    CrewMember = {
      {
        id  = "CrewMember",
        iid = "...",
        x = 80, y = 100, width = 32, height = 32,
        customFields = {
          speed   = 1,        -- number
          crewID  = "CM001",  -- string: unique crew member identifier
          isTaken = false,    -- boolean: whether already rescued (mutated at runtime)
        },
      },
    },
    NPC = {
      {
        id  = "NPC",
        iid = "...",
        x = 200, y = 150, width = 32, height = 32,
        customFields = {
          type       = "computer",  -- string: NPC visual type
          sourceFeed = 0,           -- number: dialog index
          hasGranted = false,       -- boolean: whether the NPC has already given its reward (mutated at runtime)
        },
      },
    },
    -- Prop entities (Box, PneumaticTube, Tube, etc.):
    Box = {
      {
        id  = "Box",
        iid = "0ee36e70-48b0-11f1-b67e-0304cf2370db",
        x = 84, y = 60, width = 32, height = 32,
        customFields = {
          type       = "box",   -- string: prop visual type
          nocollider = false,   -- boolean: no physical collision
          destroyed  = false,   -- boolean: whether destroyed (mutated at runtime)
        },
      },
    },
    -- Item entities (collectible objects):
    ItemGift = {
      {
        id  = "ItemGift",
        iid = "ab0e6080-d380-11f0-88fd-23cdcf2dde52",
        x = 196, y = 140, width = 32, height = 32,
        customFields = {
          type   = "itemGift",          -- string: item type
          grants = "hasDWatch:true",    -- string: what it grants when collected ("key:value,key:value")
          isItem = true,                -- boolean: marks this entity as a collectible item
        },
      },
    },
  },
})
```

### Fields mutated at runtime

These fields change while the game is running and are the only ones persisted by the save system:

| Field | Entity | Description |
|-------|---------|-------------|
| `customFields.visited` | room | The room was visited |
| `customFields.comic_wasPlayed` | room | The cutscene was played |
| `customFields.dead` | Brocorat, Bosscolli | The enemy was defeated |
| `customFields.destroyed` | Props (Box, etc.) | The prop was destroyed |
| `customFields.isTaken` | CrewMember | The crew member was rescued |
| `customFields.usedTrigger` | Triggers | The trigger was activated |
| `customFields.collected` | Items with `isItem=true` | The item was collected |
| `customFields.hasGranted` | NPC | The NPC already granted its reward |
| `entity.x`, `entity.y` | Brocorat, Bosscolli | Enemy's final position when it died |

---

## 2. Hardcoded ranges in `Floors.lua`

`source/scenes/Floors.lua` generates a scene class (`FloorXXX`) for each valid room number using fixed ranges. These ranges are NOT derived from `levelsLDTK`; they are defined literally in the code:

```lua
local floorRanges = {
  { start = 166, stop = 180 },
  { start = 231, stop = 274 },
  { start = 316, stop = 330 },
  { start = 401, stop = 415 },
  { start = 481, stop = 481 },  -- single room
}
```

The loop generates one class for each `i` in each range:

```lua
for _, range in ipairs(floorRanges) do
  for i = range.start, range.stop do
    local className = "Floor" .. i   -- "Floor166", "Floor167", ..., "Floor415"
    _G[className] = {}
    class(className).extends(MazeScene)

    _G[className].init = function(self)
      local level = math.floor(i / 100)  -- extracts the level: 401 -> 4
      local room  = i % 100              -- extracts the room:  401 -> 1
      self:setFloor(level, room)
      _G[className].super.init(self)
      PlayerData.saveLevel = i           -- stores the full RoomID
    end

    _G[className].exit = function(self)
      _G[className].super.exit(self)
    end
  end
end
```

**Important**: Adding a new room in the LDtk editor does NOT automatically register it in the game. You must add its number to the appropriate range (or create a new range) in `Floors.lua`.

---

## 3. RoomID = level * 100 + room formula

The unique numeric identifier for each room is calculated as:

```
RoomID = level * 100 + roomNumber
```

Where:
- `level` is `customFields.level` (integer, typically 1–5)
- `roomNumber` is `customFields.roomNumber` (integer, 0–99)

Examples:

| level | roomNumber | RoomID | Generated class |
|-------|-----------|--------|----------------|
| 1 | 66 | 166 | Floor166 |
| 2 | 31 | 231 | Floor231 |
| 3 | 16 | 316 | Floor316 |
| 4 | 1 | 401 | Floor401 |
| 4 | 15 | 415 | Floor415 |
| 4 | 81 | 481 | Floor481 |

The inverse operation (extracting level and room from a RoomID):
```lua
local level = math.floor(roomID / 100)  -- 408 -> 4
local room  = roomID % 100              -- 408 -> 8
```

---

## 4. `setFloor()` — search algorithm in `levelsLDTK`

`MazeScene:setFloor(levelNumber, roomNumber)` locates the room in the `levelsLDTK` array and stores its index in the local variable `room` (the numeric pointer used by all other scene methods):

```lua
-- source/scenes/MazeScene.lua
local room = nil  -- index into levelsLDTK[]

function scene:setFloor(levelNumber, roomNumber)
  for i, levelData in ipairs(levelsLDTK) do
    if levelData.customFields.level     == levelNumber and
       levelData.customFields.roomNumber == roomNumber then
      room = i   -- stores the index, NOT the table
      return
    end
  end
  print("Warning: Level " .. levelNumber .. ", Room " .. roomNumber .. " not found")
end
```

**Notes**:
- The search is O(n) linear across the entire `levelsLDTK` array.
- `room` is the module-level variable used by `enter()`, `exit()`, and other methods. It is not the room data itself, but its position in the array.
- If the room does not exist, `room` remains `nil` and a warning is printed to the console; no error is thrown, but subsequent calls to `levelsLDTK[room]` will fail silently.

---

## 5. `MazeScene:enter()` — complete step-by-step flow

`enter()` is the visual constructor for the room. It executes when the Noble Engine transition makes this scene visible. The exact order of operations is:

### 5.1 Flag initialization

```lua
PlayerData.isGaming    = false
PlayerData.isEquiping  = false
```

A bounce animation `Sequence` is created (cosmetic, non-blocking).

### 5.2 Reading room metadata

```lua
PlayerData.room         = levelsLDTK[room].customFields.roomNumber
PlayerData.isInDarkness = levelsLDTK[room].customFields.shadow
PlayerData.floor        = room   -- numeric index into levelsLDTK
PlayerData.actualLevel  = levelsLDTK[room].customFields.level
PlayerData.actualRoom   = levelsLDTK[room].customFields.roomNumber
PlayerData.actualTilemap = levelsLDTK[room].customFields.tile
levelsLDTK[room].customFields.visited = true  -- marks as visited
```

### 5.3 Background (static image)

The background PNG is loaded from:
```
assets/images/rooms/floor{level}/{identifier}
```
Example: `assets/images/rooms/floor4/Room_2`

A non-animated sprite is created, zIndex = 1, centered at (200, 120).

### 5.4 Foreground (optional overlay)

If `customFields.hasForeground == true`, the following is loaded:
```
assets/images/rooms/floor{level}/foreground_{roomNumber}
```
Example: `assets/images/rooms/floor4/foreground_2`

Added as a sprite with `ZIndex.foreground` (value 300).

### 5.5 In-game equipment menu

```lua
inGameEquip = inGameMenu()
```

### 5.6 Tile colliders

```lua
tileColliders = CreateTileColliders(tileMapData[PlayerData.actualTilemap])
```

Generates `Box` sprites (wall colliders) from the IntGrid matrix. See section 10.

### 5.7 Horizontal doors

```lua
CreateDoorsFromLDTK(currentRoom)
```

Creates `Door` sprites for each `Doors` entity in the room. See section 6.

### 5.8 Portal doors

```lua
CreatePortalDoorsFromLDTK(currentRoom)
```

Similar to `CreateDoorsFromLDTK` but for special portal doors.

### 5.9 Prop spawning

Iterates `levelsLDTK[room].entities` looking for entities with `customFields.destroyed ~= nil` or `customFields.nocollider ~= nil`:

- If `destroyed == false` or `destroyed == nil` -> `PropItem(x, y, cf.type, ZIndex.props, cf.nocollider, cf.destroyed, id)`
- If `destroyed == true` -> `PropItem(x, y, "debris", ZIndex.props, true, cf.destroyed, id)` (debris variant)

**Skip condition**: Only skipped if `destroyed == true`.

### 5.10 Item spawning

Iterates `levelsLDTK[room].entities` looking for `customFields.isItem == true`. For each one, evaluates whether it should be generated (`shouldGenerate`):

| Item type | Condition to generate |
|-------------|------------------------|
| `keycard` | `not PlayerData.keys[keyNum]` — player does not have that key |
| Has a `grants` field | Parses `"key:value,key:value"` and generates only if NONE of the keys are already in `PlayerData.items[key]` or `PlayerData.skills[key]` |
| Other known items (lamp, radio, notes, boots, plunger) | `PlayerData.items[fieldName] == false` |

If `shouldGenerate == true`:
```lua
Items(x, y, itemType, keyNumber, cf.grants)
```

**Skip condition**: The item is already owned by the player.

### 5.11 Player and HUD spawning

```lua
player   = Player(spawnPoint.x, spawnPoint.y, PlayerData.speed, ZIndex.player)
uiScreen = playerHud(player)
PlayerData.x         = player.x
PlayerData.y         = player.y
PlayerData.direction = 'idle'
```

`spawnPoint` comes from `PlayerData.playerSpawn` (set by the door system when exiting the previous room).

### 5.12 Darkness FX

If `customFields.shadow == true`:
```lua
local lightLevel = cf.light or 0
shadow = FXshadow(player, 70, lightLevel, ZIndex.fx)
PlayerData.isInDarkness = true
```
Otherwise `PlayerData.isInDarkness = false`.

### 5.13 Entry cutscene

If `customFields.comic_name` exists:
1. Looks up `comicData = comics[cf.comic_name]`
2. If `cf.play == "Enter"` and `cf.comic_wasPlayed == false`:
   - `PlayerData.isCutscene = true`
   - `PlayerData.isGaming   = false`
3. Calls `Panels.startCutscene(comicData, callback)`. On completion: `isGaming = true`, `isCutscene = false`, `comic_wasPlayed = true`.

**Skip condition**: `comic_wasPlayed == true` or `play ~= "Enter"`.

### 5.14 Enemy spawning

Iterates entities of type `"Brocorat"` or `"Bosscolli"`:

- If `dead == false`:
  - `"Brocorat"` -> `Brocorat(x, y, speed, ZIndex.enemy, player, id)`
  - `"Bosscolli"` -> `bosscolli(x, y, speed, ZIndex.enemy, player, id)`
- If `dead == true` -> `PropItem(x, y, "blood2", ZIndex.props, true)` (blood stain)

**Skip condition**: `dead == true`.

### 5.15 CrewMember spawning

Iterates `CrewMember` entities:
- If `isTaken == false` -> `CrewMember(x, y, speed, ZIndex.enemy, player, crewIid, room, crewId)`

**Skip condition**: `isTaken == true`.

### 5.16 NPC spawning

Iterates `NPC` entities (no skip condition — always created):
```lua
NPC(npcData.x, npcData.y, cf.type or "computer", npcData.iid, room, cf.sourceFeed or 0)
```

### 5.17 Trigger spawning

Iterates `Triggers` entities:
- If `usedTrigger == false` -> `Trigger(x, y, width, height, script, triggerData.iid, room, type)`

**Skip condition**: `usedTrigger == true`.

---

## 6. `CreateDoorsFromLDTK` — reading doors

Defined in `source/entities/props/door.lua`.

### Complete algorithm

```lua
function CreateDoorsFromLDTK(currentRoom)
  -- 1. Get the room's Doors entities
  local doorEntities = currentRoom.entities and currentRoom.entities.Doors
  if not doorEntities or #doorEntities == 0 then return end

  -- 2. Build a neighbor map by LDtk direction
  local neighborsByDir = {}
  for _, neighbor in ipairs(currentRoom.neighbourLevels) do
    if neighbor.dir then
      neighborsByDir[neighbor.dir] = neighbor
    end
  end

  local currentLevel      = currentRoom.customFields.level
  local currentRoomNumber = currentRoom.customFields.roomNumber

  -- Translation table: door name -> LDtk direction
  local doorDirectionMap = {
    top   = "n",    -- North
    down  = "s",    -- South
    right = "e",    -- East
    left  = "w",    -- West
    upper = ">",    -- Stairs up
    lower = "<",    -- Stairs down
  }

  -- 3. Process each door entity
  for i, doorEntity in ipairs(doorEntities) do
    local doorConnection = doorEntity.customFields.DoorsConnection
    -- doorConnection is a string like "Down", "Right", "Left"

    local ldtkDir = doorDirectionMap[doorConnection:lower()]
    local neighbor = neighborsByDir[ldtkDir]

    if neighbor then
      local direction = ConvertLDTKDirection(ldtkDir)
      local needsKey  = doorEntity.customFields.NeedsKey or false
      local keyNumber = doorEntity.customFields.KeyNumber
      local open      = needsKey and "closed" or "open"

      -- Stairs (> or <): calculated with CalculateLeadsTo without neighborRoom
      if ldtkDir == ">" or ldtkDir == "<" then
        local leadsTo = CalculateLeadsTo(currentLevel, currentRoomNumber, ldtkDir, nil)
        -- Door(direction, open, leadsTo, ZIndex.props) -- currently commented out

      -- Cardinal doors: require finding the neighboring room by iid
      else
        local neighborRoom = FindRoomByIid(neighbor.levelIid)
        if neighborRoom then
          local leadsTo = CalculateLeadsTo(currentLevel, currentRoomNumber, ldtkDir, neighborRoom)
          Door(direction, open, leadsTo, ZIndex.props, keyNumber,
               doorEntity.x, doorEntity.y, doorEntity.width, doorEntity.height)
        end
      end
    end
  end
end
```

---

## 7. `ConvertLDTKDirection` — full mapping table

Converts the internal LDtk direction to the direction name used by the game's door system:

| LDtk direction | Result | Meaning |
|----------------|-----------|-----------|
| `">"` | `"down"` | Stairs going up (visually at the bottom of the screen) |
| `"<"` | `"top"` | Stairs going down (visually at the top of the screen) |
| `"n"` | `"top"` | Door heading north |
| `"s"` | `"down"` | Door heading south |
| `"e"` | `"right"` | Door heading east |
| `"w"` | `"left"` | Door heading west |
| `"o"` | `"left"` | Alternate alias for west (treated the same as `"w"`) |
| Any other | original value | Passes through unchanged |

Note: Vertical stairs (`">"`, `"<"`) use the screen Y axis in a counterintuitive way: `">"` (moving up a floor) is shown at the bottom of the screen because the character visually "falls" to the lower floor.

---

## 8. `CalculateLeadsTo` — exact destination formula

Defined in `source/entities/props/door.lua`. Calculates the destination RoomID based on direction:

```lua
function CalculateLeadsTo(currentLevel, currentRoomNumber, direction, neighborRoom)
  local fullCurrentRoom = currentLevel * 100 + currentRoomNumber

  if direction == ">" then
    -- Stairs up: go up one level, same room number
    -- Example: level 3, room 23 -> level 4, room 23 -> 423
    return (currentLevel + 1) * 100 + currentRoomNumber

  elseif direction == "<" then
    -- Stairs down: go down one level, same room number
    -- Example: level 4, room 23 -> level 3, room 23 -> 323
    return (currentLevel - 1) * 100 + currentRoomNumber

  else
    -- Cardinal door: uses the level and room of the neighbor found by iid
    if neighborRoom then
      local neighborLevel   = neighborRoom.customFields.level   or 1
      local neighborRoomNum = neighborRoom.customFields.roomNumber or 0
      return neighborLevel * 100 + neighborRoomNum
    else
      return fullCurrentRoom  -- fallback: same room
    end
  end
end
```

Examples:
- Room 423, stairs `">"` -> `(4+1)*100 + 23 = 523`
- Room 423, stairs `"<"` -> `(4-1)*100 + 23 = 323`
- Room 402, door `"e"` toward neighbor (level=4, roomNumber=3) -> `4*100 + 3 = 403`

---

## 9. `roomsByIid` — construction and usage

### Construction in `main.lua`

At game startup, after importing `levels.lua`, a hash table is built for O(1) lookups:

```lua
-- source/main.lua
roomsByIid = {}
if levelsLDTK then
  for _, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer then
      roomsByIid[room.uniqueIdentifer] = room  -- key: UUID string, value: room table
    end
  end
end
```

### Usage in `FindRoomByIid`

Defined in `source/entities/props/door.lua`:

```lua
function FindRoomByIid(iid)
  if not iid then return nil end

  -- O(1) lookup using the hash
  if roomsByIid and roomsByIid[iid] then
    return roomsByIid[iid]
  end

  -- O(n) fallback in case the hash is not available
  for i, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer == iid then
      return room
    end
  end

  return nil
end
```

`roomsByIid` is used in:
- `CreateDoorsFromLDTK`: to resolve the destination room for each cardinal door
- `GetLowerRoom` / `GetUpperRoom`: to find the vertical neighbor room by iid

---

## 10. `CreateTileColliders` — segment merge algorithm

Defined in `source/utilities/Utilities.lua`. Converts the 2D IntGrid matrix into collidable `Box` sprites, minimizing the number of sprites by merging segments.

### IntGrid values (`Config.Tiles.IntGrid`)

| Value | Name | Walkable? |
|-------|--------|-------------|
| 1 | `wall` | No (generates collider) |
| 2 | `slime` | Yes (slippery floor) |
| 3 | `hole` | Yes (fall hole) |
| 4 | `floor` | Yes (normal floor) |
| 32 | `tinyHole` | Yes (hole for small form) |

The tile size is `Config.Tiles.size = 16` pixels.

### Two-phase algorithm

**Phase 1: Horizontal identification**

For each row `y`, scans left to right:
- If the tile is NOT walkable, extends the segment until a walkable tile or the edge is found.
- Stores segments as `{x = startX, w = segmentWidth, used = false}`.

**Phase 2: Vertical merging**

For each unused segment, tries to extend it downward by looking in subsequent rows for a segment with the same `x` and `w`. If found, marks it as `used` and increments the height `currentH`.

**Box creation**

When it can no longer extend vertically, creates the collider:
```lua
local px = (segment.x - 1) * TILE_SIZE   -- pixel position (0-based)
local py = (y - 1)         * TILE_SIZE
local pw = segment.w       * TILE_SIZE
local ph = currentH        * TILE_SIZE

local collider = Box(px, py, pw, ph)
table.insert(colliders, collider)
```

`Box` is a Playdate sprite with `setGroups(CollideGroups.wall)` (group 5) and a `collideRect` of the same size as the sprite.

Colliders are stored in `tileColliders` (a local variable of MazeScene). In `exit()`, all are removed:
```lua
for _, collider in ipairs(tileColliders) do
  collider:remove()
end
tileColliders = {}
```

---

## 11. Vertical navigation

### Connection architecture

Each room has two fields that control vertical navigation:

**`neighbourLevels`**: Defines which rooms are adjacent and in which direction. For vertical navigation:
- `dir = "<"` -> lower room (player falls)
- `dir = ">"` -> upper room (player climbs)

**`customFields.DoorsConnection`**: Array of strings that acts as a permission system. For the player to move vertically, the room must have `"Lower"` (to fall) or `"Upper"` (to climb) in this array.

Example of a room with bidirectional vertical connections:
```lua
customFields = {
  DoorsConnection = { "Upper", "Lower", "Top" }
}
neighbourLevels = {
  { levelIid = "...", dir = "<" },  -- room below
  { levelIid = "...", dir = ">" },  -- room above
}
```

### `CanMoveVertically(currentRoom, direction)`

```lua
function CanMoveVertically(currentRoom, direction)
  local doorsConnection = currentRoom.customFields.DoorsConnection or {}
  local directionMap = {
    ["<"] = "lower",  -- fall
    [">"] = "upper",  -- climb
  }
  local requiredConnection = directionMap[direction]

  for _, allowed in ipairs(doorsConnection) do
    if allowed:lower() == requiredConnection:lower() then
      return true
    end
  end
  return false
end
```

### `GetLowerRoom(currentRoomIndex)` — validation flow

1. Gets `currentRoom = levelsLDTK[currentRoomIndex]`
2. Calls `CanMoveVertically(currentRoom, "<")` — verifies that `"lower"` is in `DoorsConnection`. If not, returns `nil`.
3. Calls `FindNeighborByDirection(currentRoom, "<")` — searches `neighbourLevels` for an entry with `dir = "<"`. If none exists, returns `nil`.
4. Calls `FindRoomByIid(lowerNeighbor.levelIid)` — looks up the destination room in `roomsByIid`.
5. If the room exists: returns `level*100 + roomNumber, roomData`
6. Fallback if the room is not loaded: calculates `(currentLevel - 1) * 100 + currentRoomNum` and returns that number with `nil` as roomData.

### `GetUpperRoom(currentRoomIndex)`

Identical to `GetLowerRoom` but:
- Verifies `"upper"` in `DoorsConnection` (`dir = ">"`)
- Fallback calculates `(currentLevel + 1) * 100 + currentRoomNum`

### `RoomTranslate(roomNumber)`

Converts a numeric RoomID into the corresponding scene class:

```lua
function RoomTranslate(roomNumber)
  local floorClass = "Floor" .. roomNumber  -- "Floor308"
  return _G[floorClass]                     -- returns the FloorXXX class
end
```

The result is passed directly to `Noble.transition()`.

---

## 12. Notes for porting to Love2D

### Data (no changes needed)

The `levelsLDTK` structure is pure Lua and works in Love2D without modification. If JSON is used as the LDtk export format:

```lua
-- Load levels from JSON
local json = require("dkjson")
local content = love.filesystem.read("assets/data/levels.json")
levelsLDTK = json.decode(content)
```

Verify that the parser preserves entity `iid` fields — some parsers discard them.

### `roomsByIid` index

Build the hash at startup in exactly the same way. No API changes needed.

### Scene classes (`Floors.lua`)

Love2D has no Noble Engine. Replace the class system with a custom scene manager. The `setFloor` logic and hardcoded ranges can remain the same.

```lua
-- Love2D equivalent of the transition system
function RoomTranslate(roomNumber)
  return "Floor" .. roomNumber  -- returns the name as a string
end

function SceneManager:goToRoom(roomNumber)
  local roomName = RoomTranslate(roomNumber)
  self:transition(roomName)
end
```

### `CreateTileColliders`

The segment merge algorithm is platform-independent. Only the collider creation changes: instead of `Box` (a Playdate sprite), use Love2D's physics library (`love.physics`) or a collision detection library such as `bump.lua`.

### `playdate.datastore` -> `love.filesystem`

See document SAVE_SYSTEM.md.

### `Noble.transition` -> custom scene manager

Playdate uses imagetable transitions for fall/climb animations. In Love2D, implement with shaders or spritesheets using `love.graphics.draw`.

### Vertical navigation

The functions `GetLowerRoom`, `GetUpperRoom`, `CanMoveVertically`, `FindNeighborByDirection`, and `FindRoomByIid` are fully portable without modification: they use no Playdate APIs.
