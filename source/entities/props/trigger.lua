Trigger = {}
class('Trigger').extends(Graphics.sprite)

function Trigger:init(x, y, width, height, script, iid, room, type)
    self.script = script
    self.iid = iid  -- ⭐ CORREGIDO: Ahora recibe el iid correctamente
    self.room = room
    self.type = type
    
    self:setCollideRect(0, 0, width, height)
    self:setZIndex(3)
    self:moveTo(x - width / 2, y - height / 2)
    self:setGroups(3)
    self:add()
    
    printDebug("🎯 Trigger creado - iid:", self.iid, "type:", self.type, "script:", self.script)
end

function Trigger:returnScript()
    self:clearCollideRect()
    
    local roomData = levelsLDTK[self.room]
    if not roomData or not roomData.entities or not roomData.entities.Triggers then
        printDebug("⚠️ No trigger data found for room:", self.room)
        return self.script
    end
    
    -- Find trigger data
    local triggerData
    for _, t in ipairs(roomData.entities.Triggers) do
        if t.iid == self.iid then
            triggerData = t
            break
        end
    end

    if not triggerData then return self.script end

    local cf = triggerData.customFields or {}

    -- Check for conditional scripts
    if cf.conditionalScripts then
        for _, condStr in ipairs(cf.conditionalScripts) do
            -- Format: "condition:script"
            local conditionExpr, targetScript = condStr:match("^(.*):(.*)$")
            
            if conditionExpr and targetScript then
                local isMet = false
                
                -- Check for terminal flag '!' in script name
                local isTerminal = false
                if targetScript:sub(-1) == "!" then
                    isTerminal = true
                    targetScript = targetScript:sub(1, -2) -- Remove '!'
                end

                -- Check for comparison operators (order matters: check 2-char ops first)
                local path, op, valStr = conditionExpr:match("^([%w%.]+)%s*([<>!=]=?)%s*([%d%-%.]+)$")
                
                if path and op and valStr then
                    -- Numerical/Comparison Logic
                    local current = PlayerData
                    for part in path:gmatch("[^%.]+") do
                        if current then current = current[part] end
                    end
                    
                    local val = tonumber(valStr)
                    local currentVal = tonumber(current) or 0 -- Default to 0 if nil/not number
                    
                    if op == ">" then isMet = currentVal > val
                    elseif op == "<" then isMet = currentVal < val
                    elseif op == ">=" then isMet = currentVal >= val
                    elseif op == "<=" then isMet = currentVal <= val
                    elseif op == "==" then isMet = currentVal == val
                    elseif op == "!=" then isMet = currentVal ~= val
                    end
                    
                    printDebug(string.format("🔍 Comparación: %s (%s) %s %s -> %s", path, tostring(currentVal), op, valStr, tostring(isMet)))
                else
                    -- Boolean Logic (Original)
                    local invert = false
                    local cleanPath = conditionExpr
                    
                    if cleanPath:sub(1,1) == "!" then
                        invert = true
                        cleanPath = cleanPath:sub(2)
                    end

                    -- Resolve path in PlayerData
                    local current = PlayerData
                    for part in cleanPath:gmatch("[^%.]+") do
                        if current then current = current[part] end
                    end

                    isMet = (current == true)
                    if invert then isMet = not isMet end
                end

                if isMet then
                    if isTerminal then
                        cf.usedTrigger = true
                        printDebug("✅ Trigger marcado como usado (Terminal):", triggerData.iid)
                    else
                        printDebug("ℹ️ Trigger mantenido activo (Transient):", triggerData.iid)
                    end
                    printDebug("✅ Trigger ejecutando script:", targetScript)
                    return targetScript
                end
            end
        end
    end

    -- Fallback legacy logic
    -- By default, legacy/fallback scripts consume the trigger (backward compatibility)
    -- EXCEPT if it is a "Search" trigger, which should persist by default.
    if self.type ~= "Search" then
        cf.usedTrigger = true
        printDebug("✅ Trigger fallback marcado como usado:", triggerData.iid)
    else
        printDebug("ℹ️ Trigger Search mantenido activo (Fallback):", triggerData.iid)
    end

    local scriptToReturn = self.script
    if PlayerData.isTiny and cf.tinyScript then
        scriptToReturn = cf.tinyScript
        printDebug("🔍 Usando script tiny:", cf.tinyScript)
    end
    
    return scriptToReturn
end


function Trigger:markAsUsed()
    local roomData = levelsLDTK[self.room]
    
    if not roomData or not roomData.entities or not roomData.entities.Triggers then
        printDebug("⚠️ No trigger data found for room:", self.room)
        return
    end
    
    for _, triggerData in ipairs(roomData.entities.Triggers) do
        if triggerData.iid == self.iid then
            local cf = triggerData.customFields or {}
            cf.usedTrigger = true
            printDebug("✅ Trigger marcado como usado:", triggerData.iid)
            break
        end
    end
end