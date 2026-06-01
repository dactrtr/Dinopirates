---
name: Noble Engine input handler callback names
description: Correct callback names for Noble Engine input handlers, including d-pad hold behavior and when to use playdate.buttonIsPressed() instead
type: feedback
---

Noble Engine's input handler uses these exact callback names (note: `Hold` not `Held`):

**A/B buttons:**
- `AButtonDown`, `AButtonUp`, `AButtonHeld` (fires once after 1 second hold)
- `BButtonDown`, `BButtonUp`, `BButtonHeld`

**D-pad:**
- `upButtonDown`, `upButtonUp`, `upButtonHold`
- `downButtonDown`, `downButtonUp`, `downButtonHold`
- `leftButtonDown`, `leftButtonUp`, `leftButtonHold`
- `rightButtonDown`, `rightButtonUp`, `rightButtonHold`

**Why:** The `Hold` callbacks fire only after a `buttonHoldBufferAmount` delay (not every frame from the first press). Using `Held` (wrong name) silently does nothing.

**How to apply:** For per-frame continuous movement (e.g. pointer, cursor), skip the input handler entirely and use `playdate.buttonIsPressed(playdate.kButtonUp/Down/Left/Right)` directly in `scene:update()`. This gives immediate, zero-delay response every frame. The input handler `Hold` callbacks are better suited for menu navigation (where the buffer delay is intentional).
