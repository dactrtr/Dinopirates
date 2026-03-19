# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Compile to Playdate package
pdc source "DinoPirates from inner space Brocolation.pdx"

# Run in simulator (macOS)
open "DinoPirates from inner space Brocolation.pdx"

# Push to device
pdutil push "DinoPirates from inner space Brocolation.pdx"
```

The Playdate SDK must be installed. There is no test runner — validate changes by running in the simulator.

To toggle debug mode in-game: System Menu → "debug" or cheat code `up up up down`.

---

## Architecture Overview

**Platform**: Panic Playdate (400×240 px, 1-bit display, ~35–50 fps, Lua)
**Framework**: Noble Engine (`libraries/noble/`) — handles scenes, sprites, transitions, input

### Entry Point: `main.lua`
Sets all globals, imports everything, builds the `roomsByIid` lookup hash, then calls `Noble.new(TitleScene)`.

### Global State (set in `main.lua` or their own files)
| Global | Source | Purpose |
|--------|--------|---------|
| `PlayerData` | `assets/data/PlayerDataTables.lua` | All player state: health, inventory, battery, sanity, position |
| `levelsLDTK` | `assets/data/levels.lua` | All room/entity data exported from LDtk |
| `roomsByIid` | `main.lua` | Hash map `iid → room` for O(1) lookups |
| `Config` | `assets/data/Config.lua` | All tunable constants (speeds, costs, thresholds, z-indices, collision groups) |
| `ZIndex`, `CollideGroups` | `main.lua` (from Config) | Rendering layers and collision group IDs |
| `debug` | `main.lua` | Toggle for debug overlays / FPS display |

**Rule**: All magic numbers belong in `Config.lua`. Never hard-code values that might need tuning.

---

## Scene System

Scenes extend `NobleScene`. Lifecycle: `init → enter → update → exit`.

| Scene | File | Purpose |
|-------|------|---------|
| `TitleScene` | `scenes/TitleScene.lua` | Main menu / title screen |
| `MazeScene` | `scenes/MazeScene.lua` | Core gameplay — loads rooms, spawns entities |
| `DanceScene` | `scenes/DanceScene.lua` | Rhythm combat when player touches an enemy |
| `DeadScene` | `scenes/DeadScene.lua` | Game over |
| `FloorXXX` | `scenes/Floors.lua` | Auto-generated scene classes for every room |

`Floors.lua` dynamically creates classes like `Floor120`, `Floor408`, etc. from the `levelsLDTK` table. Each FloorXXX class calls `MazeScene:setFloor(level, room)` before entering.

**Room numbering**: `RoomID = level * 100 + roomNumber` (e.g., level 4, room 8 → `Floor408`).
**Room lookup**: `RoomTranslate(roomNumber)` → looks up `_G["Floor408"]` to get the class for `Noble.transition`.

---

## Level Loading Flow (MazeScene)

1. `setFloor(level, room)` — finds the index into `levelsLDTK` matching level+room, stores as `room`.
2. `enter()` — reads metadata (`isInDarkness`, `actualTilemap`), renders tilemap, creates `FXshadow` if dark.
3. `CreateTileColliders` — auto-generates wall colliders from non-walkable tile IDs.
4. `CreateDoorsFromLDTK` — creates door sprites from `neighbourLevels` + `DoorsConnection` fields.
5. Entity spawning loop — iterates `levelsLDTK[room].entities`, spawns `PropItem`, `Items`, `Brocorat`, `CrewMember` based on their saved state (`destroyed`, `dead`, `isTaken`, `collected`).
6. `finish()` / on room exit — calls `SaveSystem.save()`.

State mutations (kills, prop breaks) are written back into the live `levelsLDTK` table, then persisted by the save system.

---

## Player Entity

The player is split across multiple files in `entities/player/`:

| File | Responsibility |
|------|---------------|
| `init.lua` | Constructor, collision rect setup |
| `movement.lua` | Move logic, battery/sanity drain, pedometer, `isActive` flag |
| `state.lua` | `fallBelow()`, `riseAbove()` — vertical floor transitions |
| `collisions.lua` | Collision responses (enemy → `fight()`, items, doors) |
| `abilities.lua` | Skill use routing |
| `lightburst.lua` | Lamp flash cone (uses `playdate.geometry.polygon`) |
| `dash.lua` | Dash ability with cooldown |
| `plunge.lua` / `projectile.lua` | Plungerang boomerang projectile |
| `sliding.lua` | Slime tile sliding state |
| `sanity.lua` | Sanity tick logic |
| `animations.lua` | State-based animation switching |
| `items.lua` | Item pickup effects |

**Turn-based sync**: `PlayerData.isActive` is set `true` when the player moves or charges the battery. Enemies and CrewMembers only update their AI when `isActive` is true — "time moves when you move."

---

## Enemy & Combat System

- `entities/enemies/enemy.lua` — base class with `search`, `blindSearch`, `linealSearch` AI, `sonar`, `blind`
- `entities/enemies/brocorat.lua` — standard enemy
- `entities/enemies/crewmember.lua` — friendly NPC with hiding/capture AI (requires `hasBag`)

**Combat**: Player touching an enemy calls `self:fight()` → stores encounter in `PlayerData.lastEnemyTouched` → transitions to `DanceScene`.

**DanceScene difficulty** scales with `PlayerData.EnemiesData.powerLevel` (1–20). Power level rises when `sanityCounter` increments (every time sanity hits 0).

---

## Save System (`utilities/SaveSystem.lua`)

- `SaveSystem.createOriginalBackup()` — called at startup, deep-copies `levelsLDTK` so game can reset without re-reading files.
- `SaveSystem.save()` — serializes `PlayerData` + changed entity states from `levelsLDTK` into Playdate datastore key `'gameState'`, version `"2.0-LDTK"`.
- `SaveSystem.load()` — on boot, applies saved entity states (by `iid`) onto the fresh `levelsLDTK` table.

Only changed fields are saved (e.g., `dead`, `destroyed`, `isTaken`, `collected`, `usedTrigger`) — matched by LDtk entity `iid`.

---

## Vertical Navigation

Rooms connect vertically via `neighbourLevels` (with `dir = "<"` for lower, `dir = ">"` for upper) plus a `DoorsConnection` permission list in `customFields`. `GetLowerRoom()` / `GetUpperRoom()` in `utilities/Utilities.lua` validate both before allowing `fallBelow()` / `riseAbove()`.

---

## Key Docs

Detailed system documentation lives in `source/DOCS/`:
- `LEVEL_LOADING.md` — full room loading + vertical navigation
- `PLAYER_SYSTEMS.md` — battery, sanity, inventory, skills
- `ENEMIES_AND_COMBAT.md` — AI and DanceScene rhythm system
- `SAVE_SYSTEM.md` — persistence layer
- `PLUNGERANG.md` — projectile mechanics
- `DOORS_AND_KEYS.md`, `TRIGGER_SYSTEM.md`, `PROPS_AND_ITEMS.md`, `DIALOG_SYSTEM.md`, `HUD_SYSTEM.md`, `TILE_LOADING.md`, `CREWMEMBER_AND_COLLISIONS.md`
