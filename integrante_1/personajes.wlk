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


object heroe {
  var property position = game.at(0, 2)
  var property direccion = sur

  method image() = "Tupac" + direccion.numero() + "A.png"

  method moverseHacia(dir) {
    direccion = dir
    const nuevaPos = dir.siguiente(position)
    if (self.esPosicionValida(nuevaPos)) {
      position = nuevaPos
    }
  }

  method esPosicionValida(pos) =
    pos.x().between(0, game.width() - 1) &&
    pos.y().between(0, game.height() - 1)
}
