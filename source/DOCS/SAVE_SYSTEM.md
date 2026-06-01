# Save System

This document describes in full technical detail the persistence layer of the game, implemented in `source/utilities/SaveSystem.lua`.

---

## 1. Complete structure of the save file

The save is stored in the Playdate datastore under the key `'gameState'`. The Lua table that is serialized has the following form:

```lua
{
  version   = "2.0-LDTK",           -- string: save format version
  timestamp = playdate.getTime(),    -- table: {year, month, day, hour, minute, second, millisecond}
  player    = PlayerData,            -- table: complete snapshot of the player state

  levelState = {                     -- indexed array, one entry per room in levelsLDTK
    [1] = {
      identifier      = "Room_2",    -- string: room name in LDtk
      uniqueIdentifer = "bab17c70-ac70-11f0-997a-85b3d3c5d229",  -- string: LDtk UUID
      visited         = false,       -- boolean: room visited by the player
      comic_wasPlayed = false,       -- boolean: entry cutscene already played

      entities = {                   -- table: entities grouped by type
        Brocorat = {
          { iid = "...", dead = false, speed = 1, x = 100, y = 120 },
          -- ...
        },
        Bosscolli = {
          { iid = "...", dead = false, speed = 1, x = 200, y = 150 },
        },
        -- Entities with a 'destroyed' field (props):
        Box = {
          { iid = "...", destroyed = false },
        },
        CrewMember = {
          { iid = "...", isTaken = false, crewID = "CM001" },
        },
        Triggers = {
          { iid = "...", usedTrigger = false, type = "Search", script = "myScript" },
        },
        -- Any entity with isItem = true:
        ItemGift = {
          { iid = "...", collected = false },
        },
        NPC = {
          { iid = "...", hasGranted = false },
        },
      },
    },
    [2] = { -- next room
      -- same structure
    },
    -- ...
  },
}
```

### Fields saved per entity type

| Type | Saved fields |
|------|-----------------|
| `Brocorat`, `Bosscolli` | `iid`, `dead`, `speed`, `x`, `y` |
| Props with `destroyed ~= nil` (Box, etc.) | `iid`, `destroyed` |
| `CrewMember` | `iid`, `isTaken`, `crewID` |
| Items with `isItem == true` | `iid`, `collected` |
| `Triggers` | `iid`, `usedTrigger`, `type`, `script` |
| `NPC` | `iid`, `hasGranted` |

Only the fields relevant to the entity type are saved. If an entity does not belong to any of the above categories (e.g. decorative entities with no mutable state), only its `iid` is saved.

---

## 2. `save()` — complete algorithm

```lua
function SaveSystem.save()
  local saveData = {
    player     = PlayerData,
    levelState = SaveSystem.getLevelState(),
    timestamp  = playdate.getTime(),
    version    = "2.0-LDTK"
  }

  local success = playdate.datastore.write(saveData, 'gameState', true)

  if success ~= false then
    return true
  else
    return false
  end
end
```

### `getLevelState()` — extracting level state

Iterates the full `levelsLDTK` array (in-memory array, not from disk):

```lua
function SaveSystem.getLevelState()
  local levelState = {}

  for i, level in ipairs(levelsLDTK) do
    levelState[i] = {
      identifier      = level.identifier,
      uniqueIdentifer = level.uniqueIdentifer,
      visited         = level.customFields.visited        or false,
      comic_wasPlayed = level.customFields.comic_wasPlayed or false,
      entities        = {}
    }

    if level.entities then
      for entityType, entitiesList in pairs(level.entities) do
        levelState[i].entities[entityType] = {}

        for _, entity in ipairs(entitiesList) do
          local entityState = { iid = entity.iid }

          if entity.customFields then
            -- Enemies
            if entityType == "Brocorat" or entityType == "Bosscolli" then
              entityState.dead  = entity.customFields.dead or false
              entityState.speed = entity.customFields.speed
              entityState.x     = entity.x
              entityState.y     = entity.y
            end

            -- Props
            if entity.customFields.destroyed ~= nil then
              entityState.destroyed = entity.customFields.destroyed
            end

            -- CrewMembers
            if entityType == "CrewMember" then
              entityState.isTaken = entity.customFields.isTaken or false
              entityState.crewID  = entity.customFields.crewID
            end

            -- Items
            if entity.customFields.isItem == true then
              entityState.collected = entity.customFields.collected or false
            end

            -- Triggers
            if entityType == "Triggers" then
              entityState.type        = entity.customFields.type
              entityState.script      = entity.customFields.script
              entityState.usedTrigger = entity.customFields.usedTrigger or false
            end

            -- NPCs
            if entityType == "NPC" then
              entityState.hasGranted = entity.customFields.hasGranted or false
            end
          end

          table.insert(levelState[i].entities[entityType], entityState)
        end
      end
    end
  end

  return levelState
end
```

**When `save()` is called**:
- `MazeScene:finish()` — when the transition to another room completes
- `MazeScene:pause()` — when the system menu is opened (e.g. device goes to sleep)

---

## 3. `load()` — how it restores state

```lua
function SaveSystem.load()
  local saveData = playdate.datastore.read('gameState')

  if saveData then
    if saveData.version == "2.0-LDTK" then
      PlayerData = saveData.player                        -- fully replaces PlayerData
      SaveSystem.restoreLevelState(saveData.levelState)   -- patches levelsLDTK in memory
      return true, saveData.player.saveLevel              -- second value = RoomID to resume from
    else
      printDebug("Old save format detected, migration needed")
      return false, nil
    end
  end

  printDebug("No save file found")
  return false, nil
end
```

### `restoreLevelState()` — patching algorithm over `levelsLDTK`

Walks through the `levelState` array from the save file and iterates `levelsLDTK` in parallel. For each saved level:

1. **Compares `uniqueIdentifer`**: If entry `i` from the save does not match entry `i` in `levelsLDTK` (the array order may change when rooms are added in LDtk), performs a linear search to find the correct entry by `uniqueIdentifer`.

2. **Restores room fields**:
   ```lua
   levelsLDTK[i].customFields.visited         = state.visited
   levelsLDTK[i].customFields.comic_wasPlayed = state.comic_wasPlayed
   ```

3. **Restores entities by `iid`**: For each entity type and each saved entity, searches for the corresponding entity in `levelsLDTK[i].entities[entityType]` by comparing `iid`. When found, writes the saved fields back into `currentEntity.customFields`:

   - `dead`, `speed`, `x`, `y` (enemies)
   - `destroyed` (props)
   - `isTaken` (CrewMember)
   - `usedTrigger`, `type`, `script` (Triggers)
   - `collected` (Items)
   - `hasGranted` (NPC)

**What it does NOT touch**: `restoreLevelState` never modifies `levelsLDTKOriginal`. The original backup remains intact after loading.

**Return value of `load()`**: The function returns two values:
- `true` + `saveData.player.saveLevel` (RoomID number) if loading was successful
- `false, nil` if there is no file or the version does not match

The caller uses `saveLevel` to call `Noble.transition(RoomTranslate(saveLevel))`.

---

## 4. `createOriginalBackup()` — why it exists and when it is called

```lua
function SaveSystem.createOriginalBackup()
  if not levelsLDTKOriginal then
    levelsLDTKOriginal = table.deepcopy(levelsLDTK)
  end
end
```

**Why it exists**: `levelsLDTK` is mutated at runtime (enemies marked as `dead`, props as `destroyed`, etc.). If the player wants to start a "New Game" or the game needs to reset, it cannot simply re-import the Lua files (Playdate does not allow reloading modules). The only way to recover the original state is to have a deep copy stored in memory before any mutations occur.

**When it is called**: Once only, in `main.lua`, before loading the existing save and before entering any room:

```lua
-- source/main.lua
SaveSystem.createOriginalBackup()   -- first: copies the pristine state
-- ...
-- (later) SaveSystem.load() can mutate levelsLDTK with saved data
```

The `if not levelsLDTKOriginal` guard ensures the backup is only created once. If it were called again after mutating `levelsLDTK`, the backup would contain corrupted data.

---

## 5. `reset()` vs `delete()`

### `reset()`

```lua
function SaveSystem.reset()
  ResetPlayerData()
  if levelsLDTKOriginal then
    levelsLDTK = table.deepcopy(levelsLDTKOriginal)
  end
end
```

- Calls `ResetPlayerData()` to restore `PlayerData` to its default values.
- Restores `levelsLDTK` to its pristine state by copying `levelsLDTKOriginal`.
- **Does NOT delete the save file on disk**. If the game restarts after a `reset()` without saving again, `load()` will recover the previous progress from the file on disk.

### `delete()`

```lua
function SaveSystem.delete()
  local success = playdate.datastore.delete('gameState')
  ResetPlayerData()
  if levelsLDTKOriginal then
    levelsLDTK = table.deepcopy(levelsLDTKOriginal)
  end
end
```

- Calls `playdate.datastore.delete('gameState')` to remove the file from disk. If the file does not exist, no error is thrown (returns `false` silently).
- Then performs exactly the same operations as `reset()`.
- This is the equivalent of "Delete data / New Game" from the menu.

### Key difference

| | `reset()` | `delete()` |
|--|-----------|------------|
| Restores `PlayerData` | Yes | Yes |
| Restores `levelsLDTK` | Yes | Yes |
| Deletes file on disk | No | Yes |
| Use case | Temporary reset in current session | Permanently delete player progress |

---

## 6. Version `"2.0-LDTK"` and compatibility

The save version is verified in `load()`:

```lua
if saveData.version == "2.0-LDTK" then
  -- normal load
else
  printDebug("Old save format detected, migration needed")
  return false, nil
end
```

**What happens with an incorrect version**:
- The function returns `false, nil`.
- `PlayerData` and `levelsLDTK` are **not modified** (they keep their startup values).
- The debug message appears in the console.
- The game continues with the default state (no progress loaded).
- The old file remains on disk; it is not deleted automatically.

**Why the version is `"2.0-LDTK"`**: The `-LDTK` suffix indicates that the format uses the LDtk-exported structure (with entity `iid`s and room `uniqueIdentifer`s) instead of the older format based on simple array indices. If the save structure changes in the future (e.g. adding new fields or reorganizing `levelState`), the version number must be incremented to invalidate incompatible saves.

---

## 7. Notes for porting to Love2D

### 7.1 `playdate.datastore` -> `love.filesystem`

Playdate serializes Lua tables automatically. Love2D requires a JSON library:

```lua
-- Using dkjson
local json = require("dkjson")

-- Equivalent of playdate.datastore.write(saveData, 'gameState', true)
local function saveToFile(data)
  local str     = json.encode(data, { indent = true })
  local success = love.filesystem.write("gameState.json", str)
  return success
end

-- Equivalent of playdate.datastore.read('gameState')
local function readFromFile()
  if love.filesystem.getInfo("gameState.json") then
    local str = love.filesystem.read("gameState.json")
    return json.decode(str)
  end
  return nil
end

-- Equivalent of playdate.datastore.delete('gameState')
local function deleteFile()
  return love.filesystem.remove("gameState.json")
end
```

Add to `conf.lua`:
```lua
function love.conf(t)
  t.identity = "DinoPirates"  -- user data folder (like the Playdate sandbox)
end
```

### 7.2 Multiple save slots

To support multiple profiles, use numbered filenames:
```lua
local function getSavePath(slot)
  return "gameState_" .. (slot or 1) .. ".json"
end
```

### 7.3 `timestamp` — `playdate.getTime()` -> `os.date`

`playdate.getTime()` returns `{year, month, day, hour, minute, second, millisecond}`. In Love2D use:

```lua
local timestamp = os.date("*t")
-- returns: {year, month, day, hour, min, sec, wday, yday, isdst}
-- note: the field is "min" instead of "minute"
```

### 7.4 `table.deepcopy` — manual implementation

Playdate CoreLibs provides `table.deepcopy`. In Love2D it must be implemented manually:

```lua
local function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for k, v in pairs(orig) do
      copy[deepcopy(k)] = deepcopy(v)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end
```

Use this function in the equivalent of `createOriginalBackup()` and in `reset()`/`delete()`.

### 7.5 Auto-save on room exit

Hook into the scene transition logic. In Love2D with `hump.gamestate` or a custom manager:

```lua
function RoomState:leave()
  SaveSystem.save()
end
```

Or directly in the transition function:
```lua
function goToRoom(roomNumber)
  SaveSystem.save()
  SceneManager:transition("Floor" .. roomNumber)
end
```

### 7.6 Version checking and migration

Keep the same pattern:
```lua
if saveData.version ~= "2.0-LDTK" then
  -- show "incompatible save" message or run migration
  return false, nil
end
```

### 7.7 Preserving `iid` fields in the LDtk parser

The entire entity restoration system depends on the `iid` (instance) and `uniqueIdentifer` (room) fields being present in the loaded data. If a Love2D LDtk parser is used (such as `ldtk.lua` or a custom loader), verify that it **preserves entity `iid`s** — some parsers discard them when simplifying the structure. If necessary, post-process the loaded JSON to extract and retain these fields.
