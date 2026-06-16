-- RunState: in-memory source of truth for the active procedural run.
-- Holds the generated graph, the current node, and a staging field used to pass
-- the destination node across a Noble scene transition (Noble re-instantiates the
-- scene, so we hand off the target via this global instead of constructor args).
RunState = {
	graph         = nil,  -- array of nodes (see MapGenerator); also has .startId / .finalReserved
	currentNodeId = nil,  -- node the player is currently in
	pendingNodeId = nil,  -- node a door transition is heading to; consumed on enter
}

-- Generate a fresh run from current progress (crew recruited). entryRole optionally
-- picks the entry room kind ("startdown" after a hole, "startup" after a tube).
function RunState.startRun(entryRole)
	local progress = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.amountTaken) or 0
	RunState.graph = MapGenerator.generate(progress, entryRole)
	RunState.currentNodeId = nil
	RunState.pendingNodeId = RunState.graph.startId
end

function RunState.getNode(id)
	if not RunState.graph then return nil end
	return RunState.graph[id]
end

function RunState.currentNode()
	return RunState.getNode(RunState.currentNodeId)
end

-- Move the "current" pointer to the pending destination (called when MazeScene enters).
function RunState.consumePending()
	if RunState.pendingNodeId then
		RunState.currentNodeId = RunState.pendingNodeId
		RunState.pendingNodeId = nil
	end
end

-- Queue a destination for the next transition.
function RunState.goTo(nodeId)
	RunState.pendingNodeId = nodeId
end

-- Attach the final room to the graph once the whole crew roster is recruited. Connects
-- a 'final'-role template to any node that still has a free door side; the new door
-- appears next time the player enters that node (entering the final room ends the run).
function RunState.revealFinalRoom()
	if not RunState.graph or RunState.graph.finalReserved then return end
	local OPP = { right = "left", left = "right", top = "down", down = "top" }
	local DIRS = { "right", "left", "top", "down" }
	local pool = MapGenerator.buildPool()
	local finalTemplate = pool.final and pool.final[1]
	if not finalTemplate then
		printDebug("⚠️ revealFinalRoom: no roomRole='final' template in pool")
		return
	end
	for id = 1, #RunState.graph do
		local host = RunState.graph[id]
		for _, d in ipairs(DIRS) do
			if host.freeSides and host.freeSides[d] then
				local newId = #RunState.graph + 1
				RunState.graph[newId] = {
					id = newId, poolRoom = finalTemplate, edges = { [OPP[d]] = id },
					doorCounts = {}, freeSides = {},
					content = { isFinal = true, enemies = {}, items = {}, utilities = {} },
					cleared = {},
				}
				host.edges[d] = newId
				host.freeSides[d] = nil
				RunState.graph.finalReserved = newId
				printDebug("🏁 Final room revealed as node " .. newId)
				return
			end
		end
	end
	printDebug("⚠️ revealFinalRoom: no free door side to attach the final room")
end

-- Clear the active run (used on delete / reset).
function RunState.clear()
	RunState.graph = nil
	RunState.currentNodeId = nil
	RunState.pendingNodeId = nil
end

-- Serialize the active run into a plain, datastore-safe table. Nodes store their
-- template by uniqueIdentifer (not the template table itself), since templates are
-- immutable and live in levelsLDTK. content/cleared/edges are plain data already.
function RunState.serialize()
	local g = RunState.graph
	if not g then return nil end
	local nodes = {}
	for i = 1, #g do
		local n = g[i]
		nodes[i] = {
			id         = n.id,
			roomUid    = n.poolRoom and n.poolRoom.uniqueIdentifer,
			edges      = n.edges,
			doorCounts = n.doorCounts,
			freeSides  = n.freeSides,
			content    = n.content,
			cleared    = n.cleared,
			portals    = n.portals,   -- PortalID -> node id (secret-room links, A<->A)
			isSecret   = n.isSecret,
			visited    = n.visited,
		}
	end
	return {
		currentNodeId = RunState.currentNodeId,
		startId       = g.startId,
		finalReserved = g.finalReserved,
		nodes         = nodes,
	}
end

-- Rebuild the active run from serialized data. Re-links each node's poolRoom from its
-- uniqueIdentifer against the live levelsLDTK templates, and stages currentNodeId as
-- pending so the next MazeScene:enter lands on it. Returns true on success.
function RunState.deserialize(data)
	if not data or not data.nodes then return false end

	local byUid = {}
	for _, tmpl in ipairs(levelsLDTK or {}) do
		if tmpl.uniqueIdentifer then byUid[tmpl.uniqueIdentifer] = tmpl end
	end

	local graph = {}
	for i = 1, #data.nodes do
		local sn = data.nodes[i]
		local template = sn.roomUid and byUid[sn.roomUid]
		if not template then
			printDebug("⚠️ RunState.deserialize: no template for uid " .. tostring(sn.roomUid))
			return false
		end
		graph[i] = {
			id         = sn.id or i,
			poolRoom   = template,
			edges      = sn.edges or {},
			doorCounts = sn.doorCounts or {},
			freeSides  = sn.freeSides or {},
			content    = sn.content or {},
			cleared    = sn.cleared or {},
			portals    = sn.portals or {},
			isSecret   = sn.isSecret,
			visited    = sn.visited,
		}
	end
	graph.startId       = data.startId
	graph.finalReserved = data.finalReserved

	RunState.graph         = graph
	RunState.currentNodeId = nil
	RunState.pendingNodeId = data.currentNodeId or data.startId
	return true
end

return RunState
