# Achievements System

The game uses the **PlaydateSquad shared achievements library**
(<https://github.com/PlaydateSquad/pd-achievements>, Unlicense / public domain), wrapped
by a few thin game-specific helpers in `utilities/Utilities.lua`.

It is responsible for: persistent achievement state, on-grant toast popups, an in-game
viewer, and cross-game shared data. Achievements persist **independently of the game
save** (the library writes its own files) — but the game clears them on **Delete Game**
so a fresh save starts clean.

See [TITLE_SCENE.md](TITLE_SCENE.md) for the Achievements menu item and the Delete flow,
[CUTSCENE_SYSTEM.md](CUTSCENE_SYSTEM.md) for story-comic grants, and
[PLAYER_SYSTEMS.md](PLAYER_SYSTEMS.md) for the sanity counter that drives sanity grants.

---

## 1. Files

| File | Role |
|---|---|
| `achievements/all.lua` | Loader — imports the library modules in order |
| `achievements/achievements.lua` | Base library: `grant` / `revoke` / `isGranted` / `advance` / `save` / `initialize`, persistence, paths |
| `achievements/toasts.lua` | Toast popups shown when an achievement is granted |
| `achievements/viewer.lua` | Full-screen achievements viewer UI (`achievements.viewer.launch()`) |
| `achievements/crossgame.lua` | Read other games' shared achievement data (`achievements.crossgame.*`) |
| `assets/data/achievements.lua` | **Game's achievement definitions** (`achievementData`) |
| `assets/data/toastConfig.lua` | Toast appearance/behavior config (`configToast`) |
| `utilities/Utilities.lua` | Game wrappers: `grantAchievementIfNeeded`, `checkStoryAchievement`, `checkSanityAchievements`, `clearAllAchievements` |

`crossgame.lua` asserts that the base library is loaded first (`flag_is_playdatesquad_api`).

---

## 2. Initialization (`main.lua`)

```lua
import 'achievements/all'                         -- load library modules

achievementData = import 'assets/data/achievements'  -- global definition table
achievements.initialize(achievementData)          -- register definitions, load saved state
achievements.forceSaveOnGrantOrRevoke = true      -- persist immediately on every grant/revoke
achievements.toasts.initialize(configToast)       -- enable on-grant toast popups
```

`forceSaveOnGrantOrRevoke = true` means a grant is written to disk the instant it
happens — you don't have to call `achievements.save()` manually after gameplay grants.

---

## 3. Defining achievements (`assets/data/achievements.lua`)

Returns the global `achievementData` table:

```lua
local achievementData = {
    iconPath = "assets/launcher/icon",
    cardPath = "assets/images/achievements/card",
    achievements = {
        {
            id                = "wakeup",                       -- unique key used by grant/isGranted
            name              = "What a nap captn",
            descriptionLocked = "Just a little nap and I continue working",
            description       = "Wakey wakey eggs and Brocolli",
            icon              = "assets/images/achievements/achievements-1",
            scoreValue        = 2,                              -- weight toward completion %
        },
        {
            id          = "comms",
            name        = "Moshi moshi",
            description = "Achievement 1 Description",
            isSecret    = true,                                 -- hidden until granted
            icon        = "assets/images/achievements/achievements-3",
        },
        -- ...
    }
}
return achievementData
```

| Field | Meaning |
|---|---|
| `id` | Unique string key — passed to all library calls |
| `name` | Display title |
| `description` | Shown when granted (or always, if not secret) |
| `descriptionLocked` | Optional alternate description shown before granting |
| `icon` | Image path for the achievement |
| `scoreValue` | Weight toward completion percentage (defaults to `1` if omitted) |
| `isSecret` | Hidden in the viewer until granted |
| `progressMax` / `progress` | Optional — for progressive achievements advanced via `achievements.advance()` |

### Currently defined
`wakeup`, `comms` (secret), `sanityloss1` (secret), `sanityloss2` (secret),
`microwaveBurn` (secret).

---

## 4. Library API (commonly used)

```lua
achievements.grant(id)           -- unlock (no-op effects handled internally; fires a toast)
achievements.revoke(id)          -- re-lock
achievements.isGranted(id)       -- bool
achievements.advanceTo(id, n)    -- set progressive progress to n
achievements.advance(id, delta)  -- add delta to progressive progress
achievements.completionPercentage()  -- 0..1 weighted by scoreValue
achievements.getInfo(id)         -- the definition table for id
achievements.save()              -- force a write (usually unnecessary with forceSaveOnGrantOrRevoke)
```

---

## 5. Game wrappers (`utilities/Utilities.lua`)

The game never calls `achievements.grant` directly from gameplay code; it goes through
these helpers so unknown ids fail safe and double-grants are avoided.

```lua
-- Grant only if the id exists in achievementData AND isn't already granted.
Utilities.grantAchievementIfNeeded(id)

-- Map a finished story comic → its achievement.
Utilities.checkStoryAchievement(comic)   -- intro → "wakeup", "pick-the-device" → "comms"

-- Grant based on the lifetime sanity counter.
Utilities.checkSanityAchievements()      -- sanityCounter 2 → "sanityloss1", 5 → "sanityloss2"

-- Revoke every defined achievement (used by Delete Game).
Utilities.clearAllAchievements()
```

### Where they're called
| Wrapper | Trigger |
|---|---|
| `checkStoryAchievement(comic)` | Cutscene completion callback (`MazeScene` room-enter comic) — see [CUTSCENE_SYSTEM.md](CUTSCENE_SYSTEM.md) |
| `checkSanityAchievements()` | `sanity.lua` each time `sanityCounter` increments (sanity hits 0) |
| `grantAchievementIfNeeded(script)` | `player/collisions.lua` when entering a `Cutscene`/achievement trigger |
| `clearAllAchievements()` | `TitleScene` **Delete Game** action (alongside `SaveSystem.delete()`) |

> **Sanity grants are exact-match on the counter** (`sanityAchievements[sanityCounter]`),
> so they only fire on the tick that lands on `2` or `5`. If the counter could ever jump
> past a threshold, that achievement would be skipped — today it always increments by 1.

---

## 6. Toasts

`achievements.toasts.initialize(configToast)` (config in `assets/data/toastConfig.lua`)
makes a popup slide in whenever `achievements.grant()` unlocks something new. No gameplay
code needs to draw it — the library hooks the draw loop itself.

---

## 7. Viewer

`achievements.viewer.launch()` opens a full-screen list of achievements (granted, locked,
and — hidden — secret ones). It **temporarily takes over `playdate.update`** and blocks
the game until the player exits, then returns control. The game opens it from the
**Achievements** item on the title menu (`TitleScene.lua`). Call
`achievements.viewer.initialize()` ahead of time to avoid a first-launch asset-load hitch.

---

## 8. Cross-game data (`crossgame`)

`achievements.crossgame` reads achievement data **shared by other Playdate games** that
use the same library (a shared system folder):

```lua
achievements.crossgame.gamePlayed(game_id)   -- has this game written shared data?
achievements.crossgame.listGames()           -- list game_ids with shared data
achievements.crossgame.getData(game_id)      -- decoded data + completionPercentage
achievements.crossgame.loadImage(game_id, p) -- load a shared image
```

Not required for normal play; it enables cross-game features (e.g. recognizing the
player owns/played another title).

---

## 9. Persistence & lifecycle notes

- Achievement state lives in the **library's own files**, separate from `gameState.json`
  (the `3.0-PROCGEN` game save). Granting/revoking does not touch the game save.
- Because they persist independently, **Delete Game** explicitly calls
  `Utilities.clearAllAchievements()` so a brand-new game also resets achievements.
- `forceSaveOnGrantOrRevoke = true` → grants survive a crash/power-off without an explicit
  save call.

---

## 10. Love2D port notes

The PlaydateSquad library is Playdate-specific (uses `playdate.datastore`, the system
shared-data folder, and the launcher). For a Love2D port:

- Replace the library with a small module backing a JSON file: a `{ [id] = grantedAt }`
  table plus the `achievementData` definitions.
- Keep the **wrapper API identical** (`grantAchievementIfNeeded`, `checkStoryAchievement`,
  `checkSanityAchievements`, `clearAllAchievements`) so gameplay call sites don't change.
- Toasts → a simple timed banner widget; the viewer → a Love2D UI screen.
- `crossgame` has no portable equivalent (it depends on the Playdate shared folder); stub
  it out unless you build an equivalent shared store.
