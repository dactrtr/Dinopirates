MapBG = {}
class('MapBG').extends(Graphics.sprite)

local maze <const> = Graphics.image.new("assets/images/ui/map.png")
local fog <const> = Graphics.image.new(maze:getSize())

function MapBG:init()
    self:setImage(maze)
    self:setZIndex(ZIndex.ui)
    self:moveTo(16,34)
    self:add()
end

Map = {}

class('Map').extends(Graphics.sprite)

function Map:init()
    self:setImage(fog)
    self:setZIndex(ZIndex.ui+1)
    self:moveTo(16,34)
    mapbg = MapBG()
       
    --    Graphics.pushContext(maze)
    -- 
    --         Graphics.setColor(Graphics.kColorBlack)
    --         Graphics.setDitherPattern(alpha, Graphics.image.        kDitherTypeBayer8x8)
    --         Graphics.fillRect(4, 4, roomSize,roomSize)
    -- 
    --     Graphics.popContext()
       -- Graphics.pushContext(maze)
          -- 
          --     Graphics.setColor(Graphics.kColorBlack)
          --     Graphics.fillRect(6, 18, 3,3)
          -- 
          -- Graphics.popContext()
      
    local alpha = 0.5
    local roomSize = 7
    local row = 0
    local col = 0
    fog:clear(Graphics.kColorClear)
                   
     for i = 1, 9 do 
         if rooms[i].visited == false then 
             
             col = (i - 1) % 3
             row = math.floor((i - 1) / 3)
             
             Graphics.pushContext(fog)
             
             Graphics.setColor(Graphics.kColorBlack)
             Graphics.setDitherPattern(alpha, Graphics.image.kDitherTypeBayer8x8)
             Graphics.fillRect(4 + (col * 6), 4 + (row * 6), roomSize, roomSize)
             
             Graphics.popContext() 
         end
     end
    self:add()
end

function Map:update()
    
end


