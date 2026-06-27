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
| `DeadScene` | `scenes/DeadScene.lua` | Game over — Retry / Exit menu with crank support |
| `CockpitScene` | `scenes/CockpitScene.lua` | Accelerometer + D-pad button-sequence puzzle; leads to CreditsScene or TitleScene |
| `SpaceScene` | `scenes/SpaceScene.lua` | Space escape shooter with crank-toggled fighter/travel modes |
| `CreditsScene` | `scenes/CreditsScene.lua` | Scrolling credits sequence |
| `FloorXXX` | `scenes/Floors.lua` | Auto-generated scene classes for every room |

`Floors.lua` generates classes from **hardcoded floor number ranges** (not from `levelsLDTK`). Current ranges: 166–180, 231–274, 316–330, 401–415. Each FloorXXX class calls `self:setFloor(level, room)` in `init()` (derived as `level = floor(i/100)`, `room = i % 100`) and sets `PlayerData.saveLevel = i`.

**Room numbering**: `RoomID = level * 100 + roomNumber` (e.g., level 4, room 8 → `Floor408`).
**Room lookup**: `RoomTranslate(roomNumber)` → looks up `_G["Floor408"]` to get the class for `Noble.transition`.

---

## Level Loading Flow (MazeScene)

1. `setFloor(level, room)` — finds the index into `levelsLDTK` matching level+room, stores as `room`.
2. `enter()` — reads metadata into `PlayerData` (`actualLevel`, `actualRoom`, `actualTilemap`, `isInDarkness`), marks room `visited = true`, loads background PNG from `assets/images/rooms/floor{level}/{identifier}`.
3. `CreateTileColliders` — auto-generates wall colliders from `tileMapData[actualTilemap]`.
4. `CreateDoorsFromNode(node)` + `CreateWallPlugsFromNode(node)` + `CreatePortalsFromNode(node)` — build doors only on the sides the **procedural run graph** connected (`node.edges`, matched by door signature); cover unconnected sides with wall plugs; place secret/vertical exits as portals. (The old `CreateDoorsFromLDTK`, which read `neighbourLevels` + `DoorsConnection`, has been removed — see legacy note in `entities/props/door.lua`.)
5. Entity spawning — in order: `PropItem` (skip if `destroyed`), `Items` (skip if already owned), `Player` + HUD, `FXshadow` (if dark), cutscene (if `play=="Enter"` and not played), `Brocorat`/`Bosscolli` (skip if `dead`), `CrewMember` (skip if `isTaken`), `NPC`, `Trigger` (skip if `usedTrigger`).
6. `start()` — enables diagonal movement, sets `PlayerData.isGaming = true`.
7. `finish()` and `pause()` — both call `SaveSystem.save()`.

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

Falling through a hole or rising through a tube does **not** go to a fixed neighbour room — it starts a **new procedural run**. `Player:fallBelow()` / `riseAbove()` (`entities/player/state.lua`) call `RunState.startRun("startdown")` / `RunState.startRun("startup")`, which regenerates the whole graph via `MapGenerator` and enters at a random room whose `customFields.roomRole` matches `"Startdown"` / `"Startup"` (falling back to `"Start"` → `"normal"`). Player meta (items, skills, crew, sanity) persists across the run. To control where the player lands, author rooms with the matching `roomRole` and `procGen = true`; it is **not** deterministic (random among eligible rooms).

> **Legacy (removed):** the old fixed-grid path used `neighbourLevels` + `DoorsConnection` with `GetLowerRoom()` / `GetUpperRoom()` in `utilities/Utilities.lua`. Those functions were removed; a before/now note remains in `Utilities.lua` for the Love2D port.

---

## Workflow

- **Never run `git commit`** during implementation, fixes, or any other work. The user commits manually. Skip all commit steps in plans. Compiling with `pdc` to verify is fine, but stop before committing.

---

## Noble Engine Notes

- D-pad input callbacks use `upButtonHold` / `downButtonHold` / etc. (not `Held` suffix).
- Per-frame movement should use `playdate.buttonIsPressed()` inside `update()`, not callbacks.

---

## Key Docs

Detailed system documentation lives in `source/DOCS/`:
- `LEVEL_LOADING.md` — full room loading + vertical navigation
- `PROCEDURAL_GENERATION.md` — roguelike run graph: pool/nodes, door-signature matching, loops, secret rooms (portals), wall plugs, requiredItems, runCount/spawnConditions, vertical=new run, save 3.0, LDtk authoring + Love2D port
- `PLAYER_SYSTEMS.md` — battery, sanity, inventory, skills
- `ENEMIES_AND_COMBAT.md` — AI and DanceScene rhythm system overview
- `DANCE_SCENE.md` — full DanceScene: lifecycle, difficulty, hit detection, balance bar, animations, outcomes
- `SAVE_SYSTEM.md` — persistence layer
- `PLUNGERANG.md` — projectile mechanics
- `GRAPPLING_HOOK.md` — charged plungerang in lit rooms: tile-33 grapple, charge/pull, tokens
- `MICROWAVE_AND_FOOD.md` — pick up food, cook it at a microwave by cranking to heal HP (mirrors the minifier); calorie byproduct, persistence, Config
- `TITLE_SCENE.md` — TitleScene menu modes, input, Continue/NewGame/Delete flow
- `CREDITS_SCENE.md` — CreditsScene scrolling system, item types, input
- `COCKPIT_SCENE.md` — CockpitScene: accelerometer pointer, button layout, sequence matching, fail system
- `SPACE_SCENE.md` — SpaceScene: ship modes, meteorites, danger bar, accelerometer controls
- `ACHIEVEMENTS.md` — PlaydateSquad achievements lib: definitions, grant wrappers (story/sanity), toasts, viewer, crossgame, Delete-clears
- `DOORS_AND_KEYS.md`, `TRIGGER_SYSTEM.md`, `PROPS_AND_ITEMS.md`, `DIALOG_SYSTEM.md`, `HUD_SYSTEM.md`, `TILE_LOADING.md`, `CREWMEMBER_AND_COLLISIONS.md`
