import personajes.*

// ==========================================
// HÉROES DEFENSORES
// ==========================================

class Heroe inherits Personaje {
  var property puntos = 0
  var property tieneLlave = false

  method ganarPuntos(cantidad) {
    puntos += cantidad
  }

  method agarrarLlave() {
    tieneLlave = true
  }
}
