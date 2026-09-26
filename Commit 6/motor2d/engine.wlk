import wollok.game.*
import config.*

object engine {
  const actoresDinamicos = []
  const obstaculos = []
  var enEjecucion = false

  method actoresDinamicos() = actoresDinamicos
  method obstaculos() = obstaculos
  method enEjecucion() = enEjecucion

  method spawn(unActor) {
    unActor.sincronizarPosicionVisual()
    if (unActor.esDinamico()) {
      actoresDinamicos.add(unActor)
    }
    if (unActor.esObstaculo()) {
      obstaculos.add(unActor)
    }
    game.addVisual(unActor)
  }

  method despawn(unActor) {
    if (unActor.esDinamico()) {
      actoresDinamicos.remove(unActor)
    }
    if (unActor.esObstaculo()) {
      obstaculos.remove(unActor)
    }
    if (game.hasVisual(unActor)) {
      game.removeVisual(unActor)
    }
  }

  method limpiar() {
    actoresDinamicos.forEach({ actor =>
      if (game.hasVisual(actor)) {
        game.removeVisual(actor)
      }
    })
    obstaculos.forEach({ actor =>
      if (game.hasVisual(actor)) {
        game.removeVisual(actor)
      }
    })
    actoresDinamicos.clear()
    obstaculos.clear()
  }

  method iniciar() {
    if (not enEjecucion) {
      enEjecucion = true
      game.onTick(configuracionMotor.tasaRefrescoMs(), "engineLoopGeneral", { self.actualizar() })
    }
  }

  method pausar() {
    if (enEjecucion) {
      enEjecucion = false
      game.removeTickEvent("engineLoopGeneral")
    }
  }

  method actualizar() {
    actoresDinamicos.forEach({ actor =>
      if (actor.activo()) {
        actor.actualizar()
        if (actor.activo()) {
          self.verificarColisionesDe(actor)
        }
      }
    })
  }

  method verificarColisionesDe(actorDinamico) {
    obstaculos.forEach({ obs =>
      if (actorDinamico.activo() and obs.activo() and actorDinamico.colisionaCon(obs)) {
        actorDinamico.colisionoCon(obs)
        obs.colisionoCon(actorDinamico)
      }
    })
  }
}
