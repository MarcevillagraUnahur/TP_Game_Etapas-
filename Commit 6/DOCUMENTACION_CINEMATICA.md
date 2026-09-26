# ðŸŽ¬ DocumentaciÃ³n TÃ©cnica Oficial: Motor de CinemÃ¡ticas y Video en Wollok (`cinematica`)

---

## 1. IntroducciÃ³n y Contexto

El entorno educativo **Wollok Game** fue concebido para renderizar grÃ¡ficos 2D en un Canvas HTML5 mediante objetos visuales y reproducir pistas de audio (`.mp3`, `.ogg`, `.wav`). Sin embargo, **no cuenta con soporte nativo para reproducir archivos de video (`.mp4`, `.mov`, `.avi`, `.mkv`)**.

`cinematica` es una **librerÃ­a autÃ³noma y de propÃ³sito general** que resuelve esta limitaciÃ³n histÃ³rica, permitiendo incorporar cinemÃ¡ticas completas (intros, transiciones de nivel, pantallas de victoria y escenas narrativas) con **animaciÃ³n fluida de video y audio sincronizado** en cualquier proyecto Wollok.

---

## 2. Â¿CÃ³mo Funciona la TecnologÃ­a de `cinematica`?

La librerÃ­a implementa la tÃ©cnica estÃ¡ndar de los motores de videojuegos 2D retro: **Streaming Secuencial de Frames con Pista de Audio Acoplada**.

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Video Original  â”‚ â”€â”€â”€â”€â–º â”‚  procesadorCinematica.ts     â”‚ â”€â”€â”€â”€â–º â”‚ assets/cinematicas/       â”‚
â”‚  (.mp4 / .mov)  â”‚       â”‚  - ExtracciÃ³n de Frames PNG  â”‚       â”‚  â”œâ”€â”€ pase1_0.png .. N.png â”‚
â”‚                 â”‚       â”‚  - ExtracciÃ³n de Audio .mp3  â”‚       â”‚  â”œâ”€â”€ pase1_audio.mp3      â”‚
â”‚                 â”‚       â”‚  - CachÃ© inteligente (.json) â”‚       â”‚  â””â”€â”€ pase1.info.json      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                                                               â”‚
                                                                 â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                                                                 â”‚  cinematica/              â”‚
                                                                 â”‚   ReproductorCinematica   â”‚
                                                                 â”‚  - onTick(intervaloMs)    â”‚
                                                                 â”‚  - game.sound(audio)      â”‚
                                                                 â”‚  - Control Skip (ENTER)   â”‚
                                                                 â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

1. **Secuencia de Frames:** El video se transforma en una serie de imÃ¡genes PNG optimizadas a la resoluciÃ³n de la ventana ($750 \times 750\text{ px}$ u otra).
2. **Audio Sincronizado:** La pista de sonido se extrae a formato `.mp3` y se reproduce en el instante $0$ de la animaciÃ³n mediante `game.sound(...)`.
3. **Control Interactivo (*Skip*):** El jugador puede presionar **ENTER** o **Espacio** en cualquier momento para saltear el video y continuar jugando.
4. **TransiciÃ³n por Callbacks:** Al finalizar el video (o al saltearlo), se ejecuta automÃ¡ticamente un bloque de cÃ³digo (por ejemplo, cargar el siguiente nivel).
5. **CachÃ© Inteligente:** Verifica el tamaÃ±o y fecha de modificaciÃ³n de los videos; si los frames ya fueron extraÃ­dos y el video no cambiÃ³, la ejecuciÃ³n es instantÃ¡nea (0 ms).

---

## 3. Herramienta Conversora en TypeScript (`cinematica/procesadorCinematica.ts`)

Para mantener todo el stack unificado dentro del ecosistema **Node.js / TypeScript**, se provee la herramienta **`cinematica/procesadorCinematica.ts`**.

### ðŸŒŸ CaracterÃ­sticas de la Herramienta:
* **Ecosistema Nativo:** Se ejecuta directamente con `npm run cinematica` o `npx tsx` sin necesidad de instalar Python ni librerÃ­as adicionales en el sistema.
* **FFmpeg Integrado (`ffmpeg-static`):** Incluye los binarios ejecutables multiplataforma listos para usar.
* **CachÃ© InstantÃ¡neo:** Mediante archivos de metadatos `.info.json`, detecta automÃ¡ticamente si el video ya fue procesado y evita re-procesar innecesariamente.
* **Generador de CÃ³digo Wollok:** Imprime el objeto `ReproductorCinematica` listo para usar en Wollok.

---

### ðŸš€ CÃ³mo Usar el Convertidor:

#### Modo 1: Procesar todos los videos de la carpeta (AutomÃ¡tico)
```bash
npm run cinematica
```

#### Modo 2: Procesar un video puntual por lÃ­nea de comandos
```bash
npx tsx cinematica/procesadorCinematica.ts "Prueba de videos/Pase de nivel 1.mp4" 8
```

---

## 4. Estructura de la LibrerÃ­a (`cinematica/`)

La librerÃ­a contiene un Ãºnico mÃ³dulo de alta cohesiÃ³n:

```
cinematica/
â””â”€â”€ cinematica.wlk      # Clase base ReproductorCinematica
```

### ðŸ“„ Clase `ReproductorCinematica`
Hereda el contrato visual de Wollok (`image` y `position`):

| Atributo / Propiedad | Tipo | DescripciÃ³n |
| :--- | :--- | :--- |
| `prefijoFrames` | `String` | Ruta y prefijo de los frames (ej. `"cinematicas/pase1_"`). |
| `totalFrames` | `Number` | Cantidad total de imÃ¡genes que componen el video. |
| `intervaloMs` | `Number` | Milisegundos entre frames ($125\text{ms} = 8\text{ FPS}$, $100\text{ms} = 10\text{ FPS}$). |
| `rutaAudio` | `String` / `null` | Ruta al archivo `.mp3` (o `null` si es mudo). |
| `idTick` | `String` | Identificador Ãºnico para el temporizador de Wollok. |
| `x`, `y` | `Number` | PosiciÃ³n en pantalla (por defecto `(0, 0)`). |
| `width`, `height` | `Number` | Dimensiones en la grilla del juego. |

---

## 5. GuÃ­a de IntegraciÃ³n Paso a Paso en Cualquier Juego Wollok

### Paso 1: Importar la librerÃ­a
En tu archivo de juego o nivel:
```wollok
import cinematica.cinematica.*
```

### Paso 2: Declarar tu Objeto CinemÃ¡tica
```wollok
object cinematicaVictoria inherits ReproductorCinematica(
  x = 0,
  y = 0,
  width = 75,
  height = 75,
  prefijoFrames = "cinematicas/victoria_",
  totalFrames = 60,
  intervaloMs = 125, // 8 FPS
  rutaAudio = "cinematicas/victoria_audio.mp3",
  idTick = "tickVictoria",
  image = "cinematicas/victoria_0.png"
) {}
```

### Paso 3: Reproducir la CinemÃ¡tica
Para iniciar la reproducciÃ³n y definir quÃ© ocurre al terminar:
```wollok
cinematicaVictoria.reproducir({
  // CÃ³digo a ejecutar cuando termina el video:
  game.say(heroe, "Â¡Ganamos la batalla!")
  gestorDeNiveles.pasarAlSiguienteNivel()
})
```

### Paso 4: Permitir Salto Interactivo (*Skip*)
Para que el usuario pueda saltear la cinemÃ¡tica presionando una tecla:
```wollok
keyboard.enter().onPressDo({
  if (cinematicaVictoria.estaActiva()) {
    cinematicaVictoria.finalizar() // Detiene el video y salta directo a la acciÃ³n
  }
})
```

---

## 6. Mejores PrÃ¡cticas y OptimizaciÃ³n

| ParÃ¡metro | Valor Recomendado | ExplicaciÃ³n |
| :--- | :--- | :--- |
| **FPS del Video** | **6 a 10 FPS** | Provee ilusiÃ³n de movimiento cinematogrÃ¡fico perfecto sin sobrecargar la memoria del navegador. |
| **DuraciÃ³n Ã“ptima** | **5 a 15 segundos** | Ideal para transiciones de nivel o intros sin demorar la jugabilidad. |
| **ResoluciÃ³n de Frames** | $750 \times 750\text{ px}$ | Coincide con la resoluciÃ³n estÃ¡ndar retro HD de la ventana. |
| **Formato de Audio** | **MP3 128 kbps (44.1 kHz)** | MÃ¡xima compatibilidad con todos los navegadores y el motor de sonido de Wollok. |

---

## 7. Ejemplo Completo en "Defensores del Glaciar"

```wollok
import wollok.game.*
import cinematica.cinematica.*
import elementosDelJuego.*

// TransiciÃ³n al resolver el puzzle del poste en Nivel 1:
if (heroe.tieneLlave()) {
  gestorDeNiveles.limpiarNivel()
  
  reproductorCinematica.reproducir({
    // Al finalizar los 80 frames con audio, pasa al Nivel 2
    gestorDeNiveles.pasarANivel2(heroe)
  })
}
```
