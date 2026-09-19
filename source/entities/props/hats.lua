
Hats = {}
class('Hats').extends(NobleSprite)

-- Frames actually present in the hats spritesheet. Read from the image rather than
-- hardcoded, so adding hat art is the only step needed to support more crew.
local hatFrameCount <const> = #Graphics.imagetable.new('assets/images/props/hats')

function Hats:init(x, y, type, zIndex)
  Hats.super.init(self,'assets/images/props/hats', true)
  -- error handling
  if type == nil then
    type = 'CM001'
  end
  --- animation states, one per crew id (CM001 -> frame 1, CM002 -> frame 2, ...).
  -- Generated rather than written out: these were 21 hand-listed addState lines, a third
  -- copy of the roster size alongside Config.MapGen.totalCrew and inGameMenu's hat loop.
  -- Capped at the spritesheet's actual frame count so growing the roster before drawing
  -- the new hats can't register a state pointing at a frame that doesn't exist.
  local hatCount = math.min(Config.MapGen.totalCrew, hatFrameCount)
  local known = {}
  for i = 1, hatCount do
    local id = string.format('CM%03d', i)
    self.animation:addState(id, i, i)
    known[id] = true
  end

  -- Resolve the hat: accept a number or a "CMxxx" string; fall back to CM001 if nil or
  -- unknown (e.g. a crew spawn marker without a valid crewID, or a crew id whose hat art
  -- has not been drawn yet).
  local n = tonumber(type)
  if n then type = string.format('CM%03d', n) end
  if not (type and known[type]) then type = 'CM001' end
  self.animation:setState(type)
  -- position and z-index
  self:setSize(20, 16)
  self:setZIndex(zIndex)
  self:setGroups(3)
  self:add(x,y)
end


