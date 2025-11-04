import wollok.game.*
import stages.*
import combateYUI.*

class Luchador {
	var nombre
	var nivel = 1
	var vida
	var vidaMaxima // LO USAMOS DE REFERENCIA PARA TENER UN MAXIMO DE VIDA 
	var mana
	var manaMaximo // LO MISMO QUE VIDA MAXIMA
	var ataqueFisico
	var defensaFisica
	var ataqueMagico
	var defensaMagica
	var velocidad
	var property position
	var habilidades = []

	method nombre() = nombre
	method nombre(nuevoNombre) { nombre = nuevoNombre }

	method vida() = vida
	method vida(nuevaVida) { vida = nuevaVida }

	method vidaMaxima() = vidaMaxima

	method nivel() = nivel

	method mana() = mana
	method mana(nuevoMana) { mana = nuevoMana }

	method manaMaximo() = manaMaximo

	method ataqueFisico() = ataqueFisico
	method ataqueMagico() = ataqueMagico
	method defensaFisica() = defensaFisica
	method defensaMagica() = defensaMagica
	method velocidad() = velocidad

	method position() = position
	method position(nuevaPosicion) { position = nuevaPosicion }

	method habilidades() = habilidades

	method estaVivo() = vida > 0
	
	method recibirDaño(cantidad) {
		vida = (vida - cantidad).max(0)
		// delegar la reacción a la muerte a un método que puede ser sobreescrito
		if (!self.estaVivo()) { self.alMorir() }
	}
	
	method alMorir() { /* A DEFINIR MAS ADELANTE */ }
	
	method usarHabilidad(habilidad, oponente) {
		// La habilidad maneja toda su lógica internamente
		habilidad.aplicarPor(self, oponente)
	}
}

class Personaje inherits Luchador {
	var exp = 0
	var expSiguienteNivel = 100
	var inventario = []

	method inventario() = inventario
	method exp() = exp
	method exp(nuevaExp) { exp = nuevaExp }
	method expSiguienteNivel() = expSiguienteNivel
	method expSiguienteNivel(nuevoExpSiguienteNivel) { expSiguienteNivel = nuevoExpSiguienteNivel }

	override method initialize() {
		super()
		nombre = "Héroe del pueblo"
		vida = 100
		vidaMaxima = 100
		mana = 50
		manaMaximo = 50
		ataqueFisico = 10
		defensaFisica = 5
		ataqueMagico = 8
		defensaMagica = 4
		velocidad = 10
			habilidades = [
				new HabilidadAtaqueFisico(nombre="Golpe Rápido", danio=8),
				new HabilidadAtaqueMagico(nombre="Bola de Fuego", danio=15, costoMana=10),
				new HabilidadCuracion(nombre="Curación Menor", curacion=25, costoMana=8)
			]
		inventario = [new Pocion(nombre="Poción de Vida Pequeña", curacion=30)]
	}

	method image() = "player.png"
	override method alMorir() { 
		game.say(self, "He sido derrotado...")
		game.schedule(2000, { => game.stop() })
	}

	method ganarExp(cantidad) { 
		exp += cantidad
		// Subir nivel si alcanzamos la experiencia requerida
		if (exp >= expSiguienteNivel) { self.subirNivel() }
  }
	method subirNivel() { 
		nivel += 1
		exp -= expSiguienteNivel
		expSiguienteNivel *= 1.5
		vidaMaxima += 20
		vida = vidaMaxima
		manaMaximo += 10
		mana = manaMaximo
		ataqueFisico += 3
		defensaFisica += 2
		game.say(self, "¡Subí de nivel! Ahora soy nivel " + nivel) 
  }
	method usarItem(item) { 
		// Aplicar el ítem sólo si existe: usamos take(1).forEach
		inventario.take(1).forEach({ it => it.usar(self); inventario.remove(it) })
  }
	method tieneAccesoASalaBoss() = nivel >= 3
}

class Enemigo inherits Luchador {
	var expOtorgada
	var monedasOtorgadas
	var imagen

	method expOtorgada() = expOtorgada
	method monedasOtorgadas() = monedasOtorgadas
	override method initialize() {
		super()
		habilidades = [new HabilidadAtaqueFisico(nombre="Ataque Básico", danio=5)]
	}
	// Permite especificar una imagen por instancia (campo `imagen`) o elegir
	// una por defecto según el nombre del enemigo.
	method image() =
		if (imagen != null) imagen
		else if (nombre == "Lobo Salvaje") "lobo.png"
		else if (nombre == "Araña Gigante") "araña.png"
		else "enemigo.png"
	override method alMorir() { 
		mundo.combateActual().terminarCombate(self) 
  }
}

class FinalBoss inherits Enemigo {
	override method initialize() {
		super()
		// El boss tiene habilidades más poderosas y variadas
		habilidades = [
			new HabilidadAtaqueFisico(nombre="Golpe Devastador", danio=20),
			new HabilidadAtaqueMagico(nombre="Ráfaga Mortal", danio=25, costoMana=15),
			new HabilidadCuracion(nombre="Regeneración", curacion=30, costoMana=12)
		]
	}
	
	// Método para que se pueda iniciar combate al "chocar" con el boss
	method fueTocadoPor(jugador) {
		game.say(self, "¡Enfréntate al Parcial de objetos!")
		mundo.cambiarACombate(self)
	}
	
	override method alMorir() {
		salaDelBoss.removerBoss()
		game.say(mundo.heroe(), "¡Has derrotado al Parcial de objetos!")
		game.say(mundo.heroe(), "¡Felicitaciones! Has completado el juego!")
		game.schedule(3000, { => 
			game.say(mundo.heroe(), "Gracias por jugar!")
			game.schedule(2000, { => game.stop() })
		})
	}
}

class Habilidad {
	var nombre
	var costoMana = 0

	method nombre() = nombre
	method costoMana() = costoMana

	// La habilidad se encarga de validar recursos y aplicarse completamente
	method aplicarPor(lanzador, objetivo) {
		if (lanzador.mana() >= self.costoMana()) {
			lanzador.mana(lanzador.mana() - self.costoMana())
			self.ejecutarEfecto(lanzador, objetivo)
		} else {
			game.say(lanzador, "¡No tengo suficiente maná!")
		}
	}

	// Método abstracto que cada habilidad implementa
	method ejecutarEfecto(lanzador, objetivo) {}
	
	// Método que cada habilidad puede redefinir para su tipo de daño
	method esFisica() = true
}

class HabilidadAtaqueFisico inherits Habilidad {
	var danio
	
	override method esFisica() = true
	
	override method ejecutarEfecto(lanzador, objetivo) {
		const defensaObjetivo = objetivo.defensaFisica()
		const ataqueLanzador = lanzador.ataqueFisico()
		const danioReal = (ataqueLanzador + danio - defensaObjetivo).max(1)
		objetivo.recibirDaño(danioReal)
	}
}

class HabilidadAtaqueMagico inherits Habilidad {
	var danio
	
	override method esFisica() = false
	
	override method ejecutarEfecto(lanzador, objetivo) {
		const defensaObjetivo = objetivo.defensaMagica()
		const ataqueLanzador = lanzador.ataqueMagico()
		const danioReal = (ataqueLanzador + danio - defensaObjetivo).max(1)
		objetivo.recibirDaño(danioReal)
	}
}

class HabilidadCuracion inherits Habilidad {
	var curacion
	
	override method ejecutarEfecto(lanzador, objetivo) {
		const vidaRecuperada = curacion
		objetivo.vida((objetivo.vida() + vidaRecuperada).min(objetivo.vidaMaxima()))
		game.say(objetivo, "¡Recuperé " + vidaRecuperada + " puntos de vida!")
	}
}

class HabilidadEscudo inherits Habilidad {
	var defensaExtra
	var turnos
	
	override method ejecutarEfecto(lanzador, objetivo) {
		// Esta sería una habilidad de buff (simplificada para el ejemplo)
		game.say(objetivo, "¡Mi defensa aumentó temporalmente!")
		// En una implementación completa, se podría agregar un sistema de efectos temporales
	}
}

class HabilidadVelocidad inherits Habilidad {
	var velocidadExtra
	
	override method ejecutarEfecto(lanzador, objetivo) {
		game.say(objetivo, "¡Me siento más rápido!")
		// Ejemplo de habilidad que podría aumentar la velocidad temporalmente
	}
}

class Item { 
	var nombre
	method nombre() = nombre
	method nombre(nuevoNombre) { nombre = nuevoNombre }
	method usar(personaje) {} 
}
class Pocion inherits Item { 
	var property  curacion
	method curacion() = curacion
	override method usar(personaje) { 
		personaje.vida((personaje.vida() + curacion).min(personaje.vidaMaxima())) 
	} 
}


