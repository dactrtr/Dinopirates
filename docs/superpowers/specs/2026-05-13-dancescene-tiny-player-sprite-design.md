# DanceScene — Dynamic Player and Enemy Sprites

**Date:** 2026-05-13  
**Status:** Approved

---

## Summary

Two independent sprite swaps for the DanceScene battle screen:

1. **Player**: when `PlayerData.isTiny == true`, render `playerDanceTiny` instead of `playerDance`.
2. **Enemy**: when `PlayerData.lastEnemyTouched.type` identifies an alternate enemy, render a different enemy spritesheet instead of `enemyDance`.

Both use the same pattern: an optional `spritePath` parameter on the sprite constructor, resolved in `DanceScene:enter()` by reading existing `PlayerData` fields. No new state introduced.

---

## Architecture

Three files change. No new files.

### `entities/UI/battle/playerDance.lua`

`PlayerDance:init(bpm, spritePath)` gains an optional second parameter. Falls back to the current default path if omitted.

```lua
function PlayerDance:init(bpm, spritePath)
    PlayerDance.super.init(self, spritePath or 'assets/images/ui/battle/playerDance', true)
    -- rest unchanged
end
```

### `entities/UI/battle/enemyRatDance.lua`

`EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)` gains an optional fourth parameter. Falls back to the current default path if omitted.

```lua
function EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)
    EnemyRatDance.super.init(self, spritePath or 'assets/images/ui/battle/enemyDance', true)
    -- rest unchanged
end
```

### `scenes/DanceScene.lua`

In `enter()`, resolve both paths from `PlayerData` before constructing the sprites:

```lua
local charPath = PlayerData.isTiny
    and 'assets/images/ui/battle/playerDanceTiny'
    or  'assets/images/ui/battle/playerDance'
playerDance = PlayerDance(self.bpm, charPath)

local enemyPath = (PlayerData.lastEnemyTouched.type == "bosscolli")
    and 'assets/images/ui/battle/enemyBosscolliDance'
    or  'assets/images/ui/battle/enemyDance'
enemyDance = EnemyRatDance(self.bpm, self.enemyType, self.enemyEvolving, enemyPath)
```

> The enemy type string (`"bosscolli"`) is an example — replace with the actual value used in `PlayerData.lastEnemyTouched.type`.

---

## Sprite Assets Required

### Player — `playerDanceTiny-table-246-214.png`

Same frame layout as `playerDance-table-246-214.png`:

| State  | Frames |
|--------|--------|
| idle   | 1–5    |
| jump   | 5–9    |
| crouch | 11–15  |
| left   | 16–20  |
| right  | 21–24  |

Dimensions (246×214), anchor `setCenter(0,0)`, position `(0, 26)` — all inherited unchanged.

### Enemy — `enemyBosscolliDance-table-211-214.png` *(name TBD)*

Same frame layout as `enemyDance-table-211-214.png`:

| State      | Frames |
|------------|--------|
| idle       | 1–5    |
| upAttack   | 6–9    |
| leftAttack | 10–13  |
| rightAttack| 14–17  |
| downAttack | 18–21  |
| bButton    | 22–25  |
| aButton    | 26–29  |
| evolving   | 30–33  |

Dimensions (214×214), anchor `setCenter(0,0)`, position `(158, 26)` — all inherited unchanged.

---

## What Does NOT Change

- `HitZone`, `ButtonPress`, `BackgroundDance`, `ResultsScreen`, `ButtonCover` — untouched
- Win/lose logic, balance bar, difficulty system — untouched
- Animation state names and frame ranges inside both sprite classes — unchanged
- `PlayerData.isTiny` and `PlayerData.lastEnemyTouched` are read-only from DanceScene's perspective

---

## Out of Scope

- Different canvas sizes for alternate sprites (requires parametrizing `setSize` / `add`)
- More than two variants per role (requires a key string instead of a binary path selection)
- Saving/restoring sprite choice across scenes
