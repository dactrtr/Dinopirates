# Dialog System

The dialog system displays localized text, animated portraits, and static images while the game is paused. It is used by Triggers, NPCs, cutscenes, and crewmember events.

> See also: [TRIGGER_SYSTEM.md](TRIGGER_SYSTEM.md) for how triggers fire dialogs. [NPC_SYSTEM.md](NPC_SYSTEM.md) for NPC interaction. [SCRIPTS_TRIGGERS_NPC_SCHEMA.md](SCRIPTS_TRIGGERS_NPC_SCHEMA.md) for the `script.lua` schema.

---

## 1. `dialogScreen` — Constructor and Fields

Class: `dialogScreen` in `entities/UI/dialog/dialogScreen.lua`. Extends `Graphics.sprite`.

```lua
function dialogScreen:init(position)
    self:setZIndex(ZIndex.alert + 1)  -- 2201: above everything else
    self:moveTo(16, 165)              -- fixed position: text at the bottom
    self:setCenter(0, 0)
    dialogbg  = dialogBG()            -- creates the dialog box background
    screenimg = imageScreen()         -- creates the static image slot
end
```

| Field / variable | Scope | Description |
|-----------------|-------|-------------|
| `dialogbg` | module-local | `dialogBG` sprite: the background image of the dialog box (`assets/images/ui/dialog/dialogbox.png`), positioned at `(0, 138)`. |
| `screenimg` | module-local | `imageScreen` sprite: displays optional static images positioned at `(50, 4)`. |
| `video` | module-local | Current `videoFeed` instance: the animated portrait. Recreated on each line. |
| `dialogcounter` | module-local | Index of the current line within the `dialog` array. Starts at `1`. Reset to `1` when closed. |
| `dialogPosition` | module-local | Index in the global `script` table of the active entry. |
| `videoActive` | module-local | Boolean that prevents recreating the videoFeed if it is already active in the current frame. |

### Helper Classes

**`dialogBG`**: extends `Graphics.sprite`. Only displays the dialog box background image. ZIndex: `ZIndex.alert` (2200).

**`imageScreen`**: extends `Graphics.sprite`. Displays static images from the `screen` field of a `DialogLine`. ZIndex: `ZIndex.alert + 1` (2201). Removed if the current line has no `screen`.

---

## 2. `script.lua` Format — Complete Structure

The global `script` table is defined in `assets/data/script.lua`. It is an array of dialog entries.

### Entry Structure

```lua
{
    name = "uniqueName",   -- identifier, referenced by Triggers and NPCs
    dialog = {             -- array of lines, displayed in order
        {
            video  = "player",            -- animated portrait state (required)
            text   = "key-01",            -- localization key in en.strings (required)
            screen = Graphics.image.new(  -- optional static image
                'assets/images/ui/dialog/img/file.png'
            ),
        },
        {
            video  = "radioHand",
            text   = "key-02",
            -- no screen: imageScreen is hidden on this line
        },
    }
}
```

### `DialogLine` Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `video` | String | Yes | Name of the animation state in `videoFeed`. See list of valid states below. |
| `text` | String | Yes | Localization key. Resolved with `Graphics.getLocalizedText(key, lang)`. |
| `screen` | Graphics.image | No | Static image that appears above the dialog box. If absent, `screenimg` is removed. |

### Valid `video` States

| State | Description |
|-------|-------------|
| `player` | Player neutral portrait |
| `playerWorry` | Player worried |
| `playerSurprise` | Player surprised |
| `playerHappy` | Player happy |
| `playerAngry` | Player angry |
| `playerSleepy` | Player sleepy/drowsy |
| `playerScared` | Player scared |
| `playerCry` | Player crying |
| `radioHand` | Radio in hand |
| `radioPocket` | Radio in pocket |
| `radioRing` | Radio ringing |
| `notesHand` | Notes in hand |

**Tiny state**: If `PlayerData.isTiny == true`, the system automatically appends `-tiny` to the state (e.g., `player-tiny`, `radioHand-tiny`). There is no standalone `tiny` state.

---

## 3. How Dialog is Triggered

### From a `Story` type Trigger (automatic)

```lua
-- player/collisions.lua
elseif other.type == "Story" then
    PlayerData.isGaming = false
    self.dialogUI:addScreen(other:returnScript(), other.sourceFeed)
```

### From a manual Trigger (`Search`, `Call`, `nil`) — player presses A

```lua
-- MazeScene.inputHandler.AButtonDown
PlayerData.isGaming = false
PlayerData.isTalking = true
player.dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)
```

### From an NPC — player presses A

Same flow as a manual Trigger. The NPC implements `returnScript()` which evaluates its `conditionalScripts`.

### From a cutscene / crewmember event

```lua
-- collisions.lua — crewmember capture
self.dialogUI:addScreen("gotcha", other.sourceFeed)

-- collisions.lua — blocked portal
self.dialogUI:addScreen(other.blockedDialog or "nokeys")

-- collisions.lua — locked door without key
self.dialogUI:addScreen("nokeys")
```

---

## 4. State: `PlayerData.isTalking` and Input Blocking

`PlayerData.isTalking` is the central flag indicating that dialog is active.

| Flag | When set to `true` | When set to `false` |
|------|--------------------|---------------------|
| `isTalking` | In `dialogScreen:addScreen()` just before showing the first line. Also in `MazeScene.AButtonDown` before calling `addScreen()`. | In `dialogScreen:removeAll()` when closing the dialog (last line or forced close). |
| `isGaming` | In `dialogScreen:removeAll()` when restoring gameplay. | In the code that fires the dialog (`collisionResponse` or `AButtonDown`). |

While `isTalking == true`:
- Player movement is blocked (`movePlayer()` checks `isTalking`).
- Enemies and NPCs do not update their AI (turn-based sync, depends on `isActive`).
- Button input only advances the dialog (A) or opens the equipment menu.

---

## 5. How Dialog Advances (Buttons)

Dialog advances line by line with the A button.

```lua
-- MazeScene.inputHandler.AButtonDown
if PlayerData.isTalking == true then
    player:displayDialog()
end
```

`player:displayDialog()` calls `player.dialogUI:nextDialog()`.

### `nextDialog()` — Internal Logic

```
nextDialog()
  1. Adds dialogbg to the scene (in case it was removed)
  2. Reads dialogArray = script[dialogPosition].dialog
  3. If dialogcounter <= array size:
     a. Determines the video state for the current line
     b. If PlayerData.isTiny == true: appends "-tiny" to the state
     c. Creates videoFeed(400, 240, videoState, ZIndex.alert)
     d. If the line has .screen: screenimg:addScreenfeed(screen)
        If not: screenimg:remove()
     e. Renders the localized text in dialogtext (250×64 image)
        using font KH-Dot-Akihabara-16 and Graphics.getLocalizedText()
     f. Adds self (dialogScreen) to the scene
     g. Increments dialogcounter
  4. If dialogcounter > array size:
     a. Resets dialogcounter = 1
     b. Calls self:removeAll() to close the dialog
```

**Note**: The binding is `AButtonDown` in MazeScene, not `AButtonHeld` or `AButtonHold`. This prevents the same frame that opens the dialog from immediately closing it.

---

## 6. How Dialog Ends and Clears State

`dialogScreen:removeAll()` is called automatically when `dialogcounter` exceeds the total number of lines.

```lua
function dialogScreen:removeAll()
    PlayerData.isTalking = false   -- unblocks input
    PlayerData.isGaming  = true    -- restores gameplay
    videoActive = false
    if dialogbg    ~= nil then dialogbg:remove()    end
    if video       ~= nil then video:remove()       end
    if screenimg   ~= nil then screenimg:remove()   end
    self:remove()
end
```

All dialog system sprites are removed. `dialogcounter` was already reset to `1` before calling `removeAll()`.

### Behavior When Script is Not Found

If `addScreen()` does not find the script name in the `script` table:

```lua
printDebug("Warning: Dialog '" .. scriptName .. "' not found")
return
```

- `PlayerData.isTalking` is **not** set to `true`.
- `PlayerData.isGaming` remains in its current state (may be left as `false` if the caller already changed it before `addScreen()`).
- No crash, no dialog, no blank screen. The game may be left in an undefined state if `isGaming` was set to `false` before the call.

---

## Love2D Notes

### Advancing Dialog

Replace `AButtonDown` with `love.keypressed`:

```lua
function love.keypressed(key)
    if PlayerData.isTalking and (key == "return" or key == "space") then
        dialogUI:nextDialog()
    end
end
```

### Text Rendering

Replace `Graphics.drawTextInRect` and `Graphics.getLocalizedText` with:

```lua
-- Simplified, no typewriter effect
love.graphics.printf(localizedText, x, y, maxWidth)
```

For a typewriter effect, add a timer that progressively reveals characters.

### Animated Portraits (videoFeed)

Load each state as an animation using `anim8` or `love.graphics.newQuad` on a spritesheet. Map state names to frames. Apply the `-tiny` suffix when `PlayerData.isTiny == true`.

### Missing Script Handling

Add an explicit guard in Love2D to prevent `isGaming` from being left as `false`:

```lua
function DialogScreen:addScreen(name)
    local entry = findScript(name)
    if not entry then
        print("Warning: Dialog '" .. name .. "' not found")
        PlayerData.isGaming = true   -- restore for safety
        return
    end
    PlayerData.isTalking = true
    -- ... continue
end
```

### Localization

The system uses `Graphics.getLocalizedText(key, lang)` with Playdate SDK `.strings` files. In Love2D, replace with your own localization table:

```lua
local strings = require("strings.en")
local text = strings[key] or key
```
