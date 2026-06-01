class("CockpitButton").extends(Graphics.sprite)

function CockpitButton:init(x, y, w, h, label)
    CockpitButton.super.init(self)
    self.label = label
    self.w     = w
    self.h     = h

    local img = Graphics.image.new(w, h, Graphics.kColorClear)
    Graphics.pushContext(img)
        -- Face
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillRect(0, 0, w, h)
        -- Outer border
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.drawRect(0, 0, w, h)
        -- Inner shadow on bottom + right (raised 3D effect)
        Graphics.drawLine(1, h - 2, w - 2, h - 2)
        Graphics.drawLine(w - 2, 1, w - 2, h - 2)
        -- Label
        Graphics.setImageDrawMode(Graphics.kDrawModeFillBlack)
        local fontH = shinonome:getHeight()
        Graphics.drawTextAligned(label, w / 2 - 1, math.floor(h / 2 - fontH / 2), kTextAlignment.center)
        Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
    Graphics.popContext()

    self:setImage(img)
    self:setZIndex(ZIndex.ui)
    self:setVisible(debug == true)
    self:moveTo(x, y)
    self:add()
end

function CockpitButton:update()
    self:setVisible(debug == true)
end

function CockpitButton:isHovered(px, py)
    local bx, by = self:getPosition()
    return px >= bx - self.w / 2 and px <= bx + self.w / 2
       and py >= by - self.h / 2 and py <= by + self.h / 2
end
