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
        if (!self.estaVivo()) { self.alMorir() }
    }
    
    method alMorir() { /* A DEFINIR MAS ADELANTE */ }
    
    method usarHabilidad(habilidad, oponente) {
        habilidad.aplicarPor(self, oponente)
    }

    method aplicarHabilidad(habilidad, objetivo) {
        const costo = habilidad.costoMana()
        if (self.mana() < costo) {
            game.say(self, "¡No tengo suficiente maná!")
        } else {
            self.mana(self.mana() - costo)
            if (habilidad.danio() != null) {
                const esFisica = habilidad.esFisica()
                const defensaObjetivo = if (esFisica) objetivo.defensaFisica() else objetivo.defensaMagica()
                const ataqueLanzador = if (esFisica) self.ataqueFisico() else self.ataqueMagico()
                const danioReal = (ataqueLanzador + habilidad.danio() - defensaObjetivo).max(1)
                objetivo.recibirDaño(danioReal)
            }
            else if (habilidad.curacion() != null) {
                const vidaRecuperada = habilidad.curacion()
                objetivo.vida((objetivo.vida() + vidaRecuperada).min(objetivo.vidaMaxima()))
                game.say(objetivo, "¡Recuperé " + vidaRecuperada + " puntos de vida!")
            }
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
        game.schedule(2000, { => mundo.mostrarGameOver(self) })
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
	method image() =
		if (imagen != null) imagen
		else if (nombre == "Lobo Salvaje") "lobo.png"
		else if (nombre == "Araña Gigante") "araña.png"
		else "finalboss.png"
	override method alMorir() { 
		mundo.combateActual().terminarCombate(self) 
  }
}

class FinalBoss inherits Enemigo {
    override method initialize() {
        super()
        nombre = "Parcial de Objetos"
        vida = 150
        vidaMaxima = 150
        mana = 100
        manaMaximo = 100
        ataqueFisico = 12
        defensaFisica = 8
        ataqueMagico = 18
        defensaMagica = 10
        velocidad = 12
        expOtorgada = 500
        monedasOtorgadas = 1000

        
        habilidades = [
            new HabilidadAtaqueMagico(nombre="Falta de Encapsulamiento", danio=20, costoMana=10),
            new HabilidadAtaqueMagico(nombre="Lluvia de Polimorfismo", danio=25, costoMana=15),
            new HabilidadAtaqueMagico(nombre="Yo No Toco Cositas de Otros", danio=18, costoMana=12),
            new HabilidadCuracion(nombre="Revisión de Código", curacion=40, costoMana=20)
        ]
    }
    
    method fueTocadoPor(jugador) {
        game.say(self, "¡Soy el Parcial de Objetos! ¿Crees que puedes con mis paradigmas?")
        mundo.cambiarACombate(self)
    }
    
    override method alMorir() {
        salaDelBoss.removerBoss()
        game.say(mundo.heroe(), "¡He derrotado al Parcial de Objetos!")
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
    var danio = null
    var curacion = null

    method nombre() = nombre
    method costoMana() = costoMana
    method danio() = danio
    method curacion() = curacion
    method esFisica() = true

    method aplicarPor(lanzador, objetivo) {
        lanzador.aplicarHabilidad(self, objetivo)
    }
}

class HabilidadAtaqueFisico inherits Habilidad {
    override method esFisica() = true
}

class HabilidadAtaqueMagico inherits Habilidad {
    override method esFisica() = false
}

class HabilidadCuracion inherits Habilidad {
    override method esFisica() = false
}

class HabilidadEscudo inherits Habilidad {
    const defensaExtra
    const turnos
}

class HabilidadVelocidad inherits Habilidad {
    const velocidadExtra
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


