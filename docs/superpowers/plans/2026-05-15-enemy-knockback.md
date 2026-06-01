# Enemy Knockback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Push the player 2 pixels away from an enemy when taking damage, respecting wall collisions.

**Architecture:** Add `knockbackDistance` to `Config.Player`, implement `Player:applyKnockback(enemyX, enemyY)` in `state.lua` using `moveWithCollisions`, and call it from the Brocorat hit block in `collisions.lua` immediately after `startInvincibility`.

**Tech Stack:** Lua, Playdate SDK, Noble Engine. No test runner — validate by compiling with `pdc` and running in the simulator.

> **Note:** Per project rules, do NOT run `git commit`. The user commits manually.

---

## File Map

| File | Change |
|------|--------|
| `source/assets/data/Config.lua` | Add `knockbackDistance = 2` to `Config.Player` |
| `source/entities/player/state.lua` | Add `Player:applyKnockback(enemyX, enemyY)` after `startInvincibility` |
| `source/entities/player/collisions.lua` | Call `self:applyKnockback(other.x, other.y)` in Brocorat hit block |

---

### Task 1: Add `knockbackDistance` to Config

**Files:**
- Modify: `source/assets/data/Config.lua` (around line 53, end of `Config.Player` block)

- [ ] **Step 1: Add the constant**

Open `source/assets/data/Config.lua`. Find `Config.Player = { ... }` (starts at line 40). Add `knockbackDistance` as the last entry before the closing `}`:

```lua
Config.Player = {
    speed            = 2,
    speedDarkNoLamp  = 0.7,
    speedLowBattery  = 0.8,
    collideRect      = {x=8,  y=24, w=30, h=24},
    collideRectTiny  = {x=19, y=32, w=10, h=10},
    collideRectHead  = {x=8,  y=8, w=16, h=16},
    uiOffsetX        = 30,
    uiOffsetY        = 30,
    hudOffsetY       = -40,
    hudOffsetYTiny   = -17,
    triggerCheckDist        = 5,
    movementFramesPerAction = 3,
    knockbackDistance       = 2,
}
```

- [ ] **Step 2: Compile**

```bash
cd /Users/dactrtr-mini/Documents/GitHub/Dinopirates
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -v "^Copying"
```

Expected: no errors (only the "Unrecognized file types" warning is fine).

---

### Task 2: Implement `Player:applyKnockback`

**Files:**
- Modify: `source/entities/player/state.lua` (after line 70, after `startInvincibility`)

- [ ] **Step 1: Add the method**

Open `source/entities/player/state.lua`. Find `Player:startInvincibility` (line 67–70):

```lua
function Player:startInvincibility(duration)
    self.isInvincible = true
    self.invincibilityTimer = duration
end
```

Add `Player:applyKnockback` immediately after it:

```lua
function Player:startInvincibility(duration)
    self.isInvincible = true
    self.invincibilityTimer = duration
end

function Player:applyKnockback(enemyX, enemyY)
    local k = Config.Player.knockbackDistance
    local dx = (self.x ~= enemyX) and ((self.x > enemyX) and k or -k) or 0
    local dy = (self.y ~= enemyY) and ((self.y > enemyY) and k or -k) or 0
    self:moveWithCollisions(self.x + dx, self.y + dy)
end
```

**How it works:**
- `dx`: if player is to the right of the enemy, push right (+k); if to the left, push left (-k); if same X, no horizontal push.
- `dy`: same logic on Y axis.
- `moveWithCollisions` resolves the move against wall colliders — the player stops at a wall rather than clipping through.

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -v "^Copying"
```

Expected: no errors.

---

### Task 3: Call `applyKnockback` from the Brocorat hit block

**Files:**
- Modify: `source/entities/player/collisions.lua` (around line 19)

- [ ] **Step 1: Add the call**

Open `source/entities/player/collisions.lua`. Find the Brocorat hit block (lines 11–21):

```lua
      if not self.isInvincible then
        PlayerData.healthPoints -= (other.damage or 1)
        printDebug("💥 Player hit by Brocorat! HP:", PlayerData.healthPoints)
        
        -- Trigger dance only if HP < threshold
        if PlayerData.healthPoints < (PlayerData.danceThresholdHP or 5) then
          self:fight()
        else
          self:startInvincibility(Config.Invincibility.duration)
        end
      end
```

Replace it with:

```lua
      if not self.isInvincible then
        PlayerData.healthPoints -= (other.damage or 1)
        printDebug("💥 Player hit by Brocorat! HP:", PlayerData.healthPoints)
        
        -- Trigger dance only if HP < threshold
        if PlayerData.healthPoints < (PlayerData.danceThresholdHP or 5) then
          self:fight()
        else
          self:startInvincibility(Config.Invincibility.duration)
          self:applyKnockback(other.x, other.y)
        end
      end
```

`applyKnockback` is only called on the `startInvincibility` branch — not when `fight()` triggers a scene transition.

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -v "^Copying"
```

Expected: no errors.

- [ ] **Step 3: Verify in simulator**

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

Walk the player into a Brocorat (with enough HP to NOT trigger DanceScene). Confirm:
- Player is pushed ~2px away from the enemy on contact
- Player flickers (invincibility blink) as before
- Player does not clip through a wall if hit while against one
- DanceScene still triggers normally when HP is below threshold (knockback is NOT applied in that branch)
