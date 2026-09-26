import wollok.game.*

object configuracionMotor {
  var anchoPantalla = 80
  var altoPantalla = 50
  var tamanioCelda = 10
  var tasaRefrescoMs = 30

  method anchoPantalla() = anchoPantalla
  method altoPantalla() = altoPantalla
  method tamanioCelda() = tamanioCelda
  method tasaRefrescoMs() = tasaRefrescoMs

  method configurar(nuevoAncho, nuevoAlto, nuevoTamanioCelda, nuevaTasaMs) {
    anchoPantalla = nuevoAncho
    altoPantalla = nuevoAlto
    tamanioCelda = nuevoTamanioCelda
    tasaRefrescoMs = nuevaTasaMs
  }

  method inicializarPantalla(titulo) {
    game.title(titulo)
    game.width(anchoPantalla)
    game.height(altoPantalla)
    game.cellSize(tamanioCelda)
  }
}
