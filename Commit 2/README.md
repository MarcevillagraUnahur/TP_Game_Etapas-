# 🥔 Defensores del Glaciar - Commit 2: Mecánicas de Combate, Proyectiles Papa y Niveles (Dominio)

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta segunda etapa expandimos el **Modelo de Dominio** añadiendo las reglas de juego centrales:
1. **Lanzamiento y Vuelo de Proyectiles (`Papa`)**: Creación de proyectiles que avanzan, colisionan y se destruyen.
2. **Transformación de Villanos en Animales**: Cuando un villano recibe un impacto de papa, pierde su forma malvada y se transforma en un animal andino (llama, lagarto, mula), quedando inofensivo.
3. **Direcciones como Objetos Polimórficos (`norte`, `sur`, `este`, `oeste`)**: Cada dirección conoce su variación de coordenadas `(dx, dy)` y su número identificador.
4. **Niveles Polimórficos (`nivel1`, `nivel2`)**: Cada nivel otorga diferente puntaje y define rutas de patrullaje distintas para los villanos.

Todo esto continúa programado en **lógica de dominio pura**, garantizando cobertura de tests sin depender de rendering visual.

---

## 🗺️ 2. Mapa de Relación entre Archivos y Clases

```
┌────────────────────────────────────────────────────────┐
│                   personajes.wlk                       │
│                                                        │
│   ┌──────────────────────┐   ┌─────────────────────┐   │
│   │   class Personaje    │   │ Direcciones (W,S,E,N│   │
│   │   - direccion        │   │ - dx(), dy()        │   │
│   └──────────┬───────────┘   └─────────────────────┘   │
└──────────────┼─────────────────────────────────────────┘
               │ (Herencia)
        ┌──────┴─────────────────────────┐
        ▼                                ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│       heroes.wlk        │   │       villanos.wlk       │
│                         │   │                          │
│   class Heroe           │   │   class Villano          │
│   - papasActivas        │   │   - estaTransformado     │
│   - lanzarPapa()        │   │   - animalTransformado   │
│   - agregar/removerPapa │   │   - recibirImpacto()     │
└───────────┬─────────────┘   │   - patrullar()          │
            │ Dispara         └──────────────────────────┘
            ▼                              ▲
┌─────────────────────────┐                │
│  elementosDelJuego.wlk  │                │ Impacta en
│                         │                │
│   class Papa ────────────────────────────┘
│   - avanzar(), impactar()
│
│   class Nivel / nivel1 / nivel2
│   - puntosPorDerrotar(villano)
└────────────────────────────────────────────────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo y Conceptos Clave

### 📄 `personajes.wlk`
* **Direcciones Polimórficas:** Se modelan los objetos bien conocidos `norte`, `sur`, `este`, `oeste`.
  * Cada uno responde a `dx()` y `dy()` con valores enteros (`0, 1`, `0, -1`, `1, 0`, `-1, 0`), permitiendo calcular desplazamientos sin sentencias `if` anidadas.
* **Clase `Personaje`:**
  * Incorpora el atributo `var property direccion = norte` y `var property paso = false` (para alternar pasos de caminata).
  * Incorpora `alternarPaso()` que invierte el booleano `paso = !paso`.

### 📄 `heroes.wlk`
* **Gestión de Proyectiles:**
  * `papasActivas`: Lista de papas que el héroe tiene volando actualmente.
  * `cantPapasMax`: Límite de disparos simultáneos permitidos (por defecto 1).
  * `lanzarPapa(nivel)`: Instancia un nuevo objeto `Papa`, lo asocia al héroe y lo agrega a `papasActivas`.
  * `removerPapa(papa)`: Limpia el proyectil de la lista cuando impacta o sale del mapa.

### 📄 `villanos.wlk`
* **Mecánica de Purificación / Transformación:**
  * `estaTransformado`: Booleano que indica si fue alcanzado por una papa.
  * `animalTransformado`: String con el tipo de animal ("llama", "lagarto", "mula").
  * `recibirImpacto(heroe)`: Marca `estaTransformado = true`, suma puntos al héroe usando el polimorfismo de `nivel.puntosPorDerrotar(self)`, y desactiva su capacidad de atacar.
  * `patrullar()`: Avanza paso a paso siguiendo una secuencia de direcciones (`camino`), ciclando el índice.

### 📄 `elementosDelJuego.wlk`
* **Clase `Papa`:**
  * Atributos: `x, y, direccion, personaje, nivel`.
  * `avanzar()`: Suma `direccion.dx()` y `direccion.dy()` a sus coordenadas.
  * `impactar(villano)`: Envía `villano.recibirImpacto(personaje)` y se auto-destruye llamando a `personaje.removerPapa(self)`.
* **Polimorfismo de Niveles:**
  * `class Nivel`: Clase abstracta que define el contrato `puntosPorDerrotar(villano)`.
  * `object nivel1`: Devuelve 10 puntos por derrotar al demoledor, 5 por otros.
  * `object nivel2`: Devuelve 15 puntos por derrotar al envenenador, 10 por otros.

---

## 💡 4. Conceptos Teóricos de POO Demostrados en este Commit

1. **Polimorfismo en Direcciones:** Los objetos `norte`, `sur`, `este`, `oeste` comparten la misma interfaz (`dx()`, `dy()`, `numero()`), permitiendo que el cálculo del movimiento sea una simple suma vectorial `x + direccion.dx()`.
2. **Polimorfismo en Niveles:** Tanto `nivel1` como `nivel2` implementan `puntosPorDerrotar(villano)`, permitiendo que el cálculo de puntos dependa de las reglas de cada nivel sin condicionales rígidos.
3. **Manejo de Colecciones y Ciclo de Vida:** La lista `papasActivas` del héroe gestiona qué proyectiles existen y garantiza que no se supere el límite de proyectiles activos en pantalla.

---

## 🗣️ 5. Guía para la Defensa Oral (Preguntas de Examen)

| Pregunta Típica del Profesor | ¿Cómo responder con fundamentos? |
| :--- | :--- |
| **"¿Por qué modelaron las direcciones como objetos individuales (`norte`, `sur`, etc.) en lugar de simples Strings?"** | *"Porque al ser objetos con comportamiento (`dx()`, `dy()`), logramos polimorfismo. Quien mueve un objeto simplemente suma las componentes sin necesidad de hacer un `switch` o `if (dir == 'norte')`."* |
| **"¿Cómo se asegura que un villano transformado no siga atacando al héroe?"** | *"En el método `atacar(heroe)`, el villano valida `if (!estaTransformado)`. Al recibir el impacto de una papa, `estaTransformado` pasa a `true`, neutralizando el ataque."* |
| **"¿Quién es el responsable de calcular el puntaje que otorga cada enemigo?"** | *"El objeto `Nivel` correspondiente. Aplicamos polimorfismo delegando en `nivel.puntosPorDerrotar(villano)`, de modo que cada nivel define sus propias recompensas sin acoplar esa lógica al villano ni al héroe."* |

---

## 🧪 6. Cómo Ejecutar y Validar los Tests

Abrí la terminal en la carpeta de este commit y ejecutá:
```bash
wollok test
```

### Casos de prueba cubiertos:
1. `✓ "El heroe lanza un proyectil Papa y se registra en sus papas activas"`
2. `✓ "El proyectil Papa avanza y colisiona con el villano"`
3. `✓ "El villano patrulla siguiendo su camino configurado"`
4. `✓ "Los niveles otorgan diferente puntaje segun el villano derrotado"`
5. `✓ "El cofre se abre correctamente y se obtiene la llave"`