# Dark Reveal Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Dark Reveal" skill — hold B in darkness, crank 720°, release B to reveal the whole level, drain all battery, and block recharge temporarily.

**Architecture:** Crank accumulation and B-hold state live on the Player object. MazeScene wires input callbacks to player methods. FXshadow reads a new `PlayerData.showFullLight` flag to override its shadow rendering. The `chargeBattery()` function respects a new `PlayerData.rechargeBlocked` flag. All timing constants live in `Config.DarkReveal`.

**Tech Stack:** Lua, Playdate SDK, Noble Engine, existing FXshadow / UIHud / PlayerData architecture.

---

## File Map

| File | Change |
|------|--------|
| `source/assets/data/Config.lua` | Add `Config.DarkReveal` table |
| `source/assets/data/PlayerDataTables.lua` | Add `showFullLight` and `rechargeBlocked` to DefaultPlayerData |
| `source/entities/FX/FXshadow.lua` | Add `showFullLight` override block inside `refresh()` |
| `source/entities/player/abilities.lua` | Add `beginDarkCharge()`, `addDarkCrankDelta()`, `endDarkCharge()`, `activateDarkReveal()` |
| `source/entities/player/sanity.lua` | Guard `chargeBattery()` with `rechargeBlocked` check |
| `source/scenes/MazeScene.lua` | Modify `BButtonDown`, `BButtonUp`, and `cranked` callbacks |

---

## Task 1: Config constants

**Files:**
- Modify: `source/assets/data/Config.lua`

- [ ] **Step 1: Add DarkReveal config block after `Config.Dash`**

In `Config.lua`, after the `Config.Dash = { ... }` block (around line 64), insert:

```lua
-- Dark Reveal skill (hold B + crank in darkness)
Config.DarkReveal = {
    crankThreshold        = 720,   -- degrees of total crank rotation required
    revealDuration        = 3000,  -- ms the full light lasts after activation
    rechargeBlockDuration = 3000,  -- ms recharge is blocked after reveal ends
}
```

- [ ] **Step 2: Verify compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: no errors.

---

## Task 2: PlayerData flags

**Files:**
- Modify: `source/assets/data/PlayerDataTables.lua`

- [ ] **Step 1: Add flags to DefaultPlayerData**

In `PlayerDataTables.lua`, inside `local DefaultPlayerData = { ... }`, add after `showLightCone = false,` (line 55):

```lua
showFullLight    = false,  -- Dark Reveal skill active
rechargeBlocked  = false,  -- blocks crank battery recharge after Dark Reveal
```

- [ ] **Step 2: Verify compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: no errors.

---

## Task 3: FXshadow full-light override

**Files:**
- Modify: `source/entities/FX/FXshadow.lua`

- [ ] **Step 1: Add showFullLight to dirty-check in `refresh()`**

In `FXshadow:refresh()`, the change-detection block starts around line 60. Add `PlayerData.showFullLight` to the tracked state:

```lua
-- Add this local near the top of refresh(), alongside the other locals
local showFullLightValue = PlayerData.showFullLight == true
```

Add it to the early-return check:

```lua
if not self.shouldRefresh and
   battery == self.lastBattery and
   direction == self.lastDirection and
   ix == self.lastPlayerX and
   iy == self.lastPlayerY and
   lightSizeMulti == self.lastLightSizeMulti and
   globalLightAmountValue == self.lastGlobalLightAmountValue and
   showLightConeValue == self.lastShowLightConeValue and
   showFullLightValue == self.lastShowFullLightValue then   -- ADD THIS LINE
    return
end
```

Add to the tracking block:

```lua
self.lastShowFullLightValue = showFullLightValue   -- ADD THIS LINE
```

Also declare `self.lastShowFullLightValue = false` in `FXshadow:init()`, after line 24 (`self.lastShowLightConeValue = false`):

```lua
self.lastShowFullLightValue = false
```

- [ ] **Step 2: Add showFullLight override block in `refresh()`**

In `FXshadow:refresh()`, after the `showLightCone` override block (after line ~228, the block ending with `end`), insert:

```lua
-- Override for Dark Reveal skill (full level visibility)
if PlayerData.showFullLight == true then
    lightAmount = 0
    lightSourceAmount = 0
    globalLightAmount = 0
    globalDither = 0
    self.shouldRefresh = true
end
```

- [ ] **Step 3: Verify compile and visual**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"` then open simulator.
Temporarily set `PlayerData.showFullLight = true` in a dark room via debug and confirm full brightness. Revert.

---

## Task 4: Player dark skill methods

**Files:**
- Modify: `source/entities/player/abilities.lua`

- [ ] **Step 1: Add dark charge state initialization**

In `Player:init()` in `source/entities/player/init.lua`, after `self.isPlunging = false` (around line 91), add:

```lua
self.isDarkCharging  = false
self.darkCrankAccum  = 0
```

- [ ] **Step 2: Add `beginDarkCharge()` to abilities.lua**

In `source/entities/player/abilities.lua`, append:

```lua
function Player:beginDarkCharge()
    if not PlayerData.isInDarkness or not PlayerData.items.hasLamp then return end
    self.isDarkCharging = true
    self.darkCrankAccum = 0
    local state = math.random(0, 1) == 0 and 'crankClock' or 'crankAntiClock'
    self.uiHud.animation:setState(state)
    self.uiHud:setVisible(true)
end
```

- [ ] **Step 3: Add `addDarkCrankDelta()` to abilities.lua**

```lua
function Player:addDarkCrankDelta(delta)
    if not self.isDarkCharging then return end
    self.darkCrankAccum += math.abs(delta)
    self.uiHud:setRotation(math.random(-10, 10))
end
```

- [ ] **Step 4: Add `endDarkCharge()` to abilities.lua**

```lua
function Player:endDarkCharge()
    if not self.isDarkCharging then return end
    self.isDarkCharging = false
    self.uiHud:setRotation(0)
    self.uiHud:setVisible(false)
    if self.darkCrankAccum >= Config.DarkReveal.crankThreshold then
        self:activateDarkReveal()
    else
        self:useLampAbility()
    end
    self.darkCrankAccum = 0
end
```

- [ ] **Step 5: Add `activateDarkReveal()` to abilities.lua**

Note: do NOT call `shadow:refresh()` here — `shadow` is a MazeScene local. FXshadow's own `update()` calls `refresh()` every frame and the `showFullLight` block already sets `shouldRefresh = true`, so the visual updates on the next frame automatically.

```lua
function Player:activateDarkReveal()
    PlayerData.battery = 0
    PlayerData.rechargeBlocked = true
    PlayerData.showFullLight = true

    playdate.timer.performAfterDelay(Config.DarkReveal.revealDuration, function()
        PlayerData.showFullLight = false

        playdate.timer.performAfterDelay(Config.DarkReveal.rechargeBlockDuration, function()
            PlayerData.rechargeBlocked = false
        end)
    end)
end
```

- [ ] **Step 6: Verify compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: no errors.

---

## Task 5: Guard chargeBattery against rechargeBlocked

**Files:**
- Modify: `source/entities/player/sanity.lua`

- [ ] **Step 1: Add guard at the top of `chargeBattery()`**

In `sanity.lua`, `Player:chargeBattery(amount)` starts at line 42. Add a guard as the first line of the function:

```lua
function Player:chargeBattery(amount)
  if PlayerData.rechargeBlocked then return end   -- ADD THIS LINE
  if PlayerData.battery < 100 then
    self.animation:setState('charge')
  elseif PlayerData.battery >= 100 then
    self:idle()
  end
  PlayerData.battery += amount
  PlayerData.isActive = true
end
```

- [ ] **Step 2: Verify compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: no errors.

---

## Task 6: Wire input in MazeScene

**Files:**
- Modify: `source/scenes/MazeScene.lua`

- [ ] **Step 1: Modify `BButtonDown` to route darkness vs light**

Find `BButtonDown` (around line 528). The current `elseif` branch that calls `player:useAbility()` reads:

```lua
elseif PlayerData.isGaming == true and player.isAlive == true then
    player:useAbility()
end
```

Replace it with:

```lua
elseif PlayerData.isGaming == true and player.isAlive == true then
    if PlayerData.isInDarkness then
        player:beginDarkCharge()
    else
        player:useAbility()
    end
end
```

- [ ] **Step 2: Modify `BButtonUp` to end dark charge**

Find `BButtonUp` (around line 552). It is currently empty. Add:

```lua
BButtonUp = function()
    if player then player:endDarkCharge() end
end,
```

- [ ] **Step 3: Modify `cranked` to feed delta to dark skill**

Find the `cranked` callback (around line 671). After `if not player.isAlive then return end`, add an early branch that feeds crank delta to the skill and skips normal battery charge:

```lua
cranked = function(change, acceleratedChange)
    crankIsMoving = true
    crankStopTimer = 0

    local ticksValue = playdate.getCrankTicks(4)
    if not player.isAlive then return end

    -- Dark Reveal crank charging: accumulate and wobble HUD
    if player.isDarkCharging then
        player:addDarkCrankDelta(change)
        return
    end

    if ticksValue > 0 then
        player:burnCalories(1)
    end

    if PlayerData.isGaming == true then
        if ticksValue > 0 then
            if PlayerData.battery < 100 and PlayerData.readyToShrink == false and PlayerData.isTiny == false then
                player:chargeBattery(3)
                if shadow then
                    shadow:refresh()
                end
            end
        end
    else
        -- existing minifier/shrink logic continues unchanged below
```

> **Note:** Only add the `if player.isDarkCharging then ... return end` block and leave the rest of the `cranked` function untouched.

- [ ] **Step 4: Final compile**

Run: `pdc source "DinoPirates from inner space Brocolation.pdx"`
Expected: no errors.

- [ ] **Step 5: Simulator validation**

Open `"DinoPirates from inner space Brocolation.pdx"` in the simulator. In a dark room with lamp equipped and `canFlash = true`:

1. **Tap B** (no crank) → lightBurst fires (cone flash). ✓
2. **Hold B + crank slowly (< 720°) + release** → lightBurst fires. ✓
3. **Hold B + crank 2 full rotations (≥ 720°) + release** → full light for 3 s, battery drops to 0, crank does not recharge battery during block, recharge resumes after ~6 s total. ✓
4. **UIHud** shows crankClock or crankAntiClock randomly on B press and wobbles during crank. ✓
5. In a lit room, B fires plungerang as before. ✓
