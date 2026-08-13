--
-- Mazescene.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "scene" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MazeScene = {
}
class("MazeScene").extends(NobleScene)

local scene = MazeScene
local room = nil -- Level in table position

MazeScene.backgroundMusic = nil

import "entities/player/init"

import "assets/comics/comicsData"

import "entities/enemies/brocorat"
import "entities/enemies/crewmember"

import 'entities/props/propItem'
import 'entities/props/door'
import 'entities/props/portal_door'
import 'entities/props/trigger'

import 'entities/items/Items'
import 'entities/props/npc'

import "entities/FX/FXshadow"
import "entities/UI/playerHud"
import "entities/UI/inGameMenu"

-- It is recommended that you declare, but don't yet define,
-- your scene-specific variables and methods here. Use "local" where possible.
--
-- local variable1 = nil	-- local variable
-- scene.variable2 = nil	-- Scene variable.
--							   When accessed outside this file use `scene.variable2`.
-- ...
--



-- MARK: Player related
local player = nil
local shadow = nil
local foregroundSprite = nil
local inGameMenuActive = nil
-- MARK: UI
local uiScreen = nil
local inGameEquip = nil
-- MARK: Utilities
local cheat = CheatCode("up", "up", "up", "down")
-- Mark: variables for crank checking
local crankIsMoving = false
local crankStopTimer = 0
local CRANK_STOP_THRESHOLD = 0.1 -- seconds of inactivity before considering crank stopped
local bButtonDownTime = nil -- ms timestamp when B was pressed; drives custom hold-to-charge (SDK Held is fixed at 1s)
local lastTapTime = { up = nil, down = nil, left = nil, right = nil } -- ms timestamp of the previous tap per direction
local dashTaps    = { up = 0,   down = 0,   left = 0,   right = 0   } -- consecutive taps within the window per direction
-- Multi-tap dash trigger: fires once the player taps a direction Config.Dash.tapsToTrigger times
-- in a row, each within Config.Dash.tapWindow of the previous. Any longer gap resets that
-- direction's count (starting a fresh streak with the current tap).
local function checkDashTaps(dir)
	local now = playdate.getCurrentTimeMilliseconds()
	if lastTapTime[dir] and (now - lastTapTime[dir]) <= Config.Dash.tapWindow then
		dashTaps[dir] = dashTaps[dir] + 1
	else
		dashTaps[dir] = 1
	end
	lastTapTime[dir] = now
	if dashTaps[dir] >= Config.Dash.tapsToTrigger then
		dashTaps[dir] = 0
		lastTapTime[dir] = nil
		return true
	end
	return false
end
local tileColliders = {}

-- Returns true if the player's collide-rect footprint centred at sprite position (cx,cy) covers
-- only walkable tiles (no wall). The player sprite is 48x48 anchored at its centre, so its
-- top-left is (cx-24, cy-24); the collide rect is offset within that. Samples every tile the
-- rect touches; out-of-bounds tiles count as walls, so a spawn is never pushed off the map.
local function spawnFootprintClear(cx, cy)
	local grid = tileMapData[PlayerData.actualTilemap]
	if not grid then return true end  -- no tile data: don't fight it
	local TILE = Config.Tiles.size
	local cr = PlayerData.isTiny and Config.Player.collideRectTiny or Config.Player.collideRect
	local left   = cx - 24 + cr.x
	local top    = cy - 24 + cr.y
	local right  = left + cr.w - 1
	local bottom = top + cr.h - 1
	local tx0, tx1 = math.floor(left / TILE) + 1, math.floor(right / TILE) + 1
	local ty0, ty1 = math.floor(top / TILE) + 1, math.floor(bottom / TILE) + 1
	for ty = ty0, ty1 do
		local row = grid[ty]
		for tx = tx0, tx1 do
			if not IsTileWalkable(row and row[tx]) then return false end
		end
	end
	return true
end

-- If the spawn point clips a wall, return the nearest position (expanding-ring search, 2px steps)
-- whose collide-rect footprint is fully clear; otherwise return the point unchanged. Gives up
-- (returns the original) if nothing clear is found within maxRadius.
local function nudgeSpawnClearOfWalls(px, py)
	if spawnFootprintClear(px, py) then return px, py end
	local step, maxRadius = 2, 64
	local dirs = { {-1,0},{1,0},{0,-1},{0,1},{-1,-1},{1,-1},{-1,1},{1,1} }
	for r = step, maxRadius, step do
		for _, d in ipairs(dirs) do
			local nx, ny = px + d[1] * r, py + d[2] * r
			if spawnFootprintClear(nx, ny) then
				printDebug("🧱 Spawn was clipping a wall — nudged to", nx, ny)
				return nx, ny
			end
		end
	end
	printDebug("⚠️ Spawn clipping a wall and no clear spot found within", maxRadius)
	return px, py
end

-- This is the background color of this scene.
scene.backgroundColor = Graphics.kColorWhite

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitioning away from another scene.
function scene:init()
	scene.super.init(self)
	cheat.onComplete = function()
		Utilities.iddqd()
	end
	playdate.display.setRefreshRate(50)

	if not MazeScene.backgroundMusic then
		MazeScene.backgroundMusic = playdate.sound.fileplayer.new('assets/sounds/music/game/shadow_dino_explore_ima')
		if MazeScene.backgroundMusic then
			MazeScene.backgroundMusic:setVolume(0.5)
		end
	end
end
function scene:setFloor(levelNumber, roomNumber)
	for i, levelData in ipairs(levelsLDTK) do
		if levelData.customFields.level == levelNumber and levelData.customFields.roomNumber == roomNumber then
			room = i
			return
		end
	end
	print("Warning: Level " .. levelNumber .. ", Room " .. roomNumber .. " not found")
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
	scene.super.enter(self)

	if MazeScene.backgroundMusic and not MazeScene.backgroundMusic:isPlaying() then
		MazeScene.backgroundMusic:play(0)
	end

	PlayerData.isGaming = false
	PlayerData.isEquiping = false
	sequence = Sequence.new():from(0):to(50, 1.5, Ease.outBounce)
	sequence:start()
	
	-- Procedural run: resolve the room from the active graph node. Fall back to
	-- starting a fresh run if we entered with no node (stray Floor/debug transition).
	RunState.consumePending()
	if not RunState.currentNode() then
		RunState.startRun()
		RunState.consumePending()
	end
	local node = RunState.currentNode()
	local template = node.poolRoom
	-- Endgame: mark the final room (revealed once all crew are recruited). The actual
	-- transition fires in start() — calling Noble.transition here would BONK because
	-- enter() runs at the transition midpoint (still transitioning).
	self.pendingEndgame = (node.content and node.content.isFinal) or false
	-- Per-node, run-scoped visited tracking for the in-game run-graph map.
	node.visited = true
	-- Map the template back to its levelsLDTK index so all existing levelsLDTK[room]
	-- reads (background, tilemap, entities, door metadata) keep working unchanged.
	room = nil
	for i, lvl in ipairs(levelsLDTK) do
		if lvl == template then room = i; break end
	end

	-- Spawn at the authored door we entered through, inset inward, so the player lands
	-- in an open doorway (never behind a wall). Entry side = opposite of the door we
	-- left (PlayerData.lastRoom); among that side's doors, pick the one whose position
	-- matches the door we used (PlayerData.lastDoorCross). Start room → first door.
	local entrySide = PlayerData.lastRoom and MapGenerator.opposite(PlayerData.lastRoom) or nil
	local spawnDoor, spawnSide
	if entrySide then
		local sideDoors = MapGenerator.doorsForSide(template, entrySide)
		if #sideDoors > 0 then
			spawnSide = entrySide
			local cross = PlayerData.lastDoorCross
			if cross then
				local horizontal = (entrySide == "top" or entrySide == "down")
				local bestDist
				for _, de in ipairs(sideDoors) do
					local c = horizontal and de.x or de.y
					local dist = math.abs(c - cross)
					if not bestDist or dist < bestDist then spawnDoor, bestDist = de, dist end
				end
			else
				spawnDoor = sideDoors[1]
			end
		end
	end
	if not spawnDoor then
		local doors = template.entities and template.entities.Doors
		if doors and doors[1] then
			spawnDoor = doors[1]
			spawnSide = (spawnDoor.customFields and spawnDoor.customFields.DoorsConnection or ""):lower()
		end
	end
	if spawnDoor then
		-- Tiny player has a much smaller collider, so it can spawn closer to the door.
		local inset = PlayerData.isTiny and Config.Doors.spawnInsetTiny or Config.Doors.spawnInsetNormal
		-- The player sprite is 48x48 and anchored at its centre, but its collide rect is
		-- offset within it, so the centre is not the visual body. Compute the body offset
		-- (using the collider that matches the current size) and align the player's body to
		-- the door's centre on the cross axis, while pushing the body 'inset' away on the
		-- main axis. bodyDX/bodyDY are subtracted on BOTH axes so it's the body — not the
		-- sprite centre — that lands at 'inset', keeping top/down (and left/right) symmetric.
		local cr = PlayerData.isTiny and Config.Player.collideRectTiny or Config.Player.collideRect
		local spriteHalf = 24  -- player sprite is 48x48 (see Player:init setSize)
		local bodyDX = (cr.x + cr.w / 2) - spriteHalf
		local bodyDY = (cr.y + cr.h / 2) - spriteHalf
		local sx, sy = spawnDoor.x, spawnDoor.y
		if spawnSide == "left" then
			sx = spawnDoor.x + inset - bodyDX
			sy = spawnDoor.y - bodyDY
		elseif spawnSide == "right" then
			sx = spawnDoor.x - inset - bodyDX
			sy = spawnDoor.y - bodyDY
		elseif spawnSide == "top" then
			sy = spawnDoor.y + inset - bodyDY
			sx = spawnDoor.x - bodyDX
		elseif spawnSide == "down" then
			sy = spawnDoor.y - inset - bodyDY
			sx = spawnDoor.x - bodyDX
		end
		-- Don't override the spawn when returning in place from a fight (DanceScene set
		-- it to the contact point). Door-spawn applies on door entries and run start.
		if not PlayerData.returningInPlace then
			PlayerData.playerSpawn.x = sx
			PlayerData.playerSpawn.y = sy
		end
	end
	PlayerData.returningInPlace = false

	-- Vertical entry (tube rise / hole fall) overrides the door-based spawn above: a new run
	-- enters at a Startup/StartDown room, but the door-based spawn uses a stale PlayerData.lastRoom
	-- (vertical transitions never update it). One-shot: consumeEntryRole clears it, so later door
	-- navigation within the run is unaffected.
	--   • StartDown: spawn at the room's DOWN door by default, as if the player arrived from an UP
	--     door in the room below (placed just inside the bottom of the room). Falls back to a
	--     TubeExit if there is no down door.
	--   • StartUp: spawn at the authored TubeExit.
	local entryRole = RunState.consumeEntryRole()
	if entryRole == "startup" or entryRole == "startdown" then
		-- Body offset so the player BODY (not the 48x48 sprite centre) lands on the target,
		-- matching the door-spawn math above.
		local cr = PlayerData.isTiny and Config.Player.collideRectTiny or Config.Player.collideRect
		local spriteHalf = 24  -- player sprite is 48x48 (see Player:init setSize)
		local bodyDX = (cr.x + cr.w / 2) - spriteHalf
		local bodyDY = (cr.y + cr.h / 2) - spriteHalf
		local sx, sy

		if entryRole == "startdown" then
			local downDoors = MapGenerator.doorsForSide(template, "down")
			local d = downDoors and downDoors[1]
			if d then
				local inset = PlayerData.isTiny and Config.Doors.spawnInsetTiny or Config.Doors.spawnInsetNormal
				sx = d.x - bodyDX
				sy = d.y - inset - bodyDY
			end
		end

		-- StartUp default, and StartDown fallback when the room has no down door: authored TubeExit.
		if not sx then
			local exits = template.entities and template.entities.TubeExit
			if exits and exits[1] then
				local ex = exits[1]
				sx = ex.x - bodyDX
				sy = ex.y - bodyDY
			end
		end

		if sx then
			PlayerData.playerSpawn.x = sx
			PlayerData.playerSpawn.y = sy
		else
			printDebug("⚠️ Vertical entry: no down door / TubeExit — kept door-based spawn")
		end
	end

	PlayerData.room = levelsLDTK[room].customFields.roomNumber
	PlayerData.isInDarkness = levelsLDTK[room].customFields.shadow
	PlayerData.floor = room
	
	PlayerData.actualLevel = levelsLDTK[room].customFields.level
	PlayerData.actualRoom = levelsLDTK[room].customFields.roomNumber
	PlayerData.actualTilemap = levelsLDTK[room].customFields.tile

	-- MARK: Floor
	local roomBgPath = 'assets/images/rooms/floor' .. PlayerData.actualLevel
	                   .. '/' .. levelsLDTK[room].identifier
	floor = Graphics.sprite.new()
	floor:setImage(Graphics.image.new(roomBgPath))
	floor:setZIndex(1)
	floor:moveTo(200, 120)
	floor:add()

	-- MARK: Foreground
	if levelsLDTK[room].customFields.hasForeground == true then
		local fgPath = 'assets/images/rooms/floor' .. PlayerData.actualLevel
		               .. '/foreground_' .. PlayerData.actualRoom
		local fgImage = Graphics.image.new(fgPath)
		if fgImage then
			foregroundSprite = Graphics.sprite.new()
			foregroundSprite:setImage(fgImage)
			foregroundSprite:setZIndex(ZIndex.foreground)
			foregroundSprite:moveTo(200, 120)
			foregroundSprite:add()
		end
	end

	-- MARK: UI
	inGameEquip = inGameMenu()
	
	-- MARK: Tile Colliders
	if room and levelsLDTK[room] then
		tileColliders = CreateTileColliders(tileMapData[PlayerData.actualTilemap])
		-- Build the enemy pathfinding graph from the same tilemap the colliders use.
		Pathing.rebuild(tileMapData[PlayerData.actualTilemap])
	else
		printDebug("❌ ERROR: could not create wall colliders, room or levelsLDTK[room] is nil")
	end
	
	-- MARK: Doors

	
	if room and levelsLDTK[room] then
		local currentRoom = levelsLDTK[room]
		printDebug("✅ CurrentRoom:", currentRoom.identifier)
		printDebug("📍 Level:", currentRoom.customFields.level)
		printDebug("📍 RoomNumber:", currentRoom.customFields.roomNumber)

		CreateDoorsFromNode(node)
		CreateWallPlugsFromNode(node)
		CreatePortalsFromNode(node)
	else
		printDebug("❌ ERROR: room is", room, "or levelsLDTK[room] is nil")
	end
	printDebug("======================")
	
	
	
	-- MARK: Props 
	local entities = levelsLDTK[room].entities
	
	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			for _, prop in ipairs(entitiesList) do
				local cf = prop.customFields or {}
	
				if cf.destroyed ~= nil or cf.nocollider ~= nil then
					local x, y, id = prop.x, prop.y, prop.iid
	
					local isUtility = (cf.type == "microwave" or cf.type == "minifier")
					if isUtility and not (node.content.utilities and node.content.utilities[id]) then
						-- utility not rolled for this run's node: skip spawning it
					elseif cf.destroyed == false or cf.destroyed == nil then
						PropItem(x, y, cf.type , ZIndex.props, cf.nocollider,cf.destroyed, id)
					else
						PropItem(x, y, "debris", ZIndex.props, true, cf.destroyed , id)
					end
				end
			end
		end
	end
	
	-- MARK: Items
	local itemRequirements = {
		keycard = "keys",
		lamp = "items.hasLamp",
		radio = "items.hasRadio",
		notes = "items.hasNotes",
		plunger = "items.hasPlunger"
	}

	if entities ~= nil then
		for entityType, entitiesList in pairs(entities) do
			for _, item in ipairs(entitiesList) do
				local cf = item.customFields or {}

				-- spawnConditions: an optional render gate (e.g. {"run>=4","items.hasLamp"}).
				-- If present and not all met, the item is not spawned. Separate from the
				-- ownership/collected checks below.
				if cf.isItem == true and Conditions.met(cf.spawnConditions or cf.SpawnConditions) then
					local x, y = item.x, item.y
					local itemType = (cf.type or ""):lower()
					local keyNumber = cf.KeyNumber or cf.keyNumber
					local shouldGenerate = false

					if itemType == "keycard" then
						local keyNum = keyNumber or 1
						shouldGenerate = not PlayerData.keys[keyNum]
						printDebug("Checking keycard - KeyNumber:", keyNum, "shouldGenerate:", shouldGenerate)
					elseif cf.grants then
						shouldGenerate = true
						for pair in string.gmatch(cf.grants, "([^,]+)") do
							local key, value = string.match(pair, "([^:]+):([^:]+)")
							if key and value then
								key = key:gsub("%s+", "")
								if PlayerData.items[key] == true or PlayerData.skills[key] == true then
									shouldGenerate = false
									break
								end
							end
						end
					elseif itemType == "food" then
						-- Food is stackable: persist per-iid via the 'collected' flag
						shouldGenerate = cf.collected ~= true
					elseif itemRequirements[itemType] then
						local itemPath = itemRequirements[itemType]
						if itemPath:match("^items%.") then
							local fieldName = itemPath:match("^items%.(.+)$")
							shouldGenerate = PlayerData.items[fieldName] == false
						else
							shouldGenerate = PlayerData[itemPath] == false
						end
					end

					if shouldGenerate then
						printDebug("Generating item:", itemType, "at (", x, ",", y, ")")
						Items(x, y, itemType, keyNumber, cf.grants, item.iid)
					end
				end
			end
		end
	end
		-- MARK: Player
	local spawnPoint = PlayerData.playerSpawn
	-- Safety: never spawn clipping a wall (e.g. a TubeExit authored tight to a wall). Check the
	-- player's collide-rect footprint against the tilemap and, if it overlaps any non-walkable
	-- tile, nudge to the nearest position that is fully clear. No-op when the spawn is already OK.
	spawnPoint.x, spawnPoint.y = nudgeSpawnClearOfWalls(spawnPoint.x, spawnPoint.y)
	player = Player(spawnPoint.x, spawnPoint.y, PlayerData.speed, ZIndex.player)
	uiScreen = playerHud(player)
	PlayerData.x = player.x
	PlayerData.y = player.y
	PlayerData.direction = 'idle'
	
	-- MARK: FX
	local cf = levelsLDTK[room].customFields or {}
	
	if cf.shadow == true then
		local lightLevel = cf.light or 0
		shadow = FXshadow(player, 70, lightLevel, ZIndex.fx)
		PlayerData.isInDarkness = true
	else
		PlayerData.isInDarkness = false
	end
	
	-- Story cutscenes play once ever, tracked persistently by comic_name in PlayerData
	-- (rooms are reused templates across runs, so a per-room flag can't persist this).
	PlayerData.seenComics = PlayerData.seenComics or {}
	local cf = levelsLDTK[room].customFields
	if cf.comic_name then
		local comicData = comics[cf.comic_name]
		if comicData and not PlayerData.seenComics[cf.comic_name] then
			if cf.play == "Enter" then
				PlayerData.isCutscene = true
				PlayerData.isGaming = false
			end

			Panels.startCutscene(comicData, function()
				PlayerData.isGaming = true
				PlayerData.isCutscene = false
				PlayerData.seenComics[cf.comic_name] = true
				Utilities.checkStoryAchievement(cf.comic_name)
			end)
		end
	end
	
	
	-- MARK: Enemies (from node content; persistence via node.cleared within the run)
	local clearedEnemies = node.cleared.enemies or {}
	for _, e in ipairs(node.content.enemies or {}) do
		local dead = clearedEnemies[e.key]
		if dead then
			-- killed earlier this run: show the corpse where it fell
			local bx = (type(dead) == "table" and dead.x) or e.x
			local by = (type(dead) == "table" and dead.y) or e.y
			PropItem(bx, by, "blood2", ZIndex.props, true)
		elseif e.kind == "Brocorat" then
			Brocorat(e.x, e.y, e.speed, ZIndex.enemy, player, e.key)
		elseif e.kind == "Bosscolli" then
			bosscolli(e.x, e.y, e.speed, ZIndex.enemy, player, e.key)
		end
	end
	
	-- MARK: Crew (assigned identity → correct hat + dialog; persistence via node.cleared)
	if node.content.crewId and not node.cleared.crewTaken then
		local cs = node.content.crewSpawn or { x = 200, y = 120 }
		CrewMember(cs.x, cs.y, Config.CrewMember.defaultSpeed or 1.5, ZIndex.enemy,
		           player, "node" .. node.id .. "-crew", node.id, node.content.crewId)
	end
	

	-- MARK: NPCs
	local npcEntities = levelsLDTK[room].entities
	if npcEntities and npcEntities.NPC then
		for _, npcData in ipairs(npcEntities.NPC) do
			local cf = npcData.customFields or {}
			NPC(npcData.x, npcData.y, cf.type or "computer", npcData.iid, room, cf.sourceFeed or 0, cf.triggerScene)
		end
	end

-- MARK: Dialog triggers
	local entities = levelsLDTK[room].entities
	
	if entities and entities.Triggers then
		for i, triggerData in ipairs(entities.Triggers) do
			local cf = triggerData.customFields or {}
			local used = cf.usedTrigger or false

			-- spawnConditions: optional render gate (e.g. {"run>=4"}). The trigger is only
			-- created when all conditions pass; its conditionalScripts (which dialog to show)
			-- are still evaluated later, on interaction.
			if not used and Conditions.met(cf.spawnConditions or cf.SpawnConditions) then
				local x = triggerData.x
				local y = triggerData.y
				local width = triggerData.width
				local height = triggerData.height
				local script = cf.script
				local type = cf.type
				
				-- Pasar el iid en lugar del índice
				Trigger(x, y, width, height, script, triggerData.iid, room, type)
			end
		end
	end
end
-- This runs once a transition from another scene is complete.
function scene:start()
	scene.super.start(self)
	-- Endgame: the transition is complete now, so it's safe to leave for the closing
	-- sequence (swap CreditsScene for the real ending scene when authored).
	if self.pendingEndgame then
		Noble.transition(CreditsScene, 0.3, Noble.Transition.MetroNexus)
		return
	end
	self:setDiagonalMovement(diagonalMovement)
	if PlayerData.fromTitle then
		PlayerData.fromTitle = false
		-- Sleep on entry from the title (normal → 'sleep', tiny → 'sleepTiny'; the state
		-- is picked inside startSleeping). Wake is via any d-pad press (Player:update).
		player:startSleeping()
	else
		PlayerData.isGaming = true
	end

	-- If the door-spawn placed the player on a hole, fall now. This runs post-transition
	-- (start, not enter) so fallBelow's own scene transition isn't swallowed mid-transition,
	-- which would otherwise leave isFalling stuck true and silently block the fall. isFalling
	-- is cleared first in case the per-frame check already tripped during the entry transition.
	if PlayerData.isGaming == true and not player.isSleeping then
		player.isFalling = false
		player:checkHoleTile()
		player:checkTinyHoleTile()
	end
end

-- This runs once per frame.
function scene:update()
	scene.super.update(self)
	
	-- Performance: Only update cheat code when player is gaming
	if PlayerData.isGaming == true then
		cheat:update()
	end
	
	-- MARK: Custom B hold-to-charge (shorter than the SDK's fixed 1s Held)
	if bButtonDownTime and player and player.isAlive and PlayerData.isGaming == true
		and not player.isDarkCharging and not player.isGrappleCharging then
		local holdDelay = PlayerData.isInDarkness and Config.DarkReveal.holdDelay or Config.Grapple.holdDelay
		if playdate.getCurrentTimeMilliseconds() - bButtonDownTime >= holdDelay then
			if PlayerData.isInDarkness then
				player:beginDarkCharge()
			else
				player:beginGrappleCharge()
			end
		end
	end

	-- MARK: Crank stop detection
	if crankIsMoving then
		crankStopTimer += (1/50) -- Increment by frame time (assuming 50fps)
		
		if crankStopTimer >= CRANK_STOP_THRESHOLD then
			crankIsMoving = false
			crankStopTimer = 0
			-- do something when player stopped cranking
			player:idle()
		end
	end
	
	-- Cutscene input handling
	if PlayerData.isCutscene == true then
		-- Disable game input handlers while cutscene is running
		if Noble.Input.getEnabled() then
			Noble.Input.setEnabled(false)
		end
		Panels.update()
	else
		-- Re-enable game input handlers when cutscene ends
		if not Noble.Input.getEnabled() then
			Noble.Input.setEnabled(true)
		end
	end
	
	-- Mark: Enemy AI debug overlay (cone, hearing radius, state, path).
	-- Drawn here (not in the enemy's update) because Noble draws all sprites BEFORE
	-- scene:update(), so overlays drawn from a sprite's update() render underneath.
	if debug == true then
		for _, s in ipairs(Graphics.sprite.getAllSprites()) do
			if s.isa and s:isa(Enemy) and s.drawDebug then
				s:drawDebug()
			end
		end
	end

	-- Mark: Crank notification (only when needed)
	if PlayerData.battery == 0 and PlayerData.items.hasLamp == true and PlayerData.isInDarkness == true and (PlayerData.isTalking == false and PlayerData.isCutscene == false) and PlayerData.isGaming == true and (Config.Battery.chargeWhileTiny or PlayerData.isTiny == false) and not PlayerData.showFullLight and not PlayerData.rechargeBlocked then
		playdate.ui.crankIndicator:draw(0, 0)
	end
end


-- This runs once per frame, and is meant for drawing code.
function scene:drawBackground()
	scene.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
	scene.super.exit(self)
	
	uiScreen:removeAll()
	floor:remove()
	if foregroundSprite then
		foregroundSprite:remove()
		foregroundSprite = nil
	end
	if shadow then
		shadow:removeAll()
	end
	
	for _, collider in ipairs(tileColliders) do
		collider:remove()
	end
	tileColliders = {}

	-- Drop the enemy pathfinding graph/cache for the room we're leaving.
	Pathing.invalidate()
	
	Graphics.sprite.performOnAllSprites(function(s)
		if s:getZIndex() ~= -32768 then s:remove() end
	end)
	
	PlayerData.playerExit.x = player.x
	PlayerData.playerExit.y = player.y
	
end

-- Capture the player's live position so Continue resumes exactly where the run was
-- left (used together with returningInPlace in TitleScene's Continue action). Only on
-- pause (menu/sleep) — NOT on finish(): finish() runs mid-transition and would clobber
-- the spawn a door/portal/DanceScene just set for the destination room.
local function captureResumePosition()
	if player then
		PlayerData.playerSpawn.x = player.x
		PlayerData.playerSpawn.y = player.y
	end
end

-- This runs once a transition to another scene completes.
function scene:finish()
	scene.super.finish(self)
	-- Your code here
	PlayerData.isGaming = false
	-- Noble runs the OUTGOING scene's finish() (this) at the transition midpoint,
	-- BEFORE the incoming scene's enter() runs RunState.consumePending(). So on a door
	-- transition currentNodeId is still the room we're leaving — the destination is
	-- staged in pendingNodeId and not yet promoted. Promote it here so the save records
	-- the room the player is actually entering, not the previous one (otherwise Continue
	-- after a cold boot lands in the previous room). No-op for transitions that didn't
	-- queue a destination (DanceScene, DeadScene, Cockpit), where pendingNodeId is nil.
	RunState.consumePending()
	SaveSystem.save()
end

function scene:pause()
	scene.super.pause(self)
	captureResumePosition()
	SaveSystem.save()
end

function MazeScene.onDeviceSleep()
	if player and PlayerData.isGaming then
		player:startSleeping()
	end
end

function scene:movePlayer(direction)
	if PlayerData.isTalking == false and PlayerData.isCutscene == false then
		if player.isAlive == true then
			player:move(direction)
			if shadow  then
				shadow:move(direction)
			end
		end
	end
end

-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- Maps a triggerScene name (set on an NPC/Trigger customField) to its scene class.
-- Add entries here to let other entities launch other scenes when their dialog ends.
local TRIGGER_SCENES = {
	Cockpit = function() return CockpitScene end,
}

-- Scene queued by an entity with a triggerScene; fired once its dialog finishes closing.
local pendingSceneOnDialogEnd = nil

-- scene.inputHandler = someOtherInputHandler
-- OR
scene.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
		if player and player.isSleeping then return end
		if PlayerData.isTalking == true then
			player:displayDialog()
			-- Dialog just closed (isTalking flipped to false in removeAll): run any queued scene.
			if PlayerData.isTalking == false and pendingSceneOnDialogEnd then
				local sceneGetter = pendingSceneOnDialogEnd
				pendingSceneOnDialogEnd = nil
				-- Remember the player's exact spot (and current run node, untouched) so the
				-- launched scene (e.g. Cockpit) can drop them back here on exit instead of
				-- dumping them at the title screen.
				if player then
					PlayerData.playerSpawn.x = player.x
					PlayerData.playerSpawn.y = player.y
				end
				PlayerData.returnToMazeFromScene = true
				Noble.transition(sceneGetter(), 0.3, Noble.Transition.MetroNexus)
			end
		elseif player.currentTrigger and PlayerData.isGaming == true then
			local trigger = player.currentTrigger
			PlayerData.isGaming = false
			PlayerData.isTalking = true
			-- Queue a scene transition if this entity declares a triggerScene (e.g. "Cockpit").
			pendingSceneOnDialogEnd = trigger.triggerScene and TRIGGER_SCENES[trigger.triggerScene] or nil
			player.dialogUI:addScreen(trigger:returnScript(), trigger.sourceFeed)
			Utilities.grantAchievementIfNeeded(trigger.script)
		end
		
		-- Trigger minifier if ready
		if PlayerData.readyToShrink == true and PlayerData.isGaming == true then
			player:startMinifying()
		end

		-- Trigger microwave cooking if ready
		if PlayerData.readyToCook == true and PlayerData.isGaming == true then
			player:startCooking()
		end
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		if player and player.isSleeping then return end
		if PlayerData.isGaming == true and PlayerData.items.hasDWatch == true then
			inGameEquip:displayMenu(player.x,player.y)
		end
	end,
	AButtonUp = function()				-- Runs once when button is released.
		-- Your code here
	end,

	-- B button
	--

	BButtonDown = function()
		if player and player.isSleeping then return end
		if PlayerData.isGaming == false and PlayerData.isEquiping == true then
			PlayerData.isGaming = true
			PlayerData.isEquiping = false
			inGameEquip:closeMenu()
		elseif PlayerData.isGaming == false and PlayerData.readyToShrink == true then
			player:finishMinifying()
		elseif PlayerData.isGaming == false and PlayerData.readyToCook == true then
			player:finishCooking()
		elseif PlayerData.isGaming == true and player.isAlive == true then
			player:useAbility()
		end
		-- Tokens are granted by each ability when it actually fires (flash / plungerang /
		-- grapple launch), not here — so merely starting a charge while idle costs nothing.
		-- Start the custom hold timer; update() begins the dark charge after holdDelay.
		bButtonDownTime = playdate.getCurrentTimeMilliseconds()
	end,
	BButtonHold = function()
	end,
	BButtonUp = function()
		bButtonDownTime = nil
		if player then
			player:endDarkCharge()
			player:endGrappleCharge()
		end
	end,
	-- D-pad left
	--
	leftButtonDown = function()
		if player.isSleeping then return end
		if checkDashTaps('left') then
			player:dash('left')
			return
		end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'left'
			scene:movePlayer('left')
		end
	end,
	leftButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'left') then
			scene:movePlayer('left')
		end
	end,
	leftButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'left' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		if player.isSleeping then return end
		if checkDashTaps('right') then
			player:dash('right')
			return
		end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'right'
			scene:movePlayer('right')
		end
	end,
	rightButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'right') then
			scene:movePlayer('right')
		end
	end,
	rightButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'right' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad up
	--
	upButtonDown = function()
		if player.isSleeping then return end
		if checkDashTaps('up') then
			player:dash('up')
			return
		end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'up'
			scene:movePlayer('up')
		end
	end,
	upButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'up') then
			scene:movePlayer('up')
		end
	end,
	upButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'up' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- D-pad down
	--
	downButtonDown = function()
		if player.isSleeping then return end
		if checkDashTaps('down') then
			player:dash('down')
			return
		end
		if isDiagonalMovementEnabled or not isPlayerMoving then
			isPlayerMoving = true
			currentMoveDirection = 'down'
			scene:movePlayer('down')
		end
	end,
	downButtonHold = function()
		if isDiagonalMovementEnabled or (isPlayerMoving and currentMoveDirection == 'down') then
			scene:movePlayer('down')
		end
	end,
	downButtonUp = function()
		if player.isSleeping then return end
		if currentMoveDirection == 'down' then
			isPlayerMoving = false
			currentMoveDirection = nil
			player:idle()
			if shadow then
				shadow:refresh()
			end
		end
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)
		-- Reset crank stop detection
		crankIsMoving = true
		crankStopTimer = 0
		
		local ticksValue = playdate.getCrankTicks(Config.Battery.crankTicksPerRev)
		if not player.isAlive then return end

		if player.isDarkCharging then
			player:addDarkCrankDelta(change)
			return
		end

		if player.isGrappleCharging then
			player:addGrappleCrankDelta(change)
			return
		end

		-- Cranking burns calories, EXCEPT while cooking at a microwave:
		-- cooking's calorie byproduct (Config.Microwave.caloriesPerFood) must be the
		-- only calorie effect, otherwise this per-tick burn cancels it out.
		local isCooking = (PlayerData.isGaming == false and PlayerData.readyToCook == true)
		if ticksValue > 0 and not isCooking then
			player:burnCalories(Config.Pedometer.crankCalorieBurn)
		end
		
		if PlayerData.isGaming == true then
			if ticksValue > 0 then
				if PlayerData.battery < Config.Battery.max and PlayerData.readyToShrink == false and (Config.Battery.chargeWhileTiny or PlayerData.isTiny == false) then
					player:chargeBattery(Config.Battery.chargePerCrankTick)
					if shadow then
						shadow:refresh()
					end
				end
			end
		else
			-- Handle microwave cooking when locked on a microwave
			if PlayerData.readyToCook == true then
				if ticksValue ~= 0 then
					-- Play the eating animation while actively cranking to cook/heal.
						player.animation:setState('eating')
						player.cookProgress = (player.cookProgress or 0) + math.abs(ticksValue)
					while player.cookProgress >= Config.Microwave.crankPerFood
							and (PlayerData.food or 0) > 0
							and PlayerData.healthPoints < Config.Player.maxHealthPoints do
						player.cookProgress -= Config.Microwave.crankPerFood
						PlayerData.food -= 1
						PlayerData.healthPoints = math.min(PlayerData.healthPoints + Config.Microwave.hpPerFood, Config.Player.maxHealthPoints)
						PlayerData.calories = math.min((PlayerData.calories or 0) + Config.Microwave.caloriesPerFood, Config.Dance.caloriesMax)
					end
					-- Auto-finish when full or out of food
					if PlayerData.healthPoints >= Config.Player.maxHealthPoints or (PlayerData.food or 0) <= 0 then
						player:finishCooking()
					end
				end
			end
			-- Handle manual transformation when locked on minifier
			if PlayerData.readyToShrink == true then
				if ticksValue ~= 0 then
					player:transformCycle()
					
					if not PlayerData.isTiny then
						-- Shrinking (Counter-clockwise)
						if ticksValue < 0 then
							PlayerData.actualPlayerSize -= math.abs(ticksValue)
							if PlayerData.actualPlayerSize <= 0 then
								PlayerData.actualPlayerSize = 0
								player:shrink()
								player:finishMinifying()
							end
						end
					else
						-- Growing (Clockwise)
						if ticksValue > 0 then
							PlayerData.actualPlayerSize += math.abs(ticksValue)
							if PlayerData.actualPlayerSize >= PlayerData.playerSize then
								PlayerData.actualPlayerSize = PlayerData.playerSize
								player:grow()
								player:finishMinifying()
							end
						end
					end
				end
			end
		end
		-- scene:PowerCrank()
		
	end,
	crankDocked = function()	
							-- Runs once when when crank is docked.
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		
	end
}

function MazeScene:setDiagonalMovement(enabled)
	isDiagonalMovementEnabled = enabled
end

function scene:PowerCrank()
    
end
