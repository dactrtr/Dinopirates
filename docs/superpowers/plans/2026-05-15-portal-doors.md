# Portal Doors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `PortalDoor` entity that teleports the player to any room in the map, with paired portal IDs and conditional entry validation, without touching the existing door system.

**Architecture:** Standalone `PortalDoor` class (no inheritance from `Door`) with its own `CreatePortalDoorsFromLDTK` loading function. A single new `elseif other:isa(PortalDoor)` block in `collisions.lua` handles player interaction. All condition evaluation reuses the same path + operator logic already in `Trigger`.

**Tech Stack:** Lua, Noble Engine (NobleSprite), Playdate SDK, LDtk level data in `levelsLDTK` global.

---

## Files

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `source/assets/data/Config.lua` | Add `Config.Portals` default collision size |
| Create | `source/entities/props/portal_door.lua` | `PortalDoor` class + `CreatePortalDoorsFromLDTK` |
| Modify | `source/scenes/MazeScene.lua` | Import + call `CreatePortalDoorsFromLDTK` |
| Modify | `source/entities/player/collisions.lua` | Add `elseif other:isa(PortalDoor)` block |
| Modify | `source/DOCS/DOORS_AND_KEYS.md` | Document the new portal system |

---

## Task 1: Add `Config.Portals`

**Files:**
- Modify: `source/assets/data/Config.lua`

The portal collision rect defaults are used when no width/height comes from LDtk. Add this block after the `Config.Doors` section (around line 131).

- [ ] **Open `source/assets/data/Config.lua`.** Find the `Config.Doors` block (ends around line 131).

- [ ] **Add after `Config.Doors`:**

```lua
-- Portal Doors
Config.Portals = {
    collideRect = {x=0, y=0, w=24, h=24},
}
```

- [ ] **Compile to check for syntax errors:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```
Expected: no errors.

---

## Task 2: Create `portal_door.lua`

**Files:**
- Create: `source/entities/props/portal_door.lua`

This file contains the `PortalDoor` class and its loading function. `PortalDoor` is a `NobleSprite` (same base as `Door`). It evaluates `Conditions` strings using the same logic as `Trigger:returnScript()` — path resolution through `PlayerData` plus optional comparison operators.

### Condition format recap (same as `conditionalScripts` in Trigger)

Each string: `"conditionExpr:anything"` — only `conditionExpr` is used here.

- Boolean: `"isTiny:x"` → `PlayerData.isTiny == true`
- Inverted boolean: `"!isTiny:x"` → `PlayerData.isTiny ~= true`
- Numerical: `"healthPoints>=3:x"` → `PlayerData.healthPoints >= 3`
- Nested path: `"inventory.tools==1:x"` → `PlayerData.inventory.tools == 1`

All conditions must pass (AND logic). Empty `conditions` table → always passable.

- [ ] **Create `source/entities/props/portal_door.lua` with this content:**

```lua
PortalDoor = {}
class('PortalDoor').extends(NobleSprite)

function PortalDoor:init(portalId, destLevel, destRoom, spawnX, spawnY, conditions, blockedDialog, x, y, width, height)
    self.portalId      = portalId
    self.destRoomId    = destLevel * 100 + destRoom
    self.spawnX        = spawnX
    self.spawnY        = spawnY
    self.conditions    = conditions or {}
    self.blockedDialog = blockedDialog or "nokeys"

    local cr = Config.Portals.collideRect
    local w  = width  or cr.w
    local h  = height or cr.h

    PortalDoor.super.init(self, nil, true)
    self:setSize(w, h)
    self:setCollideRect(cr.x, cr.y, w, h)
    self:setZIndex(ZIndex.props)
    self:setGroups(3)
    self:add(x, y)
end

-- Resolves a dot-separated path like "inventory.tools" inside PlayerData.
local function resolvePath(path)
    local current = PlayerData
    for part in path:gmatch("[^%.]+") do
        if current == nil then return nil end
        current = current[part]
    end
    return current
end

-- Returns true if ALL conditions pass (AND logic). Empty table = open.
function PortalDoor:canEnter()
    for _, condStr in ipairs(self.conditions) do
        local conditionExpr = condStr:match("^(.*):.*$") or condStr
        local isMet = false

        -- Try numerical comparison first (e.g. "healthPoints>=3")
        local path, op, valStr = conditionExpr:match("^([%w%.]+)%s*([<>!=]=?)%s*([%d%-%.]+)$")
        if path and op and valStr then
            local current    = tonumber(resolvePath(path)) or 0
            local val        = tonumber(valStr)
            if     op == ">"  then isMet = current >  val
            elseif op == "<"  then isMet = current <  val
            elseif op == ">=" then isMet = current >= val
            elseif op == "<=" then isMet = current <= val
            elseif op == "==" then isMet = current == val
            elseif op == "!=" then isMet = current ~= val
            end
        else
            -- Boolean path (e.g. "isTiny" or "!isTiny")
            local invert    = conditionExpr:sub(1,1) == "!"
            local cleanPath = invert and conditionExpr:sub(2) or conditionExpr
            isMet = (resolvePath(cleanPath) == true)
            if invert then isMet = not isMet end
        end

        if not isMet then return false end
    end
    return true
end

function PortalDoor:setSpawn()
    PlayerData.playerSpawn.x = self.spawnX
    PlayerData.playerSpawn.y = self.spawnY
end

function PortalDoor:goTo()
    Noble.transition(RoomTranslate(self.destRoomId), 1.5, Noble.Transition.Default)
end

function PortalDoor:collisionResponse()
    return "overlap"
end

-- Iterates currentRoom.entities.PortalDoors and instantiates each one.
function CreatePortalDoorsFromLDTK(currentRoom)
    if not currentRoom then return end
    local portalEntities = currentRoom.entities and currentRoom.entities.PortalDoors
    if not portalEntities or #portalEntities == 0 then return end

    for _, entity in ipairs(portalEntities) do
        local cf = entity.customFields or {}
        local destLevel    = cf.DestLevel    or 1
        local destRoom     = cf.DestRoom     or 0
        local spawnX       = cf.SpawnX       or 196
        local spawnY       = cf.SpawnY       or 116
        local conditions   = cf.Conditions   or {}
        local blockedDialog = cf.BlockedDialog or "nokeys"
        local portalId     = cf.PortalID     or 0

        PortalDoor(
            portalId, destLevel, destRoom,
            spawnX, spawnY,
            conditions, blockedDialog,
            entity.x, entity.y,
            entity.width, entity.height
        )
        printDebug("🌀 PortalDoor created — ID:", portalId, "→ room", destLevel * 100 + destRoom)
    end
end
```

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```
Expected: no errors.

---

## Task 3: Wire up in `MazeScene.lua`

**Files:**
- Modify: `source/scenes/MazeScene.lua` (lines ~28 and ~161)

Two changes: add the import and add the loading call.

- [ ] **Open `source/scenes/MazeScene.lua`.** Find the imports block around line 28 where `entities/props/door` is imported:

```lua
import 'entities/props/door'
```

- [ ] **Add the portal import directly after it:**

```lua
import 'entities/props/door'
import 'entities/props/portal_door'
```

- [ ] **Find the `CreateDoorsFromLDTK(currentRoom)` call (around line 161).** Add the portal loading call on the next line:

```lua
CreateDoorsFromLDTK(currentRoom)
CreatePortalDoorsFromLDTK(currentRoom)
```

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```
Expected: no errors.

---

## Task 4: Handle `PortalDoor` in `collisions.lua`

**Files:**
- Modify: `source/entities/player/collisions.lua`

Add one `elseif` block **before** the existing `elseif other:isa(Door)` block (currently around line 155).

- [ ] **Open `source/entities/player/collisions.lua`.** Find this block (around line 155):

```lua
  elseif other:isa(Door) then
```

- [ ] **Insert the following immediately before it:**

```lua
  elseif other:isa(PortalDoor) then
    if other:canEnter() then
      other:setSpawn()
      other:goTo()
    else
      self.dialogUI:addScreen(other.blockedDialog or "nokeys")
    end
    return 'overlap'

```

- [ ] **Compile:**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```
Expected: no errors.

---

## Task 5: Verify in simulator

No automated test runner exists. Validation is done in the Playdate Simulator.

- [ ] **Open the simulator:**

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

- [ ] **Test A — no `PortalDoors` entities in room.** Navigate any room that has no portal entities. Confirm normal doors still work and no errors appear in the console.

- [ ] **Test B — portal with no conditions.** Temporarily add a `PortalDoors` entity in LDtk (or directly in `levelsLDTK` in a test room) with `DestLevel=1`, `DestRoom=66` (or any valid room), `SpawnX=196`, `SpawnY=116`, `PortalID=1`, `Conditions={}`. Walk the player into it. Confirm: player transitions to the correct room and spawns at the specified coordinates.

- [ ] **Test C — portal with failing condition.** Set `Conditions={"isTiny:x"}` and ensure `PlayerData.isTiny = false`. Walk into portal. Confirm: dialog screen appears (`"nokeys"` or custom key), no transition occurs.

- [ ] **Test D — portal with passing condition.** Set `PlayerData.isTiny = true` (via debug cheat `up up up down` → System Menu → debug). Walk into portal. Confirm: player passes through.

- [ ] **Test E — existing doors unaffected.** Confirm all existing cardinal doors and key-locked doors still behave as before.

---

## Task 6: Update documentation

**Files:**
- Modify: `source/DOCS/DOORS_AND_KEYS.md`

- [ ] **Open `source/DOCS/DOORS_AND_KEYS.md`.** Append the following section at the end of the file:

```markdown
---

## 🌀 Portal Doors

Portal doors teleport the player to any room in the map regardless of adjacency. They are defined as a separate LDtk entity type (`PortalDoors`) and do not interact with the existing `Doors` entity or `CreateDoorsFromLDTK`.

### LDtk Entity: `PortalDoors`

| Field | Type | Description |
|-------|------|-------------|
| `PortalID` | `Int` | Labels a portal pair for identification. No runtime effect — place a second portal in the destination room to enable return travel. |
| `DestLevel` | `Int` | Destination level number. |
| `DestRoom` | `Int` | Destination room number within that level. Combined RoomID = `DestLevel * 100 + DestRoom`. |
| `SpawnX` | `Int` | X coordinate where the player spawns in the destination room. |
| `SpawnY` | `Int` | Y coordinate where the player spawns in the destination room. |
| `Conditions` | `Array<String>` | Entry conditions (same format as Trigger `conditionalScripts`). All must pass. Empty = always open. |
| `BlockedDialog` | `String` | Dialog key shown when entry is blocked. Defaults to `"nokeys"`. |

### Condition examples

```
"isTiny:x"          -- player must be tiny
"!isTiny:x"         -- player must NOT be tiny
"inventory.tools==1:x"  -- player must have tools
"healthPoints>=3:x" -- player must have at least 3 HP
```

### Code path

1. `MazeScene:enter()` calls `CreatePortalDoorsFromLDTK(currentRoom)` after `CreateDoorsFromLDTK`.
2. `CreatePortalDoorsFromLDTK` iterates `currentRoom.entities.PortalDoors` and instantiates `PortalDoor` per entity.
3. On player collision: `player/collisions.lua` checks `other:isa(PortalDoor)` → calls `canEnter()` → either `setSpawn() + goTo()` or shows blocked dialog.

### Config

`Config.Portals.collideRect` — default collision rect used when LDtk entity has no explicit size.
```
