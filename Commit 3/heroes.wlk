import wollok.game.*
import personajes.*
import elementosDelJuego.*

// ==========================================
// HÉROE JUGABLE
// ==========================================

class Heroe inherits Personaje {
  var property puntos = 0
  var property tieneLlave = false
  var property nivelActual = nivel1
  var property cantPapasMax = 1
  const property papasActivas = []
  var totalPapasLanzadas = 0

  method moverArriba() {
    direccion = norte
    self.alternarPaso()
    if (position.y() < game.height() - 1) {
      position = position.up(1)
    }
  }

  method moverAbajo() {
    direccion = sur
    self.alternarPaso()
    if (position.y() > 0) {
      position = position.down(1)
    }
  }

  method moverIzquierda() {
    direccion = oeste
    self.alternarPaso()
    if (position.x() > 0) {
      position = position.left(1)
    }
  }

  method moverDerecha() {
    direccion = este
    self.alternarPaso()
    if (position.x() < game.width() - 1) {
      position = position.right(1)
    }
  }

  method ganarPuntos(cantidad) {
    puntos += cantidad
  }

  method agarrarLlave() {
    tieneLlave = true
  }

  method lanzarPapa() {
    if (papasActivas.size() < cantPapasMax) {
      totalPapasLanzadas += 1
      const papa = new Papa(
        position = self.posicionInicialPapa(),
        direccion = direccion,
        personaje = self,
        nivel = nivelActual
      )
      papasActivas.add(papa)
      game.addVisual(papa)
      papa.iniciarVuelo()
      return papa
    }
    return null
  }

  method posicionInicialPapa() {
    return game.at(position.x() + direccion.dx(), position.y() + direccion.dy())
  }

  method removerPapa(papa) {
    papasActivas.remove(papa)
  }
}
