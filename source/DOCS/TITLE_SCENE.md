# TitleScene — Main Menu

**File**: `scenes/TitleScene.lua`
**UI Sprites**: `entities/ui/menuTitle.lua`, `entities/UI/titleBackground.lua`
**Dependencies**: `utilities/SaveSystem`

The first scene loaded by `Noble.new(TitleScene)` in `main.lua`. Acts as the main menu. It has two distinct modes: **normal mode** (with animated sprites and background) and **debug mode** (simple text menu), controlled by the global `debugMenu`.

Background: `Graphics.kColorWhite`.

---

## Local State

| Variable | Type | Purpose |
|---|---|---|
| `menuItems` | table | List of menu entries (sprite, animation states, action) |
| `selectedIndex` | number | Currently highlighted menu item |
| `crankTick` | number | Accumulated crank delta for navigation |
| `background` | TitleBackground | Full-screen animated background sprite |
| `isDebugMenu` | bool | Snapshot of `debugMenu` taken in `enter()` |
| `versionSprite` | sprite | Version text rendered in the top-right corner |

---

## Scene Lifecycle

### `init()`
1. Calls `SaveSystem.createOriginalBackup()` — deep copy of `levelsLDTK` to allow resetting without re-reading files. Subsequent calls within SaveSystem are no-ops.
2. Legacy: writes the `playerOriginal` datastore if `levelOriginal.json` does not exist.

### `enter()`
Rebuilds the entire menu from scratch each time the scene is entered.

1. `PlayerData.isGaming = false`.
2. `Graphics.setImageDrawMode(Graphics.kDrawModeCopy)`.
3. Clears `menuItems = {}`.
4. Takes snapshot `isDebugMenu = (debugMenu == true)`.
5. Creates the **version sprite**: text `"* Demo X.X.X *"` rendered into an offscreen image with `kDrawModeFillBlack`, as a sprite at ZIndex 200, positioned in the top-right corner (`x = 400 - vw/2 - 2`, `y = vh/2 + 2`).
6. If `isDebugMenu` → builds the debug menu (see Debug section). Otherwise → builds the normal menu.
7. Calls `updateMenuSelection()` to apply the initial visual state.

### `start()`
Only calls `scene.super.start`. No additional logic.

### `update()`
In debug mode: draws the text menu overlay each frame with `Graphics.drawTextAligned`.
In normal mode: no additional code in update (sprites self-render).

### `exit()`
Removes all `MenuTitle` sprites from `menuItems`, the `TitleBackground`, and the version sprite. Clears `menuItems = {}`.

### `finish()`
Resets draw mode to `Graphics.kDrawModeCopy`.

### `pause()` / `resume()`
Only call their respective `scene.super`.

---

## Normal Mode (default)

Active when `debugMenu ~= true`.

### Background (TitleBackground)

`TitleBackground` is a 400×240 px `NobleSprite` at position (200, 120), ZIndex 1. The spritesheet has one frame per menu state (frameDuration 4 for all):

| State | Frame |
|---|---|
| `continue` | 1 |
| `deleteGame` | 3 |
| `newGame` | 6 |
| `achievements` | 8 |

The frame changes via `background:changeState(menuItems[selectedIndex].backgroundState)` each time the selection changes. The Credits and Achievements items both share the `achievements` background state (frame 8).

### Menu Construction

Layout anchor: `startX = 88`, `startY = 120`, `spacing = 20` px between items. Items stack vertically from startY.

Save check: `hasSave = playdate.file.exists('gameState.json')`.

| Item | Shown when | Default frame | Selected frame |
|---|---|---|---|
| **Continue** | `hasSave == true` | 1 (`defContinue`) | 2 (`selContinue`) |
| **Delete Game** | `hasSave == true` | 5 (`defDeleteGame`) | 6 (`selDeleteGame`) |
| **New Game** | always | 3 (`defNewGame`) | 4 (`selNewGame`) |
| **Achievements** | always | 7 (`defAchievements`) | 8 (`selAchievements`) |
| **Credits** | always | 9 (`defCredits`) | 10 (`selCredits`) |

When no save exists: the menu has 3 items (New Game, Achievements, Credits) starting at `startY = 120`.
When a save exists: the menu has 5 items; Continue occupies `startY`, Delete Game `startY + 20`, New Game `startY + 40`, etc.

Each item is registered in `menuItems` with:
- `sprite`: `MenuTitle` instance
- `defaultState`: name of the `def*` animation state
- `selectedState`: name of the `sel*` animation state
- `backgroundState`: name of the background state
- `action`: function to execute when A is pressed

### `updateMenuSelection()`
Iterates `menuItems`. The item at `i == selectedIndex` gets `animation:setState(selectedState)`; all others get `animation:setState(defaultState)`. Then calls `background:changeState(menuItems[selectedIndex].backgroundState)`.

### MenuTitle Sprite (`entities/ui/menuTitle.lua`)
`NobleSprite`. Spritesheet: `assets/images/screens/menuTitle`. Size 180×56. ZIndex received as parameter (100 in all current cases). Collision group 3. Has 12 animation states (single frames):

| State | Frame | State | Frame |
|---|---|---|---|
| `defContinue` | 1 | `selContinue` | 2 |
| `defNewGame` | 3 | `selNewGame` | 4 |
| `defDeleteGame` | 5 | `selDeleteGame` | 6 |
| `defAchievements` | 7 | `selAchievements` | 8 |
| `defCredits` | 9 | `selCredits` | 10 |
| `defPlayground` | 11 | `selPlayground` | 12 |

---

## Debug Menu

Active when `debugMenu == true` (the global `debugMenu` is activated via the system menu → "debug" or cheat code `up up up down`).

No `TitleBackground` or `MenuTitle` sprites are created. The menu is drawn as plain text in `update()`:
- Title: `"*[ DEBUG MODE ]*"` centered at (200, 80)
- Items at (200, 110 + (i-1)*20), centered; selected item prefixed with `"*> "` and suffixed with `" <*"`

| Item | Action |
|---|---|
| **COCKPIT** | `Noble.transition(CockpitScene, 0.3, Noble.Transition.MetroNexus)` |
| **SPACE** | `Noble.transition(SpaceScene, 0.3, Noble.Transition.MetroNexus)` |
| **GAME** | `SaveSystem.reset()` + `Noble.transition(Floor407, 1, Spotlight, ...)` |
| **PLAYGROUND** | `PlayerData.playerSpawn = {x=200, y=200}` + `Noble.transition(Floor409, 0.3, MetroNexus)` |
| **DANCE** | Configures `PlayerData.lastEnemyTouched` + `DanceScene.debugMode = true` + `Noble.transition(DanceScene, 0.3, MetroNexus)` |

---

## Crank Navigation

```lua
cranked = function(change, _)
    crankTick = crankTick + change
    if crankTick > Config.Input.crankMenuThreshold then
        crankTick = 0
        selectNext()
    elseif crankTick < -Config.Input.crankMenuThreshold then
        crankTick = 0
        selectPrevious()
    end
end
```

`Config.Input.crankMenuThreshold = 30` degrees of rotation to trigger a selection change. The same logic applies in `DeadScene`.

`selectNext()` / `selectPrevious()` wrap cyclically: if `selectedIndex > #menuItems` it returns to 1; if `< 1` it goes to `#menuItems`. Both call `updateMenuSelection()` when done.

---

## Full Input Reference

| Input | Effect |
|---|---|
| D-pad Up | Selects previous item (with wrap) |
| D-pad Down | Selects next item (with wrap) |
| Crank | Accumulates in `crankTick`; triggers prev/next when crossing ±30° |
| Button A | Executes `menuItems[selectedIndex].action()` |

---

## New Game Flow

```
SaveSystem.reset()          -- resets PlayerData and levelsLDTK entity states
PlayerData.fromTitle = true
Noble.transition(Floor407, 1, Noble.Transition.Spotlight, {
    x      = 200,                      -- spotlight center (screen)
    y      = 120,
    xExit  = PlayerData.playerSpawn.x, -- spotlight exit point
    yExit  = PlayerData.playerSpawn.y,
    holdTime = 0.25,
    ease   = Ease.outInQuad
})
```

The starting room is `Floor407` (level 4, room 07). `SaveSystem.reset()` restores `levelsLDTK` from the original backup and resets `PlayerData` to its initial values.

---

## Continue Flow

```
SaveSystem.load()
  └─ returns (success, savedLevel)   -- savedLevel is an integer RoomID (e.g. 407)
RoomTranslate(savedLevel)
  └─ returns FloorXXX class
Noble.transition(nextScene, 1, Noble.Transition.Spotlight, {
    x      = 200,
    y      = 120,
    xExit  = PlayerData.playerSpawn.x,
    yExit  = PlayerData.playerSpawn.y,
    holdTime = 0.25,
    ease   = Ease.outInQuad
})
```

If `RoomTranslate` returns nil (room ID not found), it falls back to `Floor120`.
`SaveSystem.load()` applies saved entity states onto a fresh `levelsLDTK` table and returns the `saveLevel` stored in `PlayerData`.

---

## Delete Game Flow

```
SaveSystem.delete()                   -- deletes gameState.json
Utilities.clearAllAchievements()      -- clears achievements
Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)  -- restarts the menu
```

The menu is rebuilt on the next `enter()` without a save, so Continue and Delete disappear.

---

## DeadScene

**File**: `scenes/DeadScene.lua`

The Game Over scene. Triggered when the player's health reaches zero during gameplay. It is small and documented here for conciseness.

**Background**: static image `assets/images/screens/dead-screen.png`.

### Retry/Exit Menu

Created in `init()` with `Noble.Menu.new(true, Noble.Text.ALIGN_RIGHT, false, nil, 2, 16)`. Has two items:

| Item | Default selection | Action |
|---|---|---|
| **Exit** | yes (selected by default) | `Noble.transition(TitleScene)` |
| **Retry** | no | `Noble.transition(RoomTranslate(PlayerData.saveLevel))` |

The menu is drawn right-aligned at `(400, 60)`. The default selection is "Exit" — the player must deliberately move to retry.

### Japanese Text

In `update()`, over the background locked with `Graphics.lockFocus(bg)`, the following is drawn:
```
"てき に さわらせないで"
```
(Hiragana: "Te-ki ni sa-wa-ra-se-na-i-de" — roughly "Don't let the enemies touch you")

With draw mode `kDrawModeFillBlack` at position `(2, 220)` using `Graphics.font.kLanguageJapanese`.

### Navigation
D-pad Up/Down or Crank (threshold `Config.Input.crankMenuThreshold = 30`) navigate the menu. Button A executes the selected item.

---

## Notes — Differences from Love2D / Non-Playdate Environments

- `playdate.file.exists('gameState.json')` → in Love2D use `love.filesystem.getInfo()`.
- `playdate.datastore.write()` / `read()` → in Love2D use `love.filesystem.write()` / `read()`.
- `Noble.transition` with type `Spotlight` is Noble Engine-specific — in Love2D implement as a circular stencil shader.
- `playdate.metadata.version` is Playdate SDK metadata — in Love2D use `love.getVersion()` or your own constant.
- `Noble.Menu.new(...)` is a Noble Engine API for simple menus. In Love2D implement manually with lists and index-based selection.
- `achievements.viewer.launch()` is the Playdate SDK achievements API — no direct equivalent in Love2D.
- The Playdate crank has no equivalent in Love2D; simulate with the mouse wheel.
