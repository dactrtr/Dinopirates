# CrewMember and Collision System

Comprehensive documentation of the `CrewMember` entity behavior, its AI states, capture mechanics, and turn-based synchronization.

---

## CrewMember Class

File: `source/entities/enemies/crewmember.lua`

`CrewMember` extends `NobleSprite` directly (it does not extend `Enemy`). It is a captured allied NPC that flees from the player and can be caught.

### Constructor

```lua
function CrewMember:init(x, y, moveSpeed, Zindex, player, iid, room, crewId)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `x, y` | number | Initial position in px |
| `moveSpeed` | number | Base speed (defaults to 1.5 if nil) |
| `Zindex` | number | Rendering layer |
| `player` | table | Reference to the Player object |
| `iid` | string | Unique LDtk entity identifier |
| `room` | number | Room index in `levelsLDTK` |
| `crewId` | string | Crew member ID (e.g., `"CM001"`) |

### Initialized Fields

| Field | Initial Value | Description |
|-------|---------------|-------------|
| `self.moveSpeed` | parameter or 1.5 | Current speed |
| `self.initialSpeed` | same as `moveSpeed` | Base speed reference |
| `self.damage` | 0 | Does not damage the player |
| `self.player` | parameter | Reference to Player |
| `self.crewId` | parameter | ID for PlayerData.CrewMemberData |
| `self.iid` | parameter | Unique LDtk ID for persistence |
| `self.room` | parameter | Room in levelsLDTK |
| `self.movementFrames` | 0 | Available movement frames |
| `self.updateFrameCounter` | `math.random(0, 2)` | Random offset for throttling |
| `self.isHiding` | false | Active hiding state |
| `self.hidingMovementTokensRequired` | `Config.CrewMember.hidingTokensRequired` (3) | Tokens required to exit hiding |
| `self.hidingMovementTokensAccumulated` | 0 | Tokens accumulated while hiding |
| `self.hidingVisionRange` | `Config.CrewMember.hidingVisionRange` (80) | Player detection radius in px |
| `self.cornerDetectionThreshold` | `Config.CrewMember.cornerDetectionThreshold` (0.5) | Minimum difference in px to detect blocking |
| `self.recentBounceCount` | 0 | Recent bounce counter |
| `self.bounceCountDecayFrames` | 0 | Frames remaining before resetting counter |
| `self.bounceCountDecayRate` | `Config.CrewMember.bounceCountDecayRate` (30) | Frames until bounce counter decays |
| `self.bouncesRequiredToHide` | `Config.CrewMember.bouncesRequiredToHide` (2) | Bounces required to enter hiding |
| `self.bounceDirection` | nil | Escape direction during bounce: 'left', 'right', 'up', 'down' |
| `self.bounceFrames` | 0 | Remaining frames of movement in bounce direction |
| `self.isBlinded` | false | Temporary blindness state |
| `self.blindFrames` | 0 | Remaining blindness frames |
| `self.blindDuration` | `Config.CrewMember.blindDuration` (60) | Default blind duration |
| `self.isStunnedInfinitely` | nil/false | Permanent stun from plungerang |
| `self.hatDelta` | `Config.CrewMember.hatDelta` (15) | Hat Y offset relative to sprite |
| `self.hat` | `Hats(x, y-15, crewId, 2)` | Hat sprite |
| `self.originalCollideRect` | `Config.CrewMember.collideRect` | Original collision rect to restore |

### Size and Collisions

- **Sprite size**: 48×48 px.
- **Collide rect**: `Config.CrewMember.collideRect` = `{x=12, y=24, w=24, h=24}`.
- **Own group**: `CollideGroups.crewMember` (group 7).
- **Collides with**: props (3), wall (5), enemy (2), crewMember (7), player (1).

---

## AI States

The CrewMember has four implicit behavioral states, controlled by flags and the `update()` loop:

### 1. Wandering (inactive/idle)

State when `movementFrames == 0`. The CrewMember does not move and its animation changes to `'idle'`. There is no random wandering logic; it simply waits to receive movement frames.

### 2. Escaping (active)

When `movementFrames > 0` and the player is within `hidingVisionRange` and `PlayerData.isTiny == false`. Calls `escape(player)`:

```lua
function CrewMember:search(player)
    if not self:isPlayerOutOfVision() and not PlayerData.isTiny then
        self:escape(player)
    else
        self.animation:setState('idle')
    end
end
```

In `escape()`, movement is in the direction opposite to the player on both axes:
```lua
movementX = self.player.x <= self.x and self.x + self.moveSpeed or self.x - self.moveSpeed
movementY = self.player.y <= self.y and self.y + self.moveSpeed or self.y - self.moveSpeed
```

### 3. Bouncing

When the CrewMember hits a wall or enemy and `bounceFrames > 0`. It moves in the direction stored in `self.bounceDirection` for exactly `Config.CrewMember.bounceFrames` (20) frames, ignoring the player's position.

Direction is chosen based on the blocked axis and the player's relative position:
- Blocked on X: escapes on Y (`'up'` if player is below, `'down'` if above).
- Blocked on Y: escapes on X (`'right'` if player is to the left, `'left'` if to the right).
- Blocked on both (corner): direction chosen randomly between the two options (`math.random() > 0.5`).

### 4. Hiding

When the CrewMember has bounced 2 times (`bouncesRequiredToHide = 2`) within a short period. See the "Hiding State" section below.

---

## hidingTokens — Amount and Consumption

### Required Amount

`self.hidingMovementTokensRequired = Config.CrewMember.hidingTokensRequired = 3`

**3 tokens** of movement accumulated while the CrewMember is hiding are required to exit the hiding state (along with the condition that the player is out of vision range).

### How They Accumulate

When the CrewMember is in hiding state, tokens accumulate in `hidingMovementTokensAccumulated` instead of converting into movement. Each call to `addMovementTokens(amount)` or `addMovementFrames(frames)` with `isHiding == true` adds to the counter:

```lua
function CrewMember:addMovementTokens(amount)
    if self.isHiding then
        self.hidingMovementTokensAccumulated = self.hidingMovementTokensAccumulated + amount
        self:checkExitHiding()
    else
        self.movementFrames = self.movementFrames + (amount * Config.CrewMember.framesPerToken)
    end
end
```

For `addMovementFrames(frames)` while hiding:
```lua
local tokenEquivalent = frames / Config.CrewMember.framesPerToken  -- framesPerToken = 30
self.hidingMovementTokensAccumulated += tokenEquivalent
```

### Frames to Tokens Conversion

`Config.CrewMember.framesPerToken = 30`

1 token = 30 frames. Each player action distributes `Config.Player.movementFramesPerAction = 3` raw frames. Therefore, **30 player actions** are needed (3 frames × 30 = 90 frames / 30 fps = 3 tokens) to accumulate the 3 tokens required to exit hiding.

---

## sightRange and hidingRange — Exact Values

### hidingVisionRange (hiding vision range)

`Config.CrewMember.hidingVisionRange = 80` px

This is the Euclidean distance between the player and the CrewMember. The check uses real distance (not AABB):

```lua
function CrewMember:isPlayerOutOfVision()
    local dx = self.player.x - self.x
    local dy = self.player.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance > self.hidingVisionRange   -- true if player is more than 80 px away
end
```

- For the escape AI (`search()`), if `isPlayerOutOfVision() == true`, the CrewMember stays idle even with available movement frames.
- To exit hiding, `isPlayerOutOfVision() == true` is required (player more than 80 px away).

### cornerDetectionThreshold (blocking detection threshold)

`Config.CrewMember.cornerDetectionThreshold = 0.5` px

In `moveCollision()`, the attempted position is compared against the actual position after resolving collisions:
```lua
local blockedX = math.abs(actualX - movementX) > self.cornerDetectionThreshold  -- > 0.5 px
local blockedY = math.abs(actualY - movementY) > self.cornerDetectionThreshold
```

If the difference between the target position and the actual position exceeds 0.5 px on any axis, that axis is considered blocked and the bounce logic is triggered.

---

## hasBag — Capture Condition

In the current system, capturing a CrewMember does **not** explicitly validate whether the player has the bag in `collisions.lua`. The collision always calls `other:taken()` when the player (at normal size) touches the CrewMember.

However, there is preparatory logic for the first encounter:

```lua
elseif other:isa(CrewMember) then
    if PlayerData.isTiny then
        self.currentTrigger = other    -- tiny mode: interaction instead of capture
        return 'overlap'
    end

    if PlayerData.CrewMemberData.amountTaken == 0 then
        if other.crewId == 'CM001' then
            -- custom screen for first crewmember (TODO: implement)
        end
        self.dialogUI:addScreen("gotcha", other.sourceFeed)  -- first capture screen
    end
    other:taken()
```

The field `PlayerData.items.hasBag` exists in `PlayerDataTables.lua` but validation of the bag before capturing is marked as pending (the `-- custom screen here` comment indicates incomplete work).

---

## Capture Mechanic — Collision Response

When the player (at normal size) collides with a CrewMember:

1. If `PlayerData.isTiny == true`: `self.currentTrigger = other` is assigned and returns `'overlap'`. No capture occurs; the CrewMember acts as a dialog trigger.
2. If it is the first capture (`amountTaken == 0`): the "gotcha" screen is shown with `dialogUI:addScreen("gotcha", other.sourceFeed)`.
3. `other:taken()` is called.

### taken()

```lua
function CrewMember:taken()
    -- Search levelsLDTK for the CrewMember by iid
    for _, crewData in ipairs(roomData.entities.CrewMember) do
        if crewData.iid == self.iid then
            crewData.customFields.isTaken = true           -- mark in live table
            PlayerData.CrewMemberData.amountTaken += 1    -- increment global counter
            if self.crewId then
                PlayerData.CrewMemberData.idNumbers[self.crewId] = true  -- mark specific ID
            end
            self.player.hasProjectile = true               -- restore plungerang if lost
            break
        end
    end
    self:remove()   -- removes CrewMember sprite and its hat
end
```

The `remove()` method also removes the hat:
```lua
function CrewMember:remove()
    if self.hat then
        self.hat:remove()
        self.hat = nil
    end
    CrewMember.super.remove(self)
end
```

---

## crewID and amountTaken in PlayerData

Defined in `PlayerDataTables.lua`:

```lua
CrewMemberData = {
    amountTaken = 0,      -- total number of crew members captured
    idNumbers = {         -- table of captured IDs: {["CM001"] = true, ...}
    }
}
```

- `amountTaken`: integer counter that increments by 1 per capture. Used in `collisions.lua` to detect the first encounter.
- `idNumbers[crewId]`: boolean that marks whether a specific crewId was captured. Allows checking capture of specific crew members by ID.

### Notes

- `amountTaken` is used for the "first time" logic in `collisions.lua`.
- There is no defined maximum in the code; the game has no victory condition based on `amountTaken` within the CrewMember code.

---

## isTaken — Save/Load Persistence

### Writing (save)

In `CrewMember:taken()`, `levelsLDTK[room].entities.CrewMember[i].customFields.isTaken = true` is modified directly. When `SaveSystem.save()` runs (on room exit or pause), it serializes the modified entity fields (identified by `iid`), including `isTaken`.

### Reading (load)

In `SaveSystem.load()`, saved entities are applied to the fresh `levelsLDTK` table by matching `iid`. If `isTaken == true` is saved for a CrewMember, the load restores that value in the live table.

### Skip in MazeScene

In `MazeScene:enter()`, when spawning CrewMembers:
```lua
-- skip if already taken
if not entityData.customFields.isTaken then
    -- spawn CrewMember(...)
end
```

If `isTaken == true`, the CrewMember is not instantiated in the room.

---

## Hiding State — Full Detail

### Entering Hiding (enterHiding)

Triggered from `moveCollision()` when `recentBounceCount >= bouncesRequiredToHide` (2):

```lua
function CrewMember:enterHiding()
    self.isHiding = true
    self.hidingMovementTokensAccumulated = 0
    self.animation:setState('hide')        -- frames 12-13
    self.hat:setVisible(false)             -- hide hat
    self:setCollideRect(0, 0, 0, 0)        -- remove collision
    self:setGroups({})                     -- exit all collision groups
end
```

While hiding:
- `update()` returns early, only maintaining the `'hide'` animation.
- Does not consume `movementFrames` or execute AI.
- Cannot be captured (no collision).
- Cannot be blinded (`blind()` checks `isHiding` and returns without effect).

### Exiting Hiding (exitHiding)

Checked in `checkExitHiding()`, called from `addMovementTokens()` and `addMovementFrames()`:

```lua
function CrewMember:checkExitHiding()
    if self:isPlayerOutOfVision() and
       self.hidingMovementTokensAccumulated >= self.hidingMovementTokensRequired then
        self:exitHiding()
    end
end
```

Both conditions must be met simultaneously:
1. Player more than 80 px Euclidean distance away.
2. At least 3 movement tokens accumulated during hiding.

`exitHiding()` restores the original collide rect, the `CollideGroups.enemy` group (note: should be `crewMember`; this is a known bug), the `'idle'` animation, and makes the hat visible again.

> **Bug**: `exitHiding()` calls `self:setGroups(CollideGroups.enemy)` (group 2) instead of `CollideGroups.crewMember` (group 7). This causes the post-hiding CrewMember to be treated as an enemy by the collision system.

---

## Turn-Based Synchronization — isActive Verification

The CrewMember does **not directly check** `PlayerData.isActive`. Instead, the system works through external frame distribution:

### How It Works

1. When the player moves, the player movement code calls `addMovementFrames(3)` (or `addMovementTokens`) on all active CrewMembers and Enemies in the room.
2. The CrewMember only runs AI in `update()` when `movementFrames > 0`.
3. If the player does not move, no frames are distributed, and CrewMembers remain idle.

This implements the "time moves when you move" concept without the CrewMember needing to read `isActive` directly.

### update() Loop

```lua
function CrewMember:update()
    self:setZIndex(self.y)                              -- dynamic y-sort
    self.updateFrameCounter = (self.updateFrameCounter + 1) % 2

    -- Priority 1: hiding
    if self.isHiding then
        self.animation:setState('hide')
        return
    end

    -- Priority 2: blinded or infinite stun
    if self.isBlinded or self.isStunnedInfinitely then
        if self.isBlinded then
            self.blindFrames -= 1
            if self.blindFrames <= 0 then
                self.isBlinded = false
            end
        end
        if self.isStunnedInfinitely then
            self.animation:setState('stunned')
        end
        return   -- early exit
    end

    -- Priority 3: active movement
    if self.movementFrames > 0 then
        self.movementFrames -= 1
        if self.updateFrameCounter % 2 == 0 then
            self:search(self.player)   -- AI every 2 frames
        end
    else
        self.animation:setState('idle')
    end
end
```

Note: the CrewMember throttle is every **2 frames** (`% 2 == 0`), unlike Brocorat which is every **3 frames** (`% 3 == 0`). This gives the CrewMember smoother movement.

---

## stunInfinite()

Triggered by the plungerang when it hits the CrewMember:

```lua
function CrewMember:stunInfinite()
    self.isStunnedInfinitely = true
    self.movementFrames = 0
    self.animation:setState('stunned')   -- frames 15-18
    self.hat:setVisible(false)
end
```

The infinite stun is permanent for the session (there is no way to revert it in the current code). A stunned CrewMember cannot be captured directly via collision while `isStunnedInfinitely == true`, as it remains in the collision group but its AI is stopped.

---

## CrewMember Animation States

| State | Frames | frameDuration | Description |
|-------|--------|---------------|-------------|
| `walk` | 1–4 | 8 | Active movement |
| `idle` | 5–8 | 6 | Waiting without movement |
| `hide` | 12–13 | 6 | Hidden in a corner |
| `stunned` | 15–18 | 6 | Stunned by plungerang |

---

## moveCollision() in CrewMember

The CrewMember's version of `moveCollision()` differs from Enemy's in that it:
1. Manages speed based on player battery.
2. Moves the hat (`self.hat:moveTo`) together with the sprite.
3. Implements the blocking detection and bounce system.
4. Calls `collision.other:collisionResponse(self)` when it contacts the player.

### Speed Based on Battery in Darkness

```lua
if PlayerData.battery < Config.CrewMember.batteryThresholdStop and PlayerData.isInDarkness then
    self.moveSpeed = 0                    -- battery < 10: CrewMember stops
elseif PlayerData.battery > Config.CrewMember.batteryThresholdRestore and PlayerData.isInDarkness then
    self.moveSpeed = self.initialSpeed    -- battery > 60: normal speed restored
end
```

- `batteryThresholdStop = Config.Battery.thresholdCritical = 10`
- `batteryThresholdRestore = Config.Battery.thresholdMid = 60`

Unlike Enemy, the CrewMember has no intermediate thresholds; only full stop or normal speed.

---

## Notes for Love2D Port

### Escape AI

The `escape()` calculation is pure Lua. Replace `moveCollision()` with the Love2D collision system. The bounce logic (direction opposite to the blocked axis) can be implemented by comparing the attempted position vs. the actual position after resolving collisions.

### hidingTokens System

The pattern `hidingMovementTokensAccumulated >= hidingMovementTokensRequired` is fully portable. It only requires calling `addMovementTokens()` from the player movement system.

### Euclidean Distance for isPlayerOutOfVision

```lua
-- In Love2D (identical, no SDK dependencies):
local dx = player.x - self.x
local dy = player.y - self.y
local distance = math.sqrt(dx*dx + dy*dy)
return distance > 80   -- hidingVisionRange
```

### Two Sprites per CrewMember

Each CrewMember instantiates a separate `Hats` sprite positioned at `y - hatDelta` (15 px above the sprite center). In Love2D, render both sprites in the same component draw call, or manage the hat as a sub-entity. The hat is moved in `moveCollision()` with `self.hat:moveTo(actualX, actualY - self.hatDelta)`.

### Collision Groups

Collision group mapping:
| Name | Value |
|------|-------|
| player | 1 |
| enemy | 2 |
| props | 3 |
| items | 4 |
| wall | 5 |
| noCollide | 6 |
| crewMember | 7 |

In Love2D with Box2D, implement as fixture categories (bitmask). Without Box2D, filter collisions manually in the entity iteration.

### Turn-Based Without isActive

The frame distribution pattern is SDK-independent:
```lua
-- In the player movement system (Love2D):
for _, crewMember in ipairs(activeCrewMembers) do
    crewMember:addMovementFrames(3)   -- Config.Player.movementFramesPerAction
end
```

Call this once per player movement action (not every frame).
