import wollok.game.*
import personajes.*

class Heroe inherits Personaje {
  var property puntos = 0
  var property tieneLlave = false
  var property nivelActual = null
  var property cantPapasMax = 1
  const property papasActivas = []

  method moverArriba() {
    direccion = norte
    self.alternarPaso()
    if (position.y() < game.height() - 2) {
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

  method posicionInicialPapa() {
    return game.at(position.x() + direccion.dx(), position.y() + direccion.dy())
  }

  method agregarPapaActiva(papa) {
    papasActivas.add(papa)
  }

  method removerPapa(papa) {
    papasActivas.remove(papa)
  }
}