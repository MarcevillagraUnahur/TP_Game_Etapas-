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
        x = x,
        y = y,
        direccion = direccion,
        personaje = self,
        nivel = nivelActual
      )
      papasActivas.add(papa)
      return papa
    }
    return null
  }

  method removerPapa(papa) {
    papasActivas.remove(papa)
  }
}
