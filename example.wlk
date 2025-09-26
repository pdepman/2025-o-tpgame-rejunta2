import wollok.game.*

class Heroe {
  var property position = game.center()
  var property nombre = ""
  method image() = "player.jpg"
}

const guerrero = new Heroe(nombre = "Guerrero")
const mago     = new Heroe(nombre = "Mago")
const arquero  = new Heroe(nombre = "Arquero")


class Portal {
  var property position = game.center()
  var property destino = null
  method image() = "portal.jpg"
  method fueTocadoPor(jugador) { mundo.cambiarArea(destino) }
}


object area1 {
  var visuals = []
  method cargar() {
    game.title("Area 1")
    const p = new Portal(position = game.at(11,3), destino = area2)
    visuals = [p]; game.addVisual(p)
  }
  method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
}

object area2 {
  var visuals = []
  method cargar() {
    game.title("Area 2")
    const a1 = new Portal(position = game.at(0,3),  destino = area1)
    const a3 = new Portal(position = game.at(11,3), destino = area3)
    visuals = [a1, a3]; visuals.forEach { v => game.addVisual(v) }
  }
  method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
}

object area3 {
  var visuals = []
  method cargar() {
    game.title("Area 3 (Boss)")
    const back = new Portal(position = game.at(0,3), destino = area1)
    visuals = [back]; game.addVisual(back)
  }
  method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
}

// ===== Mundo =====
object mundo {
  const heroe = guerrero
  var areaActual = area1

  method iniciar() {
  areaActual.cargar()
  heroe.position(game.center())                
  game.addVisualCharacter(heroe)
  game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
}

method cambiarArea(nueva) {
  areaActual.descargar()
  areaActual = nueva
  areaActual.cargar()
  heroe.position(game.center())               
}
}
