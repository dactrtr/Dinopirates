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
    if not self.indicatorPosition then
        self:moveTo(self.player.x - 22, self.player.y-36)
        batteryCanister:moveTo(self.player.x - 22, self.player.y-36)
    end
    self.battery = PlayerData.battery
    local batteryPercent = (self.battery * (batteryCanister.width - 8)) / 100
    
    local batteryFill = Graphics.image.new(batteryCanister.width - 8, 6)
    
    Graphics.pushContext(batteryFill)
        Graphics.setColor(Graphics.kColorBlack)
        Graphics.fillRect(0, 0, batteryPercent,6)
    Graphics.popContext()
    self:setImage(batteryFill)
end
function Battery:removeAll()
    batteryCanister:remove()
    self:remove()
end


