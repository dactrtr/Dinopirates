# Love2D Port — Update Log

Running changelog of gameplay/engine changes made in the Playdate project that the
Love2D port must mirror. Newest entries on top. Each entry says **what changed**, **why**,
**which files** (Playdate side), and **how it maps to Love2D**.

This complements [LOVE2D_PORT.md](LOVE2D_PORT.md) (the full port guide) and
[PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md) — when an entry touches the run graph
or door flow, those documents are the authoritative model.

---

## 2026-08-14 — Feature: DanceScene accuracy pop-up (MISS / GOOD / PERFECT)

**What:** A new `AccuracyIndicator` sprite flashes a rating on every button press during the
rhythm combat. It uses one imagetable (`accuracyIndicator-table-400-240`, 20 frames, 5×4):
frames 1–6 = MISS, 7–12 = GOOD, 13–18 = PERFECT, 19–20 = blank. Each rating is a 6-frame
animation band that plays once (`loop = false`) then transitions to the blank `hidden` state,
so the pop-up flashes and disappears. On a correct press the scene picks PERFECT when
`self.accuracy >= Config.Dance.accuracyPerfectMin` (deeper in the hit window), else GOOD; a
wrong-button press shows MISS, and so does a button that scrolls off the left edge unpressed
(`ButtonPress.missedPass`, polled and cleared each frame in `DanceScene:update`).

**Why:** Requested visual feedback for press timing.

**Files (Playdate):** new `entities/UI/battle/accuracyIndicator.lua`;
`scenes/DanceScene.lua` (import, file-scoped ref, instantiate in `enter()`, `:remove()` in
`exit()`, `:show(rating)` calls in `update()`); `entities/UI/battle/buttonPress.lua`
(`missedPass` flag set when a button wraps at `x <= 32`); `assets/data/Config.lua`
(`Config.Dance.accuracyFrameDuration`, `Config.Dance.accuracyPerfectMin`).

**Love2D mapping:** Full-screen (400×240) overlay drawn on top of the dancers. Model the three
rating bands as one-shot animations over the same spritesheet (6 frames each,
`accuracyFrameDuration` ticks/frame) that revert to an invisible/blank frame on completion.
Trigger from the same press-resolution branches: correct press → good/perfect by the accuracy
counter threshold, wrong press → miss, and a note/button that leaves the hit window unpressed →
miss. Note Noble's `animation.next` must reference the state *object* (not its name string)
because the engine dereferences `next.startFrame`.

---

## 2026-08-08 — Feature: Ghost is incorporeal (phases through everything but walls)

**What:** `Ghost:collisionResponse` now returns `'overlap'` for everything except walls (`Box`),
which stay `'slide'`. The ghost drifts through props, items, enemies, and other crew, and passes
over holes; only walls stop it.

**Why:** Requested ghost feel — incorporeal. Holes need no code: hole tiles are walkable
(`WALKABLE_TILES`), so `CreateTileColliders` never puts a collider there and the ghost already
drifts over them. Player contact still banishes via the player's own `collisionResponse` (invoked
from the inherited `moveCollision`), so `'overlap'` doesn't break banishing.

**Files (Playdate side):** `source/entities/enemies/ghost.lua` — added `Ghost:collisionResponse`.

**Love2D mapping:** Mirror in the port: the ghost's collision resolver blocks only on wall tiles;
all other overlaps are pass-through and non-blocking.

**Also — vanish animation (touch AND sanity recovery):** the ghost never disappears instantly.
A shared `Ghost:beginVanish()` becomes untouchable (collide rect zeroed), stops fleeing, and plays
a `vanish` animation state (same frames as CrewMember's `stunned`, `loop=false`, with an
`onComplete` that removes the ghost exactly once — guarded, since onComplete re-fires every frame
at the end). Two triggers: (1) `Ghost:banish()` (player touch) counts the banish then calls
beginVanish; (2) `Ghost:update` calls beginVanish when sanity recovers **above** the threshold
**while the ghost is currently manifested** (`isVisible()`) — this fade is NOT counted. A ghost that
never manifested (still hidden since spawn) just stays dormant; it does not vanish on spawn.
`Ghost:update` early-returns while `isVanishing` so the sanity gate/flee AI don't interfere; the
sprite still advances the animation via `NobleSprite:draw`. Port mapping: one-shot vanish animation
on both triggers, removal deferred to its completion callback (fired once).

Also added `CrewMember:drawDebug` (omnidirectional vision circle + state label; inherited by
Ghost, gated on visibility) and wired `MazeScene`'s debug overlay to draw it for `CrewMember` too.

---

## 2026-08-08 — Fix: CrewMember `forceSpawn` honored in map generation

**What:** A `CrewMember` LDtk marker with `customFields.forceSpawn == true` now guarantees a
crew member is assigned to that node (given the node is part of the run), instead of being
subject to the random `nCrew` distribution like every other crew marker.

**Why:** `forceSpawn` was already honored for enemies (`Brocorat`/`Bosscolli`) and utilities
(`Microwave`/`Minifier`) in `MapGenerator.generate()`, but the crew-assignment block ignored
it entirely — crew markers were treated as generic spawn points and only the first `nCrew`
shuffled eligible nodes received crew. A forced crew room (e.g. room 20) therefore often got
no crew. `markersOf` already preserved `customFields`; nothing was reading it.

**Files (Playdate side):** `source/utilities/MapGenerator.lua` — the crew block splits eligible
nodes into `forced` (any CrewMember marker with `forceSpawn == true`) and `optional`. Forced
nodes are assigned first at their forced marker (guaranteed, not counted against the cap);
`nCrew = max(desired - forcedAssigned, 0)` random slots then fill from the optional nodes.
Roster identities are still consumed from `uncollected`; if the roster is exhausted a forced
node gets nothing (expected). Also: `MapGenerator.debugRoomGraph` (TitleScene PLAYGROUND) never
assigned crew at all — it now force-spawns crew when the room has a CrewMember marker (mirroring
its force-all enemies/utilities), so authored crew rooms can be tested in isolation.

**Love2D mapping:** Mirror the same forced/optional split in the port's map generator. Semantics:
forceSpawn on a crew marker = "if this room is in the run, always place crew here" — it does NOT
force the room into the graph (identical to enemy/utility forceSpawn).

---

## 2026-08-07 — Feature: Ghost entity (sanity-gated CrewMember subclass)

**What:** New `Ghost` entity — a subclass of `CrewMember` that is only **visible and touchable
when `PlayerData.sanity < Config.Ghost.revealThreshold`** (default 30). Above the threshold the
ghost is invisible, has a zeroed collide rect, and banks no movement tokens; below it, it appears
and runs the full inherited crew flee AI (`search` → `escape`). Touching a revealed ghost calls
`Ghost:banish()` — removes it and increments `PlayerData.GhostData.banished`; at
`Config.Ghost.achievementCount` it calls `Utilities.grantAchievementIfNeeded(Config.Ghost.achievementId)`
(safe no-op until the `"ghostbuster"` id is registered). Ghosts have their **own spritesheet and no
hat**, are authored per-room in LDtk as a `Ghost` entity type, and **do not persist** (respawn on
re-entry). A `banishWhileTiny` flag (default true) gates whether tiny-player contact banishes or
passes through crew-like.

**Why:** Atmospheric enemy that manifests as the player goes insane, reusing the CrewMember flee AI
and shared movement-token system with zero new plumbing.

**Files (Playdate side):**
- `entities/enemies/ghost.lua` — NEW. `Ghost` extends `CrewMember`; `init` reaches the grandparent
  (`CrewMember.super.init`) to load its own sheet and skip the hat/hiding config; `update` adds the
  sanity gate then delegates to `CrewMember.update`; `banish` counts + optional achievement.
- `entities/enemies/crewmember.lua` — guarded the `self.hat:moveTo(...)` call in `moveCollision`
  with `if self.hat then ... end` so hatless subclasses don't crash. No-op for real crew.
- `entities/player/collisions.lua` — added an `elseif other:isa(Ghost)` branch BEFORE the
  `isa(CrewMember)` branch (order matters: Ghost is-a CrewMember) that routes to `banish()`.
- `scenes/MazeScene.lua` — imported `entities/enemies/ghost` (after crewmember) and spawn ghosts
  from `levelsLDTK[room].entities.Ghost` in `enter()`.
- `assets/data/Config.lua` — added `Config.Ghost` table; bounce math reuses `Config.CrewMember.*`.
- `assets/data/PlayerDataTables.lua` — added `PlayerData.GhostData = { banished = 0 }` inside
  `DefaultPlayerData` (reset on new game via the existing `ResetPlayerData` deepcopy).
- `assets/images/enemies/ghost-table-48-48.png` — placeholder art (copied from crewmember sheet)
  until the real ghost sheet exists; frame ranges in `Ghost:init` are placeholders.

**Love2D mapping:** Ghost maps directly onto the port's `CrewMember` once the movement-token system
is ported — it is a CrewMember subclass with two additions: (1) a **sanity-gated visibility +
collision toggle** in `update` (compare `sanity < revealThreshold`; toggle `setVisible` and the
collider), and (2) a **banish-on-touch counter** (`GhostData.banished`, optional achievement at a
cap). No hat, own spritesheet, no persistence (respawn per room). Everything else (flee AI, bounce,
token feed) is the already-ported CrewMember behavior.

---

## 2026-08-06 — Fix: enemy wall-sliding (stop grinding/oscillating against walls)

**What:** Enemies now **slide along walls** on the free axis instead of freezing and bouncing off
them. In `Enemy:collisionResponse`, walls (`Box`) return `'slide'` instead of `'freeze'`, and the
manual bounce in `Enemy:moveCollision` no longer fires for `Box` (only for dynamic `PropItem` /
`Enemy`).

**Why:** With `'freeze'` a diagonal move into a wall stopped the enemy dead (no free-axis motion),
and the manual bounce then shoved it back a few px — so each AI turn it re-approached the same wall
corner and oscillated in place ("kept trying to push through the wall") instead of rounding it. The
pathfinder was correct; the 32px body just couldn't execute the diagonal step through a 16px-grid
corner. Sliding lets the free axis carry it around the corner.

**Files (Playdate side):** `entities/enemies/enemy.lua` (`collisionResponse` Box → `'slide'`;
`moveCollision` bounce excludes `Box`).

**How it maps to Love2D:** Use the port's collision layer to slide the enemy along wall AABBs on the
free axis when the primary axis is blocked (resolve axes separately: attempt X and Y independently,
keep whichever succeeds), and do NOT apply the dynamic-object pushback to static wall tiles. Applies
to hunters only; `CrewMember` is unaffected.

---

## 2026-08-06 — Stealth-hunter enemy AI: pathfinding, line of sight, sensory states

**What:** Replaced the hunter AI (`Brocorat`, and `Bosscolli` by inheritance) with a stealth model.
Enemies now **path around walls** (Playdate native A*), detect the player through a **directional
sight cone gated by line of sight + light**, hear **omnidirectional noise** (dashing/walking), and
run a **memory state machine** (`PATROL → CHASE → INVESTIGATE → GIVE UP`) using a `lastKnownTile`.
The old see-through-walls square check and straight-line `blindSearch`-only chase are gone;
`blindSearch` survives only as the adjacent/no-path fallback. `linealSearch` (unused) was deleted.

**Why:** The previous AI saw through walls, could not navigate around them (grinding corners), and
had no memory — it snapped on/off. The new model makes the existing darkness/battery/light stealth
systems meaningful: lit = seen from afar, dark + still = nearly invisible, but dashing in the dark
gives you away.

**How it works:**
- **Sight** (`Enemy:perceive`): player within `sightRadius * lightFactor * tinyMult`, inside the
  heading cone (`facingX/Y` from real movement delta, `coneHalfAngle`), and with clear
  `HasLineOfSight`. Yields the exact tile → CHASE.
- **Hearing** (`Enemy:perceive`): omnidirectional radius (`hearDash`/`hearWalk`/`hearIdle`) from
  `player.isDashing` / `PlayerData.direction`. No cone, no LOS. Yields an approximate tile →
  INVESTIGATE.
- **State machine** (`Enemy:tick`) drives movement through the **existing** `moveCollision` (bounce,
  eat-props, hole-halt preserved). CHASE paths to the player (beeline when adjacent); INVESTIGATE
  paths to `lastKnownTile` and looks around for `investigateTimeout` frames before giving up.

**Files (Playdate side):**
- **NEW** `utilities/Pathing.lua` — wrapper over `playdate.pathfinder` (`new2DGrid` + `findPath`),
  with a first-hop-direction interface and a target-tile-keyed path cache.
- **NEW** `utilities/TileVision.lua` — `HasLineOfSight(x1,y1,x2,y2)` via Bresenham over tiles.
- `entities/enemies/enemy.lua` — `perceive()`, `tick()`, `stepTowardWorld()`, `facingX/Y` in
  `moveCollision`, `drawDebug()`; deleted `linealSearch`.
- `entities/enemies/brocorat.lua` — `search()` body is now `self:tick(player)` (stunProc gate kept).
- `assets/data/Config.lua` — new `Config.Enemy.Perception` block (all tunables; no magic numbers).
- `scenes/MazeScene.lua` — `Pathing.rebuild(...)` on room enter, `Pathing.invalidate()` on exit;
  enemy debug overlay drawn from `scene:update()` (Noble draws sprites before `scene:update`, so
  overlays drawn from a sprite's own `update()` would render underneath).
- `main.lua` — imports the two new modules.

**Love2D port mapping:**
- **`Pathing.lua` is the ONLY file the port must reimplement** — it wraps the Playdate-only
  `playdate.pathfinder`. Provide a plain-Lua A*/BFS behind the identical interface
  (`Pathing.rebuild(tileData)`, `Pathing.stepToward(fromX,fromY,toX,toY) → dirX,dirY` normalized
  first hop or nil, `Pathing.invalidate()`, plus `Pathing.debugPath()` for the overlay). Build the
  graph from `IsTileWalkable` over `tileData[y][x]`, diagonals allowed. Everything else ports
  unchanged.
- `TileVision.lua` is pure Lua — copy as-is (Bresenham over `tileMapData[floor][y][x]`).
- `Enemy:perceive` / `Enemy:tick` / `drawDebug` are engine-agnostic; only the `Graphics.*` calls in
  `drawDebug` map to `love.graphics` equivalents.

---

## 2026-07-31 — DanceScene difficulty now scales with crew recruited (+ per-tier enemy sprite)

**What:** DanceScene difficulty is now **deterministic** and driven by
`PlayerData.CrewMemberData.amountTaken` (crew recruited), replacing the old probabilistic roll.
Each fight picks a tier from crew-count thresholds; higher tiers use higher BPM, more buttons,
a harder button-pattern profile, **and their own enemy spritesheet**.

**Why:** The old system rolled a weighted chance from `sanityCounter` + `EnemiesData.powerLevel`
+ `calories`, but `powerLevel` was never incremented, so it was stuck at `basic` and the
evolve/badass/boss tiers were unreachable. Tying difficulty to crew progress makes it functional
and intentional. Requested: enemy sprite should also change with difficulty.

**Fix:**
- `scene:determineEnemyType()` now maps `amountTaken` → tier via `Config.Dance.crewEvolve/crewBadass/crewBoss` (defaults 3/6/9; roster = `Config.MapGen.totalCrew` = 12). Below `crewEvolve` = `basic`.
- `scene:enter()` sets the tier deterministically (no `math.random` roll); `enemyEvolving = (tier ~= "basic")`.
- Removed `scene:determineDifficultyUpgrade()` and its config (`sanityMax`, `powerMax`, `weightSanity/Power/Calories`). Kept `Config.Dance.caloriesMax` (still used to clamp calories).
- Each `Config.Dance` tier gained a `sprite` field (`enemyDance` / `enemyDanceEvolve` / `enemyDanceBadass` / `enemyDanceBoss`). DanceScene loads the tier sheet with an `imagetable.new` probe and **falls back to the base `enemyDance` sheet** until the per-tier PNG exists (placeholder-safe).
- `EnemyRatDance:init` keeps its four per-tier animation branches as **placeholders** (currently duplicates of `basic`) to be tuned per tier later.

**Files:** `scenes/DanceScene.lua`, `assets/data/Config.lua`, `entities/UI/battle/enemyRatDance.lua`, plus docs.

**Love2D mapping:** difficulty tier = pure function of `amountTaken` (no RNG). Load a different
enemy sprite atlas per tier with a fallback to the base atlas. `powerLevel` no longer factors
into dance difficulty (still used only for enemy sight radius / prop-eating).

---

## 2026-07-31 — Removed the Boots item (holes are always fatal-to-run)

**What:** The **Boots** item and every system that referenced it are gone. Boots were the only
way to cross a hole without falling (a battery-draining hover). Now **all holes always cause a
fall** after the grace period → a fresh procedural run at a `StartDown` room. The **Dash is
kept** and unchanged (it still smashes boxes and commits to a fall/slide when it ends on a
hazard tile).

**Why:** Design decision to cut the item; boots overlapped the lamp for battery pressure and
complicated hole traversal. Simpler model: holes are uncrossable.

**Fix (removed all of):**
- `PlayerData.items.hasBoots` field; `Player:grabBoots()`; the `'boots'` `Items` pickup branch
  in `collisions.lua`; the `'boots'` animation state in `Items.lua`.
- The boots hover branch in `hole.lua` (`checkHoleTile` / `checkTinyHoleTile`) — both now fall
  unconditionally after grace.
- The `hasBoots` check in the dash hole-commit and in the battery HUD update.
- `boots = "items.hasBoots"` from MazeScene's `requiredItems` map; the iddqd cheat line.
- `Config.Battery.drainHoleNormal` / `drainHoleTiny` (only the hover used them).
- The `catNoBoots` dialog entry in `script.lua` (nothing referenced it).

**Files:** `assets/data/PlayerDataTables.lua`, `assets/data/Config.lua`, `assets/data/script.lua`,
`entities/player/hole.lua`, `entities/player/dash.lua`, `entities/player/items.lua`,
`entities/player/collisions.lua`, `entities/items/Items.lua`, `entities/UI/battery.lua`,
`scenes/MazeScene.lua`, `utilities/Utilities.lua`, plus docs.

**Love2D mapping:** Do not port a boots item or any hole-hover. In the hole handler, always run
the grace-then-`fallBelow` path; there is no `hasBoots`/battery bypass.

---

## 2026-07-28 — Balancing: grace before falling/sliding

**What:** Falling through holes and sliding on slime no longer trigger on first contact; they
now require a short grace period (measured in pixels of movement while over the tile) with an
on-screen HUD warning and an optional "balancing" player sprite. A single-pixel clip no longer
drops the player into a whole new run.

**Why (root cause):** The immediate trigger was too punishing and led to frustrating deaths from
accidental one-frame clips.

**Fix:**
- Two per-player pixel accumulators (`holeGracePixels`, `slideGracePixels`) grow while moving
  over a hazard tile and reset when stepping off (`Player:updateGraceMove`).
- **Two thresholds per hazard**, both in px of movement over the tile: a *warning* threshold
  (when the HUD warning + balancing sprite appear) and an *activation* threshold (when the
  fall/slide actually fires). Config: `Config.Hole.warningPixels` (default 0 = on contact),
  `Config.Hole.fallPixels` (normal), `Config.Hole.fallPixelsTiny` (tiny); `Config.Slide.warningPixels`
  (default 0), `Config.Slide.slidePixels`, gated by `Config.Slide.warningEnabled`.
- The warning threshold drives BOTH the HUD warning and the balancing sprite (`hasBalanceGrace`),
  so with `warningPixels = 0` both show the moment the player steps on; the fall/slide waits for
  the activation threshold.
- Dash bypasses the grace entirely and commits (fall or slide) **only when the dash ends on a
  hazard tile** (`Player:endDash`).
- Optional `balancing` / `balancingTiny` sprite states (placeholder = sleep frames) gated by
  `Config.Player.balancingSprite`, overriding the walk pose while balancing.
- HUD warning uses the `Warning` state with a `_warningShown` flag to avoid clobbering other prompts.

**Files:** `assets/data/Config.lua` (thresholds + toggles); `entities/player/init.lua` (grace
accumulator fields); `entities/player/hole.lua` (`updateGraceMove`, `hasBalanceGrace`, `isBalancing`,
hole fall thresholds); `entities/player/sliding.lua` (slime slide threshold + `warningEnabled` gate);
`entities/player/dash.lua` (end-of-dash commit); `entities/player/animations.lua` (`balancing` /
`balancingTiny` states); `entities/player/movement.lua` (balancing sprite override in the walk path);
`entities/player/state.lua` (per-frame `updateGraceMove` call + warning HUD show/hide);
`entities/UI/UIHud.lua` (`setWarning()`).

**Love2D mapping:** The grace accumulators and the two thresholds are pure gameplay logic and must
be mirrored exactly (the warning-vs-activation split, the normal/tiny hole thresholds, and the
`warningEnabled` gate for slides). The dash-commits-only-at-end logic is also core. The HUD warning
and balancing sprite are presentation layer — map them to the port's equivalent state machine, and
drive them from the warning threshold so they appear on contact.

---

## 2026-07-26 — Tiny player sleep state (new `sleepTiny` animation)

**What:** The player can now sleep while minified, using a dedicated tiny sleep animation.
Previously tiny players never entered the sleep state, yet the entry-from-title pose forced
the normal `sleep` frames on them — so a tiny player returning via Continue briefly showed
the wrong (normal-size) sleep pose while not actually being asleep.

**Why:** The spritesheet gained a tiny-sleep animation (last two tiles), and the sleep
behaviour was inconsistent between the initial pose and the actual sleep trigger for tiny.

**Fix:**
- New animation state `sleepTiny` (frames 160-161, `frameDuration = 18`, same cadence as
  `sleep`).
- `Player:startSleeping()` and the from-title initial pose now pick `sleepTiny` when
  `PlayerData.isTiny`, else `sleep`.
- Removed the two `not PlayerData.isTiny` guards that prevented tiny from sleeping:
  `MazeScene:start()` (entry from title) and `MazeScene.onDeviceSleep()` (console sleep).
  Wake is size-agnostic — handled in `Player:update()` by any d-pad press
  (`wakeupPressesRequired = 2`).

**Files:** `entities/player/animations.lua` (`sleepTiny` state + from-title pose),
`entities/player/state.lua` (`startSleeping`), `scenes/MazeScene.lua` (`start`,
`onDeviceSleep`).

**Love2D mapping:** Add a `sleepTiny` animation and select it by player size wherever the
sleep pose is set (both the initial pose on scene entry and the runtime sleep trigger — keep
them consistent). The port's sleep/wake state machine is otherwise unchanged: enter sleep on
title-entry and device-sleep; wake on N d-pad presses regardless of size.

---

## 2026-07-25 — Save records the wrong room on door transitions

**What:** Fixed a bug where, after entering a room and cold-booting (simulator "Restart"),
pressing Continue dropped the player into the **previous** room (at roughly the last
position).

**Why (root cause):** Noble's `transitionMidpointHandler` runs the **outgoing** scene's
`finish()` *before* the **incoming** scene's `enter()`. In this game:
- `Door:goTo()` only stages the destination in `RunState.pendingNodeId` (it does **not**
  touch `currentNodeId`).
- `RunState.consumePending()` (promotes `pendingNodeId → currentNodeId`) lives in
  `MazeScene:enter()`.
- `MazeScene:finish()` calls `SaveSystem.save()`.

So on a door transition A→B the save ran while `currentNodeId` was still **A** (B was
staged but unconsumed) → the save persisted the previous room.

**Fix:** Call `RunState.consumePending()` in `MazeScene:finish()` **before**
`SaveSystem.save()`. It is a no-op for transitions that never staged a destination
(DanceScene, DeadScene, Cockpit → `pendingNodeId` is nil). The subsequent `enter()` still
calls `consumePending()` but it is now a harmless no-op.

**Files:** `scenes/MazeScene.lua` (`scene:finish()`).

**Love2D mapping:** The port's scene manager must guarantee the same ordering discipline:
whatever writes the save on room-exit must run **after** the current-node pointer is
advanced to the destination. Either (a) advance `currentNodeId` at the moment the door is
used (in `goTo`), or (b) if you keep a staged/pending pointer, promote it before the
room-exit save — mirror the fix here. Do not rely on a later autosave/pause to correct it;
the last save before a quit must already point at the correct room.

---

## 2026-07-25 — Door spawn: symmetric body placement + per-size inset

**What:** Two related fixes to where the player lands after walking through a door:
1. **Per-size inset.** `Config.Doors.spawnInset` was split into `spawnInsetNormal` (32) and
   `spawnInsetTiny` (24). Tiny player (smaller collider) now spawns closer to the door.
2. **Symmetry fix.** Entering from a **top** vs **down** door produced different distances
   (a ~24 px asymmetry). Root cause: the 48×48 player sprite is anchored at its centre, but
   the collide rect ("body") sits ~12 px below centre (`bodyDY`). The inset was applied to
   the sprite centre, and `bodyDY` was only compensated on the cross axis for side doors —
   never on the main axis for top/down. Now `bodyDX`/`bodyDY` are subtracted on **both**
   axes so it is the **body**, not the sprite centre, that lands at `inset` from the door.
3. The body offset is computed from the collider that matches the current size
   (`collideRectTiny` when `PlayerData.isTiny`, else `collideRect`).

**Why:** Consistent, predictable spawn distance regardless of entry side or player size.

**Files:** `assets/data/Config.lua` (`Config.Doors.spawnInsetNormal/Tiny`),
`scenes/MazeScene.lua` (door-spawn block in `scene:enter()`).

**Love2D mapping:** Same math applies. If your sprite origin and collision AABB differ
(they usually do with bump.lua — bump uses the top-left of the AABB), compute the offset
between the sprite anchor and the collision-box centre and apply it on both axes when
placing the player at a door. Pick the inset by player size.

---

## 2026-07-24 — Destroyed box keeps a low z-index (no longer draws over player)

**What:** When a box is smashed, its debris sprite stayed pinned to a low z-index instead of
popping above the player.

**Why (root cause):** `PropItem:destroyProp()` set a static z-index (`ZIndex.props`) but did
not set `self.isStaticZIndex = true`. Live props run a per-frame dynamic y-sort
(`if not self.isStaticZIndex then setZIndex(self.y) end` in `PropItem:update()`), which
immediately overwrote the static value on the next frame.

**Fix:** Set `self.isStaticZIndex = true` in `destroyProp()` before assigning the static
z-index. Applies to every smash path (dash, plungerang, bombs) since they all funnel through
`destroyProp`/`smash`.

**Files:** `entities/props/propItem.lua` (`PropItem:destroyProp`).

**Love2D mapping:** In the port's prop update, if you use dynamic y-sorting for draw order,
make sure destroyed/debris props are excluded from it (a `staticZIndex`/`isDebris` flag), or
they will re-sort above the player every frame.

---

## 2026-07-24 — Dash ability (double-tap a D-pad direction)

**What:** Re-introduced the dash ability, reworked from the old boots/skill-gated active item
to a **double-tap** on a D-pad direction (Up-Up dashes up, Down-Down down, etc.). Dash
direction = whichever button was double-tapped (not the facing direction).

**Design decisions:**
- **Always available** — no item/skill gating.
- **No battery cost** (the battery-gating that existed in the first pass was removed).
- **Cooldown** retained (`Config.Dash.cooldown = 500 ms`).
- **Double-tap window** `Config.Dash.tapWindow = 250 ms`.
- Dashing **smashes boxes** on collision (via `PropItem:smash()`).
- Dash **ignores** hole/tiny-hole and slime-slide tiles while active (guards updated).

**Config (`Config.Dash`):** `speed=6`, `totalDistance=56`, `bounceDistance=16`,
`cooldown=500`, `tapWindow=250`.

**Files:** `entities/player/dash.lua` (dash/updateDash/endDash), `entities/player/init.lua`
(import + dash state vars), `entities/player/state.lua` (`updateDash()` call),
`entities/player/hole.lua` + `sliding.lua` (guard against dash), `entities/player/animations.lua`
(dash anim states), `scenes/MazeScene.lua` (double-tap detection in the 4 directional
`xButtonDown` callbacks), `assets/data/Config.lua` (`Config.Dash`).

**Love2D mapping:** Track per-direction last-tap timestamps; if a direction is pressed twice
within `tapWindow`, start a dash in that direction. Dash is a timed movement lerp over
`totalDistance` at `speed`, with a `cooldown` gate. During dash, skip hole/slime tile checks
and treat box overlaps as an instant smash.

---

## 2026-07-24 — Black screen on cold boot (getFPS = 0 on first transition)

**What:** On real hardware, the very first launch after a fresh install showed a solid black
TitleScene with no audio; it self-healed on relaunch. (Simulator-only note: reproduced via
first process launch.)

**Why (root cause):** `Noble.Transition:init()` pads short transitions using
`1/playdate.getFPS()`. `playdate.getFPS()` reports a **measured** rate and can return `0` on
the very first transition of a freshly-launched process (no frame history yet). `1/0` is
`math.huge` in Lua (not an error), which made the transition's enter-duration effectively
infinite → its midpoint (and the scene's `enter()`) never fired → black screen, no audio.

**Fix:** Monkey-patch `playdate.getFPS` in `main.lua` (not in the vendored library, so it
survives Noble updates) to clamp non-positive/zero results to a sane default (30).

**Files:** `main.lua` (getFPS wrapper right after `import 'libraries/noble/Noble'`).

**Love2D mapping:** Likely **not needed** — Love2D's `dt` and timing come from the engine
and don't have the "measured FPS = 0 on first frame" pitfall. Just make sure transition
durations are never divided by a value that can be 0 on the first frame. Listed here for
completeness so the port doesn't reintroduce an equivalent divide-by-zero.

---

## 2026-07-24 — Localization: `.strings` values must be single-line

**What:** Runtime error `Localized text not found for the key: flashcrewmember-01`.

**Why (root cause):** In `en.strings`, that entry's value contained a **raw newline byte**
instead of the escaped `\n` sequence. Playdate `.strings` entries are single-line
`"key" = "value"`; a literal newline breaks parsing and the entry silently fails to load.

**Fix:** Collapse the value to one line with `\n` escaped. Also hardened the dialog authoring
tool's `exportStrings()` to escape backslashes, quotes, and newlines when writing values.

**Files:** `en.strings`, `tools/dialog-tool.html` (`exportStrings`).

**Love2D mapping:** If the port reads the same `.strings` files, apply the same escaping.
If it uses a different i18n format (e.g. a Lua table of key→string), literal newlines are
fine there — but the export tool should still produce correctly-escaped output for whichever
format the port consumes.

---

## How to use this log

- **Append new entries at the top** under a dated `##` heading using the same
  What / Why / Fix / Files / Love2D mapping structure.
- Keep entries focused on things the port must replicate or can safely skip (say which).
- When an entry supersedes an older assumption in `LOVE2D_PORT.md`, note it here and, if
  significant, add a pointer in that file.
