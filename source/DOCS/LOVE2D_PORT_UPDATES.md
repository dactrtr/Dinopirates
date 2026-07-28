# Love2D Port — Update Log

Running changelog of gameplay/engine changes made in the Playdate project that the
Love2D port must mirror. Newest entries on top. Each entry says **what changed**, **why**,
**which files** (Playdate side), and **how it maps to Love2D**.

This complements [LOVE2D_PORT.md](LOVE2D_PORT.md) (the full port guide) and
[PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md) — when an entry touches the run graph
or door flow, those documents are the authoritative model.

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
