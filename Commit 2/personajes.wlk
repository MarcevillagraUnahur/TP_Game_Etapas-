// ==========================================
// DIRECCIONES Y CLASE BASE PERSONAJE
// ==========================================

class Direccion {
  method dx()
  method dy()
  method opuesta()
}

object norte inherits Direccion {
  override method dx() = 0
  override method dy() = 1
  override method opuesta() = sur
}

object sur inherits Direccion {
  override method dx() = 0
  override method dy() = -1
  override method opuesta() = norte
}

object este inherits Direccion {
  override method dx() = 1
  override method dy() = 0
  override method opuesta() = oeste
}

object oeste inherits Direccion {
  override method dx() = -1
  override method dy() = 0
  override method opuesta() = este
}

class Personaje {
  var property nombre = ""
  var property x = 0
  var property y = 0
  var property energia = 100
  var property vidas = 3
  var property direccion = norte

  method estaVivo() = vidas > 0

  method mover(dx, dy) {
    x += dx
    y += dy
  }

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
