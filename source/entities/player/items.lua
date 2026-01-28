
function Player:grabBoots()
  PlayerData.items.hasBoots = true
  PlayerData.skills.canDash = true
  self:fillBattery()
end

function Player:grabPlunger()
  PlayerData.items.hasPlunger = true
  PlayerData.skills.canPlungerang = true
  self:fillBattery()
end

function Player:grabKey(keyNumber)
  keyNumber = keyNumber or 1  -- Default to key 1 if no number provided
  PlayerData.keys[keyNumber] = true
end

function Player:grabLamp()
  PlayerData.items.hasLamp = true
  PlayerData.skills.canFlash = true
  self:fillBattery()
end

function Player:grabRadio()
  PlayerData.items.hasRadio = true
end

function Player:processGrants(grants, targetTable)
  if not grants or grants == "" then return end
  
  -- Parse "key1:value1,key2:value2"
  for pair in string.gmatch(grants, "([^,]+)") do
    local key, value = string.match(pair, "([^:]+):([^:]+)")
    if key and value then
      key = key:gsub("%s+", "")
      value = value:gsub("%s+", "")
      
      -- Convert value to boolean if possible
      local val = value
      if value == "true" then val = true
      elseif value == "false" then val = false
      elseif tonumber(value) then val = tonumber(value)
      end
      
      targetTable[key] = val
      printDebug("🎁 Granted:", key, "=", val)
    end
  end
end

function Player:grabItemGift(grants)
  self:processGrants(grants, PlayerData.items)
  -- Optionally fill battery or other effects if needed
end

function Player:grabNotes(grants)
  if grants then
    self:processGrants(grants, PlayerData.skills)
  else
  end
end


