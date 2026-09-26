import wollok.game.*
import motor2d.actor.*
import motor2d.config.*
import motor2d.engine.*
import personajes.*
import obstaculos.*
import villanos.*

// ============================
// NIVELES
// ============================

class Nivel {
  var property imagenHUD
  var property imagenFondo
  var property yMinimo = 1
  const property obstaculosDelNivel = []

  method obstaculos() = obstaculosDelNivel

  method hayObstaculoEn(checkX, checkY) =
    obstaculosDelNivel.any({ obs => obs.ocupaPosicion(checkX, checkY) })

  method yMaximoPara(x)

  method puntosPorDerrotar(villano)

  method esNivel1() = false
  method esNivel2() = false
}

object nivel1 inherits Nivel(
  imagenHUD = "nivel1.png",
  imagenFondo = "fondo1.png",
  yMinimo = 2,
  obstaculosDelNivel = [
    new Obstaculo(x = 15, y = 10, image = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(x = 45, y = 35, image = "Camion2.png", anchoCeldas = 3, altoCeldas = 3)
  ]
) {
  override method esNivel1() = true

  method caminoDemoledor() = [este, este, este, este, norte, norte, norte, norte, oeste, oeste, oeste, oeste, sur, sur, sur, sur]

  override method yMaximoPara(x) {
    if (x <= 0 or x >= 14) return 11
    if (x.between(1, 2))  return 9
    if (x.between(3, 6))  return 11
    if (x == 7)           return 9
    if (x.between(8, 11)) return 11
    if (x.between(12, 13)) return 9
    return 9
  }

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "demoledor") return 10
    return 5
  }
}

object nivel2 inherits Nivel(
  imagenHUD = "nivel2.png",
  imagenFondo = "fondo2.png",
  obstaculosDelNivel = [
    new Obstaculo(x = 10, y = 20, image = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(x = 35, y = 40, image = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(x = 60, y = 30, image = "Camion1.png", anchoCeldas = 3, altoCeldas = 3)
  ]
) {
  override method esNivel2() = true

  method caminoEnvenenador() = [
    este, este, este, este,
    norte, norte,
    oeste, oeste, oeste, oeste,
    sur, sur
  ]

  override method yMaximoPara(x) {
    if (x.between(1, 2) or x.between(12, 13)) return 9
    return 11
  }

  override method puntosPorDerrotar(villano) {
    if (villano.nombre() == "demoledor") return 15
    return 10
  }
}

// ============================
// ELEMENTOS DEL JUEGO
// ============================

class Cofre inherits Actor(width = 5, height = 5) {
  var property estaAbierto = false

  override method esObstaculo() = true

  override method image() {
    if (estaAbierto) return "cofre.png"
    else return "cofreC.png"
  }

  method abrir() {
    estaAbierto = true
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

class Llave inherits Actor(width = 5, height = 5, image = "llave.png") {
  override method esObstaculo() = false
  method recibirImpacto(papa) {
    self.image()
  }
}

class PosteConCaja inherits Actor(width = 5, height = 5, image = "poste.png") {
  override method esObstaculo() = true
  method recibirImpacto(papa) {
    self.image()
  }
}

// ============================
// INDICADORES (HUD)
// ============================

class CorazonHUD {
  var property position
  var property indice
  var property personaje

  method image() {
    if (personaje.vidas() >= indice) {
      return "corazon.png"
    } else {
      return "vacio.png"
    }
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

class BarraEnergiaHUD {
  var property position
  var property personaje

  method image() {
    const eng = personaje.energia()
    if (eng > 80) return "energia100.png"
    if (eng > 60) return "energia80.png"
    if (eng > 40) return "energia60.png"
    if (eng > 20) return "energia40.png"
    if (eng > 0)  return "energia20.png"
    return "energia0.png"
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

class NivelHUD {
  var property position
  var property personaje

  method image() = personaje.nivelActual().imagenHUD()

  method recibirImpacto(papa) {
    self.image()
  }
}

class DigitoPuntajeHUD {
  var property position
  var property indice
  var property personaje

  method image() {
    const digito = self.obtenerDigito()
    return "n" + digito + ".png"
  }

  method obtenerDigito() {
    const pts = personaje.puntos()
    const divisor = if (indice == 0) 100
                    else if (indice == 1) 10
                    else 1
    return ((pts / divisor).truncate(0) % 10).toString()
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

// ============================
// PROYECTILES DINAMICOS MOTOR2D
// ============================

class Papa inherits Actor {
  var property direccion = norte
  var property nivel = nivel1
  var property id = 0
  var property personaje = null
  const velocidad = 2

  override method width() = 2
  override method height() = 2
  override method esDinamico() = true
  override method esObstaculo() = false

  override method image() = "papa" + direccion.numero() + ".png"

  override method actualizar() {
    x += direccion.dx() * velocidad
    y += direccion.dy() * velocidad
    self.sincronizarPosicionVisual()
    
    if (self.fueraDelTablero()) {
      self.destruir()
    }
  }

  method fueraDelTablero() =
    x < 0 || x > 73 || y < 0 || y > 73 || direccion.excedeLimite(x, y)

  override method destruir() {
    super()
    if (personaje != null) {
      personaje.removerPapaActiva(self)
    }
  }

  override method colisionoCon(otro) {
    otro.recibirImpacto(self)
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

// ============================
// FONDO Y GESTOR DE NIVELES
// ============================

object fondo inherits Actor(x = 0, y = 0, width = 75, height = 75, image = "menuInicio.png", position = game.at(0, 0)) {
  override method esDinamico() = false
  override method esObstaculo() = false
  method recibirImpacto(papa) {
    self.image()
  }
}

object gestorDeNiveles {
  var property cofreActual = null
  var property posteActual = null
  var property villanoActual = null
  var property llaveActual = null
  const objetosNivel = []
  var tickMovimientoActivo = false

  var property estaEnMenu = true
  var property estaJugando = false

  method configurarNivel1(heroe) {
    estaEnMenu = false
    estaJugando = true
    fondo.image(nivel1.imagenFondo())
    self.limpiarNivel()
    
    heroe.nivelActual(nivel1)
    heroe.nombre("Tupac")
    heroe.moverA(0, 10)
    heroe.tieneLlave(false)

    if (!game.hasVisual(heroe)) engine.spawn(heroe)

    nivel1.obstaculos().forEach({ obs => 
      engine.spawn(obs)
      objetosNivel.add(obs)
    })

    posteActual = new PosteConCaja(x = 70, y = 55)
    engine.spawn(posteActual)
    objetosNivel.add(posteActual)
    
    cofreActual = new Cofre(x = 0, y = 55)
    engine.spawn(cofreActual)
    objetosNivel.add(cofreActual)

    llaveActual = new Llave(x = 60, y = 70)
    
    villanoActual = new Villano(
      x = 35,
      y = 15,
      nombre = "demoledor",
      direccion = este,
      nivel = nivel1,
      camino = nivel1.caminoDemoledor(),
      mensajesAtaque = ["TOMA ESTO!", "JAJAJAJA!", "TE VA A DOLER!", "FUERA DE ACA!", "SUFRE!", "SIENTE MI PODER!", "AAAAAAH!"]
    )
    engine.spawn(villanoActual)
    objetosNivel.add(villanoActual)

    self.iniciarMovimientoVillano(heroe)
  }

  method pasarANivel2(heroe) {
    estaEnMenu = false
    estaJugando = true
    fondo.image(nivel2.imagenFondo())
    self.limpiarNivel()
    
    heroe.nivelActual(nivel2)
    heroe.nombre("Pachita")
    heroe.moverA(0, 10)
    heroe.tieneLlave(false)

    if (!game.hasVisual(heroe)) engine.spawn(heroe)
    
    nivel2.obstaculos().forEach({ obs => 
      engine.spawn(obs)
      objetosNivel.add(obs)
    })

    posteActual = new PosteConCaja(x = 70, y = 55)
    engine.spawn(posteActual)
    objetosNivel.add(posteActual)
    
    cofreActual = new Cofre(x = 0, y = 55)
    engine.spawn(cofreActual)
    objetosNivel.add(cofreActual)

    llaveActual = new Llave(x = 60, y = 70)

    villanoActual = new Villano(
      x = 35,
      y = 15,
      nombre = "envenenador",
      direccion = este,
      nivel = nivel2,
      camino = nivel2.caminoEnvenenador(),
      mensajesAtaque = ["TOMA ESTO!", "VENENO PURO!", "NO PASARAS!"]
    )
    engine.spawn(villanoActual)
    objetosNivel.add(villanoActual)

    self.iniciarMovimientoVillano(heroe)
  }

  method limpiarNivel() {
    objetosNivel.forEach({ obj => 
      engine.despawn(obj)
    })
    objetosNivel.clear()
    if (llaveActual != null && game.hasVisual(llaveActual)) {
      engine.despawn(llaveActual)
    }
    self.detenerMovimientoVillano()
  }

  method iniciarMovimientoVillano(heroe) {
    if (!tickMovimientoActivo) {
      game.onTick(200, "movimientoVillano", {
        if (game.hasVisual(villanoActual)) {
          villanoActual.iniciarPaso(heroe)
          if (villanoActual.estaAdjacenteA(heroe)) {
            villanoActual.atacar(heroe)
          }
        }
      })
      tickMovimientoActivo = true
    }
  }

  method detenerMovimientoVillano() {
    if (tickMovimientoActivo) {
      game.removeTickEvent("movimientoVillano")
      tickMovimientoActivo = false
    }
  }

  method obtenerObjetosQueCaen(heroe) {
    const objetos = []
    heroe.nivelActual().obstaculos().forEach({ obs => objetos.add(obs) })
    if (!villanoActual.estaTransformado()) {
      objetos.add(villanoActual)
    }
    return objetos
  }

  method ganarJuego(heroe) {
    estaJugando = false
    estaEnMenu = true
    self.limpiarNivel()
    if (game.hasVisual(heroe)) engine.despawn(heroe)
    fondo.image("menuInicio.png")
  }
}
