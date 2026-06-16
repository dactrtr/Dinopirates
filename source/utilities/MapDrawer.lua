-- MapDrawer.lua
-- Renders the current procedural run graph (RunState.graph) onto an image context.
-- Style mirrors the old fixed-floor map: dithered/filled squares with a white-box /
-- black-center marker for the current room. The legacy level*100+roomNumber floor grid
-- has been removed; the map now reflects the active per-run graph only.

MapDrawer = {}

-- Direction -> grid cell offset (col, row) used for directional grid embedding.
local DIR_OFFSET = {
	right = {  1,  0 },
	left  = { -1,  0 },
	top   = {  0, -1 },
	down  = {  0,  1 },
}

-- Build a grid layout from the graph via directional grid embedding (spec section 1).
-- Returns: cells (nodeId -> {col, row}), maxCol, maxRow. Cells are normalized so min
-- col/row = 0. Secret nodes are only placed if visited (offset from their portal host).
local function buildLayout(g)
	local cells = {}

	-- BFS from startId over edges, skipping secret nodes.
	local queue = {}
	local head = 1
	if g.startId and g[g.startId] and not g[g.startId].isSecret then
		cells[g.startId] = { 0, 0 }
		queue[#queue + 1] = g.startId
	end

	while head <= #queue do
		local nodeId = queue[head]
		head = head + 1
		local node = g[nodeId]
		local cell = cells[nodeId]
		if node and node.edges and cell then
			for dir, neighborId in pairs(node.edges) do
				local neighbor = g[neighborId]
				local offset = DIR_OFFSET[dir]
				if neighbor and offset and not neighbor.isSecret and not cells[neighborId] then
					cells[neighborId] = { cell[1] + offset[1], cell[2] + offset[2] }
					queue[#queue + 1] = neighborId
				end
			end
		end
	end

	-- Lay out visited secret nodes at their portal host's cell + secretOffset.
	local secretOffset = Config.Map.secretOffset
	for id = 1, #g do
		local node = g[id]
		if node and node.isSecret and node.visited and not cells[id] then
			local hostId = nil
			if node.portals then
				for _, h in pairs(node.portals) do
					hostId = h
					break
				end
			end
			local hostCell = hostId and cells[hostId]
			if hostCell then
				cells[id] = { hostCell[1] + secretOffset.col, hostCell[2] + secretOffset.row }
			end
		end
	end

	-- Normalize so the minimum col/row is 0; compute bounds.
	local minCol, minRow = math.huge, math.huge
	for _, cell in pairs(cells) do
		if cell[1] < minCol then minCol = cell[1] end
		if cell[2] < minRow then minRow = cell[2] end
	end
	if minCol == math.huge then
		return cells, 0, 0
	end

	local maxCol, maxRow = 0, 0
	for _, cell in pairs(cells) do
		cell[1] = cell[1] - minCol
		cell[2] = cell[2] - minRow
		if cell[1] > maxCol then maxCol = cell[1] end
		if cell[2] > maxRow then maxRow = cell[2] end
	end

	return cells, maxCol, maxRow
end

-- Draw the current run graph onto the provided image context.
-- @param targetImage: The Graphics.image to draw the map on
function MapDrawer.drawMap(targetImage)
	local g = RunState.graph
	if not g then
		return
	end

	local panel = Config.Map.panel
	local cells, maxCol, maxRow = buildLayout(g)

	-- Compute cell size to fit the (maxCol+1) x (maxRow+1) grid inside the panel,
	-- capped at maxCellSize.
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

	-- Box size (inset within its cell by cellGap).
	local boxSize = cellSize - Config.Map.cellGap
	if boxSize < 1 then boxSize = 1 end

	-- Center of a cell (used for edge lines).
	local function cellCenter(cell)
		local cx = px + cell[1] * cellSize + cellSize / 2
		local cy = py + cell[2] * cellSize + cellSize / 2
		return cx, cy
	end
	-- Top-left of a box, centered within its cell.
	local function boxOrigin(cell)
		local bx = px + cell[1] * cellSize + math.floor((cellSize - boxSize) / 2)
		local by = py + cell[2] * cellSize + math.floor((cellSize - boxSize) / 2)
		return bx, by
	end

	local roomColor = Config.Map.roomColor
	local markerColor = Config.Map.markerColor

	-- Phase 1: draw edges between placed neighbors (only id < neighborId to avoid dupes).
	Graphics.pushContext(targetImage)
	Graphics.setLineWidth(Config.Map.lineWidth)
	for id = 1, #g do
		local node = g[id]
		local cell = cells[id]
		if node and cell and node.edges then
			for _, neighborId in pairs(node.edges) do
				local neighborCell = cells[neighborId]
				if neighborCell and id < neighborId then
					local neighbor = g[neighborId]
					local x1, y1 = cellCenter(cell)
					local x2, y2 = cellCenter(neighborCell)
					if node.visited and neighbor and neighbor.visited then
						Graphics.setColor(roomColor)
						Graphics.drawLine(x1, y1, x2, y2)
					else
						Graphics.setColor(roomColor)
						Graphics.setDitherPattern(Config.Map.ditherAlpha, Graphics.image.kDitherTypeBayer8x8)
						Graphics.drawLine(x1, y1, x2, y2)
						Graphics.setColor(roomColor)
					end
				end
			end
		end
	end
	Graphics.popContext()

	-- Phase 2: draw node boxes on top.
	for id = 1, #g do
		local node = g[id]
		local cell = cells[id]
		if node and cell then
			local bx, by = boxOrigin(cell)
			Graphics.pushContext(targetImage)
			if id == RunState.currentNodeId then
				-- Current room: roomColor outer box with a contrasting markerColor center.
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
	if not g then
		return 0
	end

	local total = 0
	local visited = 0
	for id = 1, #g do
		local node = g[id]
		if node and not node.isSecret then
			total = total + 1
			if node.visited then
				visited = visited + 1
			end
		end
	end

	if total == 0 then
		return 0
	end

	return math.floor((visited / total) * 100)
end

return MapDrawer
