import wollok.game.*
import objectsAndDragons.*
import combateYUI.*

class ZonaInteractiva {
	var property position
	var property image
	var property nombre
	var property accion
	var property esTienda = false 

	method interactuar() { accion.apply() }
}

object bosqueDeMonstruos {
	const probabilidadCombate = 20
	var visuals = [] 	 

	method cargar() {
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
	}

	method background() = "bosque.png"

	method descargar() {
		visuals.forEach { visual => game.removeVisual(visual) }
		visuals = []
	}

	method alMoverse() {}
}
object puebloDelRey {
	var visuals = []
	method cargar() {
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

	method background() = "pueblito.jpg"
	method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
	method alMoverse() {}
}

object salaDelBoss {
	var visuals = []
	method cargar() { 
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

	method background() = "bosque.png"
	method descargar() { visuals.forEach { v => game.removeVisual(v) }; visuals = [] }
	method alMoverse() {}
}

object mundo {
	const heroe = heroePrincipal 
	var areaActual = puebloDelRey 
	var estadoJuego = "explorando"

	method heroe() = heroe
	method iniciar() { 
		self.cambiarArea(areaActual)
		self.configurarTeclasExploracion()
	}
	method estadoJuego() = estadoJuego
	
	method configurarTeclasExploracion() { 
		keyboard.any().clearListeners()
		
		keyboard.w().onPressDo({ => self.moverHeroe(0, 1) })
		keyboard.s().onPressDo({ => self.moverHeroe(0, -1) })
		keyboard.a().onPressDo({ => self.moverHeroe(-1, 0) })
		keyboard.d().onPressDo({ => self.moverHeroe(1, 0) }) 

		keyboard.e().onPressDo({ =>
			if (areaActual.background() == bosqueDeMonstruos.background() and estadoJuego == "explorando") {
				const listaEnemigos = [
					new EnemigoSimple(
						nombre="Lobo Salvaje", vida=40, vidaMaxima=40, mana=0, manaMaximo=0, 
						ataqueFisico=8, defensaFisica=3, ataqueMagico=0, defensaMagica=1, 
						velocidad=8, expOtorgada=30, monedasOtorgadas=10, position=game.center()
					),
					new EnemigoSimple(
						nombre="Araña Gigante", vida=30, vidaMaxima=30, mana=0, manaMaximo=0, 
						ataqueFisico=6, defensaFisica=2, ataqueMagico=0, defensaMagica=1, 
						velocidad=8, expOtorgada=20, monedasOtorgadas=5, position=game.center()
					)
				]
				const enemigo = listaEnemigos.anyOne()
				game.say(heroe, "¡Un encuentro con " + enemigo.nombre() + "!")
				self.cambiarACombate(enemigo)
			}
		})
	}
	
	method moverHeroe(dx, dy) { 
		if (estadoJuego == "explorando") { 
			
			var direccion = null
			if (dx == 1) { direccion = Direction.Right }
			else if (dx == -1) { direccion = Direction.Left }
			else if (dy == 1) { direccion = Direction.Up }
			else if (dy == -1) { direccion = Direction.Down }

			if (direccion != null) {
				game.move(heroe, direccion, 150) 
			}
			
			areaActual.alMoverse() 
		} 
	}

	method cambiarArea(nueva) { 
		areaActual.descargar()
		areaActual = nueva
		game.clear()
		areaActual.cargar()
		game.addVisual(heroe) 
		heroe.position(game.center())
		self.configurarTeclasExploracion()
		game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
	}
	method cambiarACombate(enemigo) { 
		estadoJuego = "combate" 
		sistemaDeCombate.iniciarCombate(heroe, enemigo) 
	}
	method volverAExploracion() { 
		estadoJuego = "explorando"
		game.clear()
		areaActual.cargar()
		game.addVisual(heroe)
		game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
		heroe.animarIdle() 
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