Battery = {}
class('Battery').extends(Graphics.sprite)

import 'entities/UI/batteryCanister'

function Battery:init(x, y, player, Zindex, indicator)
    self.player = player
    self.indicatorPosition = indicator
    batteryCanister = BatteryCanister(x,y,Zindex)
    self:setZIndex(Zindex-1)
    self:moveTo(x,y)
    self:add(0,0)
end

function Battery:update()
    if self.indicatorPosition then
        self:moveTo(self.player.x - 16, self.player.y-36)
        batteryCanister:moveTo(self.player.x - 16, self.player.y-36)
    end
    self.battery = self.player.battery
    local batteryPercent = (self.battery * batteryCanister.width - 4) / 100
    
    local batteryFill = Graphics.image.new(batteryCanister.width - 4, 6)
    
    Graphics.pushContext(batteryFill)
        Graphics.setColor(Graphics.kColorWhite)
        Graphics.fillRect(0, 0, batteryPercent,6)
    Graphics.popContext()
    self:setImage(batteryFill)
end
function Battery:removeAll()
    batteryCanister:remove()
    self:remove()
end


