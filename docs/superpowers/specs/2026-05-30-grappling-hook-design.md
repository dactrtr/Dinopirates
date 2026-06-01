# Grappling Hook — Design Spec

**Date:** 2026-05-30
**Status:** Approved (pending implementation plan)

## Summary

A charged variant of the plungerang, usable **only in non-dark rooms**. While the
existing boomerang plungerang fires instantly on a quick B tap, the grappling hook
fires on a **charged hold-and-release** of B: the player holds B, cranks to build up
range, and on release the hook flies out in the direction the player is facing. If the
hook reaches a new **tile value 33** within its range, the player is pulled (fast slide)
to that tile. The hook ignores every sprite — enemies, props, crew, walls — and only
reacts to tile 33.

This mirrors the existing dark-room B scheme (tap = flash/lightburst, hold = dark reveal),
extending the same gesture to lit rooms (tap = boomerang plungerang, hold = grappling hook).

## Goals

- New tile value `33`: walkable, and the only thing the grappling hook interacts with.
- Hold B in a lit room → after a short delay, a crank charge indicator appears.
- Crank amount maps to launch distance (more turns = farther), all values config-driven.
- Release B → hook fires in the player's last-faced direction.
- Hook hits a tile 33 within range → player fast-slides to that tile (input locked).
- Hook hits nothing → returns to the player like a boomerang, no effect (placeholder
  behavior; richer "miss" handling deferred).
- No interaction with any sprite other than tile 33 (passes through walls/enemies/etc.).

## Non-Goals (deferred)

- Special handling when the hook misses (beyond returning silently).
- A dedicated unlock/skill flag separate from the existing plungerang.
- Battery cost.
- Aiming UI / trajectory preview.

## Behavior Summary

| Context | B tap + direction | B hold + crank, release |
|---|---|---|
| Dark room (existing) | flash / lightburst | dark reveal |
| Lit room | boomerang plungerang (existing) | **grappling hook (new)** |

## Components

### 1. Config — `assets/data/Config.lua`

Add tile value and a new tunable block:

```lua
Config.Tiles.IntGrid.grapplePoint = 33   -- new hookable + walkable tile

Config.Grapple = {
    holdDelay       = 400,   -- ms holding B before the crank charge starts (matches dark)
    minDistance     = 64,    -- px guaranteed on any release (~4 tiles)
    maxDistance     = 320,   -- px cap (~20 tiles)
    pixelsPerDegree = 0.4,   -- crank degrees -> launch distance
    projectileSpeed = 8,     -- px/frame the hook flies out
    pullSpeed       = 8,     -- px/frame the player slides toward the tile
    cooldown        = 500,   -- ms between uses
}
```

### 2. Tiles — `utilities/Utilities.lua`

Add tile 33 to the walkable lookup so it is walkable and generates **no** wall `Box`
collider:

```lua
local WALKABLE_TILES = {
    [Config.Tiles.IntGrid.slime]        = true,
    [Config.Tiles.IntGrid.hole]         = true,
    [Config.Tiles.IntGrid.floor]        = true,
    [Config.Tiles.IntGrid.tinyHole]     = true,
    [Config.Tiles.IntGrid.grapplePoint] = true,  -- new
}
```

Tile-33 detection reuses the existing `GetTileUnderPlayer(px, py)` point lookup — the
hook samples the tile under its own center each frame. No collision groups involved.

### 3. Grappling ability + projectile — `entities/player/grapple.lua` (new file)

Chosen architecture (Option A): a dedicated file and `GrappleHook` projectile class,
leaving `projectile.lua` (the boomerang) untouched. The two share almost nothing — the
hook has no sprite collisions, variable distance, and a player-pull — so keeping them
separate avoids branching one class into two behaviors.

**Player methods:**

- `beginGrappleCharge()` — guards: NOT `isInDarkness`; `hasPlunger` and `canPlungerang`;
  not `isTiny`; `isAlive`; `isGaming`; not already `isGrappleCharging` / `isPlunging` /
  `isGrapplePulling`. Sets `isGrappleCharging = true`, `grappleCrankAccum = 0`, and shows
  the `crankClock` HUD state (same indicator as dark reveal).
- `addGrappleCrankDelta(delta)` — accumulate positive crank degrees into `grappleCrankAccum`.
- `endGrappleCharge()` — if not `isGrappleCharging`, return. Hide HUD, clear charging flag.
  `dir = self.direction`; if `idle`/nil → cancel without firing. Compute
  `distance = clamp(minDistance + grappleCrankAccum * pixelsPerDegree, minDistance, maxDistance)`.
  Spawn `GrappleHook(self, dir, distance)`; set `isGrappling = true`.
- `startGrapplePull(targetX, targetY)` — set `grappleTargetX/Y`, `isGrapplePulling = true`
  (locks input via `move()` guard).
- `updateGrapplePull()` — called from `Player:update()`. If `isGrapplePulling`, step the
  player toward the target at `pullSpeed`; when within `pullSpeed`, snap to target, clear
  `isGrapplePulling`, return to idle.
- `onGrappleFinished()` — clear `isGrappling` so another hook can be fired.

**`GrappleHook` projectile class (same file):**

- `init(player, direction, maxDistance)` — `NobleSprite` using the plungerang image for now.
  **No** `setGroups` / `setCollidesWithGroups` → zero sprite interaction. Positioned at the
  player. Stores `direction`, `maxDistance`, `distanceTravelled = 0`, `returning = false`.
- `update()`:
  - If `returning`: move toward the player (boomerang return); when caught, `remove()` and
    call `player:onGrappleFinished()`.
  - Else: move `projectileSpeed` in `direction` via `moveTo` (not `moveWithCollisions`).
    Sample `GetTileUnderPlayer(self.x, self.y)`:
    - `== Config.Tiles.IntGrid.grapplePoint` → compute that tile's center,
      `player:startGrapplePull(cx, cy)`, `remove()`, `player:onGrappleFinished()`.
    - Else accumulate `distanceTravelled`; if `>= maxDistance` → `returning = true`.

### 4. Per-frame hook — `entities/player/state.lua`

Add `self:updateGrapplePull()` inside `Player:update()` (alongside `updateDash` /
`updateSliding`).

### 5. B button routing — `scenes/MazeScene.lua`

- **Hold timer** (in `scene:update()`): after `holdDelay`, branch on room lighting —
  `isInDarkness` → `beginDarkCharge()`, else → `beginGrappleCharge()`.
- **Crank delta routing** (~line 675, where `isDarkCharging` is checked): add
  `if player.isGrappleCharging then player:addGrappleCrankDelta(change); return end`.
- **`BButtonUp`**: also call `player:endGrappleCharge()` (each end-charge method validates
  whether its own state is active, so calling both is safe).

### 6. Input lock during pull — `entities/player/movement.lua`

Add `self.isGrapplePulling` to the early-return guard in `move()` that already blocks
movement during `isPlunging` / `isDashing` / `isSliding`, freezing input during the slide.

## Data Flow

1. Lit room; the player walks, setting `self.direction` (last-faced direction).
2. Hold B > `holdDelay` → `beginGrappleCharge()` → `crankClock` HUD appears.
3. Crank → `addGrappleCrankDelta` accumulates degrees.
4. Release B → `endGrappleCharge()` → distance computed → `GrappleHook` fired in
   `self.direction`.
5. Hook flies, sampling tiles each frame:
   - Tile 33 within range → player fast-slides to the tile center (input locked) → done.
   - No tile 33 within range → returns to player → disappears (no effect).
6. No interaction with enemies / props / crew / walls at any point.

## Edge Cases

- `self.direction` is `idle`/nil on release → cancel, no fire, hide HUD.
- Tiny mode → cannot grapple (mirrors plunge).
- Already plunging (boomerang out) → do not start a grapple charge, and vice versa.
- Battery untouched throughout.
- Charging does not lock movement (consistent with dark charge); only the pull locks input.

## Decisions / Assumptions

- **Gating:** reuses `PlayerData.items.hasPlunger` + `PlayerData.skills.canPlungerang`
  (available whenever the plungerang is), no new skill flag.
- **No battery cost.**
- **Miss → boomerang return** with no effect (placeholder).
- **Tile 33 passes through walls** — only the tile matters.
- **No automated tests** (Playdate): validate in the simulator with a room containing a
  tile 33 — confirm the charge HUD, the launch, the pull, and the no-impact return.
