# 🏔️ Defensores del Glaciar - Proyecto por Etapas Evolutivas

Repositorio organizado para la construcción pedagógica y presentación grupal del proyecto **Defensores del Glaciar** desarrollado en **Wollok**.

---

## 🗺️ Índice de Etapas de Desarrollo (Commits)

| Etapa / Carpeta | Nombre | Resumen de Contenido | Tests Unitarios |
| :--- | :--- | :--- | :---: |
| 📁 [Commit 1](./Commit%201) | **Modelo de Dominio Inicial** | Clases `Personaje`, `Heroe`, `Villano`, `Cofre`. Salud, daño y vidas en POO pura sin gráficos. | `6/6 ✓` |
| 📁 [Commit 2](./Commit%202) | **Combate, Proyectiles y Niveles** | Proyectiles `Papa`, transformación pacífica de villanos en animales, direcciones y niveles polimórficos. | `5/5 ✓` |
| 📁 [Commit 3](./Commit%203) | **Integración Gráfica Wollok Game (15x15)** | Grilla visual de 15x15, sprites dinámicos, animación de caminata A/B, teclado y papas visuales. | `4/4 ✓` |
| 📁 [Commit 4](./Commit%204) | **Puzles, HUD Visual y Transición de Niveles** | HUD reactivo (Corazones, Energía, Puntos, Nivel), puzle de Llave/Cofre/Poste y gestor de pantallas. | `4/4 ✓` |
| 📁 [Commit 5](./Commit%205) | **Motor 2D a 40 FPS (Sub-Grilla 75x75)** | Motor personalizado `motor2d/`, Game Loop a 40 FPS, colisiones AABB $O(N)$ y movimiento suave por impulsos. | `9/9 ✓` |
| 📁 [Commit 6](./Commit%206) | **Entrega Final: Cinemáticas y Audio** | Reproductor de video en Wollok (`cinematica/`), pipeline TypeScript con `ffmpeg`, música andina y juego completo. | `9/9 ✓` |

---

## 📖 Documentación y Guía de Defensa Oral
Cada carpeta incluye un archivo `README.md` con:
1. **Explicación paso a paso de cada clase y método.**
2. **Diagramas ASCII de relaciones entre archivos.**
3. **Conceptos de POO aplicados.**
4. **Preguntas típicas de examen de los profesores y respuestas modelo fundamentadas.**

---

## 🧪 Ejecución de Tests
Para correr las pruebas unitarias en cualquiera de las etapas:
```bash
wollok test
```