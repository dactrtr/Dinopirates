CreditsScene = {}
class("CreditsScene").extends(NobleScene)
local scene = CreditsScene

-- Scroll speeds (px/frame)
local SCROLL_SPEED      = 1
local SCROLL_SPEED_FAST = 3
-- Layout
local LINE_HEIGHT    = 20   -- height of a text item
local ITEM_SPACING   = 16   -- vertical gap between items
local START_OFFSET   = 260  -- initial Y of first item (just below screen bottom)

-- Edit this table to change the credits content.
-- Three item types:
--   { type = "text",  value = "string" }  — white text, centered at x=200
--   { type = "image", path = "assets/..." } — image centered horizontally
--   { type = "space", height = N }          — empty vertical gap
local credits = {
    { type = "space", height = 20 },
    { type = "text",  value = "DinoPirates from Inner Space" },
    { type = "text",  value = "Brocolation" },
    { type = "space", height = 30 },
    { type = "text",  value = "A game by" },
    { type = "space", height = 8 },
    { type = "text",  value = "Sebastian Andres Guillermo Zuniga Rivas" },
    { type = "text",  value = "A.K.A" },
    { type = "text",  value = "dactrtr.rocks" },
    { type = "space", height = 30 },
    { type = "text",  value = "Music" },
    { type = "space", height = 8 },
    { type = "text",  value = "Alan Muñoz" },
    { type = "space", height = 30 },
    { type = "text",  value = "Cursor pack and Input Prompts Pixel 1-Bit by:" },
    { type = "image", path = "assets/credits/credits-kenney.png" },
    { type = "space", height = 30 },
    { type = "text",  value = "Special thanks to:" },
    { type = "space", height = 8 },
    { type = "text",  value = "Jacob Wilschrey - Dev help" },
    { type = "text",  value = "Christian Padilla - Game test" },
    { type = "space", height = 8 },
    { type = "text",  value = "This game wouldnt been possible " },
    { type = "text",  value = "without the support and love of" },
    { type = "text",  value = "Jenna Heo" },
    { type = "space", height = 40 },
    { type = "text",  value = "Thanks for playing!" },
    { type = "space", height = 80 },
    { type = "image", path = "assets/credits/credits-tangara.png" },
    { type = "space", height = 60 },
   
}

scene.backgroundColor = Graphics.kColorBlack

-- Module-local state (reset in enter())
local scrollY        = 0
local isHoldingA     = false
local totalHeight    = 0
local loadedImages   = {}
local isDone         = false  -- guard: prevents Noble.transition from firing every frame

CreditsScene.inputHandler = {
    AButtonDown = function() isHoldingA = true  end,
    AButtonUp   = function() isHoldingA = false end,
    BButtonDown = function() Noble.transition(TitleScene) end,
}

-- Returns the draw height of a single item.
local function itemHeight(item)
    if item.type == "text" then
        return LINE_HEIGHT
    elseif item.type == "image" then
        local img = loadedImages[item.path]
        if img then
            local _, h = img:getSize()
            return h
        end
        return 0
    elseif item.type == "space" then
        return item.height
    end
    return 0
end

function scene:init()
    scene.super.init(self)
end

function scene:enter()
    scene.super.enter(self)

    scrollY      = 0
    isHoldingA   = false
    loadedImages = {}
    isDone       = false

    -- CreditsScene has no sprites, so the Playdate sprite system won't
    -- generate dirty regions to trigger drawBackground. Force an explicit
    -- redraw so the black background is applied immediately on enter.
    Graphics.sprite.redrawBackground()

    -- Preload all images so drawBackground() never reads from disk
    for _, item in ipairs(credits) do
        if item.type == "image" and not loadedImages[item.path] then
            local img = Graphics.image.new(item.path)
            if img then
                loadedImages[item.path] = img
            else
                printDebug("⚠️ Credits: image not found:", item.path)
            end
        end
    end

    -- Compute total scroll distance needed
    totalHeight = 0
    for i, item in ipairs(credits) do
        totalHeight = totalHeight + itemHeight(item)
        if i < #credits then
            totalHeight = totalHeight + ITEM_SPACING
        end
    end
end

function scene:update()
    scene.super.update(self)

    local speed = isHoldingA and SCROLL_SPEED_FAST or SCROLL_SPEED
    scrollY = scrollY + speed
    Graphics.sprite.redrawBackground()

    -- All content has scrolled past the top of the screen
    if not isDone and scrollY >= START_OFFSET + totalHeight then
        isDone = true
        Noble.transition(TitleScene)
    end
end

function scene:drawBackground()
    scene.super.drawBackground(self)

    local y = START_OFFSET - scrollY

    for _, item in ipairs(credits) do
        local h = itemHeight(item)

        if y + h >= 0 and y <= 240 then
            if item.type == "text" then
                Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
                Graphics.drawTextAligned(item.value, 200, y, kTextAlignment.center)
            elseif item.type == "image" then
                local img = loadedImages[item.path]
                if img then
                    local w, _ = img:getSize()
                    Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
                    img:draw(200 - w // 2, y)
                end
            end
            -- "space": nothing to draw
        end

        y = y + h + ITEM_SPACING
    end
end

function scene:exit()
    scene.super.exit(self)
    loadedImages = {}
end

function scene:finish()
    scene.super.finish(self)
    Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
end
