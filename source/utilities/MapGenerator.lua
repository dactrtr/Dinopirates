-- MapGenerator: builds a per-run graph of room nodes from the pool of LDtk
-- templates. Single pass, no retries: a guaranteed solution path is built first,
-- then optional loop edges are added. Nodes reference templates by value (never
-- deep-copied); per-run data lives in node.content / node.cleared.
MapGenerator = {}

-- Cardinal door directions and their opposites (a "right" door must meet a "left").
local OPPOSITE = { right = "left", left = "right", top = "down", down = "top" }
local DIRS = { "right", "left", "top", "down" }
-- Grid cell offset per direction. The graph is laid out on a 2D grid as it is built so
-- that every edge connects two physically adjacent rooms — a "right" door always leads to
-- the room one cell to the right. This guarantees the run map embeds with no overlaps and
-- no illogical (teleport-looking) connections.
local DIR_OFFSET = { right = { 1, 0 }, left = { -1, 0 }, top = { 0, -1 }, down = { 0, 1 } }

-- Normalize a DoorsConnection entry ("Top"/"Down"/"Left"/"Right") to a lowercase dir.
local function normDir(name)
	if type(name) ~= "string" then return nil end
	local d = name:lower()
	if OPPOSITE[d] then return d end
	return nil
end

-- Returns the set of cardinal door sides a template actually has, read from its
-- authored LDtk door entities (not the room-level DoorsConnection array). This makes
-- a side connectable only when a real, reachable door exists there — "door to door".
local function doorSidesOf(template)
	local sides = {}
	local entities = template.entities or {}
	local doors = entities.Doors
	if doors then
		for _, de in ipairs(doors) do
			local connName = de.customFields and de.customFields.DoorsConnection
			local d = normDir(connName)
			if d then sides[d] = true end
		end
	end
	return sides
end

-- Returns how many doors each cardinal side has, as { [dir] = count }, from the
-- authored LDtk door entities. Two sides connect only when their counts match.
local function doorCountsOf(template)
	local counts = {}
	local entities = template.entities or {}
	local doors = entities.Doors
	if doors then
		for _, de in ipairs(doors) do
			local connName = de.customFields and de.customFields.DoorsConnection
			local d = normDir(connName)
			if d then counts[d] = (counts[d] or 0) + 1 end
		end
	end
	return counts
end

-- Resolve a room template by its LDtk identifier (e.g. "Room_3"). Used to pull in the
-- destination of a PortalDoor; secret rooms are procGen=false so they aren't in the pool.
local function templateByIdentifier(identifier)
	for _, tmpl in ipairs(levelsLDTK or {}) do
		if tmpl.identifier == identifier then
			return tmpl
		end
	end
	return nil
end

-- Collect generic spawn markers of a given LDtk entity key from a template.
-- Returns a list of { x=, y=, customFields= } (positions only; identity is assigned
-- by the generator, not authored).
local function markersOf(template, entityKey)
	local out = {}
	local entities = template.entities or {}
	local list = entities[entityKey]
	if list then
		for _, e in ipairs(list) do
			table.insert(out, { x = e.x, y = e.y, customFields = e.customFields or {} })
		end
	end
	return out
end

-- Expose for content placement / scene spawning.
MapGenerator.markersOf = markersOf

-- Whether a template's room renders dark (shadow FX).
local function isDarkTemplate(template)
	return (template.customFields and template.customFields.shadow) == true
end

-- Whether a template's tilemap contains any hole tile (IntGrid hole value).
local function hasHolesTemplate(template)
	local tileIndex = template.customFields and template.customFields.tile
	local map = tileIndex and tileMapData and tileMapData[tileIndex]
	if not map then return false end
	local holeValue = Config.Tiles.IntGrid.hole
	for y = 1, #map do
		local row = map[y]
		for x = 1, #row do
			if row[x] == holeValue then return true end
		end
	end
	return false
end

-- True when the player owns every entry in `req` (an LDtk array of names) inside the
-- given PlayerData sub-table. Matching is case-insensitive on both sides, since LDtk
-- enums are PascalCase ("HasLamp") while PlayerData keys are camelCase ("hasLamp").
-- nil/empty req → true.
local function ownsAll(req, ownedTable)
	if not req then return true end
	local owned = ownedTable or {}
	for _, raw in ipairs(req) do
		local want = tostring(raw):lower()
		local has = false
		for key, val in pairs(owned) do
			if val == true and key:lower() == want then has = true; break end
		end
		if not has then return false end
	end
	return true
end

-- A room qualifies only when the player meets BOTH its item and skill requirements.
-- LDtk fields (each an Array of names, case-insensitive, also accept PascalCase):
--   requiredItems  → PlayerData.items  (e.g. {"HasLamp"})
--   requiredSkills → PlayerData.skills (e.g. {"canDance"})
-- Rooms whose requirements aren't met are excluded from the pool, so the player never
-- enters a room they can't get through.
local function meetsRequirements(template)
	local cf = template.customFields
	if not cf then return true end
	return ownsAll(cf.requiredItems  or cf.RequiredItems,  PlayerData.items)
	   and ownsAll(cf.requiredSkills or cf.RequiredSkills, PlayerData.skills)
end

-- Build the pool from levelsLDTK, grouped by role. A room qualifies only when it is a
-- procGen room AND the player meets its item requirements.
-- Returns { start = {...}, normal = {...}, final = {...}, startdown = {...}, startup = {...} }.
function MapGenerator.buildPool()
	local pool = { start = {}, normal = {}, final = {}, startdown = {}, startup = {} }
	for _, tmpl in ipairs(levelsLDTK or {}) do
		local cf = tmpl.customFields or {}
		if cf.procGen == true and meetsRequirements(tmpl) then
			local role = (cf.roomRole or "normal"):lower()  -- LDtk enum is capitalized
			if pool[role] then
				table.insert(pool[role], tmpl)
			end
		end
	end
	return pool
end

-- Opposite of a cardinal direction (exposed for scene spawn logic).
function MapGenerator.opposite(dir)
	return OPPOSITE[dir]
end

-- Find a template's authored door entity for a given cardinal side, or nil.
function MapGenerator.doorEntityForSide(template, side)
	local entities = template.entities or {}
	local doors = entities.Doors
	if not doors then return nil end
	for _, de in ipairs(doors) do
		local connName = de.customFields and de.customFields.DoorsConnection
		if connName and connName:lower() == side then return de end
	end
	return nil
end

-- All authored door entities on a given cardinal side (a side may have several).
function MapGenerator.doorsForSide(template, side)
	local out = {}
	local entities = template.entities or {}
	local doors = entities.Doors
	if doors then
		for _, de in ipairs(doors) do
			local connName = de.customFields and de.customFields.DoorsConnection
			if connName and connName:lower() == side then table.insert(out, de) end
		end
	end
	return out
end

-- A side's connection axis: top/down doors line up along X (width); left/right
-- doors line up along Y (height). The position on the connection axis itself is
-- ignored (one door sits at a room edge, its partner at the opposite edge).
local function sideIsVertical(side)
	return side == "top" or side == "down"
end

-- Per-template, per-side door "signature": a canonical string of "pos:size" slots
-- sorted along the side's matching axis. Two opposite sides connect only when their
-- signatures are identical, i.e. every door lines up in position AND size. Memoized
-- because templates never change across runs.
local sideSigCache = {}
local function doorSlotsSig(template, side)
	local byDir = sideSigCache[template]
	if byDir and byDir[side] ~= nil then return byDir[side] end
	if not byDir then byDir = {}; sideSigCache[template] = byDir end

	local vertical = sideIsVertical(side)
	local slots = {}
	for _, de in ipairs(MapGenerator.doorsForSide(template, side)) do
		local pos  = vertical and de.x or de.y
		local size = vertical and de.width or de.height
		slots[#slots + 1] = { pos = pos, size = size }
	end
	table.sort(slots, function(a, b)
		if a.pos == b.pos then return a.size < b.size end
		return a.pos < b.pos
	end)
	local parts = {}
	for _, s in ipairs(slots) do parts[#parts + 1] = s.pos .. ":" .. s.size end

	local sig = table.concat(parts, ",")
	byDir[side] = sig
	return sig
end

-- Two opposite sides connect only when their door signatures match exactly.
local function sidesMatch(templA, dirA, templB)
	return doorSlotsSig(templA, dirA) == doorSlotsSig(templB, OPPOSITE[dirA])
end

-- Create an empty node wrapping a template. doorCounts records how many doors each
-- side has; two sides connect only when their door signatures match (see generate).
local function makeNode(id, template)
	local counts = doorCountsOf(template)
	local free = {}
	for dir in pairs(counts) do free[dir] = true end
	return {
		id         = id,
		poolRoom   = template,   -- reference, never copied
		edges      = {},         -- dir -> destination node id (whole side -> one room)
		doorCounts = counts,     -- dir -> number of doors on that side
		freeSides  = free,       -- dir -> true while still unconnected
		content    = { crewId = nil, enemies = {}, items = {}, utility = nil, isFinal = false },
		cleared    = {},         -- runtime deltas on revisit
	}
end

-- Pick a random element from a list (returns nil if empty).
local function pickRandom(list)
	if #list == 0 then return nil end
	return list[math.random(1, #list)]
end

-- Connect a.dir <-> b.opposite(dir), consuming a free side on both.
local function connect(a, b, dir)
	local opp = OPPOSITE[dir]
	a.edges[dir] = b.id
	b.edges[opp] = a.id
	a.freeSides[dir] = nil
	b.freeSides[opp] = nil
end

-- Build the run graph for a given progress value.
function MapGenerator.generate(progress, entryRole)
	progress = progress or 0
	local cfg = Config.MapGen
	local N = math.min(cfg.roomsMax,
	                   cfg.roomsBase + math.floor(progress / cfg.crewPerExtraRoom))

	-- Rooms don't repeat while the player is sane; once they've gone mad at least once
	-- (sanityCounter > 0) repeats are allowed (also helps when the pool is small).
	local allowRepeats = ((PlayerData.sanityCounter or 0) > 0)

	local pool = MapGenerator.buildPool()
	local graph = {}
	local used = {}  -- templates already placed (avoid repeats while sane)

	-- Grid bookkeeping: each placed node gets a (col,row) cell. occupied maps a cell key
	-- to the node id that owns it, so rooms never overlap and loops only form between
	-- physically adjacent cells.
	local occupied = {}
	local function cellKey(c, r) return c .. "," .. r end
	local function setCoord(node, c, r)
		node.coord = { col = c, row = r }
		occupied[cellKey(c, r)] = node.id
	end

	-- 1) Start node. entryRole picks the entry room kind ("startdown" after a hole,
	--    "startup" after a tube); defaults to the normal "start".
	local startKind = (entryRole and entryRole:lower()) or "start"
	local startTemplate = pickRandom(pool[startKind]) or pickRandom(pool.start) or pickRandom(pool.normal)
	assert(startTemplate, "MapGenerator: pool has no start/normal rooms (need procGen rooms)")
	local nextId = 1
	local startNode = makeNode(nextId, startTemplate)
	graph[nextId] = startNode
	graph.startId = nextId
	used[startTemplate] = true
	setCoord(startNode, 0, 0)
	nextId += 1

	-- Per-run guarantee: include at least one dark room and one room with holes.
	local isDark, hasHole = {}, {}
	for _, t in ipairs(pool.normal) do
		isDark[t]  = isDarkTemplate(t)
		hasHole[t] = hasHolesTemplate(t)
	end
	local placedDark = isDarkTemplate(startTemplate)
	local placedHole = hasHolesTemplate(startTemplate)

	-- 2) Guaranteed solution path: extend from a node that still has a free side,
	--    attaching a normal room whose opposite side is free.
	local frontier = { startNode }
	while #graph < N do
		-- Find a placed node with a free side whose adjacent grid cell is still EMPTY, so the
		-- new room occupies a real, unoccupied neighbour cell. Free sides pointing at an
		-- already-occupied cell are left for the loop pass (or become wall plugs).
		local fromNode, fromDir, tCol, tRow
		for _, node in ipairs(frontier) do
			local nc = node.coord
			for _, d in ipairs(DIRS) do
				if node.freeSides[d] then
					local off = DIR_OFFSET[d]
					local cc, rr = nc.col + off[1], nc.row + off[2]
					if not occupied[cellKey(cc, rr)] then
						fromNode, fromDir, tCol, tRow = node, d, cc, rr
						break
					end
				end
			end
			if fromNode then break end
		end
		if not fromNode then break end  -- nowhere empty to grow; stop early

		-- candidate must match the from-side's door signature on its opposite side, so
		-- every door lines up in count, position and size ("door to door").
		local candidates = {}
		for _, tmpl in ipairs(pool.normal) do
			if sidesMatch(fromNode.poolRoom, fromDir, tmpl) then table.insert(candidates, tmpl) end
		end
		-- Prefer rooms not used yet this run, unless repeats are allowed or none are free.
		if not allowRepeats then
			local fresh = {}
			for _, tmpl in ipairs(candidates) do
				if not used[tmpl] then table.insert(fresh, tmpl) end
			end
			if #fresh > 0 then candidates = fresh end
		end
		-- Bias toward a still-missing required feature (a dark room or a hole room).
		local needFeature = (not placedDark and "dark") or (not placedHole and "hole") or nil
		if needFeature then
			local biased = {}
			for _, tmpl in ipairs(candidates) do
				if (needFeature == "dark" and isDark[tmpl]) or (needFeature == "hole" and hasHole[tmpl]) then
					table.insert(biased, tmpl)
				end
			end
			if #biased > 0 then candidates = biased end
		end
		local tmpl = pickRandom(candidates)
		if not tmpl then
			-- no template can satisfy this side; burn it so we don't loop forever
			fromNode.freeSides[fromDir] = nil
		else
			local node = makeNode(nextId, tmpl)
			graph[nextId] = node
			connect(fromNode, node, fromDir)
			setCoord(node, tCol, tRow)
			table.insert(frontier, node)
			used[tmpl] = true
			if isDark[tmpl] then placedDark = true end
			if hasHole[tmpl] then placedHole = true end
			nextId += 1
		end
	end

	-- 3) Loops: connect a free side ONLY to the room that physically sits in the adjacent
	--    grid cell (and only if its opposite side is free and signature-compatible). This
	--    is what keeps the map logical — a loop edge is always between neighbouring cells,
	--    never a teleport across the run. Free sides with no adjacent match stay open and
	--    become wall plugs.
	local placed = {}
	for i = 1, #graph do placed[i] = graph[i] end
	for _, a in ipairs(placed) do
		local ac = a.coord
		for _, d in ipairs(DIRS) do
			if a.freeSides[d] and ac and not a.edges[d] then
				local off = DIR_OFFSET[d]
				local bid = occupied[cellKey(ac.col + off[1], ac.row + off[2])]
				local b = bid and graph[bid]
				local opp = OPPOSITE[d]
				if b and b ~= a and b.freeSides[opp]
					and sidesMatch(a.poolRoom, d, b.poolRoom) then
					connect(a, b, d)
				end
			end
		end
	end

	-- Post-pass guarantee: if the run still lacks a dark or hole room, swap a placed
	-- normal node for one with the same door layout (keeps connectivity intact). The
	-- replacement must match every side's door signature, not just door counts.
	local function sameDoorCounts(a, b)
		for _, d in ipairs(DIRS) do
			if doorSlotsSig(a, d) ~= doorSlotsSig(b, d) then return false end
		end
		return true
	end
	local swapped = {}
	local function ensureFeature(present, wanted, other)
		if present then return end
		for id = 1, #graph do
			local node = graph[id]
			if id ~= graph.startId and not swapped[id] and not other(node.poolRoom) then
				for _, t in ipairs(pool.normal) do
					if wanted(t) and sameDoorCounts(node.poolRoom, t) then
						node.poolRoom = t
						swapped[id] = true
						return
					end
				end
			end
		end
	end
	ensureFeature(placedDark, function(t) return isDark[t] end, function(t) return hasHole[t] end)
	ensureFeature(placedHole, function(t) return hasHole[t] end, function(t) return isDark[t] end)

	-- 3.5) Secret rooms via PortalDoors. Portals are NOT part of side-connectivity: each
	-- portal in a placed room pulls in its destination room as a separate node, linked by
	-- PortalID in both directions (A<->A). Gating (e.g. isTiny) stays in the portal's
	-- Conditions and is enforced at touch time. Snapshot the count first so we only scan
	-- the connectivity nodes, not the secret nodes we're adding.
	local secretByIdentifier = {}  -- room identifier -> nodeId (a secret room is one shared node)
	local mainCount = #graph
	for hid = 1, mainCount do
		local host = graph[hid]
		host.portals = host.portals or {}
		local portals = host.poolRoom.entities and host.poolRoom.entities.PortalDoors
		if portals then
			for _, pd in ipairs(portals) do
				local cf = pd.customFields or {}
				local pid = cf.PortalID
				local destIdentifier = cf.DestRoom
				local destTmpl = destIdentifier and templateByIdentifier(destIdentifier)
				if pid and destTmpl then
					local secretId = secretByIdentifier[destIdentifier]
					if not secretId then
						secretId = #graph + 1
						local snode = makeNode(secretId, destTmpl)
						snode.isSecret = true
						snode.portals  = {}
						graph[secretId] = snode
						secretByIdentifier[destIdentifier] = secretId
					end
					host.portals[pid] = secretId
					graph[secretId].portals[pid] = hid
				end
			end
		end
	end

	-- 4) Per-node content: roll which enemies and utilities are active this run,
	--    reusing the rooms' existing authored entities as spawn markers.
	for id = 1, #graph do
		local node = graph[id]
		local ents = node.poolRoom.entities or {}
		for _, kind in ipairs({ "Brocorat", "Bosscolli" }) do
			for _, e in ipairs(ents[kind] or {}) do
				local force = e.customFields and e.customFields.forceSpawn
				if force or math.random() < cfg.enemyChance then
					table.insert(node.content.enemies, {
						x = e.x, y = e.y, kind = kind,
						speed = e.customFields and e.customFields.speed,
						key = id .. ":" .. (e.iid or ("e" .. #node.content.enemies)),
					})
				end
			end
		end
		node.content.utilities = {}
		-- A room with a "small door" (any door with a 16px side) needs the player tiny to
		-- pass, so force its minifier(s) to appear regardless of the utility roll.
		local hasSmallDoor = false
		for _, de in ipairs(ents.Doors or {}) do
			if de.width == 16 or de.height == 16 then hasSmallDoor = true; break end
		end
		for _, kind in ipairs({ "Microwave", "Minifier" }) do
			for _, e in ipairs(ents[kind] or {}) do
				local force = (kind == "Minifier" and hasSmallDoor) or (e.customFields and e.customFields.forceSpawn)
				if e.iid and (force or math.random() < cfg.utilityChance) then
					node.content.utilities[e.iid] = true
				end
			end
		end
	end

	-- Crew: assign uncollected roster members (CMxxx) to eligible nodes. LDtk CrewMember
	-- entities are generic spawn markers; the generator picks which identity appears.
	local takenIds = (PlayerData.CrewMemberData and PlayerData.CrewMemberData.idNumbers) or {}
	local uncollected = {}
	for i = 1, cfg.totalCrew do
		local crewId = string.format("CM%03d", i)
		if not takenIds[crewId] then table.insert(uncollected, crewId) end
	end
	local eligible = {}
	for id = 1, #graph do
		local node = graph[id]
		if id ~= graph.startId and not node.isSecret and #markersOf(node.poolRoom, "CrewMember") > 0 then
			table.insert(eligible, node)
		end
	end
	for i = #eligible, 2, -1 do
		local j = math.random(1, i)
		eligible[i], eligible[j] = eligible[j], eligible[i]
	end
	local nCrew = math.min(math.ceil(#graph / cfg.roomsPerCrewSpawn), #uncollected, #eligible)
	for i = 1, nCrew do
		local node = eligible[i]
		local crewId = table.remove(uncollected, math.random(1, #uncollected))
		local markers = markersOf(node.poolRoom, "CrewMember")
		local mk = markers[math.random(1, #markers)]
		node.content.crewId = crewId
		node.content.crewSpawn = { x = mk.x, y = mk.y }
	end

	graph.finalReserved = nil  -- set when the final room is revealed (RunState.revealFinalRoom)
	return graph
end

-- Debug invariant check: generates a graph at a given progress and asserts that
-- every node is reachable from the start and every edge is bidirectional.
-- Prints a summary via printDebug. Returns true on success.
function MapGenerator.selfCheck(progress)
	local graph = MapGenerator.generate(progress or 0)

	-- bidirectional edge check
	for id = 1, #graph do
		local node = graph[id]
		for dir, destId in pairs(node.edges) do
			local opp = ({ right="left", left="right", top="down", down="top" })[dir]
			local dest = graph[destId]
			assert(dest, "edge to missing node " .. tostring(destId))
			assert(dest.edges[opp] == id,
			       "non-bidirectional edge " .. id .. "->" .. destId .. " dir " .. dir)
		end
	end

	-- reachability (BFS from start)
	local seen = { [graph.startId] = true }
	local queue = { graph.startId }
	while #queue > 0 do
		local id = table.remove(queue, 1)
		for _, destId in pairs(graph[id].edges) do
			if not seen[destId] then seen[destId] = true; table.insert(queue, destId) end
		end
	end
	local reached = 0
	for _ in pairs(seen) do reached += 1 end
	assert(reached == #graph,
	       "unreachable nodes: reached " .. reached .. " of " .. #graph)

	printDebug("✅ MapGenerator.selfCheck OK — nodes:" .. #graph .. " progress:" .. (progress or 0))
	return true
end

return MapGenerator
