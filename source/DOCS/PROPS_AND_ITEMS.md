# Props and Items — Comprehensive Documentation

This documentation covers all interactive object systems, collectibles, portal doors, and the minifier machine. All file paths are relative to `source/`.

---

## 1. PropItem System

**File**: `entities/props/propItem.lua`

`PropItem` extends `NobleSprite`. It is initialized with `PropItem:init(x, y, type, zIndex, nocollide, isDestroyed, id)`.

### 1.1 Sprite Sheet

All props share a single image sheet: `assets/images/props/props`. The Playdate SDK automatically appends the `-table-WxH` suffix. Each prop is a 32×32 px tile.

### 1.2 Full Type and Frame Table

| `type` field     | Frame(s) | Notes |
|------------------|----------|-------|
| `chair`          | 1        | Normal chair |
| `fellchair`      | 2        | Fallen chair |
| `box`            | 3        | Destructible box (the only type the plungerang can smash) |
| `trash`          | 4        | Trash can |
| `toxic`          | 5        | Toxic barrel |
| `table`          | 6        | Large table |
| `fellTable`      | 7        | Fallen table |
| `blood`          | 8        | Blood stain variant 1 |
| `blood2`         | 9        | Blood stain variant 2 |
| `deadrat`        | 10       | Dead rat (decoration) |
| `xtree-1`        | 11       | Christmas tree variant 1 |
| `xtree-2`        | 12       | Christmas tree variant 2 |
| `xtree-3`        | 13       | Christmas tree variant 3 |
| `xtree-4`        | 14       | Christmas tree variant 4 |
| `microwave`      | 15       | Microwave — cooking station; stand on it to heal (see section 2.5). Reuses frame 15 as placeholder art |
| `gifts`          | 16       | Gift pile |
| `gift`           | 17       | Single gift |
| `smallTable`     | 18       | Small table |
| `fridge1`        | 19       | Refrigerator variant 1 |
| `fridge2`        | 20       | Refrigerator variant 2 |
| `kitchenStorage` | 21       | Kitchen cabinet |
| `pot`            | 22       | Pot / planter |
| `knifeKettle`    | 23       | Knife and kettle |
| `debris`         | 33       | Debris (post-destruction state) |
| `pcBase`         | 34       | PC base variant 1 |
| `pcScreen`       | 35       | PC screen variant 1 |
| `pcBase2`        | 36       | PC base variant 2 |
| `pcLoad`         | 37-39    | PC loading screen (animation, frameDuration=12) |
| `pcBase3`        | 40       | PC base variant 3 |
| `pcScreen2`      | 41       | PC screen variant 2 |
| `pcScreen3`      | 42       | PC screen variant 3 |
| `pcSiriSad`      | 43       | Sad Siri screen |
| `pcSiriHappy`    | 44       | Happy Siri screen |
| `minifier`       | 45       | Minifier machine (see section 2) |
| `pneumaticTube`  | 47       | Pneumatic tube — `isTube=true`, not edible |
| `Tube`           | 48       | Internal tube section |
| `TubeExit`       | 49       | Tube exit |

### 1.3 Collision Rects by Type

When `nocollide == false`, the collision rect is applied according to the `propConfigs` table. If a type does not appear in the table, the default rect is used.

| Type | collideRect (x, y, w, h) | Notes |
|------|--------------------------|-------|
| `minifier` | `{0, 12, 32, 18}` | Low rect so the player can enter from above |
| `microwave` | `{0, 12, 32, 18}` | Same low rect as the minifier; player stands on it to cook (see section 2.5) |
| `pneumaticTube` | `{4, 10, 24, 22}` | isTube=true, isEdible=false; no active collideRect because isTube bypasses the default path |
| `xtree-1` | `{2, 30, 28, 12}` | Collider at the base of the tree |
| `xtree-2` | `{2, 30, 28, 12}` | Same as xtree-1 |
| `pcScreen` | `{2, 30, 28, 12}` | Only the screen base collides |
| `pcScreen2` | `{2, 30, 28, 12}` | Same |
| `pcScreen3` | `{2, 30, 28, 12}` | Same |
| `pcLoad` | `{2, 30, 28, 12}` | Same |
| `pcSiriHappy` | `{2, 30, 28, 12}` | Same |
| `pcSiriSad` | `{2, 30, 28, 12}` | Same |
| All others | `{2, 10, 28, 18}` | Default rect centered in the middle of the sprite |

Exact code logic:

```lua
if self.nocollide == false then
  if config.collideRect then
    self:setCollideRect(table.unpack(config.collideRect))
  elseif not self.isTube then
    self:setCollideRect(2, 10, 28, 18)  -- default
  end
end
```

If `nocollide == true` (or the prop is destroyed), no collideRect is registered.

The `Tube` type additionally calls `self:clearCollideRect()` explicitly after init, removing any collision.

### 1.4 Z-index: Static vs Dynamic

The system distinguishes two Z modes:

**Static Z-index** (`isStaticZIndex = true`): the sprite is fixed at `ZIndex.props` (value `2`) and does not change frame to frame. Conditions that activate static Z:

- `nocollide == true`
- `isDestroyed == true`
- `type == 'minifier'`
- `type == 'microwave'`

Special exception: the `Tube` type has a static Z fixed at `700` (hardcoded value, not `ZIndex.props`).

**Dynamic Z-index** (all others): every frame `update()` executes:

```lua
self:setZIndex(self.y)
```

This produces the pseudo-3D effect in which objects lower on screen are drawn over those higher up.

All props are registered in collision group `3` (group `props`, per `Config.CollideGroups`).

### 1.5 `isTube` Flag

The `isTube` flag is activated only for the `pneumaticTube` type. Effects:

- No default collideRect is assigned (the `elseif not self.isTube` block excludes it).
- Prints a debug message when created: `"Pneumatic Tube created: pneumaticTube at X Y"`.
- The `Tube` type (internal tube sections) also clears the rect with `clearCollideRect()` and uses ZIndex 700.
- The `TubeExit` type uses the default configuration without isTube.

Tube transport functionality is not in `propItem.lua` — it is handled by the trigger system or player collision system.

### 1.6 `isEdible` Flag

By default all props have `isEdible = true`. Only `pneumaticTube` forces it to `false` via `propConfigs`. Enemies with `powerLevel >= Config.Enemy.eatPropPowerThreshold` (25) can eat edible props; doing so costs them `Config.Enemy.eatPropPowerPenalty` (5) power levels.

### 1.7 destroyProp(id)

```lua
function PropItem:destroyProp(id)
  findAndDestroyPropById(id)    -- marks the prop as destroyed in levelsLDTK
  self:clearCollideRect()       -- removes collision
  self:setZIndex(ZIndex.props)  -- drops to the static background Z
  self.animation:setState('debris')  -- changes the sprite to debris
end
```

`findAndDestroyPropById(id)` is a utility function that locates the entity by its LDtk `iid` within the global `levelsLDTK` table and sets the `destroyed = true` field. On the next visit to the room, `MazeScene` skips spawning props with `destroyed == true`.

### 1.8 smash()

```lua
function PropItem:smash()
  if self.type == "box" and not self.isDestroyed then
    playdate.display.setRefreshRate(30)  -- 100ms stutter
    playdate.timer.performAfterDelay(100, function()
      playdate.display.setRefreshRate(0)
    end)
    self:destroyProp(self.id)
    self.isDestroyed = true
  end
end
```

Called by the plungerang projectile when it collides with a box (see `PLUNGERANG.md`). Only the `box` type responds. On impact:
1. The framerate is forced to 30 fps for 100 ms (visual stutter effect).
2. `destroyProp` is called to persist the destruction and change the sprite to `debris`.
3. `self.isDestroyed = true` is set so that future calls are ignored.

No other prop type can be smashed.

---

## 2. Minifier System (highest complexity)

The minifier is the most complex prop. It allows the player to toggle between normal size and `isTiny`. The full flow involves `propItem.lua`, `player/state.lua`, and `Config.lua`.

### 2.1 PropItem with type='minifier'

Exact prop values in `propConfigs`:

```lua
minifier = { collideRect = {0, 12, 32, 18} }
```

- `collideRect`: x=0, y=12, width=32, height=18. The rect covers the lower half of the 32×32 sprite. This allows the player to visually "enter" the machine from above.
- No special `isTube` or `isEdible` — `isEdible` remains `true` by default, but this has no practical effect for minifiers.
- `isStaticZIndex = true` — the minifier does not participate in dynamic Y-sorting; it always stays at `ZIndex.props` (2).
- No `nocollide`: the collider is active so the player can overlap with it (Playdate sprite collisions allow `collisionResponse = "overlap"` from `collisions.lua`).

### 2.2 Full Flow: Player Touches the Minifier

#### Step 1: Overlap Detection — collisions.lua

When the player's `collisionResponse` detects overlap with a `PropItem` of `type == 'minifier'`:

```lua
-- player/collisions.lua
elseif other:isa(PropItem) and other.type == 'minifier' then
    self.currentMinifier = other          -- store reference to the machine
    PlayerData.readyToShrink = true       -- flag read by crank handler and A button
    self:showUIHUD()
    self.uiHud:setPressA()               -- shows "press A" prompt
    return 'overlap'
```

At this point the player **can still move away**. `checkMinifier()` runs every frame in `update()` and clears `currentMinifier` and `readyToShrink` if the player walks out of the overlap area before pressing A.

#### Step 2: A Button → startMinifying()

`AButtonDown` in `MazeScene.inputHandler` checks:
```lua
if PlayerData.readyToShrink == true and PlayerData.isGaming == true then
    player:startMinifying()
end
```

```lua
function Player:startMinifying()
    if not self.currentMinifier or PlayerData.isTalking or not PlayerData.isGaming then return end

    PlayerData.isGaming = false       -- blocks all movement and ability input
    self.triggerEnteredOnce = true    -- stops trigger checks

    -- Centers the player in the machine (10px above the minifier center)
    local targetX = self.currentMinifier.x
    local targetY = self.currentMinifier.y - 10
    self:moveTo(targetX, targetY)
    if shadow then shadow:moveTo(targetX, targetY) end

    -- Shows crank direction indicator
    if not PlayerData.isTiny then
        self.uiHud:setCrankAntiClock()   -- counterclockwise = shrink (Q key in Love2D)
    else
        self.uiHud:setCrankClock()       -- clockwise = grow (E key in Love2D)
    end
    self:showUIHUD()

    -- Initializes transformation progress counter
    -- Normal → tiny: starts at playerSize (10), counts down to 0
    -- Tiny → normal: starts at 0, counts up to playerSize (10)
    PlayerData.actualPlayerSize = PlayerData.isTiny and 0 or PlayerData.playerSize
end
```

Blocking conditions (returns without acting if any are true):
- `self.currentMinifier` is nil
- `PlayerData.isTalking == true`
- `PlayerData.isGaming == false`

#### Step 3: Crank drives the transformation — MazeScene.cranked handler

The crank logic lives in `MazeScene.inputHandler.cranked`, **not** in the player's update loop. `getCrankTicks(4)` divides one full revolution into 4 integer ticks.

```lua
cranked = function(change, acceleratedChange)
    local ticksValue = playdate.getCrankTicks(4)

    -- Positive ticks always burn 1 calorie
    if ticksValue > 0 then player:burnCalories(1) end

    if PlayerData.isGaming == true then
        -- Normal gameplay: E key (clockwise) charges battery
        if ticksValue > 0 then
            if PlayerData.battery < 100 and not PlayerData.readyToShrink and not PlayerData.isTiny then
                player:chargeBattery(3)
            end
        end
    else
        -- Inside minifier (isGaming==false, readyToShrink==true)
        if PlayerData.readyToShrink == true and ticksValue ~= 0 then
            player:transformCycle()   -- plays animation every tick

            if not PlayerData.isTiny then
                -- Shrink: counterclockwise = negative ticks → Q key in Love2D
                if ticksValue < 0 then
                    PlayerData.actualPlayerSize -= math.abs(ticksValue)
                    if PlayerData.actualPlayerSize <= 0 then
                        PlayerData.actualPlayerSize = 0
                        player:shrink()
                        player:finishMinifying()
                    end
                end
            else
                -- Grow: clockwise = positive ticks → E key in Love2D
                if ticksValue > 0 then
                    PlayerData.actualPlayerSize += math.abs(ticksValue)
                    if PlayerData.actualPlayerSize >= PlayerData.playerSize then
                        PlayerData.actualPlayerSize = PlayerData.playerSize
                        player:grow()
                        player:finishMinifying()
                    end
                end
            end
        end
    end
end
```

**Crank direction mapping**:

| Crank direction | `ticksValue` | Effect | Love2D key |
|-----------------|-------------|--------|------------|
| Clockwise | positive | Charge battery (normal gameplay) / Grow (in minifier, if tiny) | **E** |
| Counterclockwise | negative | No effect in normal gameplay / Shrink (in minifier, if not tiny) | **Q** |

**Tick mechanics**:
- `playerSize = 10`, so 10 counterclockwise ticks complete the shrink and 10 clockwise ticks complete the grow.
- Each `cranked` callback can deliver multiple ticks at once if the crank is spun fast.
- There is no minimum speed — any non-zero tick advances the counter.

**B button cancels**: `BButtonDown` when `isGaming == false` and `readyToShrink == true` calls `player:finishMinifying()`, aborting without changing `isTiny`.

#### Step 4: Player:shrink()

```lua
function Player:shrink()
  PlayerData.isTiny = true
  local crt = Config.Player.collideRectTiny
  self:setCollideRect(crt.x, crt.y, crt.w, crt.h)
  self.animation:setState('transformTo')
end
```

Exact collideRect changes:

| State  | x  | y  | w  | h  |
|--------|----|----|----|----|
| Normal | 8  | 24 | 30 | 24 |
| Tiny   | 19 | 32 | 10 | 10 |

The tiny rect is notably smaller and offset toward the center-bottom of the sprite. The `transformTo` animation plays during the transformation.

#### Step 5: Player:grow()

```lua
function Player:grow()
    PlayerData.isTiny = false
    local cr = Config.Player.collideRect
    self:setCollideRect(cr.x, cr.y, cr.w, cr.h)
    self:idle()
end
```

Restores the normal collideRect (`{x=8, y=24, w=30, h=24}`) and calls `idle()` to reset the animation.

#### Step 6: Player:finishMinifying()

```lua
function Player:finishMinifying()
    PlayerData.isGaming = true
    self.triggerEnteredOnce = false
    self.uiHud:setVisible(false)
end
```

Unlocks movement, reactivates triggers, and hides the HUD. Called automatically when the transformation completes or if the player presses B to cancel.

#### Step 7: checkMinifier() — Exiting the Area

Every frame in `Player:update()`, `self:checkMinifier()` is called:

```lua
function Player:checkMinifier()
    if self.currentMinifier then
        local stillInside = false
        for _, sprite in ipairs(self:overlappingSprites()) do
            if sprite == self.currentMinifier then
                stillInside = true
                break
            end
        end
        if not stillInside then
            self.uiHud:setVisible(false)
            self.currentMinifier = nil
            PlayerData.readyToShrink = false
        end
    end
end
```

If the player exits the minifier area without having started the transformation, the reference is cleared and the HUD is hidden.

### 2.3 Effects of isTiny on Gameplay

#### Enemy Sight Radius

The base `PlayerData.EnemiesData.sightRadius` is `Config.Enemy.sightRadiusBase` (150 px). When `isTiny == true`, the enemy sight radius is reduced. The exact implementation is in `entities/enemies/enemy.lua`, which reads `PlayerData.isTiny` to scale the sightRadius.

#### FXshadow Light in Dark Rooms

In `player/state.lua`, the `idle()` function checks `isTiny`:

```lua
if PlayerData.isTiny == true then
  self.animation:setState('tinyIdle')
end
```

The HUD Y-offset also changes when tiny:

```lua
hudYOffset = Config.Player.hudOffsetY      -- -40 px (normal)
-- vs
hudYOffset = Config.Player.hudOffsetYTiny  -- -17 px (tiny)
```

The light radius (FXshadow) in dark rooms adapts to the player's size — the implementation is in the FX system, which reads `PlayerData.isTiny`.

#### Tiny Hole Traversal

The tilemap defines two hole types via IntGrid:

| IntGrid    | Value | Description |
|------------|-------|-------------|
| `hole`     | 3     | Normal hole — any player falls through |
| `tinyHole` | 32    | Tiny hole — only accessible when `isTiny == true` |

In `Player:update()`, both checks are called:

```lua
self:checkHoleTile()       -- tiles with value 3
self:checkTinyHoleTile()   -- tiles with value 32
```

`checkTinyHoleTile()` only acts if `PlayerData.isTiny == true`. This enables secret routes accessible only to the player in tiny state.

The battery cost for crossing a hole differs by state:

```lua
Config.Battery.drainHoleNormal = 0.5  -- per frame crossing hole (normal size)
Config.Battery.drainHoleTiny   = 0.2  -- per frame crossing hole (tiny)
```

#### Hitbox

The tiny collideRect (`{x=19, y=32, w=10, h=10}`) makes the player considerably harder for enemies to detect via physical collision. The rect fits within a 10×10 px square centered at the bottom of the sprite.

### 2.4 Full Flow Summary

```
Player enters minifier area
    -> collisions.lua assigns self.currentMinifier
    -> checkMinifier() in update() detects continuous overlap
    -> player presses A
    -> startMinifying() blocks movement, centers player, shows crank HUD
    -> player rotates crank (counterclockwise=shrink, clockwise=grow)
    -> actualPlayerSize updates frame by frame
    -> on reaching target: shrink() or grow() changes collideRect and PlayerData.isTiny
    -> finishMinifying() unlocks movement, hides HUD
    -> player can walk (at new size)

Cancellation (B during process):
    -> finishMinifying() is called directly
    -> transformation does not complete, isTiny does not change
```

### 2.5 Microwave (type='microwave') — mirrors the minifier

The microwave is a second "stand-on, crank-driven" prop, built on the same pattern as the
minifier. Instead of resizing the player, it **cooks raw food to restore HP**.

- **PropItem config**: `microwave = { collideRect = {0, 12, 32, 18} }` (same low rect as the
  minifier), animation frame 15 (placeholder), `isStaticZIndex = true`, listed in the overlap
  (non-blocking) branch so the player can stand on it.
- **Arm**: `collisions.lua` sets `self.currentMicrowave = other` and `PlayerData.readyToCook = true`,
  showing the "Press A" prompt.
- **A** → `Player:startCooking()` (centers + locks, guards on food > 0 and HP < max).
- **Crank** → consumes food for HP in the `MazeScene.cranked` locked branch.
- **B / auto** → `Player:finishCooking()` (full HP or 0 food auto-finishes).
- **Walk off** → `Player:checkMicrowave()` clears `currentMicrowave` and `readyToCook`.

The microwave has **no per-use state to persist** — it is reusable. Full details, Config, the
calorie byproduct, and persistence are in `MICROWAVE_AND_FOOD.md`.

---

## 3. Items System (Collectibles)

**File**: `entities/items/Items.lua`

`Items` extends `NobleSprite`. It is initialized with `Items:init(x, y, type, keyNumber, grants, iid)`. The trailing `iid` (LDtk entity id) is stored as `self.iid` and used for per-instance persistence of stackable items such as `food`.

### 3.1 Common Configuration for All Items

- **Sprite sheet**: `assets/images/items/items-key`
- **Size**: 32×32 px
- **CollideRect**: `{0, 0, 32, 32}` — covers the entire sprite
- **ZIndex**: `ZIndex.items` (value `4`)
- **Collision group**: group `3` (props, shared with solid props)
- **FXsonar**: each item creates an `FXsonar` instance on spawn to visually indicate its position

All animations have `frameDuration = 8`.

### 3.2 Full Item Type Table

| Type | Frames | Player function | Effect on PlayerData |
|------|--------|-----------------|----------------------|
| `boots` | 1-3 | `Player:grabBoots()` | `items.hasBoots = true`, `fillBattery()` |
| `plunger` | 4-6 | `Player:grabPlunger()` | `items.hasPlunger = true`, `skills.canPlungerang = true`, `fillBattery()` |
| `lamp` | 7-9 | `Player:grabLamp()` | `items.hasLamp = true`, `skills.canFlash = true`, `fillBattery()` |
| `notes` | 10-12 | `Player:grabNotes(grants)` | Updates fields in `PlayerData.skills` via `processGrants` |
| `keycard` | 13-15 | `Player:grabKey(keyNumber)` | `keys[keyNumber] = true` |
| `itemgift` | 16-18 | `Player:grabItemGift(grants)` | Updates fields in `PlayerData.items` via `processGrants` |
| `radio` | 19-21 | `Player:grabRadio()` | `items.hasRadio = true` |
| `food` | 10-12 (placeholder, `-- TODO art`; reuses `notes` frames) | `Player:grabFood()` | `food = min(food + Config.Microwave.perPickup, carryMax)`. Pickup also marks the entity `collected` per `iid` (`findAndCollectItemById`). See `MICROWAVE_AND_FOOD.md` |

There is no `bag` or `tools` type in the current `Items.lua` or `player/items.lua` code — no `grabBag()` or `grabTools()` functions are defined.

### 3.3 Exact Effects by Type

**boots** — `Player:grabBoots()`
```lua
PlayerData.items.hasBoots = true
self:fillBattery()
```
Prevents falling through holes (while battery is available).

**plunger** — `Player:grabPlunger()`
```lua
PlayerData.items.hasPlunger = true
PlayerData.skills.canPlungerang = true
self:fillBattery()
```
Unlocks the plungerang and prevents sliding on slime.

**lamp** — `Player:grabLamp()`
```lua
PlayerData.items.hasLamp = true
PlayerData.skills.canFlash = true
self:fillBattery()
```
Unlocks the flash ability and activates visibility logic in dark rooms. Without the lamp in dark zones, speed is multiplied by `Config.Player.speedDarkNoLamp` (0.7).

**keycard** — `Player:grabKey(keyNumber)`
```lua
keyNumber = keyNumber or 1
PlayerData.keys[keyNumber] = true
```
Grants the numbered key. Doors check `PlayerData.keys[N]` to allow passage.

**radio** — `Player:grabRadio()`
```lua
PlayerData.items.hasRadio = true
```
Only activates the flag. No other direct gameplay effects in `items.lua`.

**itemgift** — `Player:grabItemGift(grants)`
```lua
self:processGrants(grants, PlayerData.items)
```
Processes the `grants` string and applies it to `PlayerData.items`.

**notes** — `Player:grabNotes(grants)`
```lua
self:processGrants(grants, PlayerData.skills)
```
Processes the `grants` string and applies it to `PlayerData.skills`.

**food** — `Player:grabFood()`
```lua
PlayerData.food = math.min((PlayerData.food or 0) + Config.Microwave.perPickup, Config.Microwave.carryMax)
```
Adds `perPickup` (1) raw food to `PlayerData.food`, clamped to `carryMax` (10). Raw food does
not heal — it is later cooked at a microwave. Unlike other items, the collision branch first
calls `findAndCollectItemById(other.iid)` to mark the LDtk entity `collected = true`, so each
placed food is grabbed once and does not respawn (many food items may share a room). See
`MICROWAVE_AND_FOOD.md`.

### 3.4 Grants Format (processGrants)

```lua
function Player:processGrants(grants, targetTable)
  -- grants: "key1:value1,key2:value2"
  for pair in string.gmatch(grants, "([^,]+)") do
    local key, value = string.match(pair, "([^:]+):([^:]+)")
    -- Type conversion:
    -- "true"/"false" -> boolean
    -- numbers -> number
    -- rest -> string
    targetTable[key] = val
  end
end
```

Example: `grants = "hasPlunger:true,canFlash:false"` applied to `PlayerData.items` sets `items.hasPlunger = true` and `items.canFlash = false`.

### 3.5 Spawn Skip Conditions

In `MazeScene`, items are skipped during spawning if already collected. The exact conditions depend on type:

- **Items with a `collected` field in LDtk**: if the entity has `collected == true` in `levelsLDTK`, it is not spawned.
- **Keycard type items**: checks `PlayerData.keys[keyNumber] == true`.
- **Items with grants**: checks whether the player already owns the granted item/skill, avoiding duplicates.

When an item is picked up, `Items:removeAll()` handles:
1. Calling `sonar:disableFX()` — deactivates the sonar visual effect.
2. Calling `self:remove()` — removes the sprite from the Playdate system.

Persistence marking (`collected = true` in `levelsLDTK`) is performed from `player/collisions.lua` via the save system.

---

## 4. PortalDoor System

**File**: `entities/props/portal_door.lua`

`PortalDoor` extends `NobleSprite`. It is an invisible door with access conditions that teleports the player to another room.

### 4.1 Initialization

```lua
PortalDoor:init(portalId, destLevel, destRoom, spawnX, spawnY, conditions, blockedDialog, x, y, width, height)
```

Parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `portalId` | number | Unique portal identifier (from LDtk `cf.PortalID`) |
| `destLevel` | number | Destination level (from `cf.DestLevel`, default 1) |
| `destRoom` | number | Destination room (from `cf.DestRoom`, default 0) |
| `spawnX` | number | Player spawn X in destination (from `cf.SpawnX`, default 196) |
| `spawnY` | number | Player spawn Y in destination (from `cf.SpawnY`, default 116) |
| `conditions` | table | Array of condition strings (from `cf.Conditions`, default `{}`) |
| `blockedDialog` | string | Dialog ID to show if access is blocked (from `cf.BlockedDialog`, default `"nokeys"`) |
| `x, y` | number | Portal position in the room (from `entity.x`, `entity.y`) |
| `width, height` | number | Size (from `entity.width`, `entity.height`; if nil, uses `Config.Portals.collideRect`) |

The destination is calculated as: `destRoomId = destLevel * 100 + destRoom`.

Default collideRect (if width/height are not specified): `Config.Portals.collideRect = {x=0, y=0, w=24, h=24}`.

ZIndex: `ZIndex.props` (2). Collision group: 3.

### 4.2 Condition System (AND Logic)

`PortalDoor:canEnter()` evaluates all conditions in the array. Returns `true` only if **all** pass (AND logic). An empty array always returns `true` (open portal).

#### Condition Format

Each element of `conditions` is a string. There are two forms:

**Numeric comparison**:
```
"path.to.field OPERATOR value"
```
Examples: `"healthPoints>=3"`, `"EnemiesData.powerLevel<10"`, `"battery!=0"`

Supported operators: `>`, `<`, `>=`, `<=`, `==`, `!=`

**Boolean by path**:
```
"path.to.field"    -- true if the field is true
"!path.to.field"   -- true if the field is NOT true
```
Examples: `"isTiny"` (passes if isTiny==true), `"!isTiny"` (passes if isTiny~=true), `"items.hasLamp"`

#### Path Resolution

The internal `resolvePath(path)` function navigates the `PlayerData` table using dot separators:

```lua
-- "items.hasLamp" -> PlayerData.items.hasLamp
-- "EnemiesData.powerLevel" -> PlayerData.EnemiesData.powerLevel
-- "isTiny" -> PlayerData.isTiny
```

### 4.3 blockedDialog

When the player attempts to enter the portal and `canEnter()` returns `false`, the dialog identified by `blockedDialog` is shown. The default value is `"nokeys"`. The dialog system (see `DIALOG_SYSTEM.md`) looks up the corresponding text by that ID.

This behavior is implemented in `player/collisions.lua`, which calls `canEnter()` when detecting a collision with the portal and, depending on the result, calls `goTo()` or triggers the dialog.

### 4.4 goTo() and Spawn Coords

```lua
function PortalDoor:goTo()
    Noble.transition(RoomTranslate(self.destRoomId), 1.5, Noble.Transition.Default)
end

function PortalDoor:setSpawn()
    PlayerData.playerSpawn.x = self.spawnX
    PlayerData.playerSpawn.y = self.spawnY
end
```

`setSpawn()` is called before `goTo()` to set the player's spawn position in the destination room. The transition lasts 1.5 seconds using `Noble.Transition.Default`.

`RoomTranslate(destRoomId)` converts the room number (e.g. `408`) to the globally registered `Floor408` scene class.

### 4.5 collisionResponse

```lua
function PortalDoor:collisionResponse()
    return "slide"
end
```

The portal uses a `"slide"` response — the player does not bounce but slides against the portal area, making it easier to enter.

### 4.6 CreatePortalDoorsFromLDTK

Global function that instantiates all portals in a room:

```lua
function CreatePortalDoorsFromLDTK(currentRoom)
    -- Iterates currentRoom.entities.PortalDoors
    -- For each entity, reads customFields and creates a PortalDoor
end
```

Portals are read from `currentRoom.entities.PortalDoors`. If the room has no portals or the table is empty, the function returns without doing anything.

---

## 5. Initial PlayerData State Relevant to This System

Default values in `PlayerDataTables.lua`:

```lua
readyToShrink    = false,
isTiny           = false,
playerSize       = 10,
actualPlayerSize = 10,

items = {
    hasLamp    = false,
    hasRadio   = true,   -- player starts with radio
    hasDWatch  = false,
    hasNotes   = true,   -- player starts with notes
    hasBoots   = false,
    hasPlunger = false,
},
skills = {
    canFlash      = false,
    canPlungerang = false,
},
keys = {},  -- empty table; keys[N] = true when key N is collected

EnemiesData = {
    powerLevel  = 1,   -- max 20; affects DanceScene difficulty and sightRadius
    sightRadius = Config.Enemy.sightRadiusBase,  -- 150 px by default
    isEvolved   = false,
},
```

---

## 6. Notes for Love2D Port

### 6.1 Sprite System (NobleSprite vs Love2D)

`PropItem` and `Items` extend `NobleSprite`, a wrapper over `playdate.graphics.sprite`. In Love2D:

- Use a custom base class (middleclass, classic, etc.).
- Sprites are not drawn automatically — create an entity table and iterate in `love.draw()`.
- Playdate animation sheets are imagetables (image sequences); in Love2D use a sprite atlas with Quads via `love.graphics.newQuad`. The grid is 32×32 px.
- The `anim8` library can manage animations with an equivalent frameDuration.

### 6.2 Collisions

Playdate uses `setCollideRect` with `moveWithCollisions` internally. In Love2D:

- Use **bump.lua** (AABB).
- When creating a prop or item: `world:add(entity, entity.x, entity.y, entity.w, entity.h)`.
- The `setGroups(3)` group from Playdate corresponds to a collision filter in bump.lua.
- The exact collision rects are documented in section 1.3 — copy them as-is.

### 6.3 Z-ordering

Love2D does not sort automatically. Implementation:

```lua
-- For entities with dynamic Z:
table.sort(scene.entities, function(a, b) return a.y < b.y end)

-- For entities with isStaticZIndex=true: draw in a separate layer before the sort
```

Props with `isStaticZIndex = true` should be drawn in a background layer (equivalent to ZIndex 2). The `Tube` type uses ZIndex 700 — draw it above the player.

### 6.4 The Minifier Crank → Q and E Keys

The Playdate crank maps to two keyboard keys in Love2D:

| Key | Crank equivalent | Effect |
|-----|-----------------|--------|
| **E** | Clockwise (positive ticks) | Charge battery in normal play; **Grow** inside minifier (if tiny) |
| **Q** | Counterclockwise (negative ticks) | No effect in normal play; **Shrink** inside minifier (if not tiny) |

In Love2D, hold Q or E to drive `actualPlayerSize` up or down. Each key press acts as one tick (`ticksValue = ±1`). The loop runs until `actualPlayerSize` reaches 0 (tiny) or `playerSize` (10, normal):

```lua
-- love.keypressed (Love2D)
if key == "e" and state == "minifier" then
    PlayerData.actualPlayerSize = math.min(PlayerData.actualPlayerSize + 1, PlayerData.playerSize)
    if PlayerData.actualPlayerSize >= PlayerData.playerSize then
        player:grow(); player:finishMinifying()
    end
elseif key == "q" and state == "minifier" then
    PlayerData.actualPlayerSize = math.max(PlayerData.actualPlayerSize - 1, 0)
    if PlayerData.actualPlayerSize <= 0 then
        player:shrink(); player:finishMinifying()
    end
end
```

The crank indicator UI (`setCrankAntiClock` / `setCrankClock`) should be replaced with a `[Q]` / `[E]` key prompt in Love2D.

### 6.5 System Data

The `propConfigs` tables (propItem.lua) and `Config.Player.collideRect` / `collideRectTiny` are pure data with no SDK dependencies. Copy them directly to the port.

Critical values to preserve:

```lua
-- Player normal collideRect
{x=8, y=24, w=30, h=24}

-- Player tiny collideRect
{x=19, y=32, w=10, h=10}

-- Minifier collideRect
{0, 12, 32, 18}

-- Tilemap IntGrid values
hole     = 3
tinyHole = 32
slime    = 2
```

### 6.6 PortalDoor in Love2D

- The condition system (`canEnter()`) is pure Lua with no SDK dependencies — works without modification.
- `resolvePath()` navigates `PlayerData`, which must exist as a global table or be passed as a parameter.
- `Noble.transition` is equivalent to switching the active scene with a transition (fade, etc.).
- `RoomTranslate(id)` must be reimplemented as an `id -> scene class` map equivalent.

### 6.7 FXsonar in Items

Each `Items` creates an `FXsonar`. In Love2D, replace with a particle effect or an expanding circle pulse from the item's position. `removeAll()` must remove both the visual effect and the object from the bump.lua collision world.
