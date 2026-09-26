import personajes.*
import heroes.*
import villanos.*

// ==========================================
// PROYECTIL PAPA
// ==========================================

class Papa {
  var property x = 0
  var property y = 0
  var property direccion = norte
  var property personaje = null
  var property nivel = null
  const velocidad = 1

  method avanzar() {
    x += direccion.dx() * velocidad
    y += direccion.dy() * velocidad
  }

  method colisionaCon(otro) {
    return (x - otro.x()).abs() <= 1 && (y - otro.y()).abs() <= 1
  }

  method destruir() {
    if (personaje != null) {
      personaje.removerPapa(self)
    }
  }
}

// ==========================================
// ELEMENTOS Y NIVELES
// ==========================================

class Obstaculo {
  var property x = 0
  var property y = 0
  var property ancho = 1
  var property alto = 1

  method esObstaculo() = true
}

class Cofre {
  var property x = 0
  var property y = 0
  var property estaAbierto = false

  method abrir() {
    estaAbierto = true
  }
}

class Llave {
  var property x = 0
  var property y = 0
}

class Poste {
  var property x = 0
  var property y = 0
}

class Nivel {
  const property obstaculos = []

  method puntosPorDerrotar(villano)
  method esNivel1() = false
  method esNivel2() = false
}

object nivel1 inherits Nivel(
  obstaculos = [new Obstaculo(x = 3, y = 2), new Obstaculo(x = 9, y = 7)]
) {
  override method esNivel1() = true

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "demoledor") return 10
    return 5
  }

  method caminoDemoledor() = [este, este, norte, norte, oeste, oeste, sur, sur]
}

object nivel2 inherits Nivel(
  obstaculos = [new Obstaculo(x = 2, y = 4), new Obstaculo(x = 7, y = 8)]
) {
  override method esNivel2() = true

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "envenenador") return 15
    return 10
  }

  method caminoEnvenenador() = [este, este, este, norte, oeste, oeste, oeste, sur]
}
