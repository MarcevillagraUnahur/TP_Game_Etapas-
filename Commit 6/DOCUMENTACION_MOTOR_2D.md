# ðŸš€ DocumentaciÃ³n TÃ©cnica Oficial: Motor 2D MultipropÃ³sito en Wollok (`motor2d`)

## 1. IntroducciÃ³n y Contexto

El entorno estÃ¡ndar de **Wollok Game** fue concebido principalmente con fines pedagÃ³gicos para representar tableros discretos (grillas de casilleros de 1x1 estilo ajedrez o Sokoban). Sin embargo, cuando se busca desarrollar videojuegos de acciÃ³n en tiempo real (arcade, shooters, aventuras top-down o juegos de acciÃ³n fluida), el modelo clÃ¡sico presenta limitaciones severas: **movimientos toscos por casilleros, colisiones limitadas a la misma celda, ralentizaciÃ³n por chequeos $O(N^2)$ y acoplamiento entre la lÃ³gica y el renderizado**.

`motor2d` es un **motor de fÃ­sicas, colisiones y gestiÃ³n de escena 2D de propÃ³sito general** desarrollado sobre Wollok Game. Provee una capa de abstracciÃ³n orientada a objetos que independiza la fÃ­sica y las dimensiones de las entidades de la grilla visual, permitiendo **movimiento continuo de alta fluidez (40 FPS), colisiones por Ã¡rea (AABB) de entidades heterogÃ©neas y un consumo de CPU optimizado**.

---

## 2. Â¿Por quÃ© implementamos `motor2d`? (Limitaciones vs. Soluciones)

| DesafÃ­o en Wollok Game EstÃ¡ndar | Causa TÃ©cnica | SoluciÃ³n Implementada en `motor2d` |
| :--- | :--- | :--- |
| **Movimiento a Saltos (Teletransporte)** | Las posiciones solo pueden cambiar de entero en entero ($1, 2, 3...$), saltando distancias visuales grandes en un solo fotograma. | **Sub-Grilla Modular y Coordenadas Reales:** Subdivide la pantalla en celdas finas (ej. $75 \times 75$ de $10\text{ px}$). Con *Smooth Movement Buffer*, un paso de 50px se descompone en 5 desplazamientos suaves de 10px a 40 FPS. |
| **Colisiones RÃ­gidas de 1x1 (`game.colliders`)** | Solo detecta colisiÃ³n si dos objetos comparten exactamente la misma celda de $1 \times 1$. Un camiÃ³n o jefe de 3x3 celdas no funciona naturalmente. | **FÃ­sicas AABB (Axis-Aligned Bounding Box):** Cada entidad define su propio `width` y `height`. Se calcula matemÃ¡ticamente el solapamiento de rectÃ¡ngulos en tiempo constante. |
| **Cuello de Botella $O(N^2)$ en Colecciones** | Comparar todos los objetos contra todos en cada tick satura la mÃ¡quina virtual de Wollok y produce caÃ­das bruscas de FPS. | **Colisiones Dirigidas $O(N)$:** Se separa a los actores en `actoresDinamicos` (mÃ³viles) y `obstaculos` (pasivos/receptores). Solo los mÃ³viles verifican colisiones. |
| **CaÃ­das de FPS e Inconsistencias Visuales** | La velocidad de ejecuciÃ³n dependÃ­a de la cantidad de elementos en pantalla. | **Bucle de Frecuencia Fija (Fixed Time Step):** Tasa de refresco constante configurada a 25ms (40 FPS estables) administrada por `configuracionMotor` y `engine`. |
| **Acoplamiento de Datos y Vistas** | Modificar la posiciÃ³n visual directamente en la lÃ³gica ataba las reglas del juego al tamaÃ±o de los sprites. | **Desacoplamiento LÃ³gico-Visual:** Coordenadas lÃ³gicas $(x, y)$ independientes de `position = game.at(x, y)`. SincronizaciÃ³n explÃ­cita mediante `sincronizarPosicionVisual()`. |

---

## 3. Ventajas Clave para los Juegos al Usar `motor2d`

### 1. Experiencia de Jugador Fluida (60/40 FPS Real)
Los personajes y proyectiles no "saltan" de baldosa en baldosa. Los proyectiles (como las *Papas Benditas*) viajan con trayectoria continua pÃ­xel a pÃ­xel, y los hÃ©roes y villanos se desplazan con transiciones de animaciÃ³n coordinadas.

### 2. Entidades de MÃºltiples TamaÃ±os (Modularidad AABB)
Permite tener sin trucos:
- HÃ©roes de $5 \times 5$ sub-celdas ($50 \times 50\text{ px}$).
- Proyectiles pequeÃ±os de $2 \times 2$ sub-celdas ($20 \times 20\text{ px}$).
- ObstÃ¡culos grandes como camiones o cajas de $15 \times 15$ sub-celdas ($150 \times 150\text{ px}$).
- Fondos de pantalla completa de $75 \times 75$ sub-celdas ($750 \times 750\text{ px}$).

### 3. Polimorfismo Real y FÃ¡cil Extensibilidad
Cualquier entidad del juego (un enemigo, un coleccionable, una trampa, una bala) solo necesita heredar de `Actor` e implementar sus mÃ©todos de respuesta polimÃ³rfica:
- `actualizar()`: Define cÃ³mo se mueve o actÃºa en cada tick.
- `colisionoCon(otro)`: Define quÃ© le hace al otro o quÃ© le ocurre al impactar.
- `recibirImpacto(proyectil)`: Protocolo de daÃ±o/interacciÃ³n.

El `engine` no necesita saber quÃ© es cada objeto; solo sabe que es un `Actor` y orquesta su ciclo de vida.

### 4. Arquitectura Limpia y Libre de Dependencias Circulares
El diseÃ±o modular del proyecto separa responsabilidades en capas claras:
- **`motor2d/`**: Motor genÃ©rico reutilizable en cualquier juego (no conoce nada de Defensores del Glaciar).
- **`personajes.wlk`**: Capa base de tipos de personaje y direcciones espaciales (`norte`, `sur`, `este`, `oeste`).
- **`heroes.wlk` / `villanos.wlk`**: Comportamientos especÃ­ficos de entidades jugables y no jugables.
- **`elementosDelJuego.wlk`**: Niveles, HUDs, objetos interactivos (cofres, postes, llaves) y gestor de estado.
- **`defensores.wpgm`**: Punto de entrada, configuraciÃ³n de pantalla y binding de teclado.

---

## 4. Arquitectura de MÃ³dulos

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                                       motor2d                                          â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚      config.wlk      â”‚      actor.wlk       â”‚                engine.wlk                â”‚
â”‚  (ResoluciÃ³n y FPS)  â”‚    (Entidad AABB)    â”‚           (Manager de Escena)            â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â–²                      â–²                                â–²
           â”‚                      â”‚                                â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                             JUEGO (Defensores del Glaciar)                             â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚    personajes.wlk    â”‚      heroes.wlk      â”‚               villanos.wlk               â”‚
â”‚ (Direcciones y Base) â”‚  (Heroe / Controles) â”‚          (IA / Patrulla / Ataque)        â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                          elementosDelJuego.wlk / obstaculos.wlk                        â”‚
â”‚                 (Niveles, HUD, Objetos, Cofres, Llaves, Fondo, Proyectiles)             â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                     defensores.wpgm                                    â”‚
â”‚                         (Punto de Entrada e InicializaciÃ³n de Escena)                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 5. EspecificaciÃ³n de Componentes

### 5.1. `configuracionMotor` (`motor2d/config.wlk`)
Administra los parÃ¡metros de resoluciÃ³n lÃ³gica y temporal:
* **`anchoPantalla` y `altoPantalla`**: NÃºmero de sub-celdas lÃ³gicas (ej. 75x75).
* **`tamanioCelda`**: TamaÃ±o en pÃ­xeles de cada sub-celda (ej. 10px, logrando $750 \times 750\text{ px}$).
* **`tasaRefrescoMs`**: Intervalo del reloj de fÃ­sica (`25ms` $\rightarrow$ 40 actualizaciones por segundo).
* **`configurar(ancho, alto, celda, tasaMs)`**: Configura los valores del motor.
* **`inicializarPantalla(titulo)`**: Aplica la configuraciÃ³n a `game` (`game.width`, `game.height`, `game.cellSize`, `game.title`).

---

### 5.2. Clase Base `Actor` (`motor2d/actor.wlk`)
Entidad base de la que heredan todas las piezas del juego.

#### Propiedades:
* `x`, `y`: Coordenadas lÃ³gicas continuas.
* `width`, `height`: Dimensiones en sub-celdas del Ã¡rea de colisiÃ³n.
* `image`: Nombre del archivo de textura en `assets/`.
* `position`: PosiciÃ³n visual `game.at(x, y)` consumida por Wollok Game.
* `activo`: Booleano que indica si el actor estÃ¡ vivo/activo en la escena.

#### MÃ©todos de Movimiento y Render:
* `sincronizarPosicionVisual()`: Trunca las coordenadas $(x, y)$ y actualiza `position = game.at(x.truncate(0), y.truncate(0))`.
* `moverA(nuevoX, nuevoY)` / `desplazar(dx, dy)`: Modifican posiciÃ³n y sincronizan automÃ¡ticamente.
* `destruir()`: Marca `activo = false` y solicita al `engine` la remociÃ³n visual y lÃ³gica (`engine.despawn(self)`).

#### Modelo MatemÃ¡tico de Colisiones AABB:
Para dos actores $A$ y $B$:
$$\text{Solapamiento en } X \iff (x_A < x_B + width_B) \land (x_A + width_A > x_B)$$
$$\text{Solapamiento en } Y \iff (y_A < y_B + height_B) \land (y_A + height_A > y_B)$$
$$\text{ColisiÃ³n}(A, B) \iff (A \neq B) \land \text{Solapa en } X \land \text{Solapa en } Y$$

---

### 5.3. Administrador de Escena `engine` (`motor2d/engine.wlk`)
Orquestador central del ciclo de vida y del bucle principal:
* **`spawn(unActor)`**:
  1. Ejecuta `unActor.sincronizarPosicionVisual()`.
  2. Si `unActor.esDinamico()`, lo registra en `actoresDinamicos`.
  3. Si `unActor.esObstaculo()`, lo registra en `obstaculos`.
  4. Lo aÃ±ade a la escena visual de Wollok (`game.addVisual(unActor)`).
* **`despawn(unActor)`**: Lo remueve de las listas lÃ³gicas y de la vista de Wollok.
* **`iniciar()`**: Registra el evento de reloj `engineLoopGeneral` con la tasa de refresco configurada (`25ms`).
* **`actualizar()`**:
  1. Itera sobre `actoresDinamicos` activos y ejecuta `actor.actualizar()`.
  2. Para cada actor dinÃ¡mico, evalÃºa colisiones Ãºnicamente contra los `obstaculos` activos.
  3. Dispara los callbacks bidireccionales `actor.colisionoCon(obs)` y `obs.colisionoCon(actor)`.

---

## 6. Caso PrÃ¡ctico: Caso de Ã‰xito en *Defensores del Glaciar*

En el proyecto **Defensores del Glaciar**, la adopciÃ³n de `motor2d` permitiÃ³ implementar:

1. **Grilla de Alta Fidelidad**: Tablero de $75 \times 75$ sub-celdas de $10\text{ px}$ ($750 \times 750\text{ px}$ en ventana).
2. **Fondo de Escena de Cobertura Total**: Objeto `fondo` posicionado en $(0, 0)$ con $75 \times 75$ de dimensiÃ³n, cubriendo exactamente el $100\%$ de la ventana en todas las fases (MenÃº, Nivel 1 y Nivel 2).
3. **Smooth Pulse Movement**: Desplazamiento interpolado a 40 FPS en 4 direcciones (WASD y flechas) con animaciÃ³n sincronizada de sprites (`Tupac1A.png`, `Tupac1B.png`, etc.).
4. **Disparo DinÃ¡mico de Proyectiles**: InstanciaciÃ³n de `Papa` como proyectil dinÃ¡mico con velocidad 2 sub-celdas/tick, destrucciÃ³n automÃ¡tica al salir del tablero y transformaciÃ³n mÃ¡gica de villanos al colisionar.
5. **ObstÃ¡culos Modulares con Bounding Box Real**: Camiones de $15 \times 15$ sub-celdas ($3 \times 3$ casilleros grandes) que bloquean de forma matemÃ¡ticamente exacta el paso de hÃ©roes y proyectiles.
6. **MÃ³dulo Desacoplado `personajes.wlk`**: EliminaciÃ³n completa de ciclos de dependencias circulares (`Circular Imports`), garantizando cero errores de referencia y compatibilidad total con las herramientas de validaciÃ³n de Wollok.

---

## 7. GuÃ­a RÃ¡pida para Crear Nuevos Juegos con `motor2d`

### Paso 1: Importar los mÃ³dulos necesarios
```wollok
import motor2d.config.*
import motor2d.engine.*
import motor2d.actor.*
```

### Paso 2: Crear clases que hereden de `Actor`
```wollok
class Bala inherits Actor(width = 2, height = 2, image = "bala.png") {
  override method esDinamico() = true

  override method actualizar() {
    y += 2
    self.sincronizarPosicionVisual()
    if (y > configuracionMotor.altoPantalla()) {
      self.destruir()
    }
  }

  override method colisionoCon(otro) {
    self.destruir()
  }
}
```

### Paso 3: Configurar e iniciar en el `.wpgm`
```wollok
program miJuego {
  // 1. Configurar resoluciÃ³n (ancho, alto, cellSize, tasaMs)
  configuracionMotor.configurar(75, 75, 10, 25)
  configuracionMotor.inicializarPantalla("Mi Juego 40 FPS")

  // 2. Spawnear entidades
  const jugador = new MiHeroe(x = 35, y = 10, width = 5, height = 5, image = "heroe.png")
  engine.spawn(jugador)

  // 3. Iniciar bucle de fÃ­sicas y motor grÃ¡fico
  engine.iniciar()
  game.start()
}
```
