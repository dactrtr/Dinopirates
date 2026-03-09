# Save System Documentation

This document explains the game's persistence layer, handled by `utilities/SaveSystem.lua`. It manages the saving and loading of player progress and world state adjustments.

---

## 💾 Overview

The Save System enables persistence by:
1.  **Serializing** the current state of dynamic objects (Enemies, Props, Triggers) into a Lua table.
2.  **Writing** this table to the Playdate's data store.
3.  **Restoring** this state when the game loads, applying changes to the initial LDtk level data.

---

## 🗃️ Data Structure

The save file (`gameState.json` internally managed by Playdate) contains a root table with the following fields:

### Root Object
-   **`version`**: String (e.g., `"2.0-LDTK"`). Used for migration checks.
-   **`timestamp`**: Number. The time of the save.
-   **`player`**: Table. A direct snapshot of the global `PlayerData` table (Health, Inventory, Skills, Battery).
-   **`levelState`**: Array. The core world state data.

### Level State Object
`levelState` is an indexed array matching the `levelsLDTK` structure. Each entry contains:
-   **`identifier`**: String (e.g., `"Room_101"`).
-   **`visited`**: Boolean.
-   **`entities`**: Table. Grouped by Entity Type (`Brocorat`, `CrewMember`, `PropItem`, etc.).

### Entity State Object
Entities are identified by their LDtk **IID** (Instance Identifier). Only changed fields are typically saved/restored:
-   **`iid`**: String. The unique ID from LDtk.
-   **`dead`** (Enemies): Boolean.
-   **`destroyed`** (Props): Boolean.
-   **`isTaken`** (Crew): Boolean.
-   **`collected`** (Items): Boolean.
-   **`usedTrigger`** (Triggers): Boolean.

---

## 🔄 Logic Flow

### 1. Saving (`getLevelState`)
The system iterates through the active `levelsLDTK` table in memory.
-   It checks critical custom fields like `dead` or `destroyed`.
-   If an entity has these fields set (meaning it was interacted with), it creates a lightweight record containing just the `iid` and the state.
-   This minimizes file size by not saving static data (like positions of static objects).

### 2. Loading (`restoreLevelState`)
When the game boots:
1.  It loads the raw LDtk data (`levelsLDTKOriginal`).
2.  It iterates through the saved `levelState`.
3.  For each saved entity record, it searches the fresh `levelsLDTK` for a matching `iid`.
4.  It **overwrites** the properties of the fresh entity with the saved values.
    -   *Example*: If a door was locked in the LDtk file, but the save says `locked: false`, the in-memory door becomes unlocked.

---

## 🛠️ Love2D Porting Guide

This section details how to replicate this system in Love2D.

### 1. File I/O (`playdate.datastore` vs `love.filesystem`)
Playdate's `datastore` automatically serializes Lua tables to a JSON-like format.
-   **Love2D Implementation**:
    -   Use a serialization library like **bitser** (binary, fast) or **dkjson** (human-readable).
    -   **Code Example**:
        ```lua
        -- Saving
        local json = require "dkjson"
        local saveData = { player = PlayerData, ... }
        local str = json.encode(saveData)
        love.filesystem.write("savegame.json", str)

        -- Loading
        if love.filesystem.getInfo("savegame.json") then
            local str = love.filesystem.read("savegame.json")
            local data = json.decode(str)
            -- Apply data...
        end
        ```

### 2. Save Directory
-   **Playdate**: Saves to a sandbox specific to the game bundle.
-   **Love2D**: Saves to `love.filesystem.getSaveDirectory()` (e.g., `%APPDATA%/Love/GameName` on Windows). Ensure you set `t.identity` in `conf.lua` to set the folder name.

### 3. Entity ID Matching
The logic relying on `iid` is platform-agnostic and relies on your LDtk parser.
-   **Requirement**: Ensure your Love2D LDtk loader (like `Simple-Tiled-Implementation` or a custom parser) preserves the `iid` field for every entity instance. If the loader discards this ID, the save system will break.

### 4. Deep Copy
The default `SaveSystem.lua` relies on `table.deepcopy` (a Playdate CoreLibs extension).
-   **Love2D**: You will need to bring your own deep copy function to back up the original level state (`levelsLDTKOriginal`) so you can reset the game without reloading the actual files.
