# customFields Schema in levels.lua

This document defines the complete `customFields` schema for each entity type in `levelsLDTK`. It serves as a reference for creating, editing, or validating level data.

> See also: [TRIGGER_SYSTEM.md](TRIGGER_SYSTEM.md), [NPC_SYSTEM.md](NPC_SYSTEM.md), [DIALOG_SYSTEM.md](DIALOG_SYSTEM.md) for the logic of each system.

---

## Overview of the Relationship Between Entities and Scripts

```
┌────────────────────────────────────────────────────────────────────┐
│                        LDtk (level)                                │
│                                                                    │
│  ┌──────────────────┐         ┌──────────────────┐                 │
│  │  Trigger entity  │         │   NPC entity     │                 │
│  │  type            │         │  type (sprite)   │                 │
│  │  script (fallbk) │         │  sourceFeed      │                 │
│  │  conditionalScrp │         │  conditionalScrp │                 │
│  │  usedTrigger     │         │  hasGranted      │                 │
│  └────────┬─────────┘         └────────┬─────────┘                 │
│           │                            │                            │
└───────────┼────────────────────────────┼────────────────────────────┘
            │  reference by name         │  reference by name
            ▼                            ▼
┌───────────────────────────────────────────────────────────────────┐
│                  script.lua (global `script` table)               │
│  { name = "scriptName",                                           │
│    dialog = {                                                      │
│      { video = "player", text = "key-01" },                       │
│      { video = "radioHand", text = "key-02" }                     │
│    }                                                               │
│  }                                                                 │
└───────────────────────────────────────────────────────────────────┘
            │  localized text
            ▼
┌─────────────────────────────────────┐
│   en.strings / jp.strings           │
│   "key-01" = "Visible text"         │
└─────────────────────────────────────┘
```

**Core rule**: neither Trigger nor NPC contains text. They only contain the name of a script. Scripts contain the text (as localization keys), and the text lives in the `.strings` files.

---

## Schema: Room (level customFields)

Each entry in `levelsLDTK` has these level-wide fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `level` | Number | Yes | Floor number (e.g., `4` for floor 4). |
| `roomNumber` | Number | Yes | Room number within the floor (e.g., `7`). `RoomID = level * 100 + roomNumber`. |
| `tile` | Number | Yes | Tilemap index in `tileMapData` used to generate wall colliders. |
| `shadow` | Bool | Yes | `true` if the room is in darkness. Activates `FXshadow` and battery restrictions. |
| `light` | Number | Yes | Light level in dark rooms. `0` = maximum darkness. Passed to `FXshadow`. |
| `visited` | Bool | Yes | `false` by default. Set to `true` when the room is loaded. Used by the map. |
| `comic_name` | String or nil | No | Name of the Panels cutscene played when entering the room. `nil` if none. |
| `comic_wasPlayed` | Bool | Yes | `false` by default. Set to `true` after the cutscene plays. Prevents repetition. |
| `DoorsConnection` | Array\<String\> | Yes | List of allowed door directions. Values: `"Top"`, `"Down"`, `"Left"`, `"Right"`. |
| `play` | String or nil | No | When to play the cutscene. `"Enter"` = on room entry. `nil` = never automatically. |
| `hasForeground` | Bool | Yes | `true` if a foreground sprite exists at `assets/images/rooms/floor{level}/foreground_{roomNumber}`. |

### `neighbourLevels` (neighbor array)

Each neighbor has:

| Field | Type | Description |
|-------|------|-------------|
| `levelIid` | String | UUID of the neighboring room. Used by `GetLowerRoom()` / `GetUpperRoom()` for vertical navigation. |
| `dir` | String | Relative direction: `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"`, `"<"` (lower level), `">"` (upper level). |

---

## Schema: Trigger

`Triggers` entity in LDtk. Class: `entities/props/trigger.lua`.

### Position and Size

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Always `"Triggers"`. |
| `iid` | String | Unique UUID generated by LDtk. Do not modify. |
| `x`, `y` | Number | Center of the rect in room coordinates. The sprite is positioned at `(x - width/2, y - height/2)`. |
| `width`, `height` | Number | Dimensions of the invisible collision area. |

### customFields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String or nil | No | Trigger type. See type table below. |
| `script` | String | No | Fallback script. Used when `conditionalScripts` is empty or no condition applies. |
| `conditionalScripts` | Array\<String\> | Yes (can be `{}`) | List of conditions evaluated top-to-bottom. Format: `"condition:script"` or `"condition:script!"`. |
| `usedTrigger` | Bool | Yes | `false` by default. Set to `true` when the trigger is consumed. **Do not modify manually**. |
| `mapPercent` | Number | Yes | Legacy field present in the data. Currently has no functional use in the evaluator. |

### Trigger Types (`type`)

| Value | Activation | Behavior | Consumed (fallback) |
|-------|-----------|----------|---------------------|
| `"Story"` | Automatic (collision) | Calls `dialogUI:addScreen(script)` directly | Yes |
| `"Cutscene"` | Automatic (collision) | Activates `isCutscene`, runs Panels | Yes |
| `"Counter"` | Automatic (collision) | Increments `PlayerData.storyCounter` | Yes (always) |
| `"Search"` | Manual (press A) | Shows magnifier/investigate icon | **No** (only type that persists in fallback) |
| `"Call"` | Manual (press A) | Shows radio icon | Yes |
| `nil` | Manual (press A) | Shows generic "Press A" icon | Yes |

### `conditionalScripts` Format (Trigger)

Each entry: `"condition:scriptName"` or `"condition:scriptName!"`

The terminal `!` causes the trigger to be marked `usedTrigger = true` when that condition is met.

Without `!`, the trigger remains active (repeatable).

**Fallback**: if `conditionalScripts` is empty or no condition applies, the `script` field is used. In that case, the trigger is consumed unless it is `"Search"`.

### Supported Conditions (shared with NPC)

| Syntax | Example | Evaluation |
|--------|---------|-----------|
| `"true"` | `"true:scriptFallback"` | Always true (catch-all); in Trigger this is not a special case — it evaluates as a boolean path in PlayerData (fails silently). Use the `script` field as the fallback in Triggers. |
| Boolean | `"isTiny:scriptA"` | `PlayerData.isTiny == true` |
| Negated | `"!isTiny:scriptB"` | `PlayerData.isTiny ~= true` |
| Nested path | `"items.hasLamp:scriptC"` | `PlayerData.items.hasLamp == true` |
| Numeric `>` | `"battery>20:scriptD"` | `PlayerData.battery > 20` |
| Numeric `<` | `"mapPercent<50:scriptE"` | `PlayerData.mapPercent < 50` |
| Numeric `>=` | `"storyCounter>=3:scriptF"` | `PlayerData.storyCounter >= 3` |
| Numeric `<=` | `"healthPoints<=2:scriptG"` | `PlayerData.healthPoints <= 2` |
| Numeric `==` | `"storyCounter==5:scriptH"` | `PlayerData.storyCounter == 5` |
| Numeric `!=` | `"storyCounter!=0:scriptI"` | `PlayerData.storyCounter ~= 0` |

### Complete Example

```lua
{
    id     = "Triggers",
    iid    = "d86c3bd0-fa90-11f0-88fd-7de014001b21",
    x      = 180,
    y      = 60,
    width  = 96,
    height = 24,
    customFields = {
        script             = "whyXmas",      -- fallback if no condition applies
        usedTrigger        = false,
        type               = "Search",       -- manual, not consumed in fallback
        mapPercent         = 0,
        conditionalScripts = {
            "isTiny:hugeXmas"                -- if player is tiny, shows hugeXmas
            -- if not, falls through to the script field: "whyXmas"
        }
    }
}
```

---

## Schema: NPC

`NPC` entity in LDtk. Class: `entities/props/npc.lua`.

### Position and Size

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Always `"NPC"`. |
| `iid` | String | Unique UUID generated by LDtk. Do not modify. |
| `x`, `y` | Number | Sprite position in the room. |
| `width`, `height` | Number | Dimensions (normally `32×32`). |

### customFields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | Animation state in the NPC spritesheet. Valid values: `"cat"`, `"computer"`. |
| `conditionalScripts` | Array\<String\> | Yes (can be `{}`) | List of conditions. Format: `"condition:script"` or `"condition:script:grantKey:grantVal"`. |
| `sourceFeed` | Number | No | Index of the dialog portrait feed. Default: `0`. |
| `hasGranted` | Bool | Yes | `false` by default. `true` when the grant has already been applied. **Do not modify manually**. |

### `conditionalScripts` Format (NPC)

Each entry: `"condition:scriptName"` or `"condition:scriptName:grantKey:grantVal"`

Grants are applied **only once** (controlled by `hasGranted`). Dialog can always be repeated.

### Grant Formats

| Format | Example | Effect on PlayerData |
|--------|---------|---------------------|
| `key:N` | `key:2` | `PlayerData.keys[2] = true` |
| `fieldName:true` | `hasBoots:true` | `PlayerData.items.hasBoots = true` |

An NPC can give **one grant per entry**. For multiple grants, use separate entries with different conditions.

### Complete Example

```lua
{
    id     = "NPC",
    iid    = "0ea7c260-21a0-11f1-ba67-7b68c287fc9b",
    x      = 364,
    y      = 132,
    width  = 32,
    height = 32,
    customFields = {
        type = "cat",
        conditionalScripts = {
            "!items.hasLamp:catNoLamp",      -- does not have the lamp
            "!items.hasBoots:catNoBoots",    -- has the lamp but not the boots
            "true:catWhat"                   -- catch-all
        },
        sourceFeed = 0,
        hasGranted = false
    }
}
```

---

## Schema: Script

Defined in `assets/data/script.lua` as the global `script` table.

```
Script {
  name:   String         -- unique identifier, referenced by Triggers and NPCs
  dialog: DialogLine[]   -- array of lines in order
}

DialogLine {
  video:  String         -- portrait state (see list below)
  text:   String         -- key in en.strings
  screen: Image?         -- (optional) static image above the dialog box
}
```

### Valid `video` States

| State | Description |
|-------|-------------|
| `player` | Player neutral portrait |
| `playerWorry` | Player worried |
| `playerSurprise` | Player surprised |
| `playerHappy` | Player happy |
| `playerAngry` | Player angry |
| `playerSleepy` | Player sleepy |
| `playerScared` | Player scared |
| `playerCry` | Player crying |
| `radioHand` | Radio in hand |
| `radioPocket` | Radio in pocket |
| `radioRing` | Radio ringing |
| `notesHand` | Notes in hand |

If `PlayerData.isTiny == true`, `-tiny` is automatically appended (e.g., `player-tiny`). There is no standalone `tiny` state.

### Example

```lua
{
    name = "terminal_authorized",
    dialog = {
        { video = 'radioHand', text = "terminal-auth-01" },
        { video = 'radioHand', text = "terminal-auth-02",
          screen = Graphics.image.new('assets/images/ui/dialog/img/terminal.png') },
    }
}
```

---

## Schema: ItemGift

Entity in LDtk representing a collectible item. Processed by the Items block in `MazeScene:enter()`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | LDtk entity identifier (e.g., `"ItemGift"`, `"Lamp"`, `"Boots"`, etc.). |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Position. |
| `width`, `height` | Number | Yes | Dimensions. |
| `customFields.type` | String | Yes | Item type. Values: `"lamp"`, `"radio"`, `"notes"`, `"boots"`, `"plunger"`, `"bag"`, `"honk"`, `"tools"`, `"keycard"`, `"itemGift"`. |
| `customFields.isItem` | Bool | Yes | Must be `true` for MazeScene to generate the item. |
| `customFields.grants` | String | No | For `"itemGift"`: what it grants when collected. Format: `"fieldName:true"` (e.g., `"hasDWatch:true"`). Multiple grants separated by comma. |
| `customFields.KeyNumber` | Number | No | For `"keycard"`: key number (1, 2, 3...). |

### Spawn Condition in MazeScene

MazeScene checks whether the item has already been collected before instantiating it:

- `keycard`: not generated if `PlayerData.keys[keyNumber]` is already `true`.
- `grants`: not generated if any item in the grants string is already in `PlayerData.items` or `PlayerData.skills`.
- Other types (`lamp`, `radio`, etc.): not generated if the corresponding field in `PlayerData.items` is already `true`.

---

## Schema: Door

`Doors` entity in LDtk. Class: `entities/props/door.lua`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Always `"Doors"`. |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Door position in the room. |
| `width`, `height` | Number | Yes | Dimensions of the door collider. |
| `customFields.DoorsConnection` | String | Yes | Door direction. Values: `"Top"`, `"Down"`, `"Left"`, `"Right"`. |
| `customFields.NeedsKey` | Bool | Yes | `true` if the door requires a key to open. `false` if always open. |
| `customFields.KeyNumber` | Number or nil | No | Required key number if `NeedsKey == true`. `nil` if no key is required. |

### Collision Behavior

- `NeedsKey == false`: open door, player passes through (`'overlap'`) and moves to the neighboring room.
- `NeedsKey == true` and player has the key: same as above.
- `NeedsKey == true` and player **does not** have the key: `dialogUI:addScreen("nokeys")` + `'freeze'`.

---

## Schema: PortalDoor

`PortalDoors` entity in LDtk. Class: `entities/props/portal_door.lua`. Allows teleportation to another room with conditions.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Always `"PortalDoors"`. |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Portal position in the room. |
| `width`, `height` | Number | Yes | Dimensions of the collider (`24×24` per `Config.Portals.collideRect`). |
| `customFields.PortalID` | Number | Yes | Portal identifier (used to pair portals). |
| `customFields.DestLevel` | Number | Yes | Destination floor number. |
| `customFields.DestRoom` | Number | Yes | Destination room number. |
| `customFields.SpawnX` | Number | Yes | Spawn X coordinate in the destination room. |
| `customFields.SpawnY` | Number | Yes | Spawn Y coordinate in the destination room. |
| `customFields.Conditions` | Array\<String\> | No | List of conditions that must be met to use the portal. Same format as `conditionalScripts`. |
| `customFields.BlockedDialog` | String | No | Name of the dialog script shown when the player cannot use the portal. |

### Collision Behavior

- If conditions are met: `other:setSpawn()` + `other:goTo()` (teleportation).
- If not met: `dialogUI:addScreen(other.blockedDialog or "nokeys")` + `'freeze'`.

---

## Schema: Brocorat / Bosscolli

Enemy entities in LDtk. Base class: `entities/enemies/enemy.lua`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | `"Brocorat"` or `"Bosscolli"`. |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Enemy spawn position. |
| `width`, `height` | Number | Yes | Dimensions. |
| `customFields.speed` | Number | Yes | Enemy movement speed (e.g., `0.5`). |
| `customFields.dead` | Bool | Yes | `false` by default. `true` if the enemy was defeated. **Do not modify manually**. |

### Spawn Condition in MazeScene

```lua
if not dead then
    Brocorat(x, y, speed, ZIndex.enemy, player, id)
else
    PropItem(x, y, "blood2", ZIndex.props, true)  -- shows blood instead of the enemy
end
```

---

## Schema: PropItem / Box

Destructible prop entities in LDtk. Class: `entities/props/propItem.lua`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Entity identifier (e.g., `"Box"`, `"PropItem"`). |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Prop position. |
| `width`, `height` | Number | Yes | Dimensions. |
| `customFields.type` | String | Yes | Prop type. Defines the sprite that is loaded. Examples: `"box"`, `"minifier"`, `"tube"`. |
| `customFields.nocollider` | Bool | Yes | `false` = the prop has a solid collider. `true` = the prop can be walked through. |
| `customFields.destroyed` | Bool | Yes | `false` by default. `true` if the prop was destroyed. **Do not modify manually**. |

### Spawn Condition in MazeScene

```lua
if cf.destroyed == false or cf.destroyed == nil then
    PropItem(x, y, cf.type, ZIndex.props, cf.nocollider, cf.destroyed, id)
else
    PropItem(x, y, "debris", ZIndex.props, true, cf.destroyed, id)  -- rubble
end
```

MazeScene iterates over **all** entities and detects props by the presence of `destroyed` or `nocollider` in `customFields` — not by the entity `id`.

---

## Schema: CrewMember

Allied entity in LDtk. Class: `entities/enemies/crewmember.lua`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Always `"CrewMember"`. |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Spawn position. |
| `width`, `height` | Number | Yes | Dimensions. |
| `customFields.isTaken` | Bool | Yes | `false` by default. `true` if the player already rescued this member. **Do not modify manually**. |
| `customFields.crewID` | String | No | Semantic identifier for the member (e.g., `"CM001"`). Used for specific dialogs and capture logic. |

### Spawn Condition

```lua
if not taken then
    CrewMember(x, y, speed, ZIndex.enemy, player, crewIid, room, crewId)
end
```

---

## Shared Condition Evaluator (Trigger and NPC)

Both entities use the same condition syntax evaluated against `PlayerData`.

### Most Common PlayerData Paths in Conditions

```
isTiny                      -- bool: player is in tiny mode
items.hasLamp               -- bool: has the lamp
items.hasBoots              -- bool: has the boots
items.hasRadio              -- bool: has the radio
items.hasBag                -- bool: has the bag
items.hasPlunger            -- bool: has the plunger
items.hasDWatch             -- bool: has the watch
keys[1] / keys[2] / keys[3] -- bool: has key N
mapPercent                  -- number: % of map explored
battery                     -- number: battery level (0-100)
healthPoints                -- number: current HP
storyCounter                -- number: story event counter
```

### Evaluation Order

Conditions are evaluated **top-to-bottom**. The first one that applies wins; the rest are ignored.

- In NPCs: always put `"true:scriptFallback"` as the last entry to guarantee a result.
- In Triggers: use the `script` field in LDtk as the fallback (more robust than `"true"` in `conditionalScripts`).

---

## Complete Interaction Flow

```
Player collides with entity
         │
         ▼
Is it an automatic Trigger?        → executes directly
(Story, Cutscene, Counter)           without player intervention
         │ No
         ▼
Is it a manual Trigger or NPC?     → player.currentTrigger = entity
(Search, Call, nil, NPC)             MazeScene shows HUD icon
         │
         │ Player presses A
         ▼
MazeScene.AButtonDown()
  PlayerData.isGaming = false
  PlayerData.isTalking = true
  scriptName = trigger:returnScript()
  dialogUI:addScreen(scriptName, trigger.sourceFeed)
         │
         ▼
returnScript() in Trigger or NPC:
  Finds entity in levelsLDTK by iid
  Evaluates conditionalScripts top-to-bottom
  Returns the first scriptName that applies
  (NPC only) If there's a grant and !hasGranted → apply grant → markGranted()
  (Trigger) If scriptName ends in ! → marks usedTrigger = true
         │
         ▼
dialogUI:addScreen(scriptName)
  Searches global `script` table by name
  If not found → printDebug and return (no dialog, no crash)
  If found → PlayerData.isTalking = true, shows first DialogLine
         │
         │ Player presses A (advance)
         ▼
dialogUI:nextDialog()
  → next DialogLine, or closes if it was the last
  → on close: PlayerData.isTalking = false, PlayerData.isGaming = true
```

---

## Key Differences Between Trigger and NPC

| Aspect | Trigger | NPC |
|--------|---------|-----|
| Base class | `Graphics.sprite` | `NobleSprite` |
| Size | Configurable (invisible rect) | Fixed 32×32 (visible sprite) |
| Automatic activation | Yes (Story, Cutscene, Counter) | Never |
| HUD icon | Depends on `type` | Always "Press A" |
| Grants | No | Yes (`key:N` or `fieldName:true`) |
| Persistence | `usedTrigger` (destroyed) | `hasGranted` (only hides the grant) |
| Repeatable | Depends on `!` in script | Always (only the grant is one-shot) |
| Conditional spawn | Yes (skipped if `usedTrigger == true`) | No (always instantiated) |
| Fallback script | `script` field in LDtk | `"true:scriptFallback"` as last entry |
| conditionalScripts format | `cond:script` or `cond:script!` | `cond:script` or `cond:script:grantKey:grantVal` |
| Physical collision | None (overlap only) | `NPCCollider` 24×24 in `CollideGroups.wall` |

---

## Persistence — Fields by Entity

| Field | Entity | When modified | Who modifies it |
|-------|---------|---------------|-----------------|
| `usedTrigger` | Trigger | `returnScript()` decides to consume it | `returnScript()` in trigger.lua |
| `hasGranted` | NPC | First interaction with a successful grant | `NPC:markGranted()` in npc.lua |
| `dead` | Brocorat / Bosscolli | Enemy is defeated in DanceScene | Combat system |
| `isTaken` | CrewMember | Player rescues the ally | `CrewMember:taken()` |
| `destroyed` | PropItem / Box | Prop is destroyed | PropItem logic |
| `visited` | Room | When the room is loaded | `MazeScene:enter()` |
| `comic_wasPlayed` | Room | After a cutscene completes | Panels callback |

The SaveSystem serializes only modified fields (by `iid`) on top of a clean copy of `levelsLDTK`. No manual persistence management is needed — saving occurs in `MazeScene:finish()` and `MazeScene:pause()`.
