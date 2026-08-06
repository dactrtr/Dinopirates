-- Pathing.lua
--
-- Thin wrapper over the Playdate SDK's native A* pathfinder
-- (`playdate.pathfinder`). This is the ONLY file that touches the Playdate-only
-- pathfinder API, so the Love2D port reimplements JUST this module (a plain-Lua
-- A*/BFS) behind the same interface — everything else (perception, state machine)
-- ports unchanged.
--
-- Interface (stable contract for the port):
--   Pathing.rebuild(tileData)                         -- build the grid graph for a room
--   Pathing.stepToward(fromX, fromY, toX, toY) -> dx, dy  -- normalized first-hop direction (or nil)
--   Pathing.invalidate()                              -- drop graph + cache
--
-- Coordinates in stepToward are WORLD pixels; they are converted to tiles here.
-- The `playdate.pathfinder.graph.new2DGrid` grid assigns each node 0-based x,y
-- coordinates matching its column/row, so a 1-based tile (tx, ty) maps to node
-- coordinates (tx - 1, ty - 1).

Pathing = {}

local TILE_SIZE = Config.Tiles.size

-- Live graph for the current room, and the width/height it was built with.
local graph = nil
local gridWidth = 0
local gridHeight = 0

-- Path cache. `findPath` only recomputes when the target tile changes (or when the
-- enemy drifts off the stored path). Turn-based movement makes recompute rare.
local cachedPath = nil        -- array of pathfinder nodes (start .. goal)
local cachedToTileX = nil
local cachedToTileY = nil

-- World pixel -> 1-based tile index (matches GetTileUnderPlayer in Utilities.lua).
local function worldToTile(coord)
    return math.floor(coord / TILE_SIZE) + 1
end

--- Build the pathfinding graph for a room's tilemap.
-- @param tileData table 2D matrix tileData[y][x] of IntGrid values.
function Pathing.rebuild(tileData)
    Pathing.invalidate()

    if not tileData or not tileData[1] then
        return
    end

    gridHeight = #tileData
    gridWidth  = #tileData[1]

    -- includedNodes is a 1D array of length width*height, ordered by row
    -- (all of row 1, then row 2, ...). 1 = walkable node included, 0 = wall.
    local includedNodes = {}
    local i = 1
    for y = 1, gridHeight do
        local row = tileData[y]
        for x = 1, gridWidth do
            includedNodes[i] = IsTileWalkable(row[x]) and 1 or 0
            i = i + 1
        end
    end

    -- allowDiagonals = true (orthogonal cost 10, diagonal cost 14 come free).
    graph = playdate.pathfinder.graph.new2DGrid(gridWidth, gridHeight, true, includedNodes)
end

--- Drop the graph and any cached path.
function Pathing.invalidate()
    graph = nil
    gridWidth = 0
    gridHeight = 0
    cachedPath = nil
    cachedToTileX = nil
    cachedToTileY = nil
end

-- Returns the index of the node in cachedPath sitting at 0-based (nodeX, nodeY),
-- or nil if the path does not pass through that node.
local function indexOfNodeAt(nodeX, nodeY)
    if not cachedPath then return nil end
    for idx = 1, #cachedPath do
        local node = cachedPath[idx]
        if node.x == nodeX and node.y == nodeY then
            return idx
        end
    end
    return nil
end

--- Direction of the first hop of the shortest path from (fromX,fromY) to (toX,toY).
-- @return dirX, dirY each in {-1, 0, 1}; (0,0) when already on the target tile;
--         nil when no path exists (or no graph built).
function Pathing.stepToward(fromX, fromY, toX, toY)
    if not graph then
        return nil
    end

    local fromTileX = worldToTile(fromX)
    local fromTileY = worldToTile(fromY)
    local toTileX   = worldToTile(toX)
    local toTileY   = worldToTile(toY)

    if fromTileX == toTileX and fromTileY == toTileY then
        return 0, 0
    end

    -- 0-based node coordinates for the SDK grid.
    local fromNodeX = fromTileX - 1
    local fromNodeY = fromTileY - 1
    local toNodeX   = toTileX - 1
    local toNodeY   = toTileY - 1

    -- Reuse the cached path while the target tile is unchanged AND the enemy is
    -- still standing on a node the path passes through. Otherwise recompute.
    local hopIndex = nil
    if cachedPath and toTileX == cachedToTileX and toTileY == cachedToTileY then
        hopIndex = indexOfNodeAt(fromNodeX, fromNodeY)
    end

    if not hopIndex then
        local startNode = graph:nodeWithXY(fromNodeX, fromNodeY)
        local goalNode  = graph:nodeWithXY(toNodeX, toNodeY)
        if not startNode or not goalNode then
            cachedPath = nil
            cachedToTileX = nil
            cachedToTileY = nil
            return nil
        end

        local path = graph:findPath(startNode, goalNode)
        if not path or #path < 2 then
            cachedPath = nil
            cachedToTileX = nil
            cachedToTileY = nil
            return nil
        end

        cachedPath = path
        cachedToTileX = toTileX
        cachedToTileY = toTileY
        hopIndex = 1  -- path[1] is the start node the enemy stands on
    end

    -- The next node along the path is the hop to take.
    local nextNode = cachedPath[hopIndex + 1]
    if not nextNode then
        return 0, 0  -- already at the goal
    end

    local currentNode = cachedPath[hopIndex]
    local dx = nextNode.x - currentNode.x
    local dy = nextNode.y - currentNode.y

    local dirX = (dx > 0 and 1) or (dx < 0 and -1) or 0
    local dirY = (dy > 0 and 1) or (dy < 0 and -1) or 0
    return dirX, dirY
end

--- Debug accessor: the current cached path as a list of {x=tileX, y=tileY} (1-based),
-- or nil. Used only by the enemy debug overlay.
function Pathing.debugPath()
    if not cachedPath then return nil end
    local tiles = {}
    for idx = 1, #cachedPath do
        local node = cachedPath[idx]
        tiles[idx] = { x = node.x + 1, y = node.y + 1 }
    end
    return tiles
end
