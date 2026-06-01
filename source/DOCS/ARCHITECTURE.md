# Architecture — Boot Sequence and Global Connections

---

## Complete Boot Sequence (`main.lua`)

`main.lua` is the sole entry point of the game. Imports run top to bottom; order matters because later files depend on globals defined by earlier ones.

```
1.  Noble                          → scene framework (NobleScene, NobleSprite, Noble.*)
2.  Panels                         → cutscene library
3.  achievements/all               → achievement system
4.  assets/data/Config             → defines the global Config table
5.  utilities/Utilities            → defines Box, CheatCode, helpers (depends on Config)
6.  utilities/SaveSystem           → defines SaveSystem (depends on Config, Utilities)
7.  scenes/DeadScene               → game over scene
8.  scenes/MazeScene               → gameplay scene (depends on Config, PlayerData)
9.  scenes/DanceScene              → rhythm combat scene
10. scenes/Floors                  → generates FloorXXX classes (hardcoded ranges)
11. scenes/SpaceScene              → space shooter scene
12. scenes/TestScene               → test scene (dev)
13. scenes/CreditsScene            → credits scene
14. scenes/CockpitScene            → cockpit scene
15. scenes/TitleScene              → title scene (first visible scene)
16. assets/data/PlayerDataTables   → defines PlayerData and ResetPlayerData()
17. assets/data/levels             → defines levelsLDTK (rooms table)
18. assets/data/tilemap            → defines tileMapData (IntGrid matrices)
19. assets/data/script             → defines script (dialogs)
20. achievements/all (data)        → achievementData
21. assets/data/toastConfig        → configToast
```

---

## Global Initialization After Imports

Code executed in `main.lua` after all imports, before `Noble.new`:

```lua
-- Config aliases
ZIndex = Config.ZIndex
CollideGroups = Config.CollideGroups

-- Achievement setup
achievements.initialize(achievementData)
achievements.forceSaveOnGrantOrRevoke = true
achievements.toasts.initialize(configToast)

-- Noble Settings
Noble.Settings.setup({ Difficulty = "Medium", playerSlot = 1 })
Noble.showFPS = false
Noble.GameData.setup({ Score = 0 }, 1)

-- Global state variables
Panels.vars.lang = "en"
debugMenu = false
debug = false
diagonalMovement = true
shinonome = Graphics.font.new('assets/fonts/JF-Dot-Shinonome16')
Graphics.setFont(shinonome, 'normal')
Panels.Settings.path = ""

-- Backup of original state (before any mutation)
SaveSystem.createOriginalBackup()

-- Build the rooms-by-iid hash
roomsByIid = {}
if levelsLDTK then
    for _, room in ipairs(levelsLDTK) do
        if room and room.uniqueIdentifer then
            roomsByIid[room.uniqueIdentifer] = room
        end
    end
end

-- Playdate system menu
local menu = playdate.getSystemMenu()
menu:addMenuItem("Title", function()
    Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)
end)

-- Display configuration
playdate.display.setRefreshRate(50)
timers = playdate.timer

-- Start the game
Noble.new(TitleScene, 0.3, Noble.Transition.MetroNexus)
```

---

## Complete Globals Table

| Global | Type | Source | Description |
|---|---|---|---|
| `Config` | table | `Config.lua` | All tunable game constants |
| `ZIndex` | table | `main.lua` | Alias of `Config.ZIndex` — render layers |
| `CollideGroups` | table | `main.lua` | Alias of `Config.CollideGroups` — collision groups |
| `PlayerData` | table | `PlayerDataTables.lua` | Complete mutable player state |
| `levelsLDTK` | table | `levels.lua` | All room data exported from LDtk |
| `tileMapData` | table | `tilemap.lua` | 2D IntGrid matrices for collisions |
| `script` | table | `script.lua` | Array of dialog entries |
| `roomsByIid` | table | `main.lua` | Hash `iid → room` for O(1) lookup |
| `achievementData` | table | `achievements/all.lua` | Achievement definition data |
| `debug` | boolean | `main.lua` | `false` by default; enables debug overlays |
| `debugMenu` | boolean | `main.lua` | `false` by default |
| `diagonalMovement` | boolean | `main.lua` | `true` — enables diagonal movement |
| `shinonome` | font | `main.lua` | JF-Dot-Shinonome16 font |
| `timers` | table | `main.lua` | Alias of `playdate.timer` |
| `Panels` | table | Noble/Panels lib | Cutscene library |

### Why `ZIndex` and `CollideGroups` Are Aliases

```lua
ZIndex = Config.ZIndex
CollideGroups = Config.CollideGroups
```

These are references to the same objects inside `Config`. Changing `Config.ZIndex.player` also changes `ZIndex.player`. They exist as short aliases so entity files can write `ZIndex.player` instead of `Config.ZIndex.player`.

---

## Building `roomsByIid`

```lua
roomsByIid = {}
for _, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer then
        roomsByIid[room.uniqueIdentifer] = room
    end
end
```

Built once at startup. Used by `FindRoomByIid(iid)` in `door.lua` to look up neighboring rooms without linearly iterating `levelsLDTK`. The key is LDtk's `uniqueIdentifer` string (UUID).

---

## Noble Engine Lifecycle

```
Noble.new(TitleScene)
  └─ scene:init()    ← when transitioning OUT of the previous scene
     scene:enter()   ← when the scene should be visible (entity spawning)
     scene:start()   ← when the transition animation finishes
     scene:update()  ← every frame (~50fps)
     scene:pause()   ← when opening the system menu → SaveSystem.save()
     scene:exit()    ← when transitioning to the next scene
     scene:finish()  ← when the exit animation finishes → SaveSystem.save()
```

**Critical rule:** `PlayerData.isGaming = true` is set in `scene:start()`, NOT in `scene:enter()`. Entities are created during `enter()` but gameplay input is blocked until `start()` completes.

---

## Room Number Formula

```
RoomID = (level × 100) + roomNumber
Example: level=4, roomNumber=8 → Floor408
```

`Floors.lua` generates scene classes (`Floor166`, `Floor231`, etc.) from hardcoded numeric ranges:

```
Current ranges: 166–180, 231–274, 316–330, 401–415
```

Each class calls `self:setFloor(level, room)` in `init()` where:
```lua
level = math.floor(i / 100)
room  = i % 100
```

`RoomTranslate(roomNumber)` returns `_G["Floor" .. roomNumber]` — the scene class.

---

## Dependency Graph (Simplified)

```
main.lua
├── Noble (framework)
├── Panels (cutscenes)
├── Config.lua  ←────────────── everything uses Config
│     └── ZIndex, CollideGroups (aliases in main.lua)
├── Utilities.lua  ←─────────── uses Config.Tiles, Config.Doors
│     ├── Box class
│     ├── CheatCode class
│     ├── CreateTileColliders()
│     ├── FindRoomByIid()  ←── uses roomsByIid (from main.lua)
│     └── GetLowerRoom/GetUpperRoom
├── SaveSystem.lua  ←────────── uses PlayerData, levelsLDTK
├── Scenes (all)
│     └── MazeScene  ←──────── uses Config, PlayerData, levelsLDTK, tileMapData
│           ├── CreateDoorsFromLDTK()  ← in door.lua
│           ├── CreateTileColliders()  ← in Utilities.lua
│           └── FXshadow, Player, HUD, Enemies...
├── PlayerDataTables.lua  → PlayerData global
├── levels.lua  → levelsLDTK global
├── tilemap.lua → tileMapData global
└── script.lua  → script global
```

---

## Scene Flow Diagram

```
Noble.new(TitleScene)
    │
    ├──[New Game]──→ MazeScene (FloorXXX based on saveLevel)
    │                    │
    │                    ├──[touches enemy]──→ DanceScene
    │                    │                        │
    │                    │        [victory]────────┘
    │                    │        [defeat]──→ DeadScene ──[retry]──→ MazeScene
    │                    │                          └──[exit]───→ TitleScene
    │                    │
    │                    ├──[completes game]──→ CockpitScene
    │                    │                          │
    │                    │                 [correct sequence]──→ CreditsScene
    │                    │                 [fails 10 times]───→ TitleScene
    │                    │
    │                    └──[SpaceScene integrated in ending flow]
    │
    └──[Continue]──→ SaveSystem.load() → MazeScene (FloorXXX based on saveLevel)
```

---

## Complete `MazeScene:enter()` Sequence

When a `FloorXXX` scene transitions, `MazeScene:enter()` executes in this order:

```
1.  PlayerData flags:
      .room, .isInDarkness, .floor, .actualLevel, .actualRoom, .actualTilemap
      levelsLDTK[room].visited = true

2.  Load background PNG:
      'assets/images/rooms/floor{level}/{identifier}'
      Sprite at ZIndex=1, centered at (200, 120)
      [Rooms are pre-rendered PNGs, NOT runtime tilemaps]

3.  Load foreground PNG (if hasForeground == true):
      'assets/images/rooms/floor{level}/foreground_{roomNumber}'
      Sprite at ZIndex.foreground (300)

4.  Create inGameMenu instance

5.  CreateTileColliders(tileMapData[PlayerData.actualTilemap])
      Wall=1, Slime=2, Hole=3, Floor=4, TinyHole=32

6.  CreateDoorsFromLDTK(currentRoom)
      Only cardinal doors (n/s/e/w) create Door sprites
      Stairs (>/< ) do NOT create sprites

7.  Spawn Props:
      destroyed==false → PropItem(x, y, cf.type, ...)
      destroyed==true  → PropItem(x, y, "debris", ...)

8.  Spawn Items:
      isItem==true and not owned → Items(x, y, itemType, keyNumber, grants)

9.  Spawn Player at PlayerData.playerSpawn.{x,y}
      player = Player(...)
      uiScreen = playerHud(player)

10. Spawn FX:
      shadow==true → FXshadow(player, 70, lightLevel, ZIndex.fx)

11. Check room cutscene (comic_name)

12. Spawn Enemies:
      Brocorat/Bosscolli → enemy entity
      dead==true → PropItem "blood2"

13. Spawn CrewMembers:
      isTaken==true → skip

14. Spawn Triggers:
      usedTrigger==true → skip
```

`scene:start()` runs after the transition animation:
```lua
PlayerData.isGaming = true   -- gameplay begins here
```

---

## Love2D Equivalent

```lua
-- Equivalent of love.load()
Config = require("assets.data.Config")
ZIndex = Config.ZIndex
CollideGroups = Config.CollideGroups
require("assets.data.PlayerDataTables")   -- defines PlayerData global
levelsLDTK = require("assets.data.levels")
tileMapData = require("assets.data.tilemap")
script      = require("assets.data.script")

-- Build room hash
roomsByIid = {}
for _, room in ipairs(levelsLDTK) do
    if room and room.uniqueIdentifer then
        roomsByIid[room.uniqueIdentifer] = room
    end
end

SaveSystem.createOriginalBackup()  -- deep-copy of levelsLDTK before any mutation
SceneManager.switch(TitleScene)
```

Key differences for the porter:
- Noble `scene:start()` is equivalent to "after the transition animation". With instant scene changes, call `start()` immediately after `enter()`.
- `playdate.timer` (alias `timers`) is equivalent to `dt`-based timers in Love2D.
- `PlayerData.isGaming = true` must be deferred until any entry animation finishes.
- `playdate.display.setRefreshRate(50)` → 50fps target on Playdate; in Love2D use `love.window.setMode` with vsync or a custom `love.run`.

---

## Related Documentation

| Doc | Contents |
|---|---|
| [CONFIG_REFERENCE.md](CONFIG_REFERENCE.md) | Every Config field with value and description |
| [SAVE_SYSTEM.md](SAVE_SYSTEM.md) | Save/load/reset lifecycle |
| [LEVEL_LOADING.md](LEVEL_LOADING.md) | Room loading and vertical navigation |
| [DOORS_AND_KEYS.md](DOORS_AND_KEYS.md) | Door and key system |
| [TILE_LOADING.md](TILE_LOADING.md) | Tilemap structure and FXshadow |
| [INPUT_SYSTEM.md](INPUT_SYSTEM.md) | Button callbacks and Love2D mapping |
| [HUD_SYSTEM.md](HUD_SYSTEM.md) | All HUD elements |
| [INGAME_MENU.md](INGAME_MENU.md) | Equipment menu in detail |
