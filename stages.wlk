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
		// Antes los encuentros eran aleatorios al moverse, ahora la tecla E (SIGUE SIN FUNCIONAR >.< )
	}
}
object puebloDelRey inherits Stage {
	override method cargar() {
		game.title("Pueblo del Rey")
		const portalBosque = new Portal(position = game.at(0, 4), destino = bosqueDeMonstruos)
		const portalBoss = new Portal(position = game.at(15, 4), destino = salaDelBoss, condicion = { areaHeroe => areaHeroe.tieneAccesoASalaBoss() })
		const fondo = new Decoracion(image="pueblof.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		game.addVisual(portalBosque)
		game.addVisual(portalBoss)
		visuals.add(portalBosque)
		visuals.add(portalBoss)
	}

	override method background() = "pueblof.png"
	// descargar y alMoverse heredan de Stage
}

object salaDelBoss inherits Stage {
	var boss = null
	
	override method cargar() { 
		game.title("Sala del Jefe Final")
		const fondo = new Decoracion(image="boss.png", position=game.origin())
		game.addVisual(fondo)
		visuals.add(fondo)
		
		// Crear el boss estático en el centro de la sala solo si no ha sido derrotado
		if (boss == null or boss.estaVivo()) {
			boss = new FinalBoss(
				nombre="Parcial de objetos", 
				vida=200, 
				vidaMaxima=200, 
				mana=100, 
				manaMaximo=100, 
				ataqueFisico=25, 
				defensaFisica=15, 
				ataqueMagico=30, 
				defensaMagica=20, 
				velocidad=12, 
				expOtorgada=500, 
				monedasOtorgadas=100, 
				position=game.at(8, 4),
				imagen="finalboss.png"
			)
			game.addVisual(boss) // Usar addVisual en lugar de addVisualCharacter
			visuals.add(boss)
		}
		
		// Portal de salida al pueblo
		const portalPueblo = new Portal(position = game.at(0, 4), destino = puebloDelRey)
		game.addVisual(portalPueblo)
		visuals.add(portalPueblo)
	}
	
	method removerBoss() {
		if (boss != null) {
			game.removeVisual(boss)
			visuals.remove(boss)
			boss.vida(0) // Marcar como muerto para que no reaparezca
		}
	}

	override method background() = "boss.png"
}

object mundo {
	const heroe = new Personaje(position = game.center())
	var areaActual = puebloDelRey
	var estadoJuego = "inicio" // valores posibles: inicio | explorando | combate | pausa
	var combateActual = null
	var overlayPausa = null
	var fondoInicio = null
	var panelStatus = null
	var anchorStatus = null

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
					new Enemigo(nombre="Lobo Salvaje", vida=40, vidaMaxima=40, mana=10, manaMaximo=10, ataqueFisico=8, defensaFisica=3, ataqueMagico=0, defensaMagica=1, velocidad=8, expOtorgada=30, monedasOtorgadas=10, position=game.center(), imagen="lobo.png"),
					new Enemigo(nombre="Araña Gigante", vida=30, vidaMaxima=30, mana=5, manaMaximo=5, ataqueFisico=6, defensaFisica=2, ataqueMagico=0, defensaMagica=1, velocidad=8, expOtorgada=20, monedasOtorgadas=5, position=game.center(), imagen="araña.png")
					]
					const enemigo = listaEnemigos.anyOne()
					game.title("Iniciando combate contra " + enemigo.nombre())
						// Mostrar un mensaje corto antes de cambiar de pantalla
					game.say(heroe, "Iniciando combate con " + enemigo.nombre())
					self.cambiarACombate(enemigo)
					} else {
					game.say(heroe, "Aquí no puedo iniciar un combate.")
					}
				}})		

		// Pausa en exploración con tecla P
	keyboard.p().onPressDo({ => self.pausarJuego() })

	// Pantalla de status con tecla I (sólo en el pueblo)
keyboard.i().onPressDo({ => self.toggleStatus() })
  }
	method moverHeroe(dx, dy) { 
	if (estadoJuego == "explorando") { 
      heroe.position(heroe.position().right(dx).up(dy))
      areaActual.alMoverse() 
      } 
  }
		// ---- Pantalla de Status (sólo pueblo) ----
		method toggleStatus() {
			if (estadoJuego == "status") {
				self.cerrarStatus()
			} else {
				if (estadoJuego == "explorando" and areaActual.background() == puebloDelRey.background()) {
					self.mostrarStatus()
				}
			}
		}

		method mostrarStatus() {
			estadoJuego = "status"
			game.title("Status del Héroe - Presioná I para volver")
			// Crear panel y mostrar stats
			panelStatus = new Decoracion(image="papirostats.png", position=game.at(2, 1))
			game.addVisual(panelStatus)
			// Ancla invisible para centrar la burbuja por encima del papiro
			anchorStatus = new Decoracion(image=null, position=game.at(3, 3))
			game.addVisual(anchorStatus)

			var texto = "=== STATUS ===" +
				"\nNombre: " + heroe.nombre() +
				"\nNivel: " + heroe.nivel() +
				"\nHP: " + heroe.vida() + "/" + heroe.vidaMaxima() +
				"\nMP: " + heroe.mana() + "/" + heroe.manaMaximo() +
				"\nFísico: ATK=" + heroe.ataqueFisico() + " DEF=" + heroe.defensaFisica() +
				"\nMágico: ATK=" + heroe.ataqueMagico() + " DEF=" + heroe.defensaMagica() +
				"\nVelocidad: " + heroe.velocidad() +
				"\nEXP: " + heroe.exp() + "/" + heroe.expSiguienteNivel()

			// Listar habilidades con costo de MP (dos líneas por habilidad para acotar el ancho)
			texto = texto + "\n\nHabilidades:"
			heroe.habilidades().forEach({ h =>
				texto = texto + "\n- " + h.nombre() + "\n   MP: " + h.costoMana()
			})

			// Listar inventario
			texto = texto + "\n\nInventario:"
			if (heroe.inventario().size() == 0) {
				texto = texto + "\n- (vacío)"
			} else {
				heroe.inventario().forEach({ it =>
					texto = texto + "\n- " + it.nombre()
				})
			}

			// Mostramos el texto sobre el ancla para que quede centrado y por encima del papiro
			game.say(anchorStatus, texto)
		}

		method cerrarStatus() {
			// Remover panel y volver a exploración
			if (anchorStatus != null) { game.removeVisual(anchorStatus); anchorStatus = null }
			if (panelStatus != null) { game.removeVisual(panelStatus); panelStatus = null }
			estadoJuego = "explorando"
			game.title("Explorando - " + areaActual.background())
		}

	method cambiarArea(nueva) { 
	// Primero descargamos el área actual para remover sus visuales
	areaActual.descargar()
	areaActual = nueva
	// Limpiamos la pantalla, cargamos la nueva área (para que boardGround se aplique) y luego añadimos el héroe
	game.clear()
	areaActual.cargar()
	game.addVisualCharacter(heroe)
	
	// Posicionar héroe según el área
	if (nueva == salaDelBoss) {
		heroe.position(game.at(2, 2)) // Esquina inferior izquierda para la sala del boss
	} else {
		heroe.position(game.center()) // Centro para otras áreas
	}
	
	self.configurarTeclasExploracion()
	// Registrar colisión para portales/visuals del área cargada
	game.whenCollideDo(heroe, { otro => otro.fueTocadoPor(heroe) })
  }
	method cambiarACombate(enemigo) { 
		estadoJuego = "combate" 
		combateActual = new Combate()
		self.desactivarMovimientoEnTeclado()
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

	method desactivarMovimientoEnTeclado() {
		// Overwrite de WASD para que no muevan nada en combate
		keyboard.w().onPressDo({ => self.noop() })
		keyboard.a().onPressDo({ => self.noop() })
		keyboard.s().onPressDo({ => self.noop() })
		keyboard.d().onPressDo({ => self.noop() })
	}

	method noop() {}

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
			if (overlayPausa != null) { game.removeVisual(overlayPausa); overlayPausa = null }
			self.configurarTeclasExploracion()
			game.title("Explorando - " + areaActual.background())
		}
	}

	method mostrarGameOver(personaje) {
        estadoJuego = "gameover"
        game.clear()
        const gameOverScreen = new GameOverScreen()
        game.addVisual(gameOverScreen)
        keyboard.enter().onPressDo({ =>
            // Restaurar vida y maná al máximo
            personaje.vida(personaje.vidaMaxima())
            personaje.mana(personaje.manaMaximo())
            
            // Volver al pueblo
            game.clear()
            self.cambiarArea(puebloDelRey)
        })
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

class GameOverScreen {
    method position() = game.center()
    method image() = "gameOver.png"
}

