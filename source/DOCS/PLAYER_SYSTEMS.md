# Player Systems Documentation

This document explores the `PlayerData` structure and how its values influence the player's movement, survival, and interaction with the game world.

---

## 🔋 Core Resource: Battery
The Battery system is the primary driver of exploration and danger.

- **Consumption**:
    - Drains at **0.5 units per move** when `isInDarkness` is true.
    - Draining occurs in `Player:move` (in `movement.lua`) or via explicit `drainBattery(amount)` calls.
- **Impacts**:
    - **Speed**: If battery < 20 and in darkness, player speed is halved.
    - **Sanity**: Sanity drains faster if battery < 20.
    - **Movement**: If the player is in darkness and has no lamp or battery, they are significantly slowed.
- **Charging**:
    - The player can charge the battery using the crank (via `chargeBattery(amount)`).
    - Charging sets `isActive = true`, allowing enemies to move while the player stays in place.

---

## 🧠 Survival: Sanity & Calories
Sanity and Nutrition represent the player's mental and physical health.

- **Sanity**:
    - **Drain**: Occurs when in darkness with low battery.
    - **Regen**: Recharges if battery > 50 or the player is in light.
    - **Sanity Counter**: Every time sanity hits 0, the `sanityCounter` increments. This increases the global **Enemy Power Level**, making encounters more difficult.
- **Health**:
    - **Representation**: Stored as `healthPoints` (default 10).
    - **HUD**: Represented by 5 hearts, where each heart is 2 points (total 10 bits).
    - **Sync**: Updated in real-time in the HUD via the `HealthIndicator` class.
- **Calories & Steps**:
    - The `pedometer()` tracks steps. 200 steps = 10 calories burned.
    - **Calories** influence the difficulty roll of the `DanceScene`. Higher calories contribute to a higher probability of encountering "Badass" or "Boss" enemy profiles.

---

## 🏎️ State & Synchronization: `isActive`
The `isActive` flag is a critical internal value.

- **Turn-based Sync**: `isActive` is set to `true` whenever the player moves or charges.
- **NPC Movement**: Enemies and CrewMembers only process their AI movement when the player is active. This ensures that the world "moves when you move," allowing for strategic planning during battery management.
- **Tokens**: Moving distributes "Movement Frames" (3 per move) to all sprites, ensuring smooth following without unintended speed accumulation.

---

## 🤏 Transformation: Size & Collisions
- **`isTiny`**:
    - Toggled via the **Minifier** prop.
    - Changes the player's collision rectangle to a smaller **14x14** size.
    - Enables access to "Hole" props.
    - Changing size triggers specific `tiny` animation states for all directions.
- **`isBig`**: Managed via the transformation cycle, though currently less used than the tiny state in the primary maze logic.

---

## 🎒 Inventory & Skills
Items and skills can be granted either by picking up a fixed item type or dynamically via a `grants` field in level data (common for `itemgift` and `notes`).

- **Items**:
    - `hasLamp`: Enables vision and sanity regeneration. Grants **Lightburst** skill.
    - `hasBoots`: Provides "Hole" safety; player drains battery to walk over holes instead of falling. Grants **Dash** skill.
    - `hasPlunger`: Provides "Slime" safety; player can walk over slime instead of sliding. Grants **Plungerang** skill.
    - `hasBag`: Required to capture CrewMembers.
    - `hasRadio` / `hasNotes`: Story-relevant items that enable specific dialogs/video feeds.
    - `hasTools`: Story-relevant or utility item (used for certain environment interactions).
- **Skills**:
    - `canFlash` (Lightburst): Costs **10 battery**. Blinds enemies in a radius. Granted by `hasLamp`.
    - `canDash`: Costs **10 battery**. Enables a fast dash attack with a cooldown. Granted by `hasBoots`.
    - `canPlungerang`: Boomerang skill that can stun enemies or interact with props at a distance. Does not consume battery. Granted by `hasPlunger`.

> [!TIP]
> Always check `PlayerData.isInDarkness`. Most survival mechanics (Sanity drain, Battery drain, Speed debuffs) are gated by this boolean.
