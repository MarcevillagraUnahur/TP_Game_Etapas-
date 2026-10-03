import wollok.game.*
import personajes.*
import elementosDelJuego.*

class Villano inherits Personaje {
  var pasoActual = 0
  var property camino = []
  var persiguiendo = false
  var property nivel = nivel1
  var estaAtacando = false
  var indiceAtaque = 0
  var property mensajesAtaque = ["TOMA ESTO!"]
  var property estaTransformado = false
  var property animal = null

  override method image() {
    if (estaTransformado) {
      return animal + direccion.numero() + ".png"
    }
    const frame = if (estaAtacando) "A"
                  else if (usandoFrameA) "A"
                  else "B"
    return nombre + direccion.numero() + frame + ".png"
  }

  method veAl(heroe) {
    if (nivel == null) return false
    return direccion.veAl(position.x(), position.y(), heroe.position().x(), heroe.position().y(), self)
  }

  method hayObstaculoEntreX(xMin, xMax, y) {
    if (xMax - xMin <= 1) return false
    return (xMin + 1 .. xMax - 1).any({ x => nivel.hayObstaculoEn(game.at(x, y)) })
  }

  method hayObstaculoEntreY(x, yMin, yMax) {
    if (yMax - yMin <= 1) return false
    return (yMin + 1 .. yMax - 1).any({ y => nivel.hayObstaculoEn(game.at(x, y)) })
  }

  method dirHaciaHeroe(heroe) {
    const dx = heroe.position().x() - position.x()
    const dy = heroe.position().y() - position.y()
    if (dx.abs() >= dy.abs()) {
      if (dx >= 0) return este
      else return oeste
    } else {
      if (dy > 0) return norte
      else return sur
    }
  }

  method moverse(heroe) {
    if (estaTransformado) {
      if (!camino.isEmpty()) {
        const dir = camino.get(pasoActual)
        self.moverseHacia(dir)
        pasoActual = (pasoActual + 1) % camino.size()
      }
    } else if (!estaAtacando) {
      if (!persiguiendo) {
        persiguiendo = self.veAl(heroe)
      }
      if (persiguiendo) {
        const dir = self.dirHaciaHeroe(heroe)
        self.moverseHacia(dir)
      } else if (!camino.isEmpty()) {
        const dir = camino.get(pasoActual)
        self.moverseHacia(dir)
        pasoActual = (pasoActual + 1) % camino.size()
      }
    }
  }

  method moverseHacia(nuevaDireccion) {
    const nuevaPos = nuevaDireccion.siguiente(position)
    const puedeAvanzar = (nivel == null) || (!nivel.hayObstaculoEn(nuevaPos))
    if (puedeAvanzar && nuevaPos.x().between(0, game.width() - 1) && nuevaPos.y().between(0, game.height() - 1)) {
      self.actualizarAnimacion(nuevaDireccion)
      position = nuevaPos
    }
  }

  method estaAdjacenteA(heroe) {
    const dx = (position.x() - heroe.position().x()).abs()
    const dy = (position.y() - heroe.position().y()).abs()
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
  }

  method atacar(heroe) {
    if (!estaTransformado && !estaAtacando) {
      heroe.recibirDano(10)
      estaAtacando = true
      if (!mensajesAtaque.isEmpty()) {
        game.say(self, mensajesAtaque.get(indiceAtaque))
        indiceAtaque = (indiceAtaque + 1) % mensajesAtaque.size()
      }
      game.onTick(1000, "finAtaque" + nombre, {
        estaAtacando = false
        game.say(self, "")
        game.removeTickEvent("finAtaque" + nombre)
      })
    }
  }

  method puntosOtorgados() = if (nivel != null) nivel.puntosPorDerrotar(self) else 10

  override method recibirImpacto(papa) {
    if (!estaTransformado) {
      estaTransformado = true
      animal = ["condor", "lagarto", "llama", "mula"].anyOne()
      papa.personaje().ganarPuntos(self.puntosOtorgados())
      if (estaAtacando) {
        estaAtacando = false
        game.say(self, "")
        game.removeTickEvent("finAtaque" + nombre)
      }
    }
    papa.destruir()
  }
}
