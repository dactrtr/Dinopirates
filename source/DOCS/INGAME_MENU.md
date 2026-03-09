# In-Game Equipment Menu

The in-game menu (`inGameMenu.lua`) is a specialized UI overlay that allows the player to pause the game, view the map, see collected crew member hats, and equip active items (Lamp, Boots, Plungerang).

---

## 🎮 Playdate Implementation

### 1. Structure
Path: `entities/UI/inGameMenu.lua`

The menu is an extension of `Graphics.sprite`.
- **Z-Index:** Set very high (`ZIndex.menu` and above) to draw over everything else.
- **Components:**
  - A background image (`menuImage`) showing the UI frame.
  - A map overlay drawn directly onto the menu image (`MapDrawer.drawMap`).
  - Icons for the available items (Lamp, Boots, Plungerang), managed via `itemMenu` components.
  - Grid of collected crew member hats, instantiated on the fly when the menu opens (`drawCrewHats`).

### 2. State Management
The menu state is tightly coupled with two global variables in `_G.PlayerData`:
- `PlayerData.isGaming`: When `false`, standard game mechanics and inputs are disabled.
- `PlayerData.isEquiping`: When `true`, it flags the system that the equipment menu is active and hijacking the input.

### 3. Usage & Input Handling
Located primarily in `scenes/MazeScene.lua`.

- **Opening the menu (A Button Held):**
  Holding the **A Button** for 1 second (`AButtonHeld`) triggers `inGameEquip:displayMenu()`. This sets `isGaming = false` and `isEquiping = true`, pausing standard action and showing the menu overlay.
  
- **Navigating (D-pad Left/Right):**
  When `isEquiping` is `true`, pressing Left or Right (`leftButtonDown` / `rightButtonDown`) calls `inGameEquip:prevItem()` and `inGameEquip:nextItem()`. These functions cycle the `PlayerData.activeItem` integer (1: Lamp, 2: Boots, 3: Plungerang), guaranteeing it only selects items the player actually owns.

- **Selecting (A Button):**
  Pressing the **A Button** (`AButtonDown`) while the menu is open will invoke `inGameEquip:selectItem()`, committing the selection.

- **Closing the menu (B Button):**
  Pressing the **B Button** (`BButtonDown`) sets `isGaming = true`, `isEquiping = false`, and invokes `inGameEquip:closeMenu()`, destroying the temporary sprites and returning logic to the main game.

---

## 🔁 Love2D Implementation Example

When porting to Love2D, the logic will likely transfer from being a `Graphics.sprite` to standard `love.graphics.draw()` calls inside your main Game State, with inputs handled in `love.keypressed`.

### Example: Basic Structure in Love2D

```lua
-- InGameMenu.lua
InGameMenu = {}

function InGameMenu:load()
    self.menuImage = love.graphics.newImage("assets/images/ui/menu/ingame-menu.png")
    self.font = love.graphics.newFont(16)
    
    self.items = {
        { id = 1, name = "Lamp", hasItem = "hasLamp" },
        { id = 2, name = "Boots", hasItem = "hasBoots" },
        { id = 3, name = "Plungerang", hasItem = "hasPlunger" }
    }
end

function InGameMenu:getActiveSkills()
    local active = {}
    for _, item in ipairs(self.items) do
        if PlayerData.items[item.hasItem] then
            table.insert(active, item)
        end
    end
    return active
end

function InGameMenu:draw()
    if not PlayerData.isEquiping then return end

    -- Draw Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw Menu Box
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.menuImage, 400, 300, 0, 1, 1, self.menuImage:getWidth()/2, self.menuImage:getHeight()/2)
    
    -- Draw Skills/Items
    local activeSkills = self:getActiveSkills()
    for i, skill in ipairs(activeSkills) do
        if PlayerData.activeItem == skill.id then
            love.graphics.setColor(1, 1, 0, 1) -- Highlight selected item in yellow
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.print(skill.name, 350, 200 + (i * 30))
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function InGameMenu:nextItem()
    local skills = self:getActiveSkills()
    if #skills == 0 then return end
    
    local currentIndex = 1
    for i, skill in ipairs(skills) do
        if skill.id == PlayerData.activeItem then
            currentIndex = i
            break
        end
    end
    
    currentIndex = currentIndex + 1
    if currentIndex > #skills then currentIndex = 1 end
    PlayerData.activeItem = skills[currentIndex].id
end

function InGameMenu:prevItem()
    local skills = self:getActiveSkills()
    if #skills == 0 then return end
    
    local currentIndex = 1
    for i, skill in ipairs(skills) do
        if skill.id == PlayerData.activeItem then
            currentIndex = i
            break
        end
    end
    
    currentIndex = currentIndex - 1
    if currentIndex < 1 then currentIndex = #skills end
    PlayerData.activeItem = skills[currentIndex].id
end
```

### Example: Integration in `GameState` (Love2D)

```lua
-- main.lua or GameState.lua

function love.load()
    InGameMenu:load()
    
    -- Mocking PlayerData for the example
    PlayerData = {
        isGaming = true,
        isEquiping = false,
        activeItem = 1,
        items = {
            hasLamp = true,
            hasBoots = true,
            hasPlunger = true,
            hasDWatch = true
        }
    }
end

function love.update(dt)
    if PlayerData.isGaming then
        -- Update game world, player, enemies
    elseif PlayerData.isEquiping then
        -- Menu is open, game world is paused
        -- You might want to update animations or menu specific timers here
    end
end

function love.draw()
    -- Draw your game world and entities here
    -- ...

    -- Draw UI on top
    if PlayerData.isEquiping then
        InGameMenu:draw()
    end
end

function love.keypressed(key)
    if not PlayerData.isEquiping then
        -- Open Menu logic
        -- In love2d, to mimic "button held", you might need to track key times in love.update
        -- For a simple toggle:
        if key == "tab" and PlayerData.items.hasDWatch then
            PlayerData.isGaming = false
            PlayerData.isEquiping = true
        end
    else
        -- Menu Input Logic
        if key == "right" or key == "d" then
            InGameMenu:nextItem()
        elseif key == "left" or key == "a" then
            InGameMenu:prevItem()
        elseif key == "escape" or key == "tab" then
            -- Close Menu
            PlayerData.isGaming = true
            PlayerData.isEquiping = false
        elseif key == "return" or key == "space" then
            -- Select Item (Optional, activeItem updates instantly in this design)
            print("Selected item: " .. PlayerData.activeItem)
        end
    end
end
```

### Key Differences
- **Rendering:** In Playdate, `Graphics.sprite` automatically adds the menu to the display list. In Love2D, you explicitly call your `InGameMenu:draw()` sequence inside `love.draw()` only when `isEquiping` is true.
- **Input:** Playdate's `Noble.Input` handler allows functions like `AButtonHeld`. In Love2D, `love.keypressed(key)` fires once per stroke. To detect a held button natively, you check `love.keyboard.isDown("key")` in `love.update(dt)` and accumulate a timer before triggering the menu, or just bind it to a single press (like `tab` or `start` on a gamepad).
