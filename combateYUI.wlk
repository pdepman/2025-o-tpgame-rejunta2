import wollok.game.*
import objectsAndDragons.*
import stages.*

class BarraVida {
	var owner
	var property position
	var barraFondo 
	var barraVida 
	var labelNombre 
	
	const ANCHO = 6 
	const ALTO = 0.3 

	method initialize(unOwner, unaPosicion, colorBarra) {
		owner = unOwner
		position = unaPosicion
		
		barraFondo = new Rectangle(width=ANCHO, height=ALTO, color=Color.darkGray, position=position)
		barraVida = new Rectangle(width=ANCHO, height=ALTO, color=colorBarra, position=position)
		
		labelNombre = new Label(text=owner.nombre(), 
								position=position.up(0.15 + ALTO).right(ANCHO / 2 - 0.5), 
								color=Color.white, 
								size=12)
		
		game.addVisual(barraFondo)
		game.addVisual(barraVida)
		game.addVisual(labelNombre)
	}

	method actualizar() {
		const porcentaje = owner.vida() / owner.vidaMaxima()
		const nuevoAncho = ANCHO * porcentaje
		
		barraVida.width(nuevoAncho.max(0)) 
		
		labelNombre.text(owner.nombre() + " V:" + owner.vida() + "/" + owner.vidaMaxima())
	}
	
	method limpiar() {
		game.removeVisual(barraFondo)
		game.removeVisual(barraVida)
		game.removeVisual(labelNombre)
	}
}

object uiCombate {
	var barraHeroe = null 
	var barraEnemigo = null 
	
	method dibujarPantallaDeCombate(heroe, enemigo) {
		game.clear()
		const fondo = new Decoracion(image="battle_bg.png", position=game.origin())
		game.addVisual(fondo)
		
		heroe.position(game.at(3, 3)) 
		enemigo.position(game.at(12, 6)) 
		game.addVisual(heroe)
		game.addVisual(enemigo)
		
		barraHeroe = new BarraVida(owner=heroe, position=game.at(3, 1), colorBarra=Color.red) 
		barraEnemigo = new BarraVida(owner=enemigo, position=game.at(10, 8), colorBarra=Color.orange)
		
		self.actualizarUI(heroe, enemigo)
	}
	
	method actualizarUI(heroe, enemigo) {
		barraHeroe.actualizar()
		barraEnemigo.actualizar()
	}
	
	method limpiarPantalla() { 
		game.clear() 
		if (barraHeroe != null) { barraHeroe.limpiar() }
		if (barraEnemigo != null) { barraEnemigo.limpiar() }
		barraHeroe = null
		barraEnemigo = null
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
		self.mostrarMenuHeroe()
		self.siguienteTurno()
	}
	
	method siguienteTurno() {
		if (heroe.estaVivo() and enemigo.estaVivo()) {
			if (turno == heroe) { self.mostrarMenuHeroe() } else { self.turnoEnemigo() }
		} else {
			 self.terminarCombate(if (heroe.estaVivo()) enemigo else null)
		}
	}
	
	method mostrarMenuHeroe() {
		const habs = heroe.habilidades()
		const menuText = "ACCIONES: " + 
			(habs.size() >= 1 ? "[F] " + habs.get(0).nombre() + " | " : "") + 
			(habs.size() >= 2 ? "[G] " + habs.get(1).nombre() + " | " : "") + 
			(habs.size() >= 3 ? "[H] " + habs.get(2).nombre() + " | " : "") + 
			(habs.size() >= 4 ? "[J] " + habs.get(3).nombre() + " | " : "") + 
			"[3] Poción | [4] Huir (Maná:" + heroe.mana() + ")"
			
		game.title(menuText) 
		
		keyboard.any().clearListeners()
		keyboard.f().clearListeners()
		keyboard.g().clearListeners()
		keyboard.h().clearListeners()
		keyboard.j().clearListeners()

		keyboard.f().onPressDo({ =>
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(1).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurnido() })
			} else {
				game.say(heroe, "No conozco ese ataque")
				self.mostrarMenuHeroe() 
			}
		})

		keyboard.g().onPressDo({ =>
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(2).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
				self.mostrarMenuHeroe() 
			}
		})
		keyboard.h().onPressDo({ =>
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(3).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
				self.mostrarMenuHeroe()
			}
		})
		keyboard.j().onPressDo({ =>
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(4).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
				self.mostrarMenuHeroe()
			}
		})

		keyboard.any().onPressDo({ key => self.procesarAccionHeroe(key.asChar()) })
	}

	method procesarAccionHeroe(tecla) {
		keyboard.any().clearListeners()
		
		const acciones = [
			[ '3', { => 
				heroe.inventario().take(1).forEach({ item => 
					heroe.usarItem(item); 
					uiCombate.actualizarUI(heroe, enemigo); 
					turno = enemigo; 
					game.schedule(1500, { => self.siguienteTurno() }) 
				})
				self.mostrarMenuHeroe()
			} ],
			[ '4', { => self.terminarCombate(null) } ]
		]

		const entrada = acciones.filter({ a => a.first() == tecla }).first()
		if (entrada != null) { entrada.last().apply() } else { self.mostrarMenuHeroe() }
	}
	
	method turnoEnemigo() {
		game.title("Turno de " + enemigo.nombre() + "...")
		enemigo.usarHabilidad(enemigo.habilidades().first(), heroe)
		
		uiCombate.actualizarUI(heroe, enemigo)
		turno = heroe
		game.schedule(1500, { => self.siguienteTurno() })
	}
	
	method terminarCombate(enemigoDerrotado) {
		if (enemigoDerrotado != null) {
			heroe.ganarExp(enemigoDerrotado.expOtorgada())
			heroe.ganarMonedas(enemigoDerrotado.monedasOtorgadas())
		}
		uiCombate.limpiarPantalla()
		mundo.volverAExploracion()
	}
}