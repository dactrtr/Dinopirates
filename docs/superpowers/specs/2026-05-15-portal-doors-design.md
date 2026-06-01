---
name: portal-doors-design
description: Design spec for PortalDoor — a new door type that can teleport the player to any room in the map, with conditional entry validation and paired portal IDs
metadata:
  type: project
---

# Portal Doors — Design Spec

**Date:** 2026-05-15
**Branch:** new-feat

---

## Overview

A new door type (`PortalDoor`) that teleports the player to any arbitrary room in the map, bypassing the adjacency constraint of normal doors. Portals are paired by a shared `PortalID` so a return portal can be placed in the destination room. Entry can be gated by conditions on `PlayerData` (e.g., player must be tiny, must carry a specific item).

The existing door system (`Door`, `CreateDoorsFromLDTK`, normal collision logic) is **not modified**.

---

## LDtk Entity: `PortalDoors`

A new entity type distinct from the existing `Doors` entity.

| Field | LDtk Type | Description |
|-------|-----------|-------------|
| `PortalID` | `Int` | Label that identifies a portal pair (e.g. both portals in a pair use `1`). Used for debugging only — no runtime pairing logic. The return trip is handled by placing a second `PortalDoors` entity in the destination room pointing back. |
| `DestLevel` | `Int` | Destination level number (e.g. `4`). |
| `DestRoom` | `Int` | Destination room number within that level (e.g. `8`). Combined: `DestLevel * 100 + DestRoom = 408`. |
| `SpawnX` | `Int` | X coordinate where the player spawns in the destination room. |
| `SpawnY` | `Int` | Y coordinate where the player spawns in the destination room. |
| `Conditions` | `Array<String>` | Entry conditions using the same format as `conditionalScripts` on Triggers (see below). Empty = always open. |
| `BlockedDialog` | `String` | Dialog key shown when conditions are not met (e.g. `"notiny"`). Defaults to `"nokeys"` if absent. |

### Condition format (same as Trigger `conditionalScripts`)

Each string follows `"conditionExpr:script"` — the script part is ignored for portals; only the condition side is evaluated to determine if entry is allowed.

Examples:
- `"isTiny:enter"` — player must be tiny
- `"!isTiny:enter"` — player must NOT be tiny
- `"inventory.tools==1:enter"` — player must have tools
- `"healthPoints>=3:enter"` — player must have at least 3 HP

All conditions must be true for entry to be allowed (AND logic).

---

## Config

Add to `source/assets/data/Config.lua`:

```lua
Config.Portals = {
    collideRect = {x=0, y=0, w=24, h=24},  -- default collision size
    zIndex      = ZIndex.props,
}
```

---

## New File: `source/entities/props/portal_door.lua`

### Class `PortalDoor`

```
PortalDoor:init(portalId, destLevel, destRoom, spawnX, spawnY, conditions, blockedDialog, x, y, width, height)
```

Stored fields:
- `self.portalId` — for identification/debugging
- `self.destRoomId` — `destLevel * 100 + destRoom`
- `self.spawnX`, `self.spawnY`
- `self.conditions` — array of condition strings
- `self.blockedDialog` — dialog key, defaults to `"nokeys"`

Key methods:

**`PortalDoor:canEnter()`**
Evaluates `self.conditions` using the same path-resolution + operator logic as `Trigger:returnScript()`. Returns `true` if all conditions pass or the array is empty.

**`PortalDoor:setSpawn()`**
Writes `PlayerData.playerSpawn.x = self.spawnX` and `PlayerData.playerSpawn.y = self.spawnY`.

**`PortalDoor:goTo()`**
Calls `Noble.transition(RoomTranslate(self.destRoomId), 1.5, Noble.Transition.Default)`.

**`PortalDoor:collisionResponse()`**
Returns `"overlap"` (same as `Door`).

### Loading function: `CreatePortalDoorsFromLDTK(currentRoom)`

Iterates `currentRoom.entities.PortalDoors`. For each entity:
- Reads `PortalID`, `DestLevel`, `DestRoom`, `SpawnX`, `SpawnY`, `Conditions`, `BlockedDialog` from `customFields`
- Instantiates `PortalDoor(...)` with entity position and size

---

## Change to `source/entities/player/collisions.lua`

Add one new `elseif` block **before** the existing `elseif other:isa(Door)` block:

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

No other lines in this file change.

---

## Change to `source/scenes/MazeScene.lua`

In `MazeScene:enter()`, after the existing `CreateDoorsFromLDTK(currentRoom)` call, add:

```lua
CreatePortalDoorsFromLDTK(currentRoom)
```

No other lines in this file change.

---

## Documentation updates (end of implementation)

- **`source/DOCS/DOORS_AND_KEYS.md`** — add a "Portal Doors" section describing the entity fields, condition format, and pairing behavior.

---

## What is NOT in scope

- Saving/restoring portal state (portals are stateless — they don't track "has been used")
- Visual portal sprite or animation (placeholder collision rect only; art can be added later)
- Portal destinations outside the existing `levelsLDTK` table (will log a debug warning if `RoomTranslate` returns nil)
