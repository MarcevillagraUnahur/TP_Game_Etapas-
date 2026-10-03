import wollok.game.*

class Obstaculo {
  var property position = game.at(0, 0)
  var property imagen = "Camion1.png"
  var property anchoCeldas = 3
  var property altoCeldas  = 3

  method image() = imagen

  method ocupaCelda(pos) =
    pos.x().between(position.x(), position.x() + anchoCeldas - 1) &&
    pos.y().between(position.y(), position.y() + altoCeldas  - 1)

  method recibirImpacto(papa) {
    papa.destruir()
  }
}
