import wollok.game.*
import personajes.*

// ==========================================
// AMENAZAS Y VILLANOS
// ==========================================

class Villano inherits Personaje {
  var property poderAtaque = 10
  var property estaTransformado = false
  var property animal = null
  var property nivel = null
  var property camino = []
  var pasoActual = 0

  override method image() {
    if (estaTransformado) {
      return animal + direccion.numero() + ".png"
    }
    return super()
  }

  method atacar(heroe) {
    if (!estaTransformado) {
      heroe.recibirDano(poderAtaque)
      game.say(self, "TOMA ESTO!")
    }
  }

  method recibirImpacto(papa) {
    if (!estaTransformado) {
      estaTransformado = true
      animal = ["condor", "lagarto", "llama", "mula"].anyOne()
      if (papa.personaje() != null) {
        papa.personaje().ganarPuntos(self.puntosOtorgados())
      }
    }
    papa.destruir()
  }

  method puntosOtorgados() {
    if (nivel != null) return nivel.puntosPorDerrotar(self)
    return 10
  }

  method avanzarPaso() {
    if (!camino.isEmpty()) {
      const dir = camino.get(pasoActual)
      direccion = dir
      self.alternarPaso()
      position = game.at(
        (position.x() + dir.dx()).max(0).min(game.width() - 1),
        (position.y() + dir.dy()).max(0).min(game.height() - 1)
      )
      pasoActual = (pasoActual + 1) % camino.size()
    }
  }
}
