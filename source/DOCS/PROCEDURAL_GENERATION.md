# Procedural Generation (Roguelike Run Graph)

The game generates a fresh room graph every run instead of using a fixed LDtk map. Rooms, doors, contents, crew, and secret rooms are assembled at runtime from LDtk **templates**. Meta-progression (items, skills, recruited crew, run counter, seen cutscenes) persists across runs; deleting the save wipes everything. A run ends only by death.

> Code: `utilities/MapGenerator.lua` (builds the graph), `utilities/RunState.lua` (the active run), with spawning in `scenes/MazeScene.lua` and doors/plugs/portals in `entities/props/door.lua` + `entities/props/portal_door.lua`.
>
> See also: [LEVEL_LOADING.md](LEVEL_LOADING.md), [SAVE_SYSTEM.md](SAVE_SYSTEM.md), [SCRIPTS_TRIGGERS_NPC_SCHEMA.md](SCRIPTS_TRIGGERS_NPC_SCHEMA.md), [DOORS_AND_KEYS.md](DOORS_AND_KEYS.md).

---

## 1. Core concepts

| Term | Meaning |
|------|---------|
| **Template** | An entry in `levelsLDTK` (a room as authored in LDtk). Immutable; **never deep-copied**. |
| **Pool** | Templates grouped by `roomRole`, filtered to those the player can use this run. Built by `MapGenerator.buildPool()`. |
| **Node** | A placed room in the run. References a template via `poolRoom`; holds per-run `content`/`cleared`/`edges`/`portals`. |
| **Graph** | Array of nodes (`RunState.graph`) plus `startId` and (when revealed) `finalReserved`. |
| **Run** | One generated graph, played until death. `PlayerData.runCount` counts runs (NewGame + each death). |

A node never mutates its template. Everything run-specific lives on the node:

```lua
node = {
  id, poolRoom,            -- template reference (by value, not a copy)
  edges      = { dir -> destNodeId },   -- side connections (one neighbour per side)
  doorCounts = { dir -> n },            -- doors per side (from the template)
  freeSides  = { dir -> true },         -- sides still unconnected during generation
  content    = { crewId, crewSpawn, enemies={}, utilities={}, isFinal },
  cleared    = { enemies={[key]={x,y}}, crewTaken },  -- runtime deltas on revisit
  portals    = { PortalID -> nodeId },  -- secret-room links (A<->A)
  isSecret   = bool,                    -- reached only via a portal
}
```

---

## 2. The pool: LDtk authoring fields

A template qualifies for the pool only when it is a procGen room **and** the player meets its item requirements.

| Field (LDtk customField) | Type | Purpose |
|--------------------------|------|---------|
| `procGen` | Bool | `true` → eligible for random placement. Secret rooms set this `false` (reached only by portal). |
| `roomRole` | Enum (string, case-insensitive) | `Start`, `Normal`, `Final`, `StartDown`, `StartUp`. Buckets the template in the pool. |
| `requiredItems` / `RequiredItems` | Array\<String\> | Items needed to traverse the room (case-insensitive, e.g. `{"HasLamp"}` → `PlayerData.items.hasLamp`). If the player lacks any, the room is excluded from the pool — you never enter a room you can't pass. Don't put this on Start/StartDown/StartUp/Final. |
| `requiredSkills` / `RequiredSkills` | Array\<String\> | Same as `requiredItems` but checked against `PlayerData.skills` (e.g. `{"canDance"}` → `PlayerData.skills.canDance`). Both lists must be satisfied for the room to enter the pool. |

`roomRole` buckets:

- **Start** — entry room for a normal new run.
- **Normal** — the body of the run; random placement, loops, feature swaps.
- **StartDown** — entry room after falling through a hole (a new run is generated).
- **StartUp** — entry room after rising through a tube (a new run is generated).
- **Final** — the endgame room, attached only when the whole crew is recruited.

---

## 3. Generation pipeline (`MapGenerator.generate(progress, entryRole)`)

`progress` = crew recruited so far; it scales run size (`Config.MapGen.roomsBase + progress`, capped at `roomsMax`). `entryRole` picks the start bucket (`start` default, `startdown`/`startup` for vertical entries).

1. **Start node** — random template from `pool[entryRole]` (falls back to `start`, then `normal`).
2. **Guaranteed path** — repeatedly attach a `normal` room to a node that still has a free side, until the run reaches its size. The candidate must match the from-side's **door signature** (see §4). Selection prefers fresh (unused) templates while sane (see §6) and biases toward a still-missing required feature (dark room / hole room, see §5).
3. **Loops (exhaustive)** — every free side links to the first placed node whose opposite side is free and signature-compatible. No probability gate, so no door dangles. (A specific pair is still not *guaranteed* adjacent — both must be placed and reach this phase with the matching side free.)
4. **Feature guarantee** — if the run still lacks a dark room or a hole room, swap a placed normal node for one with the **same full door layout** that has the feature (keeps connectivity intact).
5. **Secret rooms** — pull portal destinations in as `isSecret` nodes (see §7).
6. **Content roll** — per node, decide which authored enemies/utilities are active this run (see §8).
7. **Crew assignment** — distribute uncollected roster members across eligible nodes (see §9).

`MapGenerator.selfCheck(progress)` (debug menu `gen-test`) asserts every node is reachable and every edge is bidirectional.

---

## 4. Door connection: signature matching

Two rooms connect a side ↔ the opposite side only when their **door signatures match** — the count, position, and size of every door on that side line up:

- **top ↔ down**: doors align on **x + width**.
- **left ↔ right**: doors align on **y + height**.
- The position along the connection axis itself is ignored (one door sits at a room edge, its partner at the opposite edge).

Implementation: `doorSlotsSig(template, side)` builds a canonical `"pos:size,..."` string (sorted), memoized per template. `sidesMatch(a, dirA, b)` compares `a`'s side to `b`'s opposite side. This is stricter than (and subsumes) a door-count match. All doors on a side lead to the **same** neighbour node. Authored door `x`/`y` is the entity **centre**.

> To make two rooms reliably connectable, author their facing sides with the same door count, x/width (for top/down) or y/height (for left/right).

---

## 5. Guaranteed variety (dark + holes)

Every run includes at least one **dark** room (`customFields.shadow == true`) and one room with **holes** (a hole IntGrid tile in its `tileMapData`). Achieved by biasing path selection toward the missing feature, then a post-pass that swaps a placed node for a same-door-layout template that has it. Best-effort: needs such rooms in the pool with compatible door layouts.

---

## 6. Room repetition rule

- While **sane** (`PlayerData.sanityCounter == 0`): templates don't repeat within a run.
- Once the player has gone mad at least once (`sanityCounter > 0`): repeats are allowed (also a safety valve when the pool is small).

---

## 7. Secret rooms via PortalDoors

PortalDoors are tiny-gated entrances to secret rooms, paired **A↔A** by `PortalID` (each room's portal cross-references the other's `DestLevel`/`DestRoom`). They are **not** part of side-connectivity.

- During generation, each placed room's `PortalDoors` resolves its destination template (`level*100 + roomNumber`; secret rooms are `procGen=false`) and adds it as an `isSecret` node, linking `host.portals[pid] ↔ secret.portals[pid]`.
- `CreatePortalsFromNode` (portal_door.lua) instantiates the portals with `targetNodeId = node.portals[pid]`.
- `PortalDoor:goTo()` → `RunState.goTo(targetNodeId)` + transition, with `returningInPlace` so the player spawns at the portal's authored `SpawnX`/`SpawnY`.
- Gating stays in the portal's `Conditions` (`canEnter`, e.g. `isTiny:true`); failing shows `BlockedDialog`.
- Secret nodes get content (enemies/utilities) but are excluded from crew spawns.

Example: Room 3 (`procGen`) ↔ Room 81 (`procGen=false`, secret), `PortalID = 1`, `Conditions = {"isTiny:true"}`.

---

## 8. Per-node content

For each node, `generate` rolls which authored markers become active this run (stored on `node.content`, persisted per-run, re-applied on revisit via `node.cleared`):

- **Enemies** (`Brocorat`, `Bosscolli`): spawn if `customFields.forceSpawn` or `math.random() < Config.MapGen.enemyChance`. Killed enemies are recorded in `node.cleared.enemies[key] = {x,y}` and drawn as blood on revisit.
- **Utilities** (`Microwave`, `Minifier`): spawn if `forceSpawn`, or — for a `Minifier` — if the room has a **small door** (any `Doors` entity with a 16px side, meaning the player must be tiny to pass), else `Config.MapGen.utilityChance`.

`forceSpawn = true` on an entity bypasses the chance roll (always spawns).

---

## 9. Crew assignment & endgame

- Crew are a numbered roster `CM001..CM0{totalCrew}` (`Config.MapGen.totalCrew`). LDtk `CrewMember` entities are **generic spawn markers**; the generator picks which uncollected identity appears where.
- Eligible nodes: non-start, non-secret, with at least one `CrewMember` marker. About `ceil(#graph / roomsPerCrewSpawn)` crew are placed per run, capped by uncollected count.
- Recruiting the **whole roster** calls `RunState.revealFinalRoom()`, which attaches a `Final`-role template to a node with a free side. Entering the final room ends the run → CreditsScene.

Each crew member has its own hat (`Hats(crewId)`) and dialog (`<crewId>_tiny`, fallback `CM001_tiny`).

---

## 10. Item gating & spawn conditions

Two independent gates layered on top of the pool:

- **Room-level** `requiredItems` / `requiredSkills` (§2): excludes whole rooms from the pool (checked against `PlayerData.items` / `PlayerData.skills`).
- **Entity-level** `spawnConditions` on Items and Triggers: a render gate evaluated before the entity is created. See [SCRIPTS_TRIGGERS_NPC_SCHEMA.md](SCRIPTS_TRIGGERS_NPC_SCHEMA.md#spawn-conditions-render-gate). Uses `utilities/Conditions.lua` (`run`/`crew` aliases, AND across the array, OR with `|` inside an entry).

`PlayerData.runCount` (alias `run`) increments on NewGame (set to 1) and on each death/Retry — not on hole/tube.

---

## 11. Closed-door wall plugs

When the graph leaves an authored door side **unconnected**, its opening would otherwise show a gap in the baked room PNG and let the player walk into the void (no collider). `CreateWallPlugsFromNode` (door.lua, called after `CreateDoorsFromNode`) covers each such opening with a `WallPlug`: a sprite that tiles a brick frame from the tilesheet **plus** a `CollideGroups.wall` collider.

- Geometry: span = door size + `trimTiles` (1 tile up for left/right, 1 each side for top/down); depth = `depthTiles` from the screen edge.
- Per-side fill tile and sizing live in `Config.Doors.plug` (`tilesheet`, `tiles.{top,down,left,right}`, `depthTiles`, `trimTiles`).

---

## 12. Vertical navigation = new run

Falling through a hole (`Player:fallBelow`) or rising through a tube (`Player:riseAbove`) **regenerates the run** rather than navigating a fixed neighbour: `RunState.startRun("startdown")` / `("startup")`. Meta persists; the player enters at a `StartDown`/`StartUp` room (fallback `Start`/`normal`). This avoids the softlocks the old fixed-map vertical links could cause.

---

## 13. RunState (active run) & navigation

`RunState` is the in-memory source of truth for the current run:

| Field / function | Purpose |
|------------------|---------|
| `graph`, `currentNodeId`, `pendingNodeId` | the run, the room you're in, the room a transition is heading to |
| `startRun(entryRole)` | generate a fresh run from `progress` (crew recruited) |
| `goTo(nodeId)` | stage a destination (consumed by the next `MazeScene:enter`) |
| `consumePending()` | move `current` ← `pending` on scene enter |
| `revealFinalRoom()` | attach the Final room when the roster is complete |
| `serialize()` / `deserialize(data)` / `clear()` | save/load/wipe the run (see §14) |

Navigation reuses a single `MazeScene`: a door's `targetNodeId` → `RunState.goTo` → `Noble.transition(MazeScene, ...)`. The old `Floors.lua` / `RoomTranslate` path is dead code in procedural mode.

---

## 14. Persistence (`3.0-PROCGEN`)

`SaveSystem` saves `{ player = PlayerData, run = RunState.serialize() }`:

- **Meta** (in `PlayerData`, persists across runs, wiped on delete): items, skills, `CrewMemberData` (idNumbers/amountTaken), `sanityCounter`, `runCount`, `seenComics`.
- **Run graph** (`RunState.serialize`): each node stores its template by `uniqueIdentifer` (re-linked against live `levelsLDTK` on load), plus `edges`/`doorCounts`/`freeSides`/`content`/`cleared`/`portals`/`isSecret`. `content`/`cleared`/`edges` are plain data.

`load()` rejects non-`3.0-PROCGEN` saves. **Continue** restores the run and resumes at the saved player position (`MazeScene:pause` captures `player.x/y` before saving). The old per-iid `levelState` model is gone. See [SAVE_SYSTEM.md](SAVE_SYSTEM.md).

---

## 15. LDtk authoring checklist

For a template to participate in procedural generation:

- [ ] `customFields.procGen = true` (or `false` for a secret room reached only by a portal).
- [ ] `customFields.roomRole` set (`Start` / `Normal` / `Final` / `StartDown` / `StartUp`).
- [ ] At least one `Start` room with no `requiredItems`. Author `StartDown`/`StartUp` rooms for hole/tube entries and one `Final` room.
- [ ] Door sides authored consistently so facing sides share door count + x/width (top/down) or y/height (left/right) — see §4.
- [ ] (Optional) `requiredItems` for item-gated rooms; `forceSpawn = true` on entities that must always appear; `spawnConditions` on items/triggers for fine gating.
- [ ] Secret rooms: a `PortalDoors` pair sharing a `PortalID`, each pointing at the other's `DestLevel`/`DestRoom`, with `Conditions` (e.g. `isTiny:true`).
- [ ] At least one dark room (`shadow`) and one hole room in the pool with door layouts that match other rooms (so the feature guarantee can place/connect them).

---

## 16. Config reference

```lua
Config.MapGen = {
    roomsBase         = 8,    -- minimum run size
    crewPerExtraRoom  = 1,    -- recruit this many crew to grow the run by +1 room
    roomsMax          = 20,   -- run size cap
    roomsPerCrewSpawn = 4,    -- ~1 crew per this many rooms
    utilityChance     = 0.4,  -- chance a microwave/minifier marker is active
    totalCrew         = 12,   -- full roster; recruiting all reveals the final room
    enemyChance       = 0.6,  -- chance an enemy marker is active
    itemChance        = 0.5,  -- chance an item marker is active
    darkBiasPerCrew   = 0.02, -- added dark-room probability per crew recruited
}

Config.Doors.plug = {        -- closed-door wall covers (§11)
    tilesheet  = 'assets/images/tile/tile-table-16-16',
    depthTiles = 1,
    trimTiles  = 1,
    tiles = { top = 44, down = 38, left = 42, right = 40 },
}
```

---

## 17. Love2D port notes

The procedural code is plain Lua with almost no Playdate-specific API, so most of it ports unchanged. Watch for these:

| Concern | Playdate / current | Love2D |
|---------|--------------------|--------|
| `MapGenerator` / `RunState` | Pure Lua tables + `math.random` | **Port as-is.** No graphics/SDK calls in the generator. Seed RNG with `love.math.setRandomSeed` / `math.randomseed(os.time())` at boot. |
| Template lookup | `levelsLDTK` global, `uniqueIdentifer` | Unchanged (`levels.lua` loads directly, see [LOVE2D_PORT.md](LOVE2D_PORT.md) §6). |
| Door rendering / colliders | `CreateDoorsFromNode`, thin door collide rects | Build the same door rects; in bump.lua add them with `type="door"` and `cross` filter; transition on overlap. |
| Wall plugs (§11) | sprite tiling a tilesheet frame + `Box` wall collider | `love.graphics.newImage` tilesheet → `love.graphics.newQuad` for the per-side frame, draw tiled to a `Canvas`; add a bump box `type="wall"`. |
| Secret-room portals (§7) | `RunState.goTo` + scene transition, `Conditions` gate | Same node routing; evaluate `Conditions` against the Love2D `PlayerData`. |
| `Conditions` evaluator | string parse against `PlayerData` | Pure Lua; **port as-is** (used by `spawnConditions`). |
| Persistence (§14) | `playdate.datastore` | `love.filesystem` + json.lua. **Serialize `RunState` (not per-iid levelState)** — the JSON model is the same node table. Map nodes to/from templates by `uniqueIdentifer`. See [SAVE_SYSTEM.md](SAVE_SYSTEM.md). |
| Navigation | single reused `MazeScene` via `RunState` | One `MazeScene` in the Scene Manager; `goTo` sets the pending node, the manager re-enters MazeScene. **`Floors.lua` / `RoomTranslate` are not needed** in procedural mode. |
| Dark/hole detection | scans `tileMapData` + `customFields.shadow` | Unchanged (plain data). |

> The biggest divergence from the existing [LOVE2D_PORT.md](LOVE2D_PORT.md): that guide still documents the fixed-map model (RoomTranslate, Floors.lua, save `2.0-LDTK`, per-iid `levelState`). For a procedural port, follow **this** document instead for level flow and persistence; use LOVE2D_PORT.md for the engine-level mapping (bump.lua, Scene Manager, input, FX, DanceScene).
