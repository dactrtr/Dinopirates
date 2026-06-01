# Data Flow — Who Talks to Who

This document shows which files read and write the major shared data structures,
and how systems are connected. Use this as a map when you need to trace a bug
or add a feature.

---

## Global data structures and their owners

```
┌─────────────────────────────────────────────────────────────────┐
│  Config.lua          → READ ONLY after boot                      │
│  (source of truth for all constants)                             │
│                                                                  │
│  Aliased in main.lua:                                            │
│    ZIndex        = Config.ZIndex                                 │
│    CollideGroups = Config.CollideGroups                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  PlayerData              → MUTABLE global game state             │
│                                                                  │
│  WRITTEN by:                                                     │
│    PlayerDataTables.lua  → defines DefaultPlayerData, init       │
│    SaveSystem.lua        → overwrites on load                    │
│    player/movement.lua   → x, y, direction, isActive, battery   │
│    player/sanity.lua     → sanity, sanityCounter                 │
│    player/items.lua      → items.*, skills.*, keys[n], food     │
│    player/state.lua      → isTiny, isBig, playerSize, floor     │
│    player/collisions.lua → lastEnemyTouched, readyToShrink,     │
│                            readyToCook                           │
│    MazeScene.cranked     → food, healthPoints, calories (cook)  │
│    player/lightburst.lua → battery (cost)                        │
│    MazeScene.lua         → isGaming, isCutscene, floor, room,   │
│                            actualLevel, actualRoom, actualTilemap│
│                            isInDarkness, visited (via levelsLDTK)│
│    DanceScene.lua        → isDancing, amountDances, calories     │
│    inGameMenu.lua        → isEquiping                            │
│    dialogScreen.lua      → isTalking, isGaming                  │
│    Panels callback       → isCutscene, isGaming                  │
│                                                                  │
│  READ by:                                                        │
│    Every entity in the game (enemies, HUD, triggers, etc.)       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  levelsLDTK              → MUTABLE world state                   │
│                                                                  │
│  WRITTEN by:                                                     │
│    levels.lua            → initial definition                    │
│    SaveSystem.load()     → restores persisted entity states      │
│    MazeScene:enter()     → sets customFields.visited = true      │
│    Panels callback       → sets comic_wasPlayed = true           │
│    player/collisions.lua → indirectly via trigger:returnScript() │
│                            (sets usedTrigger=true in cf)         │
│    DanceScene win        → enemy.customFields.dead = true via    │
│                            findAndKillEnemyById                  │
│    prop destruction      → propItem:destroyProp() via iid        │
│                                                                  │
│  READ by:                                                        │
│    MazeScene:enter()     → spawns all entities                   │
│    SaveSystem.getLevelState() → serializes for disk              │
│    trigger.lua           → returnScript() reads conditionals     │
│    door.lua              → FindRoomByIid() lookup                │
│    Utilities.lua         → GetLowerRoom, GetUpperRoom            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  tileMapData             → READ ONLY after boot                  │
│                                                                  │
│  WRITTEN by:                                                     │
│    tilemap.lua           → initial definition                    │
│                                                                  │
│  READ by:                                                        │
│    MazeScene:enter()     → CreateTileColliders(tileMapData[n])   │
│    Utilities.lua         → GetTileUnderPlayer()                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  script (dialog scripts) → READ ONLY after boot                  │
│                                                                  │
│  WRITTEN by:                                                     │
│    assets/data/script.lua → initial definition                   │
│                                                                  │
│  READ by:                                                        │
│    dialogScreen:addScreen(name) → searches for matching entry    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  comics (Panels sequences) → READ ONLY after boot                │
│                                                                  │
│  WRITTEN by:                                                     │
│    assets/comics/comicsData.lua → initial definition             │
│                                                                  │
│  READ by:                                                        │
│    MazeScene:enter()     → comics[cf.comic_name]                 │
│    (trigger cutscene should also read it — see CUTSCENE_SYSTEM)  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  roomsByIid              → READ ONLY after boot                  │
│                                                                  │
│  WRITTEN by:                                                     │
│    main.lua              → built from levelsLDTK on startup      │
│                                                                  │
│  READ by:                                                        │
│    door.lua              → FindRoomByIid(iid) O(1) lookup        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Entity collision dispatch map

`player:collisionResponse(other)` in `entities/player/collisions.lua` is the central
dispatcher for all entity interactions. Here is what happens for each entity type:

```
other type                  → action
─────────────────────────────────────────────────────────────────
Brocorat / bosscolli        → damage player OR fight() → DanceScene
                              (depending on healthPoints threshold)
CrewMember (normal size)    → taken() [capture — requires hasBag]
CrewMember (tiny size)      → currentTrigger = other [interact with A]
Box (wall collider)         → return 'freeze'
Trigger "Cutscene"          → isGaming=false, isCutscene=true, remove
                              (does NOT start Panels — see CUTSCENE_SYSTEM.md)
Trigger "Story"             → isGaming=false, dialogUI:addScreen(script, sourceFeed)
Trigger "Search"            → currentTrigger = other [manual, press A]
Trigger "Call"              → currentTrigger = other [manual, press A]
Trigger nil (untyped)       → currentTrigger = other [manual, press A]
Trigger "Counter"           → storyCounter += 1, remove
Items "keycard"             → grabKey(keyNumber)
Items "lamp"                → grabLamp()
Items "radio"               → grabRadio()
Items "notes"               → grabNotes(grants)
Items "itemgift"            → grabItemGift(grants)
Items "bag" / "honk"        → grabBag()
Items "tools"               → grabTools()
Items "boots"               → grabBoots()
Items "plunger"             → grabPlunger()
Items "food"                → collect by iid, grabFood() [food += perPickup]
PropItem "minifier"         → readyToShrink=true, show "Press A" HUD
PropItem "microwave"        → readyToCook=true, show "Press A" HUD [cook to heal]
PropItem (isTube==true)     → riseAbove() [only if PlayerData.isTiny]
PropItem (other)            → return 'freeze'
Door (open / has key)       → prevRoom() + goTo() [scene transition]
Door (locked, no key)       → dialogUI:addScreen("nokeys"), return 'freeze'
```

---

## Save / load data flow

```
[Game boots]
  └─ main.lua
       ├─ All imports run in order (see ARCHITECTURE.md)
       └─ SaveSystem.createOriginalBackup()
            └─ levelsLDTKOriginal = deepcopy(levelsLDTK)

[User selects "Continue"]
  └─ SaveSystem.load()
       ├─ playdate.datastore.read('gameState')   → raw save table
       ├─ PlayerData = saveData.player           → replaces live PlayerData
       ├─ SaveSystem.restoreLevelState(...)       → patches levelsLDTK in-place
       │    └─ for each entry: find entity by iid → apply saved fields
       └─ return true, saveData.player.saveLevel  → caller uses this to navigate to saved room

[MazeScene:finish() and MazeScene:pause()]
  └─ SaveSystem.save()
       ├─ PlayerData.saveLevel = currentRoomID   → records current room
       ├─ getLevelState()                         → reads levelsLDTK
       │    └─ for each room: serialize changed entity fields (dead, destroyed, isTaken, etc.)
       └─ playdate.datastore.write('gameState', data) → writes to disk

[User selects "New Game" or game over reset]
  └─ SaveSystem.reset()
       ├─ ResetPlayerData()                       → PlayerData = deepcopy(DefaultPlayerData)
       └─ levelsLDTK = deepcopy(levelsLDTKOriginal) → world state back to original
```

---

## The `grants` system (items → PlayerData)

`itemgift` and `notes` items carry a `grants` string from LDtk custom fields.
This is the mechanism by which picking up items unlocks skills.

```
LDtk item entity custom field:
  grants = "canFlash:true,hasLamp:true"

Format:  "key1:value1,key2:value2"
Values:  "true" → boolean true; any other string → passed as-is

Parsed in: player/items.lua → grabItemGift(grants) / grabNotes(grants)
             → splits on ","
             → splits each pair on ":"
             → sets PlayerData.items[key] or PlayerData.skills[key]

Spawn guard (MazeScene:enter()):
  For each grant pair in the item's grants field:
    if PlayerData.items[key] == true → item is already owned
  If ANY grant is already true → skip spawning this item entirely
  This prevents duplicate item pickups after loading a save
```

---

## Turn-based sync system

The game uses a "time moves when you move" mechanic. The flow is:

```
Player presses direction key
  └─ player:move() [player/movement.lua]
       ├─ Moves player 1 frame
       ├─ PlayerData.isActive = true     ← signal to NPCs
       └─ distributeMovementFrames(3)    ← grants 3 movement frames to each NPC

Each NPC (Brocorat, CrewMember) in their update():
  ├─ Check if PlayerData.isActive == true
  ├─ Process one step of AI movement
  └─ Consume their movement frame budget

Player fires a B ability (flash / plungerang / grapple launch / dark reveal):
  └─ distributeMovementTokens(Config.Player.movementTokensPerAction = 5)  ← tokens, not frames
       (Tokens are converted to frames by framesPerToken in Config.CrewMember)
       Only happens when the ability actually fires — not on every B press,
       and not while holding B to charge.
```

---

## Scene dependency graph

```
main.lua
  ├─ Noble (framework)
  ├─ Panels (cutscene library)
  ├─ Config.lua              → ZIndex, CollideGroups
  ├─ Utilities.lua           → Box, GetTileUnderPlayer, GetLowerRoom, GetUpperRoom
  ├─ SaveSystem.lua          → save(), load(), reset(), createOriginalBackup()
  ├─ TitleScene.lua
  ├─ MazeScene.lua
  │   ├─ entities/player/   (Player split across 10+ files)
  │   ├─ entities/enemies/  (Brocorat, bosscolli, CrewMember)
  │   ├─ entities/props/    (PropItem, Trigger, Door, Items)
  │   └─ entities/UI/       (playerHud, battery, healthIndicator, inGameMenu, dialogScreen)
  ├─ DanceScene.lua
  ├─ DeadScene.lua
  ├─ Floors.lua              → auto-generates FloorXXX classes
  ├─ PlayerDataTables.lua    → PlayerData, DefaultPlayerData, ResetPlayerData
  ├─ levels.lua              → levelsLDTK
  ├─ tilemap.lua             → tileMapData
  └─ script.lua              → script (dialog entries)
```

---

## Related documentation

| Doc | What it covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Boot sequence, import order, MazeScene enter() |
| [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md) | Every Config field |
| [PLAYERDATA_REFERENCE.md](PLAYERDATA_REFERENCE.md) | Every PlayerData field |
| [CUTSCENE_SYSTEM.md](CUTSCENE_SYSTEM.md) | Panels library, both cutscene types |
| [TRIGGER_SYSTEM.md](TRIGGER_SYSTEM.md) | Trigger entity types and conditions |
| [SAVE_SYSTEM.md](SAVE_SYSTEM.md) | Save/load/reset in detail |
| [ENEMIES_AND_COMBAT.md](ENEMIES_AND_COMBAT.md) | AI, DanceScene, power level |
| [DOORS_AND_KEYS.md](DOORS_AND_KEYS.md) | Door navigation |
