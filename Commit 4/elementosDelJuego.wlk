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
// ELEMENTOS DEL PUZLE Y ESCENARIOS
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

class PosteConCaja {
  var property position = game.at(0, 0)
  method image() = "poste.png"
}

// ==========================================
// ELEMENTOS DEL HUD VISUAL
// ==========================================

class CorazonHUD {
  var property position = game.at(0, 0)
  var property indice = 1
  var property personaje = null

  method image() {
    if (personaje != null && personaje.vidas() >= indice) {
      return "corazon.png"
    }
    return "vacio.png"
  }
}

class BarraEnergiaHUD {
  var property position = game.at(0, 0)
  var property personaje = null

  method image() {
    if (personaje == null) return "energia100.png"
    const porcentaje = ((personaje.energia() / 20).truncate(0) * 20).max(0).min(100)
    return "energia" + porcentaje.toString() + ".png"
  }
}

class NivelHUD {
  var property position = game.at(0, 0)
  var property personaje = null

  method image() {
    if (personaje != null && personaje.nivelActual() != null) {
      return personaje.nivelActual().imagenHUD()
    }
    return "nivel1.png"
  }
}

class DigitoPuntajeHUD {
  var property position = game.at(0, 0)
  var property indice = 0
  var property personaje = null

  method formattedPuntos() {
    if (personaje == null) return "000"
    const pts = personaje.puntos()
    if (pts < 10) return "00" + pts.toString()
    if (pts < 100) return "0" + pts.toString()
    return pts.toString()
  }

  method image() {
    const texto = self.formattedPuntos()
    const charDigit = if (indice < texto.length()) texto.charAt(indice) else "0"
    return "n" + charDigit + ".png"
  }
}

// ==========================================
// NIVELES Y GESTOR DE NIVELES
// ==========================================

class Nivel {
  var property imagenHUD = "nivel1.png"
  var property imagenFondo = "fondo1.png"
  const property obstaculos = []

  method puntosPorDerrotar(villano)
  method esNivel1() = false
  method esNivel2() = false
}

object nivel1 inherits Nivel(
  imagenHUD = "nivel1.png",
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
  imagenHUD = "nivel2.png",
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
  var property cofreActual = null
  var property posteActual = null
  var property llaveActual = null
  var property villanoActual = null
  const objetosNivel = []

  method lanzarPapaHeroe(heroe) {
    if (heroe.papasActivas().size() < heroe.cantPapasMax()) {
      const papa = new Papa(
        position = heroe.posicionInicialPapa(),
        direccion = heroe.direccion(),
        personaje = heroe,
        nivel = heroe.nivelActual()
      )
      heroe.agregarPapaActiva(papa)
      game.addVisual(papa)
      papa.iniciarVuelo()
    }
  }

  method configurarNivel1(heroe) {
    estaEnMenu = false
    estaJugando = true
    fondo.image(nivel1.imagenFondo())
    self.limpiarNivel()

    heroe.nombre("Tupac")
    heroe.position(game.at(0, 2))
    heroe.nivelActual(nivel1)
    heroe.tieneLlave(false)

    nivel1.obstaculos().forEach({ obs =>
      game.addVisual(obs)
      objetosNivel.add(obs)
    })

    posteActual = new PosteConCaja(position = game.at(14, 11))
    game.addVisual(posteActual)
    objetosNivel.add(posteActual)

    cofreActual = new Cofre(position = game.at(0, 11))
    game.addVisual(cofreActual)
    objetosNivel.add(cofreActual)

    llaveActual = new Llave(position = game.at(12, 14))

    villanoActual = new Villano(
      nombre = "demoledor",
      position = game.at(5, 5),
      nivel = nivel1,
      camino = nivel1.caminoDemoledor()
    )
    game.addVisual(villanoActual)
    objetosNivel.add(villanoActual)

    game.onTick(600, "patrullaVillano", {
      if (villanoActual != null && game.hasVisual(villanoActual)) {
        villanoActual.avanzarPaso()
      }
    })
  }

  method pasarANivel2(heroe) {
    estaEnMenu = false
    estaJugando = true
    fondo.image(nivel2.imagenFondo())
    self.limpiarNivel()

    heroe.nombre("Pachita")
    heroe.position(game.at(0, 2))
    heroe.nivelActual(nivel2)
    heroe.tieneLlave(false)

    nivel2.obstaculos().forEach({ obs =>
      game.addVisual(obs)
      objetosNivel.add(obs)
    })

    posteActual = new PosteConCaja(position = game.at(14, 11))
    game.addVisual(posteActual)
    objetosNivel.add(posteActual)

    cofreActual = new Cofre(position = game.at(0, 11))
    game.addVisual(cofreActual)
    objetosNivel.add(cofreActual)

    llaveActual = new Llave(position = game.at(12, 14))

    villanoActual = new Villano(
      nombre = "envenenador",
      position = game.at(7, 3),
      nivel = nivel2,
      camino = nivel2.caminoEnvenenador()
    )
    game.addVisual(villanoActual)
    objetosNivel.add(villanoActual)
  }

  method limpiarNivel() {
    objetosNivel.forEach({ obj =>
      if (game.hasVisual(obj)) game.removeVisual(obj)
    })
    objetosNivel.clear()

    if (llaveActual != null && game.hasVisual(llaveActual)) {
      game.removeVisual(llaveActual)
    }
    try {
      game.removeTickEvent("patrullaVillano")
    } catch e : Exception {}
  }

  method ganarJuego(heroe) {
    estaJugando = false
    estaEnMenu = true
    self.limpiarNivel()
    fondo.image("menuInicio.png")
  }
}