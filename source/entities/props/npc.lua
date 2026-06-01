NPCCollider = {}
class('NPCCollider').extends(NobleSprite)

function NPCCollider:init(x, y)
    NPCCollider.super.init(self)
    self:setSize(24, 24)
    self:setCollideRect(0, 0, 24, 24)
    self:setGroups(CollideGroups.wall)
    self:setCollidesWithGroups({})
    self:add(x, y)
end

NPC = {}
class('NPC').extends(NobleSprite)

function NPC:init(x, y, npcType, iid, room, sourceFeed)
    NPC.super.init(self, 'assets/images/props/npc', true)

    self.npcType    = npcType
    self.iid        = iid
    self.room       = room
    self.sourceFeed = sourceFeed or 0
    self.script     = nil  -- Required: MazeScene calls grantAchievementIfNeeded(trigger.script)
    self.type       = nil  -- Required: state.lua checks self.currentTrigger.type; nil → setPressA() HUD

    -- Spritesheet states: add new NPC types here mapping to frame ranges
    self.animation:addState('cat', 1, 4)
    self.animation.cat.frameDuration = 12
    self.animation:addState('computer', 5, 8)
    self.animation:setState(npcType)

    self:setSize(32, 32)
    self:setCollideRect(0, 0, 32, 32)
    self:setZIndex(ZIndex.props)
    self:setGroups(CollideGroups.props)   -- Player's collidesWithGroups includes props(3)
    self:setCollidesWithGroups({})        -- NPC doesn't need to detect anything
    self:add(x, y)

    self.wall = NPCCollider(x, y)

    printDebug("🖥️ NPC spawned - type:", npcType, "iid:", iid)
end

function NPC:update()
    self:setZIndex(self.y)
end

function NPC:remove()
    if self.wall then
        Noble.currentScene():removeSprite(self.wall)
        self.wall = nil
    end
    NPC.super.remove(self)
end

-- Called by MazeScene's AButtonDown handler when player presses A near this NPC.
-- Evaluates conditionalScripts, applies grants (once), returns dialog script name.
function NPC:returnScript()
    local scriptName, grantsStr = self:evaluateConditions()

    if grantsStr and not self:hasGranted() then
        self:applyGrant(grantsStr)
        self:markGranted()
    end

    return scriptName or ""
end

-- Evaluates conditionalScripts top-to-bottom. Returns (scriptName, grantsStr) for first match.
-- grantsStr is nil if no grants in the matching entry.
function NPC:evaluateConditions()
    local npcData = self:getLDTKData()
    if not npcData then return nil, nil end

    local cf = npcData.customFields or {}
    local conditionalScripts = cf.conditionalScripts or {}

    for _, entry in ipairs(conditionalScripts) do
        -- Split on ':' — supports "condition:script" or "condition:script:grantKey:grantVal"
        local parts = {}
        for part in entry:gmatch("[^:]+") do
            parts[#parts + 1] = part
        end

        local conditionExpr = parts[1]
        local scriptName    = parts[2]
        -- Rebuild grants string from parts 3+4 if present
        local grantsStr = nil
        if parts[3] and parts[4] then
            grantsStr = parts[3] .. ":" .. parts[4]
        end

        if conditionExpr and scriptName and self:evaluateCondition(conditionExpr) then
            return scriptName, grantsStr
        end
    end

    return nil, nil
end

-- Evaluates a single condition expression against PlayerData.
-- Supports: literal "true", numerical comparisons (>/</>=/<==/!=), boolean paths, !negation.
function NPC:evaluateCondition(conditionExpr)
    -- Special case: literal "true" always matches (catch-all fallback)
    if conditionExpr == "true" then return true end

    -- Numerical comparison: "path>N", "path<=N", etc.
    local path, op, valStr = conditionExpr:match("^([%w%.]+)%s*([<>!=]=?)%s*([%d%-%.]+)$")
    if path and op and valStr then
        local current = PlayerData
        for part in path:gmatch("[^%.]+") do
            if current then current = current[part] end
        end
        local val        = tonumber(valStr)
        local currentVal = tonumber(current) or 0
        if     op == ">"  then return currentVal > val
        elseif op == "<"  then return currentVal < val
        elseif op == ">=" then return currentVal >= val
        elseif op == "<=" then return currentVal <= val
        elseif op == "==" then return currentVal == val
        elseif op == "!=" then return currentVal ~= val
        end
    end

    -- Boolean path: "items.hasLamp", "!isTiny", etc.
    local invert    = false
    local cleanPath = conditionExpr
    if cleanPath:sub(1, 1) == "!" then
        invert    = true
        cleanPath = cleanPath:sub(2)
    end
    local current = PlayerData
    for part in cleanPath:gmatch("[^%.]+") do
        if current then current = current[part] end
    end
    local result = (current == true)
    if invert then result = not result end
    return result
end

-- Applies a grant string to PlayerData. Supported formats:
--   "key:N"          → PlayerData.keys[N] = true
--   "fieldName:true" → PlayerData.items[fieldName] = true
function NPC:applyGrant(grantsStr)
    local grantKey, grantVal = grantsStr:match("^([^:]+):(.+)$")
    if not grantKey or not grantVal then
        printDebug("⚠️ NPC: invalid grants format:", grantsStr)
        return
    end

    grantKey = grantKey:gsub("%s+", "")

    if grantKey == "key" then
        local keyNum = tonumber(grantVal)
        if keyNum then
            PlayerData.keys[keyNum] = true
            printDebug("🎁 NPC granted key:", keyNum)
        end
    elseif grantVal == "true" then
        PlayerData.items[grantKey] = true
        printDebug("🎁 NPC granted item:", grantKey)
    end
end

-- Returns true if grants have already been applied for this NPC.
function NPC:hasGranted()
    local npcData = self:getLDTKData()
    if not npcData then return false end
    return (npcData.customFields or {}).hasGranted == true
end

-- Marks hasGranted = true in levelsLDTK. SaveSystem.save() persists this on room exit.
function NPC:markGranted()
    local npcData = self:getLDTKData()
    if not npcData then return end
    if not npcData.customFields then npcData.customFields = {} end
    npcData.customFields.hasGranted = true
    printDebug("✅ NPC grants marked as used:", self.iid)
end

-- Finds this NPC's entry in levelsLDTK by iid.
function NPC:getLDTKData()
    local roomData = levelsLDTK[self.room]
    if not roomData or not roomData.entities or not roomData.entities.NPC then return nil end
    for _, data in ipairs(roomData.entities.NPC) do
        if data.iid == self.iid then return data end
    end
    return nil
end
