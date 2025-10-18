import wollok.game.*
import objectsAndDragons.*
import stages.*

object uiCombate {
	var uiHeroe = null
	var uiEnemigo = null
	
	method dibujarPantallaDeCombate(heroe, enemigo) {
		game.clear()
		const fondo = new Decoracion(image="battle_bg.jpg", position=game.origin())
		uiHeroe = new Decoracion(image="textbox.png", position=game.at(12, 2))
		uiEnemigo = new Decoracion(image="textbox.png", position=game.at(1, 7))
		
		game.addVisual(fondo)
		game.addVisual(uiHeroe)
		game.addVisual(uiEnemigo)
		
		heroe.position(game.at(3, 3))
		enemigo.position(game.at(12, 6))
		game.addVisual(heroe)
		game.addVisual(enemigo)
		
		self.actualizarUI(heroe, enemigo)
	}
	
	method actualizarUI(heroe, enemigo) {
		game.say(uiHeroe, heroe.nombre() + " | Vida: " + heroe.vida() + "/" + heroe.vidaMaxima())
		game.say(uiEnemigo, enemigo.nombre() + " | Vida: " + enemigo.vida() + "/" + enemigo.vidaMaxima())
	}
	
	method limpiarPantalla() { 
		game.clear() 
		uiHeroe = null
		uiEnemigo = null
	}
}

object sistemaDeCombate {
	var heroe = null
  	var enemigo = null
  	var turno = null
	
	method iniciarCombate(unHeroe, unEnemigo) {
		heroe = unHeroe
    enemigo = unEnemigo
		uiCombate.dibujarPantallaDeCombate(heroe, enemigo)
		turno = if (heroe.velocidad() >= enemigo.velocidad()) heroe else enemigo
		self.siguienteTurno()
	}
	
	method siguienteTurno() {
		if (heroe.estaVivo() and enemigo.estaVivo()) {
			if (turno == heroe) { self.mostrarMenuHeroe() } else { self.turnoEnemigo() }
		}
	}
	
	method mostrarMenuHeroe() {
		game.title("Elige: 1)Ataque 2)Magia 3)Poción 4)Huir")
		keyboard.any().onPressDo({ key => self.procesarAccionHeroe(key.asChar()) })
	}
	
	method procesarAccionHeroe(tecla) {
		keyboard.any().clearListeners()
		if (tecla == '1') { heroe.usarHabilidad(heroe.habilidades().first(), enemigo) } 
		else if (tecla == '2') { heroe.usarHabilidad(heroe.habilidades().last(), enemigo) } 
		else if (tecla == '3') { if (heroe.inventario().nonEmpty()) { heroe.usarItem(heroe.inventario().first()) } } 
		else if (tecla == '4') { self.terminarCombate(null) }
		
		if (tecla != '4') {
			uiCombate.actualizarUI(heroe, enemigo)
			turno = enemigo
			game.schedule(1500, { => self.siguienteTurno() })
		}
	}
	
	method turnoEnemigo() {
		game.title("Turno de " + enemigo.nombre())
		enemigo.usarHabilidad(enemigo.habilidades().first(), heroe)
		
		uiCombate.actualizarUI(heroe, enemigo)
		turno = heroe
		game.schedule(1500, { => self.siguienteTurno() })
	}
	
	method terminarCombate(enemigoDerrotado) {
		if (enemigoDerrotado != null) {
			heroe.ganarExp(enemigoDerrotado.expOtorgada())
		}
		uiCombate.limpiarPantalla()
		mundo.volverAExploracion()
	}
}