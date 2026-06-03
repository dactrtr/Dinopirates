# Procedural Level Generation — Design Spec

**Date:** 2026-06-02
**Status:** Approved design, pending implementation plan
**Game:** DinoPirates from inner space (Panic Playdate, Lua, Noble Engine)

---

## 1. Goal

Replace the current fixed LDtk map (rooms wired to specific neighbours by `iid`) with a
**roguelike with meta-progression**:

- Each run generates a fresh map from a pool of authored room templates.
- Items, skills and recruited crew **persist across runs** (meta-progression).
- Deleting the save wipes everything back to zero.
- The win condition is recruiting the **entire crew roster**; doing so opens the final room.

This gives the game an ending and a reason to replay.

---

## 2. Core loop

```
New run → procedural map (open graph, scales with progress)
  → recruit crew (banked instantly, even if you die afterwards)
  → run ends ONLY by death (HP, sanity reaching 0, or falling into the void)
  → DeadScene (message varies by death cause)
  → Retry generates a NEW run with fewer crew left to find
  → ... → when the LAST crew is recruited, the final room opens in the current run
```

### Design decisions (locked)

| Topic | Decision |
|---|---|
| Map model | Roguelike: regenerated every run. Meta (items/skills/crew) persists. |
| Generation unit | Loose rooms connected by matching door direction. |
| Topology | Open graph with loops (guaranteed-path construction, no retries). |
| Run size | Scales with progress (crew recruited → more rooms, capped). |
| Run end | Death only (no voluntary extraction). |
| Crew banking | Instant on recruit; survives death. |
| Sanity | Reaching 0 = game over, but `sanityCounter` is preserved for difficulty scaling. |
| Crew per run | Proportional to map size (~1 crew per N rooms). |
| Crew identity | **Numbered roster.** Each `crewId` has its own hat and its own dialog. |
| Final room | Opens in the current run the moment the last crew is recruited. |
| Keys/locks | Removed from procedural. Progression is gated by meta items/skills. |
| Utility rooms | Random, not guaranteed (no guaranteed microwave/minifier per run). |

---

## 3. Architecture overview

`levelsLDTK` stops being a **fixed graph** and becomes a **pool of room templates**.
Their exported `neighbourLevels` are **ignored** at runtime. The generator assembles loose
rooms into a per-run graph.

### Modules

| Module | Role |
|---|---|
| `utilities/MapGenerator.lua` *(new)* | Builds the run graph: picks rooms from the pool, connects them by matching door direction (bidirectional), adds loops, places content (crew/utilities/enemies/items). Returns a `runGraph`. |
| `utilities/RunState.lua` *(new)* | Holds the active `runGraph`, the current node, and helpers (`getNode`, `getEdge`, `revealFinalRoom`). Single source of truth for the run in memory. |
| `scenes/MazeScene.lua` *(refactor)* | No longer uses `setFloor(level, room)`. Receives the target `nodeId` via `sceneProperties` and loads that room template + doors from the node's edges. |
| `entities/props/door.lua` *(refactor)* | A door stores a `targetNodeId` (not a Floor number). `goTo()` does `Noble.transition(MazeScene, ..., { nodeId = self.targetNodeId })`. |
| `scenes/Floors.lua` *(remove)* | No longer needed. `RoomTranslate` is also retired. |
| `utilities/SaveSystem.lua` *(rewrite)* | Drops per-iid `levelState`. Persists meta + active run. Version `"3.0-PROCGEN"`. |
| `entities/props/npc.lua` *(extend)* | Adds crew-count conditions for story dialogs. |
| `entities/enemies/crewmember.lua` *(adjust)* | Dialog derived from `crewId`; marker is generic. |
| `entities/player/sanity.lua`, `state.lua` *(adjust)* | Sanity 0 triggers death; set `deathCause`. |
| `scenes/DeadScene.lua` *(adjust)* | Message by `deathCause`; Retry starts a new run. |
| `assets/data/Config.lua` *(extend)* | New `Config.MapGen` block. |

### Navigation rework (verified feasible)

`Noble.transition(NewScene, dur, transition, transitionProps, sceneProps)` creates a **new
instance** of the passed scene (`queuedScene = NewScene(sceneProps)`) and garbage-collects the
old one. Therefore a single `MazeScene` can be reused and transitioned `MazeScene → MazeScene`,
passing the destination node via `sceneProps`. This removes the need for the pre-generated
`Floor166…Floor481` classes and `Floors.lua`.

Door transition flow:

```
Player touches door → door.targetNodeId
  → Noble.transition(MazeScene, dur, transition, {}, { nodeId = targetNodeId })
  → MazeScene:init reads sceneProperties.nodeId, sets RunState.currentNode
  → MazeScene:enter loads the node's template (bg, tilemap, node entities)
     and creates doors from node.edges (each edge → a door with its targetNodeId)
```

### Run graph node (in memory, not in LDtk)

```lua
node = {
  id = 1,
  poolRoom = <reference to a levelsLDTK template>,  -- IMMUTABLE template, never deep-copied
  edges = { right = 4, down = 2 },                   -- dir → destination nodeId (bidirectional)
  content = {                                         -- decided by the generator
    crewId = 3 or nil,        -- specific roster member assigned to this node, if any
    enemies = { ... },
    items   = { ... },
    utility = "microwave" or nil,
    isFinal = false,
  },
  cleared = { ... },  -- runtime deltas (enemies killed, items taken) for revisits
}
```

**Performance rule:** `poolRoom` is a *reference*. The node only stores per-run deltas. No
template is ever deep-copied per node, and generation is single-pass (no retry/backtracking).

---

## 4. LDtk authoring requirements (the room contract)

For a room to be usable as a procedural pool piece it must satisfy:

### 4.1 Identity & eligibility
- `uniqueIdentifer` (iid): stable. Generator and save reference templates by this id.
- New customField `procGen` (bool): only rooms with `procGen = true` enter the pool
  (keeps test/cutscene rooms out).
- New customField `roomRole`: `"normal"` | `"start"` | `"final"`. The generator filters:
  starts in a `start`, reserves `final` rooms for the climax, everything else is `normal`.

### 4.2 Door sides (most important)
- `DoorsConnection` (already exists) **is the connection contract**: it lists every side that
  has a door opening, using cardinal names `"Top" | "Down" | "Left" | "Right"`.
- Golden rule: **the generator may only connect sides listed in `DoorsConnection`.** A room
  that lists only `"Left"` will never get a right-side door, regardless of the art.
- Vertical stairs (`upper`/`lower`) are optional; if declared they are treated as two extra
  directions. The default generator works with the 4 cardinal sides.

### 4.3 Generic spawn markers (replace specific entities)
- `CrewMember` entities become **generic crew spawn markers** (position only). The generator
  assigns a specific `crewId` from the uncollected set at generation time.
- Enemies and items become generic markers (`EnemySpawn`, `ItemSpawn`) with position only
  (plus an optional suggested type). The generator decides what/how much to populate.
- `FeatureSlot` (new, optional): a spot where the generator *may* place a utility
  (microwave/minifier). Since utilities are random, a room with a `FeatureSlot` will sometimes
  have one and sometimes not.
- A room may have several markers of each type; the generator picks a subset.

### 4.4 Self-containment (hard rule)
- A room's content **must not assume a specific neighbour.** Triggers, NPCs and dialogs must be
  room-local or driven by global state (e.g. crew count), never "the right door leads to room X".
- Exported `neighbourLevels` are **ignored** at runtime.

### 4.5 Assets
- Every pool room needs its background PNG at `assets/images/rooms/floor{level}/{identifier}`
  and a tilemap entry (`tile`). `shadow`/`light` are respected as the room's nature (the
  generator may bias toward more dark rooms as progress rises).

---

## 5. The generator (`MapGenerator.lua`)

**Input:** `progress` (= crew recruited), the pool, an RNG seed.
**Output:** `runGraph` (list of nodes as in §3).

**Algorithm (single pass, no retries → cheap):**

1. **Size N** of the run = function of progress (`roomsBase + floor(crewTaken / crewPerExtraRoom)`),
   capped at `roomsMax`. → `Config.MapGen`.
2. **Guaranteed solution path:** pick a `start` room. Repeat until N nodes exist: take the last
   node that still has a free door side, pick a pool room that has the **opposite** side free,
   connect them (consume a door slot on both → bidirectional) and append it.
3. **Loops:** scan pairs of nodes that still have compatible free door sides (one with `right`
   free, another with `left` free) and, with probability `loopChance`, connect them. This
   creates the open graph without breaking solvability (the base path already guarantees
   everything is reachable).
4. **Place content:**
   - **Crew:** `nCrew = ceil(N / roomsPerCrewSpawn)`, bounded by the uncollected roster. Build the set
     of not-yet-recruited crew (`idNumbers[id] ~= true`) and assign a distinct `crewId` from that
     set to `nCrew` random nodes (that have a `CrewMember` marker), never the `start`.
   - **Utilities:** for each node with a `FeatureSlot`, place a microwave/minifier with
     probability `utilityChance`.
   - **Enemies / items:** populate markers per config density.
5. **Final room:** kept hidden/sealed until the last crew is recruited (see §6). The generator
   reserves a connection but does not expose it yet.

---

## 6. Crew (numbered roster) & win condition

**Fixed roster:** `crewId = 1..totalCrew`. Each member has:
- **Own hat** → already produced by `Hats(crewId)` in `crewmember.lua` (no change).
- **Own dialog** → keyed by `crewId`. Because the LDtk marker is generic,
  `CrewMember:returnScript()` stops reading the LDtk entity's `script`/`tinyScript` and instead
  **builds the script name from `crewId`** (e.g. `"crew" .. crewId .. "_tiny"`), pointing to
  entries in `script.lua`. Each number gets a distinct line.

**Identity persists (do NOT remove `idNumbers`):**
- `PlayerData.CrewMemberData.idNumbers[crewId] = true` records which specific members are
  recruited. Persists across runs.
- `amountTaken` remains the fast counter.

**Generator assigns concrete identity:** at population time it draws distinct `crewId`s from the
uncollected set; the `CrewMember` is instantiated with that `crewId` → correct hat and dialog.
A recruited crew member never spawns again.

**Recruit:** `taken()` sets `idNumbers[crewId] = true`, `amountTaken++`, banked instantly.

**Win:** when `amountTaken == totalCrew` → `RunState:revealFinalRoom()`:
- Take a node with a free door side and connect a `final`-role template, adding a door to it.
- Crossing into the final room → closing sequence (existing scene such as `CockpitScene`/
  `CreditsScene`, or a new one). The closing content is a **hook**, defined separately.

**Two dialog layers, both valid:**
1. Per-crew recruitment dialog (keyed by `crewId`) — the distinct line per hat.
2. NPC story dialogs gated by `amountTaken` (see §8) — story progression.

---

## 7. Death & DeadScene

**Death causes** (new field `PlayerData.deathCause`):
- `"hp"` — combat/dance (currently `state.lua:107`).
- `"void"` — falling into the void (currently `state.lua:27`).
- `"sanity"` — **new**: in `sanity.lua`, when `sanity` reaches 0, keep incrementing
  `sanityCounter` (preserved) **and** set `deathCause = "sanity"` + transition to DeadScene.

**DeadScene:**
- Reads `PlayerData.deathCause` → shows a different message/art per cause.
- **Retry** no longer does `RoomTranslate(saveLevel)`: it **starts a new run** → generates a
  fresh `runGraph` (`MapGenerator`) and enters its `start` node. Meta (items/skills/crew/
  `sanityCounter`) persists; the run dies.
- **Exit** → TitleScene (unchanged).

---

## 8. Dialogs gated by crew count

- `npc.lua` (`evaluateCondition`) gains a comparison condition against the crew count, e.g.:
  - `"crew>=3:scriptMid"`, `"crew>=6:scriptLate"`, with the usual `true:scriptFallback` last.
- Evaluated against `PlayerData.CrewMemberData.amountTaken`. Story advances by how much crew you
  carry, without depending on specific rooms (respects the self-containment rule).
- The same parser can gate triggers/cutscenes by progress.

---

## 9. Save system (rewrite, version `"3.0-PROCGEN"`)

- **Removes** all per-iid `levelState` (rooms are ephemeral). This also makes `save()` lighter
  than today (no longer iterates every level + entity).
- **Persists:**
  - `PlayerData` meta: items, skills, `CrewMemberData` (`amountTaken` + `idNumbers`),
    `sanityCounter`, calories, story flags, etc.
  - **Active run** (for quit-and-resume mid-run): the `runGraph` + `currentNode` + per-node
    runtime deltas (enemies killed / items taken). On **death**, the run is discarded (not the
    meta).
  - The run seed (alternative to serializing the full graph; decided in the plan).
- **Delete** → full wipe (already calls `ResetPlayerData`); also clears the saved run.

---

## 10. Config additions

```lua
Config.MapGen = {
    roomsBase         = 5,    -- minimum run size (rooms in the smallest run)
    crewPerExtraRoom  = 1,    -- recruit this many crew to grow the run by +1 room (lower = faster growth)
    roomsMax          = 18,   -- run size cap
    loopChance        = 0.35, -- prob. of closing a loop between two compatible free door sides
    roomsPerCrewSpawn = 4,    -- spawn ~1 crew per this many rooms in a run (crew density)
    utilityChance     = 0.4,  -- prob. of populating a FeatureSlot with a microwave/minifier
    totalCrew         = 12,   -- total roster to recruit to open the final room
    -- enemy/item densities, dark-room bias by progress, etc.
}
```

**Naming note:** the two scaling knobs are intentionally distinct — `crewPerExtraRoom` controls
run **size growth** (how much crew you must recruit to earn one more room), while
`roomsPerCrewSpawn` controls crew **density** (how many crew spawn within a single run).

All tunable values live here (project rule: no hard-coded magic numbers).

---

## 11. Performance budget

- **Per frame:** zero added cost. One room loaded at a time, same sprites/AI as today.
- **Per room load (door transition):** identical to today (PNG + tile colliders + entity spawn).
- **New cost — graph build, once per run** (start / Retry): N = 5–18 nodes; path O(N), loop
  pairing worst case ~O(N²) ≈ 324 trivial table ops; pool selection over ~20–40 templates.
  Estimated ~1–3 ms, one-time, and it happens during the scene transition (masked).
- **Memory:** the pool (`levelsLDTK`) is already resident at boot. The `runGraph` is ~18 small
  tables (a few KB). Save is lighter than today.

**Two rules that keep it cheap (enforced by design):**
1. `node.poolRoom` is a reference; never deep-copy templates per node — store only deltas.
2. Single-pass generation with guaranteed-path-first; never generate-and-retry.

**Verification (in the plan):** wrap generation in `playdate.getElapsedTime()` to measure real
cost in simulator/device and tune `roomsMax` / pool size if needed.

### 📌 Pinned future fallback (out of initial scope)
If generation ever causes a noticeable hitch, **precompute the *next* run's graph during the
DeadScene** (the player is reading the death screen anyway), so Retry is instant. Not part of the
initial implementation — revisit only if measured timing warrants it.

---

## 12. Out of scope (this spec)

- The actual content of the final/closing sequence (hook only).
- New room art/templates authoring (this spec defines the contract; authoring is separate).
- Difficulty/balance tuning beyond exposing the `Config.MapGen` knobs.
```
