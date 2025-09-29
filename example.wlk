import wollok.game.*

class Personaje {
  var nombre = ""
  var nivel = 1
  var exp = 0
  var monedas = 0

  var vida = 100
  var mana = 50
  var ataque = 10
  var defensa = 5
  var magia = 0
  //var velocidad = 5 hay que definir si queremos implementar la velocidad

  var puntosDisponibles = 0 // puntos de stats a acomodar
  var habilidades = []

  var position = game.center()

  method image() = "player.jpg"

  // el pj deberia ganar experiencia y subir de lvl en algun punto (a definir a futuro)
  method ganarExp(cantidad) {
  }

  method subirNivel() {
  }

  method recibirDaño(cantidad) {
  }

  //quedaria definir metodos de ataque, uso de menu, etc
  // tambien faltaria a futuro meter metodos para acomodar los stats que se te asignan al subir de nivel

}

class Habilidad {
  var nombre = ""
  var costoMana = 0
  var costoEnergia = 0
  var daño = 0

  method usarEn(objetivo) {
    objetivo.recibirDaño(daño)
  }
}

class Enemigo {
  var nombre = ""
  var vida = 50
  var ataque = 5
  var expOtorgada = 50
  var monedasOtorgadas = 20
  var position = game.center()

  method image() = "enemigo.jpg"


  method recibirDaño(cantidad) {
    }
}


class Portal {
  var position = game.center()
  var destino = null
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
  const heroe = new Personaje(nombre = "Jugador")
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
