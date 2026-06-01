# CockpitScene — Cockpit Puzzle

**File**: `scenes/CockpitScene.lua`
**Entities**: `entities/UI/cockpit/`

An interactive puzzle scene reached from TitleScene (or directly from the debug menu). The player moves a pointer using the accelerometer or D-pad, positions it over physical buttons, and presses them in the correct order. Completing a sequence triggers a scene transition; too many incorrect presses return the player to TitleScene.

---

## Local State

| Variable | Type | Purpose |
|---|---|---|
| `buttons` | table | All `CockpitButton` sprites (13 total) |
| `bars` | CockpitBars | Decorative widget with animated horizontal bars |
| `radar` | CockpitRadar | Decorative widget with animated dot grid |
| `indicators` | CockpitIndicators | Displays sequence progress and fail bar |
| `pointer` | CockpitPointer | Animated cursor sprite |
| `pointerX / pointerY` | number | Current pointer position in screen coordinates |
| `baseAx / baseAy` | number | Accelerometer calibration baseline |
| `calibrated` | bool | Whether the accelerometer has been calibrated |
| `failCount` | number | Accumulated incorrect presses in this session |
| `sequences` | table | List of sequence definitions (pattern + action + index) |
| `bgImage` | Graphics.image | Cockpit background image (`cockpit_background`) |
| `fgSprite` | Graphics.sprite | Cockpit foreground sprite (`cockpit_foreground`) |

---

## Scene Lifecycle

### `init()`
Only calls `scene.super.init`. No additional logic.

### `enter()`
1. Resets all state variables: `calibrated = false`, `baseAx/baseAy = 0`, `pointerX/Y = 200/120`, `buttons = {}`, `failCount = 0`.
2. Calls `resetAllSequences()` to reset all sequence indices to 1.
3. Loads `bgImage` from `assets/images/cockpit/cockpit_background`.
4. Creates `fgSprite` from `assets/images/cockpit/cockpit_foreground` at zIndex `ZIndex.ui - 1`, centered at (200, 120) with `setIgnoresDrawOffset(true)`.
5. Calls `playdate.startAccelerometer()`.
6. Creates the 13 `CockpitButton` sprites according to `btnDefs`.
7. Creates `CockpitBars(206, 190, 50, 31)`, `CockpitRadar(50, 200, 80, 60)`, `CockpitIndicators()`.
8. Creates `CockpitPointer` and positions it at (pointerX, pointerY).

### `start()`
Only calls `scene.super.start`. No additional logic.

### `update()`
Each frame:
1. Reads accelerometer (`ax`, `ay`). If `not calibrated` and the values are non-zero, stores them as the baseline.
2. Applies D-pad movement first (see D-pad Fallback section).
3. If the D-pad moved, recalibrates the accelerometer baseline.
4. Calculates `targetX/Y` and lerps the pointer toward that position.
5. Moves the `CockpitPointer` sprite to (pointerX, pointerY).
6. Switches pointer animation to `hover` if over any button, or `idle` if not.
7. Updates `CockpitIndicators` with the leading sequence progress and fail rate.

### `drawBackground()`
Draws `bgImage` at (0, 0) over a white background.

### `exit()`
1. Calls `playdate.stopAccelerometer()`.
2. Removes all buttons from `buttons` and clears the table.
3. Removes and nil-ifies `bars`, `radar`, `pointer`, `indicators`, `fgSprite`.
4. Nil-ifies `bgImage`.

### `finish()`
Resets the draw mode to `Graphics.kDrawModeCopy`.

---

## Input

| Input | Action |
|---|---|
| Accelerometer (tilt) | Moves the pointer (calibrated to the device orientation on the first non-zero reading) |
| D-pad | Moves the pointer at `Config.Cockpit.dpadSpeed` px/frame; re-anchors the accelerometer baseline to avoid conflict |
| Button A | Presses the button under the pointer; `ESC` button → transitions to TitleScene |
| Button B | Resets the pointer to center (200, 120) and clears calibration (`calibrated = false`) |

---

## Accelerometer Control

**Calibration**: the first time `ax != 0` or `ay != 0`, those values are stored as `baseAx/baseAy` and `calibrated = true`. This fixes the resting point to the device's actual tilt angle at that moment.

**Re-anchor base (D-pad)**: when the D-pad moves the pointer, the baseline is recalculated so that the accelerometer "sees" the new position as the center:
```
baseAx = ax - (pointerX - halfW) / (halfW * sens)
baseAy = ay - (pointerY - halfH) / (halfH * sens)
```
This prevents the two control systems from conflicting between frames.

**Target calculation**:
```
targetX = clamp(0, Width,  halfW + (ax - baseAx) * halfW * accelSensitivity)
targetY = clamp(0, Height, halfH + (ay - baseAy) * halfH * accelSensitivity)
```

**Lerp smoothing**:
```
pointerX += (targetX - pointerX) * lerpFactor
pointerY += (targetY - pointerY) * lerpFactor
```

Config values (`Config.Cockpit`):

| Key | Default | Meaning |
|---|---|---|
| `lerpFactor` | 0.15 | Pointer smoothing (0 = frozen, 1 = instant) |
| `accelSensitivity` | 2.0 | Multiplier on the raw tilt delta |
| `dpadSpeed` | 3 | Pixels per frame with D-pad |
| `failLimit` | 10 | Incorrect presses before returning to TitleScene |

---

## D-pad Fallback

The D-pad is processed before the accelerometer each frame. Speed: `Config.Cockpit.dpadSpeed` (3 px/frame). The pointer is clamped to screen bounds (`Config.Screen.width` x `Config.Screen.height`). If any D-pad direction is pressed, the baseline re-anchor is triggered (see above).

---

## Pointer-Button Detection

`CockpitButton:isHovered(px, py)` performs an AABB check:
```lua
px >= bx - w/2  and  px <= bx + w/2
py >= by - h/2  and  py <= by + h/2
```
where `bx/by` is the sprite position (center) and `w/h` are the stored dimensions. The `isOverAnyButton()` function iterates all buttons and returns `true` as soon as it finds one.

---

## Sequence System

`sequences` is a list of tables, each with:
- `pattern` — ordered list of button labels to press
- `action` — function called when the pattern is completed (normally `Noble.transition`)
- `index` — current position in the pattern (1 = waiting for the first button)

### Hardcoded Sequences

| Pattern | Result |
|---|---|
| `"1" → "3" → "2" → "4"` | `Noble.transition(CreditsScene, 0.3, Noble.Transition.MetroNexus)` |
| `"A" → "B" → "C" → "D"` | `Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)` |

To add a new sequence, add an entry to the `sequences` table at the top of the file — no other changes are required.

### `pressButton(label)`

1. Iterates all sequences.
2. For each sequence: if `label == seq.pattern[seq.index]` — advances `seq.index += 1` and marks `advanced = true`.
   - If `seq.index > #seq.pattern` → calls `seq.action()`, resets all sequences, resets `failCount`, and returns.
   - If it does not match → resets that `seq.index = 1`.
3. If no sequence was advanced (`not advanced`): increments `failCount`. If `failCount >= Config.Cockpit.failLimit` → `Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)`.

Sequences run in parallel. A button can advance one sequence and reset another simultaneously.

### `resetAllSequences()`

Iterates `sequences` and sets `seq.index = 1` on all of them. Called automatically when any sequence is completed.

---

## failLimit

`Config.Cockpit.failLimit = 10`. When the player presses a button that does not advance any active sequence, `failCount` grows. Upon reaching 10 accumulated failures, `Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)` is executed. The counter resets to 0 when a sequence is completed successfully.

---

## Progress Bar — `leadingSequence()`

```lua
local function leadingSequence()
    local best = sequences[1]
    for _, seq in ipairs(sequences) do
        if seq.index > best.index then best = seq end
    end
    return best
end
```

Selects the most advanced sequence (highest `index`). This is the one that feeds `CockpitIndicators`:
```lua
indicators:setData(leading.index - 1, #leading.pattern, math.min(1, failCount / Config.Cockpit.failLimit))
```
- First argument: correctly pressed buttons so far.
- Second: total length of the sequence.
- Third: fail ratio (0–1) for the error bar.

---

## Button Layout

All positions are sprite centers. Buttons are invisible in normal mode (`setVisible(debug == true)`) — they function exclusively as hit zones. In debug mode they render as 3D rectangles with their label in the `shinonome` font.

| Label | x | y | w | h | Group |
|---|---|---|---|---|---|
| `1` | 26 | 140 | 32 | 48 | Left panel |
| `2` | 74 | 140 | 32 | 48 | Left panel |
| `3` | 166 | 200 | 24 | 16 | Central grid, left column |
| `4` | 166 | 220 | 24 | 16 | Central grid, left column |
| `6` | 166 | 180 | 24 | 16 | Central grid, left column |
| `7` | 246 | 200 | 24 | 16 | Central grid, right column |
| `8` | 246 | 220 | 24 | 16 | Central grid, right column |
| `9` | 246 | 180 | 24 | 16 | Central grid, right column |
| `A` | 372 | 63 | 28 | 22 | Far-right keypad |
| `B` | 372 | 89 | 28 | 22 | Far-right keypad |
| `C` | 372 | 115 | 28 | 22 | Far-right keypad |
| `D` | 372 | 141 | 28 | 22 | Far-right keypad |
| `ESC` | 206 | 228 | 50 | 20 | Exit button |

Layout notes (from internal code comments):
- Left central column (x≈166): buttons 6 (y=180), 3 (y=200), 4 (y=220).
- Right central column (x≈246): buttons 9 (y=180), 7 (y=200), 8 (y=220).
- Left panel (x=26/74, y=140): buttons 1 and 2, larger size (32×48).
- `CockpitBars` at (206, 190), size 50×31, between the two central columns.

---

## Entities

### `CockpitButton` (`entities/UI/cockpit/CockpitButton.lua`)
`Graphics.sprite`. Draws a raised 3D rectangle (white background, black border, bottom and right shadow) with the label centered in the `shinonome` font. Only visible when `debug == true`. Hit detection: AABB against the stored center and dimensions in `self.w`/`self.h`.

### `CockpitPointer` (`entities/UI/cockpit/CockpitPointer.lua`)
`NobleSprite`. Spritesheet at `assets/images/ui/cockpit/ui-pointer`. Size 28×28. ZIndex: `ZIndex.ui + 10` (above all other UI). Two animation states:
- `idle` — frames 1–2, duration 8 frames
- `hover` — frames 3–4, duration 8 frames

### `CockpitBars` (`entities/UI/cockpit/CockpitBars.lua`)
`Graphics.sprite`. Decorative widget at (206, 190), size 50×31. Renders 5 horizontal bars that lerp to independent random values each frame (`LERP_SPEED = 0.06`, `CHANGE_RATE = 0.03` probability per frame per bar). No gameplay effect. ZIndex: `ZIndex.ui`.

### `CockpitRadar` (`entities/UI/cockpit/CockpitRadar.lua`)
`Graphics.sprite`. Decorative widget at (50, 200), size 80×60. A dot grid where dots appear and fade randomly. No gameplay effect.

### `CockpitIndicators`
Displays the leading sequence progress and fail ratio. Updated each frame via `indicators:setData(steps, total, fails)`.

---

## Notes — Differences from Love2D / Non-Playdate Environments

- `playdate.startAccelerometer()` / `playdate.stopAccelerometer()` — these calls do not exist in Love2D. In a port, replace the accelerometer with joystick or mouse position.
- `playdate.readAccelerometer()` returns `(ax, ay, az)` in an approximate range of -1 to 1. In Love2D, `love.joystick:getAxis()` or relative mouse movement can substitute.
- `playdate.buttonIsPressed()` is equivalent to `love.keyboard.isDown()` or `love.gamepad:isGamepadDown()`.
- `Noble.transition` is Noble Engine-specific — in Love2D it is equivalent to a game state change with animation.
- ZIndex values in Playdate are positive integers where higher = on top. Love2D uses explicit layer ordering via the call order in `love.graphics.draw`.
