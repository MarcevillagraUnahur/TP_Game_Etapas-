import wollok.game.*

object norte {
  method siguiente(position) = position.up(1)
  method numero() = 2
}

object sur {
  method siguiente(position) = position.down(1)
  method numero() = 1
}

object este {
  method siguiente(position) = position.right(1)
  method numero() = 3
}

object oeste {
  method siguiente(position) = position.left(1)
  method numero() = 4
}

class Personaje {
  var property position = game.at(0, 0)
  var property direccion = sur
  var usandoFrameA = true
  var property nombre = ""

  method image() {
    const frame = if (usandoFrameA) "A" else "B"
    return nombre + direccion.numero() + frame + ".png"
  }

  method actualizarAnimacion(nuevaDireccion) {
    if (direccion == nuevaDireccion) {
      usandoFrameA = !usandoFrameA
    } else {
      direccion = nuevaDireccion
      usandoFrameA = true
    }
  }

  method recibirImpacto(papa) {}
}
