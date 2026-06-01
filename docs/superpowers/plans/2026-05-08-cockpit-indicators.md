# Cockpit Indicators Rework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el indicador de progreso de secuencia (rectángulos → círculos 8×8) y agregar una barra de intentos fallidos debajo que lleva a TitleScene cuando se llena.

**Architecture:** Todo el cambio vive en `CockpitScene.lua` (variables locales + `drawBackground` + `pressButton`) y en `Config.lua` (nuevo valor `failLimit`). No se crean archivos nuevos.

**Tech Stack:** Playdate Lua SDK, Noble Engine. `Graphics.fillCircleAtPoint` / `Graphics.drawCircleAtPoint` para los círculos.

---

## File Map

| Archivo | Cambio |
|---------|--------|
| `source/assets/data/Config.lua` | Añadir `failLimit` a `Config.Cockpit` |
| `source/scenes/CockpitScene.lua` | Añadir `failCount`, modificar `pressButton`, reescribir `drawBackground` |

---

## Task 1: Añadir `failLimit` a Config.Cockpit

> Este es el único lugar donde cambiar el límite de intentos fallidos más adelante.

**Files:**
- Modify: `source/assets/data/Config.lua:209-214`

- [ ] **Step 1: Añadir la clave en Config.Cockpit**

Reemplazar el bloque actual:
```lua
Config.Cockpit = {
    lerpFactor       = 0.15,
    accelSensitivity = 2.0,
    pointerRadius    = 6,
    dpadSpeed        = 3,
}
```
Por:
```lua
Config.Cockpit = {
    lerpFactor       = 0.15,
    accelSensitivity = 2.0,
    pointerRadius    = 6,
    dpadSpeed        = 3,
    failLimit        = 10,  -- ← cambiar aquí para ajustar cuántos fallos llevan a TitleScene
}
```

---

## Task 2: Añadir variable `failCount` y limpiarla al entrar

**Files:**
- Modify: `source/scenes/CockpitScene.lua`

- [ ] **Step 1: Declarar `failCount` junto con las otras variables locales del módulo**

Al inicio del archivo, justo después de `local radar = nil` (línea 21), añadir:
```lua
local failCount  = 0
```

- [ ] **Step 2: Resetear `failCount` en `scene:enter()`**

En `scene:enter()`, junto con `resetAllSequences()` (línea 109), añadir:
```lua
failCount = 0
```

El bloque queda así:
```lua
resetAllSequences()
failCount = 0
```

---

## Task 3: Modificar `pressButton` para contar fallos y disparar TitleScene

**Files:**
- Modify: `source/scenes/CockpitScene.lua` — función `pressButton` (líneas 43-56)

- [ ] **Step 1: Reescribir `pressButton` para detectar si alguna secuencia avanzó**

Reemplazar la función completa:
```lua
local function pressButton(label)
    for _, seq in ipairs(sequences) do
        if label == seq.pattern[seq.index] then
            seq.index += 1
            if seq.index > #seq.pattern then
                resetAllSequences()
                seq.action()
                return
            end
        else
            seq.index = 1
        end
    end
end
```
Por:
```lua
local function pressButton(label)
    local advanced = false
    for _, seq in ipairs(sequences) do
        if label == seq.pattern[seq.index] then
            seq.index += 1
            advanced = true
            if seq.index > #seq.pattern then
                resetAllSequences()
                failCount = 0
                seq.action()
                return
            end
        else
            seq.index = 1
        end
    end
    if not advanced then
        failCount += 1
        if failCount >= Config.Cockpit.failLimit then
            Noble.transition(TitleScene, 0.3, Noble.Transition.MetroNexus)
        end
    end
end
```

> **Nota de diseño:** `advanced = true` si el botón hizo avanzar AL MENOS una secuencia. Solo si no avanzó ninguna se considera fallo. `failCount` se resetea al completar una secuencia con éxito.

---

## Task 4: Reescribir `drawBackground` con los dos nuevos indicadores

**Files:**
- Modify: `source/scenes/CockpitScene.lua` — función `scene:drawBackground` (líneas 204-228)

**Layout visual:**
```
y=4  ○ ● ● ○  ← círculos de progreso (8×8, outline=pendiente, filled=completado)
y=18 [██░░░░]  ← barra de fallos (se llena, nunca se resetea, hasta failLimit)
```

- [ ] **Step 1: Reemplazar el bloque completo de `drawBackground`**

```lua
function scene:drawBackground()
    scene.super.drawBackground(self)

    if bgImage then bgImage:draw(0, 0) end

    local leading = leadingSequence()
    local filled  = leading.index - 1
    local n       = #leading.pattern

    -- Indicador 1: círculos de progreso de secuencia (8×8, radio=4)
    local circleD  = 8
    local circleR  = 4
    local circleGap = 4
    local rowW     = n * circleD + (n - 1) * circleGap
    local startX   = math.floor(200 - rowW / 2) + circleR
    local circleY  = 8

    Graphics.setColor(Graphics.kColorBlack)
    for i = 1, n do
        local cx = startX + (i - 1) * (circleD + circleGap)
        if i <= filled then
            Graphics.fillCircleAtPoint(cx, circleY, circleR)
        else
            Graphics.drawCircleAtPoint(cx, circleY, circleR)
        end
    end

    -- Indicador 2: barra de intentos fallidos (no se resetea)
    local barY      = 18
    local barH      = 5
    local barMargin = 40
    local barTotalW = 400 - barMargin * 2
    local barFillW  = math.floor(barTotalW * (failCount / Config.Cockpit.failLimit))

    Graphics.setColor(Graphics.kColorBlack)
    Graphics.drawRect(barMargin, barY, barTotalW, barH)
    if barFillW > 0 then
        Graphics.fillRect(barMargin, barY, barFillW, barH)
    end
end
```

---

## Task 5: Verificar en el simulador

No hay test runner — validar visualmente.

- [ ] **Step 1: Compilar**

```bash
cd /Users/dactrtr-mini/Documents/GitHub/Dinopirates
pdc source "DinoPirates from inner space Brocolation.pdx"
```

Esperado: sin errores de compilación.

- [ ] **Step 2: Abrir en simulador**

```bash
open "DinoPirates from inner space Brocolation.pdx"
```

- [ ] **Step 3: Navegar a CockpitScene y verificar**

Checklist visual:
- [ ] Los círculos de progreso se ven en la parte superior (círculos outline vacíos al inicio)
- [ ] Al presionar un botón correcto, un círculo se rellena (filled)
- [ ] Al completar una secuencia, los círculos vuelven a outline (reset)
- [ ] La barra de fallos aparece debajo de los círculos, vacía al inicio
- [ ] Al presionar un botón incorrecto, la barra se incrementa
- [ ] La barra de fallos NO se resetea al completar una secuencia correcta
- [ ] Al llegar a `failLimit` (default 10) fallos, hace transición a TitleScene

- [ ] **Step 4: Probar el ajuste de `failLimit`**

Cambiar `failLimit = 3` en `Config.lua`, recompilar, verificar que con 3 fallos lleva a TitleScene. Volver a `failLimit = 10`.

---

## Referencia rápida: "¿Dónde cambio el límite de fallos?"

**`source/assets/data/Config.lua`, línea dentro de `Config.Cockpit`:**
```lua
failLimit = 10,  -- ← aquí
```
