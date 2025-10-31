import wollok.game.*
import stages.*
import combateYUI.*
import objectsAndDragons.*

object inicio {
   method procesarTecla(tecla) {
    if (tecla == "enter") {
    mundo.cambiarEstadoControl(explorando)}
    else {
    console.println("Tecla '" + tecla + "' no es 'enter'.")}
   }
   method onEnter() {
     game.clear()
     game.title("Mi RPG - Presiona Enter para Comenzar")
   }
   method onExit() {}
 }

object explorando {
   method procesarTecla(tecla) {
     const teclaLower = tecla.toLower()
     if (teclaLower == "w") { mundo.moverHeroe(0, 1) }
     else if (teclaLower == "s") { mundo.moverHeroe(0, -1) }
     else if (teclaLower == "a") { mundo.moverHeroe(-1, 0) }
     else if (teclaLower == "d") { mundo.moverHeroe(1, 0) }
     else if (teclaLower == "e") { self.intentarCombate() }
     else if (teclaLower == "p") { mundo.cambiarEstadoControl(pausa) }
   }

   method intentarCombate() {
      if (mundo.areaActual() == bosqueDeMonstruos) { // Comparar objetos directamente
         game.say(mundo.heroe(), "¡Un enemigo aparece!")
         const enemigo = new Enemigo(nombre="Lobo Feroz", vida=50, vidaMaxima=50, mana=10, manaMaximo=10, ataqueFisico=10, defensaFisica=4, ataqueMagico=0, defensaMagica=2, velocidad=8, expOtorgada=40, monedasOtorgadas=15, position=game.center())
         mundo.iniciarLogicaCombate(enemigo) // Llama al método del mundo
      } else {
         game.say(mundo.heroe(), "Zona tranquila.")
      }
   }

   method onEnter() {
     mundo.recargarAreaActual()
     game.title("Explorando - " + mundo.areaActual().background())
   }
   method onExit() {}
 }

object combate {
   method procesarTecla(tecla) {
     
     if (sistemaDeCombate.turnoActual() == mundo.heroe()) {
       sistemaDeCombate.procesarAccionHeroeTecla(tecla.toLower())
     } else if (tecla.toLower() == "p") {
         mundo.cambiarEstadoControl(pausa) 
     }
   }
   method onEnter() {
     sistemaDeCombate.refrescarTituloYUI() 
   }
   method onExit() {
     uiCombate.limpiarPantalla() 
   }
 }
 object pausa {
   method procesarTecla(tecla) {
     if (tecla.toLower() == "p") {
       mundo.cambiarEstadoControl(mundo.estadoAnteriorAPausa()) 
     }
   }
   method onEnter() {
     game.title("Pausa (Presiona P para reanudar)")
     
   }
   method onExit() {}
 }

object final {
    var mensaje = "Fin del Juego"
    method setMensaje(msg) { mensaje = msg }
    method procesarTecla(tecla) {
     if (tecla == "escape") { game.stop() }
    }
    method onEnter() {
     game.clear()
     game.title(mensaje + " (Presiona Esc para salir)")
   }
    method onExit() {}
 }