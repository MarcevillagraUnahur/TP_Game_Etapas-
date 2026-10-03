import wollok.game.*
import personajes.*
import obstaculos.*
import villanos.*

class Nivel {
  var property imagenHUD
  var property imagenFondo
  var property yMinimo = 1
  const property obstaculosDelNivel = []

  method obstaculos() = obstaculosDelNivel

  method hayObstaculoEn(pos) =
    obstaculosDelNivel.any({ obs => obs.ocupaCelda(pos) })

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
    new Obstaculo(position = game.at(3, 2), imagen = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(position = game.at(9, 7), imagen = "Camion2.png", anchoCeldas = 3, altoCeldas = 3)
  ]
) {
  override method esNivel1() = true

  method caminoDemoledor() = [
    este, este, este, este,
    norte, norte, norte, norte,
    oeste, oeste, oeste, oeste,
    sur, sur, sur, sur
  ]

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
  yMinimo = 2,
  obstaculosDelNivel = [
    new Obstaculo(position = game.at(2, 4), imagen = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(position = game.at(7, 8), imagen = "Camion1.png", anchoCeldas = 3, altoCeldas = 3),
    new Obstaculo(position = game.at(12, 6), imagen = "Camion1.png", anchoCeldas = 3, altoCeldas = 3)
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

class Cofre {
  var property position = game.at(0, 11)
  var property estaAbierto = false

  method image() {
    if (estaAbierto) return "cofre.png"
    else return "cofreC.png"
  }

  method abrir() {
    estaAbierto = true
  }

  method recibirImpacto(papa) {}
}

class Llave {
  var property position = game.at(12, 14)
  method image() = "llave.png"
  method recibirImpacto(papa) {}
}

class PosteConCaja {
  var property position = game.at(14, 11)
  method image() = "poste.png"
  method recibirImpacto(papa) {}
}

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

  method recibirImpacto(papa) {}
}

class NivelHUD {
  var property position
  var property personaje

  method image() = personaje.nivelActual().imagenHUD()

  method recibirImpacto(papa) {}
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

  method recibirImpacto(papa) {}
}

class Papa {
  var property position
  var property direccion
  var property nivel
  var property id
  var property personaje
  var estaActiva = true

  method image() = "papa" + direccion.numero() + ".png"

  method lanzar() {
    game.addVisual(self)
    game.onTick(150, "movPapa" + id, {
      self.avanzar()
    })
  }

  method avanzar() {
    const nuevaPos = direccion.siguiente(position)
    if (self.fueraDelTablero(nuevaPos) || nivel.hayObstaculoEn(nuevaPos) || direccion.excedeLimite(nuevaPos)) {
      self.destruir()
    } else {
      position = nuevaPos
      self.verificarImpacto()
    }
  }

  method verificarImpacto() {
    game.colliders(self).forEach({ obj => obj.recibirImpacto(self) })
  }

  method fueraDelTablero(pos) =
    !pos.x().between(0, game.width() - 1) ||
    !pos.y().between(0, game.height() - 1)

  method destruir() {
    if (estaActiva) {
      estaActiva = false
      game.removeTickEvent("movPapa" + id)
      if (game.hasVisual(self)) game.removeVisual(self)
      if (personaje != null) {
        personaje.removerPapaActiva(self)
      }
    }
  }

  method recibirImpacto(papa) {}
}

object gestorDeNiveles {
  var property cofreActual = null
  var property posteActual = null
  var property villanoActual = null
  var property llaveActual = null
  const objetosNivel = []
  var tickMovimientoActivo = false

  method configurarNivel1(heroe) {
    self.limpiarNivel()
    
    heroe.nivelActual(nivel1)
    heroe.nombre("Tupac")
    heroe.position(game.at(0, 2))
    heroe.tieneLlave(false)

    if (!game.hasVisual(heroe)) game.addVisual(heroe)

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
      position = game.at(7, 3),
      nombre = "demoledor",
      direccion = este,
      nivel = nivel1,
      camino = nivel1.caminoDemoledor(),
      mensajesAtaque = ["TOMA ESTO!", "JAJAJAJA!", "TE VA A DOLER!", "FUERA DE ACA!", "SUFRE!", "SIENTE MI PODER!", "AAAAAAH!"]
    )
    game.addVisual(villanoActual)
    objetosNivel.add(villanoActual)

    self.iniciarMovimientoVillano(heroe)
  }

  method pasarANivel2(heroe) {
    self.limpiarNivel()
    
    heroe.nivelActual(nivel2)
    heroe.nombre("Pachita")
    heroe.position(game.at(0, 2))
    heroe.tieneLlave(false)

    if (!game.hasVisual(heroe)) game.addVisual(heroe)
    
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
      position = game.at(7, 3),
      nombre = "envenenador",
      direccion = este,
      nivel = nivel2,
      camino = nivel2.caminoEnvenenador(),
      mensajesAtaque = ["TOMA ESTO!", "VENENO PURO!", "NO PASARAS!"]
    )
    game.addVisual(villanoActual)
    objetosNivel.add(villanoActual)

    self.iniciarMovimientoVillano(heroe)
  }

  method limpiarNivel() {
    objetosNivel.forEach({ obj => 
      if (game.hasVisual(obj)) game.removeVisual(obj) 
    })
    objetosNivel.clear()
    if (llaveActual != null && game.hasVisual(llaveActual)) {
      game.removeVisual(llaveActual)
    }
    self.detenerMovimientoVillano()
  }

  method iniciarMovimientoVillano(heroe) {
    if (!tickMovimientoActivo) {
      game.onTick(400, "movimientoVillano", {
        if (game.hasVisual(villanoActual)) {
          villanoActual.moverse(heroe)
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
    self.limpiarNivel()
    game.say(heroe, "VICTORIA! Defendimos el Glaciar!")
  }

  method perderJuego(heroe) {
    self.detenerMovimientoVillano()
    game.say(heroe, "GAME OVER!")
  }
}
