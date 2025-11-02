import wollok.game.*
import objectsAndDragons.*
import combateYUI.*
import controlEstado.*

class Stage {
	var visuals = []

	method visuals() = visuals
	method background() = "default.png"

	method cargar() {}

	method descargar() {
		visuals.forEach { v => game.removeVisual(v) }
		visuals = []
	}

	method alMoverse() {}
}
class ZonaInteractiva {
	var property position
	var property image
	var property nombre
	var property accion
	var property esTienda = false 

	method interactuar() { accion.apply() }
}

object bosqueDeMonstruos inherits Stage{
	var property  probabilidadCombate = 20	
	override method cargar(){ 
	game.title("Bosque de Monstruos - Área 1")
		
		const portalPueblo = new Portal(
			position = game.at(15, 4), 
			destino = puebloDelRey,
			image = "portal_anim_1.png"
		)
		
		const fondo = new Decoracion(image="bosque.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
	} }

object puebloDelRey inherits Stage {
	override method cargar() {
		game.title("Pueblo del Rey - Área 2")
		
		const portalBosque = new Portal(
			position = game.at(0, 4), 
			destino = bosqueDeMonstruos,
			image = "portal_anim_1.png"
		)
		const portalBoss = new Portal(
			position = game.at(15, 4), 
			destino = salaDelBoss, 
			condicion = { areaHeroe => areaHeroe.tieneAccesoASalaBoss() },
			image = "portal_anim_1.png"
		)
		
		const fondo = new Decoracion(image="pueblito.jpg", position=game.origin())
		
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalBosque)
		game.addVisual(portalBoss)
		visuals.add(portalBosque)
		visuals.add(portalBoss)
		
		const zonaCuracion = new ZonaInteractiva(
			position=game.at(8, 2), 
			nombre="Fuente de Curación", 
			accion={ => mundo.heroe().curarse() },
			image="portal.png", 
			esTienda=false
		)
		
		game.addVisual(zonaCuracion)
		visuals.add(zonaCuracion)
	}

	override method background() = "pueblito.jpg"
}

object salaDelBoss inherits Stage {
	override method cargar() { 
		game.title("Sala del Jefe Final - Área 3")
		const fondo = new Decoracion(image="bosque.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		
		const portalPueblo = new Portal(
			position = game.at(0, 4), 
			destino = puebloDelRey,
			image = "portal_anim_1.png"
		)
		
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
		
		game.say(mundo.heroe(), "¡El Jefe Final está cerca!")
	}

	override method background() = "bosque.png"
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

	method es_estadoActualControl(estado){
		return estado == estadoActualControl;
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
		explorando.teclas()
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
		explorando.teclas()
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
	var property image = "portal.png" 

	
	method fueTocadoPor(jugador) {
		if (condicion.apply(jugador)) {
			mundo.cambiarArea(destino)
		} else {
			game.say(jugador, "Nivel 10 requerido para pasar.")
		}
	}
}

class Decoracion {
	var image
	var position

	method image() = image
	method position() = position
}

