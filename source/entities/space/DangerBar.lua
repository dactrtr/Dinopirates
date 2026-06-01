class('DangerBar').extends(Graphics.sprite)

function DangerBar:init()
    self.lastDanger = -1
    self.img        = Graphics.image.new(4, 224, Graphics.kColorClear)
    self:setZIndex(ZIndex.ui + 5)
    self:setImage(self.img)
    self:moveTo(390, 120)
    self:add()
    self:setDanger(0)
end

function DangerBar:setDanger(danger)
    if danger == self.lastDanger then return end
    self.lastDanger = danger
    self.img:clear(Graphics.kColorClear)
    Graphics.pushContext(self.img)
        Graphics.setColor(Graphics.kColorWhite)
        local fillH = math.floor(danger * 224)
        Graphics.fillRect(0, 224 - fillH, 4, fillH)
    Graphics.popContext()
    self:markDirty()
end
