# Enemy Knockback Implementation Design

**Date:** 2026-05-15  
**Status:** Approved

---

## Summary

When the player takes damage from a Brocorat and invincibility starts, apply a 2-pixel knockback that pushes the player away from the enemy using `moveWithCollisions` so walls are respected.

---

## Architecture

Three files change. No new files.

### `assets/data/Config.lua`

Add `knockbackDistance` under `Config.Player`:

```lua
Config.Player = {
    -- existing fields ...
    knockbackDistance = 2,
}
```

### `entities/player/state.lua`

New method `Player:applyKnockback(enemyX, enemyY)`:

```lua
function Player:applyKnockback(enemyX, enemyY)
    local k = Config.Player.knockbackDistance
    local dx = (self.x ~= enemyX) and ((self.x > enemyX) and k or -k) or 0
    local dy = (self.y ~= enemyY) and ((self.y > enemyY) and k or -k) or 0
    self:moveWithCollisions(self.x + dx, self.y + dy)
end
```

- Direction computed per axis from sign of `(self - enemy)` position difference.
- If player and enemy share an axis exactly, that axis contributes 0 (no movement on that axis).
- `moveWithCollisions` ensures the player stops at walls rather than clipping through.

### `entities/player/collisions.lua`

In the Brocorat hit block, call `applyKnockback` immediately after `startInvincibility`:

```lua
self:startInvincibility(Config.Invincibility.duration)
self:applyKnockback(other.x, other.y)
```

The `other` reference is already available in `collisionResponse(other)`.

---

## What Does NOT Change

- `Player:fight()` path (HP below threshold → DanceScene) — no knockback on that branch
- Invincibility timer and flicker logic — untouched
- All other collision types (CrewMember, Door, Items, Props) — untouched

---

## Out of Scope

- Knockback on `fight()` trigger (would be disorienting before a scene transition)
- Multi-frame knockback animation or velocity decay
- Knockback for non-Brocorat enemies
