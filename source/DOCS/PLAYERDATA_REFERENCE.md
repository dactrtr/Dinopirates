# PlayerData — Complete Field Reference

`PlayerData` is the **global mutable game state**. It is a Lua table accessible from any file without `require` or `import`. It is the backbone of all game logic.

---

## Lifecycle

```lua
-- PlayerDataTables.lua
local DefaultPlayerData = { ... }        -- immutable template
PlayerData = deepcopy(DefaultPlayerData) -- live mutable copy (when the module loads)

-- SaveSystem.load()
PlayerData = saveData.player             -- replaces entirely from disk when continuing

-- ResetPlayerData()
PlayerData = deepcopy(DefaultPlayerData) -- resets to default values (without reading disk)
```

`SaveSystem.createOriginalBackup()` (called in `main.lua`) deep-copies `levelsLDTK`, NOT `PlayerData`. Default values for `PlayerData` come exclusively from `DefaultPlayerData`.

---

## Complete reference table

### Survival resources

| Field | Lua type | Default | Valid range | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `healthPoints` | number | `3` | 0 – `Config.Player.maxHealthPoints` (10, hard cap) | `collisions.lua` (Brocorat damage), `DanceScene` (healing on victory, clamped), `MazeScene.cranked` (microwave cooking, clamped) | `collisions.lua` (combat threshold), `HealthIndicator` (HUD, up to 10 dots), `Player:update()` (upper clamp) | Yes |
| `danceThresholdHP` | number | `1` | 0 – N | — (constant, never modified at runtime) | `collisions.lua` — when `healthPoints < danceThresholdHP` triggers `fight()` | Yes |
| `healedHP` | number | `2` | 0 – N | — (constant) | `DanceScene` win — amount of HP to restore | Yes |
| `battery` | number | `100` | 0 – 100 (forced clamp in `update()`) | `movement.lua` (drain in darkness), `hole.lua` (drain in holes), `lightburst.lua` (cost), `sanity.lua` (charging), `items.lua` (`fillBattery`) | `sanity.lua` (sanity tick), `movement.lua` (reduced speed), `enemy.lua` (AI speed), `crewmember.lua` (AI movement), `lightburst.lua` (validation) | Yes |
| `sanity` | number | `100` | 0 – 100 (clamp in `sanity.lua`) | `sanity.lua` (periodic tick every 2 s), `state.lua:focus()` (spending) | `sanityHud` (HUD), `sanity.lua` (detects 0 hit) | Yes |
| `sanityCounter` | number | `0` | 0 – N (no hard limit; `Config.Dance.sanityMax = 100` for normalization) | `sanity.lua` (increments when `sanity` reaches 0) | `DanceScene:determineDifficultyUpgrade()` (weight 0.35), `Utilities.checkSanityAchievements()` | Yes |
| `calories` | number | `100` | 0 – 500 (`Config.Dance.caloriesMax = 500`, clamped on every gain) | `state.lua:burnCalories()` (−10 every 200 steps), `MazeScene.cranked` (microwave: +`Config.Microwave.caloriesPerFood` per food cooked), `DanceScene` (+60 on win) | `DanceScene:determineDifficultyUpgrade()` (weight 0.20) | Yes |
| `food` | number | `0` | 0 – `Config.Microwave.carryMax` (10) | `items.lua:grabFood()` (+`perPickup` on pickup, clamped), `MazeScene.cranked` (−1 per food cooked) | `MazeScene.cranked` (cook loop), `state.lua:startCooking()` (entry guard) | Yes |
| `steps` | number | `0` | 0 – `Config.Pedometer.stepsToTrigger` (200, then resets) | `state.lua:pedometer()` (+0.5 per each `move()`) | `state.lua:pedometer()` (burn threshold) | Yes |
| `totalSteps` | number | `1000` | 0 – ∞ (lifetime, never resets) | `state.lua:pedometer()` (+0.5 per each `move()`) | — (not used in active logic, potential for achievements) | Yes |
| `mapPercent` | number | `0` | 0 – 100 | — (no documented active writer) | `Trigger:conditionalScript()` (script conditions) | Yes |

---

### Boolean state flags

These flags form the central state machine. **Check before any game logic.** In practice they are mutually exclusive: only one "mode" is active at a time.

| Field | Lua type | Default | Meaning | Set to `true` by | Set to `false` by | Persisted |
|---|---|---|---|---|---|---|
| `isGaming` | boolean | `false` | Normal gameplay active; enables `Player:move()` and enemy AI | `MazeScene:start()`, `player:wake()`, `player:finishMinifying()`, `DanceScene` on return | `MazeScene:finish()`, dialog opening, menu opening, cutscene start, `player:startMinifying()` | No |
| `isTalking` | boolean | `false` | Dialog overlay open | `dialogScreen:addScreen()` | `dialogScreen:removeAll()` | No |
| `isCutscene` | boolean | `false` | Panel cutscene active | `collisions.lua` trigger type "Cutscene", `MazeScene:enter()` (room cutscene) | Panels completion callback | No |
| `isEquiping` | boolean | `false` | Equipment menu open | `inGameMenu:displayMenu()` | B button in MazeScene handler | No |
| `isDancing` | boolean | `false` | DanceScene battle active | `DanceScene:startBattle()` | DanceScene (win/lose) | No |
| `isActive` | boolean | `false` | Player performed an action (turn signal for NPCs) | `player:move()` (at start), `player:chargeBattery()` | `player:update()` (at end of each frame) | No |
| `isCharging` | boolean | `false` | Crank battery charging in progress | `chargeBattery()` (start of tick) | After completing the charge tick | No |
| `readyToShrink` | boolean | `false` | Player overlaps minifier prop | `collisions.lua` PropItem "minifier" branch | `player:finishMinifying()`, `player:checkMinifier()` (on overlap exit) | No |
| `readyToCook` | boolean | `false` | Player overlaps microwave prop | `collisions.lua` PropItem "microwave" branch | `player:checkMicrowave()` (on overlap exit) | Yes (transient; reset by `checkMicrowave()`) |
| `isTiny` | boolean | `false` | Player in tiny state | `player:shrink()` | `player:grow()` | Yes |
| `isBig` | boolean | `false` | Player in big state | `player:transformCycle()` | `player:transformCycle()` (toggle) | Yes |
| `isInDarkness` | boolean | `false` | Current room has darkness/shadow | `MazeScene:enter()` reading `customFields.shadow` | Next `MazeScene:enter()` (always overwritten) | No |
| `isFocused` | boolean | `false` | Focus mode (legacy, no active use) | `player:focus()` | `player:deFocus()` | No |
| `showLightCone` | boolean | `false` | LightBurst light cone visible | `lightburst.lua:lightBurst()` | `player:update()` (timer `lightConeHideTime`) | No |
| `sonarActive` | boolean | `false` | Enemy sonar pulse activated | `enemy:sonar()` | — (no documented cleaner) | No |
| `canDance` | boolean | `false` | Player can enter DanceScene | — (no active writer) | — | No |
| `fromTitle` | boolean | `false` | Player came from TitleScene (game start) | `TitleScene` when starting new game | — (used only in `initAnimations` to set `sleep` state) | No |

---

### Position and navigation

| Field | Lua type | Default | Range / Possible values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `x` | number | `200` | 0 – 400 (screen width) | `player:update()` — `PlayerData.x = self.x` every frame | `lightburst.lua` (cone center), `enemy.lua` (chase AI) | Yes |
| `y` | number | `200` | 0 – 240 (screen height) | `player:update()` — `PlayerData.y = self.y` every frame | `lightburst.lua` (cone center), `enemy.lua` (chase AI) | Yes |
| `speed` | number | `Config.Player.speed = 2` | > 0 | `PlayerDataTables.lua` (default), `player:update()` (darkness/battery multipliers) | `player:move()` (destination calculation) | Yes |
| `direction` | string | `"idle"` | `"left"`, `"right"`, `"up"`, `"down"`, `"idle"` | `player:move()` (on movement), `player:idle()` (on stop), `player:endSliding()` | `lightburst.lua` (cone orientation), `plunge.lua` (projectile direction), `animations.lua` | Yes |
| `floor` | number | `1` | 1 – N (index in `levelsLDTK` array) | `MazeScene:setFloor()`, `MazeScene:enter()` | `state.lua:fallBelow()` and `riseAbove()` (navigate to neighbor room index) | Yes |
| `room` | number | `1` | room number (`customFields.roomNumber`) | `MazeScene:setFloor()` | — | Yes |
| `actualLevel` | number | `nil` | LDtk level number (e.g. 4) | `MazeScene:enter()` from `levelsLDTK[floor].customFields.levelNumber` | `MazeScene:enter()` (PNG background load), `state.lua:fallBelow/riseAbove()` | Yes |
| `actualRoom` | number | `nil` | LDtk room number (e.g. 8) | `MazeScene:enter()` | `MazeScene:enter()` (PNG background load) | Yes |
| `actualTilemap` | number | `nil` | Index in `tileMapData` | `MazeScene:enter()` from `customFields.tilemapIndex` | `CreateTileColliders()`, `player:checkForegroundDepth()` | Yes |
| `saveLevel` | number | `nil` | Full room ID (e.g. 408) | `FloorXXX:init()` — `PlayerData.saveLevel = i` | `SaveSystem.load()` (second return value to know the saved room) | Yes |
| `lastRoom` | number | `nil` | Previous index in `levelsLDTK` | `MazeScene:exit()` | `Door:prevRoom()` (for backward navigation) | Yes |
| `playerSpawn` | table `{x, y}` | `{x=200, y=200}` | screen coordinates | `state.lua:fallBelow()` / `riseAbove()` (spawn in destination room) | `MazeScene:enter()` (position player on entry) | Yes |
| `playerExit` | table `{x, y}` | `{x=nil, y=nil}` | screen coordinates | `MazeScene:exit()` | — | Yes |
| `storyCounter` | number | `0` | 0 – N | `collisions.lua` trigger type "Counter" (+1) | Trigger conditional logic | Yes |

---

### Items and skills

The `PlayerData.items` and `PlayerData.skills` fields are subtables with boolean fields.

#### PlayerData.items

| Field | Type | Default | Who sets it to `true` | Who reads it | Effect when owned | Persisted |
|---|---|---|---|---|---|---|
| `hasLamp` | boolean | `false` | `player:grabLamp()` in `items.lua` | `movement.lua` (lamp animations), `sanity.lua` (speed with low battery), `abilities.lua`, `lightburst.lua`, `player:idle()` | Enables `lampXxx` animations; grants `canFlash`; in darkness, prevents the extreme speed penalty | Yes |
| `hasRadio` | boolean | `true` | Default in `PlayerDataTables.lua` | `dialogScreen` / `Trigger` (radio feed sources) | Story item; enables radio feed dialogs | Yes |
| `hasDWatch` | boolean | `false` | `grabItemGift()` / LDtk grants | `inGameMenu` (open condition) | Required to open the in-game equipment menu | Yes |
| `hasNotes` | boolean | `true` | Default in `PlayerDataTables.lua` | `dialogScreen` (notes sources) | Story item; enables note reading | Yes |
| `hasBoots` | boolean | `false` | `player:grabBoots()` in `items.lua` | `hole.lua` (hole safety), `inGameMenu` (skill slot 2) | Allows crossing holes by draining battery instead of falling | Yes |
| `hasPlunger` | boolean | `false` | `player:grabPlunger()` in `items.lua` | `sliding.lua` (slime immunity), `plunge.lua` (validation) | Immunity to slime tiles; grants `canPlungerang` | Yes |
| `hasBag` | boolean | — (not in Default) | `player:grabBag()` in `items.lua` | `crewmember.lua` (capture) | Required to capture CrewMembers | Yes |
| `hasTools` | boolean | — (not in Default) | `player:grabTools()` in `items.lua` | Story triggers | Story item | Yes |

#### PlayerData.skills

| Field | Type | Default | Who sets it to `true` | Who reads it | Item that grants it | Persisted |
|---|---|---|---|---|---|---|
| `canFlash` | boolean | `false` | `player:grabLamp()` | `lightburst.lua` (validation) | Lamp (`hasLamp`) | Yes |
| `canPlungerang` | boolean | `false` | `player:grabPlunger()` | `plunge.lua` (validation) | Plunger (`hasPlunger`) | Yes |

**Note on dynamic grants**: `grabItemGift(grants)` and `grabNotes(grants)` parse the `grants` string from LDtk in the format `"key:value,key2:value2"` and write them directly into `PlayerData.items` or `PlayerData.skills` respectively. This allows granting any field of these subtables from the level editor.

---

### Active ability selection

There is no active-item selection. Abilities fire directly from the B button based on
context: `useAbility()` routes to the lamp (`lightBurst`) while `isInDarkness`, otherwise
to the plungerang (`plunge`). Each ability self-gates on its own item/skill flags.

---

### Keys (door locks)

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `keys` | table (sparse map) | `{}` | `{[1]=true, [3]=true, ...}` — numeric key index | `player:grabKey(keyNumber)` in `items.lua` | `collisions.lua` Door branch — `PlayerData.keys[requiredKey] == true` | Yes |

---

### Enemy encounter state

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `lastEnemyTouched.type` | string \| nil | `nil` | `"Brocorat"` or other future types | `collisions.lua` when touching a Brocorat | `DanceScene` (identifies combat type) | No |
| `lastEnemyTouched.id` | any \| nil | `nil` | LDtk entity `iid` | `collisions.lua` | `DanceScene` | No |
| `lastEnemyTouched.x` | number \| nil | `nil` | enemy X position at contact | `collisions.lua` | `DanceScene` | No |
| `lastEnemyTouched.y` | number \| nil | `nil` | enemy Y position at contact | `collisions.lua` | `DanceScene` | No |
| `amountDances` | number | `0` | 0 – ∞ (lifetime) | `player:fight()` (increments +1 per battle) | — (potential for achievements/stats) | Yes |

---

### EnemiesData — enemy scaling data

| Field | Lua type | Default | Valid range | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `EnemiesData.powerLevel` | number | `1` | 1 – 20 (`Config.Dance.powerMax`) | `DanceScene:determineDifficultyUpgrade()` (increments) | `DanceScene` (rhythm difficulty), `Config.Enemy.sightRadiusPerPowerLevel` (sight radius), `sanity.lua` indirectly | Yes |
| `EnemiesData.sightRadius` | number | `Config.Enemy.sightRadiusBase = 150` | 50 – N (`sightRadiusMin = 50`) | `enemy.lua` (updates with `sightRadiusBase + powerLevel * 3`) | `enemy.lua:search()`, `enemy.lua:linealSearch()` (detection radius) | Yes |
| `EnemiesData.isEvolved` | boolean | `false` | `true` \| `false` | — (legacy field, no active writer) | — (no documented active reader) | Yes |

---

### CrewMemberData — crew tracking

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `CrewMemberData.amountTaken` | number | `0` | 0 – N | `crewmember.lua:taken()` (+1 on capture) | `collisions.lua` (first encounter logic with CM001) | Yes |
| `CrewMemberData.idNumbers` | table (sparse map) | `{}` | `{["CM001"]=true, ...}` | `crewmember.lua:taken()` | — (potential for story checks) | Yes |

---

### Transformation and minifier

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `isTiny` | boolean | `false` | `true` \| `false` | `player:shrink()`, `player:grow()` | `movement.lua` (tiny animations), `plunge.lua` (block), `hole.lua` (drain rate), `sliding.lua` (animation), `collisions.lua` (tube/crewmember) | Yes |
| `isBig` | boolean | `false` | `true` \| `false` | `player:transformCycle()` | — (no documented active reader in main logic) | Yes |
| `playerSize` | number | `10` | 0 – 10 (semantic crank range) | `PlayerDataTables.lua` (default) | `player:startMinifying()` (target size) | Yes |
| `actualPlayerSize` | number | `10` | 0 – `playerSize` | `player:startMinifying()` (reset), `MazeScene:cranked()` (modified by crank) | `MazeScene:cranked()` (determines shrink or grow) | Yes |
| `readyToShrink` | boolean | `false` | `true` \| `false` | `collisions.lua` PropItem "minifier" | `collisions.lua`, `player:startMinifying()` (guard) | No |

---

### Light and visual effects

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `showLightCone` | boolean | `false` | `true` \| `false` | `lightburst.lua:lightBurst()` (true), `player:update()` via `lightConeHideTime` (false) | `FXshadow` (draws the overlaid light cone) | No |
| `isInDarkness` | boolean | `false` | `true` \| `false` | `MazeScene:enter()` reading `customFields.shadow` | `movement.lua`, `sanity.lua`, `player:update()` (speed), `player:idle()` (animation) | No |

---

### Room spawn and exit

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `playerSpawn.x` | number | `200` | 0 – 400 | `state.lua:fallBelow()`, `state.lua:riseAbove()`, `Door:setSpawn()`, `PortalDoor:setSpawn()` | `MazeScene:enter()` (initial player positioning) | Yes |
| `playerSpawn.y` | number | `200` | 0 – 240 | Same as above | `MazeScene:enter()` | Yes |
| `playerExit.x` | number \| nil | `nil` | 0 – 400 | `MazeScene:exit()` | — | Yes |
| `playerExit.y` | number \| nil | `nil` | 0 – 240 | `MazeScene:exit()` | — | Yes |

---

### Story and UI flags

| Field | Lua type | Default | Range / Values | Who writes | Who reads | Persisted |
|---|---|---|---|---|---|---|
| `fromTitle` | boolean | `false` | `true` \| `false` | `TitleScene` when starting new game | `player:initAnimations()` (initial sleep state) | No |
| `isTalking` | boolean | `false` | `true` \| `false` | `dialogScreen:addScreen()` | `player:startMinifying()` (guard), `collisions.lua` (blocked PortalDoor) | No |
| `isDancing` | boolean | `false` | `true` \| `false` | `DanceScene:startBattle()` | — (flow control flag) | No |

---

## The state machine in prose

The game is effectively a state machine driven by the boolean flags. Here is how they interact:

```
Normal gameplay:
  isGaming=true, isTalking=false, isCutscene=false, isEquiping=false

Player enters dialog trigger (Story auto, or Search/Call + A):
  isGaming=false, isTalking=true
  → player:move() blocked
  → Enemy AI continues (isActive keeps propagating)
  → A button → dialogScreen:nextDialog()
  → last line → dialogScreen:removeAll() → isGaming=true, isTalking=false

Player opens the menu (A held 1 s, requires hasDWatch):
  isGaming=false, isEquiping=true
  → menu is purely visual (map + crew hats); no item selection
  → B button closes menu → isGaming=true, isEquiping=false

Player hits Cutscene trigger:
  isGaming=false, isCutscene=true
  → Noble.Input disabled
  → Panels.update() drives the cutscene each frame
  → Panels callback → isGaming=true, isCutscene=false

Player overlaps minifier prop:
  readyToShrink=true
  → HUD shows "Press A" prompt
  → A pressed → player:startMinifying() → isGaming=false
  → Crank → player:transformCycle()
  → Transformation complete → player:finishMinifying() → isGaming=true, readyToShrink=false

Player touches enemy (combat):
  isGaming=false, isDancing=true
  → Noble.transition(DanceScene)
  → DanceScene win/lose → Noble.transition back → isGaming=true, isDancing=false
```

---

## Which fields are persisted in the save

The `SaveSystem` serializes the full `PlayerData` plus the modified entity states in `levelsLDTK`. Fields in `PlayerData` marked "No" in the "Persisted" column are ephemeral state flags that are recalculated when the scene loads. The most important ones that are NOT persisted:

- `isGaming`, `isTalking`, `isCutscene`, `isEquiping`, `isDancing` — UI/flow state
- `isActive`, `isCharging` — per-frame signals
- `isInDarkness`, `showLightCone` — properties derived from the loaded room
- `readyToShrink`, `fromTitle` — one-time interaction flags
- `lastEnemyTouched` — one-time encounter data

Position fields (`x`, `y`, `playerSpawn`, `direction`), resources (`battery`, `sanity`, `healthPoints`, `calories`), inventory (`items`, `skills`, `keys`), and navigation (`floor`, `room`, `actualLevel`, `saveLevel`) ARE persisted.
