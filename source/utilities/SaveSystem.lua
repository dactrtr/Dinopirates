-- Create a new module for save management
SaveSystem = {}

-------------------------------------------------------------
-- Extract necessary level data
-------------------------------------------------------------
--- Extrae el estado actual de todos los niveles para guardado
-- @return table Estado serializable de todos los niveles
function SaveSystem.getLevelState()
    local levelState = {}

    for i, level in ipairs(levelsLDTK) do
        levelState[i] = {
            identifier = level.identifier,
            uniqueIdentifer = level.uniqueIdentifer,

            visited = level.customFields.visited or false,
            comic_wasPlayed = level.customFields.comic_wasPlayed or false,

            entities = {}
        }

        if level.entities then
            for entityType, entitiesList in pairs(level.entities) do
                levelState[i].entities[entityType] = {}

                for _, entity in ipairs(entitiesList) do
                    local entityState = {
                        iid = entity.iid
                    }

                    if entity.customFields then
                        -- Enemies
                        if entityType == "Brocorat" or entityType == "Bosscolli" then
                            entityState.dead = entity.customFields.dead or false
                            entityState.speed = entity.customFields.speed
                            entityState.x = entity.x
                            entityState.y = entity.y
                        end

                        -- Props
                        if entity.customFields.destroyed ~= nil then
                            entityState.destroyed = entity.customFields.destroyed
                        end

                        -- CrewMembers
                        if entityType == "CrewMember" then
                            entityState.isTaken = entity.customFields.isTaken or false
                            entityState.crewID = entity.customFields.crewID
                        end

                        -- Items
                        if entity.layer == "Items" then
                            entityState.collected = entity.customFields.collected or false
                        end

                        -- Triggers - Save ALL trigger data including 'usedTrigger' status
                        if entity.customFields.type or entity.customFields.script or entity.customFields.usedTrigger ~= nil then
                            entityState.type = entity.customFields.type
                            entityState.script = entity.customFields.script
                            entityState.usedTrigger = entity.customFields.usedTrigger or false
                        end
                        
                        -- Also check by entityType or layer name
                        if entityType == "Triggers" or entity.layer == "Triggers" then
                            entityState.type = entity.customFields.type
                            entityState.script = entity.customFields.script
                            entityState.usedTrigger = entity.customFields.usedTrigger or false
                        end
                    end

                    table.insert(levelState[i].entities[entityType], entityState)
                end
            end
        end
    end

    return levelState
end


-------------------------------------------------------------
-- Restore level state (Corregido)
-------------------------------------------------------------
--- Restaura el estado de los niveles desde datos guardados
-- @param levelState table Estado de niveles previamente guardado
function SaveSystem.restoreLevelState(levelState)
    if not levelState then return end

    for i, state in ipairs(levelState) do
        if levelsLDTK[i] then

            -- Check uniqueIdentifer in case order changed
            if levelsLDTK[i].uniqueIdentifer ~= state.uniqueIdentifer then
                
                for j, level in ipairs(levelsLDTK) do
                    if level.uniqueIdentifer == state.uniqueIdentifer then
                        
                        i = j
                        break
                    end
                end
            end

            -- Restore simple fields
            if levelsLDTK[i].customFields then
                levelsLDTK[i].customFields.visited = state.visited
                levelsLDTK[i].customFields.comic_wasPlayed = state.comic_wasPlayed
            end

            if not (state.entities and levelsLDTK[i].entities) then
                goto continue
            end

            -------------------------------------------------
            -- ENTITY RESTORATION (with Trigger fallback)
            -------------------------------------------------
            for entityType, savedEntities in pairs(state.entities) do
                local targetList = levelsLDTK[i].entities[entityType]

                -- Fallback: if entityType does not match, try by layer = "Triggers"
                if not targetList and (entityType == "Triggers") then
                    for key, list in pairs(levelsLDTK[i].entities) do
                        if list[1] and list[1].layer == "Triggers" then
                            
                            targetList = list
                            break
                        end
                    end
                end

                if targetList then
                    for _, savedEntity in ipairs(savedEntities) do
                        for _, currentEntity in ipairs(targetList) do
                            if currentEntity.iid == savedEntity.iid then
                                
                                if currentEntity.customFields then
                                    -- Enemies
                                    if savedEntity.dead ~= nil then
                                        currentEntity.customFields.dead = savedEntity.dead
                                    end
                                    if savedEntity.speed then
                                        currentEntity.customFields.speed = savedEntity.speed
                                    end
                                    if savedEntity.x and savedEntity.y then
                                        currentEntity.x = savedEntity.x
                                        currentEntity.y = savedEntity.y
                                    end

                                    -- Props
                                    if savedEntity.destroyed ~= nil then
                                        currentEntity.customFields.destroyed = savedEntity.destroyed
                                    end

                                    -- CrewMembers
                                    if savedEntity.isTaken ~= nil then
                                        currentEntity.customFields.isTaken = savedEntity.isTaken
                                    end

                                    -- Triggers (fix)
                                    if savedEntity.usedTrigger ~= nil then
                                        currentEntity.customFields.usedTrigger = savedEntity.usedTrigger
                                    end
                                    if savedEntity.type then
                                        currentEntity.customFields.type = savedEntity.type
                                    end
                                    if savedEntity.script then
                                        currentEntity.customFields.script = savedEntity.script
                                    end
                                    
                                    -- Items
                                    if savedEntity.collected ~= nil then
                                        currentEntity.customFields.collected = savedEntity.collected
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
            ::continue::
        end
    end
end


-------------------------------------------------------------
-- Save (Fixed: using datastore correctly)
-------------------------------------------------------------
--- Guarda el estado completo del juego en datastore
-- @return boolean true si el guardado fue exitoso, false en caso contrario
function SaveSystem.save()
    local saveData = {
        player = PlayerData,
        levelState = SaveSystem.getLevelState(),
        timestamp = playdate.getTime(),
        version = "2.0-LDTK"
    }

    -- Debug: Count triggers being saved
    local triggerCount = 0
    local usedTriggerCount = 0
    for _, level in ipairs(saveData.levelState) do
        if level.entities then
            for entityType, entities in pairs(level.entities) do
                for _, entity in ipairs(entities) do
                    if entity.usedTrigger ~= nil or entity.type or entity.script then
                        triggerCount = triggerCount + 1
                        if entity.usedTrigger then
                            usedTriggerCount = usedTriggerCount + 1
                        end
                    end
                end
            end
        end
    end
    

    -- Write to datastore (no .json extension needed)
    local success = playdate.datastore.write(saveData, 'gameState', true)
    
    if success ~= false then
        printDebug("💾 Game saved successfully")
        return true
    else
        printDebug("❌ Failed to save game")
        return false
    end
end


-------------------------------------------------------------
-- Load (Fixed: proper error handling)
-------------------------------------------------------------
--- Carga el estado del juego desde datastore
-- @return boolean, number|nil true si se cargó exitosamente, número de nivel guardado
function SaveSystem.load()
    local saveData = playdate.datastore.read('gameState')
    
    if saveData then
        if saveData.version == "2.0-LDTK" then
            PlayerData = saveData.player
            
            -- Debug: Count triggers being loaded
            local triggerCount = 0
            local usedTriggerCount = 0
            for _, level in ipairs(saveData.levelState) do
                if level.entities then
                    for entityType, entities in pairs(level.entities) do
                        for _, entity in ipairs(entities) do
                            if entity.usedTrigger ~= nil or entity.type or entity.script then
                                triggerCount = triggerCount + 1
                                if entity.usedTrigger then
                                    usedTriggerCount = usedTriggerCount + 1
                                end
                            end
                        end
                    end
                end
            end
            
            
            SaveSystem.restoreLevelState(saveData.levelState)
            
            return true, saveData.player.saveLevel
        else
            printDebug("⚠️ Old save format detected, migration needed")
            return false, nil
        end
    end

    print("🔭 No save file found")
    return false, nil
end


-------------------------------------------------------------
-- Reset (Resets to original state without deleting file)
-------------------------------------------------------------
function SaveSystem.reset()
    ResetPlayerData()
    if levelsLDTKOriginal then
        levelsLDTK = table.deepcopy(levelsLDTKOriginal)
    end
    print("🔄 Game state reset")
end


-------------------------------------------------------------
-- Delete save (Fixed: using correct datastore delete)
-------------------------------------------------------------
function SaveSystem.delete()
    -- Use datastore.delete instead of file.delete
    local success = playdate.datastore.delete('gameState')
    
    if success ~= false then
        print("🗑️ Save deleted successfully")
    else
        print("⚠️ Could not delete save file (may not exist)")
    end
    
    -- Reset to original state
    ResetPlayerData()

    if levelsLDTKOriginal then
        levelsLDTK = table.deepcopy(levelsLDTKOriginal)
    end
end


-------------------------------------------------------------
-- Backup original level data
-------------------------------------------------------------
function SaveSystem.createOriginalBackup()
    if not levelsLDTKOriginal then
        levelsLDTKOriginal = table.deepcopy(levelsLDTK)
    end
end

return SaveSystem