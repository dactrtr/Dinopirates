# CrewMember and Collision Screen Documentation

This document explains how the `CrewMember` entity works and how to show custom screens within the `collisions.lua` system.

---

## 🏴‍☠️ CrewMember Logic

The `CrewMember` is a specialized enemy entity with complex behavior for escaping the player and hiding when trapped.

### 1. Movement & AI
- **Escape Mode**: In its `update` loop, if not hiding or blinded, the `CrewMember` calculates a path away from the player.
- **Movement Tokens**: Movement is throttled by a token system.
    - `addMovementTokens(amount)`: Adds frames of movement based on tokens (1 token ≈ 30 frames).
    - `addMovementFrames(frames)`: Adds raw frames of movement (capped at 90).
    - The `update` loop only processes AI search/movement if `movementFrames > 0`.

### 2. Collision & Bouncing [UPDATED]
The `CrewMember` has refined collisions to balance navigation and obstacle avoidance.
- **Collision Mask**: It uses the dedicated `CollideGroups.crewMember` group. It checks for collisions with `CollideGroups.props`, `CollideGroups.wall`, and `CollideGroups.enemy`.
- **Response Logic (`collisionResponse`)**:
    - **Walls (`Box`)**: Set to `'slide'`.
    - **Enemies (`Enemy`)**: Set to `'slide'`. This blocks movement and triggers the bounce logic, allowing crew members to avoid each other and other enemies.
    - **Physical Props**: Set to `'slide'` (chairs, tables, etc.).
    - **Minifier**: Set to `'overlap'`. Crew members pass through the pod freely without triggering interactions.
    - **Items & Triggers**: Set to `'overlap'`.
- **Bounce Mechanic**: If blocked by a physical obstacle (including enemies), it increments `recentBounceCount`.
- **Direction Redirect**: If blocked, it enters a "bounce" state for 20 frames, choosing a perpendicular direction.

### 3. Hiding State
If the `CrewMember` bounces 3 times in quick succession (`bouncesRequiredToHide`), it enters the **Hiding State**:
- **Invisibility**: Sprite sets its state to `'hide'`.
- **Non-collidable**: `setCollideRect(0, 0, 0, 0)` and groups are cleared.
- **Exit Conditions**:
    1. Player must be outside `hidingVisionRange` (80 pixels).
    2. Enough movement tokens must be accumulated (`hidingMovementTokensRequired = 3`).

### 4. Special Interactions
- **Blinding**: `blind(frames)` stops the entity for a duration.
- **Projectile (Plungerang)**: The `Projectile` entity is configured to hit the `crewMember` group. When hit, it calls `stunInfinite()` on the crew member.
- **Taking**: `taken()` marks the crew member as captured in `PlayerData`, updates the UI count, and removes the sprite.

### 5. Tiny Mode Interactions [NEW]
If the player is in Tiny Mode (`PlayerData.isTiny == true`):
- **No Escape**: The crewmember will not run away (the `search` function defaults to `idle`).
- **Trigger Behavior**: Instead of being captured immediately, colliding with the crewmember sets them as the player's `currentTrigger` (`'overlap'` response instead of capture).
- **Dialogs**: This allows the player to press 'A' to interact, opening a dialog exactly like a standard `Trigger` entity. It uses the `tinyScript` from LDtk, falling back to `<crewId>_tiny` or `default_tiny` in `script.lua`.

---

## 📺 Custom Screens in Collisions

Screens (dialogs/UI overlays) are managed via `PlayerData` and the `dialogUI` component.

### 1. The Collision Hook [UPDATED]
In `source/entities/player/collisions.lua`, the `Player:collisionResponse(other)` function handles interactions.

**Note**: Colliding with a `CrewMember` does **NOT** trigger damage, blinking, or invincibility. It only initiates the capture logic.

To show a custom screen when hitting a specific `CrewMember`:
```lua
elseif other:isa(CrewMember) then
    -- Example logic: Show a unique screen for a specific Crew ID
    if other.crewId == 'CM001' then
        self.dialogUI:addScreen("unique_intro_screen")
    end
    
    -- Generic screen for capture
    if PlayerData.CrewMemberData.amountTaken == 0 then
        self.dialogUI:addScreen("gotcha", other.sourceFeed)
    end
    
    other:taken()
end
```

### 2. How `addScreen` Works
The `dialogUI` (instance of `dialogScreen.lua`) uses `addScreen(scriptName)`:
- It searches the `script` table (loaded globally, usually from `assets/data/scripts.lua`) for an entry with a matching `name`.
- It sets `PlayerData.isTalking = true`, which pauses normal gameplay logic.
- It displays the associated text, video feed, or images defined in the script.

### 3. Customizing the Screen
To add a new screen:
1.  **Define the Script**: Add an entry to your scripts data file.
    ```lua
    {
        name = "my_custom_screen",
        dialog = {
            { text = "LEVEL_UP_TEXT", video = "celebration", screen = someImage }
        }
    }
    ```
2.  **Call it in `collisions.lua`**: Use `self.dialogUI:addScreen("my_custom_screen")`.

> [!TIP]
> Use `other.sourceFeed` as the second argument if you want to pass a specific video feed index to the dialog system.
