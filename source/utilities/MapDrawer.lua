-- MapDrawer.lua
-- Utility module for drawing the game map on any image context
-- Extracted from PauseMenu.lua for reusability

MapDrawer = {}

-- Calculate map exploration percentage
-- Total rooms configuration: 80 rooms total
-- Level 1 (rooms 1-15): 15 rooms
-- Level 2 (rooms 16-30): 15 rooms  
-- Level 3 (rooms 31-65): 35 rooms
-- Level 4 (rooms 66-80): 15 rooms
function MapDrawer.calculateMapPercent()
	local TOTAL_ROOMS = 80 -- Total number of rooms in the game
	local visitedCount = 0
	
	-- Safety check
	if not levelsLDTK then
		return 0
	end
	
	-- Count visited rooms
	for _, levelData in ipairs(levelsLDTK) do
		local cf = levelData.customFields or {}
		if cf.visited == true then
			visitedCount = visitedCount + 1
		end
	end
	
	-- Calculate percentage
	local percent = math.floor((visitedCount / TOTAL_ROOMS) * 100)
	return percent
end

-- Draw the map on the provided image context
-- @param targetImage: The Graphics.image to draw the map on
function MapDrawer.drawMap(targetImage)
	-- Configuration for each floor
	local floorConfig = {
		[1] = { cols = 5, rows = 3, posX = 142, posY = 73, startRoom = 66 },  -- Level 4: 5x3 from room_66 to room_80
		[2] = { cols = 7, rows = 5, posX = 131, posY = 18, startRoom = 31 },  -- Level 3: 7x5 from room_31 to room_65
		[3] = { cols = 5, rows = 3, posX = 32, posY = 65, startRoom = 16 },  -- Level 2: 5x3 from room_16 to room_30
		[4] = { cols = 5, rows = 3, posX = 32, posY = 29, startRoom = 1 }   -- Level 1: 5x3 from room_1 to room_15
	}
	
	local alpha = 0.5
	local roomSize = 7
	local spacing = 6  
	
	-- Draw background grid for each floor
	for level, config in pairs(floorConfig) do
		local totalRooms = config.cols * config.rows
		
		for i = 1, totalRooms do
			local col = (i - 1) % config.cols
			local row = math.floor((i - 1) / config.cols)
			
			Graphics.pushContext(targetImage)
			Graphics.setColor(Graphics.kColorBlack)
			Graphics.setDitherPattern(alpha, Graphics.image.kDitherTypeBayer8x8)
			Graphics.fillRect(
				config.posX + (col * spacing), 
				config.posY + (row * spacing), 
				roomSize, 
				roomSize
			)
			Graphics.popContext()
		end
	end
	
	-- Safety check: ensure levelsLDTK exists
	if not levelsLDTK then
		printDebug("⚠️  levelsLDTK not loaded")
		return
	end
	
	-- Iterate through all levels in levelsLDTK and mark visited rooms
	for _, levelData in ipairs(levelsLDTK) do
		local cf = levelData.customFields or {}
		local level = cf.level
		local roomNumber = cf.roomNumber
		local visited = cf.visited or false
		
		-- Skip if essential data is missing
		if not level or not roomNumber then
			printDebug("⚠️  Skipping level - missing level or roomNumber")
			goto continue
		end
		
		-- Check if this floor is configured
		local config = floorConfig[level]
		if not config then
			printDebug("⚠️  Floor", level, "not configured, skipping")
			goto continue
		end
		
		-- Calculate position in grid relative to the floor's starting room
		local totalRooms = config.cols * config.rows
		local roomIndexOnFloor = roomNumber - config.startRoom
		
		if roomIndexOnFloor < 0 or roomIndexOnFloor >= totalRooms then
			printDebug("⚠️  Room", roomNumber, "out of bounds for floor", level)
			goto continue
		end
		
		local col = roomIndexOnFloor % config.cols
		local row = math.floor(roomIndexOnFloor / config.cols)
		
		-- Only draw if visited
		if visited then
			Graphics.pushContext(targetImage)
			
			-- Check if this is the player's current position
			if PlayerData.actualLevel == level and PlayerData.actualRoom == roomNumber then
				-- Mark current player position (white outline, black center)
				Graphics.setColor(Graphics.kColorWhite)
				Graphics.fillRect(
					config.posX + 1 + (col * spacing), 
					config.posY + 1 + (row * spacing), 
					5, 
					5
				)
				
				Graphics.setColor(Graphics.kColorBlack)
				Graphics.fillRect(
					config.posX + 2 + (col * spacing), 
					config.posY + 2 + (row * spacing), 
					3, 
					3
				)
			else
				-- Reveal visited room (white square)
				Graphics.setColor(Graphics.kColorWhite)
				Graphics.fillRect(
					config.posX + 1 + (col * spacing), 
					config.posY + 1 + (row * spacing), 
					5, 
					5
				)
			end
			
			Graphics.popContext()
		end
		
		::continue::
	end
end

return MapDrawer
