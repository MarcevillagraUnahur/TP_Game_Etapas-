import wollok.game.*

object norte {
  method siguiente(position) = position.up(1)
  method numero() = 2
  method dx() = 0
  method dy() = 1
  method veAl(vx, vy, hx, hy, villano) =
    hx == vx and hy > vy and not villano.hayObstaculoEntreY(vx, vy, hy)
  method excedeLimite(pos) = pos.y() > 12
}

object sur {
  method siguiente(position) = position.down(1)
  method numero() = 1
  method dx() = 0
  method dy() = -1
  method veAl(vx, vy, hx, hy, villano) =
    hx == vx and hy < vy and not villano.hayObstaculoEntreY(vx, hy, vy)
  method excedeLimite(pos) = false
}

object este {
  method siguiente(position) = position.right(1)
  method numero() = 3
  method dx() = 1
  method dy() = 0
  method veAl(vx, vy, hx, hy, villano) =
    hy == vy and hx > vx and not villano.hayObstaculoEntreX(vx, hx, vy)
  method excedeLimite(pos) = false
}

object oeste {
  method siguiente(position) = position.left(1)
  method numero() = 4
  method dx() = -1
  method dy() = 0
  method veAl(vx, vy, hx, hy, villano) =
    hy == vy and hx < vx and not villano.hayObstaculoEntreX(hx, vx, vy)
  method excedeLimite(pos) = false
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
