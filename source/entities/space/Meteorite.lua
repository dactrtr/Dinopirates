class('Meteorite').extends(Graphics.sprite)

function Meteorite:init(x, y, speed)
    Meteorite.super.init(self)

    self.imgTable   = Graphics.imagetable.new('assets/images/space/meteorite')
    self.frameCount = self.imgTable:getLength()
    self.counter    = math.random(1, 1000)
    self.baseSpeed  = speed or 1

    -- Set initial image so sprite isn't blank on first frame
    local f = math.max(1, math.min(self.frameCount, math.ceil(self.counter / 1000 * self.frameCount)))
    self:setImage(self.imgTable:getImage(f))
    self:setCollideRect(8, 8, 32, 32)
    self:setZIndex(ZIndex.props)
    self:moveTo(x, y)
    self:add()
end

-- Advance the approach counter and update frame. extraSpeed added on top of baseSpeed (ship velocity contribution).
function Meteorite:step(extraSpeed)
    self.counter = self.counter + self.baseSpeed + (extraSpeed or 0)
    if self.counter > 1000 then
        self.counter = 1
        self:moveTo(math.random(20, 380), math.random(20, 220))
    end
    local frame = math.max(1, math.min(self.frameCount, math.ceil(self.counter / 1000 * self.frameCount)))
    self:setImage(self.imgTable:getImage(frame))
end

-- Returns 0 (far) to 1 (at ship level). Collision only valid near 1.
function Meteorite:getZDepth()
    return self.counter / 1000
end

function Meteorite:scrollBy(dx, dy)
    self:moveTo(self.x + dx, self.y + dy)
end
