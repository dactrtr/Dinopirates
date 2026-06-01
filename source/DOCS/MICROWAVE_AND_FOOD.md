# Microwave + Food Healing

A survival-flavored health recovery system. The player picks up raw **food** in the
world and **cooks it at a microwave station** by cranking, which fills health one point
at a time. Healing is deliberate, vulnerable, and economy-driven — there is no scattered
instant pickup and no passive regen.

This complements the only other heal in the game: winning a `DanceScene` restores
`PlayerData.healedHP` (now clamped to the health cap) and kills the enemy.

The mechanic deliberately **mirrors the minifier** (`PROPS_AND_ITEMS.md` §2): a collision
arms it, **A** starts it, the **crank** drives it, **B** or auto-completion finishes it,
and walking off clears it. If you understand the minifier flow, you understand this one.

All file paths are relative to `source/`.

---

## 1. Core Loop

```
1. Pick up a `food` item            → PlayerData.food += perPickup (clamped to carryMax)
2. Stand on a `microwave` prop      → PlayerData.readyToCook = true ("Press A" HUD)
3. Press A → startCooking()         → isGaming = false, player centered, crank prompt
4. Crank                            → each crankPerFood ticks consumes 1 food:
                                        healthPoints += hpPerFood   (clamped to maxHealthPoints)
                                        calories     += caloriesPerFood (clamped to caloriesMax)
5. Auto-finish at full HP or 0 food; B also finishes → finishCooking()
6. Walk off the microwave           → checkMicrowave() clears the armed state
```

Raw food does **not** heal on its own — it must be cooked.

---

## 2. The Food Resource

`PlayerData.food` (default `0`) is a simple integer counter of raw food carried. It is
**not** a per-instance inventory — every food item picked up adds to the same counter.

### Pickup — `Player:grabFood()` (`entities/player/items.lua`)

```lua
function Player:grabFood()
  PlayerData.food = math.min((PlayerData.food or 0) + Config.Microwave.perPickup, Config.Microwave.carryMax)
end
```

- Adds `Config.Microwave.perPickup` (1) per pickup.
- Clamped to `Config.Microwave.carryMax` (10). Picking up food at the cap is a no-op for
  the counter (the item is still consumed/persisted).
- Uses the defensive `(PlayerData.food or 0)` form so pre-feature saves don't error.

### Food `Items` type (`entities/items/Items.lua`)

`food` is a standard `Items` type alongside `boots`/`plunger`/`lamp`/`notes`/etc.

```lua
-- TODO art: dedicated food frames; reuse 'notes' frames (10-12) as a placeholder for now
self.animation:addState('food', 10, 12)
self.animation.food.frameDuration = 8
```

- **Placeholder art**: the `food` type currently reuses the `notes` frames (10–12) on the
  shared `assets/images/items/items-key` sheet — flagged `-- TODO art` in code.
- The `Items` constructor takes an extra `iid` parameter, stored as `self.iid`, used for
  per-instance persistence (see §6).

### Pickup routing (`entities/player/collisions.lua`)

```lua
elseif other:isa(Items) and other.type == 'food' then
  if other.iid then findAndCollectItemById(other.iid) end
  other:removeAll()
  self:grabFood()
return 'overlap'
```

Unlike most item branches, the food branch first marks the LDtk entity as `collected` by
its `iid` (via `findAndCollectItemById`) before removing the sprite and granting the food.
That is what lets many food items coexist and each be grabbed exactly once.

---

## 3. The Microwave Prop

A new `PropItem` type `'microwave'` (`entities/props/propItem.lua`), modeled on the
`'minifier'`.

| Aspect | Value | Notes |
|---|---|---|
| Animation frame | `15` | Pre-existing prop frame reused (`-- TODO art` for a dedicated frame) |
| `collideRect` | `{0, 12, 32, 18}` | Low rect, same as the minifier — player enters from above |
| Z-index | static `ZIndex.props` | Listed in the static-Z branch alongside `minifier` |
| Collision | overlap (non-blocking) | Listed in the overlap branch alongside `minifier` |

```lua
-- propConfigs
microwave = { collideRect = {0, 12, 32, 18} }, -- TODO art: dedicated frame (reuses 'microwave' frame 15)

-- static Z-index / overlap branch
if self.nocollide or self.isDestroyed or self.type == 'minifier' or self.type == 'microwave' then
  self.isStaticZIndex = true
  self:setZIndex(ZIndex.props)
end
```

Because the collideRect is active but the type is in the overlap branch, the player can
stand on the microwave (the collision resolves to `'overlap'` in `collisions.lua`) instead
of being blocked. The microwave is **reusable** and has **no per-use state to persist**.

---

## 4. The Cooking Flow (mirrors the minifier)

### Step 1: Overlap detection — `collisions.lua`

```lua
elseif other:isa(PropItem) and other.type == 'microwave' then
  self.currentMicrowave = other
  PlayerData.readyToCook = true
  self:showUIHUD()
  self.uiHud:setPressA()
return 'overlap'
```

Stores the machine reference, raises the `readyToCook` flag, and shows the "Press A"
prompt. The player can still walk away at this point — `checkMicrowave()` (step 5) clears
the state if they do.

### Step 2: A button → `startCooking()` (`entities/player/state.lua`)

`AButtonDown` in `MazeScene` (independent `if`, same style as the minifier trigger):

```lua
if PlayerData.readyToCook == true and PlayerData.isGaming == true then
  player:startCooking()
end
```

```lua
function Player:startCooking()
    if not self.currentMicrowave or PlayerData.isTalking or not PlayerData.isGaming then return end
    -- Big-only: the tiny player can't operate the microwave.
    if PlayerData.isTiny then return end
    -- Nothing to do? Don't enter cooking.
    if (PlayerData.food or 0) <= 0 or PlayerData.healthPoints >= Config.Player.maxHealthPoints then return end

    PlayerData.isGaming = false        -- locks movement/abilities
    self.triggerEnteredOnce = true     -- stops trigger checks

    -- Auto center on microwave (10px above center)
    local targetX = self.currentMicrowave.x
    local targetY = self.currentMicrowave.y - 10
    self:moveTo(targetX, targetY)
    if shadow then shadow:moveTo(targetX, targetY) end

    -- Show crank prompt
    -- Future hook: distinct cooking player animation + HUD state (out of scope for v1).
    self.uiHud:setCrankClock()
    self:showUIHUD()

    self.cookProgress = 0              -- reset crank accumulator
end
```

Refuse-to-enter guards (returns without acting if any is true):
- `self.currentMicrowave` is nil
- `PlayerData.isTalking == true`
- `PlayerData.isGaming == false`
- **`PlayerData.isTiny == true`** — cooking is big-only (the tiny player can't use the microwave)
- **`(PlayerData.food or 0) <= 0`** — nothing to cook
- **`PlayerData.healthPoints >= Config.Player.maxHealthPoints`** — already full

The "Press A" prompt is likewise suppressed for a tiny player (the microwave-arm branch in
`collisions.lua` only shows it when `not PlayerData.isTiny`), so a tiny player never sees a
prompt for an action they can't perform.

Unlike the minifier, the crank prompt is always `setCrankClock()` (one direction only —
there is no "uncook").

### Step 3: Crank drives cooking — `MazeScene.cranked` (the locked `else` branch)

The cooking logic lives in `MazeScene.inputHandler.cranked`, in the same locked
(`isGaming == false`) branch where the minifier crank lives. `getCrankTicks(4)` divides
one revolution into 4 integer ticks (~90° each).

```lua
-- inside the `else` (isGaming == false) branch
if PlayerData.readyToCook == true then
  if ticksValue ~= 0 then
    player.cookProgress = (player.cookProgress or 0) + math.abs(ticksValue)
    while player.cookProgress >= Config.Microwave.crankPerFood
        and (PlayerData.food or 0) > 0
        and PlayerData.healthPoints < Config.Player.maxHealthPoints do
      player.cookProgress -= Config.Microwave.crankPerFood
      PlayerData.food -= 1
      PlayerData.healthPoints = math.min(PlayerData.healthPoints + Config.Microwave.hpPerFood, Config.Player.maxHealthPoints)
      PlayerData.calories     = math.min((PlayerData.calories or 0) + Config.Microwave.caloriesPerFood, Config.Dance.caloriesMax)
    end
    -- Auto-finish when full or out of food
    if PlayerData.healthPoints >= Config.Player.maxHealthPoints or (PlayerData.food or 0) <= 0 then
      player:finishCooking()
    end
  end
end
```

- Crank ticks accumulate (absolute value — direction is irrelevant) into `player.cookProgress`.
- Each `Config.Microwave.crankPerFood` (1 tick, ~90°) of accumulated crank consumes 1 food
  and grants `hpPerFood` HP + `caloriesPerFood` calories, both clamped.
- The `while` loop drains multiple foods in one callback if the crank is spun fast and there
  is food + HP headroom.
- After draining, if HP is full or food is exhausted, cooking auto-finishes.

### Step 4: `finishCooking()` (`entities/player/state.lua`)

```lua
function Player:finishCooking()
    PlayerData.isGaming = true
    self.triggerEnteredOnce = false
    self.uiHud:setVisible(false)
    self.cookProgress = 0
end
```

Unlocks movement, re-enables triggers, hides the prompt, and resets the accumulator. Called
automatically (full HP / out of food) or manually via **B**.

`BButtonDown` in `MazeScene` (placed alongside the minifier `finishMinifying` branch):

```lua
elseif PlayerData.isGaming == false and PlayerData.readyToCook == true then
  player:finishCooking()
```

### Step 5: `checkMicrowave()` — exiting the area (`entities/player/state.lua`)

Called every frame in `Player:update()` alongside `self:checkMinifier()`:

```lua
function Player:checkMicrowave()
    if self.currentMicrowave then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentMicrowave then
                stillInside = true
                break
            end
        end
        if not stillInside then
            self.uiHud:setVisible(false)
            self.currentMicrowave = nil
            PlayerData.readyToCook = false
        end
    end
end
```

If the player has left the microwave overlap without starting (still `isGaming == true`),
the reference and flag are cleared and the prompt is hidden.

---

## 5. Conversion Math + Config

All tunables live in `Config.Microwave` (`assets/data/Config.lua`); the health cap lives in
`Config.Player`.

| Field | Value | Unit | Description |
|---|---|---|---|
| `Microwave.hpPerFood` | `1` | HP | HP restored per food cooked (1:1 for now; tune later) |
| `Microwave.caloriesPerFood` | `1` | calories | Calories gained per food cooked (byproduct; tune later) |
| `Microwave.carryMax` | `10` | food | Max food the player can carry |
| `Microwave.perPickup` | `1` | food | Food granted per food item picked up |
| `Microwave.crankPerFood` | `1` | **crank ticks** | Crank ticks (`getCrankTicks(4)`, ~90° each) to cook 1 food — **NOT degrees** |
| `Player.maxHealthPoints` | `10` | HP | Hard cap on `healthPoints` (HUD draws up to 10 dots) |

> `crankPerFood` is measured in **crank ticks**, not degrees. The crank handler uses
> `playdate.getCrankTicks(4)`, so 1 tick is one quarter-turn (~90°). At the default of `1`,
> one quarter-turn cooks one food.

> Everything is intentionally 1:1 (`hpPerFood = 1`, `caloriesPerFood = 1`) for now; tune
> later. Never hard-code these — they all belong in `Config`.

The health cap is also enforced redundantly in `Player:update()`:

```lua
if PlayerData.healthPoints > Config.Player.maxHealthPoints then
  PlayerData.healthPoints = Config.Player.maxHealthPoints
end
```

and on the `DanceScene` win heal (`DanceScene.lua`):

```lua
PlayerData.healthPoints = math.min(PlayerData.healthPoints + PlayerData.healedHP, Config.Player.maxHealthPoints)
```

---

## 6. The Calorie-Burn-Skip Nuance (important)

The generic `cranked` handler normally burns 1 calorie per positive tick:

```lua
if ticksValue > 0 then player:burnCalories(1) end
```

This burn is **skipped while cooking**. The handler computes:

```lua
local isCooking = (PlayerData.isGaming == false and PlayerData.readyToCook == true)
if ticksValue > 0 and not isCooking then
  player:burnCalories(1)
end
```

Why: at the current 1:1 tuning, the per-tick burn would exactly cancel the cooking calorie
byproduct (`caloriesPerFood`), so cooking would have **no** net calorie effect. Guarding the
burn while cooking makes the cooking byproduct the only calorie change during cooking, so
the intended tension (below) actually fires.

---

## 7. Emergent Difficulty Tension (intended, no extra code)

Cooking raises `PlayerData.calories` as a byproduct, and `calories` is one of the three
inputs to the `DanceScene` difficulty-upgrade probability
(`caloriesNorm × Config.Dance.weightCalories`, see `DANCE_SCENE.md`). So **healing makes the
next dance harder** — a built-in risk/reward, achieved purely through existing systems.

Additionally, cranking sets `PlayerData.isActive`, which is the turn-based signal that lets
enemies and crew advance. So **you are vulnerable while cooking** — every crank tick moves
the world. Designers are expected to place microwaves in relatively safe rooms.

---

## 8. Persistence

| State | How it persists |
|---|---|
| `PlayerData.food` | Saved with the whole `PlayerData` table (`SaveSystem.save()`) |
| `PlayerData.readyToCook` | Saved with `PlayerData`; transient — reset by `checkMicrowave()` on the next update/room |
| Food `Items` | `collected = true` per `iid` in `levelsLDTK` (via `findAndCollectItemById`); skipped on respawn |
| Microwave prop | No per-use state |

### Food spawn gating (`scenes/MazeScene.lua`)

```lua
elseif itemType == "food" then
  -- Food is stackable: persist per-iid via the 'collected' flag
  shouldGenerate = cf.collected ~= true
```

A food item spawns only if its LDtk `collected` flag is not `true`.

### `findAndCollectItemById(iid)` (`utilities/Utilities.lua`)

```lua
function findAndCollectItemById(itemId)
  local room = PlayerData.floor
  -- ... iterate entities in levelsLDTK[room] ...
  if cf.isItem == true and item.iid == itemId then
    cf.collected = true
    return
  end
end
```

Locates the item entity in the current room by `iid` and sets `collected = true` so the
save system persists it.

### Defensive reads

Loading replaces the whole `PlayerData` table, so older saves may lack `food`. Every read
uses `(PlayerData.food or 0)` to survive pre-feature saves.

---

## 9. HUD / Feedback

There is **no food HUD in v1.** The only feedback is the existing `HealthIndicator`
(`entities/UI/healthIndicator.lua`), which reads `PlayerData.healthPoints` each frame and
draws up to 10 dots — so it fills live as cooking adds HP.

A distinct "cooking" player animation and a dedicated HUD state are noted **future hooks**
(a comment in `startCooking()` marks the spot) and are explicitly out of scope for v1.

---

## 10. Edge Cases

- **Cooking with 0 food or at full HP**: `startCooking()` refuses to enter.
- **Cooking while tiny**: blocked — cooking is big-only. The "Press A" prompt is also hidden while tiny.
- **HP never exceeds `maxHealthPoints`**: clamped in the cook loop, the dance-win heal, and
  `Player:update()`.
- **Food never exceeds `carryMax`**: clamped on pickup.
- **Calories never exceed `caloriesMax`**: clamped in the cook loop and the dance-win
  `+60` gain (`DanceScene.lua`).
- **Cranking while cooking still advances enemies** via `isActive` (inherited; intended).
- **Old saves without `food`**: all reads use `(PlayerData.food or 0)`.
- **Spinning the crank fast**: the `while` loop cooks multiple foods in one callback, bounded
  by available food and HP headroom; leftover crank stays in `cookProgress`.

---

## 11. Notes for Love2D Port

### Crank → Key / Mouse Wheel

`getCrankTicks(4)` maps to discrete ticks. In Love2D, drive `cookProgress` from a key (e.g.
**E**) or the mouse wheel while in the cooking state:

```lua
-- while state == "cooking"
function cookTick(ticks)   -- ticks: integer, e.g. 1 per keypress / wheel notch
  cookProgress = cookProgress + math.abs(ticks)
  while cookProgress >= Config.Microwave.crankPerFood
      and PlayerData.food > 0
      and PlayerData.healthPoints < Config.Player.maxHealthPoints do
    cookProgress = cookProgress - Config.Microwave.crankPerFood
    PlayerData.food = PlayerData.food - 1
    PlayerData.healthPoints = math.min(PlayerData.healthPoints + Config.Microwave.hpPerFood, Config.Player.maxHealthPoints)
    PlayerData.calories     = math.min(PlayerData.calories + Config.Microwave.caloriesPerFood, Config.Dance.caloriesMax)
  end
  if PlayerData.healthPoints >= Config.Player.maxHealthPoints or PlayerData.food <= 0 then
    finishCooking()
  end
end
```

- Remember to **skip the generic per-tick calorie burn while cooking** (§6), or the byproduct
  cancels out at 1:1.
- The microwave overlap detection is the same AABB "stand-on, non-blocking" pattern as the
  minifier — use a bump.lua `"cross"` filter (see `PROPS_AND_ITEMS.md` §6).
- `Config.Microwave` and `Config.Player.maxHealthPoints` are pure data — copy as-is.
- Food persistence is the same per-`iid` `collected` flag as other items.
