# ⚙️ Defensores del Glaciar - Commit 5: Motor 2D Propio a 40 FPS (Sub-Grilla 75x75 y Colisiones AABB)

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta quinta etapa superamos las limitaciones del movimiento casilla por casilla estándar de Wollok Game implementando una **arquitectura de Motor 2D personalizada (`motor2d/`)**:
1. **Sub-Grilla de Alta Resolución (75x75 celdas de 10px = 750x750 px)**: Permite movimiento suave continuo en lugar de saltos discretos de 50px.
2. **Game Loop a 40 FPS (Ticks de 25ms)**: Desacopla la lógica de refresco y simulación de la velocidad del hardware.
3. **Detección de Colisiones AABB (Axis-Aligned Bounding Box)**: Sistema de cajas delimitadoras `[x, y, width, height]` con optimización $O(N)$ separando actores dinámicos de estáticos.
4. **Buffer de Impulso Suave (Smooth Pulse Movement)**: Movimiento fluido por inercia de micro-pasos para héroes y villanos.
5. **Inteligencia de Patrullaje y Raycast de Visión**: Los villanos verifican línea de visión directa hacia el héroe (`veAl(heroe)`) sorteando obstáculos antes de iniciar la persecución.

---

## 🗺️ 2. Mapa de Relación entre Archivos y Clases

```
┌────────────────────────────────────────────────────────┐
│                   motor2d/engine.wlk                   │
│                                                        │
│   object engine                                        │
│   - Game Loop a 40 FPS (onTick cada 25ms)              │
│   - Listas: actoresDinamicos y obstaculos              │
│   - spawn(actor), despawn(actor), verificarColisiones()│
└──────────────────────────┬─────────────────────────────┘
                           │ Administra y actualiza
                           ▼
┌────────────────────────────────────────────────────────┐
│                   motor2d/actor.wlk                    │
│                                                        │
│   class Actor                                          │
│   - Coordenadas continuas: x, y, width, height         │
│   - Detección AABB: solapaEnX(), solapaEnY(), colisiona│
│   - sincronizarPosicionVisual()                        │
└──────────────────────────┬─────────────────────────────┘
                           │ Herencia de Actor
             ┌─────────────┴─────────────┐
             ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐
│     obstaculos.wlk      │ │     personajes.wlk      │
│                         │ │                         │
│   class Obstaculo       │ │   class Personaje       │
│   - anchoCeldas * 5     │ │   - direccion, paso     │
│   - ocupaPosicion(x, y) │ │   - width = 5, height =5│
└─────────────────────────┘ └────────────┬────────────┘
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   ▼                                           ▼
       ┌───────────────────────┐                   ┌───────────────────────┐
       │      heroes.wlk       │                   │     villanos.wlk      │
       │                       │                   │                       │
       │  class Heroe          │                   │  class Villano        │
       │  - Smooth Pulse Buffer│                   │  - Raycast: veAl()    │
       │  - Papas dinámicas    │                   │  - Persecución suave  │
       └───────────────────────┘                   └───────────────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo y Conceptos Clave

### 📄 `motor2d/actor.wlk`
* **Propósito:** Clase base de todas las entidades con geometría 2D.
* **Atributos:** `x, y, width, height, position, image, activo`.
* **Métodos AABB:**
  * `solapaEnX(otro)`: `(x < otro.x + otro.width) && (x + width > otro.x)`
  * `solapaEnY(otro)`: `(y < otro.y + otro.height) && (y + height > otro.y)`
  * `colisionaCon(otro)`: `solapaEnX(otro) && solapaEnY(otro)`
  * `sincronizarPosicionVisual()`: Asigna `position = game.at(x.truncate(0), y.truncate(0))` para reflejar las coordenadas en Wollok Game.

### 📄 `motor2d/engine.wlk`
* **Propósito:** Bucle principal de juego (Game Loop) y gestor de colisiones.
* **Optimización:** Divide las entidades en `actoresDinamicos` (que se mueven) y `obstaculos` (estáticos). En cada frame de 25ms, solo itera y verifica colisiones de los actores dinámicos contra los obstáculos, reduciendo drásticamente el costo computacional.

### 📄 `heroes.wlk`
* **Interpolación Suave:** En lugar de saltar 1 celda completa por pulsación, setea `ticksMovimiento = 5` y `velocidad = 1`. En cada tick del motor, el héroe avanza 1 sub-píxel hasta completar el impulso, logrando una sensación visual completamente fluida a 40 FPS.

### 📄 `villanos.wlk`
* **Algoritmo de Visión (Raycast Simple):**
  * `veAl(heroe)`: Valida si el héroe está en la misma fila/columna y utiliza `hayObstaculoEntreX` / `hayObstaculoEntreY` para comprobar si hay camiones bloqueando la línea de visión. Si el camino está despejado, cambia a modo persecución (`persiguiendo = true`).

---

## 💡 4. Conceptos Teóricos de POO Demostrados en este Commit

1. **Jerarquía Polimórfica de Actores:** Héroes, Villanos, Obstáculos, Proyectiles e incluso el Fondo heredan de `Actor`, compartiendo el protocolo geométrico y de colisión AABB.
2. **Patrón Game Loop:** Desacoplamiento temporal donde la lógica de actualización (`actualizar()`) y la renderización visual ocurren de forma sincronizada y periódica.
3. **Despacho Doble (Double Dispatch) en Colisiones:**
   - `engine` detecta `actorA.colisionaCon(actorB)`.
   - Llama a `actorA.colisionoCon(actorB)`, que a su vez envía `actorB.recibirImpacto(actorA)`. Cada subclase reacciona según el tipo de entidad que la impactó.

---

## 🗣️ 5. Guía para la Defensa Oral (Preguntas de Examen)

| Pregunta Típica del Profesor | ¿Cómo responder con fundamentos? |
| :--- | :--- |
| **"¿Por qué crearon un Motor 2D propio en lugar de usar solo las celdas de Wollok?"** | *"Porque Wollok Game por defecto solo permite movimientos discretos celda a celda. Con nuestro motor dividimos el mapa en una sub-grilla de 75x75 y agregamos un Game Loop a 40 FPS que permite movimiento suave por impulsos y colisiones AABB precisas."* |
| **"¿Cómo funciona la detección de colisiones AABB?"** | *"Comparamos los intervalos proyectados en ambos ejes: si los rectángulos se solapan tanto en el eje X (`solapaEnX`) como en el eje Y (`solapaEnY`), existe una colisión física entre las dos cajas."* |
| **"¿Cómo optimizaron las colisiones para que no baje los FPS?"** | *"Separando los actores en dos listas: `actoresDinamicos` y `obstaculos`. En lugar de hacer una comparación cuadrática $O(N^2)$ de todos contra todos, solo testeamos los elementos móviles contra los estáticos."* |

---

## 🧪 6. Cómo Ejecutar y Validar los Tests

Abrí la terminal en la carpeta de este commit y ejecutá:
```bash
wollok test
```

### Casos de prueba cubiertos (9 tests):
1. `✓ "Deteccion de Colisiones AABB entre Actores"`
2. `✓ "Obstaculo AABB calcula correctamente su area de ocupacion"`
3. `✓ "Movimiento fluido por impulsos (ticks) del Heroe"`
4. `✓ "El proyectil Papa colisiona con el villano y lo transforma en animal"`
5. `✓ "El gestor de niveles conmuta a Nivel 2 y resetea estado"`
6. `✓ "Dos actores superpuestos colisionan"`
7. `✓ "Dos actores separados no colisionan"`
8. `✓ "Un actor no colisiona consigo mismo"`
9. `✓ "Desplazar modifica coordenadas y posición"`