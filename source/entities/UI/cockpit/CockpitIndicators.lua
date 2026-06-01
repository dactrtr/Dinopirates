class("CockpitIndicators").extends(Graphics.sprite)

function CockpitIndicators:init()
    CockpitIndicators.super.init(self)
    self.filled   = 0
    self.total    = 4
    self.failFill = 0

    self:setSize(400, 28)
    self:setZIndex(ZIndex.ui)
    self:setIgnoresDrawOffset(true)
    self:moveTo(200, 14)
    self:add()
end

function CockpitIndicators:setData(filled, total, failFill)
    self.filled   = filled
    self.total    = total
    self.failFill = failFill
    self:markDirty()
end

function CockpitIndicators:draw(x, y, w, h)
    local n         = self.total
    local circleR   = 4
    local circleD   = circleR * 2
    local circleGap = 4
    local rowW      = n * circleD + (n - 1) * circleGap
    local startX    = math.floor(200 - rowW / 2) + circleR
    local circleY   = 8

    Graphics.setColor(Graphics.kColorBlack)
    for i = 1, n do
        local cx = startX + (i - 1) * (circleD + circleGap)
        if i <= self.filled then
            Graphics.fillCircleAtPoint(cx, circleY, circleR)
        else
            Graphics.drawCircleAtPoint(cx, circleY, circleR)
        end
    end

    local barY      = 18
    local barH      = 5
    local barMargin = 40
    local barTotalW = 400 - barMargin * 2
    local barFillW  = math.floor(math.min(barTotalW, barTotalW * self.failFill))

    Graphics.setColor(Graphics.kColorBlack)
    Graphics.drawRect(barMargin, barY, barTotalW, barH)
    if barFillW > 0 then
        Graphics.fillRect(barMargin, barY, barFillW, barH)
    end
end
