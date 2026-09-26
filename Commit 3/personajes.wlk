import wollok.game.*

// ==========================================
// DIRECCIONES POLIMÓRFICAS
// ==========================================

class Direccion {
  method dx()
  method dy()
  method numero()
  method opuesta()
}

object norte inherits Direccion {
  override method dx() = 0
  override method dy() = 1
  override method numero() = 1
  override method opuesta() = sur
}

object sur inherits Direccion {
  override method dx() = 0
  override method dy() = -1
  override method numero() = 2
  override method opuesta() = norte
}

object este inherits Direccion {
  override method dx() = 1
  override method dy() = 0
  override method numero() = 3
  override method opuesta() = oeste
}

object oeste inherits Direccion {
  override method dx() = -1
  override method dy() = 0
  override method numero() = 4
  override method opuesta() = este
}

// ==========================================
// CLASE BASE PERSONAJE CON VISUAL DE WOLLOK
// ==========================================

class Personaje {
  var property nombre = ""
  var property position = game.at(0, 0)
  var property energia = 100
  var property vidas = 3
  var property direccion = norte
  var property usandoFrameA = true

  // Contrato Visual de Wollok Game
  method image() {
    const frame = if (usandoFrameA) "A" else "B"
    return nombre + direccion.numero() + frame + ".png"
  }

  method alternarPaso() {
    usandoFrameA = !usandoFrameA
  }

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
