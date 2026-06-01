# Grappling Hook

A charged hold-and-release variant of the plungerang, usable **only in lit rooms** (the
plain boomerang plungerang still fires on a quick B tap). The hook flies in the direction the
player is facing and, if it reaches a walkable **tile value 33**, pulls the player to that
tile with a fast slide. It ignores every **sprite** — enemies, props, crew — and reacts only
to the tiles it flies over: tile 33 (grapple) and walls (it bounces back). Both are detected by
tile sampling, never by sprite collision.

This mirrors the dark-room B scheme:

| Context | B tap + direction | B hold + crank, release |
|---|---|---|
| Dark room | flash (`lightBurst`) | dark reveal |
| Lit room | plungerang boomerang | **grappling hook** |

Implemented entirely in `entities/player/grapple.lua` (the `GrappleHook` projectile class plus
the Player charge/fire/pull methods). See also `INPUT_SYSTEM.md` ("B Button — Hold & Release")
for input routing and `PLUNGERANG.md` for the sibling boomerang.

---

## Input Flow

The hook is driven by the custom B hold timer in `MazeScene` (not the SDK's fixed 1 s
`BButtonHeld`). In a lit room:

```
1. Player walks → self.direction holds the last faced direction.
2. Hold B > Config.Grapple.holdDelay (400 ms) → beginGrappleCharge()
     → isGrappleCharging = true, crankClock HUD shown.
3. Crank → cranked handler routes the delta to addGrappleCrankDelta() (no battery charge).
4. Release B → endGrappleCharge()
     → distance computed from crank, GrappleHook fired in self.direction.
5. Hook flies, sampling tiles each frame:
     - tile 33 in range → startGrapplePull() → player fast-slides to the tile (input locked).
     - no tile 33      → returns to the player like a boomerang, disappears (no effect).
```

The charge is performed while standing still (idle), so the instant boomerang (which needs a
direction) does **not** fire on the same press.

---

## Player Methods (`entities/player/grapple.lua`)

### `Player:beginGrappleCharge()`

Validations (all must pass, else returns silently):

```
1. PlayerData.isInDarkness == false       (lit rooms only)
2. PlayerData.items.hasPlunger == true     AND PlayerData.skills.canPlungerang == true
3. self.hasProjectile == true              (not lost to a CrewMember; recover it first)
4. PlayerData.isTiny == false
5. self.isAlive == true  AND  PlayerData.isGaming == true
6. not already isGrappleCharging / isPlunging / isGrapplePulling / isGrappling
```

On success: `isGrappleCharging = true`, `grappleCrankAccum = 0`, shows the `crankClock` HUD
state (same indicator as the dark reveal).

### `Player:addGrappleCrankDelta(delta)`

Accumulates **positive** crank degrees into `grappleCrankAccum` while charging. Reverse
cranking is ignored (mirrors `addDarkCrankDelta`).

### `Player:endGrappleCharge()`

If not charging, returns. Otherwise hides the HUD and:

```lua
local dir = self.direction
if dir == 'idle' or dir == nil then return end   -- no facing → cancel, no fire

local g = Config.Grapple
local distance = g.minDistance + self.grappleCrankAccum * g.pixelsPerDegree
if distance > g.maxDistance then distance = g.maxDistance end

self.isGrappling = true
self.grappleHook = GrappleHook(self, dir, distance)
self:distributeMovementTokens(Config.Player.movementTokensPerAction)  -- 5 tokens on launch
self:idle()
```

Because `grappleCrankAccum >= 0`, `distance` is always at least `minDistance` (the lower
clamp is guaranteed by the math).

### `Player:onGrappleFinished()`

Clears `isGrappling` and `grappleHook` so the next hook can be fired. Called on every exit
path of `GrappleHook:update()` (catch on return, or tile-33 hit).

### `Player:startGrapplePull(targetX, targetY)` / `Player:updateGrapplePull()`

`startGrapplePull` sets `grappleTargetX/Y` and `isGrapplePulling = true` (which locks
movement input). `updateGrapplePull` (called from `Player:update()`) steps the player toward
the target at `Config.Grapple.pullSpeed` each frame, sets a directional animation so the
player isn't frozen, and on arrival snaps to the target, clears `isGrapplePulling`, and
returns to idle.

The pull target is the tile **center minus `Config.Player.feetOffsetY`** (12 px), so the
player's feet — not the sprite center — settle on the tile.

---

## `GrappleHook` Class (`entities/player/grapple.lua`)

Extends `NobleSprite`. Image: `assets/images/items/projectile-table-24-24` (shared with the
boomerang). **No collision groups are set** — it never interacts with sprites; detection is
pure tile sampling.

### Constructor

```lua
GrappleHook(player, direction, maxDistance)
```

| Property | Initial Value | Source |
|---|---|---|
| `self.direction` | Launch direction | parameter |
| `self.maxDistance` | Computed from crank | parameter |
| `self.distanceTravelled` | 0 | — |
| `self.returning` | `false` | — |
| `self.speed` | 8 px/frame | `Config.Grapple.projectileSpeed` |

Z-index `ZIndex.player + 10`, size 24×24, added at `(player.x, player.y + 16)`. Animation
state `spin`: frames 1–4, duration 4.

### Movement / Detection (`GrappleHook:update`)

**Outgoing phase:** moves at constant speed via `moveTo` (not `moveWithCollisions`), then
samples the tile under its own center:

```lua
local tile = GetTileUnderPlayer(self.x, self.y)
if tile == Config.Tiles.IntGrid.grapplePoint then
    local ts = Config.Tiles.size
    local cx = math.floor(self.x / ts) * ts + ts / 2
    local cy = math.floor(self.y / ts) * ts + ts / 2
    self.player:startGrapplePull(cx, cy - Config.Player.feetOffsetY)
    self:remove()
    self.player:onGrappleFinished()
    return
elseif not IsTileWalkable(tile) then
    -- Hit a wall (or left the map) — bounce back like the boomerang.
    self.returning = true
    return
end

self.distanceTravelled += self.speed
if self.distanceTravelled >= self.maxDistance then self.returning = true end
```

Walls are detected by `IsTileWalkable(tile)` (`utilities/Utilities.lua`), which returns false
for any value outside `WALKABLE_TILES` and for `nil` (off-map). Walkable tiles the hook flies
over (floor, slime, hole, tinyHole) do not stop it; only tile 33 grapples and only walls return.

**Return phase (miss):** homes on the player's current position and finishes when within
`speed` (uses `<=`), calling `onGrappleFinished()`. No player movement results.

---

## `GrappleRope` Class (the rope visual)

A `Graphics.sprite` (like `FXshadow`) created in `endGrappleCharge` alongside the hook and
removed in `onGrappleFinished`. Each frame it sizes itself to the bounding box of the two
endpoints and draws a `Config.Grapple.ropeWidth` (2 px) black line from the player's feet
(`player.y + Config.Player.feetOffsetY`) to the hook's center. Because the camera is fixed
(world space == screen space), the sprite uses
`setCenter(0, 0)` so its local coordinates map 1:1 to world coordinates. Z-index
`ZIndex.player + 9` — above the player, just under the hook. The rope lives only while the hook
sprite exists (flight + return); the pull has no rope.

---

## Movement Locks

`Player:move()` returns early while `self.isGrappling` (hook in flight) **or**
`self.isGrapplePulling` (being pulled) is true — alongside `isSliding` /
`isPlunging`. Locking during flight keeps the boomerang-return target stable so the hook
always converges and `onGrappleFinished` reliably fires (preventing a stuck `isGrappling`).

`checkHoleTile()` / `checkTinyHoleTile()` also skip while `isGrapplePulling`, so the pull
flies the player **over** holes instead of falling in.

---

## Tile 33 (`Config.Tiles.IntGrid.grapplePoint`)

Tile 33 is registered in `WALKABLE_TILES` (`utilities/Utilities.lua`), so it is walkable and
generates **no** wall collider. It is the only tile the hook reacts to. Authoring a grapple
point means placing IntGrid value 33 in a room's matrix in `assets/data/tilemap.lua`
(typically via LDtk re-export).

---

## Relevant Constants

### `Config.Grapple`

| Field | Value | Description |
|---|---|---|
| `holdDelay` | 400 ms | Hold time before the crank charge starts |
| `minDistance` | 64 px | Guaranteed launch distance on any release (~4 tiles) |
| `maxDistance` | 320 px | Distance cap (~20 tiles) |
| `pixelsPerDegree` | 0.4 | Crank degrees → added launch distance |
| `projectileSpeed` | 8 px/frame | Hook flight speed |
| `pullSpeed` | 8 px/frame | Player slide speed toward the tile |
| `cooldown` | 500 ms | Reserved — not yet enforced |
| `ropeWidth` | 2 px | Width of the black rope drawn from player to hook |

### Shared

| Field | Value | Description |
|---|---|---|
| `Config.Tiles.IntGrid.grapplePoint` | 33 | The hookable, walkable tile |
| `Config.Player.feetOffsetY` | 12 px | Sprite-position → feet offset, used to center the landing |
| `Config.Player.movementTokensPerAction` | 5 | Enemy/crew tokens granted when the grapple launches |

---

## Behavior Summary

- **No battery cost.** The grapple never touches `PlayerData.battery`.
- **No sprite interaction.** Passes through enemies, crew, and props (sprites). Walls are
  detected by tile sampling, not collision: hitting a non-walkable tile — or leaving the map —
  bounces the hook back, so a tile 33 behind a wall is **not** reachable.
- **Miss / wall → boomerang return**, no player movement (placeholder; richer miss handling deferred).
- **Does not activate in darkness** — that path is the dark reveal instead.
