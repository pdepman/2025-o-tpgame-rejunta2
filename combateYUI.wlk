import wollok.game.*
import objectsAndDragons.*
import stages.*

object uiCombate {
	var uiHeroe = null
	var uiEnemigo = null
	var uiMensajeCombate = null

	method dibujarPantallaDeCombate(heroe, enemigo) {
		game.clear()
		const fondo = new Decoracion(image="battle_bg.png", position=game.origin())
		uiHeroe = new Decoracion(image="textbox.png", position=game.at(12, 2))
		uiEnemigo = new Decoracion(image="textbox.png", position=game.at(1, 7))
		uiMensajeCombate = new Decoracion(image="textbox.png", position=game.at(1, 1))

		game.addVisual(fondo)
		game.addVisual(uiHeroe)
		game.addVisual(uiEnemigo)
		game.addVisual(uiMensajeCombate)

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
	method mostrarMensaje(mensaje) {
 	    if (uiMensajeCombate != null) {
 	        game.say(uiMensajeCombate, mensaje)
 	    }
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
	
	method turnoActual() = turno
	method iniciarCombate(unHeroe, unEnemigo) {
 		heroe = unHeroe
     	enemigo = unEnemigo
 		uiCombate.dibujarPantallaDeCombate(heroe, enemigo)
 		turno = if (heroe.velocidad() >= enemigo.velocidad()) heroe else enemigo
 		self.siguienteTurno() 
 	}
	
	method siguienteTurno() {
 		uiCombate.actualizarUI(heroe, enemigo)
 		if (!heroe.estaVivo()) {
 			self.finalizarCombate(null)  
 		}
 		if (!enemigo.estaVivo()) {
 			self.finalizarCombate(enemigo) 
 		}
 		if (turno == heroe) {
 			self.prepararTurnoHeroe()
 		} else {
 			self.ejecutarTurnoEnemigo()
 		}
 	}
	
	method prepararTurnoHeroe() {
 		game.title("Tu Turno: F/G/H/J=Atk | 3=Poc | 4=Huir")
 		uiCombate.mostrarMensaje("Elige tu acción...")
 		// No configurar listeners aquí, el estado 'combate' recibe las teclas
 	}

 	// Método llamado por el estado 'combate' al recibir una tecla válida
 	method procesarAccionHeroeTecla(tecla) {
 	    var accionRealizada = false
 	    if (tecla == "f") { accionRealizada = self.usarHabilidadHeroe(0) }
 	    else if (tecla == "g") { accionRealizada = self.usarHabilidadHeroe(1) }
 	    else if (tecla == "h") { accionRealizada = self.usarHabilidadHeroe(2) }
 	    else if (tecla == "j") { accionRealizada = self.usarHabilidadHeroe(3) }
 	    else if (tecla == "3") { accionRealizada = self.usarPocionHeroe() }
 	    else if (tecla == "4") { self.intentarHuir(); accionRealizada = true } // Huir siempre "realiza" una acción

 	    // Si se realizó una acción válida que termina el turno
 	    if (accionRealizada) {
 	        turno = enemigo // Cambiar turno
 	        game.schedule(1000, { => self.siguienteTurno() }) // Esperar y pasar al siguiente turno
 	    } else {
 	        // Si la acción no fue válida (ej. habilidad inexistente, sin mana), permitir elegir de nuevo
 	        uiCombate.mostrarMensaje("Acción no válida. Elige de nuevo.")
 	        // No cambiamos de turno, sigue siendo turno del héroe
 	    }
 	}

 	method usarHabilidadHeroe(indice) {
 	    const hab = heroe.habilidades().getOrNull(indice) // Usar getOrNull para evitar errores
 	    if (hab == null) {
 	        uiCombate.mostrarMensaje("No tienes habilidad en ese slot.")
 	        return false // Acción no válida
 	    }
 	    if (heroe.mana() < hab.costoMana()) {
 	        uiCombate.mostrarMensaje("¡No tienes suficiente maná!")
 	        return false // Acción no válida
 	    }
 	    heroe.usarHabilidad(hab, enemigo) // Aplicar habilidad
 	    uiCombate.mostrarMensaje(heroe.nombre() + " usó " + hab.nombre() + "!")
 	    uiCombate.actualizarUI(heroe, enemigo) // Actualizar UI después del ataque
 	    return true // Acción válida realizada
 	}

 	method usarPocionHeroe() {
 	    // Buscar una poción en el inventario (asume que la primera es la que se usa)
 	    const pocion = heroe.inventario().find({item => item.esPocion()}) // Necesitaríamos un método esPocion() en Item/Pocion
 	    if (pocion == null) {
 	        uiCombate.mostrarMensaje("¡No tienes pociones!")
 	        return false // Acción no válida
 	    }
 	    heroe.usarItem(pocion) // Asume que usarItem la consume
 	    uiCombate.mostrarMensaje(heroe.nombre() + " usó " + pocion.nombre() + ".")
 	    uiCombate.actualizarUI(heroe, enemigo) // Actualizar UI después de curar
 	    return true // Acción válida realizada
 	}

 	method intentarHuir() {
 	    // Lógica simple para huir (podría fallar)
 	    uiCombate.mostrarMensaje(heroe.nombre() + " intenta huir...")
 	    // Por ahora, huida exitosa inmediata
 	    game.schedule(1000, { => self.finalizarCombate(null) }) // null porque no se derrotó al enemigo
 	}

 	method ejecutarTurnoEnemigo() {
 		game.title("Turno de " + enemigo.nombre())
 		// Lógica IA simple: usar la primera habilidad
 		const habEnemiga = enemigo.habilidades().first()
 		enemigo.usarHabilidad(habEnemiga, heroe)
 		uiCombate.mostrarMensaje(enemigo.nombre() + " usó " + habEnemiga.nombre() + "!")
 		uiCombate.actualizarUI(heroe, enemigo) // Actualizar UI después del ataque enemigo

 		turno = heroe // Cambiar turno al héroe
 		game.schedule(1500, { => self.siguienteTurno() }) // Esperar y pasar al siguiente turno
 	}

 	method finalizarCombate(enemigoDerrotado) {
 	    var mensajeFinal = ""
 	    if (!heroe.estaVivo()) {
 	        mensajeFinal = "¡Has sido derrotado!"
 	        uiCombate.mostrarMensaje(mensajeFinal)
 	        game.schedule(2000, { => mundo.finalizarJuego(mensajeFinal) }) // Llama a finalizar en mundo
 	    } else if (enemigoDerrotado != null) {
 	        mensajeFinal = "¡Victoria! Ganaste " + enemigoDerrotado.expOtorgada() + " EXP."
 	        heroe.ganarExp(enemigoDerrotado.expOtorgada())
 	        uiCombate.mostrarMensaje(mensajeFinal)
 	        game.schedule(2000, { => mundo.volverAExploracionDesdeCombate() }) // Vuelve a exploración
 	    } else {
 	        // Caso de huida
 	        mensajeFinal = "Escapaste..."
 	        uiCombate.mostrarMensaje(mensajeFinal)
 	        game.schedule(1500, { => mundo.volverAExploracionDesdeCombate() })
 	    }
 	}

 	// Método para actualizar título y UI (útil al volver de pausa)
 	method refrescarTituloYUI(){
 	    if(turno == heroe){
 	        game.title("Tu Turno: F/G/H/J=Atk | 3=Poc | 4=Huir")
 	    } else {
 	        game.title("Turno de " + enemigo.nombre())
 	    }
 	    uiCombate.actualizarUI(heroe, enemigo)
 	}
}