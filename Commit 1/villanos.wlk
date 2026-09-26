import personajes.*

// ==========================================
// AMENAZAS Y VILLANOS
// ==========================================

class Villano inherits Personaje {
  var property poderAtaque = 10
  var property estaTransformado = false

  method atacar(heroe) {
    heroe.recibirDano(poderAtaque)
  }

  method recibirImpacto() {
    estaTransformado = true
  }
}
