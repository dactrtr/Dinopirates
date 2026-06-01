# DanceScene — Rhythm Combat System

Files: `scenes/DanceScene.lua` and `entities/UI/battle/`

---

## Overview

DanceScene is the rhythm-based turn combat that triggers when the player collides with a Brocorat. The player must press the correct buttons in sync with icons scrolling across the screen to push a balance bar toward the victory zone. Winning kills the enemy and returns to the dungeon; losing transitions to TitleScene (Game Over).

---

## Entry Point

In `entities/player/collisions.lua`, when the player overlaps a Brocorat:

1. `PlayerData.lastEnemyTouched` is populated with the enemy's `id`, `type`, `x`, `y`.
2. Damage is applied: `PlayerData.healthPoints -= other.damage`.
3. If `healthPoints < PlayerData.danceThresholdHP` (default `1`): `self:fight()` is called.
4. Otherwise: `startInvincibility(Config.Invincibility.duration)` — no combat.

`Player:fight()` in `state.lua`:
- Calls `Noble.transition(DanceScene)`.

---

## Full Lifecycle

### `init()`

Runs once when the scene is constructed by Noble Engine.

- `playdate.display.setRefreshRate(50)` — locks the framerate to 50 fps for combat.
- `math.randomseed(playdate.getCurrentTimeMilliseconds())` — seeds the RNG with current time in milliseconds (fallback: `math.randomseed(1)` if the API is unavailable).
- Initializes combat state with these exact values:
  - `self.bpm = 16` — default tempo (may be overridden in `enter()`).
  - `self.ButtonPressed = nil` — key the player is currently holding.
  - `self.buttonText = "none"` — debug string.
  - `self.accuracy = 0` — frame counter for how long a button has been in the hit zone without being pressed.
  - `self.totalAccuracy = 0` — cumulative correct accuracy for the session.
  - `self.enemyHP = 50` — enemy health (also defines `balanceMaxOffset`).
  - `self.evadePower = 30` — alias for `totalAccuracy` accumulator.
  - `self.condition = nil` — combat result (`"win"`, `"lose"`, or `nil`).
  - `self.enemyType = nil` — active profile (`"basic"`, `"evolve"`, etc.).
  - `self.enemyEvolving = nil` — boolean indicating whether the type was upgraded by the roll.
  - `lifes = 3` — file-local variable (not a field of self).
  - `self.balancePosition = 0` — current position in the range `[-50, +50]`.
  - `self.balanceMaxOffset = self.enemyHP` — maximum balance limit (50).
  - `self.numberOfButtons = 4` — number of ButtonPress sprites to create.
  - `self.correctButtonPresses` — per-key counter table: `{aButton=0, bButton=0, leftButton=0, rightButton=0, upButton=0, downButton=0}`.

### `enter()`

Runs each time DanceScene becomes the active scene.

1. Calls `scene.super.enter(self)`.
2. Defines `startPoint = 400` — the off-screen X position on the right where buttons spawn.
3. Resets `condition = nil` and stops any prior `Sequence`.
4. Starts a Noble Engine `Sequence` from 0→100 over 1.5 s with `Ease.outBounce` (entrance visual effect).
5. **Difficulty determination** (see Difficulty section below):
   - If `DanceScene.debugMode == true`: forces `enemyType = "basic"`, `bpm = Config.Dance.basic.bpm`, `numberOfButtons = Config.Dance.basic.buttons`, `enemyEvolving = false`.
   - Otherwise: calls `self:determineDifficultyUpgrade()` → gets `chance` (0–100) → rolls `roll = math.random(0, 100)`.
     - If `roll <= chance`: calls `self:determineEnemyType()`, reads `Config.Dance[enemyType]`, assigns `bpm` and `numberOfButtons`, sets `enemyEvolving = true`.
     - If `roll > chance`: `enemyType = "basic"`, `enemyEvolving = false`, uses `Config.Dance.basic` values.
6. **ButtonPress creation**: Instantiates `self.numberOfButtons` sprites. Each receives `(self.bpm, startPoint + self.bpm, keyProvider)`. The `keyProvider` is a closure that calls `getPatternKey(profile)` with the current enemy's profile.
7. **HitZone creation**: `HitZone(40, 30, self.bpm)`.
8. **Dynamic sprite selection**:
   - Player: if `PlayerData.isTiny` → `'assets/images/ui/battle/playerDanceTiny'`; otherwise → `'assets/images/ui/battle/playerDance'`.
   - Enemy: if `PlayerData.lastEnemyTouched.type == "bosscolli"` → `'assets/images/ui/battle/enemyBosscolliDance'`; otherwise → `'assets/images/ui/battle/enemyDance'`.
9. Instantiates the remaining UI sprites: `EnemyRatDance`, `ButtonCover`, `WinIndicator`, `LoseIndicator`, `BackgroundDance`, `ResultsScreen`.
   - `WinIndicator` is positioned at `(screenCenterX + balanceMaxOffset + 2*barWidth, barY + barHeight/2 - 6)` = `(200 + 50 + 16, 56 + 5 - 6)` = `(266, 55)`.
   - `LoseIndicator` is positioned at `(screenCenterX - balanceMaxOffset - 2*barWidth, barY + barHeight/2 - 6)` = `(134, 55)`.

### `start()`

Runs immediately after `enter()`, once the transition completes.

- Staggers button activation with delays: for each `ButtonPress` in `self.buttons`, calls `btn:movementDelay((i-1) * 300)`.
  - Button 1: 0 ms delay (starts immediately).
  - Button 2: 300 ms delay.
  - Button 3: 600 ms delay.
  - Button N: `(N-1) × 300` ms delay.
- This prevents all buttons from starting simultaneously and stacking up.

### `update()`

Called every frame (at 50 fps). Exact flow:

1. **Ready screen guard**: If `PlayerData.isDancing == false` and `condition == nil`, calls `resultsScreen:loadingScreen()` and returns immediately — hit detection does not run.
2. **Hitzone nil guard**: If `hitzone` is nil, returns immediately.
3. Gets `collisions = hitzone:overlappingSprites()`.
4. Processes collisions (see Hit Detection section).
5. Debug rendering if `debug == true`.
6. Clamps `lifes = math.max(0, math.min(3, lifes))`.
7. Clamps `self.balancePosition = math.max(-self.balanceMaxOffset, math.min(self.balanceMaxOffset, self.balancePosition))`.
8. Loads the `nudgeIndicator` image if not yet loaded.
9. Draws `balanceBarImage` centered at `(screenCenterX + balancePosition - barWidth/2, barY)`.
10. Evaluates win condition: if `balancePosition >= balanceMaxOffset` → `resultsScreen:win()`, `isDancing = false`, `condition = "win"`.
11. Evaluates lose condition: if `balancePosition <= -balanceMaxOffset` → `resultsScreen:lose()`, `isDancing = false`, `condition = "lose"`.

### `exit()`

Runs when leaving the scene.

- Calls `:remove()` and nils all sprites: `hitzone`, `playerDance`, `enemyDance`, `buttonCover`, `winIndicator`, `loseIndicator`, `backgroundDance`, `resultsScreen`.
- Iterates `self.buttons` and calls `:remove()` on each, then nils `self.buttons`.
- Resets `DanceScene.debugMode = false`.
- **Resets player HP**: `PlayerData.healthPoints = 2` (always, regardless of outcome).
- `Noble.Input.setCrankIndicatorStatus(false)`.
- Starts a Sequence from 100→240 over 0.25 s with `Ease.inSine` (exit visual effect).
- Calls `SaveSystem.save()`.

### `finish()`

Simply delegates to `scene.super.finish(self)`. No additional logic.

---

## Difficulty System

### Enemy Profiles (`EnemyPatterns`)

A local table defined in `DanceScene.lua` with four profiles. Each profile has `weights`, `style`, and `phaseLength`:

| Profile | `arrows` | `aButton` | `bButton` | `style` | `phaseLength` |
|---------|----------|-----------|-----------|---------|---------------|
| `basic` | 0.8 | 0.2 | 0.0 | `"arrow_heavy"` | 10 |
| `evolve` | 0.6 | 0.2 | 0.2 | `"mixed"` | 10 |
| `badass` | 0.4 | 0.3 | 0.3 | `"tough"` | 8 |
| `boss` | 0.2 | 0.4 | 0.4 | `"button_spam"` | 6 |

**Note**: `phaseLength` is declared in the profile but is not used in the current code.

### Exact Values per Type (`Config.Dance`)

| Type | BPM | Buttons on screen |
|------|-----|-------------------|
| `basic` | 16 | 4 |
| `evolve` | 24 | 6 |
| `badass` | 28 | 8 |
| `boss` | 32 | 12 |

### `determineEnemyType()`

Maps `PlayerData.EnemiesData.powerLevel` to a profile:

| powerLevel | Result |
|------------|--------|
| 1 – 5 | `"basic"` |
| 6 – 12 | `"evolve"` |
| 13 – 19 | `"badass"` |
| 20 | `"boss"` |
| any other | `"basic"` (fallback) |

### `determineDifficultyUpgrade()`

Calculates the probability of upgrading difficulty above `"basic"`. Exact formula:

```
sanityNorm   = clamp(sanityCounter / 100,  0, 1)   -- Config.Dance.sanityMax = 100
powerNorm    = clamp(powerLevel    / 20,   0, 1)   -- Config.Dance.powerMax  = 20
caloriesNorm = clamp(calories      / 500,  0, 1)   -- Config.Dance.caloriesMax = 500

normalizedScore = (sanityNorm × 0.35) + (powerNorm × 0.45) + (caloriesNorm × 0.20)
                                        ↑ weightSanity       ↑ weightPower     ↑ weightCalories

probability = clamp(normalizedScore × 100, 0, 100)
```

- Weights are configurable in `Config.Dance`: `weightSanity = 0.35`, `weightPower = 0.45`, `weightCalories = 0.20`.
- The dominant weight is `powerLevel` (45%). Reaching powerLevel 20 with high sanity and calories can push the probability close to 100%.
- The roll is `math.random(0, 100)`. If `roll <= probability` → `determineEnemyType()` is called. Otherwise → `"basic"` is used.
- If the roll fails, the enemy is always `"basic"` regardless of how high `powerLevel` is.

### `getPatternKey(profile)`

A local function that performs a weighted draw to choose the next button type:

```lua
rand = math.random()  -- float in [0, 1)
sum  = weights.arrows + weights.aButton + weights.bButton  -- always 1.0
choice = rand * sum

if choice < weights.arrows:
    pick one of { "leftButton", "upButton", "rightButton", "downButton" } at random
elif choice < weights.arrows + weights.aButton:
    return "aButton"
else:
    return "bButton"
```

The result is assigned as the `buttonKey` of each `ButtonPress`.

---

## ButtonPress System

File: `entities/UI/battle/buttonPress.lua`

### Constructor `ButtonPress:init(beats, startPoint, keyProvider)`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/button'` (table image).
- Animation states defined with exact frame indices:

| State | Frame | Key represented |
|-------|-------|-----------------|
| `"aButton"` | 1 | A button |
| `"bButton"` | 2 | B button |
| `"leftButton"` | 3 | D-pad left |
| `"upButton"` | 4 | D-pad up |
| `"rightButton"` | 5 | D-pad right |
| `"downButton"` | 6 | D-pad down |
| `"empty"` | 8 | Invisible/empty |

- All states use `frameDuration = 6` (Playdate frames, not seconds).
- Size: 32×32 px.
- Collide rect: full 32×32 px.
- ZIndex: 4.
- Added at position `(startPoint, 30)` on creation.
- The `keyProvider` is a closure received from DanceScene; it is called immediately to assign the initial `buttonKey`.

### Movement

`ButtonPress:update()` only runs if `PlayerData.isDancing == true` and `self.active == true`.

**Movement speed per frame**:
```
speedX = 0.5 × bpm / 3
```

By type:
| Type | BPM | Speed px/frame |
|------|-----|----------------|
| `basic` | 16 | 16 × 0.5 / 3 ≈ **2.67 px/frame** |
| `evolve` | 24 | 24 × 0.5 / 3 = **4.0 px/frame** |
| `badass` | 28 | 28 × 0.5 / 3 ≈ **4.67 px/frame** |
| `boss` | 32 | 32 × 0.5 / 3 ≈ **5.33 px/frame** |

The target X position each frame is `self.x - speedX` (moves left).

Movement is performed with `self:tryMoveToFreePosition(targetX, self.y)`, which internally uses `moveWithCollisions`. Colliding with another `ButtonPress` → response `'freeze'`. Against anything else → `'overlap'`.

**Recycling**: If `self.x <= 32`, the button teleports back to `startPoint` and calls `changeButtonSprite()` to get a new key.

### `movementDelay(delay)`

Calls `playdate.timer.performAfterDelay(delay, callback)`. The callback sets `self.active = true`. This is what produces the staggered entrance effect at the start of combat.

### `hit()`

Called from DanceScene when the button in the zone has been processed (correct or incorrect):
1. Sets `buttonKey = "empty"` and changes the animation to that state.
2. Teleports the sprite to `self.startPoint`.
3. Calls `changeButtonSprite()`.

### `changeButtonSprite()`

Calls the `keyProvider` in a loop until it gets a key different from the current one (avoids immediate repetition). Assigns the new key and changes the animation.

---

## HitZone

File: `entities/UI/battle/hitZone.lua`

### Constructor `HitZone:init(x, y, bpm)`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/hitzone'`.
- Animation: state `'checker'` with frames 1–8, `frameDuration = bpm` (Playdate frames).
- Physical size: **10×40 px** (narrow and tall to detect passing buttons).
- Collide rect: full 10×40 px.
- ZIndex: 5 (above ButtonPress sprites at ZIndex 4).
- Fixed position: `(40, 30)` — left side of the screen, where the player "hits."

### Hit Detection

DanceScene calls `hitzone:overlappingSprites()` every frame in `update()`. This Noble/Playdate function returns all sprites whose collide rect overlaps HitZone's rect.

- **A frame is a "hit"**: when `overlappingSprites()` returns at least one `ButtonPress` at that position.
- **There is no multi-frame window concept**: any frame in which the `ButtonPress` is in the zone while the player has a key pressed is a valid hit.
- There is no timing penalty (early/late) beyond the `accuracy` system.

---

## Balance Bar System

### Constants (defined in DanceScene as local vars)

| Variable | Value | Meaning |
|----------|-------|---------|
| `screenCenterX` | 200 | Horizontal center of the screen |
| `barWidth` | 8 | Width of the indicator sprite |
| `barHeight` | 10 | Height of the indicator sprite |
| `barY` | 56 | Y where the bar is drawn |
| `balanceMaxOffset` | 50 (= `enemyHP`) | Limit in pixels in each direction |

### Range and Position

`balancePosition` ranges from `-50` to `+50`. It is clamped every frame:
```lua
self.balancePosition = math.max(-self.balanceMaxOffset, math.min(self.balanceMaxOffset, self.balancePosition))
```

The sprite is drawn at:
```
X = screenCenterX + balancePosition - barWidth/2
Y = barY
```
(horizontally centered relative to the balance point)

### Modifiers per Event

| Event | Change to `balancePosition` |
|-------|-----------------------------|
| Correct A or B button | `+5` |
| Correct arrow button | `+accuracy` (accumulated frames in zone) |
| Incorrect button | `-5` |
| Button in zone unpressed for > 5 frames | `-0.3` per additional frame |

### End Conditions

- **Victory**: `balancePosition >= +50` → `resultsScreen:win()`, `PlayerData.isDancing = false`, `condition = "win"`.
- **Defeat**: `balancePosition <= -50` → `resultsScreen:lose()`, `PlayerData.isDancing = false`, `condition = "lose"`.

Visual indicators are positioned at the edges of the range:
- `WinIndicator`: X = `200 + 50 + 2×8 = 266`, Y = `55`
- `LoseIndicator`: X = `200 - 50 - 2×8 = 134`, Y = `55`

---

## `danceStep(inputStep)`

Registers the player's input:

```lua
function scene:danceStep(inputStep)
    self.ButtonPressed = inputStep
end
```

Called from the input handlers (`AButtonDown`, `BButtonDown`, `leftButtonDown`, etc.). Only assigns the value; evaluation happens in `update()` on the next frame.

`clearButton()` sets `self.ButtonPressed = nil`, called on all `*ButtonUp` events.

---

## `checkDanceResults()`

Called from `AButtonDown` after `danceStep()`. Evaluates `condition` (file-local variable):

### If `condition == "win"`:
1. Resets `condition = nil`.
2. Resets `self.totalAccuracy = 0`.
3. If `DanceScene.debugMode == true` → transitions to `TitleScene` and returns.
4. `findAndKillEnemyById(PlayerData.lastEnemyTouched.id)` — marks the enemy as dead in `levelsLDTK`.
5. `PlayerData.healthPoints += PlayerData.healedHP` — restores HP (value in `PlayerDataTables.lua`: `healedHP = 2`).
6. `PlayerData.playerSpawn.x = PlayerData.playerExit.x` and `.y = PlayerData.playerExit.y` — restores spawn position to the point where the player entered combat.
7. `PlayerData.amountDances += 1` — increments the combat counter.
8. `PlayerData.calories += 60` — awards calories for winning.
9. `self.returnRoom = RoomTranslate(PlayerData.saveLevel)` — gets the scene class for the origin room.
10. `Noble.transition(self.returnRoom, 0.3, Noble.Transition.Default)` — returns to the room.

### If `condition == "lose"`:
1. Resets `condition = nil`.
2. `Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)` — Game Over.

**Important note about `checkDanceResults()`**: It is only wired to `AButtonDown`. The handlers for other buttons call `danceStep()` but not `checkDanceResults()`. A scene transition can only occur when the player presses A immediately after a condition is met.

---

## UI Sprites — Detail for Each

### `BackgroundDance` — Combat background

File: `entities/UI/battle/backgroundDance.lua`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/background'`.
- Animation: state `'cover'` (single frame 1, static).
- Size: 400×240 px (full screen).
- ZIndex: **1** (lowest layer, behind everything).
- Position: `(200, 120)` (screen center).
- `frameDuration = bpm` but since there is only one frame, it has no effect.
- No `update()` or additional logic.

### `EnemyRatDance` — Enemy sprite

File: `entities/UI/battle/enemyRatDance.lua`

Constructor: `EnemyRatDance(bpm, evolveType, isEvolving, spritePath)`

- Default spritesheet: `'assets/images/ui/battle/enemyDance'`.
- `frameDuration = bpm/2` for all states.
- Size: 214×214 px. Center: `(0, 0)`. Position: `(158, 26)` — right side of the screen.
- ZIndex: **2**.
- The `evolveType` parameter determines which block of animations is registered (all have the same frames — the branch exists for future spritesheet variations per type).

Available animations (the same for all four types):

| State | Frames | `frameDuration` | Returns to idle |
|-------|--------|-----------------|-----------------|
| `idle` | 1–5 | `bpm/2` | (loop) |
| `upAttack` | 6–9 | `bpm/2` | yes |
| `leftAttack` | 10–13 | `bpm/2` | yes |
| `rightAttack` | 14–17 | `bpm/2` | yes |
| `downAttack` | 18–21 | `bpm/2` | yes |
| `bButton` | 22–25 | **3** | yes |
| `aButton` | 26–29 | **3** | yes |
| `evolving` | 30–33 | `bpm/2` | (no auto return) |

Methods:
- `changeAnimation(input)` — called when a button is in the zone WITHOUT being pressed. Maps: `downButton→upAttack`, `upButton→downAttack`, `leftButton→leftAttack`, `rightButton→rightAttack`.
- `attackAnimation(input)` — called on a correct A/B hit. Maps: `aButton→aButton`, `bButton→bButton`.
- `setIdle()` — forces the `'idle'` state; called by `startBattle()`.

### `PlayerDance` — Player sprite

File: `entities/UI/battle/playerDance.lua`

Constructor: `PlayerDance(bpm, spritePath)`

- Default spritesheet: `'assets/images/ui/battle/playerDance'`.
- If `PlayerData.isTiny == true`: uses `'assets/images/ui/battle/playerDanceTiny'` (same frame layout).
- `frameDuration = bpm/2` for all states.
- Size: 246×214 px. Center: `(0, 0)`. Position: `(0, 26)` — left side of the screen.
- ZIndex: **6** (above the enemy).

Animations:

| State | Frames | Trigger |
|-------|--------|---------|
| `idle` | 1–5 | initial and default state |
| `jump` | 5–9 | correct `upButton` → returns to `idle` |
| `crouch` | 11–15 | correct `downButton` → returns to `idle` |
| `left` | 16–20 | correct `leftButton` → returns to `idle` |
| `right` | 21–24 | correct `rightButton` → returns to `idle` |

A and B buttons do not change the player animation.

`changeAnimation(input)` maps: `upButton→jump`, `downButton→crouch`, `leftButton→left`, `rightButton→right`.

### `ButtonCover` — Decorative cover

File: `entities/UI/battle/buttonCover.lua`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/buttoncover'`.
- Animation: state `'cover'` (single frame 1, static).
- Size: 78×58 px.
- ZIndex: **9** (above almost everything).
- Position: `(361, 32)` — top-right corner.
- Purpose: decorative panel that covers the origin point of buttons entering from the right. Hides where `ButtonPress` sprites appear.

### `WinIndicator` — Victory marker (enemy side)

File: `entities/UI/battle/winIndicator.lua`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/enemyIndicator'`.
- Animation: state `'enemy'` (single frame 1, static).
- Size: 39×31 px.
- ZIndex: **9**.
- Position: calculated in DanceScene `enter()` → `(screenCenterX + balanceMaxOffset + 2*barWidth, barY + barHeight/2 - 6)` = `(266, 55)`.
- Marks the right edge of the bar (victory zone).

### `LoseIndicator` — Defeat marker (player side)

File: `entities/UI/battle/loseIndicator.lua`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/playerIndicator'`.
- Animation: state `'player'` (single frame 1, static).
- Size: 39×31 px.
- ZIndex: **9**.
- Position: calculated in DanceScene `enter()` → `(screenCenterX - balanceMaxOffset - 2*barWidth, barY + barHeight/2 - 6)` = `(134, 55)`.
- Marks the left edge of the bar (defeat zone).

### `ResultsScreen` — Result overlay

File: `entities/UI/battle/resultsScreen.lua`

- Extends `NobleSprite`.
- Spritesheet: `'assets/images/ui/battle/resultsdance'`.
- Size: 400×240 px (full screen). Center: `(200, 120)`.
- ZIndex: **10** (highest layer — above absolutely everything).

Animations / states:

| State | Frame | When activated |
|-------|-------|----------------|
| `empty` | 1 | Active battle (transparent) |
| `win` | 2 | When `balancePosition >= +50` |
| `lose` | 3 | When `balancePosition <= -50` |
| `ready` | 4 | Waiting screen before the player presses A |

Methods: `win()`, `lose()`, `loadingScreen()` (→ `ready`), `empty()`.

State flow:
1. Created in state `'empty'` (constructor).
2. In `update()`, if `isDancing == false` and `condition == nil` → `loadingScreen()` is called → state `'ready'`.
3. Player presses A → `startBattle()` → `empty()` → state `'empty'`.
4. When a condition is met → `win()` or `lose()`.

---

## Z-Index Layers (back to front)

| ZIndex | Sprite |
|--------|--------|
| 1 | `BackgroundDance` (background) |
| 2 | `EnemyRatDance` (enemy) |
| 4 | `ButtonPress` (moving buttons) |
| 5 | `HitZone` (hit area) |
| 6 | `PlayerDance` (player) |
| 9 | `ButtonCover`, `WinIndicator`, `LoseIndicator` |
| 10 | `ResultsScreen` (result overlay) |

---

## Relevant PlayerData Fields

| Field | Default value | Role in DanceScene |
|-------|---------------|-------------------|
| `isDancing` | `false` | `false` = ready screen; `true` = active combat |
| `isTiny` | `false` | Selects the alternate player spritesheet |
| `lastEnemyTouched` | `{type=nil, id=nil, x=nil, y=nil}` | `type` selects the enemy spritesheet; `id` is used to kill the enemy on victory |
| `danceThresholdHP` | `1` | Minimum HP at which combat is triggered |
| `EnemiesData.powerLevel` | `1` (max 20) | Determines enemy type |
| `sanityCounter` | `0` (max 100) | Input to the difficulty roll (35% weight) |
| `calories` | `100` (max 500) | Input to the difficulty roll (20% weight) |
| `healedHP` | `2` | HP restored on victory |
| `amountDances` | `0` | Combat counter; incremented on victory |
| `playerExit` | `{x=nil, y=nil}` | Position restored on victory |
| `saveLevel` | `nil` | Used by `RoomTranslate()` to find the return room |
| `healthPoints` | `3` | Reset to `2` in `exit()` |

---

## Notes for Porting to Love2D

This section documents all Playdate/Noble Engine-specific APIs that must be replaced when porting DanceScene to Love2D.

### Noble Engine → Love2D / Custom Scene System

| Playdate/Noble API | Love2D Equivalent | Notes |
|--------------------|-------------------|-------|
| `class("DanceScene").extends(NobleScene)` | Lua table/module or an OOP library (e.g. `middleclass`) | Noble uses its own Lua class system |
| `Noble.new(Scene)` | Call `scene:init()` directly and register callbacks | Noble manages a scene stack |
| `Noble.transition(Scene, duration, type)` | Custom transition function + active scene swap | `MetroNexus` and `Default` transitions are Noble-proprietary visual effects |
| `scene.super.init(self)` / `scene.super.enter(self)` | Call the base class init/enter if using inheritance | |
| `scene.inputHandler = { ... }` | `love.keypressed`, `love.keyreleased`, or a custom InputManager | Noble uses a per-scene callback table; Love2D uses global callbacks or an input stack system |

### Sprite System (NobleSprite / playdate.graphics.sprite)

| Playdate/Noble API | Love2D Equivalent |
|--------------------|-------------------|
| `class('X').extends(NobleSprite)` | `love.graphics.draw()` + custom state table, or a sprite library (e.g. `anim8`) |
| `NobleSprite.super.init(self, imagePath, animate)` | Load image with `love.graphics.newImage(path)` |
| `self.animation:addState(name, startFrame, endFrame)` | Custom frame-based animation logic, or use `anim8` to define frame grids |
| `self.animation.state.frameDuration = N` | In Love2D duration is in seconds; `N frames / 50fps = N/50 seconds` |
| `self.animation:setState(name)` | Switch the active state in a custom AnimationManager |
| `self:setSize(w, h)` | Not used in Love2D; size comes from the image |
| `self:setZIndex(n)` | Order draw calls manually, or use a sorted layer list |
| `self:setCollideRect(x, y, w, h)` | Use a collision library (e.g. `bump.lua`) or manual AABB |
| `self:setCenter(cx, cy)` | Sprite origin; in Love2D pass `ox, oy` to `love.graphics.draw()` |
| `self:add(x, y)` | Add the sprite to a render list and store its position |
| `self:remove()` | Remove from the render list |
| `self:moveTo(x, y)` | `self.x = x; self.y = y` |
| `self:moveWithCollisions(x, y)` | Use `bump:move(item, x, y)` from `bump.lua` |
| `self:overlappingSprites()` | `bump:queryRect(x, y, w, h)` or manual overlap checks |
| `self:isa(Class)` | `type(obj)` or a custom `obj.class` field |

### Timers

| Playdate API | Love2D Equivalent |
|--------------|-------------------|
| `playdate.timer.performAfterDelay(ms, callback)` | `love.timer.getTime()` + comparison in `update()`, or a timer library (e.g. `hump.timer`: `timer.after(ms/1000, callback)`) |

### Display and Graphics

| Playdate API | Love2D Equivalent |
|--------------|-------------------|
| `playdate.display.setRefreshRate(50)` | `love.window.setMode()` does not control fps; use a fixed-tick `love.run` or a `love.update(dt)` accumulator |
| `Graphics.kColorBlack` / `Graphics.setColor()` | `love.graphics.setColor(r, g, b, a)` |
| `Graphics.drawText(str, x, y)` | `love.graphics.print(str, x, y)` |
| `Graphics.drawRect(x, y, w, h)` | `love.graphics.rectangle("line", x, y, w, h)` |
| `Graphics.drawLine(x1, y1, x2, y2)` | `love.graphics.line(x1, y1, x2, y2)` |
| `Graphics.image.new(path)` | `love.graphics.newImage(path)` |
| `image:drawCentered(x, y)` | `love.graphics.draw(img, x, y, 0, 1, 1, img:getWidth()/2, img:getHeight()/2)` |

### Animation Sequences (Noble Sequence)

| Noble API | Love2D Equivalent |
|-----------|-------------------|
| `Sequence.new():from(a):to(b, duration, easing):start()` | `flux` (tweening library) or a custom implementation in `love.update(dt)` |
| `sequence:stop()` | `tween:stop()` or a custom flag |
| `Ease.outBounce` / `Ease.inSine` | `flux` includes easings; or use `tween.lua` |

### Input

| Playdate/Noble API | Love2D Equivalent |
|--------------------|-------------------|
| `AButtonDown` / `AButtonUp` in `inputHandler` | `love.keypressed(key)` / `love.keyreleased(key)` with key mapping |
| `leftButtonDown`, `rightButtonDown`, etc. | Keyboard arrow keys or gamepad with `love.gamepadpressed()` |
| `Noble.Input.setCrankIndicatorStatus(false)` | Not applicable (no crank on PC); remove |
| `cranked`, `crankDocked`, `crankUndocked` | If porting to gamepad: analog joystick; otherwise remove |

### Miscellaneous

| Playdate API | Love2D Equivalent |
|--------------|-------------------|
| `playdate.getCurrentTimeMilliseconds()` | `math.floor(love.timer.getTime() * 1000)` |
| `math.randomseed(...)` | Same in Love2D (standard Lua) |
| `table.getsize(t)` | `#t` or a custom function for non-integer-keyed tables |
| `printDebug(str)` | `print(str)` or a custom logger |

### Architectural Considerations for the Port

1. **Update loop**: Playdate runs at 50fps with a loop managed by the SDK. Love2D uses `love.update(dt)` with delta time. `ButtonPress` speed calculations assume fixed frames; convert to `speed * dt * targetFPS`.

2. **Scene system**: Noble manages a scene stack with transitions. For Love2D, build a custom SceneManager or use `hump.gamestate`.

3. **Frame-by-frame animations**: Noble has its own state-based animation system. In Love2D use `anim8` or implement an animation StateMachine that takes a table image (grid) and advances frames by time.

4. **Collisions**: Playdate has a sprite system with built-in collisions. In Love2D use `bump.lua` for AABB collisions and replace `moveWithCollisions` and `overlappingSprites`.

5. **1-bit graphics**: Playdate is black and white. The port can keep the assets in black and white or colorize them. Playdate's screen is 400×240; Love2D can scale to any resolution.

6. **`frameDuration` in frames vs seconds**: In Playdate code `frameDuration = N` means N frames at 50fps. In Love2D convert to seconds: `duration = N / 50`. For example, `frameDuration = bpm/2 = 8` → `0.16 seconds` per animation frame for `basic`.
