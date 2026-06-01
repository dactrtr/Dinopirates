PortalDoor = {}
class('PortalDoor').extends(NobleSprite)

function PortalDoor:init(portalId, destLevel, destRoom, spawnX, spawnY, conditions, blockedDialog, x, y, width, height)
    self.portalId      = portalId
    self.destRoomId    = destLevel * 100 + destRoom
    self.spawnX        = spawnX
    self.spawnY        = spawnY
    self.conditions    = conditions or {}
    self.blockedDialog = blockedDialog or "nokeys"

    local cr = Config.Portals.collideRect
    local w  = width  or cr.w
    local h  = height or cr.h

    PortalDoor.super.init(self, nil, true)
    self:setSize(w, h)
    self:setCollideRect(cr.x, cr.y, w, h)
    self:setZIndex(ZIndex.props)
    self:setGroups(3)
    self:add(x, y)
end

-- Resolves a dot-separated path like "inventory.tools" inside PlayerData.
local function resolvePath(path)
    local current = PlayerData
    for part in path:gmatch("[^%.]+") do
        if current == nil then return nil end
        current = current[part]
    end
    return current
end

-- Returns true if ALL conditions pass (AND logic). Empty table = open.
function PortalDoor:canEnter()
    for _, condStr in ipairs(self.conditions) do
        local conditionExpr = condStr:match("^(.-):.+$") or condStr
        local isMet = false

        -- Try numerical comparison first (e.g. "healthPoints>=3")
        local path, op, valStr = conditionExpr:match("^([%w%.]+)%s*([<>!=]=?)%s*([%d%-%.]+)$")
        if path and op and valStr then
            local current    = tonumber(resolvePath(path)) or 0
            local val        = tonumber(valStr)
            if     op == ">"  then isMet = current >  val
            elseif op == "<"  then isMet = current <  val
            elseif op == ">=" then isMet = current >= val
            elseif op == "<=" then isMet = current <= val
            elseif op == "==" then isMet = current == val
            elseif op == "!=" then isMet = current ~= val
            end
        else
            -- Boolean path (e.g. "isTiny" or "!isTiny")
            local invert    = conditionExpr:sub(1,1) == "!"
            local cleanPath = invert and conditionExpr:sub(2) or conditionExpr
            isMet = (resolvePath(cleanPath) == true)
            if invert then isMet = not isMet end
        end

        if not isMet then return false end
    end
    return true
end

function PortalDoor:setSpawn()
    PlayerData.playerSpawn.x = self.spawnX
    PlayerData.playerSpawn.y = self.spawnY
end

function PortalDoor:goTo()
    Noble.transition(RoomTranslate(self.destRoomId), 1.5, Noble.Transition.Default)
end

function PortalDoor:collisionResponse()
    return "slide"
end

-- Iterates currentRoom.entities.PortalDoors and instantiates each one.
function CreatePortalDoorsFromLDTK(currentRoom)
    if not currentRoom then return end
    local portalEntities = currentRoom.entities and currentRoom.entities.PortalDoors
    if not portalEntities or not next(portalEntities) then return end

    for _, entity in ipairs(portalEntities) do
        local cf = entity.customFields or {}
        local destLevel    = cf.DestLevel    or 1
        local destRoom     = cf.DestRoom     or 0
        local spawnX       = cf.SpawnX       or 196
        local spawnY       = cf.SpawnY       or 116
        local conditions   = cf.Conditions   or {}
        local blockedDialog = cf.BlockedDialog or "nokeys"
        local portalId     = cf.PortalID     or 0

        PortalDoor(
            portalId, destLevel, destRoom,
            spawnX, spawnY,
            conditions, blockedDialog,
            entity.x, entity.y,
            entity.width, entity.height
        )
        printDebug("🌀 PortalDoor created — ID:", portalId, "→ room", destLevel * 100 + destRoom)
    end
end
