-- SaveSystem: persistence for the procedural roguelike (version "3.0-PROCGEN").
--
-- Two things are saved:
--   * player — the whole PlayerData blob (meta that persists across runs: items,
--     skills, CrewMemberData, sanityCounter, ...; plus the run-local player state so
--     Continue resumes exactly where you left off).
--   * run    — the active run graph (see RunState.serialize): nodes reference their
--     room template by uniqueIdentifer, with per-run content/cleared deltas.
--
-- The old per-iid levelState model is gone: entity state now lives per-run inside the
-- graph nodes, so there is nothing to write back onto levelsLDTK.
SaveSystem = {}

local SAVE_VERSION = "3.0-PROCGEN"

-------------------------------------------------------------
-- Save
-------------------------------------------------------------
--- Saves PlayerData + the active run graph to the datastore.
-- @return boolean true on success.
function SaveSystem.save()
    local saveData = {
        player    = PlayerData,
        run       = RunState.serialize(),
        timestamp = playdate.getTime(),
        version   = SAVE_VERSION,
    }

    local success = playdate.datastore.write(saveData, 'gameState', true)
    if success ~= false then
        printDebug("💾 Game saved (" .. SAVE_VERSION .. ")")
        return true
    else
        printDebug("❌ Failed to save game")
        return false
    end
end


-------------------------------------------------------------
-- Load
-------------------------------------------------------------
--- Loads PlayerData and rebuilds the active run graph.
-- @return boolean true if a compatible save was loaded and the run restored.
function SaveSystem.load()
    local saveData = playdate.datastore.read('gameState')
    if not saveData then
        printDebug("🔭 No save file found")
        return false
    end

    if saveData.version ~= SAVE_VERSION then
        printDebug("⚠️ Incompatible save version: " .. tostring(saveData.version))
        return false
    end

    PlayerData = saveData.player

    if not RunState.deserialize(saveData.run) then
        printDebug("❌ Failed to restore run graph from save")
        return false
    end

    printDebug("💾 Game loaded (" .. SAVE_VERSION .. ")")
    return true
end


-------------------------------------------------------------
-- Reset (in-memory reset without deleting the save file)
-------------------------------------------------------------
function SaveSystem.reset()
    ResetPlayerData()
    RunState.clear()
    if levelsLDTKOriginal then
        levelsLDTK = table.deepcopy(levelsLDTKOriginal)
    end
    printDebug("🔄 Game state reset")
end


-------------------------------------------------------------
-- Delete (wipes everything: save file + meta + active run)
-------------------------------------------------------------
function SaveSystem.delete()
    local success = playdate.datastore.delete('gameState')
    if success ~= false then
        printDebug("🗑️ Save deleted successfully")
    else
        printDebug("⚠️ Could not delete save file (may not exist)")
    end

    ResetPlayerData()
    RunState.clear()
    if levelsLDTKOriginal then
        levelsLDTK = table.deepcopy(levelsLDTKOriginal)
    end
end


-------------------------------------------------------------
-- Backup original level data (deep copy of the immutable templates)
-------------------------------------------------------------
function SaveSystem.createOriginalBackup()
    if not levelsLDTKOriginal then
        levelsLDTKOriginal = table.deepcopy(levelsLDTK)
    end
end

return SaveSystem
