import wollok.game.*
import engine.*

class Actor {
  var property x = 0
  var property y = 0
  var property width = 1
  var property height = 1
  var property image = "motor2d_default.png"
  var property position = game.at(0, 0)
  var property activo = true

  // Categorización para optimización O(N) de colisiones
  method esDinamico() = false
  method esObstaculo() = false

  method sincronizarPosicionVisual() {
    position = game.at(x.truncate(0), y.truncate(0))
  }

  method cambiarImagen(nuevaImagen) {
    image = nuevaImagen
  }

  method moverA(nuevoX, nuevoY) {
    x = nuevoX
    y = nuevoY
    self.sincronizarPosicionVisual()
  }

  method desplazar(dx, dy) {
    x += dx
    y += dy
    self.sincronizarPosicionVisual()
  }

  // --- Detección de Colisiones AABB ---
  method solapaEnX(otro) {
    return (x < (otro.x() + otro.width())) and ((x + width) > otro.x())
  }

  method solapaEnY(otro) {
    return (y < (otro.y() + otro.height())) and ((y + height) > otro.y())
  }

  method colisionaCon(otro) {
    return (self != otro) and self.solapaEnX(otro) and self.solapaEnY(otro)
  }

  // --- Ciclo de Vida y Eventos ---
  method actualizar() {
    // Subclases
  }

  method colisionoCon(otro) {
    // Subclases
  }

  method destruir() {
    activo = false
    engine.despawn(self)
  }
}
