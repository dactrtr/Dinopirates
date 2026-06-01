# Grappling Hook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a charged hold-and-release "grappling hook" variant of the plungerang for lit rooms that flies in the faced direction and pulls the player to a new walkable tile value `33`.

**Architecture:** A dedicated `entities/player/grapple.lua` holds a `GrappleHook` NobleSprite (no collision groups — it samples tiles, ignoring all sprites) plus the Player charge/pull methods. The existing dark-room B scheme is mirrored: in lit rooms, tap B = boomerang plungerang (existing), hold B + crank, release = grappling hook (new). Detection reuses `GetTileUnderPlayer`; the pull mirrors the slime-slide state machine.

**Tech Stack:** Lua, Panic Playdate SDK, Noble Engine.

---

## Project Conventions (read before starting)

- **No test runner.** Per `CLAUDE.md`, this project has no automated tests; validate by compiling with `pdc` and running the simulator. Each task's verification step is a `pdc` compile (must exit 0, no errors/warnings) plus, where noted, a manual simulator check.
- **No git commits.** Per `CLAUDE.md`, never run `git commit`. The user commits manually. Skip all commit steps.
- **Compile command** (run from repo root):
  ```bash
  pdc source "DinoPirates from inner space Brocolation.pdx" >/dev/null 2>/tmp/pdc_err; echo "exit: $?"; grep -i "error\|warning" /tmp/pdc_err || echo "(no errors)"
  ```
  Expected after each task: `exit: 0` and `(no errors)`.
- **Spec:** `docs/superpowers/specs/2026-05-30-grappling-hook-design.md`.

## File Structure

| File | Change | Responsibility |
|---|---|---|
| `source/assets/data/Config.lua` | Modify | Tile value 33 + `Config.Grapple` tunables |
| `source/utilities/Utilities.lua` | Modify | Register tile 33 as walkable (no wall collider) |
| `source/entities/player/grapple.lua` | Create | `GrappleHook` projectile + Player charge/fire/pull methods |
| `source/entities/player/init.lua` | Modify | Import the new file |
| `source/entities/player/state.lua` | Modify | Drive the pull each frame from `Player:update()` |
| `source/entities/player/movement.lua` | Modify | Lock movement input during the pull |
| `source/scenes/MazeScene.lua` | Modify | Route B hold / crank / release to the grapple charge |

---

## Task 1: Config — tile value and tunables

**Files:**
- Modify: `source/assets/data/Config.lua`

- [ ] **Step 1: Add the `grapplePoint` IntGrid value**

In the `Config.Tiles.IntGrid` table (currently ends with `tinyHole = 32,`), add the new entry:

```lua
Config.Tiles = {
    size    = 16,
    IntGrid = {
        wall        = 1,
        slime       = 2,
        hole        = 3,
        floor       = 4,
        tinyHole    = 32,
        grapplePoint = 33,   -- hookable + walkable tile for the grappling hook
    }
}
```

- [ ] **Step 2: Add the `Config.Grapple` block**

Add this block immediately after the existing `Config.DarkReveal = { ... }` block:

```lua
-- Grappling Hook (charged plungerang in lit rooms)
Config.Grapple = {
    holdDelay       = 400,   -- ms holding B before the crank charge starts
    minDistance     = 64,    -- px guaranteed on any release (~4 tiles)
    maxDistance     = 320,   -- px cap (~20 tiles)
    pixelsPerDegree = 0.4,   -- crank degrees -> launch distance
    projectileSpeed = 8,     -- px/frame the hook flies out
    pullSpeed       = 8,     -- px/frame the player slides toward the tile
    cooldown        = 500,   -- ms between uses (reserved; not yet enforced)
}
```

- [ ] **Step 3: Compile to verify**

Run the compile command. Expected: `exit: 0` and `(no errors)`.

---

## Task 2: Register tile 33 as walkable

**Files:**
- Modify: `source/utilities/Utilities.lua` (the `WALKABLE_TILES` table, ~line 462)

- [ ] **Step 1: Add tile 33 to `WALKABLE_TILES`**

Change the table from:

```lua
local WALKABLE_TILES = {
	[Config.Tiles.IntGrid.slime]    = true,
	[Config.Tiles.IntGrid.hole]     = true,
	[Config.Tiles.IntGrid.floor]    = true,
	[Config.Tiles.IntGrid.tinyHole] = true,
```

to:

```lua
local WALKABLE_TILES = {
	[Config.Tiles.IntGrid.slime]        = true,
	[Config.Tiles.IntGrid.hole]         = true,
	[Config.Tiles.IntGrid.floor]        = true,
	[Config.Tiles.IntGrid.tinyHole]     = true,
	[Config.Tiles.IntGrid.grapplePoint] = true,  -- walkable; no wall collider generated
```

(Keep the rest of the table/closing brace unchanged.)

- [ ] **Step 2: Compile to verify**

Run the compile command. Expected: `exit: 0` and `(no errors)`.

---

## Task 3: Create `grapple.lua` (projectile + Player methods)

**Files:**
- Create: `source/entities/player/grapple.lua`

- [ ] **Step 1: Write the full file**

Create `source/entities/player/grapple.lua` with this exact content:

```lua
-- Grappling Hook: charged plungerang for lit rooms.
-- Hold B + crank to charge, release to fire in the faced direction. The hook
-- ignores every sprite and only reacts to tile value 33 (Config.Tiles.IntGrid.grapplePoint):
-- on contact it pulls the player (fast slide) to that tile; otherwise it returns like a boomerang.

-- ===== Projectile =====
GrappleHook = {}
class('GrappleHook').extends(NobleSprite)

function GrappleHook:init(player, direction, maxDistance)
    local px, py = player:getPosition()
    GrappleHook.super.init(self, 'assets/images/items/projectile-table-24-24', true)

    self.player = player
    self.direction = direction
    self.maxDistance = maxDistance
    self.distanceTravelled = 0
    self.returning = false
    self.speed = Config.Grapple.projectileSpeed

    self:setZIndex(ZIndex.player + 10)
    self:setSize(24, 24)
    -- No setGroups / setCollidesWithGroups: zero sprite interaction by design.

    self:add(px, py + 16)

    self.animation:addState('spin', 1, 4)
    self.animation.spin.frameDuration = 4
    self.animation:setState('spin')

    printDebug("🪝 Grapple hook launched, dir: " .. tostring(direction) .. " dist: " .. tostring(maxDistance))
end

function GrappleHook:update()
    if self.returning then
        local dx = self.player.x - self.x
        local dy = self.player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < self.speed then
            self:remove()
            if self.player.onGrappleFinished then self.player:onGrappleFinished() end
        else
            self:moveTo(self.x + (dx/dist)*self.speed, self.y + (dy/dist)*self.speed)
        end
        return
    end

    -- Fly out in the launch direction (no collisions).
    local moveX, moveY = 0, 0
    if self.direction == 'left' then moveX = -self.speed
    elseif self.direction == 'right' then moveX = self.speed
    elseif self.direction == 'up' then moveY = -self.speed
    elseif self.direction == 'down' then moveY = self.speed
    end
    self:moveTo(self.x + moveX, self.y + moveY)

    -- Sample the tile under the hook's center.
    if GetTileUnderPlayer(self.x, self.y) == Config.Tiles.IntGrid.grapplePoint then
        local ts = Config.Tiles.size
        local cx = math.floor(self.x / ts) * ts + ts / 2
        local cy = math.floor(self.y / ts) * ts + ts / 2
        self.player:startGrapplePull(cx, cy)
        self:remove()
        if self.player.onGrappleFinished then self.player:onGrappleFinished() end
        return
    end

    self.distanceTravelled += self.speed
    if self.distanceTravelled >= self.maxDistance then
        self.returning = true
    end
end

-- ===== Player charge / fire =====
function Player:beginGrappleCharge()
    if PlayerData.isInDarkness then return end
    if not PlayerData.items.hasPlunger or not PlayerData.skills.canPlungerang then return end
    if PlayerData.isTiny then return end
    if not self.isAlive or PlayerData.isGaming ~= true then return end
    if self.isGrappleCharging or self.isPlunging or self.isGrapplePulling or self.isGrappling then return end

    self.isGrappleCharging = true
    self.grappleCrankAccum = 0
    self.uiHud.animation:setState('crankClock')
    self.uiHud:setVisible(true)
end

function Player:addGrappleCrankDelta(delta)
    if not self.isGrappleCharging then return end
    if delta > 0 then self.grappleCrankAccum += delta end
end

function Player:endGrappleCharge()
    if not self.isGrappleCharging then return end
    self.isGrappleCharging = false
    self.uiHud:setRotation(0)
    self.uiHud:setVisible(false)

    local dir = self.direction
    if dir == 'idle' or dir == nil then
        self.grappleCrankAccum = 0
        return
    end

    local g = Config.Grapple
    local distance = g.minDistance + self.grappleCrankAccum * g.pixelsPerDegree
    if distance > g.maxDistance then distance = g.maxDistance end
    self.grappleCrankAccum = 0

    self.isGrappling = true
    self.grappleHook = GrappleHook(self, dir, distance)
    self:idle()
end

function Player:onGrappleFinished()
    self.isGrappling = false
    self.grappleHook = nil
end

-- ===== Player pull (fast slide to the tile) =====
function Player:startGrapplePull(targetX, targetY)
    self.grappleTargetX = targetX
    self.grappleTargetY = targetY
    self.isGrapplePulling = true
end

function Player:updateGrapplePull()
    if not self.isGrapplePulling then return end

    local dx = self.grappleTargetX - self.x
    local dy = self.grappleTargetY - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local speed = Config.Grapple.pullSpeed

    if dist <= speed then
        self:moveTo(self.grappleTargetX, self.grappleTargetY)
        self.uiHud:moveTo(self.x + self.playerUIX, self.y - self.playerUIY)
        self.isGrapplePulling = false
        PlayerData.direction = 'idle'
        self:idle()
    else
        local nx = self.x + (dx/dist)*speed
        local ny = self.y + (dy/dist)*speed
        self:moveTo(nx, ny)
        self.uiHud:moveTo(self.x + self.playerUIX, self.y - self.playerUIY)
    end
end
```

- [ ] **Step 2: Compile check is deferred to Task 4**

This file is not imported yet, so `pdc` will not load it. Proceed to Task 4, then compile. (No standalone verification possible for an unimported file.)

---

## Task 4: Import the new file

**Files:**
- Modify: `source/entities/player/init.lua` (import list, ~line 18)

- [ ] **Step 1: Add the import after `plunge`**

Change:

```lua
import "entities/player/projectile"
import "entities/player/plunge"
```

to:

```lua
import "entities/player/projectile"
import "entities/player/plunge"
import "entities/player/grapple"
```

- [ ] **Step 2: Compile to verify (loads Task 3 + Task 4)**

Run the compile command. Expected: `exit: 0` and `(no errors)`.
This confirms `grapple.lua` parses and all referenced globals (`NobleSprite`, `class`, `ZIndex`, `GetTileUnderPlayer`, `Config`, `Player`, `printDebug`) resolve at compile time.

---

## Task 5: Drive the pull each frame

**Files:**
- Modify: `source/entities/player/state.lua` (`Player:update()`, ~line 285)

- [ ] **Step 1: Call `updateGrapplePull` in the update loop**

Change:

```lua
  -- Update sliding movement if on slime
  self:updateSliding()
```

to:

```lua
  -- Update sliding movement if on slime
  self:updateSliding()

  -- Update grappling-hook pull if active
  self:updateGrapplePull()
```

- [ ] **Step 2: Compile to verify**

Run the compile command. Expected: `exit: 0` and `(no errors)`.

---

## Task 6: Lock movement input during the pull

**Files:**
- Modify: `source/entities/player/movement.lua` (`Player:move()` guard, ~line 6)

- [ ] **Step 1: Add `isGrapplePulling` to the guard**

Change:

```lua
    -- Don't allow normal movement while dashing, sliding or plunging
    if self.isDashing or self.isSliding or self.isPlunging then
      return
    end
```

to:

```lua
    -- Don't allow normal movement while dashing, sliding, plunging or being pulled
    if self.isDashing or self.isSliding or self.isPlunging or self.isGrapplePulling then
      return
    end
```

- [ ] **Step 2: Compile to verify**

Run the compile command. Expected: `exit: 0` and `(no errors)`.

---

## Task 7: Route B hold / crank / release in MazeScene

**Files:**
- Modify: `source/scenes/MazeScene.lua` — hold timer (~line 385), crank handler (~line 682), `BButtonUp` (~line 553)

- [ ] **Step 1: Branch the hold timer on room lighting**

Change the existing hold-to-charge block:

```lua
	-- MARK: Custom B hold-to-charge (shorter than the SDK's fixed 1s Held)
	if bButtonDownTime and player and player.isAlive and PlayerData.isGaming == true
		and not player.isDarkCharging then
		if playdate.getCurrentTimeMilliseconds() - bButtonDownTime >= Config.DarkReveal.holdDelay then
			player:beginDarkCharge()
		end
	end
```

to:

```lua
	-- MARK: Custom B hold-to-charge (shorter than the SDK's fixed 1s Held)
	if bButtonDownTime and player and player.isAlive and PlayerData.isGaming == true
		and not player.isDarkCharging and not player.isGrappleCharging then
		local holdDelay = PlayerData.isInDarkness and Config.DarkReveal.holdDelay or Config.Grapple.holdDelay
		if playdate.getCurrentTimeMilliseconds() - bButtonDownTime >= holdDelay then
			if PlayerData.isInDarkness then
				player:beginDarkCharge()
			else
				player:beginGrappleCharge()
			end
		end
	end
```

- [ ] **Step 2: Route crank delta to the grapple charge**

In the `cranked` handler, find the existing dark-charge routing:

```lua
		if player.isDarkCharging then
			player:addDarkCrankDelta(change)
			return
		end
```

and add the grapple routing immediately after it:

```lua
		if player.isDarkCharging then
			player:addDarkCrankDelta(change)
			return
		end

		if player.isGrappleCharging then
			player:addGrappleCrankDelta(change)
			return
		end
```

- [ ] **Step 3: End the grapple charge on B release**

Change:

```lua
	BButtonUp = function()
		bButtonDownTime = nil
		if player then player:endDarkCharge() end
	end,
```

to:

```lua
	BButtonUp = function()
		bButtonDownTime = nil
		if player then
			player:endDarkCharge()
			player:endGrappleCharge()
		end
	end,
```

- [ ] **Step 4: Compile to verify**

Run the compile command. Expected: `exit: 0` and `(no errors)`.

---

## Task 8: Simulator validation

**Prerequisite (content authoring):** A lit room must contain at least one tile with
IntGrid value `33`. Add it via LDtk (re-export `levels.lua`/`tilemap.lua`) or by editing a
matrix in `source/assets/data/tilemap.lua` directly for a test room. Without a tile 33 in
the current room, only the "miss → boomerang return" path is observable.

- [ ] **Step 1: Launch the simulator**

Run:
```bash
open "DinoPirates from inner space Brocolation.pdx"
```

- [ ] **Step 2: Verify charge + indicator (lit room)**

In a lit room, walk in a direction, stop, then hold B. After ~400 ms the `crankClock` HUD
indicator should appear. Crank the crank; release B. The hook should fly out in the last
faced direction. Confirm a longer crank produces a longer flight.

- [ ] **Step 3: Verify the pull onto tile 33**

Aim the hook at a tile 33 within range and release. The hook should stop at the tile and the
player should fast-slide to it with input locked until arrival. Confirm the player ends
standing on/at the tile. If the player lands visibly off-center vertically, tune the pull
target in `Player:startGrapplePull` (e.g. offset `targetY`) — feet sit ~12 px below the
sprite position.

- [ ] **Step 4: Verify the miss path**

Fire the hook where no tile 33 is in range. It should travel to `maxDistance`, return to the
player like a boomerang, and disappear with no player movement.

- [ ] **Step 5: Verify no sprite interaction**

Fire the hook through enemies, crew, props, and walls. It must pass through all of them with
no effect — only tile 33 triggers a reaction.

- [ ] **Step 6: Verify dark rooms are unchanged**

In a dark room, confirm tap B still flashes (lightburst) and hold B + crank still triggers the
dark reveal — the grapple must not activate in darkness.

---

## Self-Review Notes

- **Spec coverage:** tile 33 walkable (T2), config tunables (T1), hold→charge→release fire
  (T3/T7), crank→distance with min/cap (T3), faced-direction launch (T3), tile-33 pull /
  fast slide / input lock (T3/T5/T6), miss→boomerang return (T3), no sprite interaction
  (T3, no collision groups), no battery cost (nothing touches battery), dark rooms unchanged
  (T7 branch). All covered.
- **Method-name consistency:** `beginGrappleCharge` / `addGrappleCrankDelta` /
  `endGrappleCharge` / `startGrapplePull` / `updateGrapplePull` / `onGrappleFinished` and the
  flags `isGrappleCharging` / `isGrappling` / `isGrapplePulling` are used identically across
  T3, T5, T6, T7.
- **Deferred (per spec non-goals):** richer miss handling, dedicated unlock flag, aiming UI,
  cooldown enforcement (the config field exists but is intentionally not wired yet).
