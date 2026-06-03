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

-- MARK: Door Utility Functions

--- Finds a room by its uniqueIdentifer (iid)
-- Uses a hash index for O(1) search
-- @param iid string The uniqueIdentifer of the room to search for
-- @return table|nil The room data or nil if not found
function FindRoomByIid(iid)
	if not iid then
		printDebug("❌ iid is nil")
		return nil
	end
	
	-- Use hash index for fast O(1) search
	if roomsByIid and roomsByIid[iid] then
		printDebug("✅ Room found (hash):", roomsByIid[iid].identifier)
		return roomsByIid[iid]
	end
	
	-- Fallback: linear search if index is not available
	if not levelsLDTK then
		printDebug("❌ levelsLDTK is not initialized")
		return nil
	end
	
	printDebug("🔍 Searching room with iid (fallback):", iid)
	for i, room in ipairs(levelsLDTK) do
		if room and room.uniqueIdentifer == iid then
			printDebug("✅ Room found:", room.identifier)
			return room
		end
	end
	printDebug("❌ Room NOT found with iid:", iid)
	return nil
end

--- Converts LDTK direction to door direction
-- @param dir string LDTK direction
-- @return string Door direction
function ConvertLDTKDirection(dir)
	printDebug("🧭 Converting direction:", dir)
	local result
	if dir == ">" then
		result = "down"  -- Staircase up (visually at bottom of screen)
	elseif dir == "<" then
		result = "top"  -- Staircase down (visually at top of screen)
	elseif dir == "n" then
		result = "top"  -- Door up
	elseif dir == "s" then
		result = "down"  -- Door down
	elseif dir == "e" then
		result = "right"  -- Door right
	elseif dir == "w" or dir == "o" then
		result = "left"  -- Door left
	else
		result = dir
	end
	printDebug("   → Result:", result)
	return result
end

--- Calculates the destination room number based on direction
-- @param currentLevel number The current level (1, 2, 3...)
-- @param currentRoomNumber number The current room number (0-99)
-- @param direction string The LDTK direction (">", "<", "n", "s", "e", "w")
-- @param neighborRoom table|nil The neighbor data (optional for stairs)
-- @return number The complete destination room number (e.g. 220)
function CalculateLeadsTo(currentLevel, currentRoomNumber, direction, neighborRoom)
	printDebug("🎯 Calculating leadsTo:")
	printDebug("   Current Level:", currentLevel)
	printDebug("   Current Room:", currentRoomNumber)
	printDebug("   Direction:", direction)
	
	local fullCurrentRoom = currentLevel * 100 + currentRoomNumber
	printDebug("   Full Current Room:", fullCurrentRoom)
	
	local result
	if direction == ">" then
		-- Upper floor: 120 -> 220
		result = (currentLevel + 1) * 100 + currentRoomNumber
		printDebug("   → Staircase UP to:", result)
	elseif direction == "<" then
		-- Lower floor: 120 -> 020
		result = (currentLevel - 1) * 100 + currentRoomNumber
		printDebug("   → Staircase DOWN to:", result)
	else
		-- Normal door: uses neighbor's level and roomNumber
		if neighborRoom then
			local neighborLevel = neighborRoom.customFields.level or 1
			local neighborRoomNum = neighborRoom.customFields.roomNumber or 0
			result = neighborLevel * 100 + neighborRoomNum
			printDebug("   → NORMAL door to:", result, "(level:", neighborLevel, "room:", neighborRoomNum, ")")
		else
			printDebug("   ⚠️  neighborRoom is nil, cannot calculate")
			result = fullCurrentRoom -- Fallback to same room
		end
	end
	return result
end

--- Generates doors for a room from levelsLDTK
-- Creates doors based on the Doors entities list
-- Each door entity has a DoorsConnection field indicating its direction
-- @param currentRoom table The current room data
function CreateDoorsFromLDTK(currentRoom)
	if not currentRoom then
		printDebug("❌ ERROR: currentRoom is nil")
		return
	end
	
	printDebug("🚪 ===== CREATING DOORS =====")
	printDebug("📍 Current room:", currentRoom.identifier)
	
	-- Check if there are door entities
	local doorEntities = currentRoom.entities and currentRoom.entities.Doors
	if not doorEntities or #doorEntities == 0 then
		printDebug("⚠️  No door entities in this room")
		return
	end
	
	printDebug("📊 Total door entities:", #doorEntities)
	
	local neighbourLevels = currentRoom.neighbourLevels
	if not neighbourLevels then
		printDebug("⚠️  No neighbourLevels in this room")
		return
	end
	
	local currentLevel = currentRoom.customFields.level or 1
	local currentRoomNumber = currentRoom.customFields.roomNumber or 0
	
	printDebug("🏢 Current level:", currentLevel, "| Room:", currentRoomNumber)
	
	-- Create a map of neighbors by direction for quick lookup
	local neighborsByDir = {}
	for _, neighbor in ipairs(neighbourLevels) do
		if neighbor.dir then
			neighborsByDir[neighbor.dir] = neighbor
		end
	end
	
	-- Mapping from door direction names to LDTK directions
	local doorDirectionMap = {
		-- Cardinal directions (north, south, east, west)
		top = "n",      -- North
		down = "s",     -- South
		right = "e",    -- East
		left = "w",     -- West
		-- Stairs
		upper = ">",    -- Stairs up
		lower = "<"     -- Stairs down
	}
	
	-- Process each door entity
	for i, doorEntity in ipairs(doorEntities) do
		printDebug("")
		printDebug("--- Processing door entity", i, "---")
		printDebug("   iid:", doorEntity.iid)
		printDebug("   position: (", doorEntity.x, ",", doorEntity.y, ")")
		
		local doorConnection = doorEntity.customFields and doorEntity.customFields.DoorsConnection
		if not doorConnection then
			printDebug("⚠️  Door entity has no DoorsConnection field, skipping")
		else
			printDebug("🔑 Door direction:", doorConnection)
			
			local doorNameLower = doorConnection:lower()
			local ldtkDir = doorDirectionMap[doorNameLower]
			
			if not ldtkDir then
				printDebug("⚠️  Unknown door direction:", doorConnection)
			else
				printDebug("🔍 Looking for neighbor in LDTK direction:", ldtkDir)
				
				local neighbor = neighborsByDir[ldtkDir]
				
				if not neighbor then
					printDebug("🚫 No neighbor found in direction:", ldtkDir, "- skipping door")
				else
					printDebug("✅ Neighbor found in direction:", ldtkDir)
					printDebug("   levelIid:", neighbor.levelIid)
					
					local direction = ConvertLDTKDirection(ldtkDir)
					
					-- Check if door needs a key
					local needsKey = doorEntity.customFields.NeedsKey or false
					local keyNumber = doorEntity.customFields.KeyNumber
					
					printDebug("🔐 NeedsKey:", needsKey)
					if needsKey and keyNumber then
						printDebug("   KeyNumber:", keyNumber)
					end
					
					-- Handle stairs (upper/lower)
					if ldtkDir == ">" or ldtkDir == "<" then
						printDebug("⚡ It's a STAIRCASE")
						
						local leadsTo = CalculateLeadsTo(currentLevel, currentRoomNumber, ldtkDir, nil)
						local open = needsKey and "closed" or "open"
						
						printDebug("🔧 Creating staircase:")
						printDebug("   direction:", direction)
						printDebug("   open:", open)
						printDebug("   leadsTo:", leadsTo)
						printDebug("   ZIndex:", ZIndex.props)
						
						-- Create the staircase
						--Door(direction, open, leadsTo, ZIndex.props)
						printDebug("✅ Staircase created (commented out)")
						
					-- Handle cardinal directions (north, south, east, west)
					else
						local neighborRoom = FindRoomByIid(neighbor.levelIid)
						
						if neighborRoom then
							printDebug("✅ Neighbor room loaded:", neighborRoom.identifier)
							
							local leadsTo = CalculateLeadsTo(currentLevel, currentRoomNumber, ldtkDir, neighborRoom)
							local open = needsKey and "closed" or "open"
							local keyNumber = needsKey and keyNumber or nil
							
							printDebug("🔧 Creating door:")
							printDebug("   direction:", direction)
							printDebug("   open:", open)
							printDebug("   leadsTo:", leadsTo)
							printDebug("   ZIndex:", ZIndex.props)
							if keyNumber then
								printDebug("   keyNumber:", keyNumber)
							end
							
							-- Create the door
							Door(direction, open, leadsTo, ZIndex.props, keyNumber, doorEntity.x, doorEntity.y, doorEntity.width, doorEntity.height)
							printDebug("✅ Door created successfully")
						else
							printDebug("⚠️  Neighbor room not loaded in levelsLDTK")
						end
					end
				end
			end
		end
	end
	
	printDebug("🚪 ===== END DOOR CREATION =====")
	printDebug("")
end

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