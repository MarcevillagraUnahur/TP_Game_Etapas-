# 🎮 Defensores del Glaciar - Commit 3: Primera Integración Gráfica con Wollok Game (15x15)

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta tercera etapa damos el gran salto hacia la **interfaz visual** integrando la biblioteca estándar `wollok.game.*`:
1. **Grilla estándar de Wollok Game**: Ventana de 15x15 casillas con celdas de 50px.
2. **Sistema de Sprites y Animación de Caminata (A/B)**: Alternancia entre frames `Tupac1A.png` y `Tupac1B.png` según la dirección y el paso.
3. **Control por Teclado**: Soporte para Flechas de dirección y teclas WASD para desplazamiento en 4 direcciones.
4. **Vuelo Visual de Proyectiles**: Movimiento periódico de la Papa mediante eventos `game.onTick` y detección de colisión con `game.onCollideDo`.
5. **Transformación Visual de Villanos**: Al ser impactados, su sprite cambia automáticamente a la imagen del animal correspondiente (`llama1.png`, etc.).

---

## 🗺️ 2. Mapa de Relación entre Archivos y Clases

```
┌────────────────────────────────────────────────────────┐
│                   defensores.wpgm                      │
│                                                        │
│   - Configura game.width(15), game.height(15)          │
│   - Mapea teclado (WASD, Flechas, Barra Espaciadora)   │
│   - Configura colisiones con game.onCollideDo          │
└──────────────────────────┬─────────────────────────────┘
                           │ Agrega visuales a la grilla
                           ▼
┌────────────────────────────────────────────────────────┐
│                   personajes.wlk                       │
│                                                        │
│   class Personaje                                      │
│   - position (game.at), direccion, paso                │
│   - image(): Calcula dinámicamente el nombre de PNG    │
└──────────────┬──────────────────────────┬──────────────┘
               │                          │
        ┌──────┴──────────┐        ┌──────┴──────────┐
        ▼                 ▼        ▼                 ▼
┌──────────────┐   ┌─────────────┐┌────────────────┐ ┌──────────────┐
│  heroes.wlk  │   │villanos.wlk ││   fondo.wlk    │ │elementos...  │
│              │   │             ││                │ │              │
│ class Heroe  │   │class Villano││ object fondo   │ │ class Papa   │
│ - Tupac /    │   │- Demoledor /││ - fondo1.png   │ │ class Cofre  │
│   Pachita    │   │  Envenenador││ - position 0,0 │ │ class Llave  │
└──────────────┘   └─────────────┘└────────────────┘ └──────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo y Conceptos Clave

### 📄 `personajes.wlk`
* **Polimorfismo Visual de Wollok Game:**
  * Cualquier objeto que se agrega a `game.addVisual(obj)` debe entender los mensajes polimórficos `position()` e `image()`.
  * En `Personaje`, `position` se inicializa como una coordenada `game.at(x, y)`.
  * El método `image()` calcula el nombre del archivo de imagen combinando atributos: `nombre + direccion.numero() + (if (paso) "B" else "A") + ".png"`. Por ejemplo: `"Tupac1A.png"`.

### 📄 `heroes.wlk`
* **Movimiento en Grilla:**
  * Métodos `moverArriba()`, `moverAbajo()`, `moverIzquierda()`, `moverDerecha()`:
    1. Actualizan la variable `direccion`.
    2. Ejecutan `self.alternarPaso()` para cambiar entre el pie A y el pie B.
    3. Validan los límites del tablero (`position.y() < game.height() - 1`) antes de avanzar con `position.up(1)`.

### 📄 `villanos.wlk`
* **Sprite Dinámico según Estado:**
  * Si `estaTransformado` es `false`, su `image()` calcula el sprite del villano (ej: `"demoledor1A.png"`).
  * Si `estaTransformado` es `true`, su `image()` retorna automáticamente el sprite del animal pacificado (ej: `"llama1.png"`).

### 📄 `elementosDelJuego.wlk`
* **Clase `Papa` Visual:**
  * Implementa `iniciarVuelo()` con un tick periódico `game.onTick(200, id, { self.avanzar() })`.
  * En `avanzar()`, si alcanza el límite del mapa, llama a `destruir()` removiendo el visual de la pantalla y cancelando el tick.
  * Si colisiona con un villano, ejecuta `impactar(villano)` y se autodestruye.

### 📄 `defensores.wpgm`
* **Punto de Entrada del Programa:**
  * Inicializa el motor gráfico, posiciona el fondo, el héroe y los enemigos iniciales, conecta los callbacks del teclado y ejecuta `game.start()`.

---

## 💡 4. Conceptos Teóricos de POO Demostrados en este Commit

1. **Polimorfismo con el Motor de Juego (`wollok.game`):** Todas las entidades gráficas implementan el protocolo visual (`position` e `image()`), permitiendo que el motor de renderizado las dibuje de manera uniforme.
2. **Cálculo de Estado Derivado:** En lugar de guardar cientos de nombres de imagen en variables, el método `image()` calcula el nombre del recurso en tiempo de ejecución combinando el estado actual (`nombre`, `direccion`, `paso`, `estaTransformado`).
3. **Manejo de Eventos Asíncronos (Ticks y Teclado):** Uso de bloques (`{ ... }`) como callbacks para reaccionar a la pulsación de teclas y al paso del tiempo de forma desacoplada.

---

## 🗣️ 5. Guía para la Defensa Oral (Preguntas de Examen)

| Pregunta Típica del Profesor | ¿Cómo responder con fundamentos? |
| :--- | :--- |
| **"¿Qué necesita entender un objeto para ser agregado al `game`?"** | *"Necesita cumplir con el protocolo visual de Wollok Game: entender el mensaje `position()` que devuelve un `Position` y el mensaje `image()` que devuelve un `String` con el path de la imagen."* |
| **"¿Cómo resolvieron la animación de caminata de los personajes?"** | *"Con un booleano `paso`. Cada vez que el personaje se desplaza, se invierte `paso = !paso`. El método polimórfico `image()` concatena `'A'` o `'B'`, alternando naturalmente los sprites al caminar."* |
| **"¿Cómo evitan que el héroe se escape del mapa al moverse?"** | *"Validamos los límites del tablero consultando `game.width()` y `game.height()` antes de modificar la posición con `.up(1)`, `.right(1)`, etc."* |

---

## 🧪 6. Cómo Ejecutar y Validar los Tests

Abrí la terminal en la carpeta de este commit y ejecutá:
```bash
wollok test
```

### Casos de prueba cubiertos:
1. `✓ "El heroe cambia de posicion y alterna frame de paso al moverse"`
2. `✓ "El villano transformado cambia su imagen al animal correspondiente"`
3. `✓ "El proyectil Papa calcula correctamente su imagen segun la direccion"`
4. `✓ "El cofre cambia de sprite cuando se abre"`