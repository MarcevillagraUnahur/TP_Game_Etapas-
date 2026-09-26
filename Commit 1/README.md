# 🏔️ Defensores del Glaciar - Commit 1: Modelo de Dominio Inicial (POO Pura)

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta primera etapa nos enfocamos **exclusivamente en modelar la lógica de negocio (el Dominio)** mediante Objetos y Clases en Wollok, **sin mezclar todavía nada de gráficos ni del motor de juego (`wollok.game`)**.

El objetivo es construir una base sólida, limpia, desacoplada y 100% testeable donde validamos que los personajes tienen vida, reciben daño, pierden vidas y pueden interactuar con elementos básicos (llaves y cofres).

---

## 🗺️ 2. Mapa de Relación entre Archivos y Clases

```
┌────────────────────────────────────────────────────────┐
│                   personajes.wlk                       │
│                                                        │
│   ┌────────────────────────────────────────────────┐   │
│   │               class Personaje                  │   │
│   │   - nombre, energia, vidas                     │   │
│   │   - recibirDano(cant), perderVida()            │   │
│   └──────────────────────┬─────────────────────────┘   │
└──────────────────────────┼─────────────────────────────┘
                           │ (Herencia)
             ┌─────────────┴─────────────┐
             ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐
│       heroes.wlk        │ │      villanos.wlk       │
│                         │ │                         │
│   class Heroe           │ │   class Villano         │
│   - puntos, tieneLlave  │ │   - poderAtaque         │
│   - ganarPuntos()       │ │   - atacar(heroe)       │
│   - agarrarLlave()      │ │   - recibirImpacto()    │
└─────────────────────────┘ └─────────────────────────┘

┌────────────────────────────────────────────────────────┐
│                elementosDelJuego.wlk                   │
│                                                        │
│   class Cofre           class Llave                    │
│   - estaAbierto         (Elemento pasivo)              │
│   - abrir()                                            │
└────────────────────────────────────────────────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo y Conceptos Clave

### 📄 `personajes.wlk`
* **Propósito:** Concentra todo el comportamiento y estado común a cualquier entidad viva del juego.
* **Atributos:**
  * `nombre`: Identificador del personaje (String).
  * `energia`: Nivel de salud actual (comienza en 100).
  * `vidas`: Cantidad de vidas o intentos restantes (comienza en 3).
* **Métodos Clave:**
  * `recibirDano(cantidad)`: Resta energía asegurando que no baje de cero con `.max(0)`. Si la energía llega a 0, automáticamente **delega** la pérdida de vida en `perderVida()`.
  * `perderVida()`: Resta una vida. Si aún le quedan vidas, restaura la energía a 100 para permitirle seguir jugando.
  * `estaVivo()`: Retorna un booleano (`vidas > 0`).

### 📄 `heroes.wlk`
* **Propósito:** Modela a los protagonistas defensores (`Heroe`).
* **Concepto POO aplicado:** **Herencia**. `Heroe` hereda de `Personaje`, reutilizando energía, vidas y lógica de daño sin duplicar código.
* **Atributos específicos:**
  * `puntos`: Acumulador de puntuación obtenida al cumplir objetivos.
  * `tieneLlave`: Booleano que registra si recogió la llave del nivel.
* **Métodos específicos:**
  * `ganarPuntos(cant)`: Incrementa la puntuación.
  * `agarrarLlave()`: Setea `tieneLlave = true`.

### 📄 `villanos.wlk`
* **Propósito:** Modela a los enemigos que atacan el glaciar (`Villano`).
* **Conceptos POO aplicados:**
  * **Herencia**: Hereda de `Personaje`.
  * **Delegación y Encapsulamiento**: En `atacar(heroe)`, el villano no le modifica directamente la variable `energia` al héroe (lo que rompería el encapsulamiento), sino que le envía el mensaje `heroe.recibirDano(poderAtaque)`.
* **Atributos específicos:**
  * `poderAtaque`: Cantidad de daño que inflige en cada ataque (por defecto 20).

### 📄 `elementosDelJuego.wlk`
* **Propósito:** Modela objetos inanimados con estado mutable (`Cofre`) y elementos pasivos (`Llave`).
* **Métodos:**
  * `Cofre.abrir()`: Cambia el estado interno `estaAbierto = true`.

---

## 💡 4. Conceptos Teóricos de POO Demostrados en este Commit

1. **Herencia:** `Heroe` y `Villano` extienden de `Personaje`, compartiendo atributos (`energia`, `vidas`) y comportamiento (`recibirDano()`).
2. **Encapsulamiento:** El estado interno de los objetos solo se muta a través de métodos con lógica de negocio controlada (por ejemplo, `recibirDano` no permite números negativos).
3. **Delegación:** `recibirDano()` delega en `perderVida()` cuando la energía llega a 0.
4. **Desacoplamiento del Dominio:** El juego funciona y se valida 100% mediante lógica pura sin depender de una ventana visual o interfaz gráfica.

---

## 🗣️ 5. Guía para la Defensa Oral (Preguntas de Examen)

| Pregunta Típica del Profesor | ¿Cómo responder con fundamentos? |
| :--- | :--- |
| **"¿Por qué `Heroe` y `Villano` heredan de `Personaje`?"** | *"Porque comparten estado y comportamiento común (energía, vidas, lógica de daño). Aplicamos herencia para evitar repetición de código y mantener una única fuente de verdad para la lógica vital."* |
| **"¿Por qué el villano no le resta energía directamente al héroe con un setter?"** | *"Porque violaría el principio de encapsulamiento. El villano solo le envía el mensaje `heroe.recibirDano(poderAtaque)`, y el propio héroe decide cómo impacta ese daño en su salud y si debe perder una vida."* |
| **"¿Por qué no agregaron `wollok.game` en este primer commit?"** | *"Porque seguimos la buena práctica de arquitectura de software: primero diseñamos y testeamos el modelo de dominio puro. Una vez validada la lógica, la interfaz gráfica se monta encima sin acoplamientos innecesarios."* |

---

## 🧪 6. Cómo Ejecutar y Validar los Tests

Abrí la terminal en la carpeta de este commit y ejecutá:
```bash
wollok test
```

### Casos de prueba cubiertos:
1. `✓ "El heroe inicia con 100 de energia y 3 vidas"`
2. `✓ "El heroe recibe daño y disminuye su energia"`
3. `✓ "Al perder toda la energia pierde 1 vida y se recupera la energia"`
4. `✓ "El villano ataca al heroe con su poder de ataque"`
5. `✓ "El heroe puede sumar puntos y agarrar la llave"`
6. `✓ "El cofre se abre correctamente"`