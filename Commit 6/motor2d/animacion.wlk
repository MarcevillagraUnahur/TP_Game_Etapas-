class Animacion {
  const frames = []
  var ticksPorFrame = 4
  var tickActual = 0
  var indiceFrame = 0
  var repetitiva = true
  var terminada = false

  method frameActual() = frames.get(indiceFrame)
  method terminada() = terminada
  method frames() = frames

  method ticksPorFrame(nuevoValor) {
    ticksPorFrame = nuevoValor
  }

  method repetitiva(nuevoValor) {
    repetitiva = nuevoValor
  }

  method agregarFrame(nombreArchivo) {
    frames.add(nombreArchivo)
  }

  method avanzar() {
    if (not terminada and not frames.isEmpty()) {
      tickActual += 1
      if (tickActual >= ticksPorFrame) {
        tickActual = 0
        self.proximoFrame()
      }
    }
  }

  method proximoFrame() {
    if (indiceFrame + 1 < frames.size()) {
      indiceFrame += 1
    } else {
      if (repetitiva) {
        indiceFrame = 0
      } else {
        terminada = true
      }
    }
  }

  method reiniciar() {
    tickActual = 0
    indiceFrame = 0
    terminada = false
  }
}
