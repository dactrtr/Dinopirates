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

-------------------------------------------------------------
-- Untranslated glyphs
-------------------------------------------------------------
-- The readout is always on screen; `debug` only decides whether its LABELS are legible.
-- With debug off the D-Watch shows the numbers but renders every word as alien glyphs --
-- the data is there, you just can't read what it means.
--
-- Substitution is per character and WIDTH-PRESERVING: each letter is replaced by a symbol
-- the font draws at exactly the same pixel width, so a scrambled label occupies the same
-- box as the real one and the layout cannot shift between the two modes.
--
-- Widths are measured from the font at runtime rather than copied out of the .fnt, so
-- re-exporting Nano Sans can't silently desync this table. ASCII only, deliberately: the
-- font has multi-byte glyphs (¥ … ™ ©) but Playdate Lua has no utf8 library to iterate
-- them safely, and labels are pure ASCII anyway.
local GLYPH_POOL <const> = { '.', ':', ';', '!', '|', '[', ']', '`',
                             '{', '}', '^', '<', '=', '>', '?', '\\', '_', '"',
                             '@', '~' }

local glyphsByWidth = nil   -- pixel width -> array of same-width symbols
local scrambleCache = {}    -- real string -> scrambled string

local function buildGlyphsByWidth()
    glyphsByWidth = {}
    for _, symbol in ipairs(GLYPH_POOL) do
        local w = statsFont:getTextWidth(symbol)
        glyphsByWidth[w] = glyphsByWidth[w] or {}
        table.insert(glyphsByWidth[w], symbol)
    end
end

--- Replace every character with a same-width symbol. Deterministic: a given letter always
--- becomes the same glyph, so the gibberish is stable across opens rather than flickering,
--- and a curious player could in principle decode it.
local function scramble(text)
    if scrambleCache[text] then return scrambleCache[text] end
    if not glyphsByWidth then buildGlyphsByWidth() end

    local out = {}
    for i = 1, #text do
        local char    = text:sub(i, i)
        local bucket  = glyphsByWidth[statsFont:getTextWidth(char)]
        -- No same-width symbol: keep the character. Staying legible is better than
        -- breaking the column alignment the whole readout depends on.
        out[i] = bucket and bucket[(text:byte(i) % #bucket) + 1] or char
    end

    scrambleCache[text] = table.concat(out)
    return scrambleCache[text]
end

--- Labels pass through here; values never do. Numbers stay readable in both modes.
local function label(text)
    if debug == true then return text end
    return scramble(text)
end

--- Builds the two columns of the debug readout, as {label, value} rows.
-- `header` rows are section titles; `blank` rows are spacers. Everything is read fresh on
-- each menu open, so the numbers are always current.
local function buildStatColumns()
    local pd      = PlayerData
    local crew    = pd.CrewMemberData or {}
    local enemies = pd.EnemiesData or {}

    local left = {
        { header = 'RUN' },
        -- Two different numbers, deliberately on separate rows: `node` is the position in
        -- the generated run graph (1..N, generator order), `room` is the LDtk template the
        -- node drew -- level and roomNumber from its customFields. A single row labelled
        -- "room" showing the node id reads as the room and is not.
        { 'node',     tostring(RunState.currentNodeId or '-') },
        { 'room',     string.format('%s-%s', tostring(pd.actualLevel or '-'),
                                             tostring(pd.actualRoom or '-')) },
        { 'run',      tostring(pd.runCount or 0) },
        -- Lifetime atlas, not this run's graph. Shows the fraction as well as the percent:
        -- at 78% what you want to know is that three rooms are still missing.
        { 'map',      string.format('%d%% %d/%d', math.floor(RoomAtlas.percent()),
                                                  RoomAtlas.seenCount(), RoomAtlas.total()) },
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
    -- Always drawn. `debug` decides legibility, not presence -- see label()/scramble().
    self:drawStats()
end

--- Paints the stat readout onto the menu buffer's empty right-hand page.
-- Drawn into the same buffer as the map, so it inherits the pristine-art reset above and
-- needs no sprite of its own to tear down in closeMenu().
function inGameMenu:drawStats()
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
        -- Register the same face for every variant: the markup Playdate uses for *bold* and
        -- _italic_ swaps to a variant font, and Nano Sans ships a single .fnt -- an unset
        -- variant silently falls back to the ~14px system font, which overflows lineHeight
        -- and collides with the neighbouring rows. Headers are set apart with a rule instead.
        Graphics.setFont(statsFont, Graphics.font.kVariantNormal)
        Graphics.setFont(statsFont, Graphics.font.kVariantBold)
        Graphics.setFont(statsFont, Graphics.font.kVariantItalic)
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
        for columnIndex, column in ipairs(columns) do
            local x = cfg.panel.x + (columnIndex - 1) * cfg.columnGap
            local y = startY
            for _, row in ipairs(column) do
                if row.header then
                    Graphics.drawText(label(row.header), x, y)
                    -- Nano Sans is 10px tall on an 11px line, so the rule sits in the 1px
                    -- gutter: clear of this header's baseline and of the next row's top.
                    local ruleY = y + cfg.lineHeight - 1
                    Graphics.drawLine(x, ruleY, x + cfg.valueRight, ruleY)
                elseif not row.blank then
                    Graphics.drawText(label(row[1]), x, y)
                    Graphics.drawTextAligned(row[2], x + cfg.valueRight, y, kTextAlignment.right)
                end
                y = y + cfg.lineHeight
            end
        end
    Graphics.popContext()
end

function inGameMenu:drawCrewHats()
    -- Create sprites for captured crew member hats in the menu.
    -- Geometry lives in Config.CrewHats, which is also what caps the roster: totalCrew is
    -- derived from this grid's capacity, so every crew member has a slot by construction.
    local grid          = Config.CrewHats
    local hatX          = grid.x
    local hatY          = grid.y
    local hatSpacing    = grid.spacing
    local rowSpacing    = grid.rowSpacing
    local maxHatsPerRow = grid.columns

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
        -- Iterate the whole roster in id order so slots stay stable regardless of rescue
        -- order. Follows totalCrew rather than a literal: a hardcoded 21 meant any crew
        -- authored past the 21st would silently never show a hat.
        for i = 1, Config.MapGen.totalCrew do
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