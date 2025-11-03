import wollok.game.*
import objectsAndDragons.*
import stages.*

object uiCombate {
	var uiHeroe = null
	var uiEnemigo = null
	var uiMenu = null
	var uiAccion = null
	var opcionesActivas = false
	var menuTexto = ""
	
	method dibujarPantallaDeCombate(heroe, enemigo) {
		game.clear()
		const fondo = new Decoracion(image="battle_bg.png", position=game.origin())
		
		// Paneles de estado: separados verticalmente para evitar superposición
		uiHeroe = new Decoracion(image="textbox.png", position=game.at(1, 1))
		uiEnemigo = new Decoracion(image="textbox.png", position=game.at(9, 6))
		uiMenu = new Decoracion(image="textbox.png", position=game.at(1, 7))
		uiAccion = new Decoracion(image="textbox.png", position=game.at(6, 4))
		
		game.addVisual(fondo)
		game.addVisual(uiHeroe)
		game.addVisual(uiEnemigo)
		game.addVisual(uiMenu)
		game.addVisual(uiAccion)
		
		heroe.position(game.at(3, 2))
		enemigo.position(game.at(12, 5))
		game.addVisualCharacter(heroe)
		game.addVisualCharacter(enemigo)
		
		self.actualizarUI(heroe, enemigo)
		// El texto del menú se establece desde Combate.mostrarMenuHeroe()
	}
	
	method actualizarUI(heroe, enemigo) {
		// Refrescar periódicamente para que persista
		self.actualizarEstadoHeroe(heroe)
		self.actualizarEstadoEnemigo(enemigo)
	}

	method actualizarEstadoHeroe(heroe) {
		game.say(uiHeroe, "HEROE\nHP: " + heroe.vida() + "/" + heroe.vidaMaxima() + "\nMP: " + heroe.mana() + "/" + heroe.manaMaximo())
		game.schedule(3000, { => if (mundo.estadoJuego() == "combate") self.actualizarEstadoHeroe(heroe) })
	}

	method actualizarEstadoEnemigo(enemigo) {
		game.say(uiEnemigo, "ENEMIGO\nHP: " + enemigo.vida() + "/" + enemigo.vidaMaxima() + "\nMP: " + enemigo.mana() + "/" + enemigo.manaMaximo())
		game.schedule(3000, { => if (mundo.estadoJuego() == "combate") self.actualizarEstadoEnemigo(enemigo) })
	}

	method mostrarAccion(texto) {
		// Panel central para acciones/feedback visible
		game.say(uiAccion, texto)
	}
	
	method limpiarPantalla() { 
		game.clear() 
		uiHeroe = null
		uiEnemigo = null
		uiMenu = null
		uiAccion = null
		opcionesActivas = false
	}

	method mostrarOpcionesCon(texto) {
		menuTexto = texto
		opcionesActivas = true
		self.refrescarMenu()
	}

	method refrescarMenu() {
		if (opcionesActivas) {
			game.say(uiMenu, menuTexto)
			game.schedule(3500, { => if (opcionesActivas and mundo.estadoJuego() == "combate") self.refrescarMenu() })
		}
	}
}

class Combate {
	var heroe = null
	var enemigo = null
	var turno = null
	var escuchandoInputHeroe = false

	// Evitamos re-registrar listeners múltiples veces
	var listenersIniciados = false

	method iniciarCombate(unHeroe, unEnemigo) {
		heroe = unHeroe
		enemigo = unEnemigo
		uiCombate.dibujarPantallaDeCombate(heroe, enemigo)

		turno = if (heroe.velocidad() >= enemigo.velocidad()) heroe else enemigo

		// Registramos listeners una sola vez
		if (!listenersIniciados) {
			self.iniciarListeners()
			listenersIniciados = true
		}

		self.siguienteTurno()
	}

	// Registramos listeners globales; cada handler verifica la bandera escuchandoInputHeroe
	method iniciarListeners() {
		// Bloquear movimiento WASD y E durante el combate (overrides simples)
		keyboard.w().onPressDo({ => self.noop() })
		keyboard.a().onPressDo({ => self.noop() })
		keyboard.s().onPressDo({ => self.noop() })
		keyboard.d().onPressDo({ => self.noop() })
		keyboard.e().onPressDo({ => self.noop() })

		keyboard.f().onPressDo({ =>
			if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) {
				self.ejecutarSlot(1)
			}
		})

		keyboard.g().onPressDo({ =>
			if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) {
				self.ejecutarSlot(2)
			}
		})

		keyboard.h().onPressDo({ =>
			if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) {
				self.ejecutarSlot(3)
			}
		})

		keyboard.j().onPressDo({ =>
			if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) {
				self.ejecutarSlot(4)
			}
		})

		// Listener numérico 1..4 explícitos y atajo X para huir
		keyboard.num1().onPressDo({ => if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) self.procesarAccionHeroe('1') })
		keyboard.num2().onPressDo({ => if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) self.procesarAccionHeroe('2') })
		keyboard.num3().onPressDo({ => if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) self.procesarAccionHeroe('3') })
		keyboard.num4().onPressDo({ => if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) self.procesarAccionHeroe('4') })
		keyboard.x().onPressDo({ => if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) self.procesarAccionHeroe('4') })
	}

	method noop() { }

	// Ejecuta la lógica común al elegir un slot de habilidad (1..4)
	method ejecutarSlot(slot) {
		escuchandoInputHeroe = false

		// Seguridad: obtener habilidad de forma segura
		const habs = heroe.habilidades()
		const hab = if (habs.size() >= slot and slot >= 1) habs.take(slot).last() else null

		if (hab != null) {
			heroe.usarHabilidad(hab, enemigo)
			uiCombate.actualizarUI(heroe, enemigo)
			uiCombate.mostrarAccion("¡Héroe usó " + hab.nombre() + "!")
			turno = enemigo
			game.schedule(2000, { => self.siguienteTurno() })
		} else {
			uiCombate.mostrarAccion("No tenés ese ataque")
			escuchandoInputHeroe = true
		}
	}

	method siguienteTurno() {
		// Si alguno está muerto, terminamos combate (pasamos el derrotado si corresponde)
		if (heroe != null and enemigo != null) {
			if (heroe.estaVivo() and enemigo.estaVivo()) {
				if (turno == heroe) {
					self.mostrarMenuHeroe()
				} else {
					self.turnoEnemigo()
				}
			} else {
				self.terminarCombate(if (heroe.estaVivo()) enemigo else null)
			}
		}
	}

	method mostrarMenuHeroe() {
		game.title("Tu turno - Elige una acción")
		escuchandoInputHeroe = true
		// Nota: no registramos listeners aquí (ya están registrados en iniciarListeners)

		// Construir nombres de habilidades para el menú
		const habs = heroe.habilidades()
		const n1 = (if (habs.size() >= 1) habs.take(1).last().nombre() else "-")
		const n2 = (if (habs.size() >= 2) habs.take(2).last().nombre() else "-")
		const n3 = (if (habs.size() >= 3) habs.take(3).last().nombre() else "-")
		const n4 = (if (habs.size() >= 4) habs.take(4).last().nombre() else "-")
		const textoMenu = "F=" + n1 + " G=" + n2 + " H=" + n3 + " J=" + n4 + "\n3=Poción 4=Huir X=Huir"
		uiCombate.mostrarOpcionesCon(textoMenu)
		uiCombate.mostrarAccion("Esperando tu acción...")
	}

	method procesarAccionHeroe(tecla) {
		if (mundo.estadoJuego() == "combate" and turno == heroe and escuchandoInputHeroe) {
			escuchandoInputHeroe = false

			const acciones = [
			[ '1', { => 
				const habs = heroe.habilidades()
				if (habs.size() >= 1) {
					heroe.usarHabilidad(habs.first(), enemigo)
					uiCombate.actualizarUI(heroe, enemigo)
					uiCombate.mostrarAccion("¡Héroe usó " + habs.first().nombre() + "!")
					turno = enemigo
					game.schedule(2000, { => self.siguienteTurno() })
				} else {
					uiCombate.mostrarAccion("No tenés esa habilidad")
					escuchandoInputHeroe = true
				}
			} ],
			[ '2', { => 
				const habs = heroe.habilidades()
				if (habs.size() >= 2) {
					heroe.usarHabilidad(habs.get(1), enemigo)
					uiCombate.actualizarUI(heroe, enemigo)
					uiCombate.mostrarAccion("¡Héroe usó " + habs.get(1).nombre() + "!")
					turno = enemigo
					game.schedule(2000, { => self.siguienteTurno() })
				} else {
					uiCombate.mostrarAccion("No tenés esa habilidad")
					escuchandoInputHeroe = true
				}
			} ],
			[ '3', { =>
				const inv = heroe.inventario()
				if (inv != null and inv.size() > 0) {
					const item = inv.first()
					heroe.usarItem(item)
					uiCombate.actualizarUI(heroe, enemigo)
					uiCombate.mostrarAccion("¡Usaste una Poción! +HP")
					turno = enemigo
					game.schedule(2000, { => self.siguienteTurno() })
				} else {
					uiCombate.mostrarAccion("No tenés items")
					escuchandoInputHeroe = true
				}
			} ],
			[ '4', { => 
				uiCombate.mostrarAccion("¡Huiste del combate!")
				game.schedule(1500, { => self.terminarCombate(null) })
			} ]
		]

			const entrada = acciones.filter({ a => a.first() == tecla }).first()
			if (entrada != null) { entrada.last().apply() }
		}
	}

	method turnoEnemigo() {
		game.title("Turno del enemigo...")
		const habs = enemigo.habilidades()
		if (habs != null and habs.size() > 0) {
			const hab = habs.first()
			enemigo.usarHabilidad(hab, heroe)
			uiCombate.mostrarAccion(enemigo.nombre() + " usó " + hab.nombre() + "!")
		} else {
			uiCombate.mostrarAccion(enemigo.nombre() + " no tiene ataques")
		}

		uiCombate.actualizarUI(heroe, enemigo)
		turno = heroe
		game.schedule(2000, { => self.siguienteTurno() })
	}

	method terminarCombate(enemigoDerrotado) {
		if (enemigoDerrotado != null) {
			heroe.ganarExp(enemigoDerrotado.expOtorgada())
		}
		uiCombate.limpiarPantalla()
		mundo.volverAExploracion()
	}
}
