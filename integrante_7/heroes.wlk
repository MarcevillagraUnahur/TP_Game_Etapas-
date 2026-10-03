import wollok.game.*
import personajes.*
import elementosDelJuego.*

class Heroe inherits Personaje(nombre = "Tupac", position = game.at(0, 2)) {
  var vidas = 3
  var puntos = 0
  var nivelActual = nivel1
  var property tieneLlave = false
  var papasLanzadas = 0
  var property cantPapasMax = 1
  const property papasActivas = []

  method nivelActual() = nivelActual

  method nivelActual(nuevoNivel) {
    nivelActual = nuevoNivel
    game.boardGround(nuevoNivel.imagenFondo())
  }
  
  method vidas() = vidas
  method puntos() = puntos
  
  method ganarPuntos(cant) {
    puntos += cant
  }
  
  method perderVida() {
    vidas = (vidas - 1).max(0)
    if (vidas == 0) {
      game.say(self, "Me quede sin vidas!")
      gestorDeNiveles.perderJuego(self)
    }
  }
  
  method recibirDano(cantidad) {
    self.perderVida()
  }

  method recibirDaño(cantidad) {
    self.perderVida()
  }
  
  method moverseHacia(dir) {
    self.actualizarAnimacion(dir)
    const nuevaPosicion = dir.siguiente(position)
    if (self.esPosicionValida(nuevaPosicion)) {
      position = nuevaPosicion
    }
  }
  
  method esPosicionValida(pos) =
    pos.x().between(0, game.width() - 1) &&
    pos.y().between(nivelActual.yMinimo(), nivelActual.yMaximoPara(pos.x())) &&
    (!nivelActual.hayObstaculoEn(pos))
  
  method lanzarPapa() {
    if (papasActivas.size() < cantPapasMax) {
      papasLanzadas += 1
      const papa = new Papa(
        position = position,
        direccion = direccion,
        nivel = nivelActual,
        id = papasLanzadas,
        personaje = self
      )
      papasActivas.add(papa)
      papa.lanzar()
    }
  }

  method removerPapaActiva(papa) {
    papasActivas.remove(papa)
  }
}
