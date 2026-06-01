# Player Sleep State — Design Spec

## Goal

When the player enters MazeScene coming from TitleScene (Continue or New Game), the player sprite starts in a sleeping animation and all input is blocked. After any two button presses, the player wakes up and transitions directly to idle, enabling normal gameplay.

## Trigger

`PlayerData.fromTitle` (boolean, default `false`) is a transient flag added to `PlayerDataTables.lua`. It is set to `true` in TitleScene immediately before `Noble.transition(FloorXXX, ...)` for both Continue and New Game actions. MazeScene resets it to `false` in `scene:start()` before consuming it. Because it is always reset before any `SaveSystem.save()` call, it is never persisted as `true`.

To support the unlock screen (CockpitScene) in the future: set `PlayerData.fromTitle = true` before any `Noble.transition(FloorXXX, ...)` call added there.

## Player State

**New fields in `Player:init()`:**
- `self.isSleeping = false`
- `self.wakeupPresses = 0`

**New methods in `source/entities/player/state.lua`:**

### `Player:startSleeping()`
- Sets `self.isSleeping = true`
- Sets `self.wakeupPresses = 0`
- Sets animation state to `'sleep'`
- Leaves `PlayerData.isGaming = false` (already false at the point it is called)

### `Player:onWakePress()`
- Increments `self.wakeupPresses`
- If `self.wakeupPresses >= 2`, calls `self:wake()`

### `Player:wake()`
- Sets `self.isSleeping = false`
- Sets animation state: `'lampIdle'` if lamp+dark+not tiny, `'tinyIdle'` if tiny, otherwise `'idle'`
- Sets `PlayerData.isGaming = true`

**Animation bug fix in `source/entities/player/animations.lua` line 94:**
```lua
-- Before (bug: sets wrong animation's frameDuration)
self.animation.slideTiny.frameDuration = 2

-- After
self.animation.sleep.frameDuration = 4
```

## MazeScene Integration

**`source/scenes/MazeScene.lua` — `scene:start()`:**

Replace:
```lua
PlayerData.isGaming = true
```
With:
```lua
if PlayerData.fromTitle then
    PlayerData.fromTitle = false
    player:startSleeping()
else
    PlayerData.isGaming = true
end
```

**`scene.inputHandler` — `AButtonDown` (top of handler):**
```lua
if player and player.isSleeping then
    player:onWakePress()
    return
end
```

**`scene.inputHandler` — `BButtonDown` (top of handler):**
```lua
if player and player.isSleeping then
    player:onWakePress()
    return
end
```

**`scene:update()` — D-pad detection during sleep:**
In the D-pad section, wrap the direction logic to skip movement when sleeping, and separately detect new dpad presses:
```lua
if player and player.isSleeping then
    local dpad = {
        playdate.kButtonUp, playdate.kButtonDown,
        playdate.kButtonLeft, playdate.kButtonRight
    }
    for _, btn in ipairs(dpad) do
        if playdate.buttonJustPressed(btn) then
            player:onWakePress()
            break
        end
    end
    -- skip movement (do not call player:move())
else
    -- existing direction calculation + player:move(direction) call
end
```

## Files Modified

| File | Change |
|------|--------|
| `source/assets/data/PlayerDataTables.lua` | Add `fromTitle = false` |
| `source/entities/player/animations.lua` | Fix sleep frameDuration bug (line 94) |
| `source/entities/player/init.lua` | Add `self.isSleeping`, `self.wakeupPresses` |
| `source/entities/player/state.lua` | Add `startSleeping()`, `onWakePress()`, `wake()` |
| `source/scenes/MazeScene.lua` | Modify `start()`, `inputHandler`, `update()` |
| `source/scenes/TitleScene.lua` | Set `PlayerData.fromTitle = true` before both FloorXXX transitions |

## No Test Runner

Validate by running in the Playdate simulator: start new game from TitleScene, confirm player is in sleep animation and blocked, press two buttons, confirm switch to idle and free movement.
