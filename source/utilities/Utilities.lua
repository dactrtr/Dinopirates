-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

class('Box').extends(playdate.graphics.sprite)

function Utilities.getZero()
	return 0
end

-- mark: Draw collider boxes (walls)

function Box:init(x, y, width, height) 
	Graphics.setColor(playdate.graphics.kColorWhite)
	Graphics.fillRect(x, y, width, height)
	Graphics.drawRect(x, y, width, height)
	self:setSize(width, height)
	self:moveTo(x, y)
	self:setCenter(0,0)
	self:addSprite()
	self:setCollideRect(0,0,width,height)
	self:setGroups(CollideGroups.wall)
end

function Utilities.iddqd()
	print("IDDQD")
	PlayerData.items.hasLamp = true
	PlayerData.items.hasRadio = true
	PlayerData.items.hasDWatch = true
	PlayerData.items.hasNotes = true
	PlayerData.items.hasBoots = true
	PlayerData.items.hasPlunger = true
	
	PlayerData.battery = 100
	
	PlayerData.skills.canFlash = true
	PlayerData.skills.canDash = true
	PlayerData.skills.canPlungerang = true
	
	PlayerData.CrewMemberData.amountTaken = 21
	PlayerData.CrewMemberData.idNumbers.CM001 = true
	PlayerData.CrewMemberData.idNumbers.CM002 = true
	PlayerData.CrewMemberData.idNumbers.CM003 = true
	PlayerData.CrewMemberData.idNumbers.CM004 = true
	PlayerData.CrewMemberData.idNumbers.CM005 = true
	PlayerData.CrewMemberData.idNumbers.CM006 = true
	PlayerData.CrewMemberData.idNumbers.CM007 = true
	PlayerData.CrewMemberData.idNumbers.CM008 = true
	PlayerData.CrewMemberData.idNumbers.CM009 = true
	PlayerData.CrewMemberData.idNumbers.CM010 = true
	PlayerData.CrewMemberData.idNumbers.CM011 = true
	PlayerData.CrewMemberData.idNumbers.CM012 = true
	PlayerData.CrewMemberData.idNumbers.CM013 = true
	PlayerData.CrewMemberData.idNumbers.CM014 = true
	PlayerData.CrewMemberData.idNumbers.CM015 = true
	PlayerData.CrewMemberData.idNumbers.CM016 = true
	PlayerData.CrewMemberData.idNumbers.CM017 = true
	PlayerData.CrewMemberData.idNumbers.CM018 = true 
	PlayerData.CrewMemberData.idNumbers.CM019 = true
	PlayerData.CrewMemberData.idNumbers.CM020 = true
	PlayerData.CrewMemberData.idNumbers.CM021 = true
end

-- MARK: Cheat codes

local keys = {
	a = playdate.kButtonA,
	b = playdate.kButtonB,
	up = playdate.kButtonUp,
	down = playdate.kButtonDown,
	left = playdate.kButtonLeft,
	right = playdate.kButtonRight,
}

-- Mark: Cheatcodes
class("CheatCode").extends()

function CheatCode: init(...)
	local seq = {}
	for _, key in ipairs({...}) do
		local v = keys[key]
		assert(v, "CheatCode: unkwnown key given => "..tostring(key))
		table.insert(seq, v)
	end
	self._seq= seq
	self.progress = 1
	self.run_once = false
	self:setTimerDelay(400)
end

function CheatCode:update()
	if self.run_once and self.completed then return end
	
	local _, pressed, _= playdate.getButtonState()
	
	if pressed == 0 then return end
	
	if pressed == self._seq[self.progress] then
		self.progress += 1
		self._timer:reset()
	
		if self.progress > #self._seq then
		  self.completed = true
		  if type(self.onComplete) == "function" then
			self.onComplete()
		  end
		end
	  else
		self:reset()
	  end
end

function CheatCode:reset()
	self.progress = 1
	self._timer:reset()
	self._timer:pause()
end

function CheatCode:setTimerDelay(ms)
  if self._timer then
	self._timer:remove()
  end
  self._timer = playdate.timer.new(ms, function() self:reset() end)
  self._timer:pause()
  self._timer.discardOnCompletion = false
end

function CheatCode:nextIs(key)
  return keys[key] == self._seq[self.progress]
end

function RandomScreen(axis)
	if axis == "x" then
		return math.random(Config.Screen.randomBoundsX.min, Config.Screen.randomBoundsX.max)
	elseif axis == "y" then
		return math.random(Config.Screen.randomBoundsY.min, Config.Screen.randomBoundsY.max)
	end
end

function checkBool(bool)
	local string
	if bool == true then
		print('true')
	elseif (bool == false) then
		print('false')
	end
end
function printDebug(value)
	if debug == true then
		print(value)
	end
end
function RoomTranslate(roomNumber)
	local floorClass = "Floor" .. roomNumber
	return _G[floorClass]
end
-- Door utilities have been moved to entities/props/door.lua

--- Finds a neighbor by direction
-- @param currentRoom table Current room data
-- @param direction string Direction to search for
-- @return table|nil Neighbor data or nil
function FindNeighborByDirection(currentRoom, direction)
	printDebug("🔍 Searching for neighbor with direction:", direction)
	
	if not currentRoom.neighbourLevels then
		printDebug("❌ No neighbourLevels")
		return nil
	end
	
	for _, neighbor in ipairs(currentRoom.neighbourLevels) do
		if neighbor.dir == direction then
			printDebug("✅ Neighbor found with dir:", direction)
			return neighbor
		end
	end
	
	printDebug("❌ Neighbor not found with dir:", direction)
	return nil
end

--- Validates if you can fall/climb in a direction
-- @param currentRoom table Current room data
-- @param direction string Direction: "<" to fall (down), ">" to climb (up)
-- @return boolean true if movement is allowed
function CanMoveVertically(currentRoom, direction)
	-- direction: "<" to fall (down), ">" to climb (up)
	local doorsConnection = currentRoom.customFields.DoorsConnection or {}
	
	-- Mapping of vertical directions to names in DoorsConnection
	local directionMap = {
		["<"] = "lower",  -- Fall downwards
		[">"] = "upper"   -- Climb upwards
	}
	
	local requiredConnection = directionMap[direction]
	if not requiredConnection then
		printDebug("⚠️  Vertical direction not recognized:", direction)
		return false
	end
	
	-- Check if it's allowed in DoorsConnection
	for _, allowed in ipairs(doorsConnection) do
		if allowed:lower() == requiredConnection:lower() then
			return true
		end
	end
	
	return false
end

--- Gets the lower room (fall)
-- @param currentRoomIndex number Current room index in levelsLDTK
-- @return number|nil, table|nil Room number and room data
function GetLowerRoom(currentRoomIndex)
	printDebug("⬇️  === SEARCHING FOR LOWER ROOM ===")
	local currentRoom = levelsLDTK[currentRoomIndex]
	
	if not currentRoom then
		printDebug("❌ currentRoom not valid")
		return nil
	end
	
	-- Validate if you can fall
	if not CanMoveVertically(currentRoom, "<") then
		printDebug("🚫 Cannot fall from this room (doesn't have 'lower' in DoorsConnection)")
		return nil
	end
	
	-- Search for neighbor with direction "<" (lower floor)
	local lowerNeighbor = FindNeighborByDirection(currentRoom, "<")
	
	if not lowerNeighbor then
		printDebug("❌ No lower room defined in neighbourLevels")
		return nil
	end
	
	-- Search for room by its iid
	local lowerRoom = FindRoomByIid(lowerNeighbor.levelIid)
	
	if lowerRoom then
		local level = lowerRoom.customFields.level or 0
		local roomNum = lowerRoom.customFields.roomNumber or 0
		local roomNumber = level * 100 + roomNum
		
		printDebug("✅ Lower room found:")
		printDebug("   identifier:", lowerRoom.identifier)
		printDebug("   level:", level)
		printDebug("   roomNumber:", roomNum)
		printDebug("   fullRoomNumber:", roomNumber)
		
		return roomNumber, lowerRoom
	else
		printDebug("⚠️  Lower room is not loaded in levelsLDTK")
		-- Calculate expected number even if not loaded
		local currentLevel = currentRoom.customFields.level or 1
		local currentRoomNum = currentRoom.customFields.roomNumber or 0
		local expectedRoom = (currentLevel - 1) * 100 + currentRoomNum
		
		printDebug("📊 Expected room (calculated):", expectedRoom)
		return expectedRoom, nil
	end
end

--- Gets the upper room (climb)
-- @param currentRoomIndex number Current room index in levelsLDTK
-- @return number|nil, table|nil Room number and room data
function GetUpperRoom(currentRoomIndex)
	printDebug("⬆️  === SEARCHING FOR UPPER ROOM ===")
	local currentRoom = levelsLDTK[currentRoomIndex]
	
	if not currentRoom then
		printDebug("❌ currentRoom not valid")
		return nil
	end
	
	-- Validate if you can climb
	if not CanMoveVertically(currentRoom, ">") then
		printDebug("🚫 Cannot climb from this room (doesn't have 'upper' in DoorsConnection)")
		return nil
	end
	
	-- Search for neighbor with direction ">" (upper floor)
	local upperNeighbor = FindNeighborByDirection(currentRoom, ">")
	
	if not upperNeighbor then
		printDebug("❌ No upper room defined in neighbourLevels")
		return nil
	end
	
	-- Search for room by its iid
	local upperRoom = FindRoomByIid(upperNeighbor.levelIid)
	
	if upperRoom then
		local level = upperRoom.customFields.level or 0
		local roomNum = upperRoom.customFields.roomNumber or 0
		local roomNumber = level * 100 + roomNum
		
		printDebug("✅ Upper room found:")
		printDebug("   identifier:", upperRoom.identifier)
		printDebug("   level:", level)
		printDebug("   roomNumber:", roomNum)
		printDebug("   fullRoomNumber:", roomNumber)
		
		return roomNumber, upperRoom
	else
		printDebug("⚠️  Upper room is not loaded in levelsLDTK")
		-- Calculate expected number even if not loaded
		local currentLevel = currentRoom.customFields.level or 1
		local currentRoomNum = currentRoom.customFields.roomNumber or 0
		local expectedRoom = (currentLevel + 1) * 100 + currentRoomNum
		
		printDebug("📊 Expected room (calculated):", expectedRoom)
		return expectedRoom, nil
	end
end

--- Gets a room by its number
-- @param roomNumber number Complete room number (e.g. 220 = level 2, room 20)
-- @return table|nil Room data or nil
function GetRoomByNumber(roomNumber)
	local level = math.floor(roomNumber / 100)
	local room = roomNumber % 100
	
	printDebug("🔍 Searching room by number:", roomNumber, "(level:", level, "room:", room, ")")
	
	for _, roomData in ipairs(levelsLDTK) do
		if roomData.customFields.level == level and 
		   roomData.customFields.roomNumber == room then
			printDebug("✅ Room found:", roomData.identifier)
			return roomData
		end
	end
	
	printDebug("❌ Room NOT found")
	return nil
end

function drawVersionNumber(x, y, alignment)
	-- Save current graphics context to avoid affecting sprites
	Graphics.pushContext()
	
	Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
	
	-- local version = "*"..Panels.vars.lang.."* Demo*" .. playdate.metadata.version .. "*"
	local version = "* Demo " .. playdate.metadata.version .. "*"  -- Wrap version in * for bold
	local versionWidth = Graphics.getTextSize(version)
	
	-- If no x position provided, default to right-aligned at 400 (screen width)
	x = x or 400
	-- If no y position provided, default to 2 (near top)
	y = y or 2
	-- If no alignment provided, default to right alignment with 4px padding
	if alignment == nil then
		x = x - versionWidth - 4
	end
	
	Graphics.drawText(version, x, y)
	
	-- Restore previous graphics context
	Graphics.popContext()
end 

-- Finds and kills an enemy by its unique ID (LDtk version)
function findAndKillEnemyById(enemyId)
	local room = PlayerData.floor
	local entities = levelsLDTK[room].entities

	if not entities then
		printDebug("⚠️ No entities found in room:", room)
		return
	end

	for entityType, entitiesList in pairs(entities) do
		-- Buscar dentro de tipos de enemigos conocidos
		if entityType == "Brocorat" or entityType == "Bosscolli" then
			for _, enemy in ipairs(entitiesList) do
				if enemy.iid == enemyId then
					local cf = enemy.customFields or {}
					if cf.dead == false or cf.dead == nil then
						cf.dead = true
						-- Actualizamos su posición a donde fue derrotado
						if PlayerData.lastEnemyTouched then
							enemy.x = PlayerData.lastEnemyTouched.x
							enemy.y = PlayerData.lastEnemyTouched.y
						end
						printDebug("💀 Enemy killed:", enemyId, "in", entityType)
					end
					return
				end
			end
		end
	end
end

-- finds and destroys a prop
function findAndDestroyPropById(propId)
	local room = PlayerData.floor
	local entities = levelsLDTK[room].entities

	if not entities then
		printDebug("⚠️ No entities found in room:", room)
		return
	end

	for entityType, entitiesList in pairs(entities) do
		for _, prop in ipairs(entitiesList) do
			local cf = prop.customFields or {}
			-- Detectar si es un prop por tener 'destroyed' o 'nocollider'
			if cf.destroyed ~= nil or cf.nocollider ~= nil then
				if prop.iid == propId then
					if not cf.destroyed then
						cf.destroyed = true
						printDebug("💥 Prop destroyed:", propId, "in", entityType)
					end
					return
				end
			end
		end
	end
end

-- Grants an achievement if it hasn't been granted yet
function Utilities.grantAchievementIfNeeded(name)
	-- Check if the ID exists in achievementData
	for _, data in ipairs(achievementData.achievements) do
		if data.id == name then
			if not achievements.isGranted(name) then
				achievements.grant(name)
			end
			return -- Found and handled, exit function
		end
	end

end

-- Maps comics to achievements
local storyAchievements = {
	intro = "wakeup",
	["pick-the-device"] = "comms",
}

function Utilities.checkStoryAchievement(comic)
	local achievement = storyAchievements[comic]
	if achievement then
		Utilities.grantAchievementIfNeeded(achievement)
	end
end

-- Sanity-based achievements
function Utilities.checkSanityAchievements()
	local sanityAchievements = {
		[2] = "sanityloss1",
		[5] = "sanityloss2",
		-- Future: add [5] = "sanityloss2", etc.
	}
	
	local achievement = sanityAchievements[PlayerData.sanityCounter]
	if achievement then
		Utilities.grantAchievementIfNeeded(achievement)
	end
end

function renderTileMap(tileData, tilemap)
  local height = #tileData
  local width = #tileData[1]
  tilemap:setSize(width, height)
  for y = 1, height do
	for x = 1, width do
	  tilemap:setTileAtPosition(x, y, tileData[y][x])
	end
  end
end

local SECTION_TILE_IDS = {}
for _, id in ipairs(Config.Tiles.walkable) do
	SECTION_TILE_IDS[id] = true
end
local TILE_SIZE = Config.Tiles.size

--- Creates wall colliders from tilemap data with 2D clustering (horizontal and vertical merging)
-- @param tileData table The 2D matrix of tile IDs
-- @return table List of created Box sprites
function CreateTileColliders(tileData)
	local colliders = {}
	local height = #tileData
	local width = #tileData[1]
	
	local allSegments = {}

	-- Phase 1: Horizontal identification
	-- We find all contiguous wall tiles (anything NOT in SECTION_TILE_IDS) in each row and store them as segments.
	for y = 1, height do
		allSegments[y] = {}
		local x = 1
		while x <= width do
			local tileID = tileData[y][x]
			if not SECTION_TILE_IDS[tileID] then
				local startX = x
				while x <= width and tileData[y][x] and not SECTION_TILE_IDS[tileData[y][x]] do
					x = x + 1
				end
				local segmentWidth = x - startX
				table.insert(allSegments[y], {x = startX, w = segmentWidth, used = false})
			else
				x = x + 1
			end
		end
	end

	-- Phase 2: Vertical merging
	-- We try to merge segments from consecutive rows if they have the same X and Width.
	for y = 1, height do
		for _, segment in ipairs(allSegments[y]) do
			if not segment.used then
				local currentH = 1
				-- Look ahead in subsequent rows
				for nextY = y + 1, height do
					local found = false
					for _, nextSegment in ipairs(allSegments[nextY]) do
						if not nextSegment.used and nextSegment.x == segment.x and nextSegment.w == segment.w then
							nextSegment.used = true
							currentH = currentH + 1
							found = true
							break
						end
					end
					if not found then break end
				end
				
				-- Create the Box sprite for the final merged area
				local px = (segment.x - 1) * TILE_SIZE
				local py = (y - 1) * TILE_SIZE
				local pw = segment.w * TILE_SIZE
				local ph = currentH * TILE_SIZE
				
				local collider = Box(px, py, pw, ph)
				table.insert(colliders, collider)
			end
		end
	end
	
	return colliders
end

-- Bulk revoke (delete) achievements
function Utilities.clearAllAchievements()
	for _, data in ipairs(achievementData.achievements) do
		if data.id then
			achievements.revoke(data.id)
		end
	end
end

-- Dev Tools
function printEnemies()
	for i, enemy in pairs(playdate.graphics.sprite.getAllSprites()) do
		if enemy.type == "Enemy" then
			printDebug("x:", enemy.x)
			printDebug("y:", enemy.y)
			printDebug("Type:", enemy.type)
			printDebug("ID:", enemy.id)
			printDebug("----")
		end
	end
end

function Utilities.switchLang()
	if Panels.vars.lang == "en" then
		Panels.vars.lang = "jp"
	else
		Panels.vars.lang = "en"
	end
end

function Utilities.renderLangPanel(panel, offset)
	for i, layer in ipairs(panel.layers) do
		if layer.name == "base" then
			Panels.renderLayerInPanel(layer, panel, offset)
		elseif layer.name == "en" and Panels.vars.lang == "en" then
			Panels.renderLayerInPanel(layer, panel, offset)
		elseif layer.name == "jp" and Panels.vars.lang == "jp" then
			Panels.renderLayerInPanel(layer, panel, offset)
		end
	end
end

function Utilities.toggle(value)
  return not value
end


function CurrentTile()
	local floor = PlayerData.actualTilemap or 1
	local x = tonumber(PlayerData.x) or 0
	local y = tonumber(PlayerData.y) or 0

	-- Convertir coordenadas de píxeles a coordenadas de tile
	local tileX = math.floor(x / TILE_SIZE) + 1
	local tileY = math.floor(y / TILE_SIZE) + 1

	-- Obtener referencias seguras
	local floorData = tileMapData[floor]
	if not floorData then
		printDebug("⚠️ Piso no encontrado:", floor)
		return
	end

	local row = floorData[tileY]
	if not row then
		printDebug(string.format("⚠️ Fuera del rango vertical (tileY=%.2f)", tileY))
		return
	end

	local tileNumber = row[tileX]
	if not tileNumber then
		printDebug(string.format("⚠️ Fuera del rango horizontal (tileX=%.2f)", tileX))
		return
	end

	-- ✅ Usa %.2f para floats y %d solo para enteros seguros
	printDebug(string.format(
		"🧭 Piso %d | Player (%.1f, %.1f) | Tile (%d, %d) = %d",
		floor, x, y, tileX, tileY, tileNumber
	))
end

-- Returns the tile ID at a given pixel position (or player position by default)
function GetTileUnderPlayer(px, py)
	local floor = PlayerData.actualTilemap or 1
	local x = px or tonumber(PlayerData.x) or 0
	local y = py or tonumber(PlayerData.y) or 0

	local tileX = math.floor(x / TILE_SIZE) + 1
	local tileY = math.floor(y / TILE_SIZE) + 1

	local floorData = tileMapData[floor]
	if not floorData then return nil end

	local row = floorData[tileY]
	if not row then return nil end

	return row[tileX]
end

SLIME_TILE_IDS = {}
for _, id in ipairs(Config.Tiles.slime) do
	SLIME_TILE_IDS[id] = true
end

-- Checks if the player is standing on a slime tile using a 16x16 area at their feet.
-- The player sprite is 48x48 with center at (px, py). The feet are at ~py+12.
-- Samples a 16x16 grid (5 points) to catch overlap with tile edges.
function IsPlayerOnSlime(px, py)
	-- Feet center is at py + 12 (bottom of the collider rect)
	local feetY = py + 12
	-- Tiny mode collider is 10px wide (±5px), normal is 30px wide (±8px sample)
	local halfW = PlayerData.isTiny and 5 or 8
	local xOffsets = { -halfW, 0, halfW }
	local yOffsets = { -4, 0, 4 }
	for _, dx in ipairs(xOffsets) do
		for _, dy in ipairs(yOffsets) do
			local tileID = GetTileUnderPlayer(px + dx, feetY + dy)
			if tileID and SLIME_TILE_IDS[tileID] then
				return true
			end
		end
	end
	return false
end

local function formatNumberK(n)
	if n >= 1000000 then
		return string.format("%.1fM", n / 1000000):gsub("%.0M", "M")
	elseif n >= 1000 then
		return string.format("%.1fk", n / 1000):gsub("%.0k", "k")
	else
		return tostring(n)
	end
end
function drawStatusText(image)
	local xPos = 160
	local yPos = 128
	Graphics.pushContext(image)
	
	-- Clear text areas
	Graphics.setColor(Graphics.kColorWhite)
	Graphics.fillRect(xPos, yPos, 100, 12)
	Graphics.fillRect(xPos, yPos + 12, 100, 12)
	Graphics.fillRect(xPos, yPos + 25, 100, 12)
	Graphics.fillRect(xPos, yPos + 38, 100, 12)
	
	local smallFont = Graphics.font.new('assets/fonts/Mini Sans')
	Graphics.setFont(smallFont)
	
	-- Apply formatting to steps
	local sanityText = ": " .. tostring(PlayerData.sanity)
	local caloriesText = ": " .. tostring(PlayerData.calories)
	local stepsText = ": " .. formatNumberK(PlayerData.totalSteps)
	local mapPercent = ": " .. MapDrawer.calculateMapPercent().."%"

	Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
	Graphics.drawText(sanityText, xPos, yPos)
	Graphics.drawText(caloriesText, xPos, yPos + 12)
	Graphics.drawText(stepsText, xPos, yPos + 25)
	Graphics.drawText(mapPercent, xPos, yPos + 38)
	Graphics.popContext()
end