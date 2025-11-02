import wollok.game.*
import objectsAndDragons.*
import combateYUI.*
import controlEstado.*
object bosqueDeMonstruos {
	var property  probabilidadCombate = 20
	var visuals = []	

	method cargar() {
		game.title("Bosque de Monstruos")
		const portalPueblo = new Portal(position = game.at(15, 4), destino = puebloDelRey)
		const fondo = new Decoracion(image="bosque.png", position=game.origin())
		var areaActual = bosqueDeMonstruos
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
		// La tecla E se maneja globalmente en mundo.configurarTeclasExploracion()
	}
	method background() = "bosque.png"

	method descargar() {
		visuals.forEach { visual => game.removeVisual(visual) }
		visuals = []
		// No limpiamos listeners globales aca
	}
	method alMoverse() {
		// Antes los encuentros eran aleatorios al moverse; ahora los dejamos controlados por la tecla E (SIGUE SIN FUNCIONAR >.< )
	}
}
object puebloDelRey {
	var visuals = []
	method cargar() {
		game.title("Pueblo del Rey")
		const portalBosque = new Portal(position = game.at(0, 4), destino = bosqueDeMonstruos)
		const portalBoss = new Portal(position = game.at(15, 4), destino = salaDelBoss, condicion = { areaHeroe => areaHeroe.tieneAccesoASalaBoss() })
		const fondo = new Decoracion(image="pueblo.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalBosque)
		game.addVisual(portalBoss)
		visuals.add(portalBosque)
		visuals.add(portalBoss)
	}

	method background() = "pueblo.png"
	method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
	method alMoverse() {}
}

object salaDelBoss {
	var visuals = []
	method cargar() { 
		game.title("Sala del Jefe Final")

		const fondo = new Decoracion(image="pueblo.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		const portalPueblo = new Portal(position = game.at(0, 4), destino = puebloDelRey)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
	}

	method background() = "pueblo.png"
	method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
	method alMoverse() {}
}

object mundo {
 	const heroe = new Personaje(position = game.center())
 	var areaActual = puebloDelRey
 	var estadoActualControl = inicio 
 	var estadoAnteriorAPausa = null 
	var property esPausa = pausa
	
 	method heroe() = heroe
 	method areaActual() = areaActual 

 	method iniciar() {
		self.cambiarEstadoControl(inicio)
 	}

 	method cambiarEstadoControl(nuevoEstado) {
		if (estadoActualControl != null) {
 			estadoActualControl.onExit() 
 		}
 		if (nuevoEstado == esPausa) {
 		    estadoAnteriorAPausa = estadoActualControl
 		}
 		estadoActualControl = nuevoEstado
 		estadoActualControl.onEnter()
 	}
 	method procesarTeclaGlobal(tecla) {
 	    estadoActualControl.procesarTecla(tecla)
 	}
 	method estadoAnteriorAPausa() = estadoAnteriorAPausa

 	method moverHeroe(dx, dy) {
 		heroe.position(heroe.position().right(dx).up(dy))
 		areaActual.alMoverse() 
 	}
 	method cambiarArea(nueva) {
 		areaActual.descargar()
 		areaActual = nueva
 		game.clear()
 		areaActual.cargar()
 		game.addVisualCharacter(heroe)
 		heroe.position(game.center()) 
 		game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
 		game.title("Explorando - " + areaActual.background()) 
 	}

 	method iniciarLogicaCombate(enemigo) {
 	    sistemaDeCombate.iniciarCombate(heroe, enemigo) 
 	    self.cambiarEstadoControl(combate) 
 	}

 	method volverAExploracionDesdeCombate() {
 	    self.cambiarEstadoControl(explorando) 
 	}

 	method recargarAreaActual() {
 	    game.clear()
 	    areaActual.cargar()
 	    game.addVisualCharacter(heroe)
 	    game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
 	}

 	method finalizarJuego(mensaje) {
 	    final.setMensaje(mensaje)
 	    self.cambiarEstadoControl(final) 
 	}
 }

class Portal {
	var property position
	var property destino
	var property condicion = { heroeParam => true }

	method position() = position
	method position(nuevaPosicion) { position = nuevaPosicion }
	method destino() = destino
	
	method image() = "portal.png"
	
	method fueTocadoPor(jugador) {
		if (condicion.apply(jugador)) {
			mundo.cambiarArea(destino)
		} else {
			game.say(jugador, "Aún no cumplo los requisitos.")
		}
	}
}
class Decoracion {
	var property image
	var property position

	method image() = image
	method position() = position
}

