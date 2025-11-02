import wollok.game.*
import stages.*
import combateYUI.*

class Luchador {
	var nombre
	var nivel = 1
	var vida
	var vidaMaxima 
	var mana
	var manaMaximo 
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
		if (!self.estaVivo()) { self.alMorir() }
	}
	
	method alMorir() { }
	
	method usarHabilidad(habilidad, oponente) {
		habilidad.aplicarPor(self, oponente)
	}
}

class Personaje inherits Luchador {
	var exp = 0
	var expSiguienteNivel = 100
	var inventario = []
	var puntosDisponibles = 0
	var monedas = 0
	
	var frame = 1
	var property image = "player_idle_1.png"

	method animarIdle() {
		game.schedule(250, { 
			frame = if (frame == 1) 2 else 1 
			image = "player_idle_" + frame + ".png"
			if (mundo.estadoJuego() == "explorando") { 
				self.animarIdle() 
			}
		})
	}

	method inventario() = inventario
	method exp() = exp
	method exp(nuevaExp) { exp = nuevaExp }
	method expSiguienteNivel() = expSiguienteNivel
	method expSiguienteNivel(nuevoExpSiguienteNivel) { expSiguienteNivel = nuevoExpSiguienteNivel }
	method puntosDisponibles() = puntosDisponibles
	method monedas() = monedas

	override method initialize() {
		super()
		nombre = "Héroe"
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
		inventario = [new Pocion(nombre="Poción Chica", curacion=30)]
		
		image = "player_idle_1.png"
		self.animarIdle()
	}

	override method alMorir() { 
		game.say(self, "He sido derrotado...")
		game.schedule(2000, { => game.stop() })
	}

	method ganarExp(cantidad) { 
		exp += cantidad
		if (exp >= expSiguienteNivel) { self.subirNivel() }
	}
	method ganarMonedas(cantidad) {
		monedas += cantidad
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
		puntosDisponibles += 5
		game.say(self, "¡Subí de nivel! Ahora soy nivel " + nivel) 
	}
	method usarItem(item) { 
		inventario.take(1).forEach({ it => it.usar(self); inventario.remove(it) })
	}
	method tieneAccesoASalaBoss() = nivel >= 10

	method defensaPara(tipo) = if (tipo == "fisico") self.defensaFisica() else self.defensaMagica()
	method ataquePara(tipo) = if (tipo == "fisico") self.ataqueFisico() else self.ataqueMagico()
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
	method image() = "goblin.png" 
	
	override method alMorir() { 
		sistemaDeCombate.terminarCombate(self) 
	}
}

class Habilidad {
	var nombre
	var costoMana = 0
	method nombre() = nombre
	method costoMana() = costoMana
	method aplicarPor(lanzador, objetivo) {
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
	var danio
	var tipoDanio
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
}
class Pocion inherits Item { 
	var property  curacion
	method curacion() = curacion
	override method usar(personaje) { 
		personaje.vida((personaje.vida() + curacion).min(personaje.vidaMaxima())) 
	} 
}

object generadorEnemigos {
	method generarEnemigoSimple() = new EnemigoSimple()
}

class EnemigoSimple inherits Enemigo {
	override method initialize() {
		super()
		nombre = "Goblin"
		vida = 40
		vidaMaxima = 40
		mana = 0 
		manaMaximo = 0 
		ataqueFisico = 7
		defensaFisica = 3
		ataqueMagico = 0 
		defensaMagica = 0 
		velocidad = 5
		expOtorgada = 20
		monedasOtorgadas = 5
		position = game.at(0, 0) 
	}
}

object heroePrincipal inherits Personaje {
	override method initialize() {
		nombre = "Héroe"
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
		inventario = [new Pocion(nombre="Poción Chica", curacion=30)]
		
		frame = 1
		image = "player_idle_1.png"
		self.animarIdle() 
		
		position = game.at(3, 4)
		game.addVisual(self)
	}

	method mover(direccion) {
	}
	
	method curarse() {
		vida = vidaMaxima
		mana = manaMaximo
		game.say(self, "¡Me siento renovado!")
	}
}