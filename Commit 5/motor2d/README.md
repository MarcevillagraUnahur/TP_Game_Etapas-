# 🎮 Wollok 2D Game Engine (`motor2d`)

Motor de físicas y renderizado 2D de propósito general para **Wollok Game** con soporte para colisiones AABB multicelda, movimiento continuo y alto rendimiento (40 FPS).

---

## 📂 Módulos del Motor

1. **[config.wlk](file:///f:/UNAHUR/Objetos_I/TRES%20EMPANADAS/motor2d/config.wlk):** Configuración desacoplada de resolución lógica, tamaño de celda en píxeles y tasa de refresco en ms.
2. **[actor.wlk](file:///f:/UNAHUR/Objetos_I/TRES%20EMPANADAS/motor2d/actor.wlk):** Clase base `Actor` con detección de colisiones rectangulares AABB ($O(1)$) y sincronización visual.
3. **[engine.wlk](file:///f:/UNAHUR/Objetos_I/TRES%20EMPANADAS/motor2d/engine.wlk):** Manager de escena y loop de física a 40 FPS que categoriza entidades en dinámicas y obstáculos ($O(N)$).
4. **[animacion.wlk](file:///f:/UNAHUR/Objetos_I/TRES%20EMPANADAS/motor2d/animacion.wlk):** Secuenciador de frames PNG por ticks para efectos y animaciones.

---

## 📖 Documentación Completa

Para conocer todos los detalles de arquitectura, fórmulas matemáticas de colisión AABB, optimizaciones de rendimiento y la guía paso a paso para crear nuevos juegos, consulta:

👉 **[DOCUMENTACION_MOTOR_2D.md](file:///f:/UNAHUR/Objetos_I/TRES%20EMPANADAS/DOCUMENTACION_MOTOR_2D.md)**
