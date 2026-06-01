class('HealthDisplay').extends(Graphics.sprite)

function HealthDisplay:init(x, y)
    self.circles = {}
    HealthDisplay.super.init(self)

    local img = Graphics.image.new(8, 8, Graphics.kColorClear)
    Graphics.pushContext(img)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillCircleAtPoint(4, 4, 2)
    Graphics.popContext()

    local startY = y - 8  -- center 3 circles vertically around y
    for i = 1, 3 do
        local s = Graphics.sprite.new(img)
        s:setZIndex(ZIndex.ui + 2)
        s:moveTo(x, startY + (i - 1) * 8)
        s:add()
        self.circles[i] = s
    end
    -- intentionally not calling self:add() — this class is just a manager
end

function HealthDisplay:setHealth(health)
    for i = health + 1, 3 do
        if self.circles[i] then
            self.circles[i]:remove()
            self.circles[i] = nil
        end
    end
end

function HealthDisplay:moveTo(x, y)
    local startY = y - 8
    for i = 1, 3 do
        if self.circles[i] then
            self.circles[i]:moveTo(x, startY + (i - 1) * 8)
        end
    end
end

function HealthDisplay:remove()
    for i = 1, 3 do
        if self.circles[i] then
            self.circles[i]:remove()
            self.circles[i] = nil
        end
    end
end
