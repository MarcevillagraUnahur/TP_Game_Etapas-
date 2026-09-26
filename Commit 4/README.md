# 🔑 Defensores del Glaciar - Commit 4: Puzles, HUD Visual y Transición de Niveles

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta cuarta etapa completamos la estructura de juego por niveles, puzles e interfaz de usuario (HUD) en pantalla:
1. **HUD Gráfico Completo en Tiempo Real**:
   - **Corazones (`CorazonHUD`)**: Visualiza las 3 vidas del héroe (`corazon.png` o `vacio.png`).
   - **Barra de Energía (`BarraEnergiaHUD`)**: Muestra 6 estados escalonados de salud (`energia100.png` a `energia0.png`).
   - **Contador de Puntaje a 3 Dígitos (`DigitoPuntajeHUD`)**: Renderiza unidades, decenas y centenas dinámicamente (`n0.png` a `n9.png`).
   - **Indicador de Nivel (`NivelHUD`)**: Muestra el badge del nivel actual (`nivel1.png`, `nivel2.png`).
2. **Puzle de Llave, Cofre y Poste de Destrucción**:
   - Para ganar cada nivel, el héroe debe acercarse al `Cofre`, abrirlo con **ENTER** para obtener la `Llave`, y luego llevar la llave al `PosteConCaja` para desactivar la maquinaria contaminante.
3. **Gestor de Niveles (`gestorDeNiveles`)**:
   - Controla el flujo completo: Pantalla de inicio (`menuInicio.png`), carga de obstáculos y villanos de Nivel 1 (Tupac vs Demoledor), transición a Nivel 2 (Pachita vs Envenenador), y pantalla de victoria.

---

## 🗺️ 2. Mapa de Relación entre Archivos y Clases

```
┌────────────────────────────────────────────────────────┐
│                   defensores.wpgm                      │
│                                                        │
│   - ENTER: Inicia juego o interactúa con Cofre/Poste   │
│   - ESPACIO: Lanza papa mediante gestorDeNiveles       │
│   - Instancia el HUD en la franja superior (y = 14)    │
└──────────────────────────┬─────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
┌─────────────────────────┐         ┌──────────────────────────┐
│  elementosDelJuego.wlk  │         │       villanos.wlk       │
│                         │         │                          │
│   object gestorDeNiveles│◄────────┤   class Villano          │
│   - configurarNivel1()  │         │   - patrulla periódica   │
│   - pasarANivel2()      │         │   - colisión con héroe   │
│   - limpiarNivel()      │         └──────────────────────────┘
│                         │
│   Clases HUD            │
│   - CorazonHUD          │
│   - BarraEnergiaHUD     │
│   - DigitoPuntajeHUD    │
│   - NivelHUD            │
│                         │
│   Puzle                 │
│   - Cofre, Llave, Poste │
└─────────────────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo y Conceptos Clave

### 📄 `elementosDelJuego.wlk`
* **Componentes del HUD Visual:**
  * `CorazonHUD`: Conoce su `indice` (1, 2 o 3) y su `personaje`. Si `personaje.vidas() >= indice`, muestra `"corazon.png"`, sino `"vacio.png"`.
  * `BarraEnergiaHUD`: Redondea la energía a múltiplos de 20 para seleccionar el sprite adecuado (`"energia80.png"`, etc.).
  * `DigitoPuntajeHUD`: Formatea la puntuación del jugador con ceros a la izquierda (ej: `045`) y muestra el dígito correspondiente a su `indice` (centena, decena, unidad).
  * `NivelHUD`: Delega en `personaje.nivelActual().imagenHUD()` para mostrar la insignia del nivel en curso.
* **Mecánica del Puzle:**
  * `Cofre`: Inicia cerrado (`cofreC.png`). Al abrirse pasa a `estaAbierto = true` (`cofre.png`) y revela la `Llave`.
  * `PosteConCaja`: Si el héroe interactúa con él teniendo `heroe.tieneLlave() == true`, se detiene la destrucción y se avanza al siguiente nivel o a la victoria.
* **Objeto `gestorDeNiveles`:**
  * Administra el ciclo de vida del juego: carga obstáculos (`Camion1.png`, `Camion2.png`), inicializa los villanos con sus caminos de patrulla y limpia los elementos al cambiar de pantalla.

### 📄 `defensores.wpgm`
* **Interacción por Proximidad:**
  * Al presionar **ENTER**, se calcula la distancia Manhattan/Euclídea respecto al cofre y al poste: `(heroe.x - objeto.x).abs() <= 1 && (heroe.y - objeto.y).abs() <= 1`.

---

## 💡 4. Conceptos Teóricos de POO Demostrados en este Commit

1. **Polimorfismo en Objetos del HUD:** Todos los elementos del HUD (`CorazonHUD`, `BarraEnergiaHUD`, `DigitoPuntajeHUD`, `NivelHUD`) responden al mismo protocolo visual (`position()` e `image()`) y consultan al `Heroe` para reflejar su estado en tiempo real.
2. **Patrón Gestor (Manager Pattern):** El objeto `gestorDeNiveles` centraliza la creación, transición y limpieza de entidades visuales, evitando que la lógica de cambio de nivel contamine a los personajes u objetos individuales.
3. **Encapsulamiento del Estado de Partida:** Variables como `estaEnMenu` y `estaJugando` aseguran que las teclas de acción solo tengan efecto cuando el juego está en el estado correcto.

---

## 🗣️ 5. Guía para la Defensa Oral (Preguntas de Examen)

| Pregunta Típica del Profesor | ¿Cómo responder con fundamentos? |
| :--- | :--- |
| **"¿Cómo se actualiza el HUD si no hay un bucle infinito que lo redibuje manualmente?"** | *"Wollok Game consulta el método `image()` de cada objeto visual en cada ciclo de render. Como nuestros objetos HUD leen dinámicamente las propiedades del `Heroe` (`vidas`, `energia`, `puntos`), la pantalla se actualiza en tiempo real de forma reactiva."* |
| **"¿Cómo resolvieron el formateo del puntaje en 3 dígitos?"** | *"Implementamos tres instancias de `DigitoPuntajeHUD` (para índices 0, 1 y 2). Cada una formatea el número a 3 caracteres con ceros a la izquierda y extrae el carácter correspondiente con `.charAt(indice)` para retornar el sprite `n{digito}.png`."* |
| **"¿Cómo funciona la transición de Nivel 1 a Nivel 2?"** | *"El `gestorDeNiveles` ejecuta `limpiarNivel()` (removiendo visuales y eventos de tick antiguos), cambia el fondo a `fondo2.png`, configura al nuevo héroe (Pachita), coloca los nuevos obstáculos y spawnea al nuevo villano (Envenenador) con su respectiva ruta."* |

---

## 🧪 6. Cómo Ejecutar y Validar los Tests

Abrí la terminal en la carpeta de este commit y ejecutá:
```bash
wollok test
```

### Casos de prueba cubiertos:
1. `✓ "El HUD de corazones se actualiza segun las vidas del heroe"`
2. `✓ "La barra de energia calcula el sprite correcto segun el porcentaje"`
3. `✓ "El HUD de puntaje formatea a tres digitos"`
4. `✓ "El gestor de niveles pasa fluidamente de Nivel 1 a Nivel 2"`