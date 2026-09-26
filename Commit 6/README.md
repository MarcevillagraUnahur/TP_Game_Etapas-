# 🎬 Defensores del Glaciar - Commit 6: Entrega Final Completa (Cinemáticas de Video, Audio y Motor 2D)

---

## 🎯 1. ¿Cuál es el Objetivo de este Commit?
En esta sexta y última etapa completamos el desarrollo integral de **Defensores del Glaciar**, integrando todas las capas construidas en los commits anteriores junto con dos sistemas de nivel profesional:
1. **Reproductor de Cinemáticas de Video en Wollok Game (`cinematica/`)**:
   - Pipeline automatizado en TypeScript (`procesadorCinematica.ts`) y Node.js (`prepararCinematicas.js`) que extrae fotogramas con `ffmpeg` a 10 FPS optimizados a 750x750px.
   - Sistema de caché inteligente con hash MD5 para regenerar únicamente cuando los videos fuente cambian.
   - Reproductor polimórfico en Wollok (`ReproductorCinematica`) que sincroniza audio MP3 y proyecta los frames secuencialmente con `game.onTick`.
2. **Paisaje Sonoro y Música Adaptativa**:
   - Banda sonora andina instrumental con quena y sikus (`Música Tradicional dos Andes - El Milagroso.mp3`).
   - Pistas ambientales para niveles y persecución (`Sun_Gate_Pursuit.mp3`, `Canyon_Runner.mp3`, `Soplo_Entre_Rocas.mp3`).
3. **Flujo de Juego Completo y Cinemáticas de Transición**:
   - Cinemática de Introducción / Nivel 1.
   - Cinemática Intermedia tras derrotar al Demoledor y salvar el primer glaciar.
   - Cinemática Final de Victoria tras vencer al Envenenador.

---

## 🗺️ 2. Mapa de Arquitectura Global del Sistema

```
┌────────────────────────────────────────────────────────────────────────┐
│                          defensores.wpgm                               │
│                                                                        │
│   - Punto de entrada principal                                         │
│   - Configura pantalla 75x75 celdas a 40 FPS                           │
│   - Conecta teclado, audio y llamadas a cinemáticas                    │
└──────┬────────────────────────┬────────────────────────┬───────────────┘
       │                        │                        │
       ▼                        ▼                        ▼
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────────────┐
│     motor2d/     │   │   cinematica/    │   │         Dominio          │
│                  │   │                  │   │                          │
│ object engine    │   │ Reproductor...   │   │ class Heroe              │
│ class Actor (AABB│   │ (Frames + Audio) │   │ class Villano            │
│ class Animacion  │   │ Pipeline Node.js │   │ class Obstaculo          │
│ configMotor      │   │ procesadorTS     │   │ object gestorDeNiveles   │
└──────────────────┘   └──────────────────┘   │ Clases HUD (Vidas/Energia│
                                              └──────────────────────────┘
```

---

## 📦 3. Desglose Archivo por Archivo

### 📄 `cinematica/cinematica.wlk`
* **`ReproductorCinematica`**:
  * Controla la reproducción de cinemáticas en pantalla completa.
  * Oculta los elementos visuales del juego, reproduce la música de la cinemática, avanza frame a frame en un tick de 100ms (10 FPS) y, al terminar (o presionar ESPACIO/ENTER para skipear), ejecuta el callback de continuación (por ejemplo, cargar el Nivel 2).

### 📄 `cinematica/procesadorCinematica.ts` y `prepararCinematicas.js`
* **Pipeline de Generación de Frames:**
  * Script de automatización que detecta videos `.mp4` en `Prueba de videos/`, genera los frames `.png` secuenciales en `assets/cinematicas/` con resolución escalada y crea el manifiesto de frames para Wollok.

### 📄 `motor2d/` (`actor.wlk`, `engine.wlk`, `config.wlk`, `animacion.wlk`)
* **Motor 2D a 40 FPS:**
  * Administra la sub-grilla 75x75, las colisiones AABB entre proyectiles, héroes, villanos y camiones, y los impulsos de movimiento suave.

### 📄 `heroes.wlk`, `villanos.wlk`, `elementosDelJuego.wlk`, `obstaculos.wlk`
* **Lógica de Juego:**
  * Implementan el ciclo completo: movimiento, lanzamiento de papas, transformación de enemigos, resolución de puzles (cofre + llave + poste) y HUD interactivo.

---

## 💡 4. Resumen de Conceptos de POO Aplicados a lo Largo de Todo el Proyecto

| Concepto POO | Dónde se aplica en el Proyecto |
| :--- | :--- |
| **Herencia** | `Personaje inherits Actor`, `Heroe inherits Personaje`, `Villano inherits Personaje`, `Obstaculo inherits Actor`. |
| **Polimorfismo** | Direcciones (`norte`, `sur`, `este`, `oeste`), Niveles (`nivel1`, `nivel2`), Actores gráficos en Wollok Game (`image()`, `position()`), HUDs. |
| **Encapsulamiento** | Salud y vidas del héroe (`recibirDano`, `perderVida`), coordenadas protegidas en `Actor` con métodos `moverA` y `desplazar`. |
| **Delegación** | `Papa.impactar` delega en `Villano.recibirImpacto`, `Heroe` delega en `Nivel` para validar obstáculos y límites. |
| **Despacho Doble (Double Dispatch)** | En colisiones físicas: `actor.colisionoCon(otro)` -> `otro.recibirImpacto(actor)`. |
| **Manejo de Estado Complejo** | Estados de villano (`estaTransformado`, `estaAtacando`, `persiguiendo`), estados de cofre (`estaAbierto`), estados de nivel (`estaEnMenu`, `estaJugando`). |

---

## 🗣️ 5. Guía de Preguntas para la Defensa Oral del Grupo

| Pregunta de Examen | Respuesta Modelo para cualquier Integrante |
| :--- | :--- |
| **"¿Cómo evolucionó el proyecto a lo largo de los commits?"** | *"Comenzamos en el **Commit 1** diseñando el dominio puro y testeando vidas/daño sin gráficos. En el **Commit 2** agregamos proyectiles y niveles polimórficos. En el **Commit 3** integramos la grilla 15x15 de Wollok Game con sprites A/B. En el **Commit 4** agregamos HUD, puzles y gestión de pantallas. En el **Commit 5** creamos nuestro propio Motor 2D a 40 FPS con subgrilla 75x75 y colisiones AABB. Finalmente en el **Commit 6** integramos cinemáticas de video y audio."* |
| **"¿Cómo lograron reproducir video en Wollok Game?"** | *"Diseñamos una herramienta en TypeScript que procesa los videos con `ffmpeg`, extrayendo frames secuenciales a 10 FPS optimizados. En Wollok creamos un `ReproductorCinematica` que va proyectando esos frames en orden y sincroniza el audio con eventos periódicos de tick."* |
| **"¿Cómo garantizan que el juego sea mantenible y fácil de extender?"** | *"Mediante un fuerte desacoplamiento: el motor gráfico no sabe qué es un héroe o un villano (solo conoce `Actor`), los niveles son objetos polimórficos intercambiables, y la lógica de combate se valida con tests unitarios automatizados."* |

---

## 🧪 6. Cómo Ejecutar los Tests y el Juego

### Para correr la suite de tests unitarios:
```bash
wollok test
```

### Para jugar la versión final:
Abrí `defensores.wpgm` en Wollok o ejecutalo desde la consola.