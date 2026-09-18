inGameMenu = {}
class('inGameMenu').extends(Graphics.sprite)
import 'utilities/MapDrawer'

local shadow = Graphics.image.new(400,240)
-- Pristine menu art, plus a working buffer we paint the map onto. The buffer is reset to
-- the pristine art on every open so repeated opens never stack ghost map renders.
local baseMenuImage = Graphics.image.new('assets/images/ui/menu/ingame-menu')
local menuImage = baseMenuImage:copy()
local menuSprite = nil

-- Crew member hat images
local hatImages = {}
local hatSpriteSheet = Graphics.imagetable.new('assets/images/props/hats')

-- Debug readout font. Loaded once; only ever used inside a pushContext, which restores the
-- previous font on pop, so the global shinonome default is never disturbed.
local statsFont = Graphics.font.new(Config.DebugStats.font)

--- Builds the two columns of the debug readout, as {label, value} rows.
-- `header` rows are section titles; `blank` rows are spacers. Everything is read fresh on
-- each menu open, so the numbers are always current.
local function buildStatColumns()
    local pd      = PlayerData
    local crew    = pd.CrewMemberData or {}
    local enemies = pd.EnemiesData or {}

    local left = {
        { header = 'RUN' },
        { 'room',     tostring(RunState.currentNodeId or '-') },
        { 'run',      tostring(pd.runCount or 0) },
        { 'map',      string.format('%d%%', math.floor(pd.mapPercent or 0)) },
        { blank = true },
        { header = 'FAT LOOP' },
        -- calories is a float since the fat loop landed (burnPerMove = 0.2)
        { 'calories', string.format('%.1f', pd.calories or 0) },
        { 'fat',      pd.isFat and 'YES' or 'NO' },
        { 'steps',    string.format('%d', math.floor(pd.totalSteps or 0)) },
        { blank = true },
        { header = 'STATE' },
        { 'size',     pd.isTiny and 'TINY' or 'BIG' },
        { 'food',     tostring(pd.food or 0) },
    }

    local right = {
        { header = 'BODY' },
        { 'hp',       string.format('%d/%d', pd.healthPoints or 0, Config.Player.maxHealthPoints) },
        { 'battery',  string.format('%d', math.floor(pd.battery or 0)) },
        { 'sanity',   string.format('%d', math.floor(pd.sanity or 0)) },
        -- sanityCounter, labelled apart from `sanity`: one is the 0-100 resource, the other
        -- the lifetime counter that drives the horror escalation. Conflating them has bitten
        -- the docs before.
        { 'madness',  tostring(pd.sanityCounter or 0) },
        { blank = true },
        { header = 'PROGRESS' },
        { 'crew',     string.format('%d/%d', crew.amountTaken or 0, Config.MapGen.totalCrew) },
        { 'power',    tostring(enemies.powerLevel or 0) },
        { 'dances',   tostring(pd.amountDances or 0) },
    }

    return { left, right }
end

function inGameMenu:init()
  self:moveTo(200,120)
  self:setZIndex(ZIndex.menu)
  self:setImage(shadow)

  -- Crear sprite para el menú
  menuSprite = Graphics.sprite.new()
  menuSprite:setImage(menuImage)
  menuSprite:setCenter(0.5, 0.5)
  menuSprite:moveTo(200, 120)
  menuSprite:setZIndex(ZIndex.menu + 2)

  self:add()
end

function inGameMenu:displayMenu()
    if not PlayerData.items.hasDWatch then return end
    PlayerData.isGaming = false
    PlayerData.isEquiping = true
    
    self:drawMapOnMenu()
    
    -- Create hat sprites when menu opens
    if PlayerData.CrewMemberData.amountTaken > 0 then
        self:drawCrewHats()
    end
end

function inGameMenu:drawMapOnMenu()
    -- Reset the buffer to the pristine menu art first, so the map is always drawn on a
    -- clean canvas (otherwise each open paints over the previous render → ghost/double boxes).
    Graphics.pushContext(menuImage)
        baseMenuImage:draw(0, 0)
    Graphics.popContext()
    MapDrawer.drawMap(menuImage)
    if debug == true then
        self:drawDebugStats()
    end
end

--- Paints the debug stat readout onto the menu buffer's empty right-hand page.
-- Drawn into the same buffer as the map, so it inherits the pristine-art reset above and
-- needs no sprite of its own to tear down in closeMenu().
function inGameMenu:drawDebugStats()
    local cfg     = Config.DebugStats
    local columns = buildStatColumns()

    -- Vertically centre the taller column inside the panel.
    local rows = 0
    for _, column in ipairs(columns) do
        rows = math.max(rows, #column)
    end
    local blockHeight = rows * cfg.lineHeight
    local startY = cfg.panel.y + math.max(0, math.floor((cfg.panel.h - blockHeight) / 2))

    Graphics.pushContext(menuImage)
        Graphics.setFont(statsFont)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
        for columnIndex, column in ipairs(columns) do
            local x = cfg.panel.x + (columnIndex - 1) * cfg.columnGap
            local y = startY
            for _, row in ipairs(column) do
                if row.header then
                    Graphics.drawText('*' .. row.header .. '*', x, y)  -- * wraps text in bold
                elseif not row.blank then
                    Graphics.drawText(row[1], x, y)
                    Graphics.drawTextAligned(row[2], x + cfg.valueRight, y, kTextAlignment.right)
                end
                y = y + cfg.lineHeight
            end
        end
    Graphics.popContext()
end

function inGameMenu:drawCrewHats()
    -- Create sprites for captured crew member hats in the menu
    local hatX = 43  -- Starting X position for hats
    local hatY = 108  -- Starting Y position for hats
    local hatSpacing = 20  -- Space between hats
    local rowSpacing = 20  -- Space between rows
    local maxHatsPerRow = 7 -- Max hats before starting a new row
    
    -- Remove any existing hat sprites first
    if self.hatSprites then
        for _, hatSprite in ipairs(self.hatSprites) do
            if hatSprite then
                hatSprite:remove()
            end
        end
    end
    self.hatSprites = {}
    
    -- Check each crew member and create a sprite for their hat if captured
    if PlayerData.CrewMemberData and PlayerData.CrewMemberData.idNumbers then
        -- Iterate through a fixed range of possible IDs to ensure order and filtering
        -- There are 21 states defined in Hats.lua
        for i = 1, 21 do
            local crewId = string.format("CM%03d", i)
            local isCaptured = PlayerData.CrewMemberData.idNumbers[crewId]
            
            -- Explicitly check if the value is TRUE
            if isCaptured == true then
                -- Get the slot index from the ID (CM001 -> 0, CM002 -> 1, ...)
                local slotIndex = i - 1
                
                -- Create a sprite for this hat using its ID as the frame index
                local hatImage = hatSpriteSheet:getImage(i)
                if hatImage then
                    local hatSprite = Graphics.sprite.new(hatImage)
                    hatSprite:setCenter(0, 0)
                    local row = math.floor(slotIndex / maxHatsPerRow)
                    local col = slotIndex % maxHatsPerRow
                    hatSprite:moveTo(hatX + (col * hatSpacing), hatY + (row * rowSpacing))
                    hatSprite:setZIndex(ZIndex.menu + 9)
                    hatSprite:add()
                    table.insert(self.hatSprites, hatSprite)
                end
            end
        end
    end
end

function inGameMenu:closeMenu()
    shadow:clear(Graphics.kColorClear)
    if menuSprite then
        menuSprite:remove()
    end
    -- Remove hat sprites
    if self.hatSprites then
        for _, hatSprite in ipairs(self.hatSprites) do
            if hatSprite then
                hatSprite:remove()
            end
        end
        self.hatSprites = nil
    end
end

-- The menu is purely visual: it shows the map and the captured crew hats.
-- There is no skill/item selection — abilities fire from the B button directly.
function inGameMenu:update()
  if PlayerData.isEquiping == true then
    if menuSprite then
        menuSprite:add()
    end
  end
end