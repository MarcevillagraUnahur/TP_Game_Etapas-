import wollok.game.*

// ==========================================================
// CINEMATICA: MOTOR AUTÓNOMO DE CINEMÁTICAS Y VIDEO EN WOLLOK
// ==========================================================

class ReproductorCinematica {
  var property x = 0
  var property y = 0
  var property width = 1
  var property height = 1
  var property image = ""
  var property position = game.at(0, 0)
  
  var property prefijoFrames = ""
  var property totalFrames = 0
  var property intervaloMs = 125 // 8 FPS por defecto
  var property rutaAudio = null
  var property idTick = "tickCinematica"
  
  var property frameActual = 0
  var property accionAlTerminar = null
  var property activa = false
  var property sonido = null

  method estaActiva() = activa

  method reproducir(alTerminar) {
    activa = true
    frameActual = 0
    accionAlTerminar = alTerminar
    image = prefijoFrames + "0.png"
    position = game.at(x, y)
    
    if (game.hasVisual(self)) {
      game.removeVisual(self)
    }
    game.addVisual(self)

    if (rutaAudio != null) {
      try {
        sonido = game.sound(rutaAudio)
        sonido.play()
      } catch e : Exception {
        sonido = null
      }
    }

    game.onTick(intervaloMs, idTick, { self.siguienteFrame() })
  }

  method siguienteFrame() {
    frameActual += 1
    if (frameActual >= totalFrames) {
      self.finalizar()
    } else {
      image = prefijoFrames + frameActual.toString() + ".png"
      position = game.at(x, y)
    }
  }

  method finalizar() {
    if (activa) {
      activa = false
      game.removeTickEvent(idTick)
      
      if (sonido != null) {
        try {
          sonido.stop()
        } catch e : Exception {
          sonido = null
        }
      }
      
      if (game.hasVisual(self)) {
        game.removeVisual(self)
      }
      if (accionAlTerminar != null) {
        accionAlTerminar.apply()
      }
    }
  }

  method saltar() {
    if (activa) {
      self.finalizar()
    }
  }

  method recibirImpacto(papa) {
    self.image()
  }
}

// Instancia para la cinemática de Pase de Nivel 1
object reproductorCinematica inherits ReproductorCinematica(
  x = 0,
  y = 0,
  width = 75,
  height = 75,
  prefijoFrames = "cinematicas/pase_de_nivel_1_",
  totalFrames = 80,
  intervaloMs = 125,
  rutaAudio = "cinematicas/pase_de_nivel_1_audio.mp3",
  idTick = "tickCinematicaPase1",
  image = "cinematicas/pase_de_nivel_1_0.png"
) {}

// Instancia para la cinemática de Pase de Nivel 2 / Victoria
object reproductorCinematicaNivel2 inherits ReproductorCinematica(
  x = 0,
  y = 0,
  width = 75,
  height = 75,
  prefijoFrames = "cinematicas/pase_de_nivel_2_",
  totalFrames = 80,
  intervaloMs = 125,
  rutaAudio = "cinematicas/pase_de_nivel_2_audio.mp3",
  idTick = "tickCinematicaPase2",
  image = "cinematicas/pase_de_nivel_2_0.png"
) {}
