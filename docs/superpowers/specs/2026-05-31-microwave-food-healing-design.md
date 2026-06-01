# Microwave + Food Healing — Design Spec

**Date:** 2026-05-31
**Status:** Approved, ready for implementation
**Game:** DinoPirates from inner space (Playdate / Noble Engine / Lua)

---

## 1. Goal

Add a **survival-flavored health recovery** system. The player picks up raw
**food** in the world and **cooks it at a microwave station** by cranking, which
fills health point by point. Healing is deliberate, vulnerable, and economy-driven —
no scattered instant pickups, no passive regen.

This complements the only other heal in the game (winning a DanceScene already gives
`+healedHP` and kills the enemy).

---

## 2. Core loop

1. **Pick up food** (LDtk item) → `PlayerData.food += Config.Microwave.perPickup` (clamped to `carryMax`). Raw food does **not** heal on its own.
2. **Stand on a microwave** (LDtk prop) → it arms, exactly like the minifier (`readyToCook`).
3. **Press A** → `startCooking()`: locks gameplay (`isGaming=false`), centers the player on the microwave, shows the crank prompt.
4. **Crank** → each `crankPerFood` of accumulated crank consumes 1 food:
   - `healthPoints += hpPerFood` (clamped to `Config.Player.maxHealthPoints = 10`),
   - `calories += caloriesPerFood` (clamped to `Config.Dance.caloriesMax = 500`).
   - The **health indicator filling up is the only feedback** — there is **no food HUD** in v1.
5. Cooking **auto-stops** when health is full (10) or food runs out; **B** also stops it (`finishCooking()`).
6. Walking off the microwave clears the armed state (`checkMicrowave()`).

### Emergent tension (intended, not extra code)
Cooking raises `calories` as a byproduct, and `calories` already weight the DanceScene
difficulty-upgrade probability (`caloriesNorm × weightCalories`). So **healing makes the
next dance harder** — survival risk/reward, for free.

### Turn-based friction (already exists)
Cranking sets `PlayerData.isActive`, so enemies/crew advance while you cook. No new code
needed; designers place microwaves in safe-ish rooms.

---

## 3. Configuration (all tunable — `Config.Microwave`)

Add a new block in `assets/data/Config.lua`:

```lua
Config.Microwave = {
    hpPerFood       = 1,   -- HP restored per food cooked (1:1 for now; tune later)
    caloriesPerFood = 1,   -- calories gained per food cooked (byproduct; tune later)
    carryMax        = 10,  -- max food the player can carry
    perPickup       = 1,   -- food granted per food item picked up
    crankPerFood    = 90,  -- degrees of crank accumulated to cook 1 food
}
```

Also add the health cap to `Config.Player`:

```lua
-- in Config.Player
maxHealthPoints = 10,  -- hard cap on healthPoints (HUD draws up to 10 dots)
```

> Per the user: keep everything 1:1 for now (`hpPerFood = 1`, `caloriesPerFood = 1`)
> and tune later. All values live in Config — never hard-code.

---

## 4. Data model

### `PlayerData` (`assets/data/PlayerDataTables.lua`)
- Add `food = 0,` near `calories`/`steps`.
- Persisted automatically (SaveSystem saves the whole `PlayerData` table; `save.lua:187`).
- **Defensive reads:** old saves replace the whole table on load (`SaveSystem` line ~235), so always read `(PlayerData.food or 0)` to survive pre-feature saves.

### Player instance fields (`entities/player/init.lua`)
- `self.currentMicrowave = nil` (mirror of `self.currentMinifier`).
- `self.cookProgress = 0` (transient crank accumulator; mirror of how `actualPlayerSize` accumulates).

### `readyToCook`
- Add `readyToCook = false` to `PlayerData` (mirror of `readyToShrink`). It gates the A/B/crank routing.

---

## 5. Entities

### 5.1 Food item — extend `Items` (`entities/items/Items.lua` + `entities/player/items.lua`)
- Add a new `food` animation/type following the existing pattern (boots/plunger/lamp/notes/keycard/itemgift/radio). Pick the next free frame range in the item imagetable (implementer: confirm the sprite sheet; if no art exists yet, reuse an existing placeholder frame and leave a `-- TODO art` note).
- Pickup routing (collisions / item grab) calls a new `Player:grabFood()`:
  ```lua
  function Player:grabFood()
    PlayerData.food = math.min((PlayerData.food or 0) + Config.Microwave.perPickup, Config.Microwave.carryMax)
  end
  ```
- Collected state persisted per `iid` like every other item (so each placed food is grabbed once and does not respawn). Many food items may be placed.

### 5.2 Microwave — new `PropItem` type `'microwave'` (`entities/props/propItem.lua`)
Mirror the `'minifier'` type exactly:
- Add an animation state for `'microwave'` (next free frame in the prop imagetable; `-- TODO art` if none).
- Add a `microwave = { collideRect = {...} }` entry in the type→collideRect table (use the minifier's rect as a starting point).
- Add `'microwave'` to the **non-blocking / overlap** branch alongside `'minifier'` (`propItem.lua:96` `if self.nocollide or self.isDestroyed or self.type == 'minifier' then`) so the player can stand on it.
- Reusable, no per-use state to persist.

---

## 6. Wiring (mirror the minifier)

### 6.1 Collision — arm the microwave (`entities/player/collisions.lua`)
Next to the existing minifier branch (`collisions.lua:135`):
```lua
elseif other:isa(PropItem) and other.type == 'microwave' then
  self.currentMicrowave = other
  PlayerData.readyToCook = true
```

### 6.2 Player state (`entities/player/state.lua`)
Add three functions mirroring `startMinifying` / `finishMinifying` / `checkMinifier`:

- `Player:startCooking()` — guard on `self.currentMicrowave`, `isGaming`, not talking, **and `(PlayerData.food or 0) > 0` and `healthPoints < maxHealthPoints`** (don't enter if nothing to do). Lock `isGaming=false`, center on the microwave, show crank prompt (`self.uiHud:setCrankClock()` / `showUIHUD()`), reset `self.cookProgress = 0`. (Future hook: set a distinct cooking player animation + HUD state — out of scope for v1, leave a comment.)
- `Player:finishCooking()` — unlock `isGaming=true`, hide the crank prompt, reset `self.cookProgress = 0`. Mirror `finishMinifying`'s cleanup.
- `Player:checkMicrowave()` — mirror `checkMinifier`: if the player no longer overlaps `currentMicrowave`, hide prompt, `currentMicrowave=nil`, `readyToCook=false`.
- Call `self:checkMicrowave()` in the player update alongside `self:checkMinifier()` (`state.lua:304`).
- Clamp on heal: add a `healthPoints` upper clamp in `Player:update()` next to the existing battery clamp: `if PlayerData.healthPoints > Config.Player.maxHealthPoints then PlayerData.healthPoints = Config.Player.maxHealthPoints end`.

### 6.3 MazeScene input (`scenes/MazeScene.lua`)
- **A button** (`AButtonDown`, near `readyToShrink` trigger at line ~517): add
  `if PlayerData.readyToCook == true and PlayerData.isGaming == true then player:startCooking() end`
  (independent `if`, same style as the minifier trigger).
- **B button** (`BButtonDown`, near line ~543): add an `elseif PlayerData.isGaming == false and PlayerData.readyToCook == true then player:finishCooking()` branch (place it consistently with the minifier `finishMinifying` branch).
- **Crank** (`cranked`, the `else`/locked branch where the minifier crank lives, ~703-731): add a cooking branch gated by `PlayerData.readyToCook`:
  ```lua
  if PlayerData.readyToCook == true then
    if ticksValue ~= 0 then
      player.cookProgress = (player.cookProgress or 0) + math.abs(ticksValue)
      while player.cookProgress >= Config.Microwave.crankPerFood
            and (PlayerData.food or 0) > 0
            and PlayerData.healthPoints < Config.Player.maxHealthPoints do
        player.cookProgress -= Config.Microwave.crankPerFood
        PlayerData.food -= 1
        PlayerData.healthPoints = math.min(PlayerData.healthPoints + Config.Microwave.hpPerFood, Config.Player.maxHealthPoints)
        PlayerData.calories = math.min((PlayerData.calories or 0) + Config.Microwave.caloriesPerFood, Config.Dance.caloriesMax)
      end
      -- Auto-finish when full or out of food
      if PlayerData.healthPoints >= Config.Player.maxHealthPoints or (PlayerData.food or 0) <= 0 then
        player:finishCooking()
      end
    end
  end
  ```
  > Implementer: match the surrounding indentation/style and confirm `ticksValue` is the
  > same crank measure the minifier branch uses (`playdate.getCrankTicks(...)`). If the
  > minifier uses raw `change` degrees instead, use the same measure and set
  > `crankPerFood` accordingly.

### 6.4 Clamp the existing dance-win heal (`scenes/DanceScene.lua`)
At line ~448 (`PlayerData.healthPoints += PlayerData.healedHP`), clamp to the cap:
```lua
PlayerData.healthPoints = math.min(PlayerData.healthPoints + PlayerData.healedHP, Config.Player.maxHealthPoints)
```

### 6.5 Calorie clamp (cleanup)
Now that calories are gained deliberately (and the "top 500" was only a comment), enforce a
real clamp wherever calories increase: the cook loop (above) already clamps; also clamp the
DanceScene win gain (`DanceScene.lua:455` `PlayerData.calories += 60`) to
`Config.Dance.caloriesMax`.

---

## 7. HUD / feedback
- **No food HUD in v1.** The `HealthIndicator` (`entities/UI/healthIndicator.lua`) already
  reads `PlayerData.healthPoints` every frame and draws up to 10 dots, so it fills live as
  cooking adds HP — that is the feedback.
- Future (explicitly out of scope, leave hooks/comments only): a distinct HUD state and a
  distinct player "cooking" animation while `readyToCook` + locked.

---

## 8. Persistence
- `PlayerData.food` and `PlayerData.readyToCook`: saved with the whole `PlayerData` table.
  (`readyToCook` is transient gameplay state; harmless if saved, but it is reset by
  `checkMicrowave()` on the next room/update. Optional: reset `readyToCook=false` on room
  enter for safety.)
- Food items: collected flag per `iid` (existing item persistence).
- Microwave prop: no per-use state.

---

## 9. Edge cases
- Cooking with 0 food or at full HP: `startCooking()` refuses to enter.
- Health never exceeds `maxHealthPoints` (clamped in cook loop, dance heal, and `Player:update`).
- Food never exceeds `carryMax` (clamped on pickup).
- Calories never exceed `caloriesMax` (clamped on cook and dance gain).
- Cranking the microwave still advances enemies via `isActive` (inherited; intended).
- Old saves without `food`: all reads use `(PlayerData.food or 0)`.

---

## 10. Files touched
**Code:**
- `assets/data/Config.lua` — `Config.Microwave` block; `Config.Player.maxHealthPoints`.
- `assets/data/PlayerDataTables.lua` — `food = 0`, `readyToCook = false`.
- `entities/player/init.lua` — `currentMicrowave`, `cookProgress`.
- `entities/items/Items.lua` + `entities/player/items.lua` — `food` item type + `grabFood()`.
- `entities/props/propItem.lua` — `microwave` prop type (anim, collideRect, overlap).
- `entities/player/collisions.lua` — arm microwave on overlap.
- `entities/player/state.lua` — `startCooking`, `finishCooking`, `checkMicrowave`, update hook, HP clamp.
- `scenes/MazeScene.lua` — A/B/crank routing for cooking.
- `scenes/DanceScene.lua` — clamp dance-win HP and calorie gain.

**Docs (separate pass):**
- New `source/DOCS/MICROWAVE_AND_FOOD.md`.
- Update `PLAYER_SYSTEMS.md`, `CONFIG_REFERENCE.md`, `PLAYERDATA_REFERENCE.md`, `PROPS_AND_ITEMS.md`, `INPUT_SYSTEM.md`, `DATA_FLOW.md`, and the docs list in `CLAUDE.md`.

---

## 11. Verification
- Compile with `pdc source "DinoPirates from inner space Brocolation.pdx"`; must be clean (no errors/warnings).
- No git commit (project rule: the user commits manually).
