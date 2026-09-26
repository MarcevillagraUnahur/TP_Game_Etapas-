// ==========================================
// MODELO DE DOMINIO BASE: PERSONAJES
// ==========================================

class Personaje {
  var property nombre = ""
  var property energia = 100
  var property vidas = 3

  method estaVivo() = vidas > 0

  method recibirDano(cantidad) {
    energia = (energia - cantidad).max(0)
    if (energia == 0) {
      self.perderVida()
    }
  }

  method perderVida() {
    vidas = (vidas - 1).max(0)
    if (self.estaVivo()) {
      energia = 100
    } else {
      energia = 0
    }
  }
}
