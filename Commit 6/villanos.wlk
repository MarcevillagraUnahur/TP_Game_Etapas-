import wollok.game.*
import motor2d.actor.*
import motor2d.engine.*
import personajes.*

class Villano inherits Personaje {
  var pasoActual = 0
  var property camino = []
  var persiguiendo = false
  var property nivel = null
  var estaAtacando = false
  var indiceAtaque = 0
  var property mensajesAtaque = ["TOMA ESTO!"]
  var property estaTransformado = false
  var property animal = null

  // Smooth Movement a 40 FPS
  var vx = 0
  var vy = 0
  var ticksMovimiento = 0
  const velocidad = 1
  const duracionImpulso = 5

  override method esDinamico() = true
  override method esObstaculo() = true

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
    const vxTile = (x / 5).truncate(0)
    const vyTile = (y / 5).truncate(0)
    const hxTile = (heroe.x() / 5).truncate(0)
    const hyTile = (heroe.y() / 5).truncate(0)
    return direccion.veAl(vxTile, vyTile, hxTile, hyTile, self)
  }

  method hayObstaculoEntreX(xMin, xMax, checkY) {
    if (xMax - xMin <= 1) return false
    return (xMin + 1 .. xMax - 1).any({ checkX => nivel.hayObstaculoEn(checkX * 5, checkY * 5) })
  }

  method hayObstaculoEntreY(checkX, yMin, yMax) {
    if (yMax - yMin <= 1) return false
    return (yMin + 1 .. yMax - 1).any({ checkY => nivel.hayObstaculoEn(checkX * 5, checkY * 5) })
  }

  method dirHaciaHeroe(heroe) {
    const dx = heroe.x() - x
    const dy = heroe.y() - y
    if (dx.abs() >= dy.abs()) {
      if (dx >= 0) return este
      else return oeste
    } else {
      if (dy > 0) return norte
      else return sur
    }
  }

  method iniciarPaso(heroe) {
    if (ticksMovimiento <= 0) {
      if (estaTransformado) {
        if (!camino.isEmpty()) {
          const dir = camino.get(pasoActual)
          self.iniciarAvance(dir)
          pasoActual = (pasoActual + 1) % camino.size()
        }
      } else if (!estaAtacando) {
        if (!persiguiendo) {
          persiguiendo = self.veAl(heroe)
        }
        if (persiguiendo) {
          const dir = self.dirHaciaHeroe(heroe)
          self.iniciarAvance(dir)
        } else if (!camino.isEmpty()) {
          const dir = camino.get(pasoActual)
          self.iniciarAvance(dir)
          pasoActual = (pasoActual + 1) % camino.size()
        }
      }
    }
  }

  method iniciarAvance(nuevaDireccion) {
    self.actualizarAnimacion(nuevaDireccion)
    vx = nuevaDireccion.dx() * velocidad
    vy = nuevaDireccion.dy() * velocidad
    ticksMovimiento = duracionImpulso
  }

  override method actualizar() {
    if (ticksMovimiento > 0) {
      const nuevoX = x + vx
      const nuevoY = y + vy
      const puedeAvanzar = (nivel == null) || (!nivel.hayObstaculoEn(nuevoX, nuevoY))
      if (puedeAvanzar && nuevoX.between(0, 70) && nuevoY.between(0, 70)) {
        x = nuevoX
        y = nuevoY
        self.sincronizarPosicionVisual()
      } else {
        ticksMovimiento = 0
      }
      ticksMovimiento -= 1
    }
  }

  method estaAdjacenteA(heroe) {
    const dx = (x - heroe.x()).abs()
    const dy = (y - heroe.y()).abs()
    return (dx <= 6 && dy <= 2) || (dx <= 2 && dy <= 6)
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

  override method colisionoCon(otro) {
    otro.recibirImpacto(self)
  }
}
