# Input System

This document describes the Noble Engine callbacks used, per-frame input with `buttonIsPressed()`, the crank system, the complete MazeScene input map, the `CheatCode` class, and portability notes.

---

## Playdate Input Hardware

| Control | Description |
|---|---|
| D-pad | 4 directions: `up`, `down`, `left`, `right` |
| **A** | Primary action button (right side) |
| **B** | Secondary action button (left side) |
| Crank | Analog rotary dial with no equivalent on standard consoles |

---

## Noble Engine Callbacks — Exact Naming

Noble Engine uses a specific suffix for button callbacks. The rule is:

- `ButtonDown` — exact frame the button is pressed.
- `ButtonHold` — called every frame while held down.
- `ButtonUp` — exact frame the button is released.

**The correct suffix is `Hold`, NOT `Held`.** Example:

```lua
-- CORRECT
function MazeScene:upButtonHold()    player:move("up")    end
function MazeScene:downButtonHold()  player:move("down")  end
function MazeScene:leftButtonHold()  player:move("left")  end
function MazeScene:rightButtonHold() player:move("right") end

-- INCORRECT (does not work)
function MazeScene:upButtonHeld()    ...  end
```

### Per-Frame Input with `buttonIsPressed()`

For continuous movement that must respond every frame (not just at the start of a hold), use `playdate.buttonIsPressed()` inside `update()`:

```lua
function MazeScene:update()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        player:move("up")
    end
    -- etc.
end
```

The practical difference: `ButtonHold` is not called on the first frame of a press (it has a small OS delay); `buttonIsPressed()` in `update()` responds from the very first frame.

---

## Game State Map

`PlayerData` flags determine which actions are active. They are mutually exclusive by design:

```
isGaming = true                              → normal gameplay
isGaming = false + isEquiping = true         → equipment menu open
isGaming = false + readyToShrink = true      → minifier active
isTalking = true                             → dialog active
isDancing = false (in DanceScene)            → "ready" screen
isDancing = true  (in DanceScene)            → active rhythm battle
```

---

## MazeScene — Complete Input Table

### D-pad

| Input | Required State | Action |
|---|---|---|
| `up/down/left/right` (Hold) | `isGaming == true` | `player:move(direction)` — moves the player |
| `up/down/left/right` (Up) | Always | `player:idle()` — stops movement |

The in-game menu is purely visual (map + crew hats); the D-pad has no menu actions.

---

### Button A — Multi-Function by Priority

`AButtonDown` evaluates conditions in this order:

```
1. isTalking == true
   → player:displayDialog()

2. currentTrigger != nil  AND  isGaming == true
   → isGaming = false, isTalking = true
   → dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)

3. readyToShrink == true  AND  isGaming == true
   → player:startMinifying()

4. readyToCook == true  AND  isGaming == true   (independent `if`)
   → player:startCooking()   (microwave — see MICROWAVE_AND_FOOD.md)
```

`AButtonHeld` (after holding for 1 second):

```
isGaming == true  AND  hasDWatch == true
→ inGameEquip:displayMenu()
```

| Input | Condition | Action |
|---|---|---|
| `A` (Down) | `isTalking` | Advance / close dialog |
| `A` (Down) | `currentTrigger` + `isGaming` | Activate manual trigger |
| `A` (Down) | `isEquiping` | Confirm skill in menu |
| `A` (Down) | `readyToShrink` + `isGaming` | Start minification |
| `A` (Down) | `readyToCook` + `isGaming` + **not tiny** | Start cooking at microwave (`startCooking()`) — big-only |
| `A` (Hold every frame) | — | No action |
| **`A` (1 second hold)** | `isGaming` + `hasDWatch` | **Open equipment menu** |
| `A` (Up) | — | No action |

---

### Button B — Multi-Function by Priority

`BButtonDown` evaluates in this order:

```
1. isGaming == false  AND  isEquiping == true
   → inGameEquip:closeMenu()
   → isGaming = true, isEquiping = false

2. isGaming == false  AND  readyToShrink == true
   → player:finishMinifying()

2b. isGaming == false  AND  readyToCook == true
   → player:finishCooking()   (cancel/finish microwave cooking)

3. isGaming == true  AND  player.isAlive
   → player:useAbility()   (instant; requires a facing direction — idle does nothing)
       isInDarkness → lightBurst()  (flash)
       else         → plunge()      (plungerang boomerang)
```

Holding B instead starts a charge, and releasing fires the charged ability (see
"B Button — Hold & Release" below). Movement tokens are granted by each ability **when it
actually fires**, not on every B press.

| Input | Condition | Action |
|---|---|---|
| `B` (Down) | `!isGaming` + `isEquiping` | Close equipment menu |
| `B` (Down) | `!isGaming` + `readyToShrink` | Finish minification |
| `B` (Down) | `!isGaming` + `readyToCook` | Finish/cancel microwave cooking (`finishCooking()`) |
| `B` (Down) | `isGaming` + alive | Use instant ability — `lightBurst()` (dark) or `plunge()` (lit); requires a direction |
| `B` (Hold) | `isGaming` + alive, after `holdDelay` | Start charge — `beginDarkCharge()` (dark) or `beginGrappleCharge()` (lit) |
| `B` (Up) | charge active | End charge — dark reveal / grapple launch (nothing if undercharged) |

### B Button — Hold & Release

The B hold uses a **custom timer** in `MazeScene:update()` (`bButtonDownTime`), not the SDK's
`BButtonHeld` (which is fixed at 1 s). After `Config.DarkReveal.holdDelay` (dark) or
`Config.Grapple.holdDelay` (lit) ms of holding B, the matching charge begins and the
`crankClock` HUD indicator appears. While charging, crank rotation accumulates into the
charge instead of charging the battery. On release:
- **Dark reveal** — if crank ≥ `Config.DarkReveal.crankThreshold` and battery ≥
  `Config.DarkReveal.minBattery`, `activateDarkReveal()` fires.
- **Grapple launch** — `endGrappleCharge()` fires the hook, distance ∝ crank amount.
- Undercharged release fires nothing (the instant-ability fallback needs a direction, and you
  charge while idle).

---

### Crank

The crank uses `playdate.getCrankTicks(4)` — equivalent to 4 clicks per full revolution.

| Input | Condition | Action |
|---|---|---|
| Rotation (any) | `isDarkCharging` or `isGrappleCharging` | Routes delta to the active charge (`addDarkCrankDelta` / `addGrappleCrankDelta`); returns early, skipping battery charge |
| Positive rotation | `isAlive == true` AND **not** cooking | `player:burnCalories(1)` — **skipped while cooking** (`isGaming==false` + `readyToCook==true`) so the cook calorie byproduct isn't cancelled |
| Positive rotation | `isGaming` + `battery < 100` + not minifying/tiny | `player:chargeBattery(3)` + refresh shadow |
| Rotation (any) | `readyToShrink == true` | `player:transformCycle()` |
| Rotation (any) | `!isGaming` + `readyToCook == true` | Cook food: accumulate `cookProgress`; each `Config.Microwave.crankPerFood` ticks consumes 1 food for `+hpPerFood` HP and `+caloriesPerFood` calories (both clamped); auto-finishes at full HP or 0 food. See `MICROWAVE_AND_FOOD.md` |

Battery charges 3 points per crank tick. Negative crank rotation does not charge (only positive direction charges).

---

## DanceScene — Input Table

### Pre-Battle (`isDancing == false`)

| Input | Action |
|---|---|
| `A` (Down) | `scene:startBattle()` |
| Any other | No effect |

### Active Battle (`isDancing == true`)

| Input | Action | Basic Weight | Boss Weight |
|---|---|---|---|
| `left` (Down) | `danceStep("leftButton")` | 20% | 5% |
| `right` (Down) | `danceStep("rightButton")` | 20% | 5% |
| `up` (Down) | `danceStep("upButton")` | 20% | 5% |
| `down` (Down) | `danceStep("downButton")` | 20% | 5% |
| `A` (Down) | `danceStep("aButton")` + `checkDanceResults()` | 20% | 40% |
| `B` (Down) | `danceStep("bButton")` | 0% | 40% |
| Any (Up) | `clearButton()` | — | — |

The crank has no function in DanceScene.

---

## `CheatCode` Class

Defined in `utilities/Utilities.lua`. Allows registering button sequences with automatic timeout.

### Constructor

```lua
CheatCode("up", "up", "up", "down")
-- Valid identifiers: "a", "b", "up", "down", "left", "right"
```

Internally translates each key to the corresponding Playdate constant:

```lua
local keys = {
    a     = playdate.kButtonA,
    b     = playdate.kButtonB,
    up    = playdate.kButtonUp,
    down  = playdate.kButtonDown,
    left  = playdate.kButtonLeft,
    right = playdate.kButtonRight,
}
```

### Properties

| Property | Description |
|---|---|
| `self._seq` | Sequence of button constants |
| `self.progress` | Index of the currently expected button (1-based) |
| `self.completed` | `true` if the sequence was completed |
| `self.run_once` | If `true`, does not re-activate after completion |
| `self.onComplete` | Callback function on completion |

### `CheatCode:update()`

Called every frame. Uses `playdate.getButtonState()` to read the pressed button:
- If it matches `_seq[progress]` → advance `progress` and reset the timer.
- If it does not match → `self:reset()` (returns to progress=1).
- If `progress > #_seq` → `completed = true`, calls `onComplete()`.

### Timeout — `setTimerDelay(ms)`

Default: **400 ms**. If the player takes more than 400ms between buttons, the sequence is automatically reset via a `playdate.timer`.

### Debug Toggle

The debug cheat code (`up up up down`) is registered in `main.lua` (commented out in the current code) and calls `Utilities.toggle(debug)`. The sequence can also be activated from the Playdate System Menu with the "debug" item.

---

## Complete Decision Tree

```
AButtonDown:
├── isTalking?                → displayDialog()
├── currentTrigger + isGaming? → activate manual trigger
├── readyToShrink + isGaming? → startMinifying()
└── readyToCook + isGaming?   → startCooking()   (microwave)

AButtonHeld (1 sec):
└── isGaming + hasDWatch      → displayMenu()

BButtonDown:
├── !isGaming + isEquiping    → closeMenu(), isGaming=true
├── !isGaming + readyToShrink → finishMinifying()
├── !isGaming + readyToCook   → finishCooking()   (microwave)
└── isGaming + isAlive        → useAbility()   (instant; needs a direction)
      ├── isInDarkness → lightBurst()  (flash)
      └── else         → plunge()      (plungerang)

BButtonHeld (custom timer in MazeScene:update, ~holdDelay):
└── isGaming + isAlive → beginDarkCharge() (dark) / beginGrappleCharge() (lit)

BButtonUp:
└── endDarkCharge() / endGrappleCharge() → dark reveal or grapple launch

Movement tokens: granted by each ability when it fires (lightBurst / plunge /
grapple launch / dark reveal = Config.Player.movementTokensPerAction), NOT on every B press.
```

---

## Notes for Porting to Love2D

### Button Equivalents

| Playdate | Keyboard | Gamepad | Love2D |
|---|---|---|---|
| D-pad up | `W` / `↑` | D-pad up | `love.keyboard.isDown("w")` |
| D-pad down | `S` / `↓` | D-pad down | `love.keyboard.isDown("s")` |
| D-pad left | `A` / `←` | D-pad left | `love.keyboard.isDown("a")` |
| D-pad right | `D` / `→` | D-pad right | `love.keyboard.isDown("d")` |
| A button | `Space` / `Z` | South (Cross/A) | `love.keyboard.isDown("space")` |
| B button | `LShift` / `X` | West (Square/X) | `love.keyboard.isDown("lshift")` |
| Crank (rotation) | `Q`/`E` / Mouse wheel | R Stick Y | `love.keyboard.isDown("e")` |
| A held 1 sec | `Space` hold | South hold | Timer in `love.update` |

### 1-Second Hold for the Menu

```lua
local holdTimers = { action1 = 0 }
local HOLD_THRESHOLD = 1.0

function love.update(dt)
    if love.keyboard.isDown("space") then
        holdTimers.action1 = holdTimers.action1 + dt
        if holdTimers.action1 >= HOLD_THRESHOLD
        and PlayerData.isGaming and PlayerData.items.hasDWatch then
            inGameEquip:displayMenu()
            holdTimers.action1 = 0
        end
    else
        holdTimers.action1 = 0
    end
end
```

### Crank → Mouse Wheel

```lua
function love.wheelmoved(x, y)
    if y > 0 and PlayerData.isGaming and PlayerData.battery < 100 then
        player:chargeBattery(3)
    end
    player:burnCalories(1)
end
```

### `distributeMovementTokens` Runs When a B Ability Fires

A B ability advances the enemy turn only when it **actually fires** — `lightBurst` (flash),
`plunge` (plungerang), grapple launch, or dark reveal each grant
`Config.Player.movementTokensPerAction` (5) tokens. Tapping B with no valid action, or holding
B to charge while idle, grants nothing. In Love2D, replicate this per-ability behavior (not a
blanket grant on every B press).

### CheatCode in Love2D

The `CheatCode` class is pure Lua and only needs to replace `playdate.getButtonState()` with `love.keypressed` reading + manual sequence accumulation.
