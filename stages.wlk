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
	var estadoJuego = "inicio" // valores posibles: inicio | explorando | combate | pausa
	var combateActual = null
	var overlayPausa = null
	var fondoInicio = null

	method heroe() = heroe
	method iniciar() { 
		// Mostrar pantalla de inicio antes de comenzar a explorar
		self.mostrarPantallaInicio()
	}
	method estadoJuego() = estadoJuego
	method combateActual() = combateActual

	// Pantalla de inicio simple: Enter para empezar
	method mostrarPantallaInicio() {
		estadoJuego = "inicio"
		game.clear()
		game.title("RPG por turnos - Presioná Enter para comenzar")
		fondoInicio = new Decoracion(image="inicio_bg.png", position=game.origin())
		game.addVisual(fondoInicio)
		keyboard.enter().onPressDo({ => if (estadoJuego == "inicio") self.empezarExploracion() })
	}

	method empezarExploracion() {
		// Pasamos a exploración, cargamos el área por defecto y seteamos teclas
		estadoJuego = "explorando"
		game.clear()
		// Usar cambiarArea para centralizar la lógica de carga de áreas
		self.cambiarArea(areaActual)
	}
	method configurarTeclasExploracion() { 
	keyboard.w().onPressDo({ => if (estadoJuego == "explorando") self.moverHeroe(0, 1) })
	keyboard.s().onPressDo({ => if (estadoJuego == "explorando") self.moverHeroe(0, -1) })
	keyboard.a().onPressDo({ => if (estadoJuego == "explorando") self.moverHeroe(-1, 0) })
	keyboard.d().onPressDo({ => if (estadoJuego == "explorando") self.moverHeroe(1, 0) }) 

		// iniciar combate manual en el bosque al tocar la e
	keyboard.e().onPressDo({ => if (estadoJuego == "explorando") {
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

		// Pausa en exploración con tecla P
	keyboard.p().onPressDo({ => self.pausarJuego() })
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
	self.configurarTeclasExploracion()
			combateActual = null
  }

	// --- Pausa simple (solo desde exploración) ---
	method pausarJuego() {
		if (estadoJuego == "explorando") {
			estadoJuego = "pausa"
			game.title("Pausa - Presioná P para reanudar")
			overlayPausa = new Decoracion(image="textbox.png", position=game.at(5, 3))
			game.addVisual(overlayPausa)
			game.say(overlayPausa, "Juego en pausa\nP para continuar")
			keyboard.p().onPressDo({ => if (estadoJuego == "pausa") self.reanudarJuego() })
		}
	}

	method reanudarJuego() {
		if (estadoJuego == "pausa") {
			estadoJuego = "explorando"
			// remover overlay si existe
			if (overlayPausa != null) { game.removeVisual(overlayPausa); overlayPausa = null }
			self.configurarTeclasExploracion()
			game.title("Explorando - " + areaActual.background())
		}
	}
}

class Portal {
	const position
	const destino
	const condicion = { heroeParam => true }

	method position() = position
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
	const image
	const position

	method image() = image
	method position() = position
}

