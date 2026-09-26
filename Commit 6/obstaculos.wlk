import wollok.game.*
import motor2d.actor.*

// ============================================
// OBSTACULOS MODULARES CON AABB EN SUB-GRID
// ============================================

class Obstaculo inherits Actor {
  var property anchoCeldas = 3
  var property altoCeldas  = 3

  override method width() = anchoCeldas * 5
  override method height() = altoCeldas * 5
  override method esDinamico() = false
  override method esObstaculo() = true

  // Verificación de ocupación de área en coordenadas sub-grid
  method ocupaPosicion(checkX, checkY) =
    checkX < (x + self.width()) && (checkX + 5) > x &&
    checkY < (y + self.height()) && (checkY + 5) > y

  method recibirImpacto(papa) {
    papa.destruir()
  }

  override method colisionoCon(otro) {
    otro.recibirImpacto(self)
  }
}
