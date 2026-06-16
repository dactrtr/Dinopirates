-- MapDrawer.lua
-- Renders the current procedural run graph (RunState.graph) onto an image context.
-- Style mirrors the old fixed-floor map: dithered/filled squares with a marker for the
-- current room. The legacy level*100+roomNumber floor grid has been removed.
--
-- LAYOUT: rooms are positioned straight from the grid cell MapGenerator assigned to each
-- node (node.coord). The generator builds the graph on a 2D grid so every edge connects
-- physically adjacent cells (no overlaps, no teleport-looking links), so the map just
-- reads those coordinates. A few nodes are added after generation without a coord —
-- visited secret rooms (portal-linked) and the revealed final room — and are placed
-- relative to a neighbour, nudged to the nearest free cell.

MapDrawer = {}

local DIRS = { "top", "right", "down", "left" }
local DIR_OFFSET = {
	right = {  1,  0 },
	left  = { -1,  0 },
	top   = {  0, -1 },
	down  = {  0,  1 },
}

-- Build a grid layout from the graph. Returns: cells (nodeId -> {col,row}), maxCol, maxRow,
-- and portalLinks (list of { secret = id, host = id }) so the map can draw the portal
-- connection a secret room has to its host (portals are not part of node.edges).
-- Cells are normalized so min col/row = 0.
local function buildLayout(g)
	local cells       = {}
	local occupied    = {}
	local portalLinks = {}
	local function key(c, r) return c .. "," .. r end

	-- Nearest free cell to (c,r), searched in expanding rings (only used for coord-less nodes).
	local function freeCellNear(c, r)
		if not occupied[key(c, r)] then return c, r end
		for radius = 1, 64 do
			for dc = -radius, radius do
				for dr = -radius, radius do
					if math.abs(dc) == radius or math.abs(dr) == radius then
						local nc, nr = c + dc, r + dr
						if not occupied[key(nc, nr)] then return nc, nr end
					end
				end
			end
		end
		return c, r
	end

	local function place(id, c, r)
		cells[id] = { c, r }
		occupied[key(c, r)] = id
	end

	-- A secret room is only shown once visited; every other node is always shown.
	local function placeable(node)
		if not node then return false end
		if node.isSecret then return node.visited == true end
		return true
	end

	-- Phase 1: every node with a generated grid coordinate (MapGenerator assigns one to
	-- main rooms AND to secret rooms — a free cell next to their host). Coords are unique
	-- per run, so no nudging is needed.
	for id = 1, #g do
		local node = g[id]
		if node and node.coord and placeable(node) then
			place(id, node.coord.col, node.coord.row)
		end
	end

	-- Phase 2: nodes without a coord (e.g. the revealed final room) — placed next to a
	-- placed neighbour via the connecting edge, nudged to the nearest free cell.
	local changed = true
	while changed do
		changed = false
		for id = 1, #g do
			local node = g[id]
			if node and not node.isSecret and not cells[id] and node.edges then
				for _, d in ipairs(DIRS) do
					local nid = node.edges[d]
					if nid and cells[nid] then
						local nc  = cells[nid]
						local off = DIR_OFFSET[d]
						-- d is the side of `node` facing the neighbour, so step from the
						-- neighbour back toward node = neighbour cell - offset(d).
						local c, r = freeCellNear(nc[1] - off[1], nc[2] - off[2])
						place(id, c, r)
						changed = true
						break
					end
				end
			end
		end
	end

	-- Phase 3 (fallback): a visited secret room with no coord (shouldn't normally happen)
	-- is anchored next to its portal host.
	local secretOffset = Config.Map.secretOffset
	for id = 1, #g do
		local node = g[id]
		if node and node.isSecret and node.visited and not cells[id] and node.portals then
			local hostId
			for _, h in pairs(node.portals) do hostId = h; break end
			local hc = hostId and cells[hostId]
			if hc then
				local c, r = freeCellNear(hc[1] + secretOffset.col, hc[2] + secretOffset.row)
				place(id, c, r)
			end
		end
	end

	-- Portal links: connect each placed visited secret room to its (placed) portal host,
	-- so the portal relationship is drawn even though it is not a cardinal edge.
	for id = 1, #g do
		local node = g[id]
		if node and node.isSecret and node.visited and cells[id] and node.portals then
			local hostId
			for _, h in pairs(node.portals) do hostId = h; break end
			if hostId and cells[hostId] then
				portalLinks[#portalLinks + 1] = { secret = id, host = hostId }
			end
		end
	end

	-- Normalize so min col/row = 0; compute bounds.
	local minCol, minRow = math.huge, math.huge
	for _, cell in pairs(cells) do
		if cell[1] < minCol then minCol = cell[1] end
		if cell[2] < minRow then minRow = cell[2] end
	end
	if minCol == math.huge then return cells, 0, 0 end

	local maxCol, maxRow = 0, 0
	for _, cell in pairs(cells) do
		cell[1] = cell[1] - minCol
		cell[2] = cell[2] - minRow
		if cell[1] > maxCol then maxCol = cell[1] end
		if cell[2] > maxRow then maxRow = cell[2] end
	end
	return cells, maxCol, maxRow, portalLinks
end

-- Draw the current run graph onto the provided image context.
-- @param targetImage: The Graphics.image to draw the map on
function MapDrawer.drawMap(targetImage)
	local g = RunState.graph
	if not g then return end

	local panel = Config.Map.panel
	local cells, maxCol, maxRow, portalLinks = buildLayout(g)

	-- Cell size fits the grid inside the panel, capped at maxCellSize.
	local colsCount = maxCol + 1
	local rowsCount = maxRow + 1
	local cellSize = math.min(panel.w / colsCount, panel.h / rowsCount)
	cellSize = math.min(cellSize, Config.Map.maxCellSize)
	cellSize = math.floor(cellSize)
	if cellSize < 1 then cellSize = 1 end

	-- Origin centers the grid within the panel.
	local gridW = colsCount * cellSize
	local gridH = rowsCount * cellSize
	local px = panel.x + math.floor((panel.w - gridW) / 2)
	local py = panel.y + math.floor((panel.h - gridH) / 2)

	local boxSize = cellSize - Config.Map.cellGap
	if boxSize < 1 then boxSize = 1 end

	local roomColor   = Config.Map.roomColor
	local markerColor = Config.Map.markerColor

	local function cellCenter(cell)
		return px + cell[1] * cellSize + cellSize / 2,
		       py + cell[2] * cellSize + cellSize / 2
	end
	local function boxOrigin(cell)
		return px + cell[1] * cellSize + math.floor((cellSize - boxSize) / 2),
		       py + cell[2] * cellSize + math.floor((cellSize - boxSize) / 2)
	end

	-- Phase 1: connection lines between adjacent rooms (deduped via id < neighborId).
	Graphics.pushContext(targetImage)
	Graphics.setLineWidth(Config.Map.lineWidth)
	for id = 1, #g do
		local node = g[id]
		local cell = cells[id]
		if node and cell and node.edges then
			for _, d in ipairs(DIRS) do
				local nid = node.edges[d]
				local neighborCell = nid and cells[nid]
				if neighborCell and id < nid then
					local neighbor = g[nid]
					Graphics.setColor(roomColor)
					if not (node.visited and neighbor and neighbor.visited) then
						Graphics.setDitherPattern(Config.Map.ditherAlpha, Graphics.image.kDitherTypeBayer8x8)
					end
					local x1, y1 = cellCenter(cell)
					local x2, y2 = cellCenter(neighborCell)
					Graphics.drawLine(x1, y1, x2, y2)
					Graphics.setColor(roomColor)  -- reset any dither to solid
				end
			end
		end
	end
	-- Portal links (secret room -> its host): always dithered, so a portal reads as a
	-- linked secret room rather than a duplicate box floating next to the predecessor.
	for _, link in ipairs(portalLinks) do
		local sc, hc = cells[link.secret], cells[link.host]
		if sc and hc then
			Graphics.setColor(roomColor)
			Graphics.setDitherPattern(Config.Map.ditherAlpha, Graphics.image.kDitherTypeBayer8x8)
			local x1, y1 = cellCenter(sc)
			local x2, y2 = cellCenter(hc)
			Graphics.drawLine(x1, y1, x2, y2)
			Graphics.setColor(roomColor)
		end
	end
	Graphics.popContext()

	-- Phase 2: room boxes on top.
	for id = 1, #g do
		local node = g[id]
		local cell = cells[id]
		if node and cell then
			local bx, by = boxOrigin(cell)
			Graphics.pushContext(targetImage)
			if id == RunState.currentNodeId then
				-- Current room: roomColor box with a contrasting markerColor center.
				Graphics.setColor(roomColor)
				Graphics.fillRect(bx, by, boxSize, boxSize)
				local innerSize = boxSize - 2
				if innerSize < 1 then innerSize = 1 end
				local inset = math.floor((boxSize - innerSize) / 2)
				Graphics.setColor(markerColor)
				Graphics.fillRect(bx + inset, by + inset, innerSize, innerSize)
			elseif node.visited then
				-- Visited room: solid roomColor box.
				Graphics.setColor(roomColor)
				Graphics.fillRect(bx, by, boxSize, boxSize)
			else
				-- In-graph, not visited: dithered roomColor box.
				Graphics.setColor(roomColor)
				Graphics.setDitherPattern(Config.Map.ditherAlpha, Graphics.image.kDitherTypeBayer8x8)
				Graphics.fillRect(bx, by, boxSize, boxSize)
			end
			Graphics.popContext()
		end
	end
end

-- Percent of the current run visited = visited non-secret nodes / total non-secret nodes.
-- Returns 0 if there is no graph or no non-secret nodes.
function MapDrawer.calculateMapPercent()
	local g = RunState.graph
	if not g then return 0 end

	local total, visited = 0, 0
	for id = 1, #g do
		local node = g[id]
		if node and not node.isSecret then
			total = total + 1
			if node.visited then visited = visited + 1 end
		end
	end
	if total == 0 then return 0 end
	return math.floor((visited / total) * 100)
end

return MapDrawer
