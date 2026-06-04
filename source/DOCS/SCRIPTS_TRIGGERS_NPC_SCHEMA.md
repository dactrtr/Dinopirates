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
| `comic_wasPlayed` | Bool | Yes (legacy) | **No longer used for persistence.** Cutscene "already seen" state now lives in `PlayerData.seenComics[comic_name]` (rooms are reused templates in procedural mode). See [PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md). |
| `DoorsConnection` | Array\<String\> | Yes | List of allowed door directions. Values: `"Top"`, `"Down"`, `"Left"`, `"Right"`. |
| `play` | String or nil | No | When to play the cutscene. `"Enter"` = on room entry. `nil` = never automatically. |
| `hasForeground` | Bool | Yes | `true` if a foreground sprite exists at `assets/images/rooms/floor{level}/foreground_{roomNumber}`. |
| `procGen` | Bool | Yes (procedural) | `true` → the room is eligible for random placement in the run graph. Secret rooms set `false`. See [PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md). |
| `roomRole` | Enum String | Yes (procedural) | `Start` / `Normal` / `Final` / `StartDown` / `StartUp` (case-insensitive). Buckets the template in the pool. |
| `requiredItems` / `RequiredItems` | Array\<String\> | No | Items needed to traverse the room (case-insensitive, e.g. `{"HasLamp"}`). If the player lacks any, the room is excluded from the pool. |
| `requiredSkills` / `RequiredSkills` | Array\<String\> | No | Skills needed for the room to enter the pool, checked against `PlayerData.skills` (e.g. `{"canDance"}`). Both this and `requiredItems` must be satisfied. |

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
| `conditionalScripts` | Array\<String\> | Yes (can be `{}`) | List of conditions evaluated top-to-bottom. Format: `"condition:script"` or `"condition:script!"`. Chooses which dialog runs **on interaction**. |
| `spawnConditions` | Array\<String\> | No | Render gate evaluated **before** the trigger is created (see [Spawn Conditions](#spawn-conditions-render-gate)). If present and not all met, the trigger is not spawned. Independent of `conditionalScripts`. |
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
| `customFields.spawnConditions` | Array\<String\> | No | Render gate evaluated before the item is created (see [Spawn Conditions](#spawn-conditions-render-gate)). Applied **in addition** to the ownership check below. |

### Spawn Condition in MazeScene

MazeScene checks whether the item has already been collected before instantiating it:

- `keycard`: not generated if `PlayerData.keys[keyNumber]` is already `true`.
- `grants`: not generated if any item in the grants string is already in `PlayerData.items` or `PlayerData.skills`.
- Other types (`lamp`, `radio`, etc.): not generated if the corresponding field in `PlayerData.items` is already `true`.

On top of the above, if `spawnConditions` is present it must pass too (see next section).

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

### Procedural behavior

In procedural mode (keys are removed), `CreateDoorsFromNode` creates a functional door only on sides the graph **connected** (`node.edges`), matching facing sides by **door signature** (count + position + size). All doors on a side lead to the same neighbour. A side the graph left **unconnected** is covered by a **wall plug** (`CreateWallPlugsFromNode`): wall brick stamped from the tilesheet + a wall collider, so the opening looks solid and can't be walked through. See [PROCEDURAL_GENERATION.md §4 & §11](PROCEDURAL_GENERATION.md#4-door-connection-signature-matching).

---

## Schema: PortalDoor

`PortalDoors` entity in LDtk. Class: `entities/props/portal_door.lua`. In procedural mode, portals are **entrances to secret rooms**, paired A↔A by `PortalID`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Always `"PortalDoors"`. |
| `iid` | String | Yes | Unique UUID. |
| `x`, `y` | Number | Yes | Portal position in the room. |
| `width`, `height` | Number | Yes | Dimensions of the collider (`24×24` per `Config.Portals.collideRect`). |
| `customFields.PortalID` | Number | Yes | Pairing id. The portal in the destination room with the **same** `PortalID` is the return portal. |
| `customFields.DestLevel` | Number | Yes | Destination floor. Resolves the secret room by `DestLevel*100 + DestRoom`. |
| `customFields.DestRoom` | Number | Yes | Destination room number (the secret room is authored `procGen = false`). |
| `customFields.SpawnX` | Number | Yes | Spawn X in the destination room. |
| `customFields.SpawnY` | Number | Yes | Spawn Y in the destination room. |
| `customFields.Conditions` | Array\<String\> | No | Conditions to use the portal (e.g. `{"isTiny:true"}`). Same syntax as `conditionalScripts` conditions. |
| `customFields.BlockedDialog` | String | No | Dialog script shown when conditions aren't met. |

### Procedural behavior

During generation, each placed room's portals pull their destination template in as an `isSecret` graph node, linking `host.portals[PortalID] ↔ secret.portals[PortalID]`. Secret rooms are **not** part of side-connectivity. See [PROCEDURAL_GENERATION.md §7](PROCEDURAL_GENERATION.md#7-secret-rooms-via-portaldoors).

### Collision Behavior

- If `canEnter()` (all `Conditions`) passes: `other:setSpawn()` (spawn at `SpawnX/SpawnY`) + `other:goTo()` → `RunState.goTo(targetNodeId)` + transition.
- If not: `dialogUI:addScreen(other.blockedDialog or "nokeys")` + `'freeze'`.

> Authoring: a secret-room pair is two `PortalDoors` sharing a `PortalID`, each pointing at the other's room (`DestLevel`/`DestRoom`). The secret room must be `procGen = false` so it's reachable only via the portal.

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

## Spawn Conditions (render gate)

`spawnConditions` is an **optional render gate** on `Triggers` and item entities, evaluated by `MazeScene:enter()` **before** the entity is created. If present and not satisfied, the entity is never spawned. It is completely separate from `conditionalScripts` (which only chooses *which dialog* runs once you interact with an already-spawned trigger).

- **Field name:** `spawnConditions` (LDtk PascalCase `SpawnConditions` is also accepted).
- **Type:** `Array<String>`.
- **Evaluator:** `utilities/Conditions.lua` (`Conditions.met`). Shared, but independent from the `conditionalScripts` logic in `trigger.lua` / `npc.lua`.

### Logic: AND across entries, OR within an entry

- Every entry in the array must pass (**AND**).
- Inside one entry, `|`-separated sub-conditions are **OR** (the entry passes if any sub passes).
- `nil` / empty array = no gate (always spawns).

### Condition syntax

| Form | Example | Meaning |
|------|---------|---------|
| Numeric | `"run>=4"`, `"crew==2"`, `"healthPoints<3"` | `<path> <op> <number>`, ops `> < >= <= == !=` |
| Boolean path | `"items.hasLamp"` | `PlayerData.items.hasLamp == true` |
| Negated | `"!isTiny"` | `PlayerData.isTiny ~= true` |
| Literal | `"true"` | always passes |

Aliases: `run` → `PlayerData.runCount`, `crew` → `PlayerData.CrewMemberData.amountTaken`. Numeric values and aliases are case-stable; boolean **paths are case-sensitive** (write `items.hasLamp`, not `HasLamp`).

### Examples

| Goal | `spawnConditions` |
|------|-------------------|
| Only on run 4 | `{"run==4"}` |
| On run 4 **or** 8 | `{"run==4\|run==8"}` |
| Run 4 onward | `{"run>=4"}` |
| (Run 4 or 8) **and** has lamp | `{"run==4\|run==8", "items.hasLamp"}` |
| Run 4/8/12 and tiny | `{"run==4\|run==8\|run==12", "isTiny"}` |

```lua
-- A trigger that only appears from the 4th run onward, and only if the player has the lamp.
customFields = {
    type               = "Story",
    script             = "lateGameHint",
    usedTrigger        = false,
    conditionalScripts = {},                       -- dialog selection (unchanged)
    spawnConditions    = { "run>=4", "items.hasLamp" }, -- render gate (new)
}
```

> `runCount` is incremented on NewGame and on each death/Retry (not on hole/tube), and persists in the save. See `PLAYERDATA_REFERENCE.md`.

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

## Persistence (procedural model)

> **Updated for `3.0-PROCGEN`.** The game no longer patches a fixed `levelsLDTK` with per-`iid` `levelState`. Templates are immutable; per-run entity state lives on graph **nodes** (`node.content` / `node.cleared`) and is serialized as part of `RunState`. See [SAVE_SYSTEM.md](SAVE_SYSTEM.md) and [PROCEDURAL_GENERATION.md](PROCEDURAL_GENERATION.md).

| State | Where it lives now | When modified |
|-------|--------------------|---------------|
| Enemy killed | `node.cleared.enemies[key] = {x,y}` | Defeated in DanceScene (`findAndKillEnemyById`) |
| Crew taken | `node.cleared.crewTaken` + `PlayerData.CrewMemberData.idNumbers` | `CrewMember:taken()` |
| Active enemies / utilities / crew for the run | `node.content` | Rolled in `MapGenerator.generate` |
| Cutscene seen | `PlayerData.seenComics[comic_name]` | Panels completion callback |
| `usedTrigger` / `hasGranted` | template `customFields` (run-local) | `returnScript()` / `NPC:markGranted()` |

`SaveSystem.save()` writes `{ player = PlayerData, run = RunState.serialize() }`; saving occurs in `MazeScene:finish()`, `MazeScene:pause()`, and `DanceScene`.
