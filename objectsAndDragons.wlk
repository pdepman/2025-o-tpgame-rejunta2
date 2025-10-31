import wollok.game.*
import stages.*
import combateYUI.*

class Luchador {
	var nombre
	var property nivel = 1
	var vida
	var property vidaMaxima // LO USAMOS DE REFERENCIA PARA TENER UN MAXIMO DE VIDA 
	var mana
	var property manaMaximo // LO MISMO QUE VIDA MAXIMA
	var property ataqueFisico
	var property defensaFisica
	var property ataqueMagico
	var property defensaMagica
	var property velocidad
	var property position
	var property habilidades = []

	method nombre() = nombre
	method nombre(nuevoNombre) { nombre = nuevoNombre }

	method vida() = vida
	method vida(nuevaVida) { vida = nuevaVida }

	method vidaMaxima() = vidaMaxima

	method mana() = mana
	method mana(nuevoMana) { mana = nuevoMana }

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
		// Delegamos la validación y aplicación de la habilidad a la propia habilidad
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
		habilidades = [new HabilidadAtaque(nombre="Golpe Rápido", danio=8, tipoDanio="fisico"), new HabilidadAtaque(nombre="Bola de Fuego", danio=15, costoMana=10, tipoDanio="magico")]
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

	// Delegación para obtener valores según tipo de daño
	method defensaPara(tipo) = if (tipo == "fisico") self.defensaFisica() else self.defensaMagica()
	method ataquePara(tipo) = if (tipo == "fisico") self.ataqueFisico() else self.ataqueMagico()
}

class Enemigo inherits Luchador {
	var property expOtorgada
	var property monedasOtorgadas

	method expOtorgada() = expOtorgada
	method monedasOtorgadas() = monedasOtorgadas
	override method initialize() {
		super()
		habilidades = [new HabilidadAtaque(nombre="Ataque Básico", danio=5, tipoDanio="fisico")]
	}
	method image() = "enemigo.jpg"
	override method alMorir() { 
		sistemaDeCombate.finalizarCombate(self) 
  }
}


class Habilidad {
	var property nombre
	var property costoMana = 0

	method nombre() = nombre
	method costoMana() = costoMana

	// La habilidad se encarga de validar recursos y aplicarse.
	method aplicarPor(lanzador, objetivo) {
		// delegamos la verificación de recursos a la habilidad
		if (lanzador.mana() >= self.costoMana()) {
			lanzador.mana(lanzador.mana() - self.costoMana())
			self.usarEn(objetivo, lanzador)
		} else {
			game.say(lanzador, "¡No tengo suficiente maná!")
		}
	}

	method usarEn(objetivo, lanzador) {}
}

class HabilidadAtaque inherits Habilidad {
	var property danio
	var property tipoDanio
	override method usarEn(objetivo, lanzador) {
		const defensaObjetivo = objetivo.defensaPara(tipoDanio)
		const ataqueLanzador = lanzador.ataquePara(tipoDanio)
		const danioReal = (ataqueLanzador + danio - defensaObjetivo).max(1)
		objetivo.recibirDaño(danioReal)
	}
}

class Item { 
	var nombre
	method nombre() = nombre
	method nombre(nuevoNombre) { nombre = nuevoNombre }
	method usar(personaje) {} 
	method esPocion() = false
}
class Pocion inherits Item { 
	var property  curacion
	method curacion() = curacion
	override method usar(personaje) { 
		personaje.vida((personaje.vida() + curacion).min(personaje.vidaMaxima())) 
	} 
	override method esPocion() = true
}