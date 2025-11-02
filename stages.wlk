import wollok.game.*
import objectsAndDragons.*
import combateYUI.*

// Superclase abstracta para áreas/escenarios
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

object bosqueDeMonstruos inherits Stage {

	override method cargar() {
		game.title("Bosque de Monstruos")
		const portalPueblo = new Portal(position = game.at(15, 4), destino = puebloDelRey)
		const fondo = new Decoracion(image="bosque.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
		// La tecla E se maneja globalmente en mundo.configurarTeclasExploracion()
	}

	override method background() = "bosque.png"

	// descargar y alMoverse heredan de Stage

	override method alMoverse() {
		// Antes los encuentros eran aleatorios al moverse; ahora los dejamos controlados por la tecla E (SIGUE SIN FUNCIONAR >.< )
	}
}
object puebloDelRey inherits Stage {
	override method cargar() {
		game.title("Pueblo del Rey")
		const portalBosque = new Portal(position = game.at(0, 4), destino = bosqueDeMonstruos)
		const portalBoss = new Portal(position = game.at(15, 4), destino = salaDelBoss, condicion = { areaHeroe => areaHeroe.tieneAccesoASalaBoss() })
		const fondo = new Decoracion(image="pueblo.jpg", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalBosque)
		game.addVisual(portalBoss)
		visuals.add(portalBosque)
		visuals.add(portalBoss)
	}

	override method background() = "pueblo.jpg"
	// descargar y alMoverse heredan de Stage
}

object salaDelBoss inherits Stage {
	override method cargar() { 
		game.title("Sala del Jefe Final")
		// const fondo = new Decoracion(image="sala_jefe.png", position=game.origin())
		// game.addVisual(fondo)
		// un único portal que devuelva al pueblo (ciudad)
		const fondo = new Decoracion(image="pueblo.jpg", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		const portalPueblo = new Portal(position = game.at(0, 4), destino = puebloDelRey)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
	}

	override method background() = "pueblo.jpg"
	// descargar y alMoverse heredan de Stage
}

object mundo {
	const heroe = new Personaje(position = game.center())
	var areaActual = puebloDelRey
	var estadoJuego = "explorando"
	var combateActual = null

	method heroe() = heroe
	method iniciar() { 
		// Usar cambiarArea para centralizar la lógica de carga de áreas
		self.cambiarArea(areaActual)
		self.configurarTeclasExploracion()
	}
	method estadoJuego() = estadoJuego
	method combateActual() = combateActual
	method configurarTeclasExploracion() { 
    keyboard.w().onPressDo({ => self.moverHeroe(0, 1) })
    keyboard.s().onPressDo({ => self.moverHeroe(0, -1) })
    keyboard.a().onPressDo({ => self.moverHeroe(-1, 0) })
	keyboard.d().onPressDo({ => self.moverHeroe(1, 0) }) 

		// iniciar combate manual en el bosque al tocar la e
	keyboard.e().onPressDo({ =>
					// Debug: mostrar que se pulsó E y el contexto (área + estado)
			game.title("E pulsada en area=" + areaActual.background() + " estado=" + estadoJuego)
			game.say(heroe, "E pulsada: comprobando inicio de combate")
			if (areaActual.background() == bosqueDeMonstruos.background() and estadoJuego == "explorando") {
						// Generar enemigo aleatorio simple
				const listaEnemigos = [
					new Enemigo(nombre="Lobo Salvaje", vida=40, vidaMaxima=40, mana=10, manaMaximo=10, ataqueFisico=8, defensaFisica=3, ataqueMagico=0, defensaMagica=1, velocidad=8, expOtorgada=30, monedasOtorgadas=10, position=game.center()),
					new Enemigo(nombre="Araña Gigante", vida=30, vidaMaxima=30, mana=5, manaMaximo=5, ataqueFisico=6, defensaFisica=2, ataqueMagico=0, defensaMagica=1, velocidad=8, expOtorgada=20, monedasOtorgadas=5, position=game.center())
					]
					const enemigo = listaEnemigos.anyOne()
					game.title("Iniciando combate contra " + enemigo.nombre())
						// Mostrar un mensaje corto antes de cambiar de pantalla
					game.say(heroe, "Iniciando combate con " + enemigo.nombre())
					self.cambiarACombate(enemigo)
					}
				})
  }
	method moverHeroe(dx, dy) { 
    if (estadoJuego == "explorando") { 
      heroe.position(heroe.position().right(dx).up(dy))
      areaActual.alMoverse() 
      } 
  }
	method cambiarArea(nueva) { 
	// Primero descargamos el área actual para remover sus visuales
	areaActual.descargar()
	areaActual = nueva
	// Limpiamos la pantalla, cargamos la nueva área (para que boardGround se aplique) y luego añadimos el héroe
	game.clear()
	areaActual.cargar()
	game.addVisualCharacter(heroe)
	heroe.position(game.center())
	self.configurarTeclasExploracion()
	// Registrar colisión para portales/visuals del área cargada
	game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
  }
	method cambiarACombate(enemigo) { 
		estadoJuego = "combate" 
		combateActual = new Combate()
		combateActual.iniciarCombate(heroe, enemigo) 
  }
	method volverAExploracion() { 
	estadoJuego = "explorando"
	game.clear()
	areaActual.cargar()
	game.addVisualCharacter(heroe)
	// Registrar colisión para portales/visuals del área cargada
	game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
			combateActual = null
  }
}

class Portal {
	var position
	var destino
	var condicion = { heroeParam => true }

	method position() = position
	method position(nuevaPosicion) { position = nuevaPosicion }
	method destino() = destino
	method condicion() = condicion
	
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
	var image
	var position

	method image() = image
	method position() = position
}

