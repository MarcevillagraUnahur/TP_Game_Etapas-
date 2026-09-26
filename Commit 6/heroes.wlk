import wollok.game.*
import motor2d.actor.*
import motor2d.config.*
import motor2d.engine.*
import personajes.*
import elementosDelJuego.*

class Heroe inherits Personaje(nombre = "Tupac", x = 0, y = 10) {
  var energia = 100
  var vidas = 3
  var puntos = 0
  var nivelActual = nivel1
  var property tieneLlave = false
  var papasLanzadas = 0
  var property cantPapasMax = 1
  const property papasActivas = []

  // Smooth Pulse Buffer a 40 FPS
  var vx = 0
  var vy = 0
  var ticksMovimiento = 0
  const velocidad = 1
  const duracionImpulso = 5

  override method esDinamico() = true
  override method esObstaculo() = true

  method nivelActual() = nivelActual

  method nivelActual(nuevoNivel) {
    nivelActual = nuevoNivel
    fondo.image(nuevoNivel.imagenFondo())
  }
  
  method energia() = energia
  method vidas() = vidas
  method puntos() = puntos
  
  method ganarPuntos(cant) {
    puntos += cant
  }
  
  method perderVida() {
    vidas -= 1
    energia = 100
  }
  
  method recibirDano(cantidad) {
    energia = (energia - cantidad).max(0)
    if (energia == 0) self.perderVida()
  }

  method recibirDaño(cantidad) {
    self.recibirDano(cantidad)
  }
  
  // --- Controles con interpolación suave a 40 FPS ---
  method moverArriba() {
    vy = velocidad
    vx = 0
    ticksMovimiento = duracionImpulso
    self.actualizarAnimacion(norte)
  }

  method moverAbajo() {
    vy = -velocidad
    vx = 0
    ticksMovimiento = duracionImpulso
    self.actualizarAnimacion(sur)
  }

  method moverIzquierda() {
    vx = -velocidad
    vy = 0
    ticksMovimiento = duracionImpulso
    self.actualizarAnimacion(oeste)
  }

  method moverDerecha() {
    vx = velocidad
    vy = 0
    ticksMovimiento = duracionImpulso
    self.actualizarAnimacion(este)
  }

  override method actualizar() {
    if (ticksMovimiento > 0) {
      const nuevoX = x + vx
      const nuevoY = y + vy
      if (self.esPosicionValida(nuevoX, nuevoY)) {
        x = nuevoX
        y = nuevoY
        self.sincronizarPosicionVisual()
      } else {
        ticksMovimiento = 0
      }
      ticksMovimiento -= 1
    }
  }
  
  method esPosicionValida(checkX, checkY) =
    checkX.between(0, 70) &&
    checkY.between(nivelActual.yMinimo() * 5, nivelActual.yMaximoPara(checkX / 5) * 5) &&
    (!nivelActual.hayObstaculoEn(checkX, checkY))
  
  method lanzarPapa() {
    if (papasActivas.size() < cantPapasMax) {
      papasLanzadas += 1
      const papa = new Papa(
        x = x + 1.5,
        y = y + 1.5,
        direccion = direccion,
        nivel = nivelActual,
        id = papasLanzadas,
        personaje = self
      )
      papasActivas.add(papa)
      engine.spawn(papa)
    }
  }

  method removerPapaActiva(papa) {
    papasActivas.remove(papa)
  }
}
