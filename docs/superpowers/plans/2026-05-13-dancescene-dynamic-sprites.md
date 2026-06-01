# DanceScene Dynamic Sprites Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow DanceScene to render alternate sprites for the player and enemy based on `PlayerData.isTiny` and `PlayerData.lastEnemyTouched.type`.

**Architecture:** Add an optional `spritePath` parameter to both `PlayerDance` and `EnemyRatDance` constructors. `DanceScene:enter()` resolves the correct path from `PlayerData` before constructing either sprite. No new files, no new state.

**Tech Stack:** Lua, Playdate SDK, Noble Engine. No test runner — validate by compiling with `pdc` and running in the simulator.

> **Note:** Per project rules, do NOT run `git commit` at any point. The user commits manually.

---

### Task 1: Parametrize `PlayerDance` constructor

**Files:**
- Modify: `source/entities/UI/battle/playerDance.lua`

- [ ] **Step 1: Add `spritePath` parameter to `PlayerDance:init`**

Open `source/entities/UI/battle/playerDance.lua`. Change line 4–5 from:

```lua
function PlayerDance:init(bpm)
	PlayerDance.super.init(self, 'assets/images/ui/battle/playerDance',true)
```

to:

```lua
function PlayerDance:init(bpm, spritePath)
	PlayerDance.super.init(self, spritePath or 'assets/images/ui/battle/playerDance', true)
```

Everything else in the file stays exactly as-is.

- [ ] **Step 2: Compile to verify no syntax errors**

```bash
cd /Users/dactrtr-mini/Documents/GitHub/Dinopirates
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: compiles with no errors. If it errors, check the line edit above for a stray comma or missing quote.

---

### Task 2: Parametrize `EnemyRatDance` constructor

**Files:**
- Modify: `source/entities/UI/battle/enemyRatDance.lua`

- [ ] **Step 1: Add `spritePath` parameter to `EnemyRatDance:init`**

Open `source/entities/UI/battle/enemyRatDance.lua`. Change line 4–5 from:

```lua
function EnemyRatDance:init(bpm, evolveType, isEvolving)
	EnemyRatDance.super.init(self, 'assets/images/ui/battle/enemyDance',true)
```

to:

```lua
function EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)
	EnemyRatDance.super.init(self, spritePath or 'assets/images/ui/battle/enemyDance', true)
```

Everything else in the file stays exactly as-is.

- [ ] **Step 2: Compile to verify no syntax errors**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: compiles with no errors.

---

### Task 3: Wire path resolution in `DanceScene:enter()`

**Files:**
- Modify: `source/scenes/DanceScene.lua`

- [ ] **Step 1: Replace the `playerDance` and `enemyDance` construction lines in `enter()`**

Open `source/scenes/DanceScene.lua`. Find these two lines inside `scene:enter()` (around line 204–205):

```lua
    playerDance = PlayerDance(self.bpm)
    enemyDance = EnemyRatDance(self.bpm, self.enemyType, self.enemyEvolving)
```

Replace them with:

```lua
    local charPath = PlayerData.isTiny
        and 'assets/images/ui/battle/playerDanceTiny'
        or  'assets/images/ui/battle/playerDance'
    playerDance = PlayerDance(self.bpm, charPath)

    local enemyPath = (PlayerData.lastEnemyTouched and PlayerData.lastEnemyTouched.type == "bosscolli")
        and 'assets/images/ui/battle/enemyBosscolliDance'
        or  'assets/images/ui/battle/enemyDance'
    enemyDance = EnemyRatDance(self.bpm, self.enemyType, self.enemyEvolving, enemyPath)
```

> Replace `"bosscolli"` with the actual string value that appears in `PlayerData.lastEnemyTouched.type` for the alternate enemy. The rest of the string is an example name — update the asset paths to match whatever the real spritesheet filenames will be.

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Expected: no errors.

- [ ] **Step 3: Verify default behavior in simulator**

Open the simulator:

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

Start a normal run with `PlayerData.isTiny == false` (default). Trigger a combat encounter. Confirm:
- Player sprite renders as normal (same as before)
- Enemy sprite renders as normal (same as before)
- All dance animations work (jump, crouch, left, right)

- [ ] **Step 4: Verify tiny player path in simulator**

In `source/assets/data/PlayerDataTables.lua`, temporarily set:

```lua
isTiny = true,
```

Compile and run. Trigger combat. Expected: the game loads without crashing. Since `playerDanceTiny` asset doesn't exist yet, Noble Engine will either show a blank sprite or log an asset-not-found error — **this is expected**. The point is that the path resolution code runs without a Lua error.

Revert `isTiny` back to `false` after verifying.

---

### Task 4: Asset integration (when sprites are ready)

**Files:**
- Add: `source/assets/images/ui/battle/playerDanceTiny-table-246-214.png`
- Add: `source/assets/images/ui/battle/enemyBosscolliDance-table-211-214.png` *(name TBD)*

- [ ] **Step 1: Place the player tiny spritesheet**

Drop the finished `playerDanceTiny-table-246-214.png` into `source/assets/images/ui/battle/`. The filename format `<name>-table-<w>-<h>.png` is required by the Playdate SDK for image tables — do not rename it.

Required frame layout (246×214 canvas, 24 frames total):

| State  | Frames |
|--------|--------|
| idle   | 1–5    |
| jump   | 5–9    |
| crouch | 11–15  |
| left   | 16–20  |
| right  | 21–24  |

- [ ] **Step 2: Place the enemy alternate spritesheet**

Drop the finished enemy spritesheet into `source/assets/images/ui/battle/`. Update the path string in `DanceScene:enter()` (Task 3, Step 1) to match the actual filename if it differs from `enemyBosscolliDance`.

Required frame layout (214×214 canvas, 33 frames total):

| State       | Frames |
|-------------|--------|
| idle        | 1–5    |
| upAttack    | 6–9    |
| leftAttack  | 10–13  |
| rightAttack | 14–17  |
| downAttack  | 18–21  |
| bButton     | 22–25  |
| aButton     | 26–29  |
| evolving    | 30–33  |

- [ ] **Step 3: Full verify in simulator**

Set `isTiny = true` in `PlayerDataTables.lua` and trigger a combat encounter. Confirm:
- Tiny player sprite renders at position (0, 26)
- All dance animations play correctly

Revert `isTiny` back to `false`.

Trigger a combat with the alternate enemy type. Confirm:
- Alternate enemy sprite renders at position (158, 26)
- All attack animations play correctly

