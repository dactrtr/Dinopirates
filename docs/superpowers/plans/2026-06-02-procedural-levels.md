# Procedural Level Generation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the game from a fixed LDtk map into a roguelike that generates a fresh room graph each run, with persistent meta-progression (items, skills, numbered crew) and a win condition of recruiting the full crew roster.

**Architecture:** `levelsLDTK` becomes an immutable **pool of room templates**. A `MapGenerator` builds a per-run graph of nodes (each node references a template + per-run content deltas) connected by matching door directions, with loops. `RunState` holds the active graph in memory. A single reused `MazeScene` loads a node at a time; doors transition `MazeScene → MazeScene` by node id. Crew/enemies/items spawn from node content. Death (HP / sanity 0 / void) ends the run; `Retry` regenerates. Save persists meta + the active run, not per-room state.

**Tech Stack:** Panic Playdate SDK, Lua, Noble Engine. No automated test runner — validation is `pdc` compile + manual simulator checks, plus a debug self-check harness for the generator.

### Project rules baked into this plan
- **Never `git commit`.** The user commits manually. There are NO commit steps below.
- **All code, comments, and docs in English** (conversation may be Spanish).
- **No magic numbers in code** — all tunables live in `Config.lua` (`Config.MapGen`).
- **Compile command:** `pdc source "DinoPirates from inner space Brocolation.pdx"` (run from repo root). Expected on success: exit code 0, no `error:` lines.
- **Run command:** `open "DinoPirates from inner space Brocolation.pdx"`.
- Debug mode: System Menu → "debug" or cheat `up up up down`. `printDebug(...)` only prints when `debug == true`.

### Phase order & why
Each phase leaves the game compilable. The risky "big flip" (navigation) is Phase 3, after the generator (Phase 1–2) is built and self-checked in isolation. Spec reference: `docs/superpowers/specs/2026-06-02-procedural-levels-design.md`.

0. Config + data scaffolding
1. MapGenerator + RunState (standalone, debug-validated)
2. Pool authoring contract (LDtk fields + pool helpers)
3. Navigation rework (the flip to node-based MazeScene)
4. Content spawning from nodes
5. Numbered crew + win condition (final room)
6. Death model (sanity death + DeadScene by cause + Retry)
7. Dialogs gated by crew count
8. Save system rewrite

---

## Phase 0 — Config + data scaffolding

### Task 0.1: Add `Config.MapGen`

**Files:**
- Modify: `source/assets/data/Config.lua` (insert a new block; suggested after `Config.Microwave`, ~line 68)

- [ ] **Step 1: Add the config block**

Insert into `source/assets/data/Config.lua`:

```lua
-- Procedural map generation (roguelike run graph)
Config.MapGen = {
    roomsBase         = 5,    -- minimum run size (rooms in the smallest run)
    crewPerExtraRoom  = 1,    -- recruit this many crew to grow the run by +1 room (lower = faster growth)
    roomsMax          = 18,   -- run size cap
    loopChance        = 0.35, -- prob. of closing a loop between two compatible free door sides
    roomsPerCrewSpawn = 4,    -- spawn ~1 crew per this many rooms in a run (crew density)
    utilityChance     = 0.4,  -- prob. of populating a FeatureSlot with a microwave/minifier
    totalCrew         = 12,   -- total roster to recruit to open the final room
    enemyChance       = 0.6,  -- prob. of populating an enemy marker
    itemChance        = 0.5,  -- prob. of populating an item marker
    darkBiasPerCrew   = 0.02, -- added probability that a room renders dark, per crew recruited (capped at 1)
}
```

- [ ] **Step 2: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

### Task 0.2: Add player meta fields for the run loop

**Files:**
- Modify: `source/assets/data/PlayerDataTables.lua` (the `PlayerData` table and, if present, the reset path)

- [ ] **Step 1: Inspect current PlayerData**

Run: `grep -n "deathCause\|CrewMemberData\|sanityCounter\|idNumbers\|amountTaken\|function ResetPlayerData" source/assets/data/PlayerDataTables.lua`
Expected: shows `CrewMemberData`/`sanityCounter` exist; `deathCause` does NOT yet.

- [ ] **Step 2: Add `deathCause` field**

In `source/assets/data/PlayerDataTables.lua`, add to the `PlayerData` table (near `sanityCounter`):

```lua
    deathCause = "hp",   -- "hp" | "sanity" | "void"; set on death, read by DeadScene
```

- [ ] **Step 3: Ensure crew roster fields exist and are reset-safe**

Confirm `CrewMemberData` contains `amountTaken = 0` and `idNumbers = {}`. If `idNumbers` is missing, add it:

```lua
    CrewMemberData = {
        amountTaken = 0,
        idNumbers   = {},   -- [crewId] = true once that specific roster member is recruited
    },
```

If a `ResetPlayerData()` function exists, make sure it resets `deathCause = "hp"`, `CrewMemberData.amountTaken = 0`, and `CrewMemberData.idNumbers = {}`.

- [ ] **Step 4: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

---

## Phase 1 — MapGenerator + RunState (standalone)

This phase builds pure modules with **no gameplay wiring**. Validation is a debug harness that generates a graph and asserts invariants.

### Task 1.1: Create `RunState`

**Files:**
- Create: `source/utilities/RunState.lua`
- Modify: `source/main.lua` (add import after `utilities/SaveSystem`, ~line 10)

- [ ] **Step 1: Create the module**

Create `source/utilities/RunState.lua`:

```lua
-- RunState: in-memory source of truth for the active procedural run.
-- Holds the generated graph, the current node, and a staging field used to pass
-- the destination node across a Noble scene transition (Noble re-instantiates the
-- scene, so we hand off the target via this global instead of constructor args).
RunState = {
    graph         = nil,  -- array of nodes (see MapGenerator); also has .startId / .finalReserved
    currentNodeId = nil,  -- node the player is currently in
    pendingNodeId = nil,  -- node a door transition is heading to; consumed on enter
}

-- Generate a fresh run from current progress (crew recruited).
function RunState.startRun()
    local progress = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0
    RunState.graph = MapGenerator.generate(progress)
    RunState.currentNodeId = nil
    RunState.pendingNodeId = RunState.graph.startId
end

function RunState.getNode(id)
    if not RunState.graph then return nil end
    return RunState.graph[id]
end

function RunState.currentNode()
    return RunState.getNode(RunState.currentNodeId)
end

-- Move the "current" pointer to the pending destination (called when MazeScene enters).
function RunState.consumePending()
    if RunState.pendingNodeId then
        RunState.currentNodeId = RunState.pendingNodeId
        RunState.pendingNodeId = nil
    end
end

-- Queue a destination for the next transition.
function RunState.goTo(nodeId)
    RunState.pendingNodeId = nodeId
end

return RunState
```

- [ ] **Step 2: Import it in main.lua**

In `source/main.lua`, after `import 'utilities/SaveSystem'`, add:

```lua
import 'utilities/MapGenerator'
import 'utilities/RunState'
```

(`MapGenerator` is created in Task 1.2; importing it now will fail to compile until then — do Task 1.2 before compiling.)

### Task 1.2: Create `MapGenerator` core (graph build, no content yet)

**Files:**
- Create: `source/utilities/MapGenerator.lua`

- [ ] **Step 1: Create the module with direction helpers and pool stub**

Create `source/utilities/MapGenerator.lua`:

```lua
-- MapGenerator: builds a per-run graph of room nodes from the pool of LDtk
-- templates. Single pass, no retries: a guaranteed solution path is built first,
-- then optional loop edges are added. Nodes reference templates by value (never
-- deep-copied); per-run data lives in node.content / node.cleared.
MapGenerator = {}

-- Cardinal door directions and their opposites (a "right" door must meet a "left").
local OPPOSITE = { right = "left", left = "right", top = "down", down = "top" }
local DIRS = { "right", "left", "top", "down" }

-- Normalize a DoorsConnection entry ("Top"/"Down"/"Left"/"Right") to a lowercase dir.
local function normDir(name)
    if type(name) ~= "string" then return nil end
    local d = name:lower()
    if OPPOSITE[d] then return d end
    return nil
end

-- Returns the set of cardinal door sides a template declares, as { [dir]=true }.
local function doorSidesOf(template)
    local sides = {}
    local cf = template.customFields or {}
    local list = cf.DoorsConnection or {}
    for _, name in ipairs(list) do
        local d = normDir(name)
        if d then sides[d] = true end
    end
    return sides
end

-- Build the pool from levelsLDTK, grouped by role. Only procGen rooms qualify.
-- Returns { start = {...}, normal = {...}, final = {...} }.
function MapGenerator.buildPool()
    local pool = { start = {}, normal = {}, final = {} }
    for _, tmpl in ipairs(levelsLDTK or {}) do
        local cf = tmpl.customFields or {}
        if cf.procGen == true then
            local role = cf.roomRole or "normal"
            if pool[role] then
                table.insert(pool[role], tmpl)
            end
        end
    end
    return pool
end

-- Create an empty node wrapping a template.
local function makeNode(id, template)
    return {
        id       = id,
        poolRoom = template,                 -- reference, never copied
        edges    = {},                       -- dir -> destination node id
        freeSides = doorSidesOf(template),   -- dir -> true while still unused
        content  = { crewId = nil, enemies = {}, items = {}, utility = nil, isFinal = false },
        cleared  = {},                       -- runtime deltas on revisit
    }
end

-- Pick a random element from a list (returns nil if empty).
local function pickRandom(list)
    if #list == 0 then return nil end
    return list[math.random(1, #list)]
end

-- Connect a.dir <-> b.opposite(dir), consuming a free side on both.
local function connect(a, b, dir)
    local opp = OPPOSITE[dir]
    a.edges[dir] = b.id
    b.edges[opp] = a.id
    a.freeSides[dir] = nil
    b.freeSides[opp] = nil
end

-- Build the run graph for a given progress value.
function MapGenerator.generate(progress)
    progress = progress or 0
    local cfg = Config.MapGen
    local N = math.min(cfg.roomsMax,
                       cfg.roomsBase + math.floor(progress / cfg.crewPerExtraRoom))

    local pool = MapGenerator.buildPool()
    local graph = {}

    -- 1) Start node.
    local startTemplate = pickRandom(pool.start) or pickRandom(pool.normal)
    assert(startTemplate, "MapGenerator: pool has no start/normal rooms (need procGen rooms)")
    local nextId = 1
    local startNode = makeNode(nextId, startTemplate)
    graph[nextId] = startNode
    graph.startId = nextId
    nextId += 1

    -- 2) Guaranteed solution path: extend from a node that still has a free side,
    --    attaching a normal room whose opposite side is free.
    local frontier = { startNode }
    while #graph < N do
        -- find a placed node with at least one free cardinal side
        local fromNode, fromDir
        for _, node in ipairs(frontier) do
            for _, d in ipairs(DIRS) do
                if node.freeSides[d] then fromNode = node; fromDir = d; break end
            end
            if fromNode then break end
        end
        if not fromNode then break end  -- no free sides anywhere; stop early

        local need = OPPOSITE[fromDir]
        -- pick a normal template that has the needed side
        local candidates = {}
        for _, tmpl in ipairs(pool.normal) do
            if doorSidesOf(tmpl)[need] then table.insert(candidates, tmpl) end
        end
        local tmpl = pickRandom(candidates)
        if not tmpl then
            -- no template can satisfy this side; burn it so we don't loop forever
            fromNode.freeSides[fromDir] = nil
        else
            local node = makeNode(nextId, tmpl)
            graph[nextId] = node
            connect(fromNode, node, fromDir)
            table.insert(frontier, node)
            nextId += 1
        end
    end

    -- 3) Loops: connect pairs of placed nodes with compatible free sides.
    local placed = {}
    for i = 1, #graph do placed[i] = graph[i] end
    for _, a in ipairs(placed) do
        for _, d in ipairs(DIRS) do
            if a.freeSides[d] and math.random() < cfg.loopChance then
                local opp = OPPOSITE[d]
                for _, b in ipairs(placed) do
                    if b ~= a and b.freeSides[opp] and not a.edges[d] then
                        connect(a, b, d)
                        break
                    end
                end
            end
        end
    end

    graph.finalReserved = nil  -- set in Phase 5 when content is placed
    return graph
end

return MapGenerator
```

- [ ] **Step 2: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

### Task 1.3: Generator self-check harness (debug-only)

**Files:**
- Modify: `source/utilities/MapGenerator.lua` (add `MapGenerator.selfCheck`)
- Modify: `source/main.lua` (add a System Menu item "gen-test" that runs the self-check)

- [ ] **Step 1: Add the self-check function**

Append to `source/utilities/MapGenerator.lua` (before `return MapGenerator`):

```lua
-- Debug invariant check: generates a graph at a given progress and asserts that
-- every node is reachable from the start and every edge is bidirectional.
-- Prints a summary via printDebug. Returns true on success.
function MapGenerator.selfCheck(progress)
    local graph = MapGenerator.generate(progress or 0)

    -- bidirectional edge check
    for id = 1, #graph do
        local node = graph[id]
        for dir, destId in pairs(node.edges) do
            local opp = ({ right="left", left="right", top="down", down="top" })[dir]
            local dest = graph[destId]
            assert(dest, "edge to missing node " .. tostring(destId))
            assert(dest.edges[opp] == id,
                   "non-bidirectional edge " .. id .. "->" .. destId .. " dir " .. dir)
        end
    end

    -- reachability (BFS from start)
    local seen = { [graph.startId] = true }
    local queue = { graph.startId }
    while #queue > 0 do
        local id = table.remove(queue, 1)
        for _, destId in pairs(graph[id].edges) do
            if not seen[destId] then seen[destId] = true; table.insert(queue, destId) end
        end
    end
    local reached = 0
    for _ in pairs(seen) do reached += 1 end
    assert(reached == #graph,
           "unreachable nodes: reached " .. reached .. " of " .. #graph)

    printDebug("✅ MapGenerator.selfCheck OK — nodes:" .. #graph .. " progress:" .. (progress or 0))
    return true
end
```

- [ ] **Step 2: Add a debug menu trigger**

In `source/main.lua`, after the existing `menu:addMenuItem("debug", ...)` block, add:

```lua
local genItem, genErr = menu:addMenuItem("gen-test", function()
    debug = true
    MapGenerator.selfCheck(0)
    MapGenerator.selfCheck(4)
    MapGenerator.selfCheck(40)  -- exercises the roomsMax cap
end)
```

- [ ] **Step 3: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

- [ ] **Step 4: Validate in simulator**

Run: `open "DinoPirates from inner space Brocolation.pdx"`
In the simulator: open the System Menu, tap **gen-test**. Watch the simulator console.
Expected: three `✅ MapGenerator.selfCheck OK` lines (nodes counts ~5, ~9, ~18) and **no `assertion failed`**. If an assertion fires, the pool/template door sides are inconsistent — see Phase 2 (rooms need `procGen` + valid `DoorsConnection`).

---

## Phase 2 — Pool authoring contract

The generator needs `procGen` / `roomRole` on templates and valid `DoorsConnection`. This phase tags real rooms so the generator runs over actual data.

### Task 2.1: Tag pool rooms in LDtk data

**Files:**
- Modify: `source/assets/data/levels_floor4.lua`, `source/assets/data/levels_floor3.lua`

> The LDtk-exported `.lua` files are the source the game reads. Editing them directly is acceptable for tagging; ideally the same fields are added in the LDtk project and re-exported. The exact fields matter, not where they were authored.

- [ ] **Step 1: Audit which rooms have valid door sides**

Run: `grep -n "identifier = \|DoorsConnection\|roomNumber = " source/assets/data/levels_floor4.lua | head -60`
Expected: a list of rooms with their `DoorsConnection` arrays. Note which rooms have ≥1 cardinal side ("Top"/"Down"/"Left"/"Right").

- [ ] **Step 2: Add `procGen` and `roomRole` to each pool room's `customFields`**

For every room you want in the pool, add to its `customFields` table (alongside `level`, `roomNumber`, `DoorsConnection`):

```lua
    procGen = true,
    roomRole = "normal",   -- or "start" for at least one room, "final" for the ending room
```

Requirements to satisfy (from the spec §4):
- At least **one** room with `roomRole = "start"`.
- At least **one** room with `roomRole = "final"`.
- Every pool room's `DoorsConnection` must list only `"Top" | "Down" | "Left" | "Right"` (cardinal). Remove/convert non-cardinal entries for procGen rooms, or leave them — the generator ignores unknown directions.
- Rooms used only for tests/cutscenes: leave `procGen` absent or `false`.

- [ ] **Step 3: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

- [ ] **Step 4: Validate generation over real pool**

Run: `open "DinoPirates from inner space Brocolation.pdx"`, System Menu → **gen-test**.
Expected: `selfCheck OK` lines, no assertions. If "pool has no start/normal rooms" asserts, no room has `procGen = true`.

### Task 2.2: Marker readers in MapGenerator

**Files:**
- Modify: `source/utilities/MapGenerator.lua`

- [ ] **Step 1: Add marker helpers**

Add to `source/utilities/MapGenerator.lua` (near `doorSidesOf`):

```lua
-- Collect generic spawn markers of a given LDtk entity key from a template.
-- Returns a list of { x=, y=, customFields= } (positions only; identity is assigned
-- by the generator, not authored).
local function markersOf(template, entityKey)
    local out = {}
    local entities = template.entities or {}
    local list = entities[entityKey]
    if list then
        for _, e in ipairs(list) do
            table.insert(out, { x = e.x, y = e.y, customFields = e.customFields or {} })
        end
    end
    return out
end

-- Expose for content placement / scene spawning.
MapGenerator.markersOf = markersOf
```

- [ ] **Step 2: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

---

## Phase 3 — Navigation rework (the flip)

Switch `MazeScene` from Floor-class/`setFloor` to node-based loading, and doors from Floor numbers to node ids. After this phase the game runs on generated maps (content still spawns from the template's own entities until Phase 4).

### Task 3.1: MazeScene loads from the current node

**Files:**
- Modify: `source/scenes/MazeScene.lua` (`scene:enter`, ~lines 100–177; replace `setFloor` usage and the room-resolution at the top of `enter`)

- [ ] **Step 1: Replace `setFloor` with node consumption**

In `source/scenes/MazeScene.lua`, replace the body of `function scene:setFloor(levelNumber, roomNumber)` (lines 88–96) with a node-based setter, and keep the name for minimal churn:

```lua
-- Set the room to load from the active run graph node. Called via RunState before
-- the transition (RunState.goTo) — here we just make the current node authoritative.
function scene:setFloor()
    RunState.consumePending()
end
```

- [ ] **Step 2: Resolve `room`/template from the node in `enter`**

At the top of `scene:enter` (after `scene.super.enter(self)` and the music block, before the `PlayerData.room = ...` lines ~112), insert:

```lua
    RunState.consumePending()
    local node = RunState.currentNode()
    assert(node, "MazeScene:enter with no current node — start a run first")
    local template = node.poolRoom
```

Then replace the existing references that read `levelsLDTK[room]` for metadata (lines ~112–119) with the template:

```lua
    PlayerData.room = template.customFields.roomNumber
    PlayerData.isInDarkness = template.customFields.shadow
    PlayerData.floor = node.id

    PlayerData.actualLevel = template.customFields.level
    PlayerData.actualRoom = template.customFields.roomNumber
    PlayerData.actualTilemap = template.customFields.tile
```

(Remove the `levelsLDTK[room].customFields.visited = true` line — visited tracking is obsolete in procgen.)

- [ ] **Step 3: Point background/foreground/colliders/doors at `template`**

In the same `enter`, change the background path and subsequent `levelsLDTK[room]` reads to use `template`:
- Background (`roomBgPath`, ~122): unchanged path formula, but it already uses `PlayerData.actualLevel` and `levelsLDTK[room].identifier`. Replace `levelsLDTK[room].identifier` with `template.identifier`.
- Foreground block (~131): replace `levelsLDTK[room].customFields.hasForeground` with `template.customFields.hasForeground`.
- Tile colliders (~148): replace `if room and levelsLDTK[room] then` with `if template then`, and pass `tileMapData[PlayerData.actualTilemap]` (unchanged).
- Doors (~157): replace `local currentRoom = levelsLDTK[room]` with `local currentRoom = template` AND replace the door-creation call (see Task 3.2).

- [ ] **Step 4: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors. (Game won't run correctly until Task 3.2–3.4 are done.)

### Task 3.2: Doors created from node edges

**Files:**
- Modify: `source/scenes/MazeScene.lua` (door creation call, ~line 172)
- Modify: `source/entities/props/door.lua` (`init` signature + `goTo`, lines 23–74)

- [ ] **Step 1: New door creation from edges in MazeScene**

Replace the `CreateDoorsFromLDTK(currentRoom)` / `CreatePortalDoorsFromLDTK(currentRoom)` calls (~172–173) with:

```lua
    CreateDoorsFromNode(node)
```

- [ ] **Step 2: Add `CreateDoorsFromNode` in Utilities**

In `source/utilities/Utilities.lua`, add (near the old `CreateDoorsFromLDTK`):

```lua
-- Create door sprites from a run-graph node's edges. Each edge (dir -> destNodeId)
-- becomes a door at the cardinal screen position; crossing it transitions to that node.
function CreateDoorsFromNode(node)
    if not node then return end
    local positions = Config.Doors.positions
    for dir, destNodeId in pairs(node.edges) do
        local pos = positions[dir]
        if pos then
            -- open door (no keys in procgen); destination is a node id
            Door(dir, "open", destNodeId, ZIndex.props, nil, pos.x, pos.y)
        end
    end
end
```

- [ ] **Step 3: Door stores `targetNodeId` and transitions by node**

In `source/entities/props/door.lua`, change `Door:init` (line 23) so the third arg is the destination node id and is stored directly (remove the `RoomTranslate` call at line 25):

```lua
function Door:init(direction, status, targetNodeId, zIndex, keyNumber, x, y, width, height)
  self.targetNodeId = targetNodeId
  self.direction = direction
  self.status = status
  self.keyNumber = keyNumber
```

Replace `Door:goTo` (lines 67–74) with:

```lua
function Door:goTo()
  RunState.goTo(self.targetNodeId)
  Noble.transition(MazeScene, 1.5, Noble.Transition.Default)
end
```

- [ ] **Step 4: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

### Task 3.3: Retire Floors.lua and RoomTranslate

**Files:**
- Modify: `source/main.lua` (remove `import 'scenes/Floors'`, ~line 15)
- Delete: `source/scenes/Floors.lua`
- Modify: `source/utilities/Utilities.lua` (remove `RoomTranslate`, lines 133–136)
- Modify: `source/scenes/DeadScene.lua` (Retry uses RoomTranslate — fixed in Phase 6; for now make it start a run, see Step 3)

- [ ] **Step 1: Remove the import and the file**

In `source/main.lua` delete the line `import 'scenes/Floors'`. Then:
Run: `rm source/scenes/Floors.lua`

- [ ] **Step 2: Remove `RoomTranslate`**

Delete the `RoomTranslate` function (lines 133–136) from `source/utilities/Utilities.lua`.
Run: `grep -rn "RoomTranslate" source/` to find remaining callers.
Expected callers: `DeadScene.lua` (handled next), `door.lua` (already removed in 3.2). Fix any others to not use it.

- [ ] **Step 3: Temporary DeadScene Retry**

In `source/scenes/DeadScene.lua`, replace the Retry handler body (lines 75–79) with:

```lua
	menu:addItem("Retry", function()
		RunState.startRun()
		Noble.transition(MazeScene)
	end)
```

- [ ] **Step 4: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

### Task 3.4: Entry point starts a run

**Files:**
- Modify: `source/scenes/TitleScene.lua` (the New Game / Continue handlers that currently transition into a Floor)

- [ ] **Step 1: Find the gameplay entry transition**

Run: `grep -n "Noble.transition\|Floor\|RoomTranslate\|saveLevel\|MazeScene\|NewGame\|Continue" source/scenes/TitleScene.lua`
Expected: locate where the title starts gameplay (a `Noble.transition` into a Floor class or `RoomTranslate`).

- [ ] **Step 2: Start a run on New Game**

Replace the gameplay-start transition with:

```lua
    RunState.startRun()
    Noble.transition(MazeScene, 0.3, Noble.Transition.MetroNexus)
```

For **Continue**: if a saved run exists it is restored in Phase 8; until then, Continue also calls `RunState.startRun()`. Add a code comment: `-- TODO(Phase 8): restore saved run instead of regenerating`.

- [ ] **Step 3: Compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: exit 0, no errors.

- [ ] **Step 4: Validate navigation in simulator**

Run: `open "DinoPirates from inner space Brocolation.pdx"`. Start a New Game.
Expected: you spawn in a room; doors exist on the sides the room declares; walking through a door loads another room; walking back returns you to a room (graph is navigable). Enable `debug` to see door/node logs. No crash on transitions.

---

## Phase 4 — Content spawning from nodes

Spawn enemies/items/utilities/crew from `node.content` (assigned by the generator) instead of the template's authored entity lists. Crew identity is finalized in Phase 5; here we wire enemy/item/utility population and a placeholder crew spawn.

### Task 4.1: Generator places non-crew content

**Files:**
- Modify: `source/utilities/MapGenerator.lua` (`generate`, after the loops step)

- [ ] **Step 1: Add content placement**

In `MapGenerator.generate`, before `return graph`, insert:

```lua
    -- 4) Place non-crew content per node (markers decide where; config decides whether).
    for id = 1, #graph do
        local node = graph[id]
        local tmpl = node.poolRoom

        for _, m in ipairs(markersOf(tmpl, "EnemySpawn")) do
            if math.random() < cfg.enemyChance then
                table.insert(node.content.enemies, { x = m.x, y = m.y, type = m.customFields.type })
            end
        end
        for _, m in ipairs(markersOf(tmpl, "ItemSpawn")) do
            if math.random() < cfg.itemChance then
                table.insert(node.content.items, { x = m.x, y = m.y, type = m.customFields.type })
            end
        end
        local slots = markersOf(tmpl, "FeatureSlot")
        if #slots > 0 and math.random() < cfg.utilityChance then
            local slot = slots[math.random(1, #slots)]
            node.content.utility = { x = slot.x, y = slot.y,
                                     type = slot.customFields.type or "microwave" }
        end
    end
```

- [ ] **Step 2: Compile + self-check**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"` (expect exit 0), then simulator → **gen-test** (expect `selfCheck OK`, no assertions).

### Task 4.2: MazeScene spawns from node content

**Files:**
- Modify: `source/scenes/MazeScene.lua` (the Props/Items/Enemies/CrewMember/NPC/Trigger spawn blocks, lines 181–371)

- [ ] **Step 1: Replace enemy spawning**

Replace the `-- MARK: Enemies` block (lines 298–320) with a node-content version:

```lua
	-- MARK: Enemies (from node content)
	for _, e in ipairs(node.content.enemies) do
		if not (node.cleared.enemies and node.cleared.enemies[e.x .. "," .. e.y]) then
			Brocorat(e.x, e.y, e.type and tonumber(e.type) or 1, ZIndex.enemy, player, node.id .. "-" .. e.x .. "-" .. e.y)
		end
	end
```

- [ ] **Step 2: Replace item spawning**

Replace the `-- MARK: Items` block (lines 202–259) with:

```lua
	-- MARK: Items (from node content)
	for _, it in ipairs(node.content.items) do
		local key = node.id .. "-item-" .. it.x .. "-" .. it.y
		if not (node.cleared.items and node.cleared.items[key]) then
			Items(it.x, it.y, (it.type or "food"):lower(), nil, nil, key)
		end
	end
```

- [ ] **Step 3: Replace utility (microwave/minifier) spawning**

Where props are spawned (the `-- MARK: Props` block ~181–200), after it add:

```lua
	-- MARK: Utility (from node content)
	if node.content.utility then
		local u = node.content.utility
		PropItem(u.x, u.y, u.type, ZIndex.props, false, false, node.id .. "-util")
	end
```

(Keep template-authored static props if any rooms still rely on them; otherwise the Props block can read from a `Prop` marker list instead. For now, leave the existing Props block but guard it so it only runs for entities the template actually has.)

- [ ] **Step 4: Crew placeholder spawn (identity wired in Phase 5)**

Replace the `-- MARK: Crew members` block (lines 322–339) with:

```lua
	-- MARK: Crew (identity assigned by generator; see Phase 5)
	if node.content.crewId and not node.cleared.crewTaken then
		local cm = markersOf and nil  -- placeholder; real marker chosen in Phase 5
	end
```

(This is intentionally inert until Phase 5 Task 5.2 fills it in.)

- [ ] **Step 5: NPC + Triggers**

Leave the NPC and Triggers blocks reading from `template.entities` (they are room-local content authored in the template). Replace `levelsLDTK[room]` with `template` in those two blocks (lines 343–371).

- [ ] **Step 6: Compile + validate**

Run: `pdc ...` (exit 0). Then simulator: New Game, walk the map.
Expected: enemies/items/utilities appear in some rooms and not others (random per run); revisiting a room you cleared does not respawn killed enemies / taken items (uses `node.cleared`). Re-rolling a New Game produces a different layout/content.

### Task 4.3: Persist clears into the node on the way out

**Files:**
- Modify: `source/scenes/MazeScene.lua` (`scene:exit`, ~451; or the kill/pickup paths)

- [ ] **Step 1: Record clears**

The simplest reliable point: when an enemy dies or an item is picked up, mark the node. In the enemy death handler and item pickup handler, set:

```lua
	local node = RunState.currentNode()
	node.cleared.enemies = node.cleared.enemies or {}
	node.cleared.enemies[key] = true   -- key as constructed at spawn
```

(Use the same `key` string built at spawn in Task 4.2. For items use `node.cleared.items[key] = true`.)

- [ ] **Step 2: Compile + validate**

Run: `pdc ...` (exit 0). Simulator: kill an enemy, leave the room, come back — it stays dead. Pick up an item, return — it's gone.

---

## Phase 5 — Numbered crew + win condition

### Task 5.1: Generator assigns crew identities from the uncollected roster

**Files:**
- Modify: `source/utilities/MapGenerator.lua` (`generate`, in the content step)

- [ ] **Step 1: Build uncollected roster and assign**

In `MapGenerator.generate`, before `return graph`, after the non-crew content step, add:

```lua
    -- Crew: assign specific uncollected crewIds to eligible nodes (nodes that have a
    -- CrewMember marker and are not the start). Count scales with run size.
    local taken = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.idNumbers) or {}
    local uncollected = {}
    for crewId = 1, cfg.totalCrew do
        if not taken[crewId] then table.insert(uncollected, crewId) end
    end

    local nCrew = math.ceil(#graph / cfg.roomsPerCrewSpawn)
    nCrew = math.min(nCrew, #uncollected)

    local eligible = {}
    for id = 1, #graph do
        local node = graph[id]
        if id ~= graph.startId and #markersOf(node.poolRoom, "CrewMember") > 0 then
            table.insert(eligible, node)
        end
    end

    -- shuffle eligible (Fisher-Yates) and assign nCrew distinct crewIds
    for i = #eligible, 2, -1 do
        local j = math.random(1, i)
        eligible[i], eligible[j] = eligible[j], eligible[i]
    end
    for i = 1, nCrew do
        local node = eligible[i]
        if not node then break end
        local crewId = table.remove(uncollected, math.random(1, #uncollected))
        node.content.crewId = crewId
        -- remember the marker position to spawn at
        local markers = markersOf(node.poolRoom, "CrewMember")
        local mk = markers[math.random(1, #markers)]
        node.content.crewSpawn = { x = mk.x, y = mk.y }
    end
```

- [ ] **Step 2: Compile + self-check**

Run: `pdc ...` (exit 0). Simulator → **gen-test** (no assertions).

### Task 5.2: MazeScene spawns the assigned crew member

**Files:**
- Modify: `source/scenes/MazeScene.lua` (the crew block from Task 4.2 Step 4)

- [ ] **Step 1: Spawn with the assigned crewId**

Replace the inert crew placeholder with:

```lua
	-- MARK: Crew (assigned identity → correct hat + dialog)
	if node.content.crewId and not node.cleared.crewTaken then
		local cs = node.content.crewSpawn or { x = 200, y = 120 }
		CrewMember(cs.x, cs.y, Config.CrewMember.defaultSpeed or 1.5, ZIndex.enemy,
		           player, "node" .. node.id .. "-crew", node.id, node.content.crewId)
	end
```

(If `Config.CrewMember.defaultSpeed` does not exist, add `defaultSpeed = 1.5` to `Config.CrewMember`.)

- [ ] **Step 2: Compile + validate**

Run: `pdc ...` (exit 0). Simulator: find a room with a crew member; confirm the hat matches the assigned id. (Dialog correctness comes next.)

### Task 5.3: Crew dialog by id, banking, and clear-on-take

**Files:**
- Modify: `source/entities/enemies/crewmember.lua` (`returnScript` lines 307–335, `taken` lines 337–368)

- [ ] **Step 1: Dialog from crewId**

Replace `CrewMember:returnScript` (lines 307–335) with:

```lua
function CrewMember:returnScript()
    -- Marker is generic in procgen: the dialog is keyed by the assigned crewId.
    return self.crewId and ("crew" .. self.crewId .. "_tiny") or "default_tiny"
end
```

- [ ] **Step 2: Banking + mark node cleared**

Replace `CrewMember:taken` (lines 337–368) with:

```lua
function CrewMember:taken()
	if self.crewId then
		PlayerData.CrewMemberData.idNumbers[self.crewId] = true
	end
	PlayerData.CrewMemberData.amountTaken += 1

	local node = RunState.currentNode()
	if node then node.cleared.crewTaken = true end

	if self.player then
		self.player.hasProjectile = true
	end

	-- Win condition: full roster recruited → open the final room this run.
	if PlayerData.CrewMemberData.amountTaken >= Config.MapGen.totalCrew then
		RunState.revealFinalRoom()
	end

	self:remove()
end
```

- [ ] **Step 3: Add crew dialog entries**

In `source/assets/data/script.lua`, add one entry per roster member used in testing, e.g. `crew1_tiny`, `crew2_tiny`, … following the existing script entry format. At minimum add `crew1_tiny` and a `default_tiny` fallback.

- [ ] **Step 4: Compile + validate**

Run: `pdc ...` (exit 0). Simulator: recruit a crew member; confirm the dialog matches its id, and the crew counter (HUD/`amountTaken`) increases and persists if you re-enter the room (it does not respawn).

### Task 5.4: `RunState.revealFinalRoom`

**Files:**
- Modify: `source/utilities/RunState.lua`

- [ ] **Step 1: Implement reveal**

Add to `source/utilities/RunState.lua` (before `return RunState`):

```lua
-- Attach the final room to the graph once the full roster is recruited. Finds any
-- node with a free door side, creates a final node, and connects it. The new door
-- appears next time the player enters that node.
function RunState.revealFinalRoom()
    if not RunState.graph or RunState.graph.finalReserved then return end

    local OPPOSITE = { right="left", left="right", top="down", down="top" }
    local DIRS = { "right", "left", "top", "down" }

    -- pick a final template
    local pool = MapGenerator.buildPool()
    local finalTemplate = pool.final[1]
    if not finalTemplate then
        printDebug("⚠️ revealFinalRoom: no roomRole='final' template in pool")
        return
    end

    -- find a host node with a free side
    for id = 1, #RunState.graph do
        local host = RunState.graph[id]
        for _, d in ipairs(DIRS) do
            if host.freeSides[d] then
                local newId = #RunState.graph + 1
                local finalNode = {
                    id = newId, poolRoom = finalTemplate, edges = {},
                    freeSides = {}, content = { isFinal = true }, cleared = {},
                }
                host.edges[d] = newId
                finalNode.edges[OPPOSITE[d]] = id
                host.freeSides[d] = nil
                RunState.graph[newId] = finalNode
                RunState.graph.finalReserved = newId
                printDebug("🏁 Final room revealed as node " .. newId)
                return
            end
        end
    end
    printDebug("⚠️ revealFinalRoom: no free door side to attach the final room")
end
```

- [ ] **Step 2: Final room entry hook in MazeScene**

In `scene:enter`, after `local node = RunState.currentNode()`, add:

```lua
    if node.content and node.content.isFinal then
        -- Endgame hook: transition to the closing sequence. Swap CreditsScene for the
        -- real ending scene when authored.
        Noble.transition(CreditsScene, 1.0, Noble.Transition.Default)
        return
    end
```

- [ ] **Step 3: Compile + validate**

Run: `pdc ...` (exit 0). To validate without recruiting 12 crew, temporarily set `Config.MapGen.totalCrew = 1`, recruit one crew, confirm `🏁 Final room revealed`, find the new door, enter it, and confirm the closing scene triggers. **Restore `totalCrew = 12` afterward.**

---

## Phase 6 — Death model

### Task 6.1: Sanity 0 triggers death with cause

**Files:**
- Modify: `source/entities/player/sanity.lua` (`checkSanity`, lines 11–17)
- Modify: `source/entities/player/state.lua` (set `deathCause` on the existing HP/void deaths, lines 27 and 107)

- [ ] **Step 1: Sanity death**

In `source/entities/player/sanity.lua`, inside `checkSanity`, replace the block at lines 11–17 with:

```lua
    -- Check if sanity just reached zero
    if PlayerData.sanity <= 0 and lastSanity > 0 then
      PlayerData.sanityCounter += 1   -- preserved: still scales difficulty
      PlayerData.sanity = 0
      Utilities.checkSanityAchievements()
      PlayerData.deathCause = "sanity"
      PlayerData.isGaming = false
      Noble.transition(DeadScene, 1.5, Noble.Transition.Default)
      return
    end
```

- [ ] **Step 2: Tag HP and void deaths**

In `source/entities/player/state.lua`:
- At the void-death path (~line 27, before the `Noble.transition(DeadScene...)`), add: `PlayerData.deathCause = "void"`.
- At the HP/dance death path (~line 107, before `Noble.transition(DeadScene)`), add: `PlayerData.deathCause = "hp"`.

- [ ] **Step 3: Compile**

Run: `pdc ...`
Expected: exit 0.

### Task 6.2: DeadScene message by cause; Retry already starts a run

**Files:**
- Modify: `source/scenes/DeadScene.lua` (`scene:update` draw, lines 99–109)

- [ ] **Step 1: Branch the message**

In `source/scenes/DeadScene.lua` `scene:update`, replace the hard-coded `drawText` (line 105) with a cause-based message:

```lua
		local msg = "you died"
		if PlayerData.deathCause == "sanity" then
			msg = "you lost your mind"
		elseif PlayerData.deathCause == "void" then
			msg = "you fell into the void"
		elseif PlayerData.deathCause == "hp" then
			msg = "they caught you"
		end
		Graphics.drawText(msg, 2, 220)
```

(Keep the Japanese line if desired, or replace it. Use the project font already set globally.)

- [ ] **Step 2: Confirm Retry**

Confirm the Retry handler (edited in Task 3.3) reads:

```lua
	menu:addItem("Retry", function()
		RunState.startRun()
		Noble.transition(MazeScene)
	end)
```

- [ ] **Step 3: Compile + validate**

Run: `pdc ...` (exit 0). Simulator: die three ways — let sanity hit 0 (dark room, drained battery), get caught by an enemy, fall into a hole — and confirm each shows the matching message. Retry produces a fresh map.

---

## Phase 7 — Dialogs gated by crew count

### Task 7.1: NPC crew-count condition

**Files:**
- Modify: `source/entities/props/npc.lua` (`evaluateCondition`, ~line 105)

- [ ] **Step 1: Parse `crew>=N` conditions**

In `source/entities/props/npc.lua` `evaluateCondition`, before the existing `if conditionExpr == "true" then return true end` (line 105), add:

```lua
	-- Crew-count gate: "crew>=N", "crew>N", "crew==N", "crew<N", "crew<=N"
	local op, num = string.match(conditionExpr, "^crew(>=?|<=?|==)(%d+)$")
	if op and num then
		local count = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0
		num = tonumber(num)
		if op == ">=" then return count >= num end
		if op == ">"  then return count >  num end
		if op == "<=" then return count <= num end
		if op == "<"  then return count <  num end
		if op == "==" then return count == num end
	end
```

(If the existing parser splits on `:` first, ensure this runs on the `conditionExpr` portion only, matching the established split.)

- [ ] **Step 2: Add a test dialog gate**

Pick a test NPC in a pool room and set its `conditionalScripts` to e.g.:

```lua
{ "crew>=2:reachComputer", "true:catWhat" }
```

- [ ] **Step 3: Compile + validate**

Run: `pdc ...` (exit 0). Simulator: with <2 crew the NPC shows `catWhat`; after recruiting 2, it shows `reachComputer`.

---

## Phase 8 — Save system rewrite

### Task 8.1: Persist meta + active run; drop levelState

**Files:**
- Modify: `source/utilities/SaveSystem.lua` (`save`, `load`, `getLevelState`/`restoreLevelState` removal, `delete`)

- [ ] **Step 1: New save payload**

In `source/utilities/SaveSystem.lua`, replace `SaveSystem.save` (lines 185–222) with:

```lua
function SaveSystem.save()
    local saveData = {
        player    = PlayerData,
        run       = RunState.graph and {
            graph         = RunState.graph,
            currentNodeId = RunState.currentNodeId,
        } or nil,
        timestamp = playdate.getTime(),
        version   = "3.0-PROCGEN",
    }
    local success = playdate.datastore.write(saveData, 'gameState', true)
    if success ~= false then
        printDebug("💾 Game saved (3.0-PROCGEN)")
        return true
    end
    printDebug("❌ Failed to save game")
    return false
end
```

> Note: `RunState.graph` contains template references (`poolRoom`). `playdate.datastore.write` serializes plain tables; a reference to a `levelsLDTK` entry will be written by value. To keep saves small and avoid duplicating templates, in Step 2 we strip `poolRoom` to its `uniqueIdentifer` on save and re-link on load.

- [ ] **Step 2: Strip/relink template references**

Add two helpers in `source/utilities/SaveSystem.lua`:

```lua
-- Replace each node.poolRoom (a template ref) with its uniqueIdentifer for saving.
local function serializeGraph(graph)
    local out = { startId = graph.startId, finalReserved = graph.finalReserved }
    for id = 1, #graph do
        local n = graph[id]
        out[id] = {
            id = n.id, edges = n.edges, freeSides = n.freeSides,
            content = n.content, cleared = n.cleared,
            poolIid = n.poolRoom and n.poolRoom.uniqueIdentifer or nil,
        }
    end
    return out
end

-- Re-link poolIid back to the live template via roomsByIid.
local function deserializeGraph(saved)
    if not saved then return nil end
    local graph = { startId = saved.startId, finalReserved = saved.finalReserved }
    for id = 1, #saved do
        local s = saved[id]
        s.poolRoom = s.poolIid and roomsByIid[s.poolIid] or nil
        s.poolIid = nil
        graph[id] = s
    end
    return graph
end
```

Then in `SaveSystem.save`, change `graph = RunState.graph` to `graph = serializeGraph(RunState.graph)`.

- [ ] **Step 3: New load**

Replace `SaveSystem.load` (lines 230–267) with:

```lua
function SaveSystem.load()
    local saveData = playdate.datastore.read('gameState')
    if not saveData then
        printDebug("🔭 No save file found")
        return false, nil
    end
    if saveData.version ~= "3.0-PROCGEN" then
        printDebug("⚠️ Incompatible save version; ignoring")
        return false, nil
    end
    PlayerData = saveData.player
    if saveData.run then
        RunState.graph = deserializeGraph(saveData.run.graph)
        RunState.currentNodeId = saveData.run.currentNodeId
        RunState.pendingNodeId = saveData.run.currentNodeId
    end
    return true, nil
end
```

- [ ] **Step 4: Remove obsolete functions**

Delete `SaveSystem.getLevelState` (lines 9–77) and `SaveSystem.restoreLevelState` (lines 85–177). Run `grep -rn "getLevelState\|restoreLevelState" source/` and remove any remaining callers.

- [ ] **Step 5: Delete wipes run too**

In `SaveSystem.delete`, after `ResetPlayerData()`, add:

```lua
    RunState.graph = nil
    RunState.currentNodeId = nil
    RunState.pendingNodeId = nil
```

- [ ] **Step 6: Continue restores the run**

In `source/scenes/TitleScene.lua`, replace the Phase-3 TODO so Continue restores: if `SaveSystem.load()` returned a run (`RunState.graph ~= nil`), `Noble.transition(MazeScene)` without regenerating; otherwise `RunState.startRun()` first.

- [ ] **Step 7: Compile + validate**

Run: `pdc ...` (exit 0). Simulator:
1. New Game, recruit a crew, walk into a couple of rooms, then quit (System Menu → Title).
2. Continue → you resume the SAME run/map at the same node, with the crew still banked.
3. Die → Retry → new map, but crew/items/skills persist.
4. Delete save (Title flow) → everything resets to zero.

---

## Self-Review (completed by plan author)

**Spec coverage:**
- §2 core loop → Phases 3,5,6 (run start, win, death). ✓
- §3 modules/navigation → Phases 1,3. ✓
- §4 LDtk contract → Phase 2 (tagging) + generator readers. ✓
- §5 generator algorithm → Phase 1 (path+loops) + Phase 4 (content) + Phase 5 (crew). ✓
- §6 numbered crew + win → Phase 5. ✓
- §7 death + DeadScene → Phase 6. ✓
- §8 dialogs by crew count → Phase 7. ✓
- §9 save rewrite → Phase 8. ✓
- §10 Config.MapGen → Phase 0. ✓
- §11 performance (reference-not-copy, single-pass) → enforced in MapGenerator design; timing harness available via gen-test. ✓
- §11 pinned fallback (precompute during DeadScene) → intentionally out of scope; revisit only if timing warrants.

**Type/name consistency:** `RunState.goTo`/`consumePending`/`currentNode`/`startRun`/`revealFinalRoom`; `MapGenerator.generate`/`buildPool`/`markersOf`/`selfCheck`; node fields `poolRoom`/`edges`/`freeSides`/`content`/`cleared`; `content.crewId`/`crewSpawn`/`enemies`/`items`/`utility`/`isFinal`. Door third arg is `targetNodeId` everywhere. `Config.MapGen` keys match across Phase 0 and usages.

**Open items to confirm during execution (not blockers):**
- Exact line numbers drift as edits land — always re-grep before editing.
- `TitleScene.lua` entry transition shape is confirmed by grep in Task 3.4 Step 1.
- Enemy death / item pickup handler locations (Task 4.3) are found by grep; the `key` string must match the spawn-time key exactly.
- If the existing `npc.lua` condition parser pre-splits on `:`, slot the `crew>=N` parse into the same place.
```
