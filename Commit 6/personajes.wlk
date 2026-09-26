import wollok.game.*
import motor2d.actor.*

// ============================
// DIRECCIONES POLIMÓRFICAS
// ============================

object norte {
  method siguiente(position) = position.up(5)
  method numero() = 2
  method dx() = 0
  method dy() = 1
  method excedeLimite(x, y) = y > 60
  method veAl(vxTile, vyTile, hxTile, hyTile, villano) =
    hxTile == vxTile and hyTile > vyTile and not villano.hayObstaculoEntreY(vxTile, vyTile, hyTile)
}

object sur {
  method siguiente(position) = position.down(5)
  method numero() = 1
  method dx() = 0
  method dy() = -1
  method excedeLimite(x, y) = y < 10
  method veAl(vxTile, vyTile, hxTile, hyTile, villano) =
    hxTile == vxTile and hyTile < vyTile and not villano.hayObstaculoEntreY(vxTile, hyTile, vyTile)
}

object este {
  method siguiente(position) = position.right(5)
  method numero() = 3
  method dx() = 1
  method dy() = 0
  method excedeLimite(x, y) = x > 70
  method veAl(vxTile, vyTile, hxTile, hyTile, villano) =
    hyTile == vyTile and hxTile > vxTile and not villano.hayObstaculoEntreX(vxTile, hxTile, vyTile)
}

object oeste {
  method siguiente(position) = position.left(5)
  method numero() = 4
  method dx() = -1
  method dy() = 0
  method excedeLimite(x, y) = x < 0
  method veAl(vxTile, vyTile, hxTile, hyTile, villano) =
    hyTile == vyTile and hxTile < vxTile and not villano.hayObstaculoEntreX(hxTile, vxTile, vyTile)
}

// ============================
// PERSONAJES (Clase Base)
// ============================

class Personaje inherits Actor {
  var property direccion = sur
  var usandoFrameA = true
  var property nombre = ""

  override method width() = 5
  override method height() = 5

  override method image() {
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

  method recibirImpacto(papa) {
    self.image()
  }
}
