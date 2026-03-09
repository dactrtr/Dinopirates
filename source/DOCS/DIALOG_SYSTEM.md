# Dialog & Script System Documentation

This document explains how the dialog engine works, how scripts are structured, and how localized text and media are displayed.

---

## 📜 Script Data Structure
Dialogs are defined in `source/assets/data/script.lua`. Each script is a table with a unique `name` and a list of `dialog` entries.

### Script Entry Example
```lua
{
    name = "wakeup",
    dialog = {
        { video = 'playerSleepy', text = "wakeup-01" },
        { video = 'playerWorry', text = "wakeup-02" },
        { video = 'playerSurprise', text = "wakeup-03" }
    }
}
```

- **`video`**: Refers to an animation state in the `videoFeed`.
- **`text`**: A localization key found in `en.strings` or `jp.strings`.
- **`screen`** (Optional): A `Graphics.image` object to show as a main visual (e.g., items or cutscene stills).

---

## 📺 UI Components

The system consists of three main classes in `entities/UI/dialog/`:

### 1. `dialogScreen`
The main controller. It manages:
- **`addScreen(scriptName)`**: Searches the global `script` table, finds the entry, and initiates the dialog sequence. It also sets `PlayerData.isTalking = true`.
- **`nextDialog()`**: Advances to the next line in the current script. It updates the text, resets the video feed, and adds images to the screen.
- **`removeAll()`**: Closes the dialog and restores game control.

### 2. `videoFeed`
Displays an animated portrait in the dialog box.
- Supported states include: `player`, `playerWorry`, `playerSurprise`, `playerHappy`, `playerAngry`, `playerSleepy`, `radioHand`, `radioRing`, `notesHand`, and `tiny`.
- **Dynamic "Tiny" States**: If the player is in the "tiny" state (`PlayerData.isTiny == true`), the system automatically appends `-tiny` to the requested video state (e.g., `radioHand-tiny`). This ensures the correct miniature portrait is shown.

### 3. `imageScreen`
A helper sprite used to display static images (defined in the script's `screen` field) above the dialog box.

---

## 🕹️ Interaction and Triggers

Dialogs can be triggered automatically by game events or manually by player interaction.

### Manual Interaction (HUD Feedback)
When the player is inside a manual trigger (like `Search` or `Call`), a HUD icon appears above their head:
*   **Investigate Icon**: Shown for `Search` type triggers.
*   **Radio Ring Icon**: Shown for `Call` type triggers.
*   **Press A Icon**: Shown for default triggers without a specific type.

Pressing **A** while inside these areas calls `dialogUI:addScreen`.

### Automatic Interaction
Triggers of type `Story` or `Cutscene` activate `dialogUI:addScreen` or the cutscene logic immediately upon collision, with no HUD prompt required.

### Navigating Dialogs
While `PlayerData.isTalking` is true:
- Pressing **A** advances the dialog via `dialogUI:nextDialog()`. This interaction is explicitly bound to the `AButtonDown` event handler (e.g., in `MazeScene.lua`) to prevent double-firings within the same frame as opening a dialog.
- Movement and most game logic (including enemies) are paused to allow the player to read.
- Once the last line is reached, the UI automatically closes and `PlayerData.isTalking` is set to false.

### Missing Dialog Safe-fallbacks [NEW]
- If a requested script name does not exist in `script.lua`, `self:removeAll()` is immediately called, aborting the dialog safely without throwing a nil-indexing error.
- Interacting with `CrewMember` entities in tiny mode defaults to looking for `<crewId>_tiny` (e.g. `CM001_tiny`). If the specific crew member has no dialog written, it falls back to a special safety dialog named `default_tiny`.

---

## 🌍 Localization
The system uses the standard Playdate `strings` files.
- Text is retrieved using `Graphics.getLocalizedText(key, lang)`.
- All keys used in `script.lua` must have a corresponding entry in `source/en.strings` (and other languages).

> [!NOTE]
> Ensure all script names and localization keys follow a consistent naming convention to avoid missing strings.
