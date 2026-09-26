import wollok.game.*
import personajes.*
import heroes.*
import villanos.*

// ==========================================
// PROYECTIL PAPA VISUAL
// ==========================================

class Papa {
  var property position = game.at(0, 0)
  var property direccion = norte
  var property personaje = null
  var property nivel = null

  method image() = "papa" + direccion.numero() + ".png"

  method iniciarVuelo() {
    game.onTick(200, "vueloPapa" + self.identity().toString(), {
      self.avanzar()
    })
  }

  method avanzar() {
    const proxX = position.x() + direccion.dx()
    const proxY = position.y() + direccion.dy()

    if (proxX < 0 || proxX >= game.width() || proxY < 0 || proxY >= game.height()) {
      self.destruir()
    } else {
      position = game.at(proxX, proxY)
    }
  }

  method destruir() {
    try {
      game.removeTickEvent("vueloPapa" + self.identity().toString())
    } catch e : Exception {}

    if (game.hasVisual(self)) {
      game.removeVisual(self)
    }
    if (personaje != null) {
      personaje.removerPapa(self)
    }
  }
}

// ==========================================
// FONDO, OBSTACULOS Y NIVELES
// ==========================================

object fondo {
  var property image = "menuInicio.png"
  var property position = game.at(0, 0)
}

class Obstaculo {
  var property position = game.at(0, 0)
  var property image = "Camion1.png"
}

class Cofre {
  var property position = game.at(0, 0)
  var property estaAbierto = false

  method image() = if (estaAbierto) "cofre.png" else "cofreC.png"

  method abrir() {
    estaAbierto = true
  }
}

class Llave {
  var property position = game.at(0, 0)
  method image() = "llave.png"
}

class Nivel {
  var property imagenFondo = "fondo1.png"
  const property obstaculos = []

  method puntosPorDerrotar(villano)
  method esNivel1() = false
  method esNivel2() = false
}

object nivel1 inherits Nivel(
  imagenFondo = "fondo1.png",
  obstaculos = [new Obstaculo(position = game.at(3, 2), image = "Camion1.png"), new Obstaculo(position = game.at(9, 7), image = "Camion2.png")]
) {
  override method esNivel1() = true

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "demoledor") return 10
    return 5
  }

  method caminoDemoledor() = [este, este, norte, norte, oeste, oeste, sur, sur]
}

object nivel2 inherits Nivel(
  imagenFondo = "fondo2.png",
  obstaculos = [new Obstaculo(position = game.at(2, 4), image = "Camion1.png"), new Obstaculo(position = game.at(7, 8), image = "Camion1.png")]
) {
  override method esNivel2() = true

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "envenenador") return 15
    return 10
  }

  method caminoEnvenenador() = [este, este, este, norte, oeste, oeste, oeste, sur]
}

object gestorDeNiveles {
  var property estaEnMenu = true
  var property estaJugando = false
  var property villanoActual = null

  method configurarNivel1(heroe) {
    estaEnMenu = false
    estaJugando = true
    fondo.image(nivel1.imagenFondo())
    
    heroe.nombre("Tupac")
    heroe.position(game.at(0, 2))
    heroe.nivelActual(nivel1)

    nivel1.obstaculos().forEach({ obs =>
      if (!game.hasVisual(obs)) game.addVisual(obs)
    })

    villanoActual = new Villano(
      nombre = "demoledor",
      position = game.at(5, 5),
      nivel = nivel1,
      camino = nivel1.caminoDemoledor()
    )
    game.addVisual(villanoActual)

    game.onTick(600, "patrullaVillano", {
      if (villanoActual != null && game.hasVisual(villanoActual)) {
        villanoActual.avanzarPaso()
      }
    })
  }
}
