# Save System

The persistence layer, implemented in `source/utilities/SaveSystem.lua`. Version **`3.0-PROCGEN`**.

> The game is a procedural roguelike: there is no fixed map to patch. The save stores the player's meta-progression plus the **active run graph**. See [PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md) for the run model and [RunState](PROCEDURAL_GENERATION.md#13-runstate-active-run--navigation) serialization.
>
> **History:** versions `2.0-LDTK` and earlier saved a per-`iid` `levelState` patched onto a fixed `levelsLDTK`. That model (and `getLevelState`/`restoreLevelState`) was removed when the game became procedural. Old saves are rejected by `load()`.

---

## 1. Structure of the save file

Stored in the Playdate datastore under the key `'gameState'`:

```lua
{
  version   = "3.0-PROCGEN",
  timestamp = playdate.getTime(),
  player    = PlayerData,            -- full meta snapshot (see below)
  run       = RunState.serialize(),  -- the active run graph (see below)
}
```

### `player` — meta-progression (persists across runs, wiped on delete)

The whole `PlayerData` blob, including the cross-run meta:

- `items`, `skills`, `keys`
- `CrewMemberData` (`amountTaken`, `idNumbers`)
- `sanityCounter` (madness count — drives difficulty and the room-repeat rule)
- `runCount` (runs started; NewGame=1, +1 per death, +1 per hole fall/tube rise)
- `seenComics` (story cutscenes already watched, keyed by `comic_name`)
- run-local player state (battery, sanity, health, position) so **Continue** resumes exactly where you left off

### `run` — the active run graph (`RunState.serialize()`)

```lua
{
  currentNodeId, startId, finalReserved,
  nodes = {
    [i] = {
      id,
      roomUid    = <template uniqueIdentifer>,  -- not the template itself
      edges      = { dir -> nodeId },
      doorCounts = { dir -> n },
      freeSides  = { dir -> true },
      content    = { ... },   -- per-run enemies/utilities/crew (plain data)
      cleared    = { ... },   -- runtime deltas (killed enemies, crew taken)
      portals    = { PortalID -> nodeId },  -- secret-room links
      isSecret   = bool,
    },
    -- ...
  },
}
```

Nodes reference their room **template by `uniqueIdentifer`**, re-linked against the live `levelsLDTK` on load. `content`/`cleared`/`edges`/`portals` are plain data and serialize directly.

---

## 2. `save()`

```lua
function SaveSystem.save()
  local saveData = {
    player    = PlayerData,
    run       = RunState.serialize(),
    timestamp = playdate.getTime(),
    version   = "3.0-PROCGEN",
  }
  return playdate.datastore.write(saveData, 'gameState', true) ~= false
end
```

**Called from:**
- `MazeScene:finish()` — when a room transition completes.
- `MazeScene:pause()` — system menu / sleep. **Also captures the player's live `x/y` into `playerSpawn` first**, so Continue resumes at the exact spot. (`finish()` does **not** capture position — it runs mid-transition and would clobber the spawn a door/portal/DanceScene just set.)
- `DanceScene` — on combat resolution.

---

## 3. `load()`

```lua
function SaveSystem.load()
  local saveData = playdate.datastore.read('gameState')
  if not saveData then return false end
  if saveData.version ~= "3.0-PROCGEN" then return false end   -- reject old saves

  PlayerData = saveData.player
  if not RunState.deserialize(saveData.run) then return false end
  return true
end
```

- Returns a single boolean (the old `(bool, saveLevel)` signature is gone).
- `RunState.deserialize` rebuilds the graph, re-links each node's `poolRoom` from `roomUid`, and stages `currentNodeId` as pending so the next `MazeScene:enter` lands on it. Fails (returns false) if a template `uniqueIdentifer` can't be found.

**Continue flow** (TitleScene): `SaveSystem.load()` → set `PlayerData.returningInPlace = true` → `Noble.transition(MazeScene, ...)`. The player resumes inside the saved node at the saved position. `hasSave` is still `playdate.file.exists('gameState.json')`.

---

## 4. `createOriginalBackup()`

```lua
function SaveSystem.createOriginalBackup()
  if not levelsLDTKOriginal then
    levelsLDTKOriginal = table.deepcopy(levelsLDTK)
  end
end
```

`levelsLDTK` is the **template** source. Although the procedural model keeps run state on nodes (not on templates), a pristine deep copy is still kept so `reset()`/`delete()` can restore a clean template table (Playdate cannot re-import Lua modules). Called once in `main.lua` before `load()`.

---

## 5. `reset()` vs `delete()`

```lua
function SaveSystem.reset()
  ResetPlayerData()
  RunState.clear()
  if levelsLDTKOriginal then levelsLDTK = table.deepcopy(levelsLDTKOriginal) end
end

function SaveSystem.delete()
  playdate.datastore.delete('gameState')
  ResetPlayerData()
  RunState.clear()
  if levelsLDTKOriginal then levelsLDTK = table.deepcopy(levelsLDTKOriginal) end
end
```

Both reset `PlayerData` (wiping meta: items/skills/crew/`sanityCounter`/`runCount`/`seenComics`), clear the active run, and restore the template table. `delete()` additionally removes the file from disk.

| | `reset()` | `delete()` |
|--|-----------|------------|
| Reset `PlayerData` (meta) | Yes | Yes |
| Clear `RunState` | Yes | Yes |
| Restore `levelsLDTK` templates | Yes | Yes |
| Delete file on disk | No | Yes |
| Use case | New Game start (then `startRun`) | Permanently wipe progress |

---

## 6. Version `"3.0-PROCGEN"`

`load()` rejects any save whose `version` is not `"3.0-PROCGEN"` (returns `false`, leaving `PlayerData`/`levelsLDTK` at startup defaults). The old file is **not** auto-deleted, so the Continue button may still appear (from `file.exists`) but do nothing — the player should use Delete once when migrating from an older build.

Bump this version string whenever the serialized shape of `PlayerData` or the run graph changes.

---

## 7. Notes for porting to Love2D

### 7.1 `playdate.datastore` → `love.filesystem` + JSON

```lua
local json = require("dkjson")

local function saveToFile(data)
  return love.filesystem.write("gameState.json", json.encode(data, { indent = true }))
end

local function readFromFile()
  if love.filesystem.getInfo("gameState.json") then
    return json.decode(love.filesystem.read("gameState.json"))
  end
end

local function deleteFile()
  return love.filesystem.remove("gameState.json")
end
```

```lua
-- conf.lua
function love.conf(t) t.identity = "DinoPirates" end
```

### 7.2 Serialize the run graph, not a per-iid levelState

The JSON model is exactly the `RunState.serialize()` node table from §1: each node stores `roomUid` (template `uniqueIdentifer`), `edges`, `content`, `cleared`, `portals`, `isSecret`. On load, build a `uniqueIdentifer → template` lookup over `levelsLDTK` and re-link each node's `poolRoom`. **Do not** try to port the old `getLevelState`/`restoreLevelState` — they no longer exist.

### 7.3 `table.deepcopy`

Playdate provides it; in Love2D implement a recursive deepcopy for `createOriginalBackup()` and `reset()`/`delete()`.

### 7.4 `timestamp`

`playdate.getTime()` → `os.date("*t")` (note `min`/`sec`, not `minute`/`second`).

### 7.5 Preserve `iid` / `uniqueIdentifer` in the LDtk parser

Node↔template re-linking depends on room `uniqueIdentifer`s, and per-run cleared state keys on entity `iid`s. If you use a Love2D LDtk loader, verify it preserves both; some parsers discard them when simplifying.

### 7.6 Auto-save points

Mirror the Playdate hooks: save on room-transition complete and on focus loss (`love.focus(false)`). Capture the player's live position before the focus-loss save (not on every transition) so Continue resumes in place — see §2.
