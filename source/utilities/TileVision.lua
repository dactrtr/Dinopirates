-- TileVision.lua
--
-- Line of sight over the tile grid, kept separate from Pathing.lua because the
-- pathfinder does not provide visibility queries. Pure Lua (no Playdate-only API),
-- so the Love2D port uses this file unchanged.
--
-- Interface:
--   HasLineOfSight(x1, y1, x2, y2) -> bool
--
-- Walks a Bresenham line over the tiles between the two WORLD points and returns
-- false as soon as it crosses a non-walkable tile (a wall blocks sight).

local TILE_SIZE = Config.Tiles.size

-- World pixel -> 1-based tile index (matches GetTileUnderPlayer in Utilities.lua).
local function worldToTile(coord)
    return math.floor(coord / TILE_SIZE) + 1
end

--- True if nothing blocks a straight line between the two world points.
-- @param x1,y1 number Source world position.
-- @param x2,y2 number Target world position.
-- @return boolean false if any tile along the line is non-walkable.
function HasLineOfSight(x1, y1, x2, y2)
    local floor = PlayerData.actualTilemap or 1
    local floorData = tileMapData[floor]
    if not floorData then
        return true  -- no tile data: fail open (don't block)
    end

    local tx0 = worldToTile(x1)
    local ty0 = worldToTile(y1)
    local tx1 = worldToTile(x2)
    local ty1 = worldToTile(y2)

    local dx = math.abs(tx1 - tx0)
    local dy = math.abs(ty1 - ty0)
    local stepX = tx0 < tx1 and 1 or -1
    local stepY = ty0 < ty1 and 1 or -1
    local err = dx - dy

    local x, y = tx0, ty0
    while true do
        -- Any wall tile between the endpoints breaks line of sight. The endpoints
        -- themselves are walkable (both actors stand on floor), so testing every
        -- visited tile is safe.
        local row = floorData[y]
        local tileValue = row and row[x]
        if not IsTileWalkable(tileValue) then
            return false
        end

        if x == tx1 and y == ty1 then
            break
        end

        local err2 = err * 2
        if err2 > -dy then
            err = err - dy
            x = x + stepX
        end
        if err2 < dx then
            err = err + dx
            y = y + stepY
        end
    end

    return true
end
