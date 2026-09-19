-- RoomAtlas: lifetime record of which authored rooms the player has ever set foot in.
--
-- The run graph is regenerated from scratch every run (see MapGenerator), so "explored"
-- cannot mean "visited every node of the current graph" -- that is reachable in almost
-- any run and says nothing about exploration. The atlas instead counts DISTINCT ROOM
-- TEMPLATES seen across every run: a single run surfaces roughly a quarter of the pool,
-- so filling the atlas is a many-run goal. That is the explorer's achievement.
--
-- Persistence is deliberately its OWN datastore key, not a PlayerData field:
--   * PlayerData is wiped by ResetPlayerData() on death and on New Game, which would
--     reset the atlas constantly -- the opposite of a lifetime record.
--   * Deleting the save DOES clear it (SaveSystem.delete -> RoomAtlas.clear), so a wipe
--     is still a true wipe.
RoomAtlas = {}

local STORE_KEY        <const> = 'roomAtlas'
local ACHIEVEMENT_ID   <const> = 'cartographer'

-- uniqueIdentifer -> true, for every room template ever entered.
local seen  = {}
local count = 0

-- Cached denominator; see RoomAtlas.total().
local totalCache = nil

--- How many rooms the game can ever show, i.e. every procGen-eligible template.
--
-- Counted straight off levelsLDTK rather than via MapGenerator.buildPool(): buildPool
-- additionally filters by meetsRequirements(), so a pool-based denominator would shrink
-- and grow as the player picks up items and the percentage would wander on its own.
-- Lazy + cached because this module is imported before assets/data/levels.
function RoomAtlas.total()
    if totalCache then return totalCache end
    local n = 0
    for _, tmpl in ipairs(levelsLDTK or {}) do
        if tmpl.customFields and tmpl.customFields.procGen == true then n = n + 1 end
    end
    if n == 0 then return 0 end  -- levels not imported yet; do not cache a bogus zero
    totalCache = n
    return totalCache
end

function RoomAtlas.seenCount()
    return count
end

--- Explored percentage, 0-100. Derived on every read, never stored: a cached percentage
--- and a changing denominator drift apart the moment a room is authored.
function RoomAtlas.percent()
    local total = RoomAtlas.total()
    if total == 0 then return 0 end
    return (count / total) * 100
end

--- Record a room template as seen. No-op if it already was.
-- Writes through to the datastore only on an actual discovery -- at most once per new
-- room for the lifetime of the save, so this is not a per-transition write.
function RoomAtlas.discover(template)
    local uid = template and template.uniqueIdentifer
    if not uid or seen[uid] then return false end

    seen[uid]  = true
    count      = count + 1
    RoomAtlas.syncAchievement()
    RoomAtlas.store()
    printDebug("🗺️ New room discovered: " .. tostring(uid) ..
               " (" .. count .. "/" .. RoomAtlas.total() .. ")")
    return true
end

--- Push the current count into the incremental achievement. advanceTo() grants it on its
--- own once progress reaches progressMax, so there is no separate grant call.
function RoomAtlas.syncAchievement()
    if not achievements or not achievements.keyedAchievements then return end
    if not achievements.keyedAchievements[ACHIEVEMENT_ID] then return end
    achievements.advanceTo(ACHIEVEMENT_ID, count)
end

function RoomAtlas.store()
    playdate.datastore.write({ seen = seen, count = count }, STORE_KEY, true)
end

function RoomAtlas.load()
    local data = playdate.datastore.read(STORE_KEY)
    seen, count = {}, 0
    if data and data.seen then
        -- Recount rather than trusting the stored count: a room template deleted from LDtk
        -- since the save was written must not keep inflating the numerator above total().
        for uid in pairs(data.seen) do
            if roomsByIid == nil or roomsByIid[uid] then
                seen[uid] = true
                count = count + 1
            end
        end
    end
    RoomAtlas.syncAchievement()
    printDebug("🗺️ Atlas loaded: " .. count .. "/" .. RoomAtlas.total())
end

--- Wipe the atlas and the achievement with it. Called from SaveSystem.delete() only:
--- dying or starting a new game must NOT reach this.
function RoomAtlas.clear()
    seen, count = {}, 0
    playdate.datastore.delete(STORE_KEY)
    -- advanceTo(0) clears stored progress and revokes the achievement if it was granted.
    if achievements and achievements.keyedAchievements
       and achievements.keyedAchievements[ACHIEVEMENT_ID] then
        achievements.advanceTo(ACHIEVEMENT_ID, 0)
    end
end

--- Stamp the runtime room count onto the explorer achievement's progressMax.
-- The total lives in levelsLDTK, so it cannot be written as a literal in
-- assets/data/achievements.lua. Must run BEFORE achievements.initialize().
function RoomAtlas.stampAchievementTotal(data)
    local total = RoomAtlas.total()
    if total == 0 then return end
    for _, ach in ipairs(data.achievements or {}) do
        if ach.id == ACHIEVEMENT_ID then
            ach.progressMax = total
            return
        end
    end
end

return RoomAtlas
