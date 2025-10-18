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
	var position
	var habilidades = []

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
		if (!self.estaVivo()) {
			self.alMorir()
		}
	}
	
	method alMorir() { /* A DEFINIR MAS ADELANTE */ }
	
	method usarHabilidad(habilidad, oponente) {
		if (mana >= habilidad.costoMana()) {
			mana -= habilidad.costoMana()
			habilidad.usarEn(oponente, self)
		} else {
			game.say(self, "¡No tengo suficiente maná!")
		}
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

	method image() = "player.jpg"
	override method alMorir() { 
		game.say(self, "He sido derrotado...")
		game.schedule(2000, { => game.stop() })
	}

	method ganarExp(cantidad) { 
		exp += cantidad
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
    if (inventario.contains(item)) { item.usar(self); inventario.remove(item) } 
  }
	method tieneAccesoASalaBoss() = nivel >= 3
}

class Enemigo inherits Luchador {
	var expOtorgada
	var monedasOtorgadas

	method expOtorgada() = expOtorgada
	method monedasOtorgadas() = monedasOtorgadas
	override method initialize() {
		super()
		habilidades = [new HabilidadAtaque(nombre="Ataque Básico", danio=5, tipoDanio="fisico")]
	}
	method image() = "enemigo.jpg"
	override method alMorir() { 
		sistemaDeCombate.terminarCombate(self) 
  }
}

class Habilidad {
	var nombre
	var costoMana = 0

	method nombre() = nombre
	method costoMana() = costoMana
	method usarEn(objetivo, lanzador) {}
}

class HabilidadAtaque inherits Habilidad {
	var danio
	var tipoDanio
	override method usarEn(objetivo, lanzador) {
		const defensaObjetivo = if (tipoDanio == "fisico") objetivo.defensaFisica() else objetivo.defensaMagica()
		const ataqueLanzador = if (tipoDanio == "fisico") lanzador.ataqueFisico() else lanzador.ataqueMagico()
		const danioReal = (ataqueLanzador + danio - defensaObjetivo).max(1)
		objetivo.recibirDaño(danioReal)
	}
}

class Item { 
	var nombre
	method nombre() = nombre
	method nombre(nuevoNombre) { nombre = nuevoNombre }
	method usar(personaje) {} 
}
class Pocion inherits Item { 
	var curacion
	method curacion() = curacion
	override method usar(personaje) { 
		personaje.vida((personaje.vida() + curacion).min(personaje.vidaMaxima())) 
	} 
}

