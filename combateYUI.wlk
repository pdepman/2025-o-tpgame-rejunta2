import wollok.game.*
import objectsAndDragons.*
import stages.*

object uiCombate {
	var uiHeroe = null
	var uiEnemigo = null
	
	method dibujarPantallaDeCombate(heroe, enemigo) {
		game.clear()
		const fondo = new Decoracion(image="battle_bg.png", position=game.origin())
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
		self.mostrarMenuHeroe()
		self.siguienteTurno()
	}
	
	method siguienteTurno() {
		if (heroe.estaVivo() and enemigo.estaVivo()) {
			if (turno == heroe) { self.mostrarMenuHeroe() } else { self.turnoEnemigo() }
		}
	}
	
	method mostrarMenuHeroe() {
		game.title("Elige: F/G/H/J = Ataques | 3 = Poción | 4 = Huir")
		// Limpiamos listeners previos por si quedaron registrados
		keyboard.any().clearListeners()
		keyboard.f().clearListeners()
		keyboard.g().clearListeners()
		keyboard.h().clearListeners()
		keyboard.j().clearListeners()

		keyboard.f().onPressDo({ =>
			// Slot 1 (primer ataque)
			keyboard.f().clearListeners()
			keyboard.g().clearListeners()
			keyboard.h().clearListeners()
			keyboard.j().clearListeners()
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(1).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
			}
		})

		keyboard.g().onPressDo({ =>
			// Slot 2 (segundo ataque)
			keyboard.f().clearListeners()
			keyboard.g().clearListeners()
			keyboard.h().clearListeners()
			keyboard.j().clearListeners()
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(2).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
			}
		})

		keyboard.h().onPressDo({ =>
			// Slot 3 (tercer ataque, si existe)
			keyboard.f().clearListeners()
			keyboard.g().clearListeners()
			keyboard.h().clearListeners()
			keyboard.j().clearListeners()
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(3).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
			}
		})

		keyboard.j().onPressDo({ =>
			// Slot 4 (cuarto ataque, si existe)
			keyboard.f().clearListeners()
			keyboard.g().clearListeners()
			keyboard.h().clearListeners()
			keyboard.j().clearListeners()
			keyboard.any().clearListeners()
			const hab = heroe.habilidades().take(4).last()
			if (hab != null) {
				heroe.usarHabilidad(hab, enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} else {
				game.say(heroe, "No conozco ese ataque")
			}
		})

		// Mantenemos las opciones de objeto/huir por tecla numérica como fallback (3 y 4)
		keyboard.any().onPressDo({ key => self.procesarAccionHeroe(key.asChar()) })
	}
	
	method procesarAccionHeroe(tecla) {
		keyboard.any().clearListeners()
		// Tabla de delegación: cada entrada mapea una tecla a una función que realiza la acción.
		const acciones = [
			[ '1', { => 
				heroe.usarHabilidad(heroe.habilidades().first(), enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} ],
			[ '2', { => 
				heroe.usarHabilidad(heroe.habilidades().last(), enemigo)
				uiCombate.actualizarUI(heroe, enemigo)
				turno = enemigo
				game.schedule(1500, { => self.siguienteTurno() })
			} ],
			[ '3', { => 
				// Usar take(1).forEach para aplicar el ítem sólo si existe, evitando ifs
				heroe.inventario().take(1).forEach({ item => heroe.usarItem(item); uiCombate.actualizarUI(heroe, enemigo); turno = enemigo; game.schedule(1500, { => self.siguienteTurno() }) })
			} ],
			[ '4', { => self.terminarCombate(null) } ]
		]

		const entrada = acciones.filter({ a => a.first() == tecla }).first()
		if (entrada != null) { entrada.last().apply() }
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