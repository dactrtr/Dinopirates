CockpitBars = {}
class("CockpitBars").extends(Graphics.sprite)

local BAR_COUNT   = 5
local LERP_SPEED  = 0.06
local CHANGE_RATE = 0.03  -- probability per frame each bar picks a new target

function CockpitBars:init(x, y, w, h)
    CockpitBars.super.init(self)
    self.bw   = w
    self.bh   = h
    self.bars = {}

    for i = 1, BAR_COUNT do
        local v = math.random()
        self.bars[i] = { current = v, target = v }
    end

    self:setSize(w, h)
    self:setZIndex(ZIndex.ui)
    self:moveTo(x, y)
    self:add()
end

function CockpitBars:update()
    for _, bar in ipairs(self.bars) do
        if math.random() < CHANGE_RATE then
            bar.target = math.random()
        end
        bar.current = bar.current + (bar.target - bar.current) * LERP_SPEED
    end
    self:markDirty()
end

function CockpitBars:draw(x, y, width, height)
    local n   = #self.bars
    local gap = 2
    local rowH = math.floor((self.bh - 2 - gap * (n - 1)) / n)

    Graphics.setColor(Graphics.kColorWhite)
    Graphics.fillRect(0, 0, self.bw, self.bh)
    Graphics.setColor(Graphics.kColorBlack)
    Graphics.drawRect(0, 0, self.bw, self.bh)

    for i, bar in ipairs(self.bars) do
        local by   = 1 + (i - 1) * (rowH + gap)
        local barW = math.max(1, math.floor(bar.current * (self.bw - 4)))
        Graphics.fillRect(2, by, barW, rowH)
    end
end
