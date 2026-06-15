PortalDoor = {}
class('PortalDoor').extends(NobleSprite)

function PortalDoor:init(portalId, spawnX, spawnY, conditions, blockedDialog, x, y, width, height)
    self.portalId      = portalId
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
    -- Procedural mode: a portal routes to its paired secret-room node (resolved by the
    -- generator via PortalID). setSpawn() already placed the player at this portal's
    -- authored SpawnX/SpawnY, so flag returningInPlace to keep it (skip door-spawn).
    if not self.targetNodeId then
        printDebug("⚠️ PortalDoor has no target node (secret room not in this run)")
        return
    end
    PlayerData.returningInPlace = true
    RunState.goTo(self.targetNodeId)
    Noble.transition(MazeScene, 1.5, Noble.Transition.Default)
end

function PortalDoor:collisionResponse()
    return "slide"
end

-- Instantiates the PortalDoors authored in a node's room template, wiring each one to
-- the secret-room node the generator paired it with (node.portals[PortalID]). Portals
-- whose secret room isn't in this run (no pairing) get no target and stay inert.
function CreatePortalsFromNode(node)
    if not node or not node.poolRoom then return end
    local portalEntities = node.poolRoom.entities and node.poolRoom.entities.PortalDoors
    if not portalEntities or not next(portalEntities) then return end
    local portals = node.portals or {}

    for _, entity in ipairs(portalEntities) do
        local cf = entity.customFields or {}
        local portalId = cf.PortalID or 0

        local p = PortalDoor(
            portalId,
            cf.SpawnX or 196, cf.SpawnY or 116,
            cf.Conditions or {}, cf.BlockedDialog or "nokeys",
            entity.x, entity.y,
            entity.width, entity.height
        )
        p.targetNodeId = portals[portalId]
        printDebug("🌀 PortalDoor created — ID:", portalId, "→ node", tostring(p.targetNodeId))
    end
end
