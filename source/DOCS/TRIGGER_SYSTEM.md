# Sistema de Triggers Condicionales

Este sistema permite que los Triggers ejecuten diferentes scripts dependiendo del estado del jugador.

## 1. Configuración en LDTK

Agrega los siguientes **Custom Fields** a tu entidad `Triggers`:

*   **Identificador**: `conditionalScripts`
    *   **Tipo**: `Array<String>`
*   **Identificador**: `type`
    *   **Tipo**: `String` (Opciones: `Story`, `Cutscene`, `Search`, `Call`, `Counter`)

## 2. Tipos de Condiciones

Las condiciones en `conditionalScripts` siguen el formato `condicion:script`.

### A. Condiciones Booleanas
*   `isTiny:script` (Si es tiny)
*   `!isTiny:script` (Si NO es tiny)
*   `items.hasLamp:script` (Si tiene lámpara)

### B. Comparaciones Numéricas
Operadores soportados: `>`, `<`, `>=`, `<=`, `==`, `!=`
*   `mapPercent>50:midGameDialogue`
*   `battery<20:lowBatteryWarning`

## 3. Persistencia (IMPORTANTE)

Por defecto, los scripts condicionales **NO eliminan el trigger**. Esto es útil para mensajes de rechazo o pistas que el jugador puede volver a ver.

Para hacer que un script **SI elimine el trigger** (es decir, que sea de un solo uso), agrega `!` al final del nombre del script.

*   `!hasKey:msgLocked` -> **Mantiene** el trigger. (Puedes verlo muchas veces).
*   `hasKey:openDoor!` -> **Elimina** el trigger. (Solo ocurre una vez).

Si usas el campo `script` normal (fallback), este **siempre elimina el trigger** (comportamiento clásico), **EXCEPTO** si el Trigger es de tipo `Search`. Los triggers de tipo Search persisten por defecto.

## 4. Prioridad

El juego evalúa la lista de **arriba a abajo**. La primera condición que se cumpla ganará.

**Ejemplo completo:**
1.  `!items.hasKey:msgDoorLocked` (Sin llave -> Mensaje recurrente)
2.  `items.hasKey:enterSecretRoom!` (Con llave -> Entrar y borrar trigger)

## 5. Diálogos y Traducciones

El sistema de triggers se integra con el sistema de diálogos para mostrar mensajes al jugador.

### A. Trigger Tipo `Story`

Un trigger con el campo `type` configurado como `Story` ejecutará automáticamente un diálogo al entrar en contacto.

*   **Funcionamiento**: Llama a `dialogUI:addScreen(scriptName)` usando el nombre del script retornado por la lógica de condiciones.

### B. Definición de Diálogos (`assets/data/script.lua`)

Los diálogos se definen en una tabla global llamada `script`. Cada entrada tiene:

*   `name`: El identificador que usa el Trigger (p.ej., `nolamp`).
*   `dialog`: Un array de páginas de diálogo.
    *   `text`: Clave de traducción (localización).
    *   `video`: Nombre del video/animación del personaje (p.ej., `playerSurprise`).
        *   **Nota**: Si el jugador es "tiny", el sistema buscará automáticamente la versión `-tiny` (ej: `playerSurprise-tiny`).
    *   `screen` (Opcional): Imagen que se muestra en la pantalla de la radio/comunicador.

```lua
{
    name = "example",
    dialog = {
        { video = 'player', text = "key-01" },
        { video = 'playerHappy', text = "key-02", screen = image }
    }
}
```

### C. Archivos de Traducción (`en.strings`, `jp.strings`)

El juego utiliza archivos estándar de Playdate para la localización. El sistema busca la clave definida en el `text` del script.

*   **Ubicación**: Raíz del proyecto (`source/en.strings`, `source/jp.strings`).
*   **Formato**: `"clave" = "Texto a mostrar"`

El motor selecciona automáticamente el archivo basado en el idioma configurado (`Panels.vars.lang`).

**Ejemplo en `en.strings`**:
```strings
"key-01" = "Hello! I found a key."
```
