# Player Sleep State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When starting a game from TitleScene (Continue or New Game), the player appears sleeping and all input is blocked until any two button presses wake them up and switch to idle.

**Architecture:** A transient `PlayerData.fromTitle` flag signals MazeScene that the player should start asleep. Three new methods on `Player` (`startSleeping`, `onWakePress`, `wake`) own the state. Button detection lives in `Player:update()` via `buttonJustPressed`. MazeScene input handlers are guarded with `if player.isSleeping then return end` to prevent side effects.

**Tech Stack:** Playdate Lua SDK, Noble Engine. No test runner — validate in simulator.

---

## File Map

| File | Change |
|------|--------|
| `source/assets/data/PlayerDataTables.lua` | Add `fromTitle = false` |
| `source/entities/player/animations.lua` | Fix sleep `frameDuration` bug (line 94) |
| `source/entities/player/init.lua` | Add `self.isSleeping = false`, `self.wakeupPresses = 0` |
| `source/entities/player/state.lua` | Add `startSleeping()`, `onWakePress()`, `wake()`; add sleep guard at top of `Player:update()` |
| `source/scenes/TitleScene.lua` | Set `PlayerData.fromTitle = true` before Continue and NewGame transitions |
| `source/scenes/MazeScene.lua` | Modify `scene:start()` to call `player:startSleeping()`; guard all `ButtonDown` and `ButtonUp` handlers |

---

## Task 1: Add `fromTitle` flag to PlayerData

**Files:**
- Modify: `source/assets/data/PlayerDataTables.lua:50`

- [ ] **Step 1: Read the file and find the `isGaming` line**

```
source/assets/data/PlayerDataTables.lua line 50: isGaming = false,
```

- [ ] **Step 2: Add `fromTitle = false` after `isGaming`**

Replace:
```lua
	isGaming = false,
```
With:
```lua
	isGaming = false,
	fromTitle = false,
```

- [ ] **Step 3: Compile to verify no syntax errors**

```bash
cd /Users/dactrtr-mini/Documents/GitHub/Dinopirates
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output (no errors).

---

## Task 2: Fix sleep animation frameDuration bug

**Files:**
- Modify: `source/entities/player/animations.lua:93-94`

- [ ] **Step 1: Read lines 93-94 to confirm the bug**

Current state:
```lua
  self.animation:addState('sleep', 145, 148)
  self.animation.slideTiny.frameDuration = 2
```
Line 94 sets `slideTiny`'s frameDuration instead of `sleep`'s. This is a bug.

- [ ] **Step 2: Fix the frameDuration target**

Replace:
```lua
  self.animation:addState('sleep', 145, 148)
  self.animation.slideTiny.frameDuration = 2
```
With:
```lua
  self.animation:addState('sleep', 145, 148)
  self.animation.sleep.frameDuration = 4
```

- [ ] **Step 3: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 3: Add sleep state fields to Player:init()

**Files:**
- Modify: `source/entities/player/init.lua:64-65`

The `init.lua` already sets `PlayerData.isActive = false` at line 64 and `self.loadingPower = false` at line 65. Add the two new fields alongside the other state variables.

- [ ] **Step 1: Add `self.isSleeping` and `self.wakeupPresses` after `self.loadingPower`**

Find this block (lines 64-65):
```lua
    PlayerData.isActive = false
    self.loadingPower = false
```

Replace with:
```lua
    PlayerData.isActive = false
    self.loadingPower = false
    self.isSleeping = false
    self.wakeupPresses = 0
```

- [ ] **Step 2: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 4: Add sleep methods and update() guard to Player

**Files:**
- Modify: `source/entities/player/state.lua`

Three new methods go at the end of the file, before the last blank line. `Player:update()` gets a sleep guard at the very top.

> **Context:** `Player:idle()` already exists in `state.lua` (line 72) and handles lamp/tiny state correctly — `wake()` reuses it. `Player:update()` is also in `state.lua` (line 251).

- [ ] **Step 1: Add the three sleep methods at the end of state.lua**

Append after `Player:checkForegroundDepth()` (after line 335), before the final blank line:

```lua
function Player:startSleeping()
    self.isSleeping = true
    self.wakeupPresses = 0
    self.animation:setState('sleep')
end

function Player:onWakePress()
    self.wakeupPresses += 1
    if self.wakeupPresses >= 2 then
        self:wake()
    end
end

function Player:wake()
    self.isSleeping = false
    self:idle()
    PlayerData.isGaming = true
end
```

- [ ] **Step 2: Add sleep guard at the top of Player:update() (line 251)**

Find the start of `Player:update()`:
```lua
function Player:update()
  -- Update dash movement if dashing
  self:updateDash()
```

Replace with:
```lua
function Player:update()
  if self.isSleeping then
    local buttons = {
      playdate.kButtonA, playdate.kButtonB,
      playdate.kButtonUp, playdate.kButtonDown,
      playdate.kButtonLeft, playdate.kButtonRight
    }
    for _, btn in ipairs(buttons) do
      if playdate.buttonJustPressed(btn) then
        self:onWakePress()
        break
      end
    end
    return
  end

  -- Update dash movement if dashing
  self:updateDash()
```

- [ ] **Step 3: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 5: Set fromTitle flag in TitleScene before transitions

**Files:**
- Modify: `source/scenes/TitleScene.lua`

There are two transitions from TitleScene to a FloorXXX scene:
1. **Continue** (line ~166): `Noble.transition(nextScene, 1, Noble.Transition.Spotlight, ...)`
2. **New Game** (line ~208): `Noble.transition(Floor407, 1, Noble.Transition.Spotlight, ...)`

- [ ] **Step 1: Add `PlayerData.fromTitle = true` before the Continue transition**

Find this block (inside the Continue action):
```lua
						Noble.transition(nextScene, 1, Noble.Transition.Spotlight, {
```

Replace with:
```lua
						PlayerData.fromTitle = true
						Noble.transition(nextScene, 1, Noble.Transition.Spotlight, {
```

- [ ] **Step 2: Add `PlayerData.fromTitle = true` before the New Game transition**

Find this block (inside the New Game action):
```lua
				Noble.transition(Floor407, 1, Noble.Transition.Spotlight, {
					x = 200, y = 120,
					xExit = PlayerData.playerSpawn.x,
					yExit = PlayerData.playerSpawn.y,
					holdTime = 0.25, ease = Ease.outInQuad
				})
```

Replace with:
```lua
				PlayerData.fromTitle = true
				Noble.transition(Floor407, 1, Noble.Transition.Spotlight, {
					x = 200, y = 120,
					xExit = PlayerData.playerSpawn.x,
					yExit = PlayerData.playerSpawn.y,
					holdTime = 0.25, ease = Ease.outInQuad
				})
```

- [ ] **Step 3: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 6: Wire up sleep in MazeScene

**Files:**
- Modify: `source/scenes/MazeScene.lua`

Two types of changes:
1. `scene:start()` — conditionally call `player:startSleeping()` instead of setting `isGaming = true`
2. All `ButtonDown` and `ButtonUp` handlers — early return when sleeping to prevent side effects

- [ ] **Step 1: Modify scene:start() to conditionally start sleeping**

Find (lines 359-363):
```lua
function scene:start()
	scene.super.start(self)
	self:setDiagonalMovement(diagonalMovement)
	PlayerData.isGaming = true
end
```

Replace with:
```lua
function scene:start()
	scene.super.start(self)
	self:setDiagonalMovement(diagonalMovement)
	if PlayerData.fromTitle then
		PlayerData.fromTitle = false
		player:startSleeping()
	else
		PlayerData.isGaming = true
	end
end
```

- [ ] **Step 2: Guard AButtonDown**

Find (line 475):
```lua
	AButtonDown = function()			-- Runs once when button is pressed.
		if PlayerData.isTalking == true then
```

Replace with:
```lua
	AButtonDown = function()			-- Runs once when button is pressed.
		if player and player.isSleeping then return end
		if PlayerData.isTalking == true then
```

- [ ] **Step 3: Guard AButtonHeld**

Find (line 499):
```lua
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		-- Your code here
		if PlayerData.isGaming == true and PlayerData.items.hasDWatch == true then
```

Replace with:
```lua
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		if player and player.isSleeping then return end
		if PlayerData.isGaming == true and PlayerData.items.hasDWatch == true then
```

- [ ] **Step 4: Guard BButtonDown**

Find (line 512):
```lua
	BButtonDown = function()
		-- Close equipment menu if open
		if PlayerData.isGaming == false and PlayerData.isEquiping == true then
```

Replace with:
```lua
	BButtonDown = function()
		if player and player.isSleeping then return end
		-- Close equipment menu if open
		if PlayerData.isGaming == false and PlayerData.isEquiping == true then
```

- [ ] **Step 5: Guard D-pad ButtonDown handlers**

Find `leftButtonDown`:
```lua
	leftButtonDown = function()
		if isDiagonalMovementEnabled or not isPlayerMoving then
```
Replace with:
```lua
	leftButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
```

Find `rightButtonDown`:
```lua
	rightButtonDown = function()
		if isDiagonalMovementEnabled or not isPlayerMoving then
```
Replace with:
```lua
	rightButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
```

Find `upButtonDown`:
```lua
	upButtonDown = function()
		if isDiagonalMovementEnabled or not isPlayerMoving then
```
Replace with:
```lua
	upButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
```

Find `downButtonDown`:
```lua
	downButtonDown = function()
		if isDiagonalMovementEnabled or not isPlayerMoving then
```
Replace with:
```lua
	downButtonDown = function()
		if player.isSleeping then return end
		if isDiagonalMovementEnabled or not isPlayerMoving then
```

- [ ] **Step 6: Guard D-pad ButtonUp handlers (prevents idle() overwriting sleep animation)**

Find `leftButtonUp`:
```lua
	leftButtonUp = function()
		if currentMoveDirection == 'left' then
```
Replace with:
```lua
	leftButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'left' then
```

Find `rightButtonUp`:
```lua
	rightButtonUp = function()
		if currentMoveDirection == 'right' then
```
Replace with:
```lua
	rightButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'right' then
```

Find `upButtonUp`:
```lua
	upButtonUp = function()
		if currentMoveDirection == 'up' then
```
Replace with:
```lua
	upButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'up' then
```

Find `downButtonUp`:
```lua
	downButtonUp = function()
		if currentMoveDirection == 'down' then
```
Replace with:
```lua
	downButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'down' then
```

- [ ] **Step 7: Compile**

```bash
pdc source "DinoPirates from inner space Brocolation.pdx" 2>&1 | grep -i error
```
Expected: no output.

---

## Task 7: Verify in simulator

No test runner — visual validation only.

- [ ] **Step 1: Open in simulator**

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

- [ ] **Step 2: New Game path**

1. From TitleScene, select **New Game**
2. When MazeScene loads: player must show sleeping animation, not idle
3. Press any button once: nothing happens (player still sleeping)
4. Press any second button: player switches to idle, movement works normally
5. Navigate to another room and back: player does NOT sleep again (only once per title entry)

- [ ] **Step 3: Continue path**

1. Save a game, return to TitleScene
2. Select **Continue**
3. Same checklist as Step 2

- [ ] **Step 4: Room-to-room navigation does NOT trigger sleep**

Navigate from floor to floor via doors. Player should start in idle (not sleeping) in every room except the first one after TitleScene.
