CockpitRadar = {}
class("CockpitRadar").extends(Graphics.sprite)

local COLS        = 8
local ROWS        = 5
local APPEAR_RATE = 0.04
local FADE_RATE   = 0.03

-- dot geometry (fits inside 80×60 with 1px border)
-- inner area: 76×56 px
-- 8 cols × 4px + 7 gaps × 4px = 60 → 8px padding each side
-- 5 rows × 8px + 4 gaps × 4px = 56 → 0px padding top/bottom
local DOT_W  = 4
local DOT_H  = 8
local GAP_X  = 4
local GAP_Y  = 4
local PAD_X  = 8
local PAD_Y  = 0

function CockpitRadar:init(x, y, w, h)
    CockpitRadar.super.init(self)
    self.rw   = w
    self.rh   = h
    self.dots = {}

    for row = 1, ROWS do
        self.dots[row] = {}
        for col = 1, COLS do
            self.dots[row][col] = math.random() < 0.3
        end
    end

    self:setSize(w, h)
    self:setZIndex(ZIndex.ui)
    self:moveTo(x, y)
    self:add()
end

function CockpitRadar:update()
    local dirty = false
    for row = 1, ROWS do
        for col = 1, COLS do
            if self.dots[row][col] then
                if math.random() < FADE_RATE then
                    self.dots[row][col] = false
                    dirty = true
                end
            else
                if math.random() < APPEAR_RATE then
                    self.dots[row][col] = true
                    dirty = true
                end
            end
        end
    end
    if dirty then self:markDirty() end
end

function CockpitRadar:draw(x, y, width, height)
    Graphics.setColor(Graphics.kColorWhite)
    Graphics.fillRect(0, 0, self.rw, self.rh)
    Graphics.setColor(Graphics.kColorBlack)
    Graphics.drawRect(0, 0, self.rw, self.rh)

    local startX = 2 + PAD_X
    local startY = 2 + PAD_Y

    for row = 1, ROWS do
        for col = 1, COLS do
            if self.dots[row][col] then
                local dx = startX + (col - 1) * (DOT_W + GAP_X)
                local dy = startY + (row - 1) * (DOT_H + GAP_Y)
                Graphics.fillRect(dx, dy, DOT_W, DOT_H)
            end
        end
    end
end
