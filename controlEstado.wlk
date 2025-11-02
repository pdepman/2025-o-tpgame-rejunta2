import wollok.game.*
import stages.*
import combateYUI.*
import objectsAndDragons.*

class Estado{
  method onEnter(){}
  method onExit(){}
  method teclas(){}
}
object inicio inherits Estado {
   override method onEnter() {
    game.clear()
    game.title("Mi RPG - Presiona Enter para Comenzar")
    keyboard.enter().onPressDo {mundo.cambiarEstadoControl(explorando)}
    } 
 }

object explorando inherits Estado {
   method intentarCombate() {
      /*if (mundo.areaActual().background() == bosqueDeMonstruos.background()) { 
         game.say(mundo.heroe(), "¡Un enemigo aparece!")
         const enemigo = new Enemigo(nombre="Lobo Feroz", vida=50, vidaMaxima=50, mana=10, manaMaximo=10, ataqueFisico=10, defensaFisica=4, ataqueMagico=0, defensaMagica=2, velocidad=8, expOtorgada=40, monedasOtorgadas=15, position=game.center())
         mundo.iniciarLogicaCombate(enemigo) 
      } else {
         game.say(mundo.heroe(), "Zona tranquila.")
      }
   }*/
   if (mundo.areaActual.background() == bosqueDeMonstruos.background()) {
				const listaEnemigos = [
					new EnemigoSimple(
						nombre="Lobo Salvaje", vida=40, vidaMaxima=40, mana=0, manaMaximo=0, 
						ataqueFisico=8, defensaFisica=3, ataqueMagico=0, defensaMagica=1, 
						velocidad=8, expOtorgada=30, monedasOtorgadas=10, position=game.center()
					),
					new EnemigoSimple(
						nombre="Araña Gigante", vida=30, vidaMaxima=30, mana=0, manaMaximo=0, 
						ataqueFisico=6, defensaFisica=2, ataqueMagico=0, defensaMagica=1, 
						velocidad=8, expOtorgada=20, monedasOtorgadas=5, position=game.center()
					)
				]
				const enemigo = listaEnemigos.anyOne()
				/*game.say(heroe, "¡Un encuentro con " + enemigo.nombre() + "!")*/
				mundo.iniciarLogicaCombate(enemigo)
			} 
    }

   override method onEnter() {
     mundo.recargarAreaActual()
     const titulo = "Explorando - " + mundo.areaActual().background()
     game.title(titulo)
     self.teclas()
   }
   override method teclas() {
     keyboard.w().onPressDo { mundo.moverHeroe(0, 1) }
     keyboard.s().onPressDo { mundo.moverHeroe(0, -1) }
     keyboard.a().onPressDo { mundo.moverHeroe(-1, 0) }
     keyboard.d().onPressDo { mundo.moverHeroe(1, 0) }
     keyboard.e().onPressDo { self.intentarCombate()  }
     keyboard.p().onPressDo { mundo.cambiarEstadoControl(pausa) }
   }
   }

object combate inherits Estado{
   override method onEnter() {
     mundo.recargarAreaActual()
     sistemaDeCombate.refrescarTituloYUI() 
   }
   override method onExit() {
     uiCombate.limpiarPantalla() 
   }
 }
 object pausa inherits Estado{
   override method onEnter() {
     game.title("Pausa (Presiona P para reanudar)")
     keyboard.p().onPressDo {
       mundo.cambiarEstadoControl(mundo.estadoAnteriorAPausa())
     }
   }
 }
object tienda inherits Estado{}

object final inherits Estado {
    var mensaje = "Fin del Juego"
    method setMensaje(msg) { mensaje = msg }

    override method onEnter() {
     game.clear()
     game.title(mensaje + " (Presiona Esc para salir)")
   }
 }