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
- **Dynamic "Tiny" States**: If the player is in the "tiny" state (`PlayerData.isTiny == true`), the system automatically attempts to display a `-tiny` version of the requested video state (e.g., `radioHand-tiny`). If a specific tiny state is not defined in `videoFeed.lua`, it will fallback to a default behavior or error depending on implementation (currently it appends `-tiny`).

### 3. `imageScreen`
A helper sprite used to display static images (defined in the script's `screen` field) above the dialog box.

---

## 🌍 Localization
The system uses the standard Playdate `strings` files.
- Text is retrieved using `Graphics.getLocalizedText(key, lang)`.
- All keys used in `script.lua` must be defined for all supported languages (e.g., `source/en.strings`).

---

## 🕹️ Triggering Dialogs

### From Code (Collisions/Events)
In `collisions.lua` or other event handlers, you can trigger a dialog by calling `addScreen` on the player's `dialogUI`:
```lua
self.dialogUI:addScreen("gotcha")
```

### From LDtk (Triggers)
The `Trigger` entity in LDtk can be configured with a `script` custom field.
- In `MazeScene.lua`, when a player enters a trigger and presses **A**, the game fetches the script name from the trigger and calls `dialogUI:addScreen`.

### Navigating Dialogs
While `PlayerData.isTalking` is true:
- Pressing **A** calls `player:displayDialog()`, which triggers `dialogUI:nextDialog()` to advance the text.
- Once the last line is reached, the UI automatically removes itself.

> [!NOTE]
> Dialogs pause movement logic and certain AI updates to ensure the player can read the story without being attacked.
