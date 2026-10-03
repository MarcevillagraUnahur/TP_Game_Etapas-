import wollok.game.*
import personajes.*

class Papa {
  var property position
  var property direccion
  var property id
  var property personaje
  const property obstaculos = []
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
    if (self.fueraDelTablero(nuevaPos) || self.hayObstaculoEn(nuevaPos)) {
      self.destruir()
    } else {
      position = nuevaPos
      self.verificarImpacto()
    }
  }

  method hayObstaculoEn(pos) =
    obstaculos.any({ obs => obs.ocupaCelda(pos) })

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
