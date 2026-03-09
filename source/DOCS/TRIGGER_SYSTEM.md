# Conditional Trigger System

This system allows Triggers to execute different scripts depending on the player's state and interaction type.

## 1. LDtk Configuration

Add the following **Custom Fields** to your `Triggers` entity in LDtk:

*   **Identifier**: `conditionalScripts`
    *   **Type**: `Array<String>`
*   **Identifier**: `type`
    *   **Type**: `String` (Options: `Story`, `Cutscene`, `Search`, `Call`, `Counter`)
*   **Identifier**: `script`
    *   **Type**: `String` (Used as a fallback or for simple triggers)

## 2. Trigger Types and Behaviors

The `type` field determines how the trigger is activated and how the player interacts with it.

### A. Automatic Triggers
*   **`Story`**: Activated automatically upon collision. It immediately triggers a dialogue sequence using the script name returned by the condition logic.
*   **`Cutscene`**: Activated automatically upon collision. It disables normal gameplay input and starts a cutscene (comic-style).
*   **`Counter`**: Activated automatically upon collision. It increments the global `PlayerData.storyCounter` and removes itself immediately.

### B. Manual Triggers (Interactable)
These triggers do not activate automatically. Instead, they show a HUD prompt when the player is inside the trigger area, requiring the player to press **A** to activate.

*   **`Search`**: Displays an "Investigate" HUD icon. Used for inspecting objects in the world.
*   **`Call`**: Displays a "Radio Ring" HUD icon. Used for incoming or outgoing radio communications.
*   **`null` (None)**: If no type is specified, it defaults to showing a standard "Press A" HUD icon.

## 3. Condition Logic (`conditionalScripts`)

Conditions in `conditionalScripts` follow the format `condition:script`.

### A. Boolean Conditions
*   `isTiny:script` (If player is tiny)
*   `!isTiny:script` (If player is NOT tiny)
*   `items.hasLamp:script` (If player has the lamp)

### B. Numerical Comparisons
Supported operators: `>`, `<`, `>=`, `<=`, `==`, `!=`
*   `mapPercent>50:midGameDialogue`
*   `battery<20:lowBatteryWarning`

Evaluating follows a **top-to-bottom** priority. The first condition met will be executed.

## 4. Persistence and Single-Use (IMPORTANT)

By default, conditional scripts **DO NOT remove the trigger**. This is useful for repeatable hints or "locked" messages.

To make a script **remove the trigger** after one use, append `!` to the end of the script name.

*   `!hasKey:msgLocked` -> **Keeps** the trigger (Player can see it multiple times).
*   `hasKey:openDoor!` -> **Removes** the trigger (Occurs only once).

**Persistence Defaults:**
*   **Manual Triggers (`Search`, `Call`)**: Persist by default unless `!` is used.
*   **`Story` / `Cutscene`**: Usually intended to be single-use. If using the legacy `script` field (not conditional), they are removed automatically after activation.
*   **`Counter`**: Always removed after activation.

## 5. Dialog Integration

The trigger system communicates with `dialogUI:addScreen(scriptName)` to display text.

### Character Portraits (Video Feed)
Each dialog entry can specify a `video` state (e.g., `player`, `playerHappy`). 
*   **Tiny State Support**: If `PlayerData.isTiny` is true, the system automatically appends `-tiny` to the video state (e.g., `player-tiny`) to show the correct miniature portrait.

### Localization
All text keys used in `script.lua` must be defined in the localization files:
*   `source/en.strings` (English)
*   `source/jp.strings` (Japanese)

**Example Entry in `en.strings`**:
`"door-locked" = "It's locked from the other side."`
