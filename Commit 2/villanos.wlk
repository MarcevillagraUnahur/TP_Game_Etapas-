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

  method atacar(heroe) {
    if (!estaTransformado) {
      heroe.recibirDano(poderAtaque)
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
      self.mover(dir.dx(), dir.dy())
      pasoActual = (pasoActual + 1) % camino.size()
    }
  }
}
