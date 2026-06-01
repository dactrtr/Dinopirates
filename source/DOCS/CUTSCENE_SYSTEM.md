# Cutscene System

The game uses the **Panels** library (`libraries/panels/`) to display comic-style
cutscenes. There are two entry points that trigger cutscenes:

1. **Room-entry cutscene** — triggered by `MazeScene:enter()` based on LDtk room fields
2. **Trigger cutscene** — triggered by `player:collisionResponse()` when the player
   walks into a `Trigger` entity of type `"Cutscene"`

Both share the same underlying system: a `comics` table registry and `Panels.startCutscene()`.

See [TRIGGER_SYSTEM.md](TRIGGER_SYSTEM.md) for how trigger entities work in general.
See [PLAYERDATA_REFERENCE.md](PLAYERDATA_REFERENCE.md) for `isCutscene` and `isGaming` flag semantics.

---

## The `comics` Registry

`source/assets/comics/comicsData.lua` is the registry of all cutscene sequences:

```lua
-- comicsData.lua
import "assets/comics/intro"
import "assets/comics/pick-the-device"

comics = {
    ["intro"]           = intro,
    ["pick-the-device"] = pickDevice
}
```

**`comics` is a global table.** Each key is a string name; each value is a Panels
sequence table (a Lua table that Panels reads to display panels/images).

### Adding a new cutscene

1. Create `source/assets/comics/my-cutscene.lua` defining a `myCutscene` local variable
2. Add `import "assets/comics/my-cutscene"` to `comicsData.lua`
3. Add `["my-cutscene"] = myCutscene` to the `comics` table
4. Reference `"my-cutscene"` in LDtk `comic_name` field (room-entry) or in a trigger's `script` field (trigger cutscene)

---

## Panels sequence data structure

Each Panels sequence is a Lua array of **sequences** (chapters). Each sequence contains
**panels** (pages). Each panel contains **layers** (images stacked on top of each other).

```lua
-- Minimal example (based on intro.lua)
intro = {
    -- Sequence 1
    {
        scrollType       = Panels.ScrollType.AUTO,
        direction        = Panels.ScrollDirection.NONE,
        backgroundColor  = Graphics.kColorWhite,
        advanceControl   = Panels.Input.A,    -- A button advances
        frame            = { margin = 0 },
        title            = "Intro",

        panels = {
            -- Panel 1: single image layer
            {
                layers = {
                    { image = "comics/intro/001", x = -8, y = -8 }
                }
            },
            -- Panel 2: two layers (background + overlay)
            {
                layers = {
                    { image = "comics/intro/001", x = -8, y = -8 },
                    { image = "comics/intro/002", x = -8, y = -8 },
                }
            },
            -- Additional panels add more layers cumulatively...
        }
    }
}
```

**Image paths** are relative to `Panels.Settings.path` (set to `""` in `main.lua`),
then the Playdate SDK appends `.png`. So `image = "comics/intro/001"` loads
`source/assets/images/comics/intro/001.png` (check `Panels.Settings.path` for the exact root).

---

## Type 1: Room-Entry Cutscene

### How it's configured (LDtk)

On the room's custom fields in LDtk:

| Field | Type | Value | Meaning |
|---|---|---|---|
| `comic_name` | String | `"intro"` | Key into the `comics` table |
| `play` | String | `"Enter"` | When to play (`"Enter"` = on room entry) |
| `comic_wasPlayed` | Boolean | `false` | Tracks if already played (saved to disk) |

### Code path (in `MazeScene:enter()`)

```lua
-- MazeScene.lua (step 11 of enter sequence)
local cf = levelsLDTK[room].customFields

if cf.comic_name then
    local comicData = comics[cf.comic_name]     -- look up Panels sequence
    if comicData then
        if cf.play == "Enter" and cf.comic_wasPlayed == false then
            PlayerData.isCutscene = true         -- block game input
            PlayerData.isGaming = false
        end

        Panels.startCutscene(comicData, function()
            -- This callback runs when the player finishes the cutscene
            PlayerData.isGaming = true
            PlayerData.isCutscene = false
            levelsLDTK[room].customFields.comic_wasPlayed = true  -- mark as seen
            Utilities.checkStoryAchievement(cf.comic_name)
        end)
    end
end
```

### Update loop integration (`MazeScene:update()`)

```lua
-- MazeScene.lua update()
if PlayerData.isCutscene == true then
    if Noble.Input.getEnabled() then
        Noble.Input.setEnabled(false)   -- disable all game inputs
    end
    Panels.update()                     -- Panels drives itself each frame
else
    if not Noble.Input.getEnabled() then
        Noble.Input.setEnabled(true)    -- re-enable when done
    end
end
```

**Panels must receive `Panels.update()` every frame while a cutscene is playing.**
The game ensures this by checking `PlayerData.isCutscene` in `MazeScene:update()`.

### One-shot persistence

When the cutscene completes, the callback sets:
```lua
levelsLDTK[room].customFields.comic_wasPlayed = true
```
`SaveSystem.save()` (called on `MazeScene:finish()` and `MazeScene:pause()`) then
serializes `comic_wasPlayed` into the save file. On next load, `SaveSystem.load()`
restores it — so `comic_wasPlayed == true` and the cutscene is skipped.

### Flow diagram

```
MazeScene:enter()
  ├─ Read customFields.comic_name
  ├─ Lookup comics[comic_name]           → nil? skip
  ├─ comic_wasPlayed == false?           → true? skip (already seen)
  ├─ Set isCutscene=true, isGaming=false
  └─ Panels.startCutscene(data, callback)

MazeScene:update() [every frame]
  ├─ isCutscene == true?
  │   ├─ Noble.Input.setEnabled(false)
  │   └─ Panels.update()                ← Panels draws and reads its own input
  └─ isCutscene == false?
      └─ Noble.Input.setEnabled(true)

[Player presses A to advance panels until end]

Panels completion callback:
  ├─ isGaming = true
  ├─ isCutscene = false
  ├─ levelsLDTK[room].customFields.comic_wasPlayed = true
  └─ Utilities.checkStoryAchievement(comic_name)
```

---

## Type 2: Trigger-Activated Cutscene

### How it's configured (LDtk)

On a `Triggers` entity in LDtk:

| Field | Type | Value | Meaning |
|---|---|---|---|
| `type` | String | `"Cutscene"` | Triggers the cutscene path in collisionResponse |
| `script` | String | `"my-cutscene"` | Key into the `comics` table (same registry) |
| `usedTrigger` | Boolean | `false` | Saved; when `true` the trigger is skipped on room load |

> **Important:** A trigger cutscene uses `cf.script` as the `comics` key — NOT
> `comic_name`. The naming is different from room-entry cutscenes.

### Spawn condition (in `MazeScene:enter()`)

```lua
-- MazeScene.lua (step 14 of enter sequence)
if entities and entities.Triggers then
    for i, triggerData in ipairs(entities.Triggers) do
        local cf = triggerData.customFields or {}
        local used = cf.usedTrigger or false

        if not used then  -- skip if already consumed
            Trigger(x, y, width, height, cf.script, triggerData.iid, room, cf.type)
        end
    end
end
```

### Code path (in `player:collisionResponse`)

```lua
-- entities/player/collisions.lua
elseif other:isa(Trigger) then
    if other.type == "Cutscene" then
        PlayerData.isGaming = false
        PlayerData.isCutscene = true           -- same flag as room-entry cutscene
        other:returnScript()                   -- marks usedTrigger=true in levelsLDTK
        other:remove()                         -- removes sprite from scene
        Utilities.grantAchievementIfNeeded(other.script)
    end
    return 'overlap'
```

### What `returnScript()` does for a Cutscene trigger

```lua
-- trigger.lua returnScript() — fallback branch (no conditionalScripts)
if self.type ~= "Search" then
    cf.usedTrigger = true   -- marks consumed in levelsLDTK live table
end
return self.script          -- returns the comics key string
```

### IMPORTANT: Where the cutscene actually starts

The `"Cutscene"` collision handler sets `PlayerData.isCutscene = true` but does
**not** call `Panels.startCutscene()`. The return value of `returnScript()` (the
comics key) is **discarded** in `collisionResponse`.

This means:
- Input is blocked (`isCutscene=true`)
- `MazeScene:update()` calls `Panels.update()` each frame
- **But no Panels sequence is started** — so nothing is displayed

**To make a Cutscene trigger actually play a Panels sequence, add this to
`collisionResponse` after `other:remove()`:**

```lua
-- Suggested addition to player/collisions.lua for self-contained trigger cutscenes:
local comicKey = other.script
local comicData = comics[comicKey]
if comicData then
    Panels.startCutscene(comicData, function()
        PlayerData.isGaming = true
        PlayerData.isCutscene = false
    end)
end
```

### Flow diagram (current behavior)

```
Player walks into Trigger (type="Cutscene")
  ↓
collisionResponse → Trigger branch
  ├─ isGaming = false
  ├─ isCutscene = true
  ├─ trigger:returnScript()          → sets usedTrigger=true in levelsLDTK
  ├─ trigger:remove()                → sprite gone, won't fire again this room
  └─ grantAchievementIfNeeded()

MazeScene:update() [next frame and beyond]
  ├─ isCutscene == true
  ├─ Noble.Input.setEnabled(false)   ← input is blocked
  └─ Panels.update()                 ← called but no sequence is active

[On room exit → SaveSystem.save() → usedTrigger=true persisted]
[On next room load → usedTrigger=true → Trigger not spawned]
```

---

## Panels.startCutscene — API reference

```lua
Panels.startCutscene(
    sequenceData,   -- Panels sequence table (from comics registry)
    callback        -- function() called when player completes all panels
)
```

**Must be called while `Panels.update()` is being called each frame.**
If `Panels.update()` is not in the update loop, Panels will not advance.

The game ensures this by checking `PlayerData.isCutscene` in `MazeScene:update()`.

---

## Love2D Porting Notes

### Replacing Panels

Panels is a Playdate-specific library. In Love2D, implement a minimal equivalent:

```lua
-- CutscenePlayer.lua
local CutscenePlayer = {}
local current = nil   -- { sequences, seqIdx, panelIdx, callback }

function CutscenePlayer.start(sequenceData, callback)
    current = {
        sequences = sequenceData,
        seqIdx    = 1,
        panelIdx  = 1,
        callback  = callback,
    }
    PlayerData.isCutscene = true
    PlayerData.isGaming   = false
end

function CutscenePlayer.update() end  -- no-op; drawing is in draw()

function CutscenePlayer.draw()
    if not current then return end
    local seq   = current.sequences[current.seqIdx]
    local panel = seq.panels[current.panelIdx]

    -- Draw background
    love.graphics.setBackgroundColor(unpack(seq.backgroundColor or {1, 1, 1}))

    -- Draw all layers of this panel
    for _, layer in ipairs(panel.layers) do
        local img = love.graphics.newImage(layer.image .. ".png")
        love.graphics.draw(img, layer.x, layer.y)
    end
end

function CutscenePlayer.advance()
    if not current then return end
    local seq = current.sequences[current.seqIdx]
    current.panelIdx = current.panelIdx + 1

    if current.panelIdx > #seq.panels then
        current.seqIdx   = current.seqIdx + 1
        current.panelIdx = 1

        if current.seqIdx > #current.sequences then
            -- All sequences complete
            local cb = current.callback
            current = nil
            PlayerData.isCutscene = false
            PlayerData.isGaming   = true
            if cb then cb() end
        end
    end
end

-- Integration:
-- In love.keypressed:
--   if PlayerData.isCutscene and (key == "return" or key == "space") then
--       CutscenePlayer.advance()
--   end
-- In love.draw (after world, before HUD):
--   if PlayerData.isCutscene then CutscenePlayer.draw() end

return CutscenePlayer
```

### Replacing `Panels.Settings.path`

Panels resolves image paths relative to `Panels.Settings.path` (set to `""` in `main.lua`).
In Love2D, prefix all image paths with your asset root (e.g. `"assets/images/"`).

### `comic_wasPlayed` persistence

The field is saved and loaded by `SaveSystem`. In Love2D, ensure your save serializer
includes `levelsLDTK[i].customFields.comic_wasPlayed` for every room — the existing
`SaveSystem.getLevelState()` already handles this for the Playdate version.
