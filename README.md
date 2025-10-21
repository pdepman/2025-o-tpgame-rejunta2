UTN - Facultad Regional Buenos Aires - Materia Paradigmas de Programación

## Equipo de desarrollo:

- Lucas Almiron
- Federico Bremberg
- David Fuertes Mamani
- Franco Marcolin

## Introducción

- Nuestro juego se trata de un juego RPG de combate, donde hay diversas areas, 3 en total, en las que nuestro personaje elegido puede transitar. El objetivo de nuestro protagonista es llegar al nivel 3, donde se encuentra la Boss Fight final, y si gana, finaliza exitosamente el juego. 



## Capturas

- Completar

## Reglas de Juego / Instrucciones

### Instrucciones del juego

- Completar

### Controles:

- Completar

## Explicaciones teóricas y diagramas

En nuestro proyecto aplicamos los principales conceptos del paradigma de objetos vistos en la materia, modelando un pequeño RPG por turnos. A continuación, explicamos las decisiones de diseño y cómo se reflejan los conceptos clave:

Clases y Objetos
Modelamos entidades principales como clases: Personaje, Enemigo, Habilidad, Item, Pocion, Portal, etc. Cada instancia representa un objeto concreto: por ejemplo, el héroe principal es un objeto de la clase Personaje, y cada enemigo que aparece es un objeto de la clase Enemigo. Esto permite reutilizar el comportamiento y los atributos definidos en la clase, pero con estado propio para cada objeto.

Herencia y Polimorfismo
Utilizamos herencia para factorizar comportamientos comunes. Por ejemplo, tanto Personaje como Enemigo heredan de la clase abstracta Luchador, que define atributos y métodos compartidos como vida, ataque, defensa y la lógica de recibir daño. Esto permite que ambos tipos de luchadores sean tratados polimórficamente en el sistema de combate: el sistema no necesita saber si está manejando un héroe o un enemigo, sólo que es un Luchador.

El polimorfismo se ve, por ejemplo, en el método alMorir(), que es redefinido (override) en cada subclase para personalizar la reacción ante la muerte (el héroe termina el juego, el enemigo otorga experiencia). También en las habilidades: el sistema de combate puede invocar usarHabilidad sobre cualquier luchador, y la habilidad concreta sabe cómo aplicarse.

Buscamos bajo acoplamiento: las áreas (bosqueDeMonstruos, puebloDelRey) sólo conocen la interfaz del héroe y del juego, no detalles internos. El sistema de combate no depende de detalles de cada habilidad o luchador, sólo de sus interfaces. La cohesión se mantiene alta: cada clase agrupa atributos y métodos relacionados a su rol.

![Diagrama UML del juego](assets/DE.png)

![Diagrama UML del juego2](assets/UML-TPRejunta2.pdf.png)



