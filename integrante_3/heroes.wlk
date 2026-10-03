import wollok.game.*
import personajes.*
import obstaculos.*

class Heroe inherits Personaje(nombre = "Tupac", position = game.at(0, 2)) {
  var vidas = 3
  var puntos = 0
  const obstaculos = []

  method obstaculos() = obstaculos

  method vidas() = vidas
  method puntos() = puntos

  method ganarPuntos(cant) {
    puntos += cant
  }

  method perderVida() {
    vidas = (vidas - 1).max(0)
    if (vidas == 0) {
      game.say(self, "Me quede sin vidas!")
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
    pos.y().between(0, game.height() - 1) &&
    (!self.hayObstaculoEn(pos))

  method hayObstaculoEn(pos) =
    obstaculos.any({ obs => obs.ocupaCelda(pos) })
}
