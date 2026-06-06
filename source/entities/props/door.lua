Door = {}
class('Door').extends(NobleSprite)

local animationStates = {
  normalClosed = 18,
  reverseClosed = 9,
  normalOpen = 10,
  reverseOpen = 1
}

local positions = Config.Doors.positions

local function setRectValues(direction)
  local rectValues = {
    right = {0, 0, 16, 50},
    left = {0, 0, 14, 50},
    down = {0, 0, 50, 16},
    top = {0, 0, 50, 16},
  }
  return table.unpack(rectValues[direction])
end

function Door:init(direction, status, targetNodeId, zIndex, keyNumber, x, y, width, height)

  self.targetNodeId = targetNodeId
  self.direction = direction
  self.status = status
  self.keyNumber = keyNumber  -- Store the required key number
  
  local isHorizontal = direction == 'top' or direction == 'down'
  -- local asset = isHorizontal and 'assets/images/props/door-horizontal' or 'assets/images/props/door-vertical'
  local sizeX = width or (isHorizontal and 56 or 10)
  local sizeY = height or (isHorizontal and 10 or 56)
  
  local rectX, rectY, rectW, rectH
  if width and height then
    rectX, rectY, rectW, rectH = 0, 0, width, height
  else
    rectX, rectY, rectW, rectH = setRectValues(direction)
  end

  Door.super.init(self, asset, true)
  self:setSize(sizeX, sizeY)
  self:setCollideRect(rectX, rectY, rectW, rectH)

  -- for state, frame in pairs(animationStates) do
  --   self.animation:addState(state, frame, frame)
  --   self.animation[state].frameDuration = 12
  -- end

  local isNormal = direction == 'top' or direction == 'right'
  local statePrefix = isNormal and 'normal' or 'reverse'
  -- self.animation:setState(statePrefix .. (status == 'closed' and 'Closed' or 'Open'))
  

  local position = positions[direction]
  self:setZIndex(zIndex)
  self:setGroups(3)
  
  -- Use provided LDTK coordinates if available, otherwise fallback to hardcoded positions
  local finalX = x or position.x
  local finalY = y or position.y

  self.posX = finalX
  self.posY = finalY

  self:add(finalX, finalY)
end

function Door:goTo()
  -- Remember which door we used (cross-axis position) so the destination room can
  -- spawn the player at the matching door. Top/down doors vary in x; left/right in y.
  if self.direction == "top" or self.direction == "down" then
    PlayerData.lastDoorCross = self.posX
  else
    PlayerData.lastDoorCross = self.posY
  end
  RunState.goTo(self.targetNodeId)
  Noble.transition(MazeScene, 1.5, Noble.Transition.Default)
end

function Door:prevRoom(direction, playerX, playerY)
    PlayerData.lastRoom = direction
    local sc = Config.Doors.spawnCoords
    local spawnCoordinates = {
        top   = {x = playerX or sc.top.x,   y = sc.top.y  },
        down  = {x = playerX or sc.down.x,  y = sc.down.y },
        right = {x = sc.right.x, y = playerY or sc.right.y},
        left  = {x = sc.left.x,  y = playerY or sc.left.y },
    }
    PlayerData.playerSpawn.x = spawnCoordinates[direction].x
    PlayerData.playerSpawn.y = spawnCoordinates[direction].y
end

function Door:collisionResponse(other)
  -- no use
	-- if other.type == "player" then
	-- 	if self.isOpen then
	-- 		-- Save current state before transition
	-- 		Noble.transition(MazeScene, {
	-- 			nextLevel = self.nextLevel,
	-- 			nextRoom = self.nextRoom,
	-- 			enterDoor = self.doorID,
	-- 			playerData = other:getPlayerData()
	-- 		},0.3, Noble.Transition.MetroNexus)  
	-- 	end
	-- end
	return "overlap"
end

-- ============================================================================
-- LEGACY (removed): doors connected by neighbourLevels / fixed floor grid
-- ----------------------------------------------------------------------------
-- BEFORE: rooms were a fixed authored grid. CreateDoorsFromLDTK(currentRoom)
-- read each Doors entity, mapped its LDtk direction to a side, found the
-- neighbour room, and computed the destination roomNumber, so every door led to
-- a predetermined room. Helpers it relied on (all removed with it):
--   FindRoomByIid(iid)                        -- O(1) room lookup via roomsByIid
--   ConvertLDTKDirection(dir)                 -- ">"/"<"/n/s/e/w → top/down/left/right
--   CalculateLeadsTo(lvl, room, dir, neighbor)-- destination roomNumber (incl. stairs)
-- Doors also honoured NeedsKey / KeyNumber against PlayerData.keys.
--
-- NOW: doors come from the procedural run graph. MazeScene calls
-- CreateDoorsFromNode(node) (below): a door is built only on sides the graph
-- connected (node.edges), matched by door SIGNATURE (count + position + size).
-- Unconnected sides are covered by CreateWallPlugsFromNode; secret/vertical exits
-- by CreatePortalsFromNode. Keys are stripped in procedural mode. neighbourLevels,
-- DoorsConnection and roomNumber-based leadsTo are no longer read at runtime.
--
-- LOVE2D PORT: to ship classic fixed-grid doors instead of procedural ones, the
-- removed CreateDoorsFromLDTK + helpers are the reference implementation.
-- ============================================================================

-- WallPlug: covers an unconnected door opening with wall brick (stamped from the
-- tilesheet) and a wall collider, so closed doors look solid and can't be walked through.
local plugTilesheet = nil
local function plugBrickImage(tileIndex)
	if not plugTilesheet then
		plugTilesheet = Graphics.imagetable.new(Config.Doors.plug.tilesheet)
	end
	return plugTilesheet and plugTilesheet:getImage(tileIndex or 1)
end

class('WallPlug').extends(playdate.graphics.sprite)

function WallPlug:init(x, y, w, h, tileIndex)
	local tile = Config.Tiles.size
	local img  = Graphics.image.new(w, h)
	local brick = plugBrickImage(tileIndex)
	if brick then
		Graphics.pushContext(img)
			for ty = 0, h - 1, tile do
				for tx = 0, w - 1, tile do
					brick:draw(tx, ty)
				end
			end
		Graphics.popContext()
	end
	self:setImage(img)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(ZIndex.props)
	self:setCollideRect(0, 0, w, h)
	self:setGroups(CollideGroups.wall)
	self:addSprite()
end

-- For each authored door on a side the graph left UNCONNECTED, stamp a wall plug over
-- its opening. Span axis = door size + trim (1 tile up for side doors, 1 each side for
-- top/down); perpendicular axis = wall depth from the screen edge. Authored door x/y is
-- the entity centre.
function CreateWallPlugsFromNode(node)
	if not node or not node.poolRoom then return end
	local doors = node.poolRoom.entities and node.poolRoom.entities.Doors
	if not doors then return end

	local tile  = Config.Tiles.size
	local cfg   = Config.Doors.plug
	local trim  = (cfg.trimTiles  or 1) * tile
	local depth = (cfg.depthTiles or 1) * tile

	for _, de in ipairs(doors) do
		local conn = de.customFields and de.customFields.DoorsConnection
		local dir  = conn and conn:lower()
		if dir and not node.edges[dir] then
			local hw, hh = (de.width or 0) / 2, (de.height or 0) / 2
			local x, y, w, h
			if dir == "top" then
				x, w = de.x - hw - trim, de.width + 2 * trim
				y, h = 0, depth
			elseif dir == "down" then
				x, w = de.x - hw - trim, de.width + 2 * trim
				y, h = 240 - depth, depth
			elseif dir == "left" then
				x, w = 0, depth
				y, h = de.y - hh - trim, de.height + trim
			elseif dir == "right" then
				x, w = 400 - depth, depth
				y, h = de.y - hh - trim, de.height + trim
			end
			if x then WallPlug(x, y, w, h, cfg.tiles and cfg.tiles[dir]) end
		end
	end
end

-- Create door sprites from a run-graph node's edges. Each edge (dir -> destNodeId)
-- becomes an open door at the cardinal screen position; crossing it transitions to
-- that node. Keys are removed in procedural mode, so all doors are open.
function CreateDoorsFromNode(node)
	if not node then return end
	local template = node.poolRoom
	local positions = Config.Doors.positions
	local t, s = Config.Doors.thickness, Config.Doors.span

	-- Group the room's authored LDtk door entities by cardinal side. A side may have
	-- several doors (a multi-door interface); all of them lead to the same neighbour.
	local nameToDir = { top = "top", down = "down", left = "left", right = "right" }
	local doorsByDir = { top = {}, down = {}, left = {}, right = {} }
	local doorEntities = template.entities and template.entities.Doors
	if doorEntities then
		for _, de in ipairs(doorEntities) do
			local connName = de.customFields and de.customFields.DoorsConnection
			local dir = connName and nameToDir[connName:lower()]
			if dir then table.insert(doorsByDir[dir], de) end
		end
	end

	-- For each connected side, create a functional door for EVERY authored door on
	-- that side (all pointing to the same neighbour node). Fall back to a single
	-- generic thin door only if the template has no door entity for that side.
	for dir, destNodeId in pairs(node.edges) do
		local list = doorsByDir[dir]
		if list and #list > 0 then
			for _, de in ipairs(list) do
				Door(dir, "open", destNodeId, ZIndex.props, nil, de.x, de.y, de.width, de.height)
			end
		else
			local pos = positions[dir]
			if pos then
				local w, h
				if dir == "left" or dir == "right" then w, h = t, s else w, h = s, t end
				Door(dir, "open", destNodeId, ZIndex.props, nil, pos.x, pos.y, w, h)
			end
		end
	end
end